use std::process::{Command, Stdio};
use anyhow::{Result, Context};

/// Run warp-cli with the given arguments and return output
pub fn run(args: &[&str]) -> Result<String> {
    let output = Command::new("warp-cli")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .context("Failed to execute warp-cli")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("warp-cli failed: {}", stderr.trim());
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

/// Run warp-cli and return raw output (including errors)
pub fn run_raw(args: &[&str]) -> Result<String> {
    let output = Command::new("warp-cli")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .context("Failed to execute warp-cli")?;

    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

/// Connect to WARP
pub fn connect() -> Result<()> {
    run(&["connect"])?;
    Ok(())
}

/// Disconnect from WARP
pub fn disconnect() -> Result<()> {
    run(&["disconnect"])?;
    Ok(())
}

/// Get current status
pub fn get_status() -> Result<String> {
    run(&["status"])
}

/// Check if connected
pub fn is_connected() -> Result<bool> {
    let status = get_status()?;
    Ok(status.contains("Connected"))
}

/// Run diagnostics
pub fn diagnose() -> Result<String> {
    run(&["diagnose"])
}
