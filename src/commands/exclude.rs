use anyhow::Result;
use crate::format;
use crate::warp_cli;
use crate::ExcludeAction;

pub fn run(action: Option<ExcludeAction>, json: bool, quiet: bool, _verbose: bool) -> Result<()> {
    match action {
        None | Some(ExcludeAction::List) => {
            // Use tunnel dump to see current exclusions
            let output = warp_cli::run(&["tunnel", "dump"])?;
            println!("{}", output);
        }
        Some(ExcludeAction::Add { target }) => {
            // Check if target is an IP address or domain
            if target.contains('.') && !target.contains(':') && target.split('.').all(|p| p.parse::<u8>().is_ok() || p == "*") {
                // Looks like an IP, use tunnel ip
                warp_cli::run(&["tunnel", "ip", "add", &target])?;
            } else {
                // Domain or hostname, use tunnel host
                warp_cli::run(&["tunnel", "host", "add", &target])?;
            }
            format::success(json, quiet, format!("✓ Added '{}' to split tunnel", target));
        }
        Some(ExcludeAction::Remove { target }) => {
            // Check if target is an IP address or domain
            if target.contains('.') && !target.contains(':') && target.split('.').all(|p| p.parse::<u8>().is_ok() || p == "*") {
                // Looks like an IP, use tunnel ip
                warp_cli::run(&["tunnel", "ip", "remove", &target])?;
            } else {
                // Domain or hostname, use tunnel host
                warp_cli::run(&["tunnel", "host", "remove", &target])?;
            }
            format::success(json, quiet, format!("✓ Removed '{}' from split tunnel", target));
        }
    }

    Ok(())
}
