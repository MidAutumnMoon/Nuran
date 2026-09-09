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

    eprintln!("Checking {PACKAGE_NAME} upstream metadata...");
    let upstream = fetch_upstream(&agent)?;
    if !force && pinned.matches_upstream(&upstream) {
        eprintln!("{} is already up to date.", upstream.label());
        return Ok(());
    }

    let temporary =
        tempdir().context("Failed to create download directory")?;
    let kernel_path = temporary.path().join(package_file_name(
        &upstream.kernel.name,
        &upstream.package_version,
    ));
    let headers_path = temporary.path().join(package_file_name(
        &upstream.headers.name,
        &upstream.package_version,
    ));
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
    let (package_version, kernel_hash) =
        fetch_dashboard_package(agent, PACKAGE_NAME)?;
    let headers_name = format!("{PACKAGE_NAME}-headers");
    let (headers_version, headers_hash) =
        fetch_dashboard_package(agent, &headers_name)?;
    ensure!(
        package_version == headers_version,
        "CachyOS kernel and headers versions differ: {package_version} vs {headers_version}"
    );

    let version = kernel_version(&package_version)?.to_owned();
    let kernel = package(PACKAGE_NAME, &package_version, kernel_hash);
    let headers = package(&headers_name, &package_version, headers_hash);
    Ok(UpstreamRelease {
        version,
        package_version,
        kernel,
        headers,
    })
}

fn fetch_dashboard_package(
    agent: &Agent,
    expected_name: &str,
) -> Result<(String, Checksum)> {
    let url = format!(
        "{DASHBOARD_ORIGIN}/package/{REPOSITORY}/{ARCHITECTURE}/{expected_name}"
    );
    let html = get_text(agent, &url)?;
    let name = dashboard_string(&html, "pkg_name")?;
    ensure!(
        name == expected_name,
        "Dashboard at {url} describes {name}, expected {expected_name}"
    );
    let version = dashboard_string(&html, "pkg_version")?.to_owned();
    let checksum = dashboard_string(&html, "pkg_sha256sum")?
        .parse()
        .with_context(|| format!("Invalid checksum in {url}"))?;
    Ok((version, checksum))
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

fn package(name: &str, package_version: &str, hash: Checksum) -> Package {
    let file_name = package_file_name(name, package_version);
    Package {
        name: name.to_owned(),
        url: format!(
            "{MIRROR_ORIGIN}/repo/{ARCHITECTURE}/{REPOSITORY}/{file_name}"
        ),
        hash: hash.sri(),
    }
}

fn package_file_name(name: &str, package_version: &str) -> String {
    format!("{name}-{package_version}-{ARCHITECTURE}.pkg.tar.zst")
}

fn http_agent() -> Agent {
    Agent::config_builder()
        .timeout_connect(Some(Duration::from_secs(30)))
        .timeout_global(Some(Duration::from_mins(15)))
        .user_agent(concat!("ci-driver/", env!("CARGO_PKG_VERSION")))
        .build()
        .into()
}

fn get_text(agent: &Agent, url: &str) -> Result<String> {
    let mut response = agent
        .get(url)
        .call()
        .with_context(|| format!("Failed to fetch {url}"))?;
    response
        .body_mut()
        .read_to_string()
        .with_context(|| format!("Failed to read response from {url}"))
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
    let mut source = response.body_mut().as_reader();
    let mut output = File::create(destination).with_context(|| {
        format!("Failed to create {}", destination.display())
    })?;
    let mut hasher = Sha256::new();
    let mut buffer = vec![0_u8; 1024 * 1024];
    let mut size = 0_u64;

    loop {
        let read = source.read(&mut buffer).with_context(|| {
            format!("Failed while downloading {}", package.url)
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
        size += u64::try_from(read).context("Download size overflow")?;
    }
    output.flush().with_context(|| {
        format!("Failed to flush {}", destination.display())
    })?;

    let actual = Checksum(hasher.finalize().into());
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
    use std::str::FromStr as _;

    use super::Checksum;
    use super::dashboard_string;
    use super::kernel_version;

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
        assert_eq!(kernel_version("7.2.3-1").unwrap(), "7.2.3");
        assert!(kernel_version("7.2-1").is_err());
        assert!(kernel_version("7.2.3").is_err());
        assert!(kernel_version("7.2.3rc1-1").is_err());
    }
}
