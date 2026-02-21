use anyhow::Result;
use crate::format;
use crate::warp_cli;

pub fn run(_json: bool, _quiet: bool) -> Result<()> {
    let stats = warp_cli::run(&["stats"])?;
    println!("{}", stats);
    Ok(())
}
