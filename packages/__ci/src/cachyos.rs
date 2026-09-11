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
    ///
    /// Exits 3 when the pinned release is stale.
    Check {
        /// Package directory. Defaults to packages/cachyos in this worktree.
        #[arg(long, value_name = "DIR")]
        package_dir: Option<PathBuf>,
    },

    /// Download and pin the current CachyOS kernel and headers.
    Update {
        /// Package directory. Defaults to packages/cachyos in this worktree.
        #[arg(long, value_name = "DIR")]
        package_dir: Option<PathBuf>,

        /// Regenerate the pin even when upstream metadata is unchanged.
        #[arg(long)]
        force: bool,
    },

    /// Convert a Linux kernel `.config` to a JSON object.
    GenConfig {
        /// Kernel .config path, or - for standard input.
        #[arg(value_name = "CONFIG")]
        input: PathBuf,

        /// Output path, or - for standard output.
        #[arg(long, short, default_value = "-", value_name = "OUTPUT")]
        output: PathBuf,
    },
}

pub fn run(args: Args) -> Result<ExitCode> {
    match args.command {
        Command::Check { package_dir } => check(package_dir.as_deref()),
        Command::Update { package_dir, force } => {
            update(package_dir.as_deref(), force)?;
            Ok(ExitCode::SUCCESS)
        }
        Command::GenConfig { input, output } => {
            generate_config(&input, &output)?;
            Ok(ExitCode::SUCCESS)
        }
    }
}

fn check(package_dir: Option<&Path>) -> Result<ExitCode> {
    let directory = package_directory(package_dir)?;
    let pinned = Release::load(&directory.join("release.json"))?;
    let upstream = fetch_upstream(&http_agent())?;

    if pinned.matches_upstream(&upstream) {
        println!("{} is up to date.", upstream.label());
        Ok(ExitCode::SUCCESS)
    } else {
        println!("{}", change_description(&pinned, &upstream));
        Ok(ExitCode::from(3))
    }
}

fn update(package_dir: Option<&Path>, force: bool) -> Result<()> {
    let directory = package_directory(package_dir)?;
    let release_path = directory.join("release.json");
    let config_path = directory.join("config.json");
    let pinned = Release::load(&release_path)?;
    let agent = http_agent();

    eprintln!("Checking the {REPOSITORY} repository database...");
    let upstream = fetch_upstream(&agent)?;
    if !force && pinned.matches_upstream(&upstream) {
        eprintln!("{} is already up to date.", upstream.label());
        return Ok(());
    }

    let temporary =
        tempdir().context("Failed to create download directory")?;
    let kernel_path = temporary.path().join(upstream.kernel.file_name()?);
    let headers_path =
        temporary.path().join(upstream.headers.file_name()?);
    download_verified(&agent, &upstream.kernel, &kernel_path)?;
    download_verified(&agent, &upstream.headers, &headers_path)?;

    let extracted =
        inspect_release_archives(&kernel_path, &headers_path, &upstream)?;
    let config = KernelConfig::parse(&extracted.config)
        .context("Failed to parse the headers package .config")?;
    let description = change_description(&pinned, &upstream);
    let UpstreamRelease {
        version,
        package_version,
        kernel,
        headers,
    } = upstream;
    let release = Release {
        pname: PACKAGE_NAME.to_owned(),
        version,
        package_version,
        architecture: ARCHITECTURE.to_owned(),
        mod_dir_version: extracted.mod_dir_version,
        kernel,
        headers,
        config_hash: Checksum::digest(&extracted.config).to_string(),
        is_lts: false,
        is_zen: false,
    };

    let config_json = config.render_json()?;
    let release_json = release.render_json()?;
    let config_changed =
        write_if_changed(&config_path, config_json.as_bytes())?;
    let release_changed =
        write_if_changed(&release_path, release_json.as_bytes())?;

    if config_changed || release_changed {
        eprintln!(
            "Pinned {} ({} config options, module directory {}).",
            release.label(),
            config.len(),
            release.mod_dir_version,
        );
        println!("## CachyOS kernel\n\n{description}");
    } else {
        eprintln!(
            "Regenerated files are unchanged for {}.",
            release.label()
        );
    }

    Ok(())
}

fn generate_config(input: &Path, output: &Path) -> Result<()> {
    let raw = if input == Path::new("-") {
        let mut raw = Vec::new();
        io::stdin()
            .lock()
            .read_to_end(&mut raw)
            .context("Failed to read kernel config from standard input")?;
        raw
    } else {
        fs::read(input).with_context(|| {
            format!("Failed to read {}", input.display())
        })?
    };
    let config = KernelConfig::parse(&raw)?;
    let rendered = config.render_json()?;

    let output_name = if output == Path::new("-") {
        io::stdout().lock().write_all(rendered.as_bytes()).context(
            "Failed to write generated config to standard output",
        )?;
        "stdout".to_owned()
    } else {
        fs::write(output, rendered).with_context(|| {
            format!("Failed to write {}", output.display())
        })?;
        output.display().to_string()
    };

    eprintln!("Generated {} options -> {output_name}", config.len());
    eprintln!("Input .config sha256: {}", Checksum::digest(&raw));
    Ok(())
}

fn package_directory(requested: Option<&Path>) -> Result<PathBuf> {
    let directory = match requested {
        Some(directory) => directory.to_owned(),
        None => git_toplevel()
            .context("Failed to locate the Git worktree")?
            .join("packages/cachyos"),
    };
    ensure!(
        directory.is_dir(),
        "CachyOS package directory does not exist: {}",
        directory.display()
    );
    Ok(directory)
}

struct UpstreamRelease {
    version: String,
    package_version: String,
    kernel: Package,
    headers: Package,
}

impl UpstreamRelease {
    fn label(&self) -> String {
        format!("{PACKAGE_NAME} {}", self.package_version)
    }
}

fn fetch_upstream(agent: &Agent) -> Result<UpstreamRelease> {
    let (kernel, headers) = fetch_kernel_and_headers(agent)?;
    ensure!(
        kernel.version == headers.version,
        "CachyOS kernel and headers versions differ: {} vs {}",
        kernel.version,
        headers.version
    );

    let package_version = kernel.version.clone();
    let version = kernel_version(&package_version)?.to_owned();
    let kernel = kernel.into_package()?;
    let headers = headers.into_package()?;
    Ok(UpstreamRelease {
        version,
        package_version,
        kernel,
        headers,
    })
}

/// A package entry of the mirror's pacman repository database.
#[derive(Debug)]
struct RepoPackage {
    name: String,
    version: String,
    architecture: String,
    file_name: String,
    checksum: Checksum,
}

impl RepoPackage {
    fn into_package(self) -> Result<Package> {
        ensure!(
            self.architecture == ARCHITECTURE,
            "The {REPOSITORY} repository lists architecture {} for {}, expected {ARCHITECTURE}",
            self.architecture,
            self.name
        );
        Ok(Package {
            name: self.name,
            url: format!(
                "{MIRROR_ORIGIN}/repo/{ARCHITECTURE}/{REPOSITORY}/{}",
                self.file_name
            ),
            hash: self.checksum.sri(),
        })
    }
}

/// Download the pacman repository database of the mirror, which describes
/// exactly the packages the mirror currently serves, and select the pinned
/// kernel and its headers from it.
fn fetch_kernel_and_headers(
    agent: &Agent,
) -> Result<(RepoPackage, RepoPackage)> {
    let url = format!(
        "{MIRROR_ORIGIN}/repo/{ARCHITECTURE}/{REPOSITORY}/{REPOSITORY}.db"
    );
    let mut response = agent
        .get(&url)
        .call()
        .with_context(|| format!("Failed to fetch {url}"))?;
    let bytes = response
        .body_mut()
        .read_to_vec()
        .with_context(|| format!("Failed to read {url}"))?;
    select_kernel_and_headers(&bytes, &url)
}

/// Select the pinned kernel and its headers from a pacman repository
/// database.
fn select_kernel_and_headers(
    bytes: &[u8],
    url: &str,
) -> Result<(RepoPackage, RepoPackage)> {
    let headers_name = format!("{PACKAGE_NAME}-headers");
    let decoder = zstd::stream::read::Decoder::new(bytes)
        .with_context(|| format!("Failed to decompress {url}"))?;
    let mut archive = tar::Archive::new(decoder);
    let mut kernel = None;
    let mut headers = None;

    for entry in archive.entries().with_context(|| {
        format!("Failed to read archive index from {url}")
    })? {
        let mut entry = entry.with_context(|| {
            format!("Failed to read an entry from {url}")
        })?;
        let entry_path = entry
            .path()
            .with_context(|| format!("Invalid path in {url}"))?
            .into_owned();
        if !is_desc_path(&entry_path)? {
            continue;
        }
        let raw = read_archive_metadata(&mut entry, &entry_path)?;
        let package = parse_repo_desc(&raw).with_context(|| {
            format!("Invalid {}", entry_path.display())
        })?;
        match package.name.as_str() {
            PACKAGE_NAME => {
                ensure!(
                    kernel.is_none(),
                    "Duplicate {PACKAGE_NAME} in {url}"
                );
                kernel = Some(package);
            }
            name if name == headers_name => {
                ensure!(
                    headers.is_none(),
                    "Duplicate {headers_name} in {url}"
                );
                headers = Some(package);
            }
            _ => (),
        }
    }

    Ok((
        kernel.with_context(|| {
            format!(
                "{PACKAGE_NAME} is missing from the {REPOSITORY} repository database"
            )
        })?,
        headers.with_context(|| {
            format!(
                "{headers_name} is missing from the {REPOSITORY} repository database"
            )
        })?,
    ))
}

fn parse_repo_desc(raw: &[u8]) -> Result<RepoPackage> {
    let text = std::str::from_utf8(raw)
        .context("Repository desc is not valid UTF-8")?
        .trim_end_matches('\n');
    let mut name = None;
    let mut version = None;
    let mut architecture = None;
    let mut file_name = None;
    let mut checksum = None;

    for block in text.split("\n\n") {
        let Some((header, value)) = block.split_once('\n') else {
            continue;
        };
        let Some(field) = header
            .strip_prefix('%')
            .and_then(|field| field.strip_suffix('%'))
        else {
            bail!("Malformed field header {header:?} in repository desc");
        };
        match field {
            "ARCH" => assign_desc_field(&mut architecture, field, value)?,
            "FILENAME" => assign_desc_field(&mut file_name, field, value)?,
            "NAME" => assign_desc_field(&mut name, field, value)?,
            "SHA256SUM" => assign_desc_field(&mut checksum, field, value)?,
            "VERSION" => assign_desc_field(&mut version, field, value)?,
            _ => (),
        }
    }

    let name = name.context("Repository desc has no %NAME%")?;
    let checksum = checksum
        .context("Repository desc has no %SHA256SUM%")?
        .parse()
        .with_context(|| format!("Invalid %SHA256SUM% for {name}"))?;
    Ok(RepoPackage {
        name,
        checksum,
        version: version.context("Repository desc has no %VERSION%")?,
        architecture: architecture
            .context("Repository desc has no %ARCH%")?,
        file_name: file_name
            .context("Repository desc has no %FILENAME%")?,
    })
}

fn assign_desc_field(
    slot: &mut Option<String>,
    field: &str,
    value: &str,
) -> Result<()> {
    ensure!(
        !value.is_empty() && !value.contains('\n'),
        "Invalid %{field}% value in repository desc"
    );
    ensure!(slot.is_none(), "Duplicate %{field}% in repository desc");
    *slot = Some(value.to_owned());
    Ok(())
}

fn kernel_version(package_version: &str) -> Result<&str> {
    let end = package_version
        .bytes()
        .position(|byte| !(byte.is_ascii_digit() || byte == b'.'))
        .unwrap_or(package_version.len());
    let version = package_version
        .get(..end)
        .context("Package version prefix is not valid UTF-8")?;
    let mut components = version.split('.');
    for name in ["major", "minor", "patch"] {
        let component = components.next().with_context(|| {
            format!("CachyOS package version {package_version:?} has no {name} component")
        })?;
        ensure!(
            !component.is_empty()
                && component.bytes().all(|byte| byte.is_ascii_digit()),
            "Invalid {name} component in CachyOS package version {package_version:?}"
        );
    }
    ensure!(
        components.next().is_none()
            && package_version.as_bytes().get(end) == Some(&b'-'),
        "Invalid CachyOS package version {package_version:?}"
    );
    Ok(version)
}

fn http_agent() -> Agent {
    Agent::config_builder()
        .timeout_connect(Some(Duration::from_secs(30)))
        .timeout_global(Some(Duration::from_mins(15)))
        .user_agent(concat!("ci-driver/", env!("CARGO_PKG_VERSION")))
        .build()
        .into()
}

fn download_verified(
    agent: &Agent,
    package: &Package,
    destination: &Path,
) -> Result<()> {
    eprintln!("Downloading {}", package.url);
    let mut response = agent
        .get(&package.url)
        .call()
        .with_context(|| format!("Failed to download {}", package.url))?;
    let mut source = io::BufReader::with_capacity(
        1024 * 1024,
        response.body_mut().as_reader(),
    );
    let mut output =
        HashingWriter::new(File::create(destination).with_context(
            || format!("Failed to create {}", destination.display()),
        )?);
    let size = io::copy(&mut source, &mut output).with_context(|| {
        format!("Failed while downloading {}", package.url)
    })?;
    let actual = output.finish();

    let actual_sri = actual.sri();
    ensure!(
        actual_sri == package.hash,
        "Checksum mismatch for {}: expected {}, got {actual_sri}",
        package.url,
        package.hash
    );
    eprintln!("Verified {actual} ({size} bytes).");
    Ok(())
}

/// Hashes everything written while forwarding it to the file.
struct HashingWriter {
    output: File,
    hasher: Sha256,
}

impl HashingWriter {
    fn new(output: File) -> Self {
        Self {
            output,
            hasher: Sha256::new(),
        }
    }

    fn finish(self) -> Checksum {
        Checksum(self.hasher.finalize().into())
    }
}

impl std::io::Write for HashingWriter {
    fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
        self.hasher.update(buf);
        self.output.write(buf)
    }

    fn flush(&mut self) -> io::Result<()> {
        self.output.flush()
    }
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
        let (pairs, _) = value.as_bytes().as_chunks::<2>();
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
    kernel: Package,
    headers: Package,
    config_hash: String,
    #[serde(rename = "isLTS")]
    is_lts: bool,
    is_zen: bool,
}

#[derive(Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct Package {
    #[serde(rename = "packageName")]
    name: String,
    url: String,
    hash: String,
}

impl Package {
    fn file_name(&self) -> Result<&str> {
        let (_, name) = self.url.rsplit_once('/').with_context(|| {
            format!("Package URL has no file name: {}", self.url)
        })?;
        ensure!(
            !name.is_empty(),
            "Package URL has no file name: {}",
            self.url
        );
        Ok(name)
    }
}

impl Release {
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

    fn matches_upstream(&self, upstream: &UpstreamRelease) -> bool {
        self.pname == PACKAGE_NAME
            && self.version == upstream.version
            && self.package_version == upstream.package_version
            && self.architecture == ARCHITECTURE
            && self.kernel == upstream.kernel
            && self.headers == upstream.headers
            && !self.is_lts
            && !self.is_zen
    }

    fn label(&self) -> String {
        format!("{} {}", self.pname, self.package_version)
    }
}

fn change_description(
    pinned: &Release,
    upstream: &UpstreamRelease,
) -> String {
    let old = pinned.label();
    let new = upstream.label();
    if old == new {
        format!("Refreshed `{new}` because the upstream package changed.")
    } else {
        format!("Updated `{old}` to `{new}`.")
    }
}

struct PackageArchive {
    name: String,
    version: String,
    module_dir: String,
    config: Option<Vec<u8>>,
    build_version: Option<String>,
}

#[derive(Clone, Copy)]
enum ArchiveMember {
    Other,
    Config,
    BuildVersion,
}

fn inspect_archive(path: &Path) -> Result<PackageArchive> {
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
    let (name, version) = parse_package_info(&package_info)?;
    Ok(PackageArchive {
        name,
        version,
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

fn is_desc_path(path: &Path) -> Result<bool> {
    let mut components = path.components();
    Ok(next_normal_component(&mut components)?.is_some()
        && next_normal_component(&mut components)?
            == Some(OsStr::new("desc"))
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

fn parse_package_info(package_info: &[u8]) -> Result<(String, String)> {
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

    Ok((
        name.context("Missing pkgname in .PKGINFO")?,
        version.context("Missing pkgver in .PKGINFO")?,
    ))
}

struct ExtractedRelease {
    mod_dir_version: String,
    config: Vec<u8>,
}

fn inspect_release_archives(
    kernel_path: &Path,
    headers_path: &Path,
    upstream: &UpstreamRelease,
) -> Result<ExtractedRelease> {
    let kernel =
        inspect_archive(kernel_path).context("Invalid kernel package")?;
    let headers = inspect_archive(headers_path)
        .context("Invalid headers package")?;

    for (archive, package) in
        [(&kernel, &upstream.kernel), (&headers, &upstream.headers)]
    {
        ensure!(
            archive.name == package.name,
            "Archive package is {}, expected {}",
            archive.name,
            package.name
        );
        ensure!(
            archive.version == upstream.package_version,
            "Archive version is {}, expected {}",
            archive.version,
            upstream.package_version
        );
    }
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
    use std::io::Write as _;
    use std::str::FromStr as _;

    use super::Checksum;
    use super::HashingWriter;
    use super::kernel_version;
    use super::parse_repo_desc;
    use super::select_kernel_and_headers;

    const KERNEL_SHA256: &str =
        "30752798fc22ea3674be9acde965f63153a739bd93653998b29c90598931db7e";

    fn repo_desc(
        name: &str,
        file_name: &str,
        arch: Option<&str>,
    ) -> String {
        let mut desc = format!(
            "%FILENAME%\n{file_name}\n\n\
             %NAME%\n{name}\n\n\
             %VERSION%\n7.2.3-1\n\n\
             %PROVIDES%\nWIREGUARD-MODULE\nKSMBD-MODULE\n\n\
             %SHA256SUM%\n{KERNEL_SHA256}\n\n"
        );
        if let Some(arch) = arch {
            desc.push_str("%ARCH%\n");
            desc.push_str(arch);
            desc.push('\n');
        }
        desc
    }

    fn kernel_desc() -> String {
        repo_desc(
            "linux-cachyos",
            "linux-cachyos-7.2.3-1-x86_64_v3.pkg.tar.zst",
            Some("x86_64_v3"),
        )
    }

    fn headers_desc() -> String {
        repo_desc(
            "linux-cachyos-headers",
            "linux-cachyos-headers-7.2.3-1-x86_64_v3.pkg.tar.zst",
            Some("x86_64_v3"),
        )
    }

    fn database_bytes(entries: &[(&str, String)]) -> Vec<u8> {
        let encoder =
            zstd::stream::write::Encoder::new(Vec::new(), 0).unwrap();
        let mut builder = tar::Builder::new(encoder);
        for (directory, desc) in entries {
            let mut header = tar::Header::new_gnu();
            header.set_size(u64::try_from(desc.len()).unwrap());
            header.set_mode(0o644);
            header.set_cksum();
            builder
                .append_data(
                    &mut header,
                    format!("{directory}/desc"),
                    desc.as_bytes(),
                )
                .unwrap();
        }
        builder.into_inner().unwrap().finish().unwrap()
    }

    #[test]
    fn parses_repository_desc_fields() {
        let package = parse_repo_desc(kernel_desc().as_bytes()).unwrap();

        assert_eq!(package.name, "linux-cachyos");
        assert_eq!(package.version, "7.2.3-1");
        assert_eq!(package.architecture, "x86_64_v3");
        assert_eq!(
            package.file_name,
            "linux-cachyos-7.2.3-1-x86_64_v3.pkg.tar.zst"
        );
        assert_eq!(package.checksum.to_string(), KERNEL_SHA256);
    }

    #[test]
    fn rejects_invalid_repository_descs() {
        let multi_line_file_name = repo_desc(
            "linux-cachyos",
            "a.pkg.tar.zst\nb.pkg.tar.zst",
            Some("x86_64_v3"),
        );
        parse_repo_desc(multi_line_file_name.as_bytes()).unwrap_err();

        let missing_arch =
            repo_desc("linux-cachyos", "a.pkg.tar.zst", None);
        parse_repo_desc(missing_arch.as_bytes()).unwrap_err();
    }

    #[test]
    fn selects_kernel_and_headers_from_database() {
        let bytes = database_bytes(&[
            (
                "some-other-pkg-1-1",
                repo_desc(
                    "some-other-pkg",
                    "some-other-pkg-1-1-x86_64_v3.pkg.tar.zst",
                    Some("x86_64_v3"),
                ),
            ),
            ("linux-cachyos-7.2.3-1", kernel_desc()),
            ("linux-cachyos-headers-7.2.3-1", headers_desc()),
        ]);

        let (kernel, headers) =
            select_kernel_and_headers(&bytes, "test://database").unwrap();

        assert_eq!(kernel.name, "linux-cachyos");
        assert_eq!(kernel.version, "7.2.3-1");
        assert_eq!(
            kernel.file_name,
            "linux-cachyos-7.2.3-1-x86_64_v3.pkg.tar.zst"
        );
        assert_eq!(headers.name, "linux-cachyos-headers");
        assert_eq!(headers.version, "7.2.3-1");
        assert_eq!(
            headers.file_name,
            "linux-cachyos-headers-7.2.3-1-x86_64_v3.pkg.tar.zst"
        );
    }

    #[test]
    fn rejects_duplicate_kernel_in_database() {
        let bytes = database_bytes(&[
            ("linux-cachyos-7.2.3-1", kernel_desc()),
            ("linux-cachyos-7.2.4-1", kernel_desc()),
            ("linux-cachyos-headers-7.2.3-1", headers_desc()),
        ]);

        select_kernel_and_headers(&bytes, "test://database").unwrap_err();
    }

    #[test]
    fn rejects_missing_headers_in_database() {
        let bytes =
            database_bytes(&[("linux-cachyos-7.2.3-1", kernel_desc())]);

        let error = select_kernel_and_headers(&bytes, "test://database")
            .unwrap_err()
            .to_string();
        assert!(error.contains("linux-cachyos-headers"));
    }

    #[test]
    fn hashing_writer_digests_what_it_writes() {
        let mut writer = HashingWriter::new(tempfile::tempfile().unwrap());
        writer.write_all(b"linux-").unwrap();
        writer.write_all(b"cachyos").unwrap();

        assert_eq!(writer.finish(), Checksum::digest(b"linux-cachyos"));
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
        assert_eq!(kernel_version("7.2.3-1").unwrap(), "7.2.3");
        kernel_version("7.2-1").unwrap_err();
        kernel_version("7.2.3").unwrap_err();
        kernel_version("7.2.3rc1-1").unwrap_err();
    }
}
