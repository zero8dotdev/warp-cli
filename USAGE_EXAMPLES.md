# Cloudflare WARP CLI - Usage Examples

Practical examples for using the `warp` CLI tool.

## Installation

```bash
./install.sh
# or
sudo install -m 755 target/release/warp /usr/local/bin/warp

# Verify
which warp
warp --version
```

---

## Basic Connection Management

### Check if Connected

```bash
$ warp status
Status update: Connected
Reason: Auto Connect

$ warp status --json
{"connected":true,"raw":"Status update: Connected\nReason: Auto Connect"}

# Parse JSON in scripts
connected=$(warp status --json | jq .connected)
echo "Connected: $connected"  # Output: Connected: true
```

### Connect to WARP

```bash
$ warp up
✓ Connected to WARP

# Wait a moment and verify
$ sleep 2 && warp status
Status update: Connected
Reason: Manual Connection
```

### Disconnect from WARP

```bash
$ warp down
✓ Disconnected from WARP

$ warp status
Status update: Disconnected
Reason: Manual Disconnection
```

### Toggle Connection

```bash
$ warp status
Status update: Disconnected

$ warp toggle
✓ Toggled: now connected to WARP

$ warp status
Status update: Connected
```

---

## Advanced Connection Modes

### Switch to DoH (DNS over HTTPS)

```bash
$ warp mode doh
✓ Mode set to doh
```

### Switch to Gateway Mode

```bash
$ warp mode gateway
✓ Mode set to gateway
```

### Switch to WARP Mode

```bash
$ warp mode warp
✓ Mode set to warp
```

### Switch to WARP+ WARP Mode

```bash
$ warp mode warp+warp
✓ Mode set to warp+warp
```

### Validate Mode (Error Handling)

```bash
$ warp mode invalid_mode
Error: Invalid mode: invalid_mode. Valid modes: doh, gateway, warp, warp+warp
[exit code: 1]
```

---

## Split Tunnel Management (Exclude Domains/IPs)

### List Current Exclusions

```bash
$ warp exclude list
Excluded domains/IPs:
  - example.com
  - 192.168.1.0/24
  - *.internal.corp
```

### Add Domain to Exclusions

```bash
$ warp exclude add example.com
✓ Added 'example.com' to exclusions

# Verify
$ warp exclude list | grep example.com
  - example.com
```

### Add IP Range to Exclusions

```bash
$ warp exclude add 192.168.1.0/24
✓ Added '192.168.1.0/24' to exclusions

$ warp exclude add 10.0.0.0/8
✓ Added '10.0.0.0/8' to exclusions
```

### Remove from Exclusions

```bash
$ warp exclude remove example.com
✓ Removed 'example.com' from exclusions

# Verify it's gone
$ warp exclude list
Excluded domains/IPs:
  - 192.168.1.0/24
  - *.internal.corp
```

### Bulk Management

```bash
# Create a list of domains to exclude
cat > /tmp/exclude_list.txt << 'EOF'
internal.corp
staging.company.com
192.168.1.0/24
10.0.0.0/8
EOF

# Add each one
while read domain; do
    warp exclude add "$domain"
done < /tmp/exclude_list.txt

# Verify
warp exclude list
```

---

## Logs and Diagnostics

### View Current Daemon Logs

```bash
$ warp logs
2025-02-21 18:45:23 [INFO] Daemon started
2025-02-21 18:45:24 [INFO] Connected to 1.1.1.1
2025-02-21 18:45:25 [INFO] Split tunnel rules loaded
```

### Follow Logs (Real-Time)

```bash
$ warp logs --follow
2025-02-21 18:45:23 [INFO] Daemon started
2025-02-21 18:45:24 [INFO] Connected to 1.1.1.1
2025-02-21 18:45:25 [INFO] Split tunnel rules loaded
# ... continues to follow new log entries ...
[Press Ctrl+C to exit]
```

### Run Diagnostics

```bash
$ warp diagnose
=== Cloudflare WARP Diagnostics ===
System:
  OS: macOS 14.2.1
  Architecture: arm64
Daemon:
  Version: 2025.10.186.0
  Status: Running
Connection:
  Status: Connected
  IP: 203.0.113.42
  Location: US
Network:
  DNS: 1.1.1.1
  MTU: 1500
...
```

---

## Daemon Management

### Check Daemon Status

```bash
$ warp daemon status
✓ Daemon is running

# When not running:
$ warp daemon status
✗ Daemon is not running
```

### Start Daemon

```bash
$ warp daemon start
✓ Daemon started

# Verify with launchctl
$ launchctl list | grep cloudflare
123 0 com.cloudflare.1dot1dot1dot1.macos.warp.daemon
```

### Stop Daemon

```bash
$ warp daemon stop
✓ Daemon stopped

# Verify
$ pgrep CloudflareWARP
[no output - daemon is stopped]
```

### Restart Daemon

```bash
$ warp daemon restart
✓ Daemon restarted

# Usually helpful if daemon has issues
$ warp status  # Should work again
Status update: Connected
```

---

## Settings Management

### Show All Settings

```bash
$ warp settings
{
  "auto_connect": true,
  "connect_on_launch": true,
  "notify_on_connect": true,
  "ipv6": true,
  "tunnel_mode": "warp"
}
```

### Get Specific Setting

```bash
$ warp settings get auto_connect
true

$ warp settings get tunnel_mode
warp
```

### Set a Setting

```bash
$ warp settings set auto_connect false
✓ Setting 'auto_connect' updated

# Verify
$ warp settings get auto_connect
false

# Re-enable
$ warp settings set auto_connect true
✓ Setting 'auto_connect' updated
```

---

## Update Checking

### Check for Available Updates

```bash
$ warp update check
Checking for updates...
Current version: 2025.10.186.0
No updates available

# When update is available:
$ warp update check
Checking for updates...
Current version: 2025.10.186.0
New version available: 2025.10.187.0
Update via: App Store or Cloudflare website
```

### Get Version Info

```bash
$ warp update check --json
{
  "current_version": "2025.10.186.0",
  "status": "up_to_date",
  "message": "No updates available at this time"
}
```

---

## Global Flags

### JSON Output (Scripting)

```bash
# All commands support --json
$ warp status --json
{"connected":true,"raw":"..."}

$ warp daemon status --json
{"status":"running"}

# Parse with jq
warp status --json | jq '.connected'
# Output: true
```

### Quiet Mode (No Output)

```bash
# Useful in scripts where you only care about exit code
$ warp up --quiet
[no output]

# Check exit code
$ echo $?
0  # success

# When command fails:
$ warp mode invalid --quiet
[no output]

$ echo $?
1  # failure
```

### Verbose Mode (Debug Info)

```bash
$ warp up --verbose
[DEBUG] Spawning: /usr/local/bin/warp-cli connect
[DEBUG] Exit code: 0
✓ Connected to WARP
```

---

## Scripting Examples

### Bash Script: Auto-Connect if Disconnected

```bash
#!/bin/bash

if ! warp status --json | jq -e '.connected' > /dev/null; then
    warp up
    echo "Auto-connected to WARP"
else
    echo "Already connected"
fi
```

### Bash Script: Monitor Connection Health

```bash
#!/bin/bash

while true; do
    if warp status --quiet && [ $? -eq 0 ]; then
        if ! warp status --json | jq -e '.connected' > /dev/null; then
            echo "$(date): Connection lost, reconnecting..."
            warp up
        fi
    else
        echo "$(date): Daemon not responding"
    fi
    sleep 30
done
```

### Zsh Script: Add Domains to Exclude on Demand

```bash
#!/bin/zsh

function exclude_domain() {
    local domain=$1
    echo "Excluding $domain from WARP..."
    warp exclude add "$domain"
    echo "✓ $domain excluded"
}

# Usage:
exclude_domain "example.com"
exclude_domain "staging.company.com"
```

### Python Script: Get JSON Status

```python
#!/usr/bin/env python3
import json
import subprocess

result = subprocess.run(
    ["/usr/local/bin/warp", "status", "--json"],
    capture_output=True,
    text=True
)

data = json.loads(result.stdout)
print(f"Connected: {data['connected']}")
print(f"Details: {data['raw']}")
```

### Make/Justfile

```makefile
.PHONY: status connect disconnect toggle logs

status:
	warp status

connect:
	warp up

disconnect:
	warp down

toggle:
	warp toggle

logs:
	warp logs --follow

daemon-restart:
	warp daemon restart
```

Or with Justfile:

```just
# justfile

status:
    warp status

connect:
    warp up

disconnect:
    warp down

follow-logs:
    warp logs --follow

restart-daemon:
    warp daemon restart
```

Usage:

```bash
just status
just connect
just disconnect
```

---

## Common Workflows

### Enable Split Tunnel for Local Development

```bash
# Exclude local network from WARP
warp exclude add 127.0.0.1
warp exclude add localhost
warp exclude add 192.168.1.0/24  # Home network
warp exclude add 10.0.0.0/8      # Corporate network

# Verify
warp exclude list
```

### Temporary Disable WARP

```bash
# Quick toggle
warp toggle

# Or explicit
warp down

# Re-enable
warp up
```

### Switch Modes Based on Network

```bash
# On cellular: lightweight DoH only
warp mode doh

# On WiFi: full WARP tunnel
warp mode warp

# On corporate WiFi: WARP+ with exclusions
warp mode warp+warp
warp exclude add corp-internal.com
```

### Automated Startup Script

```bash
#!/bin/bash
# ~/.local/bin/warp-startup.sh

# Start warp daemon if not running
if ! warp daemon status --quiet; then
    warp daemon start
    sleep 2
fi

# Auto-connect
warp up

# Apply split tunnel rules
warp exclude add 192.168.1.0/24
warp exclude add internal.company.com

echo "WARP ready for work"
```

Add to login items or call from shell rc file:

```bash
# In ~/.zshrc or ~/.bashrc
if [ -f ~/.local/bin/warp-startup.sh ]; then
    ~/.local/bin/warp-startup.sh &
fi
```

---

## Troubleshooting via CLI

### Daemon Not Running?

```bash
$ warp daemon status
✗ Daemon is not running

# Try restarting
$ warp daemon restart
✓ Daemon restarted

# Verify
$ warp daemon status
✓ Daemon is running

# Check full details
$ warp diagnose
```

### Connection Unstable?

```bash
# Check current status
$ warp status

# Try reconnecting
$ warp down && sleep 2 && warp up

# Monitor logs while reconnecting
$ warp logs
```

### Settings Not Applied?

```bash
# Verify setting was set
$ warp settings get <setting_name>

# Restart daemon to apply
$ warp daemon restart

# Check again
$ warp settings get <setting_name>
```

---

## Exit Codes

Commands return standard exit codes:

```
0  = Success
1  = Error (check stderr for details)
```

Useful for scripts:

```bash
warp status
if [ $? -eq 0 ]; then
    echo "Command succeeded"
else
    echo "Command failed"
fi

# Compact form
warp status && echo "Success" || echo "Failed"
```
