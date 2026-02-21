# Cloudflare WARP CLI

A lightweight command-line tool for Cloudflare WARP. Control your VPN connection from the terminal.

## What You Can Do

```bash
# Check connection status
warp status

# Connect to WARP
warp up

# Disconnect from WARP
warp down

# Toggle connection
warp toggle

# View daemon logs
warp logs --follow

# Manage split tunnel (exclude domains)
warp exclude add example.com
warp exclude list

# Switch protocols
warp mode warp        # Standard WARP
warp mode gateway     # Gateway mode
warp mode doh         # DNS over HTTPS

# Control daemon
warp daemon restart

# Check for updates
warp update check

# View help
warp --help
```

## Install

**One-line install:**
```bash
curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash
```

Or clone and install manually:
```bash
git clone https://github.com/zero8dotdev/warp-cli.git
cd warp-cli
./install-complete.sh
```

## Requirements

- **macOS 10.15+**
- **Cloudflare WARP** app from [App Store](https://apps.apple.com/app/cloudflare-warp/id1423210915)
- **Rust** (for building from source) - `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

## Features

✅ Simple, intuitive commands
✅ JSON output mode for scripting
✅ Colored terminal output
✅ Split tunnel support
✅ Connection logging
✅ Daemon management
✅ Zero runtime dependencies

## Next Steps

- **Need more examples?** → See [QUICKSTART.md](QUICKSTART.md)
- **Want detailed guide?** → See [DETAILS.md](DETAILS.md)
- **Looking for advanced features?** → See [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)

## Support

- Run `warp --help` for all available commands
- Check `INSTALLATION.md` for troubleshooting
- Run `bash scripts/detect-installation.sh` to diagnose issues
