use anyhow::{Result, bail};
use crate::format;
use crate::warp_cli;

pub fn run(protocol: &str, json: bool, quiet: bool) -> Result<()> {
    let valid_modes = ["doh", "gateway", "warp", "warp+warp"];

    if !valid_modes.contains(&protocol) {
        bail!("Invalid mode: {}. Valid modes: {}", protocol, valid_modes.join(", "));
    }

    warp_cli::run(&["mode", protocol])?;
    format::success(json, quiet, format!("✓ Mode set to {}", protocol));

    Ok(())
}
