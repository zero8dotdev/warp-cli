# warp-cli

> **Simple, fast VPN access from your terminal.**

Control Cloudflare WARP with intuitive commands instead of wrestling with menus.

```bash
warp up              # Connect to WARP
warp down            # Disconnect
warp status          # Check your status
```

---

## What is WARP?

Cloudflare WARP is a free VPN service that:
- **Encrypts your internet traffic** - Your ISP can't see what you're doing
- **Hides your location** - Websites see Cloudflare's IP, not yours
- **Blocks malware & trackers** - Cloudflare's network filters out bad stuff
- **Makes browsing faster** - Cloudflare optimizes your connection

**This CLI works with WARP (the free consumer version).** For enterprise/teams? See [Cloudflare One](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/warp/).

[Learn more about WARP →](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/warp/)

---

## Why Use This CLI?

The official WARP app is designed for people who click menus. If you live in the terminal, this is better:

| Need | Official App | warp-cli |
|------|--------------|----------|
| **Quick toggle** | Click menu bar | `warp up` |
| **Check connection** | Open app | `warp status` |
| **Scripts & automation** | ❌ Not possible | ✅ Works great |
| **Low resource usage** | High (GUI overhead) | Low |
| **Works on servers** | ❌ No GUI | ✅ Works everywhere |

---

## 30-Second Setup

One command to install everything:

```bash
brew tap zero8dotdev/tools
brew install warp-cli
```

That's it! The formula automatically:
- ✅ Installs WARP daemon
- ✅ Removes the GUI app (you don't need it)
- ✅ Installs warp-cli

Then use it:
```bash
warp up          # Connect to WARP
warp status      # Check connection
warp --help      # See all commands
```

---

## Common Commands

```bash
# Connection control
warp up                    # Connect to WARP
warp down                  # Disconnect
warp toggle                # Switch on/off
warp status                # Check connection status

# Split tunnel (exclude sites from VPN)
warp exclude add example.com      # Don't route through WARP
warp exclude list                 # See all exclusions
warp exclude remove example.com   # Remove from list

# Info & troubleshooting
warp stats                 # Show connection quality
warp logs                  # View recent activity
warp diagnose              # Run health check
```

See all commands: `warp --help`

---

## Installation Options

**Recommended (easiest):**
```bash
brew tap zero8dotdev/tools
brew install warp-cli
```

**From source:**
```bash
git clone https://github.com/zero8dotdev/warp-cli.git
cd warp-cli
./install-complete.sh
```

**Or with one-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash
```

---

## Need More?

**New to WARP?**
- [QUICKSTART.md](QUICKSTART.md) - Get running in 5 minutes
- [Official WARP Documentation](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/warp/)

**Want technical details?**
- [DETAILS.md](DETAILS.md) - How it works under the hood
- [INSTALLATION.md](INSTALLATION.md) - Troubleshooting & install methods
- [PROJECT_STORY.md](PROJECT_STORY.md) - Why this was built

**Want real-world examples?**
- [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) - 100+ command examples for scripts & automation

**For developers:**
- [Homebrew setup guide](HOMEBREW_SETUP.md) - Publishing other tools

---

## FAQs

**Q: Do I need to install the WARP app first?**
A: Yes, the app sets up the VPN daemon that this CLI controls. Think of it as: app = engine, CLI = dashboard.

**Q: Will this work on my Mac?**
A: Yes, all Macs with Homebrew (Intel or Apple Silicon).

**Q: Is it safe?**
A: Yes. Cloudflare is a major company. This CLI is just a friendlier way to control their VPN.

**Q: Can I use this on Linux/Windows?**
A: Not yet. It's macOS-only because WARP daemon integration is macOS-specific.

**Q: Do I pay anything?**
A: No, WARP is free (with optional paid plans for advanced features).

**Q: Is this for enterprise/teams?**
A: No, this CLI is for personal/consumer WARP. For enterprise use, see [Cloudflare One](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/warp/).

**Q: How much data do I use?**
A: WARP doesn't count against your ISP's data cap—you're encrypting existing traffic, not adding to it.

**Q: Can I script this?**
A: Yes! Use `warp status --json` to get structured output for scripts.

---

## Status

✅ **Production ready** for daily use
🎓 **Learning project** - demonstrates CLI design, Rust, and macOS integration
📦 **Open source** - MIT licensed

Not affiliated with Cloudflare. Use WARP according to their [terms of service](https://www.cloudflare.com/terms/).

---

## Next Steps

1. **[QUICKSTART.md](QUICKSTART.md)** if you're new to WARP
2. **Install it** with the command above
3. **Try it**: `warp up` then `warp status`
4. **Get help**: `warp --help`

Questions? Issues? See [INSTALLATION.md](INSTALLATION.md) for troubleshooting.
