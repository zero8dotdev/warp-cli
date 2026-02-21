use anyhow::Result;
use crate::format;
use crate::warp_cli;
use crate::ExcludeAction;

pub fn run(action: Option<ExcludeAction>, json: bool, quiet: bool, _verbose: bool) -> Result<()> {
    match action {
        None | Some(ExcludeAction::List) => {
            let output = warp_cli::run(&["tunnel", "exclude", "list"])?;
            println!("{}", output);
        }
        Some(ExcludeAction::Add { target }) => {
            warp_cli::run(&["tunnel", "exclude", "add", &target])?;
            format::success(json, quiet, format!("✓ Added '{}' to exclusions", target));
        }
        Some(ExcludeAction::Remove { target }) => {
            warp_cli::run(&["tunnel", "exclude", "remove", &target])?;
            format::success(json, quiet, format!("✓ Removed '{}' from exclusions", target));
        }
    }

    Ok(())
}
