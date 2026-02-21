# Technical Details

Complete technical documentation for the Cloudflare WARP CLI tool.

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
  /usr/local/bin/warp (our CLI wrapper) ← YOU ARE HERE
```

The CLI tool wraps the existing `warp-cli` binary, which already speaks the gRPC protocol to the daemon.

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

scripts/
  detect-installation.sh  - check system state and readiness
  extract-warp.sh         - extract binaries from WARP app
  setup-daemon.sh         - configure daemon via launchd

install-complete.sh  - orchestrates entire installation process
```

## Build

```bash
cargo build --release
```

Output: `target/release/warp` (1.1 MB static binary, no runtime dependencies)

## Installation Methods

### Method 1: One-line install from GitHub
```bash
curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash
```

### Method 2: Clone and install
```bash
git clone https://github.com/zero8dotdev/warp-cli.git
cd warp-cli
./install-complete.sh
```

### Method 3: Manual installation
```bash
# Clone repo
git clone https://github.com/zero8dotdev/warp-cli.git
cd warp-cli

# Build
cargo build --release

# Install
sudo install -m 755 target/release/warp /usr/local/bin/warp
```

## Commands Reference

### Connection Management

```bash
# Check connection status
warp status                    # Human-readable output
warp status --json             # JSON format
warp status --quiet            # Only exit code

# Connect to WARP
warp up

# Disconnect from WARP
warp down

# Toggle connection state
warp toggle
```

### Protocol/Mode Management

```bash
# Switch protocol mode
warp mode warp                 # Standard WARP
warp mode gateway              # Gateway mode
warp mode doh                  # DNS over HTTPS only
warp mode warp+warp            # WARP + additional layer

# Get current mode
warp status --json | jq .protocol
```

### Logging

```bash
# View recent logs
warp logs

# Follow logs in real-time
warp logs --follow

# Follow logs with other options
warp logs --follow --verbose
```

### Split Tunnel (Exclude)

```bash
# List excluded domains/IPs
warp exclude list

# Add domain to split tunnel
warp exclude add example.com

# Add IP range to split tunnel
warp exclude add 192.168.1.0/24

# Remove from split tunnel
warp exclude remove example.com
```

### Daemon Management

```bash
# Check daemon status
warp daemon status

# Start daemon
warp daemon start

# Stop daemon
warp daemon stop

# Restart daemon
warp daemon restart
```

### Other Commands

```bash
# Check for app updates
warp update check

# Run diagnostics
warp diagnose

# Show help for any command
warp --help
warp up --help
warp exclude --help
```

### Global Flags

All commands support these flags:

```bash
# JSON output (for scripting)
warp status --json

# Quiet mode (no output)
warp up --quiet

# Verbose mode (debugging)
warp status --verbose

# Combine flags
warp status --json --quiet
```

## Dependencies

All pure Rust, no C FFI or system libraries:

- **clap 4** — CLI argument parsing with derive macros
- **colored 2** — Terminal colors
- **tokio 1** — Async runtime
- **reqwest 0.12** — HTTP client
- **roxmltree 0.20** — XML parsing
- **serde/serde_json** — JSON serialization
- **anyhow** — Error handling

## Design Principles

1. **Subcommand hierarchy** — logical grouping via clap
2. **Global flags** — `--json`, `--quiet`, `--verbose` everywhere
3. **Stderr for progress** — long operations stream to stderr
4. **Stdout for data** — actual results to stdout for piping
5. **Exit codes** — non-zero on error, zero on success
6. **Descriptive errors** — clear error messages
7. **Zero overhead** — single static binary, no JIT/GC

## Smart Installation Features

### 1. System Detection
`scripts/detect-installation.sh` checks:
- ✓ Cloudflare WARP app installed
- ✓ warp-cli binary available
- ✓ Daemon configured and running
- ✓ IPC socket available
- ✓ Installation readiness

Returns exit codes:
- `0` = System fully ready
- `1` = Can extract binaries and proceed
- `2` = WARP app needed

### 2. Automatic Extraction
`scripts/extract-warp.sh`:
- Verifies WARP app exists
- Extracts warp-cli binary
- Sets proper permissions
- Handles sudo elevation

### 3. Daemon Setup
`scripts/setup-daemon.sh`:
- Configures launchd daemon
- Starts daemon if needed
- Verifies IPC socket
- Provides troubleshooting help

### 4. Installation Orchestration
`install-complete.sh`:
- Detects system state
- Extracts binaries
- Sets up daemon
- Builds CLI from source
- Installs to /usr/local/bin
- Verifies everything works

## Troubleshooting

### "Command not found: warp"

Check if binary is in PATH:
```bash
which warp
echo $PATH | grep /usr/local/bin
```

### "Permission denied" on install

The installation script uses sudo automatically. If you get permission errors:
```bash
sudo bash ./install-complete.sh
```

### "Daemon not running"

Restart the daemon:
```bash
warp daemon restart
```

Or manually:
```bash
sudo launchctl restart com.cloudflare.1dot1dot1dot1.macos.warp.daemon
```

### "IPC socket not available"

The daemon may need time to initialize:
```bash
sleep 3
warp status
```

## JSON Output Examples

```bash
# Get connection status as JSON
$ warp status --json
{
  "connected": true,
  "protocol": "warp",
  "ips": ["104.16.0.0"],
  "country": "US"
}

# Parse with jq
$ warp status --json | jq .connected
true

# Check in scripts
if warp status --json | jq -e '.connected' > /dev/null; then
  echo "Connected to WARP"
else
  echo "Not connected"
fi
```

## License

Internal project, follows Cloudflare WARP license terms.
