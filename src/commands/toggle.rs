use anyhow::Result;
use crate::format;
use crate::warp_cli;

pub fn run(json: bool, quiet: bool) -> Result<()> {
    let is_connected = warp_cli::is_connected()?;

    if is_connected {
        warp_cli::disconnect()?;
        format::success(json, quiet, "✓ Toggled: now disconnected from WARP");
    } else {
        warp_cli::connect()?;
        format::success(json, quiet, "✓ Toggled: now connected to WARP");
    }

    Ok(())
}
