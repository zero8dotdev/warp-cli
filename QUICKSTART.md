# Quick Start: 5 Minutes to CLI WARP

Get up and running in 5 minutes flat.

## Prerequisites

You need:
1. **macOS 10.15+** (any Mac)
2. **Cloudflare WARP** from [App Store](https://apps.apple.com/app/cloudflare-warp/id1423210915)
3. **This repository** cloned to your Mac

## Installation (2 minutes)

```bash
# 1. Clone or download this repo
git clone https://github.com/yourusername/cloudflare-warp.git
cd cloudflare-warp

# 2. Run installation (one command!)
./install-complete.sh

# That's it! Wait 2-3 minutes for build to complete.
```

## First Use (1 minute)

```bash
# Check status
$ warp status
Status update: Disconnected

# Connect
$ warp up
✓ Connected to WARP

# Disconnect
$ warp down
✓ Disconnected from WARP

# Check again
$ warp status
Status update: Disconnected
```

## Most Used Commands (2 minutes to learn)

```bash
warp status              # Check connection
warp up                  # Connect
warp down                # Disconnect
warp toggle              # Toggle on/off
warp logs --follow       # Watch logs (Ctrl+C to stop)
warp mode warp           # Change to WARP mode
warp exclude add DOMAIN  # Exclude domain from WARP
warp --help              # See all commands
```

## Done! 🎉

You're all set. Use `warp` in your terminal just like any other command.

```bash
$ warp
Cloudflare WARP CLI

Usage: warp [OPTIONS] <COMMAND>

Commands:
  status    Show current WARP status
  up        Connect to WARP
  down      Disconnect from WARP
  toggle    Toggle WARP connection
  mode      Set WARP mode
  logs      Follow daemon logs
  exclude   Manage split tunnel
  daemon    Manage daemon
  ...
```

## Troubleshooting (If Something Goes Wrong)

**Installation failed?**
```bash
# Check if Cloudflare WARP is installed
ls "/Applications/Cloudflare WARP.app"

# If not, install it from App Store first:
# https://apps.apple.com/app/cloudflare-warp/id1423210915
```

**Command not found?**
```bash
# Make sure /usr/local/bin is in PATH
echo $PATH | grep -q "/usr/local/bin" && echo "OK" || echo "NOT OK"

# If not OK, add to ~/.zshrc or ~/.bashrc:
export PATH="/usr/local/bin:$PATH"
```

**Daemon not running?**
```bash
warp daemon restart
```

**Still stuck?**
- See `INSTALLATION.md` for detailed troubleshooting
- Run `warp diagnose` to check everything
- Check logs: `warp logs --follow`

## Next Steps

- **Want more examples?** → Read `USAGE_EXAMPLES.md`
- **Need help installing?** → Read `INSTALLATION.md`
- **Want technical details?** → Read `README_COMPLETE.md`
- **Need all features?** → Run `warp --help`

## One-Liners for Common Tasks

```bash
# Check if connected (script-friendly)
warp status --json | grep -q '"connected":true' && echo "ON" || echo "OFF"

# Auto-reconnect if disconnected
warp status --quiet || warp up

# View real-time logs
warp logs --follow

# Exclude your home network
warp exclude add 192.168.1.0/24

# Restart everything
warp daemon restart && sleep 2 && warp up
```

---

**That's it! Enjoy your CLI.** 🚀

```
$ warp up
✓ Connected to WARP
```
