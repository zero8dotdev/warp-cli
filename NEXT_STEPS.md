# Next Steps: Phases 2-4

This document outlines how to proceed with Phases 2, 3, and 4 of the plan.

## Phase 2: Remove the GUI, Keep the Daemon

**Goal**: Disable the Cloudflare WARP GUI while keeping the daemon running.

### Why This Works

The architecture separates concerns:

- **Daemon** (`CloudflareWARP` binary) → runs as root via launchd, controlled independently
- **GUI** (Swift app) → optional wrapper, can be removed without affecting daemon
- **warp-cli** (existing CLI) → already talks to daemon via Unix socket at `/var/run/warp_service`

Removing the GUI launcher won't stop the daemon from running.

### Step 1: Kill the Running GUI (if any)

```bash
pkill -f "Cloudflare WARP" 2>/dev/null || true
```

Verify it's gone:

```bash
pgrep "Cloudflare WARP"  # should return nothing
```

### Step 2: Disable Auto-Launch

The GUI has a login item that starts it automatically. Remove it:

```bash
sudo rm -rf "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"
```

Verify it's removed:

```bash
ls -la "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/"
# should be empty or not exist
```

### Step 3: Verify Daemon is Still Running

```bash
pgrep CloudflareWARP  # should show a PID (root daemon)
```

Check launchd status:

```bash
launchctl list | grep cloudflare
# should show: com.cloudflare.1dot1dot1dot1.macos.warp.daemon
```

### Step 4: Test CLI Still Works

```bash
warp status  # should work normally
```

### Step 5 (Optional): Hide the App from Spotlight/Dock

```bash
sudo touch "/Applications/Cloudflare WARP.app/.hidden"
```

This prevents it from appearing in Spotlight search and Dock when clicked.

### Reverting Phase 2

If you need to restore the GUI:

1. Reinstall from App Store or Cloudflare
2. Or restore the backup: `rsync -av ~/Backups/Cloudflare\ WARP.app /Applications/`

---

## Phase 3: Update Monitoring Without the GUI

**Problem**: The GUI uses Sparkle framework to auto-update. Without the GUI, we lose this feature.

**Solution**: Implement periodic version checking via our CLI + a launchd agent.

### Step 1: Find the Sparkle Feed URL

The Sparkle framework stores the app cast URL somewhere. Try these methods:

```bash
# Method 1: Query Info.plist
defaults read "/Applications/Cloudflare WARP.app/Contents/Info.plist" SUFeedURL

# Method 2: Search strings in daemon binary
strings "/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP" | grep -i appcast

# Method 3: Search in warp-cli binary
strings /usr/local/bin/warp-cli | grep -i appcast

# Method 4: Check Frameworks directory
ls -la "/Applications/Cloudflare WARP.app/Contents/Frameworks/"
```

If found, the feed URL will look like: `https://updates.cloudflare.com/warp/appcast.xml`

### Step 2: Implement Periodic Version Checking

We've already got `warp update check` that prints the current version. To monitor for updates:

#### Option A: Manual Check (Lightweight)

```bash
# Run manually when you want to check
warp update check

# Output:
# Checking for updates...
# Current version: 2025.10.186.0
# No updates available
```

#### Option B: Periodic Check via Launchd Agent

Create a launchd agent that runs `warp update check` daily:

```bash
# Create agent plist
cat > ~/Library/LaunchAgents/com.zero8.warp-update-check.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.zero8.warp-update-check</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/warp</string>
        <string>update</string>
        <string>check</string>
    </array>
    <key>StartInterval</key>
    <integer>86400</integer> <!-- Run every 24 hours -->
    <key>StandardOutPath</key>
    <string>/tmp/warp-update-check.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/warp-update-check.err</string>
</dict>
</plist>
EOF

# Enable the agent
launchctl load ~/Library/LaunchAgents/com.zero8.warp-update-check.plist

# Check logs
tail -f /tmp/warp-update-check.log
```

#### Option C: Use Homebrew (if available)

Check if Cloudflare WARP is available via Homebrew:

```bash
brew search cloudflare-warp
brew info --cask cloudflare-warp
```

If available:

```bash
# Cask auto-updates
brew upgrade --cask cloudflare-warp
```

### Step 3: Send Notification When Update Available

Enhance `update.rs` to send a macOS notification:

```rust
// src/commands/update.rs - enhanced version

use std::process::Command;

fn send_notification(title: &str, message: &str) -> Result<()> {
    let script = format!(
        r#"display notification "{}" with title "{}""#,
        message, title
    );

    Command::new("osascript")
        .arg("-e")
        .arg(&script)
        .output()?;

    Ok(())
}

pub fn run(action: Option<UpdateAction>, json: bool, quiet: bool, _verbose: bool) -> Result<()> {
    // ... existing code ...

    // If update available:
    if update_available {
        send_notification("WARP Update Available", &format!(
            "New version {new_version} is available. Update via App Store.",
            new_version = new_version
        ))?;
    }
}
```

---

## Phase 4: Direct gRPC Communication (Advanced, Optional)

**Goal**: Talk directly to the daemon without relying on `warp-cli` binary.

**Complexity**: High - requires reverse-engineering the gRPC `.proto` schema.

### Why You Might Want This

- Remove dependency on `warp-cli` binary (currently 20 MB)
- Potentially faster (direct socket vs spawning process)
- More control over error handling and features

### Why It's Optional

- `warp-cli` already works and is maintained by Cloudflare
- Current implementation is already minimal and fast
- Reverse-engineering is time-consuming

### Step 1: Extract .proto Definitions

The daemon binary contains embedded protobuf definitions. Extract them:

#### Method 1: Strings Extraction (Easiest)

```bash
# Extract all strings that look like proto definitions
strings "/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP" | \
    grep -E "^\s*(service|rpc|message|enum)" | head -50
```

#### Method 2: Binary Analysis with Hopper/Ghidra

1. Download [Hopper Disassembler](https://www.hopperapp.com/) (macOS) or [Ghidra](https://ghidra-sre.org/) (free)
2. Open `/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP`
3. Search for string patterns like `.proto`, `service`, `rpc`
4. Reconstruct `.proto` from field IDs and type info

#### Method 3: Dynamic Interception with Frida

```bash
# Install Frida
brew install frida

# Create frida hook script (intercept_grpc.js)
cat > intercept_grpc.js << 'EOF'
// Hook protobuf encode/decode to dump messages
Interceptor.attach(Module.findExportByName(null, "protobuf_encode"), {
  onEnter(args) {
    console.log("Protobuf encode called");
    console.log("Buffer:", args[0]);
  }
});
EOF

# Run Frida
frida -n CloudflareWARP --no-pause -l intercept_grpc.js

# Run warp-cli commands in another terminal to capture traffic
```

#### Method 4: Static Analysis with nm/otool

```bash
# List symbols that might reveal gRPC services
nm "/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP" | grep -i rpc

# Or use otool
otool -t "/Applications/Cloudflare WARP.app/Contents/Resources/CloudflareWARP" | head -100
```

### Step 2: Build .proto Files

Once you've extracted the schema, create `.proto` files:

```protobuf
// proto/warp_service.proto

syntax = "proto3";

package warp;

service WarpService {
    rpc Connect(ConnectRequest) returns (ConnectResponse);
    rpc Disconnect(DisconnectRequest) returns (DisconnectResponse);
    rpc GetStatus(GetStatusRequest) returns (GetStatusResponse);
    // ... more methods ...
}

message ConnectRequest {
    // Fields...
}

message ConnectResponse {
    bool success = 1;
    string error = 2;
}

// ... more messages ...
```

### Step 3: Generate Rust Bindings

Add to `Cargo.toml`:

```toml
[dependencies]
tonic = "0.10"
prost = "0.12"

[build-dependencies]
tonic-build = "0.10"
```

Create `build.rs`:

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::compile_protos("proto/warp_service.proto")?;
    Ok(())
}
```

### Step 4: Create gRPC Client

```rust
// src/grpc_client.rs

use tonic::transport::Channel;
use std::pin::Pin;

// Generated from proto compilation
pub mod warp {
    include!(concat!(env!("OUT_DIR"), "/warp.rs"));
}

pub async fn connect() -> Result<()> {
    let channel = Channel::from_static("http+unix:///var/run/warp_service")
        .connect()
        .await?;

    let mut client = warp::WarpServiceClient::new(channel);
    let request = warp::ConnectRequest {};

    let response = client.connect(request).await?;
    Ok(())
}
```

### Step 5: Integrate into Commands

Replace `warp_cli.run()` calls with gRPC client calls:

```rust
// In src/warp_cli.rs

#[cfg(feature = "grpc")]
pub async fn connect() -> Result<()> {
    grpc_client::connect().await
}

#[cfg(not(feature = "grpc"))]
pub fn connect() -> Result<()> {
    // Fall back to warp-cli wrapper
    std::process::Command::new("warp-cli")
        .arg("connect")
        .status()?;
    Ok(())
}
```

Enable via feature flag:

```toml
# Cargo.toml
[features]
default = []
grpc = ["tonic", "prost"]
```

Build with:

```bash
cargo build --release --features grpc
```

---

## Decision Matrix

| Phase | Difficulty | Priority | Required? | Next Step |
|-------|-----------|----------|-----------|-----------|
| 1 (CLI Wrapper) | Easy | High | ✅ Yes | **DONE** |
| 2 (Remove GUI) | Trivial | High | ✅ Recommended | Run `rm -rf LoginLauncherApp.app` |
| 3 (Update Monitor) | Medium | Medium | ⏳ Optional | Set up launchd agent for periodic checks |
| 4 (gRPC Direct) | Hard | Low | ❌ No | Only if you want to remove `warp-cli` dependency |

---

## Recommended Execution Order

1. **Today**: ✅ Phase 1 is done
2. **This week**: Phase 2 (just a few `rm` commands)
3. **Next week**: Phase 3 (add launchd agent for update checks)
4. **Future**: Phase 4 (only if needed)

---

## Troubleshooting

### Daemon dies after removing GUI

**Problem**: After removing LoginLauncherApp, daemon stops running.

**Solution**: Daemon is controlled by launchd, not the GUI. Check:

```bash
pgrep CloudflareWARP  # should still run
launchctl list | grep cloudflare  # should be listed
```

If daemon is stopped:

```bash
sudo launchctl start com.cloudflare.1dot1dot1dot1.macos.warp.daemon
```

### warp-cli no longer works

**Problem**: After changes, `warp status` fails.

**Solution**: Verify `warp-cli` is still in PATH:

```bash
which warp-cli
ls -la /usr/local/bin/warp-cli
```

If missing, reinstall Cloudflare WARP app.

### Update check fails

**Problem**: `warp update check` errors out.

**Solution**:

```bash
# Check Info.plist is readable
defaults read "/Applications/Cloudflare WARP.app/Contents/Info"

# Verify app is still installed
ls -la "/Applications/Cloudflare WARP.app/Contents/Info.plist"
```

---

## Resources

- [tonic - Rust gRPC framework](https://github.com/hyperium/tonic)
- [Hopper Disassembler](https://www.hopperapp.com/)
- [Ghidra - Free reverse engineering tool](https://ghidra-sre.org/)
- [Frida - Dynamic instrumentation](https://frida.re/)
- [launchd - System service launcher](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchDaemons.html)
- [macOS Notifications (osascript)](https://developer.apple.com/library/archive/documentation/ScriptingFramework/Conceptual/AppleScriptObjCTB/Chapters/SendingMessages.html#//apple_ref/doc/uid/TP40010810-CH106-SW4)
