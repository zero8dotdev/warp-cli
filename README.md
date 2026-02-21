# Cloudflare WARP CLI Tool

A minimal, ergonomic CLI tool for Cloudflare WARP, written in Rust. This project implements **Phase 1** of the plan: building a user-friendly wrapper around the existing `warp-cli` daemon.

## Architecture

```
launchd daemon
  ↓
  /Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist
  ↓
  /Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP (root daemon)
  ↓
  IPC: /var/run/warp_service (Unix socket, gRPC protocol)
  ↓
  /usr/local/bin/warp-cli (existing 20MB Rust binary)
  ↓
  /usr/local/bin/warp (our new wrapper CLI) ← YOU ARE HERE
```

## Project Structure

```
src/
  main.rs              - clap CLI definition, command dispatch
  warp_cli.rs          - thin wrapper around warp-cli binary
  format.rs            - colored output & JSON formatting
  commands/
    mod.rs             - command module exports
    connect.rs         - up/down/toggle operations
    status.rs          - display connection status
    logs.rs            - tail daemon logs
    mode.rs            - switch WARP mode (doh, gateway, warp, warp+warp)
    stats.rs           - show connection stats
    settings.rs        - manage preferences
    exclude.rs         - split tunnel management
    daemon.rs          - launchctl wrappers (start/stop/restart)
    update.rs          - check for app updates
    diagnose.rs        - run warp-cli diagnostics
```

## Build

```bash
cargo build --release
```

Output: `target/release/warp` (1.1 MB static binary, no runtime dependencies)

## Installation

```bash
./install.sh
```

Or manually:

```bash
sudo install -m 755 target/release/warp /usr/local/bin/warp
```

## Usage

```bash
# Show status
warp status
warp status --json

# Connect/disconnect
warp up
warp down
warp toggle

# View logs
warp logs
warp logs --follow

# Manage split tunnel
warp exclude list
warp exclude add example.com
warp exclude remove example.com

# Control daemon
warp daemon status
warp daemon start
warp daemon restart

# Check for updates
warp update check

# Run diagnostics
warp diagnose

# Global flags
warp status --json --quiet --verbose
```

## Completed Features

- ✅ **Status command**: Connect/disconnect detection
- ✅ **Up/Down/Toggle**: Connection management
- ✅ **Mode switching**: doh, gateway, warp, warp+warp modes
- ✅ **Logs**: Tail daemon log files
- ✅ **Settings**: View and modify preferences
- ✅ **Exclude (split tunnel)**: Add/remove domains and IPs
- ✅ **Daemon control**: Start/stop/restart via launchctl
- ✅ **Update checking**: Query installed app version
- ✅ **Diagnostics**: Run warp-cli diagnostics
- ✅ **JSON output mode**: `--json` for scripting
- ✅ **Quiet mode**: `--quiet` to suppress output
- ✅ **Verbose mode**: `--verbose` for debugging

## Next Steps (Phase 2-4)

### Phase 2: Remove the GUI

The GUI can be disabled without affecting the daemon:

```bash
# Option 1: Remove GUI launcher
sudo rm -rf "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"

# Option 2: Hide from Spotlight/Dock
sudo touch "/Applications/Cloudflare WARP.app/.hidden"

# Option 3: Kill any running instance
pkill -f "Cloudflare WARP" 2>/dev/null || true
```

The daemon (`CloudflareWARP` binary) is controlled by launchd and runs independently.

### Phase 3: Update Monitoring

Cloudflare WARP uses Sparkle framework for auto-updates. To monitor without the GUI:

```bash
# Query installed version
defaults read "/Applications/Cloudflare WARP.app/Contents/Info" CFBundleShortVersionString

# Extract Sparkle feed URL (if available)
strings "/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP" | grep appcast
```

Future: Implement periodic version check via launchd agent.

### Phase 4: gRPC Protocol Reverse Engineering (Optional)

If you want direct daemon communication without `warp-cli`:

```bash
# Extract gRPC service definitions from binary
strings "/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP" | grep -E "\.proto|service|message"

# Or use dynamic instrumentation (Frida) to capture gRPC frames
```

Once `.proto` files are recovered, build a TypeScript gRPC client with `@grpc/grpc-js`.

## Testing

```bash
# Test all subcommands
warp --help
warp daemon --help
warp exclude --help
warp update --help

# Test connection state
warp status
warp status --json

# Test JSON output parsing
warp status --json | jq .connected

# Test error handling
warp mode invalid-mode  # should fail gracefully
```

## Dependencies

- **clap 4** — CLI argument parsing with derive macros
- **colored 2** — Terminal colors
- **tokio 1** — Async runtime
- **reqwest 0.12** — HTTP client (for future update checks)
- **roxmltree 0.20** — XML parsing (for Sparkle feed)
- **serde/serde_json** — JSON serialization
- **anyhow** — Error handling

All dependencies are pure Rust with no C FFI or system libraries required.

## Verification

```bash
# Build succeeds with no errors
cargo build --release

# Binary works without warp-cli in PATH (it calls via full path)
# Actually, it does require warp-cli to be installed since we use std::process::Command

# Help text is auto-generated from clap derive
./target/release/warp --help

# JSON mode works
./target/release/warp status --json | jq .

# Global flags propagate to subcommands
./target/release/warp status --json --quiet
./target/release/warp up --verbose
```

## Design Principles (from smriti CLI)

1. **Subcommand hierarchy** — logical grouping via clap derive
2. **Global flags** — `--json`, `--quiet`, `--verbose` available everywhere
3. **Stderr for progress** — long operations stream to stderr
4. **Stdout for data** — actual results to stdout for piping
5. **Exit codes** — non-zero on error, zero on success
6. **Descriptive errors** — clear messages to help users
7. **Zero runtime overhead** — single static binary, no JIT/GC

## License

Internal project, follows Cloudflare WARP license terms.
