use anyhow::Result;
use serde_json::json;
use colored::Colorize;
use crate::format;
use crate::warp_cli;
use crate::ip;

pub fn run(connect: bool, json: bool, quiet: bool) -> Result<()> {
    if connect {
        // Get IP before connecting
        let before_ip = ip::get_public_ip().ok();

        warp_cli::connect()?;

        // Get IP after connecting
        let after_ip = ip::get_public_ip().ok();

        if json {
            let obj = json!({
                "status": "success",
                "message": "Connected to WARP",
                "before_ip": before_ip,
                "after_ip": after_ip
            });
            if !quiet {
                println!("{}", obj.to_string());
            }
        } else {
            if !quiet {
                format::success(false, false, "✓ Connected to WARP");
                if let Some(ref before) = before_ip {
                    println!("  Before: {}", before.cyan());
                }
                if let Some(ref after) = after_ip {
                    println!("  After:  {}", after.green());
                }
            }
        }
    } else {
        // Get IP before disconnecting
        let before_ip = ip::get_public_ip().ok();

        warp_cli::disconnect()?;

        // Get IP after disconnecting
        let after_ip = ip::get_public_ip().ok();

        if json {
            let obj = json!({
                "status": "success",
                "message": "Disconnected from WARP",
                "before_ip": before_ip,
                "after_ip": after_ip
            });
            if !quiet {
                println!("{}", obj.to_string());
            }
        } else {
            if !quiet {
                format::success(false, false, "✓ Disconnected from WARP");
                if let Some(ref before) = before_ip {
                    println!("  Before: {}", before.cyan());
                }
                if let Some(ref after) = after_ip {
                    println!("  After:  {}", after.green());
                }
            }
        }
    }

    Ok(())
}
