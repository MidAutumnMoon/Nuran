use std::path::PathBuf;

use bpaf::OptionParser;
use bpaf::Parser;
use bpaf::construct;
use bpaf::long;
use rootcause::Result;

mod nix;
mod pins;
mod refresh;
mod verify;

#[derive(Debug)]
#[derive(Clone)]
enum Cli {
    /// Update the __pin flake lock, refresh pins.json from it, and copy
    /// the packages into my cache. Prints the update report to stdout.
    RefreshPin {
        dir: PathBuf,
        cachix: String,
        no_push: bool,
    },

    /// Verify pins.json against the __pin flake lock, and that my cache
    /// serves every pinned closure.
    VerifyPin {
        dir: PathBuf,
        substituters: Vec<String>,
    },
}

fn pin_dir() -> impl Parser<PathBuf> {
    long("dir")
        .help("The __pin directory (default: packages/__pin under the repo root)")
        .argument::<PathBuf>("DIR")
        .fallback("packages/__pin".into())
}

fn cli() -> OptionParser<Cli> {
    let refresh = {
        let dir = pin_dir();
        let cachix = long("cachix")
            .help("Push the pinned closures to this cachix cache")
            .argument::<String>("CACHE")
            .fallback("nuirrce".into());
        let no_push = long("no-push")
            .help("Refresh pins.json without pushing to cachix")
            .switch();
        construct!(Cli::RefreshPin {
            dir,
            cachix,
            no_push,
        })
        .to_options()
        .descr("Update the pin lock and pins.json, copy to my cache.")
        .command("refresh-pin")
    };

    let verify = {
        let dir = pin_dir();
        let substituters = long("substituter")
            .help("A substituter the closures must be served from (repeatable; default: the cachix.org entries of nix config)")
            .argument::<String>("URL")
            .many();
        construct!(Cli::VerifyPin { dir, substituters })
            .to_options()
            .descr("Verify pins.json and cache coverage.")
            .command("verify-pin")
    };

    construct!([refresh, verify])
        .to_options()
        .version(env!("CARGO_PKG_VERSION"))
        .descr("Maintain the store-path pins under packages/__pin.")
}

#[cfg(test)]
mod tests {
    use super::cli;

    #[test]
    fn cli_invariants() {
        // Panics if a positional/command item is not right-most.
        // (Dumps the parser meta tree to stdout; that is expected.)
        cli().check_invariants(false);
    }
}

fn main() -> Result<()> {
    match cli().run() {
        Cli::RefreshPin {
            dir,
            cachix,
            no_push,
        } => refresh::run(&dir, &cachix, no_push),
        Cli::VerifyPin { dir, substituters } => {
            verify::run(&dir, &substituters)
        }
    }
}
