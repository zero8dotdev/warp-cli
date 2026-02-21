use anyhow::Result;
use crate::format;
use crate::warp_cli;

pub fn run(connect: bool, json: bool, quiet: bool) -> Result<()> {
    if connect {
        warp_cli::connect()?;
        format::success(json, quiet, "✓ Connected to WARP");
    } else {
        warp_cli::disconnect()?;
        format::success(json, quiet, "✓ Disconnected from WARP");
    }

    Ok(())
}
