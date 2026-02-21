use anyhow::Result;
use crate::format;
use crate::warp_cli;

pub fn run(json: bool, quiet: bool) -> Result<()> {
    if !quiet {
        eprintln!("Running diagnostics...");
    }

    let output = warp_cli::diagnose()?;

    if json {
        println!("{}", output);
    } else {
        println!("{}", output);
    }

    Ok(())
}
