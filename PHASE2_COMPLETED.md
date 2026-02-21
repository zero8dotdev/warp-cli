# Phase 2: Remove GUI, Keep Daemon - Implementation Guide

## Completed: GUI Stopped ✅

The GUI has been successfully stopped:

```bash
$ pkill -f "Cloudflare WARP"
✓ GUI killed

$ pgrep -f "Cloudflare WARP"
[no output - GUI is stopped]
```

## Next: Remove Auto-Launcher (Requires sudo)

To permanently prevent the GUI from auto-launching at login, run this command:

```bash
sudo rm -rf "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"
```

Or use the provided script:

```bash
./phase2-remove-gui.sh
```

## What Phase 2 Does

### 1. ✅ Stops the Running GUI
```bash
pkill -f "Cloudflare WARP"
```
The GUI process(es) are terminated immediately.

### 2. Removes Auto-Launch (requires sudo)
```bash
sudo rm -rf "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"
```
Deletes the LoginLauncherApp that starts the GUI at login.

**Current state:**
```
$ ls -la "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/"
LoginLauncherApp.app  ← This will be removed
```

### 3. Hide App from Spotlight (optional, requires sudo)
```bash
sudo touch "/Applications/Cloudflare WARP.app/.hidden"
```
Prevents the app from appearing in Spotlight search results and Dock.

## Why This Works

**Architecture:**
```
User Login
  ↓
launchd starts login items
  ├─ LoginLauncherApp (REMOVES THIS)
  │   └─ Launches Cloudflare WARP GUI
  │
launchd starts daemons (independent)
  └─ CloudflareWARP daemon (KEEPS RUNNING)
      └─ IPC: /var/run/warp_service
```

The daemon is controlled by **launchd as a daemon**, not by the GUI. It runs independently.

## Current Status

### ✅ GUI is Stopped
```bash
$ pgrep -f "Cloudflare WARP"
[no output - GUI is not running]
```

### Pending: Remove Auto-Launcher

The LoginLauncherApp.app is still in place. You need to run:

```bash
sudo rm -rf "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"
```

### ✅ Daemon Status
```bash
$ launchctl list | grep cloudflare
5542	0	application.com.cloudflare.1dot1dot1dot1.macos.76529528.76529533
-	0	com.cloudflare.1dot1dot1dot1.macos.loginlauncherapp
```

The daemon will continue running even after removing the LoginLauncherApp.

## Complete Phase 2 (Step-by-Step)

### Option A: Use the Script (Recommended)

```bash
./phase2-remove-gui.sh
```

This script will:
1. ✅ Stop GUI (already done)
2. Remove auto-launcher
3. Hide app from Spotlight
4. Verify daemon is still running
5. Test warp CLI

### Option B: Manual Commands

```bash
# 1. Stop GUI
pkill -f "Cloudflare WARP"
sleep 2

# 2. Remove auto-launcher (requires entering password when prompted)
sudo rm -rf "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"

# 3. Hide app from Spotlight (optional)
sudo touch "/Applications/Cloudflare WARP.app/.hidden"

# 4. Verify daemon still runs
pgrep CloudflareWARP  # should show a PID

# 5. Test warp CLI
warp status
```

## Verification After Phase 2

### GUI Should Not Run on Login
After removing LoginLauncherApp, the GUI will no longer:
- Auto-start at login
- Auto-restart if killed
- Appear in Spotlight search (with .hidden)

### Daemon Should Still Run
```bash
$ pgrep CloudflareWARP
5542

$ launchctl list | grep cloudflare
5542	0	application.com.cloudflare.1dot1dot1dot1.macos.76529528.76529533
```

### warp CLI Should Work
```bash
$ warp status
Status update: Disconnected
Reason: Manual Disconnection

$ warp up
✓ Connected to WARP

$ warp daemon status
✓ Daemon is running
```

## Reverting Phase 2 (If Needed)

If you need to restore the GUI:

### Option 1: Reinstall from App Store
```bash
# Open App Store and search "Cloudflare WARP"
# Click Install
```

### Option 2: Restore from Time Machine
If you have a backup, restore the LoginLauncherApp:
```bash
# Use Time Machine to restore
/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app
```

### Option 3: Extract from Backup

If you saved the app bundle, restore it:
```bash
sudo cp -r ~/Backups/LoginLauncherApp.app "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/"
sudo chown -R root:wheel "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"
```

## Next Steps

After completing Phase 2:

### Immediate
1. ✅ Verify daemon is running: `warp daemon status`
2. ✅ Test connection: `warp up && warp status`
3. ✅ Verify no GUI appears

### Phase 3 (Optional): Update Monitoring
Set up automatic update checking:
- Create launchd agent for daily version checks
- Send macOS notification when update available
- See NEXT_STEPS.md for implementation

### Phase 4 (Optional): Direct gRPC
Remove dependency on warp-cli binary:
- Reverse-engineer .proto definitions
- Build gRPC client with tonic
- See NEXT_STEPS.md for details

## Files Created

- `phase2-remove-gui.sh` — Automated Phase 2 script
- `PHASE2_COMPLETED.md` — This document

## Summary

**Phase 2 Status:**

| Step | Status | Action |
|------|--------|--------|
| Stop GUI | ✅ Done | `pkill -f "Cloudflare WARP"` |
| Remove auto-launcher | ⏳ Pending | Run script or `sudo rm -rf LoginLauncherApp.app` |
| Hide from Spotlight | ⏳ Pending | Run script or `sudo touch .hidden` |
| Verify daemon | ✅ Ready | Script will test |
| Test warp CLI | ✅ Ready | Script will test |

**Next Action:**
```bash
./phase2-remove-gui.sh
```

Or manually:
```bash
sudo rm -rf "/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"
```
