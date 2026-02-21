use anyhow::Result;
use serde_json::json;
use colored::Colorize;
use crate::format;
use crate::warp_cli;
use crate::ip;

pub fn run(json: bool, quiet: bool) -> Result<()> {
    let status_output = warp_cli::get_status()?;
    let is_connected = status_output.contains("Connected");

    // Try to get current IP
    let current_ip = ip::get_public_ip().ok();

    if json {
        let obj = json!({
            "connected": is_connected,
            "ip": current_ip,
            "raw": status_output
        });
        if !quiet {
            println!("{}", obj.to_string());
        }
    } else {
        if !quiet {
            println!("{}", status_output);
            if let Some(ip_addr) = current_ip {
                println!("Current IP: {}", ip_addr.cyan());
            }
        }
    }

    Ok(())
}
