use anyhow::Result;
use serde_json::json;
use crate::format;
use crate::warp_cli;

pub fn run(json: bool, _quiet: bool) -> Result<()> {
    let status_output = warp_cli::get_status()?;

    if json {
        let is_connected = status_output.contains("Connected");
        let obj = json!({
            "connected": is_connected,
            "raw": status_output
        });
        println!("{}", obj.to_string());
    } else {
        println!("{}", status_output);
    }

    Ok(())
}
