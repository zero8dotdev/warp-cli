# Installation Guide: Cloudflare WARP CLI Tool

Complete guide for installing and setting up the warp CLI tool.

## Quick Start (Recommended)

```bash
# One command to install everything
./install-complete.sh
```

That's it! The script will:
1. Detect your system state
2. Extract warp-cli from Cloudflare WARP app
3. Set up the daemon
4. Build the CLI tool
5. Install to /usr/local/bin
6. Verify everything works

## Prerequisites

### Required
- **macOS 10.15+** (Catalina or newer)
- **Cloudflare WARP** installed from [App Store](https://apps.apple.com/app/cloudflare-warp/id1423210915)
- **Rust & Cargo** for building (optional if using pre-built binary)

### Optional
- **Command-line tools**: `xcode-select --install`
- **Homebrew**: https://brew.sh (for dependencies)

## Installation Methods

### Method 1: Automated Installation (Easiest)

```bash
cd cloudflare-warp
./install-complete.sh
```

**What it does:**
- Checks your system configuration
- Extracts warp-cli and daemon from Cloudflare WARP app
- Sets up launchd daemon
- Builds and installs the CLI tool
- Verifies everything works

**Time:** 2-3 minutes

### Method 2: Step-by-Step Installation

For more control, run each step manually:

```bash
# Step 1: Check what's installed
bash scripts/detect-installation.sh

# Step 2: Extract binaries
bash scripts/extract-warp.sh

# Step 3: Setup daemon
bash scripts/setup-daemon.sh

# Step 4: Build CLI
cargo build --release

# Step 5: Install
sudo install -m 755 target/release/warp /usr/local/bin/warp

# Step 6: Verify
warp status
```

### Method 3: Manual Installation

If you prefer manual control:

```bash
# 1. Ensure Cloudflare WARP is installed
ls -la /Applications/Cloudflare\ WARP.app

# 2. Ensure warp-cli is in PATH
which warp-cli

# 3. Build the CLI
cargo build --release

# 4. Install the binary
sudo install -m 755 target/release/warp /usr/local/bin/warp

# 5. Test
warp status
```

## Pre-Installation Checks

### Check System Requirements

```bash
# Verify Cloudflare WARP is installed
ls -la "/Applications/Cloudflare WARP.app"

# Check warp-cli availability
which warp-cli
warp-cli --version

# Check if daemon is running
pgrep CloudflareWARP
launchctl list | grep cloudflare

# Check IPC socket
ls -la /var/run/warp_service
```

### Run Detection Script

```bash
bash scripts/detect-installation.sh

# Output will show:
# - Cloudflare WARP app status
# - warp-cli binary location
# - Daemon configuration and status
# - IPC socket availability
# - Installation readiness
```

## Troubleshooting

### Issue: "Cloudflare WARP app not found"

**Solution:**
```bash
# Install from App Store
open "https://apps.apple.com/app/cloudflare-warp/id1423210915"

# Or install via Homebrew (if available)
brew install --cask cloudflare-warp

# Then run installation again
./install-complete.sh
```

### Issue: "warp-cli binary not found"

**Solution:**
```bash
# Check if it's in the app bundle
ls -la "/Applications/Cloudflare WARP.app/Contents/Resources/warp-cli"

# Manually add to PATH
sudo cp "/Applications/Cloudflare WARP.app/Contents/Resources/warp-cli" /usr/local/bin/warp-cli
sudo chmod 755 /usr/local/bin/warp-cli

# Verify
which warp-cli
```

### Issue: "Permission denied" errors

**Solution:**
```bash
# Some steps require sudo. The script should prompt for password.
# If you get stuck, try:
sudo -l  # Check sudo privileges

# Run with explicit sudo
sudo bash ./install-complete.sh
```

### Issue: "Daemon is not running"

**Solution:**
```bash
# Check daemon status
launchctl list | grep cloudflare

# Check if process is running
pgrep CloudflareWARP

# Restart daemon
sudo launchctl stop com.cloudflare.1dot1dot1dot1.macos.warp.daemon
sleep 2
sudo launchctl start com.cloudflare.1dot1dot1dot1.macos.warp.daemon

# Verify
pgrep CloudflareWARP
```

### Issue: "Rust/Cargo not found"

**Solution:**
```bash
# Install Rust from https://rustup.rs/
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Then reload shell
source $HOME/.cargo/env

# Try installation again
./install-complete.sh
```

### Issue: "IPC socket not available"

**Solution:**
```bash
# Wait a moment for daemon to fully initialize
sleep 3

# Check if socket appears
ls -la /var/run/warp_service

# If still missing, restart daemon
bash scripts/setup-daemon.sh
```

### Issue: "warp status" fails

**Solution:**
```bash
# Check if daemon is running
pgrep CloudflareWARP

# Check IPC socket
nc -U /var/run/warp_service < /dev/null

# View daemon logs
log stream --predicate 'eventMessage contains[cd] warp'

# Try restarting
bash scripts/setup-daemon.sh
```

## Verification Steps

After installation, verify everything works:

```bash
# 1. Check warp command
which warp
warp --version

# 2. Check daemon
pgrep CloudflareWARP
launchctl list | grep cloudflare

# 3. Test basic commands
warp status              # Show connection status
warp daemon status       # Check daemon health
warp update check        # Check for updates
warp diagnose            # Run diagnostics

# 4. Verify full functionality
warp status --json       # JSON output
warp up                  # Try connecting
warp down                # Try disconnecting
```

## Post-Installation

### Shell Completions (Coming in Phase 3b)

When shell completions are available:

```bash
# For Zsh (add to ~/.zshrc)
source /usr/local/share/zsh/site-functions/_warp

# For Bash (add to ~/.bashrc)
source /usr/local/share/bash-completion/completions/warp.bash

# Then use TAB to autocomplete
warp <TAB>
```

### Homebrew (Coming in Phase 3b)

When Homebrew formula is available:

```bash
# Install via Homebrew
brew tap yourrepo/warp
brew install warp

# Update via Homebrew
brew upgrade warp
```

### Configuration (Coming in Phase 3c+)

When configuration file support is available:

```bash
mkdir -p ~/.config/warp
cat > ~/.config/warp/config.toml << 'EOF'
[connection]
auto_connect = true
mode = "warp"

[split_tunnel]
enabled = true
excluded = ["192.168.1.0/24"]
EOF
```

## Uninstallation

To completely remove the warp CLI tool:

```bash
# Remove binary
sudo rm -f /usr/local/bin/warp

# (Optional) Remove daemon (this keeps Cloudflare WARP working)
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist

# (Optional) Remove Cloudflare WARP entirely
rm -rf "/Applications/Cloudflare WARP.app"
```

## Rollback/Reinstall

If you need to start over:

```bash
# 1. Remove old installation
sudo rm -f /usr/local/bin/warp

# 2. Clean build artifacts
cargo clean

# 3. Re-run installation
./install-complete.sh
```

## Getting Help

### Documentation
- `README.md` - Project overview
- `USAGE_EXAMPLES.md` - Command examples
- `NEXT_STEPS.md` - Advanced features
- `OPTION_C_IMPLEMENTATION_PLAN.md` - Implementation roadmap

### Debugging
```bash
# Verbose installation
bash -x ./install-complete.sh

# System detection
bash scripts/detect-installation.sh json  # JSON output

# View daemon logs
log stream --predicate 'eventMessage contains[cd] warp'

# Check connections
nc -U /var/run/warp_service < /dev/null
```

### Common Commands

```bash
# Check status
warp status
warp daemon status

# Connection control
warp up
warp down
warp toggle

# Split tunnel
warp exclude list
warp exclude add example.com

# Daemon control
warp daemon start
warp daemon stop
warp daemon restart

# View logs
warp logs
warp logs --follow

# Get help
warp --help
warp up --help
```

## Next Steps

After successful installation:

1. **Try basic commands:**
   ```bash
   warp status
   warp up
   warp down
   ```

2. **Read documentation:**
   ```bash
   cat USAGE_EXAMPLES.md
   cat README.md
   ```

3. **Explore advanced features:**
   - Phase 3b: Shell completions, Homebrew
   - Phase 3c: Pure Rust gRPC client
   - Phase 3d: Comprehensive tests
   - Phase 4: Update monitoring, advanced features

## Support

For issues or questions:
1. Check this guide's troubleshooting section
2. Review project documentation
3. Check daemon logs: `log stream --predicate 'eventMessage contains[cd] warp'`
4. Verify system state: `bash scripts/detect-installation.sh`

## Feedback

Found a bug? Have suggestions? Let us know!

---

**Installation Date:** $(date)
**Version:** 1.0.0
**Status:** ✓ Complete
