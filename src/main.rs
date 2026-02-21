use clap::{Parser, Subcommand};
use colored::Colorize;
use std::process;

mod commands;
mod format;
mod warp_cli;

use commands::*;

#[derive(Parser)]
#[command(name = "warp", about = "Cloudflare WARP CLI", long_about = None)]
#[command(version = "0.1.0")]
struct Cli {
    #[arg(long, global = true)]
    /// Output as JSON for scripting
    json: bool,

    #[arg(long, global = true)]
    /// Suppress output
    quiet: bool,

    #[arg(long, global = true)]
    /// Verbose output
    verbose: bool,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Show current WARP status
    Status,

    /// Connect to WARP
    Up,

    /// Disconnect from WARP
    Down,

    /// Toggle WARP connection
    Toggle,

    /// Set WARP mode (doh, gateway, warp, warp+warp)
    Mode {
        /// Protocol mode
        protocol: String,
    },

    /// Follow daemon logs
    Logs {
        #[arg(short, long)]
        /// Follow log file in real-time
        follow: bool,
    },

    /// Show connection statistics
    Stats,

    /// Manage settings
    Settings {
        #[command(subcommand)]
        action: Option<SettingsAction>,
    },

    /// Manage split tunnel exclusions
    Exclude {
        #[command(subcommand)]
        action: Option<ExcludeAction>,
    },

    /// Manage WARP daemon
    Daemon {
        #[command(subcommand)]
        action: Option<DaemonAction>,
    },

    /// Check for updates
    Update {
        #[command(subcommand)]
        action: Option<UpdateAction>,
    },

    /// Run diagnostics
    Diagnose,
}

#[derive(Subcommand)]
enum SettingsAction {
    /// Show all settings
    Show,
    /// Get a specific setting
    Get { key: String },
    /// Set a setting
    Set { key: String, value: String },
}

#[derive(Subcommand)]
enum ExcludeAction {
    /// List excluded domains/IPs
    List,
    /// Add a domain or IP to exclusions
    Add { target: String },
    /// Remove from exclusions
    Remove { target: String },
}

#[derive(Subcommand)]
enum DaemonAction {
    /// Start the WARP daemon
    Start,
    /// Stop the WARP daemon
    Stop,
    /// Restart the WARP daemon
    Restart,
    /// Check daemon status
    Status,
}

#[derive(Subcommand)]
enum UpdateAction {
    /// Check for available updates
    Check,
    /// Apply available update
    Apply,
}

fn main() {
    let cli = Cli::parse();

    let result = match cli.command {
        Commands::Status => status::run(cli.json, cli.quiet),
        Commands::Up => connect::run(true, cli.json, cli.quiet),
        Commands::Down => connect::run(false, cli.json, cli.quiet),
        Commands::Toggle => toggle::run(cli.json, cli.quiet),
        Commands::Mode { protocol } => mode::run(&protocol, cli.json, cli.quiet),
        Commands::Logs { follow } => logs::run(follow, cli.json, cli.quiet),
        Commands::Stats => stats::run(cli.json, cli.quiet),
        Commands::Settings { action } => {
            settings::run(action, cli.json, cli.quiet, cli.verbose)
        }
        Commands::Exclude { action } => {
            exclude::run(action, cli.json, cli.quiet, cli.verbose)
        }
        Commands::Daemon { action } => {
            daemon::run(action, cli.json, cli.quiet, cli.verbose)
        }
        Commands::Update { action } => {
            update::run(action, cli.json, cli.quiet, cli.verbose)
        }
        Commands::Diagnose => diagnose::run(cli.json, cli.quiet),
    };

    if let Err(e) = result {
        if !cli.quiet {
            eprintln!("{}", format!("Error: {}", e).red());
        }
        process::exit(1);
    }
}
