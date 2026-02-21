use anyhow::Result;
use crate::format;
use crate::warp_cli;
use crate::SettingsAction;

pub fn run(action: Option<SettingsAction>, json: bool, quiet: bool, _verbose: bool) -> Result<()> {
    match action {
        None | Some(SettingsAction::Show) => {
            // Show all settings via warp-cli account
            let output = warp_cli::run(&["settings"])?;
            println!("{}", output);
        }
        Some(SettingsAction::Get { key }) => {
            let output = warp_cli::run(&["settings", "get", &key])?;
            println!("{}", output);
        }
        Some(SettingsAction::Set { key, value }) => {
            warp_cli::run(&["settings", "set", &key, &value])?;
            format::success(json, quiet, format!("✓ Setting '{}' updated", key));
        }
    }

    Ok(())
}
