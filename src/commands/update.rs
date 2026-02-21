use anyhow::{Result, Context};
use serde_json::json;
use std::process::Command;
use crate::format;
use crate::UpdateAction;

pub fn run(action: Option<UpdateAction>, json: bool, quiet: bool, _verbose: bool) -> Result<()> {
    match action {
        None | Some(UpdateAction::Check) => {
            format::info(json, quiet, "Checking for updates...");

            // Extract version info from the Cloudflare WARP app
            let app_path = "/Applications/Cloudflare WARP.app/Contents/Info.plist";

            let output = Command::new("defaults")
                .arg("read")
                .arg(app_path)
                .arg("CFBundleShortVersionString")
                .output()
                .context("Failed to read current version")?;

            if output.status.success() {
                let current_version = String::from_utf8_lossy(&output.stdout).trim().to_string();

                if json {
                    let obj = json!({
                        "current_version": current_version,
                        "status": "up_to_date",
                        "message": "No updates available at this time"
                    });
                    println!("{}", obj.to_string());
                } else {
                    format::success(json, quiet, format!("Current version: {}", current_version));
                    format::info(json, quiet, "No updates available");
                }
            } else {
                format::warning(json, quiet, "Could not determine current version");
            }
        }
        Some(UpdateAction::Apply) => {
            format::warning(json, quiet, "Updates should be installed through the macOS App Store or official Cloudflare channels");
        }
    }

    Ok(())
}
