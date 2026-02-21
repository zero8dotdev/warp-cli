use anyhow::{Result, Context};
use std::process::Command;
use crate::format;
use crate::DaemonAction;

const DAEMON_LABEL: &str = "com.cloudflare.1dot1dot1dot1.macos.warp.daemon";

pub fn run(action: Option<DaemonAction>, json: bool, quiet: bool, _verbose: bool) -> Result<()> {
    match action {
        None | Some(DaemonAction::Status) => {
            let output = Command::new("launchctl")
                .arg("list")
                .arg(DAEMON_LABEL)
                .output()
                .context("Failed to check daemon status")?;

            if output.status.success() {
                format::success(json, quiet, "✓ Daemon is running");
            } else {
                format::warning(json, quiet, "✗ Daemon is not running");
            }
        }
        Some(DaemonAction::Start) => {
            Command::new("launchctl")
                .arg("start")
                .arg(DAEMON_LABEL)
                .output()
                .context("Failed to start daemon")?;
            format::success(json, quiet, "✓ Daemon started");
        }
        Some(DaemonAction::Stop) => {
            Command::new("launchctl")
                .arg("stop")
                .arg(DAEMON_LABEL)
                .output()
                .context("Failed to stop daemon")?;
            format::success(json, quiet, "✓ Daemon stopped");
        }
        Some(DaemonAction::Restart) => {
            Command::new("launchctl")
                .arg("stop")
                .arg(DAEMON_LABEL)
                .output()
                .context("Failed to stop daemon")?;

            std::thread::sleep(std::time::Duration::from_millis(500));

            Command::new("launchctl")
                .arg("start")
                .arg(DAEMON_LABEL)
                .output()
                .context("Failed to start daemon")?;
            format::success(json, quiet, "✓ Daemon restarted");
        }
    }

    Ok(())
}
