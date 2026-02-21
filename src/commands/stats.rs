use anyhow::Result;
use crate::format;
use crate::warp_cli;

pub fn run(json: bool, _quiet: bool) -> Result<()> {
    let stats = warp_cli::run(&["account"])?;

    if json {
        println!("{}", stats);
    } else {
        println!("{}", stats);
    }

    Ok(())
}
