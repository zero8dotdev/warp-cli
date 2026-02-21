# Cloudflare WARP CLI

> **Make Cloudflare WARP actually usable from the terminal.**

A beautiful, user-friendly command-line interface for Cloudflare WARP. Control your VPN connection with simple, intuitive commands instead of remembering 20+ confusing warp-cli arguments.

```bash
$ warp up
✓ Connected to WARP

$ warp status
Status: Connected to WARP

$ warp exclude add example.com
✓ Added 'example.com' to split tunnel
```

---

## ⚠️ Learning Project Notice

**This is an educational/learning project.** It demonstrates:
- Building a CLI wrapper in Rust
- Command-line UX design
- System integration on macOS
- Smart installation automation

Use at your own discretion. This is not an official Cloudflare tool.

---

## Why You Need This

### The Problem with Raw `warp-cli`

```bash
# Raw warp-cli - confusing and verbose
$ warp-cli connect
$ warp-cli disconnect
$ warp-cli tunnel host add example.com
$ warp-cli tunnel host list
$ warp-cli settings list
```

### Our Solution

```bash
# Our warp CLI - simple and intuitive
$ warp up
$ warp down
$ warp exclude add example.com
$ warp exclude list
$ warp settings
```

---

## ✨ What We Add

| Feature | warp-cli | Our CLI |
|---------|----------|---------|
| **Simple commands** | ❌ | ✅ |
| **Colored output** | ❌ | ✅ |
| **JSON mode** | ❌ | ✅ |
| **Pretty errors** | ❌ | ✅ |
| **Help text** | ❌ | ✅ |
| **Intuitive interface** | ❌ | ✅ |
| **Quiet mode** | ❌ | ✅ |
| **Connection toggle** | ❌ | ✅ |

---

## 🚀 Quick Start

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash
```

### Then Use Immediately

```bash
warp up              # Connect to WARP
warp down            # Disconnect
warp status          # Check status
warp exclude add X   # Add domain to split tunnel
warp --help          # See all commands
```

---

## 📚 All Available Commands

```bash
status              # Show connection status
up                  # Connect to WARP
down                # Disconnect from WARP
toggle              # Toggle connection state

mode warp           # Set WARP mode (warp, gateway, doh, warp+warp)
logs                # Follow daemon logs
stats               # Show connection statistics
settings            # View/manage settings

exclude list        # List excluded domains/IPs
exclude add DOMAIN  # Add domain to split tunnel
exclude remove X    # Remove from split tunnel

daemon status       # Check daemon health
daemon restart      # Restart daemon

update check        # Check for updates
diagnose            # Run diagnostics
```

---

## 💡 Real-World Examples

### Check Connection in Scripts
```bash
if warp status --json | jq -e '.connected' > /dev/null; then
  echo "Connected to WARP"
fi
```

### Setup Split Tunnel
```bash
warp exclude add 192.168.1.0/24    # Local network
warp exclude add example.com        # Specific domain
warp exclude list                   # View all exclusions
```

### Monitor Connection
```bash
warp stats          # Shows 40+ connection metrics
```

### Quiet Mode for Scripts
```bash
warp up --quiet     # No output, just exit code
```

---

## 🎯 Why This is Better

### 1. **User-Friendly Interface**
Compare these:
- Raw: `warp-cli tunnel host add example.com`
- Ours: `warp exclude add example.com`

### 2. **Beautiful Output**
```bash
$ warp up
✓ Connected to WARP
```
vs confusing raw output

### 3. **Scriptable**
```bash
warp status --json | jq .connected  # Easy scripting
```

### 4. **No GUI Bloat**
Pure CLI - no menu bar app needed. Just the daemon + CLI.

### 5. **Works Everywhere**
Single static Rust binary. No dependencies. Works on all Macs.

---

## 📋 Requirements

- **macOS 10.15+** (Catalina or newer)
- **Cloudflare WARP** app from [App Store](https://apps.apple.com/app/cloudflare-warp/id1423210915)
- **Rust** (for building) - `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

---

## 📖 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get running in 5 minutes
- **[DETAILS.md](DETAILS.md)** - Technical architecture & deep dive
- **[INSTALLATION.md](INSTALLATION.md)** - Troubleshooting & installation methods
- **[USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)** - 100+ real-world command examples

---

## 🛠️ How It Works

```
Your Terminal
    ↓
  warp CLI (our wrapper)
    ↓
warp-cli binary (communicates via gRPC)
    ↓
CloudflareWARP daemon (running as root via launchd)
    ↓
/var/run/warp_service (Unix socket)
```

We translate simple commands into warp-cli calls, add pretty colors, and handle all the complexity.

---

## 💎 Key Features

✅ **12 simple commands** - easy to remember and use
✅ **Colored output** - green for success, red for errors
✅ **JSON mode** - `--json` flag for scripting
✅ **Quiet mode** - minimal output for automation
✅ **Split tunnel** - manage excluded domains/IPs easily
✅ **Connection stats** - 40+ metrics about your connection
✅ **Zero dependencies** - single static binary
✅ **Works offline** - no internet needed after installation

---

## 🔄 Install Methods

### Method 1: One-Liner (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash
```

### Method 2: Clone & Install
```bash
git clone https://github.com/zero8dotdev/warp-cli.git
cd warp-cli
./install-complete.sh
```

### Method 3: Manual
```bash
git clone https://github.com/zero8dotdev/warp-cli.git
cd warp-cli
cargo build --release
sudo install -m 755 target/release/warp /usr/local/bin/warp
```

---

## ❓ FAQ

**Q: Why not just use the WARP GUI?**
A: The GUI is bloated, slow, and uses lots of battery. Our CLI is lightweight and perfect for developers.

**Q: Is this official?**
A: No, this is a community learning project. Use at your own risk.

**Q: Does it work on Intel/Apple Silicon?**
A: Yes, it's a universal Rust binary that works on both.

**Q: Can I script this?**
A: Yes! Use `--json` mode and parse with `jq` for full automation.

---

## 📝 License

Educational project. Not affiliated with Cloudflare. Use the Cloudflare WARP app according to their terms.
