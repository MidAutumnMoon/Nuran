use std::ffi::OsStr;
use std::fmt;
use std::fs;
use std::fs::File;
use std::io;
use std::io::Read;
use std::io::Write as _;
use std::path::Components;
use std::path::Path;
use std::path::PathBuf;
use std::process::ExitCode;
use std::time::Duration;

use anyhow::Context as _;
use anyhow::Result;
use anyhow::bail;
use anyhow::ensure;
use base64::Engine as _;
use base64::engine::general_purpose::STANDARD as BASE64;
use serde::Deserialize;
use serde::Serialize;
use sha2::Digest as _;
use sha2::Sha256;
use tempfile::tempdir;
use ureq::Agent;

use crate::git_toplevel;
use crate::kernel_config::KernelConfig;

const PACKAGE_NAME: &str = "linux-cachyos";
const REPOSITORY: &str = "cachyos-v3";
const ARCHITECTURE: &str = "x86_64_v3";
const DASHBOARD_ORIGIN: &str = "https://dashboard.cachyos.org";
const MIRROR_ORIGIN: &str = "https://cdn77.cachyos.org";
const MAX_ARCHIVE_METADATA_SIZE: u64 = 4 * 1024 * 1024;

#[derive(clap::Args)]
#[derive(Debug)]
pub struct Args {
    #[command(subcommand)]
    command: Command,
}

#[derive(clap::Subcommand)]
#[derive(Debug)]
#[expect(
    clippy::doc_markdown,
    reason = "Clap renders these comments as plain text"
)]
enum Command {
    /// Check whether the pinned CachyOS kernel is current.
    Check(PackageLocation),

    /// Download and pin the current CachyOS kernel and headers.
    Update(UpdateArgs),

    /// Convert a Linux kernel `.config` to a JSON object.
    GenConfig(GenConfigArgs),
}

#[derive(clap::Args)]
#[derive(Debug)]
#[expect(
    clippy::doc_markdown,
    reason = "Clap renders these comments as plain text"
)]
struct PackageLocation {
    /// CachyOS package directory.
    ///
    /// Defaults to packages/cachyos below the current Git worktree root.
    #[arg(long, value_name = "DIR")]
    package_dir: Option<PathBuf>,
}

#[derive(clap::Args)]
#[derive(Debug)]
struct UpdateArgs {
    #[command(flatten)]
    location: PackageLocation,

    /// Download and regenerate the pin even when upstream metadata is unchanged.
    #[arg(long)]
    force: bool,
}

#[derive(clap::Args)]
#[derive(Debug)]
struct GenConfigArgs {
    /// Kernel .config path, or - for standard input.
    #[arg(value_name = "CONFIG")]
    input: PathBuf,

    /// Output path, or - for standard output.
    #[arg(long, short, default_value = "-", value_name = "OUTPUT")]
    output: PathBuf,
}

pub fn run(args: Args) -> Result<ExitCode> {
    match args.command {
        Command::Check(location) => check(&location),
        Command::Update(args) => {
            update(&args)?;
            Ok(ExitCode::SUCCESS)
        }
        Command::GenConfig(args) => {
            generate_config(&args)?;
            Ok(ExitCode::SUCCESS)
        }
    }
}

fn check(location: &PackageLocation) -> Result<ExitCode> {
    let files = PackageFiles::resolve(location)?;
    let target = Target::supported();
    let pinned = Release::load(&files.release)?;
    let remote = RemoteRelease::fetch(&HttpClient::new(), &target)?;

    if pinned.matches(&target, &remote) {
        println!(
            "{} {} is up to date.",
            remote.kernel.name, remote.version.package
        );
        Ok(ExitCode::SUCCESS)
    } else {
        println!("{}", change_description(&pinned, &remote));
        Ok(ExitCode::from(3))
    }
}

fn update(args: &UpdateArgs) -> Result<()> {
    let files = PackageFiles::resolve(&args.location)?;
    let target = Target::supported();
    let pinned = Release::load(&files.release)?;
    let client = HttpClient::new();

    eprintln!("Checking {} upstream metadata...", target.package_name);
    let remote = RemoteRelease::fetch(&client, &target)?;
    if !args.force && pinned.matches(&target, &remote) {
        eprintln!(
            "{} {} is already up to date.",
            remote.kernel.name, remote.version.package
        );
        return Ok(());
    }

    let temporary =
        tempdir().context("Failed to create download directory")?;
    let kernel_path = temporary
        .path()
        .join(remote.kernel.file_name(&target, &remote.version.package));
    let headers_path = temporary
        .path()
        .join(remote.headers.file_name(&target, &remote.version.package));

    client.download(
        &remote.kernel.url(&target, &remote.version.package),
        remote.kernel.checksum,
        &kernel_path,
    )?;
    client.download(
        &remote.headers.url(&target, &remote.version.package),
        remote.headers.checksum,
        &headers_path,
    )?;

    let extracted =
        inspect_release_archives(&kernel_path, &headers_path, &remote)?;
    let generated_config = KernelConfig::parse(&extracted.config)
        .context("Failed to parse the headers package .config")?;
    let config_hash = Checksum::digest(&extracted.config);
    let release = Release::from_remote(
        &target,
        &remote,
        &extracted.mod_dir_version,
        config_hash,
    );
    let config_json = generated_config.render_json()?;
    let release_json = release.render_json()?;

    let config_changed =
        write_if_changed(&files.config, config_json.as_bytes())?;
    let release_changed =
        write_if_changed(&files.release, release_json.as_bytes())?;

    if config_changed || release_changed {
        eprintln!(
            "Pinned {} {} ({} config options, module directory {}).",
            remote.kernel.name,
            remote.version.package,
            generated_config.len(),
            extracted.mod_dir_version,
        );
        println!(
            "## CachyOS kernel\n\n{}",
            change_description(&pinned, &remote)
        );
    } else {
        eprintln!(
            "Regenerated files are unchanged for {} {}.",
            remote.kernel.name, remote.version.package
        );
    }

    Ok(())
}

fn generate_config(args: &GenConfigArgs) -> Result<()> {
    let raw = read_input(&args.input)?;
    let config = KernelConfig::parse(&raw)?;
    let rendered = config.render_json()?;

    if args.output == Path::new("-") {
        io::stdout().lock().write_all(rendered.as_bytes()).context(
            "Failed to write generated config to standard output",
        )?;
    } else {
        fs::write(&args.output, rendered).with_context(|| {
            format!("Failed to write {}", args.output.display())
        })?;
    }

    eprintln!(
        "Generated {} options -> {}",
        config.len(),
        display_stdio_path(&args.output, "stdout")
    );
    eprintln!("Input .config sha256: {}", Checksum::digest(&raw));
    Ok(())
}

fn read_input(path: &Path) -> Result<Vec<u8>> {
    if path == Path::new("-") {
        let mut raw = Vec::new();
        io::stdin()
            .lock()
            .read_to_end(&mut raw)
            .context("Failed to read kernel config from standard input")?;
        Ok(raw)
    } else {
        fs::read(path)
            .with_context(|| format!("Failed to read {}", path.display()))
    }
}

fn display_stdio_path(path: &Path, standard: &'static str) -> String {
    if path == Path::new("-") {
        standard.to_owned()
    } else {
        path.display().to_string()
    }
}

struct PackageFiles {
    release: PathBuf,
    config: PathBuf,
}

impl PackageFiles {
    fn resolve(location: &PackageLocation) -> Result<Self> {
        let directory = match &location.package_dir {
            Some(directory) => directory.clone(),
            None => git_toplevel()
                .context("Failed to locate the Git worktree")?
                .join("packages/cachyos"),
        };
        ensure!(
            directory.is_dir(),
            "CachyOS package directory does not exist: {}",
            directory.display()
        );

        let release = directory.join("release.json");
        let config = directory.join("config.json");
        ensure!(
            release.is_file(),
            "CachyOS release file does not exist: {}",
            release.display()
        );

        Ok(Self { release, config })
    }
}

#[derive(Clone, Copy)]
struct Target {
    package_name: &'static str,
    repository: &'static str,
    architecture: &'static str,
}

impl Target {
    const fn supported() -> Self {
        Self {
            package_name: PACKAGE_NAME,
            repository: REPOSITORY,
            architecture: ARCHITECTURE,
        }
    }

    fn dashboard_url(self, package_name: &str) -> String {
        format!(
            "{DASHBOARD_ORIGIN}/package/{}/{}/{package_name}",
            self.repository, self.architecture
        )
    }

    fn mirror_base_url(self) -> String {
        format!(
            "{MIRROR_ORIGIN}/repo/{}/{}",
            self.architecture, self.repository
        )
    }
}

struct HttpClient {
    agent: Agent,
}

impl HttpClient {
    fn new() -> Self {
        let config = Agent::config_builder()
            .timeout_connect(Some(Duration::from_secs(30)))
            .timeout_global(Some(Duration::from_mins(15)))
            .user_agent(concat!("ci-driver/", env!("CARGO_PKG_VERSION")))
            .build();
        Self {
            agent: config.into(),
        }
    }

    fn get_text(&self, url: &str) -> Result<String> {
        let mut response = self
            .agent
            .get(url)
            .call()
            .with_context(|| format!("Failed to fetch {url}"))?;
        response
            .body_mut()
            .read_to_string()
            .with_context(|| format!("Failed to read response from {url}"))
    }

    fn download(
        &self,
        url: &str,
        expected: Checksum,
        destination: &Path,
    ) -> Result<()> {
        eprintln!("Downloading {url}");
        let mut response = self
            .agent
            .get(url)
            .call()
            .with_context(|| format!("Failed to download {url}"))?;
        let mut source = response.body_mut().as_reader();
        let mut output = File::create(destination).with_context(|| {
            format!("Failed to create {}", destination.display())
        })?;
        let mut hasher = Sha256::new();
        let mut buffer = vec![0_u8; 1024 * 1024];
        let mut size = 0_u64;

        loop {
            let read = source.read(&mut buffer).with_context(|| {
                format!("Failed while downloading {url}")
            })?;
            if read == 0 {
                break;
            }
            let chunk = buffer
                .get(..read)
                .context("HTTP reader returned an invalid byte count")?;
            hasher.update(chunk);
            output.write_all(chunk).with_context(|| {
                format!("Failed to write {}", destination.display())
            })?;
            size +=
                u64::try_from(read).context("Download size overflow")?;
        }
        output.flush().with_context(|| {
            format!("Failed to flush {}", destination.display())
        })?;

        let actual = Checksum(hasher.finalize().into());
        ensure!(
            actual == expected,
            "Checksum mismatch for {url}: expected {expected}, got {actual}"
        );
        eprintln!("Verified {expected} ({size} bytes).");
        Ok(())
    }
}

struct RemoteRelease {
    version: ReleaseVersion,
    kernel: RemoteArtifact,
    headers: RemoteArtifact,
}

impl RemoteRelease {
    fn fetch(client: &HttpClient, target: &Target) -> Result<Self> {
        let kernel =
            DashboardPackage::fetch(client, *target, target.package_name)?;
        let headers_name = format!("{}-headers", target.package_name);
        let headers =
            DashboardPackage::fetch(client, *target, &headers_name)?;
        ensure!(
            kernel.package_version == headers.package_version,
            "CachyOS kernel and headers versions differ: {} vs {}",
            kernel.package_version,
            headers.package_version
        );
        let version = ReleaseVersion::parse(kernel.package_version)?;

        Ok(Self {
            version,
            kernel: kernel.artifact,
            headers: headers.artifact,
        })
    }
}

struct ReleaseVersion {
    upstream: String,
    package: String,
}

impl ReleaseVersion {
    fn parse(package: String) -> Result<Self> {
        let end = package
            .bytes()
            .position(|byte| !(byte.is_ascii_digit() || byte == b'.'))
            .unwrap_or(package.len());
        let upstream = package
            .get(..end)
            .context("Package version prefix is not valid UTF-8")?;
        let mut components = upstream.split('.');
        for component_name in ["major", "minor", "patch"] {
            let component = components.next().with_context(|| {
                format!(
                    "CachyOS package version {package:?} has no {component_name} component"
                )
            })?;
            ensure!(
                !component.is_empty()
                    && component.bytes().all(|byte| byte.is_ascii_digit()),
                "Invalid {component_name} component in CachyOS package version {package:?}"
            );
        }
        ensure!(
            components.next().is_none() && end < package.len(),
            "Invalid CachyOS package version {package:?}"
        );

        Ok(Self {
            upstream: upstream.to_owned(),
            package,
        })
    }
}

struct DashboardPackage {
    package_version: String,
    artifact: RemoteArtifact,
}

impl DashboardPackage {
    fn fetch(
        client: &HttpClient,
        target: Target,
        expected_name: &str,
    ) -> Result<Self> {
        let url = target.dashboard_url(expected_name);
        let html = client.get_text(&url)?;
        let name = dashboard_string(&html, "pkg_name")?.to_owned();
        ensure!(
            name == expected_name,
            "Dashboard at {url} describes {name}, expected {expected_name}"
        );
        let package_version =
            dashboard_string(&html, "pkg_version")?.to_owned();
        let checksum =
            dashboard_string(&html, "pkg_sha256sum")?
                .parse()
                .with_context(|| format!("Invalid checksum in {url}"))?;

        Ok(Self {
            package_version,
            artifact: RemoteArtifact { name, checksum },
        })
    }
}

struct RemoteArtifact {
    name: String,
    checksum: Checksum,
}

impl RemoteArtifact {
    fn file_name(&self, target: &Target, package_version: &str) -> String {
        format!(
            "{}-{package_version}-{}.pkg.tar.zst",
            self.name, target.architecture
        )
    }

    fn url(&self, target: &Target, package_version: &str) -> String {
        format!(
            "{}/{}",
            target.mirror_base_url(),
            self.file_name(target, package_version)
        )
    }
}

fn dashboard_string<'html>(
    html: &'html str,
    field: &str,
) -> Result<&'html str> {
    let marker = format!(r#"{field}:""#);
    let value = html
        .split_once(&marker)
        .map(|(_, value)| value)
        .with_context(|| format!("Dashboard payload has no {field}"))?;
    let value =
        value.split_once('"').map(|(value, _)| value).with_context(
            || format!("Dashboard payload has an unterminated {field}"),
        )?;
    ensure!(
        !value.contains('\\'),
        "Dashboard payload has an escaped {field}, which is unsupported"
    );
    Ok(value)
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct Checksum([u8; 32]);

impl Checksum {
    fn digest(bytes: &[u8]) -> Self {
        Self(Sha256::digest(bytes).into())
    }

    fn sri(self) -> String {
        format!("sha256-{}", BASE64.encode(self.0))
    }
}

impl std::str::FromStr for Checksum {
    type Err = anyhow::Error;

    fn from_str(value: &str) -> Result<Self> {
        ensure!(
            value.len() == 64,
            "Expected 64 hexadecimal characters, got {}",
            value.len()
        );
        let mut bytes = [0_u8; 32];
        let (pairs, remainder) = value.as_bytes().as_chunks::<2>();
        ensure!(
            remainder.is_empty(),
            "Hexadecimal checksum has an incomplete byte"
        );
        for (byte, &[high, low]) in bytes.iter_mut().zip(pairs) {
            *byte =
                (hex_nibble(high, value)? << 4) | hex_nibble(low, value)?;
        }
        Ok(Self(bytes))
    }
}

fn hex_nibble(byte: u8, checksum: &str) -> Result<u8> {
    match byte {
        b'0'..=b'9' => Ok(byte - b'0'),
        b'a'..=b'f' => Ok(byte - b'a' + 10),
        b'A'..=b'F' => Ok(byte - b'A' + 10),
        _ => bail!("Invalid hexadecimal checksum {checksum:?}"),
    }
}

impl fmt::Display for Checksum {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for byte in self.0 {
            write!(f, "{byte:02x}")?;
        }
        Ok(())
    }
}

#[derive(Deserialize, Serialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct Release {
    pname: String,
    version: String,
    package_version: String,
    architecture: String,
    mod_dir_version: String,
    kernel: ReleasePackage,
    headers: ReleasePackage,
    config_hash: String,
    #[serde(rename = "isLTS")]
    is_lts: bool,
    is_zen: bool,
}

#[derive(Deserialize, Serialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct ReleasePackage {
    package_name: String,
    url: String,
    hash: String,
}

impl Release {
    fn from_remote(
        target: &Target,
        remote: &RemoteRelease,
        mod_dir_version: &str,
        config_hash: Checksum,
    ) -> Self {
        Self {
            pname: target.package_name.to_owned(),
            version: remote.version.upstream.clone(),
            package_version: remote.version.package.clone(),
            architecture: target.architecture.to_owned(),
            mod_dir_version: mod_dir_version.to_owned(),
            kernel: ReleasePackage::from_remote(
                &remote.kernel,
                target,
                &remote.version.package,
            ),
            headers: ReleasePackage::from_remote(
                &remote.headers,
                target,
                &remote.version.package,
            ),
            config_hash: config_hash.to_string(),
            is_lts: false,
            is_zen: false,
        }
    }

    fn load(path: &Path) -> Result<Self> {
        let raw = fs::read(path).with_context(|| {
            format!("Failed to read {}", path.display())
        })?;
        serde_json::from_slice(&raw)
            .with_context(|| format!("Failed to parse {}", path.display()))
    }

    fn render_json(&self) -> Result<String> {
        let mut output = serde_json::to_string_pretty(self)
            .context("Failed to serialize CachyOS release metadata")?;
        output.push('\n');
        Ok(output)
    }

    fn matches(&self, target: &Target, remote: &RemoteRelease) -> bool {
        self.pname == target.package_name
            && self.version == remote.version.upstream
            && self.package_version == remote.version.package
            && self.architecture == target.architecture
            && self.kernel.matches(
                &remote.kernel,
                target,
                &remote.version.package,
            )
            && self.headers.matches(
                &remote.headers,
                target,
                &remote.version.package,
            )
    }

    fn label(&self) -> String {
        format!("{} {}", self.pname, self.package_version)
    }
}

impl ReleasePackage {
    fn from_remote(
        remote: &RemoteArtifact,
        target: &Target,
        package_version: &str,
    ) -> Self {
        Self {
            package_name: remote.name.clone(),
            url: remote.url(target, package_version),
            hash: remote.checksum.sri(),
        }
    }

    fn matches(
        &self,
        remote: &RemoteArtifact,
        target: &Target,
        package_version: &str,
    ) -> bool {
        self.package_name == remote.name
            && self.url == remote.url(target, package_version)
            && self.hash == remote.checksum.sri()
    }
}

fn change_description(pinned: &Release, remote: &RemoteRelease) -> String {
    let old = pinned.label();
    let new = format!("{} {}", remote.kernel.name, remote.version.package);
    if old == new {
        format!("Refreshed `{new}` because the upstream package changed.")
    } else {
        format!("Updated `{old}` to `{new}`.")
    }
}

struct ArchiveInspection {
    identity: PackageIdentity,
    module_dir: String,
    config: Option<Vec<u8>>,
    build_version: Option<String>,
}

struct PackageIdentity {
    name: String,
    version: String,
}

#[derive(Clone, Copy)]
enum ArchiveMember {
    Other,
    Config,
    BuildVersion,
}

fn inspect_archive(path: &Path) -> Result<ArchiveInspection> {
    let file = File::open(path)
        .with_context(|| format!("Failed to open {}", path.display()))?;
    let decoder =
        zstd::stream::read::Decoder::new(file).with_context(|| {
            format!("Failed to decompress {}", path.display())
        })?;
    let mut archive = tar::Archive::new(decoder);
    let mut package_info = None;
    let mut module_dir = None;
    let mut config = None;
    let mut build_version = None;

    for entry in archive.entries().with_context(|| {
        format!("Failed to read archive index from {}", path.display())
    })? {
        let mut entry = entry.with_context(|| {
            format!("Failed to read an entry from {}", path.display())
        })?;
        let entry_path = entry
            .path()
            .with_context(|| {
                format!("Invalid path in {}", path.display())
            })?
            .into_owned();

        if is_root_file(&entry_path, OsStr::new(".PKGINFO"))? {
            ensure!(
                package_info.is_none(),
                "Duplicate .PKGINFO in {}",
                path.display()
            );
            package_info =
                Some(read_archive_metadata(&mut entry, &entry_path)?);
            continue;
        }

        let Some((candidate_module_dir, member)) =
            module_member(&entry_path)?
        else {
            continue;
        };
        let candidate_module_dir =
            candidate_module_dir.to_str().with_context(|| {
                format!("Non-UTF-8 module directory in {}", path.display())
            })?;
        if let Some(module_dir) = &module_dir {
            ensure!(
                module_dir == candidate_module_dir,
                "Expected one module directory in {}, found {module_dir:?} and {candidate_module_dir:?}",
                path.display()
            );
        } else {
            module_dir = Some(candidate_module_dir.to_owned());
        }

        if !entry.header().entry_type().is_file() {
            continue;
        }
        match member {
            ArchiveMember::Other => (),
            ArchiveMember::Config => {
                ensure!(
                    config.is_none(),
                    "Duplicate headers .config in {}",
                    path.display()
                );
                config =
                    Some(read_archive_metadata(&mut entry, &entry_path)?);
            }
            ArchiveMember::BuildVersion => {
                ensure!(
                    build_version.is_none(),
                    "Duplicate headers build/version in {}",
                    path.display()
                );
                let raw = read_archive_metadata(&mut entry, &entry_path)?;
                build_version = Some(
                    String::from_utf8(raw)
                        .with_context(|| {
                            format!("Non-UTF-8 {}", entry_path.display())
                        })?
                        .trim()
                        .to_owned(),
                );
            }
        }
    }

    let package_info = package_info.with_context(|| {
        format!("Missing .PKGINFO in {}", path.display())
    })?;
    Ok(ArchiveInspection {
        identity: PackageIdentity::parse(&package_info)?,
        module_dir: module_dir.with_context(|| {
            format!("No module directory in {}", path.display())
        })?,
        config,
        build_version,
    })
}

fn read_archive_metadata<R>(
    entry: &mut tar::Entry<'_, R>,
    path: &Path,
) -> Result<Vec<u8>>
where
    R: Read,
{
    ensure!(
        entry.size() <= MAX_ARCHIVE_METADATA_SIZE,
        "Archive metadata {} is unexpectedly large ({} bytes)",
        path.display(),
        entry.size()
    );
    let capacity = usize::try_from(entry.size())
        .context("Archive metadata size does not fit in memory")?;
    let mut raw = Vec::with_capacity(capacity);
    entry.read_to_end(&mut raw).with_context(|| {
        format!("Failed to read {} from archive", path.display())
    })?;
    Ok(raw)
}

fn is_root_file(path: &Path, expected: &OsStr) -> Result<bool> {
    let mut components = path.components();
    Ok(next_normal_component(&mut components)? == Some(expected)
        && next_normal_component(&mut components)?.is_none())
}

fn module_member(path: &Path) -> Result<Option<(&OsStr, ArchiveMember)>> {
    let mut components = path.components();
    if next_normal_component(&mut components)? != Some(OsStr::new("usr"))
        || next_normal_component(&mut components)?
            != Some(OsStr::new("lib"))
        || next_normal_component(&mut components)?
            != Some(OsStr::new("modules"))
    {
        return Ok(None);
    }

    let Some(module_dir) = next_normal_component(&mut components)? else {
        return Ok(None);
    };
    let Some(child) = next_normal_component(&mut components)? else {
        return Ok(None);
    };
    if child != OsStr::new("build") {
        return Ok(Some((module_dir, ArchiveMember::Other)));
    }

    let member = match (
        next_normal_component(&mut components)?,
        next_normal_component(&mut components)?,
    ) {
        (Some(name), None) if name == OsStr::new(".config") => {
            ArchiveMember::Config
        }
        (Some(name), None) if name == OsStr::new("version") => {
            ArchiveMember::BuildVersion
        }
        _ => ArchiveMember::Other,
    };
    Ok(Some((module_dir, member)))
}

fn next_normal_component<'path>(
    components: &mut Components<'path>,
) -> Result<Option<&'path OsStr>> {
    loop {
        match components.next() {
            Some(std::path::Component::Normal(component)) => {
                return Ok(Some(component));
            }
            Some(std::path::Component::CurDir) => (),
            Some(component) => {
                bail!("Unsupported archive path component {component:?}")
            }
            None => return Ok(None),
        }
    }
}

impl PackageIdentity {
    fn parse(package_info: &[u8]) -> Result<Self> {
        let package_info = std::str::from_utf8(package_info)
            .context("Package .PKGINFO is not valid UTF-8")?;
        let mut name = None;
        let mut version = None;

        for line in package_info.lines() {
            if let Some(value) = line.strip_prefix("pkgname = ") {
                ensure!(name.is_none(), "Duplicate pkgname in .PKGINFO");
                name = Some(value.to_owned());
            }
            if let Some(value) = line.strip_prefix("pkgver = ") {
                ensure!(version.is_none(), "Duplicate pkgver in .PKGINFO");
                version = Some(value.to_owned());
            }
        }

        Ok(Self {
            name: name.context("Missing pkgname in .PKGINFO")?,
            version: version.context("Missing pkgver in .PKGINFO")?,
        })
    }

    fn verify(
        &self,
        expected: &RemoteArtifact,
        expected_version: &ReleaseVersion,
    ) -> Result<()> {
        ensure!(
            self.name == expected.name,
            "Archive package is {}, expected {}",
            self.name,
            expected.name
        );
        ensure!(
            self.version == expected_version.package,
            "Archive version is {}, expected {}",
            self.version,
            expected_version.package
        );
        Ok(())
    }
}

struct ExtractedRelease {
    mod_dir_version: String,
    config: Vec<u8>,
}

fn inspect_release_archives(
    kernel_path: &Path,
    headers_path: &Path,
    remote: &RemoteRelease,
) -> Result<ExtractedRelease> {
    let kernel =
        inspect_archive(kernel_path).context("Invalid kernel package")?;
    let headers = inspect_archive(headers_path)
        .context("Invalid headers package")?;
    kernel.identity.verify(&remote.kernel, &remote.version)?;
    headers.identity.verify(&remote.headers, &remote.version)?;
    ensure!(
        kernel.module_dir == headers.module_dir,
        "Kernel and headers module directories differ: {:?} vs {:?}",
        kernel.module_dir,
        headers.module_dir
    );
    let build_version = headers
        .build_version
        .context("Headers package has no build/version")?;
    ensure!(
        build_version == kernel.module_dir,
        "Headers build/version {build_version:?} does not match module directory {:?}",
        kernel.module_dir
    );

    Ok(ExtractedRelease {
        mod_dir_version: kernel.module_dir,
        config: headers
            .config
            .context("Headers package has no build/.config")?,
    })
}

fn write_if_changed(path: &Path, content: &[u8]) -> Result<bool> {
    if fs::read(path).is_ok_and(|current| current == content) {
        return Ok(false);
    }
    fs::write(path, content)
        .with_context(|| format!("Failed to write {}", path.display()))?;
    Ok(true)
}

#[cfg(test)]
#[expect(clippy::unwrap_used, reason = "Tests")]
mod tests {
    use std::str::FromStr as _;

    use super::Checksum;
    use super::ReleaseVersion;
    use super::dashboard_string;

    #[test]
    fn parses_dashboard_package_fields() {
        let payload = r#"before pkg_name:"linux-cachyos",pkg_sha256sum:"0000000000000000000000000000000000000000000000000000000000000000",pkg_version:"7.2.3-1" after"#;

        assert_eq!(
            dashboard_string(payload, "pkg_name").unwrap(),
            "linux-cachyos"
        );
        assert_eq!(
            dashboard_string(payload, "pkg_version").unwrap(),
            "7.2.3-1"
        );
    }

    #[test]
    fn converts_hex_checksum_to_nix_sri() {
        let checksum = Checksum::from_str(
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        )
        .unwrap();

        assert_eq!(
            checksum.sri(),
            "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="
        );
    }

    #[test]
    fn derives_kernel_version_from_package_version() {
        assert_eq!(
            ReleaseVersion::parse("7.2.3-1".to_owned())
                .unwrap()
                .upstream,
            "7.2.3"
        );
        assert!(ReleaseVersion::parse("7.2-1".to_owned()).is_err());
        assert!(ReleaseVersion::parse("7.2.3".to_owned()).is_err());
    }
}
