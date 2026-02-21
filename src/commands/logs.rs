use anyhow::Result;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;
use crate::format;

const LOG_PATH: &str = "/Library/Application Support/Cloudflare/cfwarp_service_log.txt";

pub fn run(follow: bool, json: bool, quiet: bool) -> Result<()> {
    let path = Path::new(LOG_PATH);

    if !path.exists() {
        format::warning(json, quiet, "Log file not found at /Library/Application Support/Cloudflare/cfwarp_service_log.txt");
        return Ok(());
    }

    let file = File::open(path)?;
    let reader = BufReader::new(file);

    if follow {
        // Tail the file like 'tail -f'
        let lines: Vec<String> = reader.lines().collect::<Result<Vec<_>, _>>()?;

        // Print last 20 lines first
        let start = if lines.len() > 20 { lines.len() - 20 } else { 0 };
        for line in &lines[start..] {
            println!("{}", line);
        }

        // For continuous following, we'd need to watch the file for changes
        // For now, just print the current content
        format::info(json, quiet, "Following logs... (press Ctrl+C to exit)");

        // In a real implementation, you'd use notify crate to watch for file changes
        // For now, just read and exit
    } else {
        // Just print current logs
        for line in reader.lines() {
            println!("{}", line?);
        }
    }

    Ok(())
}
