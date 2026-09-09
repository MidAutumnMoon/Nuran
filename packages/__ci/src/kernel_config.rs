use std::collections::BTreeMap;
use std::str;

use anyhow::Context as _;
use anyhow::Result;
use anyhow::ensure;

/// The enabled and explicitly-valued entries from a Linux kernel `.config`.
///
/// Disabled comment entries are deliberately absent: that matches the
/// semantics of nixpkgs' `kernel.config.isDisabled` helper.
#[derive(Debug)]
pub struct KernelConfig {
    entries: BTreeMap<String, String>,
}

impl KernelConfig {
    pub fn parse(raw: &[u8]) -> Result<Self> {
        let text = str::from_utf8(raw)
            .context("Kernel config is not valid UTF-8")?;
        let mut entries = BTreeMap::new();

        for (index, line) in text.lines().enumerate() {
            let line_number = index + 1;
            if line.is_empty() || line.starts_with('#') {
                continue;
            }

            let (name, value) = line.split_once('=').with_context(|| {
                format!("Unrecognized kernel config line {line_number}: {line:?}")
            })?;
            ensure!(
                is_option_name(name),
                "Invalid kernel option on line {line_number}: {name:?}"
            );
            let previous =
                entries.insert(name.to_owned(), value.to_owned());
            ensure!(
                previous.is_none(),
                "Duplicate kernel option on line {line_number}: {name}"
            );
        }

        Ok(Self { entries })
    }

    #[inline]
    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn render_json(&self) -> Result<String> {
        let mut output = serde_json::to_string_pretty(&self.entries)
            .context("Failed to serialize kernel config")?;
        output.push('\n');
        Ok(output)
    }
}

fn is_option_name(name: &str) -> bool {
    name.strip_prefix("CONFIG_").is_some_and(|suffix| {
        !suffix.is_empty()
            && suffix
                .bytes()
                .all(|byte| byte.is_ascii_alphanumeric() || byte == b'_')
    })
}

#[cfg(test)]
#[expect(clippy::unwrap_used, reason = "Tests")]
mod tests {
    use super::KernelConfig;

    #[test]
    fn parses_kernel_config_semantics() {
        let config = KernelConfig::parse(
            b"# generated\n\
              CONFIG_MODULES=y\n\
              # CONFIG_UNUSED is not set\n\
              CONFIG_EXPLICITLY_DISABLED=n\n\
              CONFIG_COMMAND=\"echo ${HOME} \\\\ ok\"\n",
        )
        .unwrap();

        assert_eq!(config.len(), 3);
        assert_eq!(
            config.render_json().unwrap(),
            concat!(
                "{\n",
                "  \"CONFIG_COMMAND\": \"\\\"echo ${HOME} \\\\\\\\ ok\\\"\",\n",
                "  \"CONFIG_EXPLICITLY_DISABLED\": \"n\",\n",
                "  \"CONFIG_MODULES\": \"y\"\n",
                "}\n",
            )
        );
    }

    #[test]
    fn rejects_duplicate_options() {
        let error =
            KernelConfig::parse(b"CONFIG_MODULES=y\nCONFIG_MODULES=m\n")
                .unwrap_err();

        assert!(
            error
                .to_string()
                .contains("Duplicate kernel option on line 2")
        );
    }

    #[test]
    fn rejects_malformed_lines() {
        let error =
            KernelConfig::parse(b"CONFIG_MODULES y\n").unwrap_err();

        assert!(
            error
                .to_string()
                .contains("Unrecognized kernel config line 1")
        );
    }
}
