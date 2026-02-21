# Uninstall & Fresh Install Guide

Complete steps to cleanly remove and reinstall warp-cli and WARP daemon.

---

## When to Do a Fresh Install

- ❌ Something isn't working right
- ❌ WARP daemon crashed and won't restart
- ❌ Switching from old `homebrew-warp` tap to new `homebrew-tools`
- ❌ Clearing out old installation after updates
- ✅ Starting completely fresh
- ✅ Troubleshooting connection issues

---

## Complete Uninstall

### Step 1: Disconnect WARP

```bash
warp down
```

### Step 2: Uninstall warp-cli

```bash
# If installed via Homebrew
brew uninstall warp-cli

# If installed from source
rm /usr/local/bin/warp
```

### Step 3: Uninstall WARP Daemon & App

```bash
# If installed via Homebrew cask
brew uninstall --cask cloudflare-warp

# If installed from App Store (manual removal)
rm -rf /Applications/Cloudflare\ WARP.app

# Remove configuration files
rm -rf ~/.cloudflare-warp
rm -rf ~/Library/Application\ Support/Cloudflare
rm -rf ~/Library/Preferences/com.cloudflare.warp.plist
```

### Step 4: Remove Old Taps (if switching)

```bash
# If you were using the old tap
brew untap zero8dotdev/warp

# Verify it's removed
brew tap | grep warp
# Should return nothing if successfully removed
```

### Step 5: Verify Complete Removal

```bash
# Confirm warp-cli is gone
which warp
# Should say "not found"

# Confirm WARP daemon is stopped
launchctl list | grep -i warp
# Should return nothing

# Confirm no app remains
ls /Applications | grep -i cloudflare
# Should return nothing
```

---

## Fresh Install

### Step 1: Add the Tap

```bash
brew tap zero8dotdev/tools
```

### Step 2: Install Everything in One Command

```bash
brew install warp-cli
```

This automatically:
✅ Installs WARP daemon (via cask dependency)
✅ Removes GUI app (post-install hook)
✅ Installs warp-cli binary
✅ Configures everything

### Step 3: Verify Installation

```bash
# Check warp-cli is installed
warp --version
# Should output: warp 0.1.0

# Check WARP daemon is running
warp status
# Should show connection status

# Check daemon is active
launchctl list | grep -i warp
# Should show warp_service running as root
```

### Step 4: Test Connection

```bash
# Connect to WARP
warp up
# Should output: ✓ Connected to WARP

# Verify it worked
warp status
# Should show: Status: Connected to WARP

# Disconnect
warp down
# Should output: ✓ Disconnected from WARP
```

---

## Troubleshooting During Fresh Install

### Problem: `brew tap` fails

```bash
# Verify tap exists
brew tap-info zero8dotdev/tools

# Try adding tap again
brew tap zero8dotdev/tools
```

**Solution:** If it still fails, the tap might be temporarily unavailable. Wait a few minutes and try again.

### Problem: `brew install warp-cli` fails with dependency errors

```bash
# Update Homebrew
brew update

# Try installing again
brew install warp-cli
```

**Solution:** Outdated Homebrew can cause issues. Update first.

### Problem: Permission denied removing WARP app

```bash
# Use sudo if needed
sudo rm -rf /Applications/Cloudflare\ WARP.app
```

**Solution:** The post-install hook should handle this automatically, but if it fails, use `sudo`.

### Problem: WARP daemon won't start after install

```bash
# Check daemon status
warp status

# Restart daemon manually
sudo launchctl stop com.cloudflare.warp.daemon
sudo launchctl start com.cloudflare.warp.daemon

# Check if it's running
launchctl list | grep warp
```

**Solution:** Try restarting the daemon. If still fails, do another fresh install.

### Problem: `warp --help` shows old version after update

```bash
# Clear Homebrew cache
brew cleanup

# Uninstall and reinstall
brew uninstall warp-cli
brew install warp-cli
```

**Solution:** Cached version issue. Clean and reinstall.

---

## Advanced: Clean Everything (Nuclear Option)

Use this if you want to completely remove all WARP-related files:

```bash
#!/bin/bash

echo "🔴 NUCLEAR OPTION: Removing ALL WARP-related files..."

# Stop any running processes
echo "Stopping WARP..."
warp down 2>/dev/null || true
pkill -f warp || true

# Uninstall via Homebrew
echo "Uninstalling via Homebrew..."
brew uninstall warp-cli 2>/dev/null || true
brew uninstall --cask cloudflare-warp 2>/dev/null || true
brew untap zero8dotdev/warp 2>/dev/null || true
brew untap zero8dotdev/tools 2>/dev/null || true

# Remove binaries
echo "Removing binaries..."
rm -f /usr/local/bin/warp
rm -f /opt/homebrew/bin/warp

# Remove configuration files
echo "Removing config files..."
rm -rf ~/.cloudflare-warp
rm -rf ~/Library/Application\ Support/Cloudflare
rm -rf ~/Library/Preferences/com.cloudflare.warp.plist
rm -rf ~/Library/LaunchAgents/com.cloudflare.warp*

# Remove app
echo "Removing app..."
rm -rf /Applications/Cloudflare\ WARP.app

# Stop launchd services
echo "Stopping daemon..."
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.warp.daemon.plist 2>/dev/null || true
sudo rm -f /Library/LaunchDaemons/com.cloudflare.warp.daemon.plist

# Clear Homebrew cache
echo "Clearing cache..."
brew cleanup -s

echo "✅ Complete removal finished!"
echo "Safe to do fresh install now: brew tap zero8dotdev/tools && brew install warp-cli"
```

Save as `cleanup.sh` and run:
```bash
chmod +x cleanup.sh
./cleanup.sh
```

---

## Installation Methods Comparison

### Method 1: Homebrew (Recommended)
```bash
brew tap zero8dotdev/tools
brew install warp-cli
```
- ✅ Automatic updates
- ✅ Easy uninstall
- ✅ One command
- ✅ Handles dependencies

### Method 2: From Source
```bash
git clone https://github.com/zero8dotdev/warp-cli.git
cd warp-cli
./install-complete.sh
```
- ✅ Latest development version
- ❌ Manual updates needed
- ❌ Requires Rust toolchain

### Method 3: One-Liner
```bash
curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash
```
- ✅ Quick and easy
- ❌ Less control
- ❌ Manual updates needed

**Recommendation:** Use Homebrew (Method 1) for easiest management.

---

## Switching Between Installation Methods

If you installed via Method 2 or 3 and want to switch to Homebrew:

```bash
# Step 1: Remove old installation
if [ -f /usr/local/bin/warp ]; then
  rm /usr/local/bin/warp
  echo "Removed source installation"
fi

# Step 2: Install via Homebrew
brew tap zero8dotdev/tools
brew install warp-cli

# Step 3: Verify
warp --version
```

---

## Maintenance: Keep Everything Updated

### Auto-update WARP daemon

Homebrew automatically updates when you run:
```bash
brew upgrade
```

### Auto-update warp-cli

Update warp-cli specifically:
```bash
brew upgrade warp-cli
```

### Check for outdated packages

```bash
brew outdated
# Shows packages with updates available
```

### Update everything at once

```bash
brew update && brew upgrade
```

---

## Verifying Everything Works

After fresh install, run this verification script:

```bash
#!/bin/bash

echo "🔍 Verifying warp-cli installation..."

# Check binary
echo -n "✓ warp-cli installed: "
if command -v warp &> /dev/null; then
  echo "$(warp --version)"
else
  echo "❌ FAILED"
  exit 1
fi

# Check daemon
echo -n "✓ WARP daemon running: "
if warp status &> /dev/null; then
  echo "Yes"
else
  echo "❌ FAILED - Try: sudo launchctl start com.cloudflare.warp.daemon"
  exit 1
fi

# Test connection
echo -n "✓ Test connection: "
if warp up &> /dev/null; then
  if warp status | grep -q "Connected"; then
    echo "Connected ✓"
    warp down &> /dev/null
  else
    echo "❌ Failed to connect"
    exit 1
  fi
else
  echo "❌ Connection command failed"
  exit 1
fi

# Check Homebrew tap
echo -n "✓ Homebrew tap configured: "
if brew tap-info zero8dotdev/tools &> /dev/null; then
  echo "Yes"
else
  echo "⚠️  Not found (re-add with: brew tap zero8dotdev/tools)"
fi

echo ""
echo "✅ All checks passed! warp-cli is ready to use."
```

Save as `verify.sh` and run:
```bash
chmod +x verify.sh
./verify.sh
```

---

## Getting Help

If something goes wrong:

1. **Check the logs:**
   ```bash
   warp logs
   ```

2. **Run diagnostics:**
   ```bash
   warp diagnose
   ```

3. **Try a fresh install:**
   Follow the [Complete Uninstall](#complete-uninstall) section above, then reinstall.

4. **Check documentation:**
   - [INSTALLATION.md](INSTALLATION.md) - Detailed troubleshooting
   - [QUICKSTART.md](QUICKSTART.md) - Basic setup
   - [DETAILS.md](DETAILS.md) - Technical details

---

## Checklist: Fresh Install Complete

- [ ] Old installation completely removed
- [ ] Homebrew cache cleared
- [ ] New tap added (`zero8dotdev/tools`)
- [ ] `brew install warp-cli` completed successfully
- [ ] WARP daemon is running
- [ ] warp-cli binary works (`warp --version`)
- [ ] Can connect to WARP (`warp up && warp down`)
- [ ] No error messages or warnings
- [ ] All verification checks pass

---

## Next Steps

Once fresh install is verified:

1. **Learn the basics:**
   ```bash
   warp --help
   warp status
   ```

2. **Read documentation:**
   - [QUICKSTART.md](QUICKSTART.md) - 5-minute intro
   - [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) - Real examples

3. **For developers:**
   - [AGENTIC_DEVELOPMENT.md](AGENTIC_DEVELOPMENT.md) - Use WARP with AI agents

---

## Still Having Issues?

See [INSTALLATION.md](INSTALLATION.md) for comprehensive troubleshooting guide.
