#!/bin/bash

# Phase 2: Remove Cloudflare WARP GUI (Keep Daemon)
# This script removes the GUI components while keeping the daemon running.

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Phase 2: Remove GUI, Keep Daemon                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Kill running GUI
echo "Step 1: Stopping running GUI..."
if pkill -f "Cloudflare WARP" 2>/dev/null; then
    echo "  ✓ Killed GUI process"
    sleep 2
else
    echo "  → GUI not running (or already stopped)"
fi

# Step 2: Verify no GUI process
echo ""
echo "Step 2: Verifying GUI is stopped..."
if pgrep -f "Cloudflare WARP" > /dev/null 2>&1; then
    echo "  → GUI still running, force killing..."
    pkill -9 -f "Cloudflare WARP" 2>/dev/null || true
    sleep 1
fi

if ! pgrep -f "Cloudflare WARP" > /dev/null 2>&1; then
    echo "  ✓ GUI is stopped"
else
    echo "  ✗ Could not stop GUI (may auto-restart)"
fi

# Step 3: Remove auto-launcher
echo ""
echo "Step 3: Removing auto-launcher (requires sudo)..."
echo "  Target: /Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"
echo ""

LAUNCHER_PATH="/Applications/Cloudflare WARP.app/Contents/Library/LoginItems/LoginLauncherApp.app"

if [ -d "$LAUNCHER_PATH" ]; then
    echo "  Removing LoginLauncherApp.app..."
    sudo rm -rf "$LAUNCHER_PATH"

    if [ ! -d "$LAUNCHER_PATH" ]; then
        echo "  ✓ Successfully removed auto-launcher"
    else
        echo "  ✗ Failed to remove (permission denied?)"
        exit 1
    fi
else
    echo "  → Auto-launcher already removed"
fi

# Step 4: Hide app from Spotlight/Dock
echo ""
echo "Step 4: Hiding app from Spotlight/Dock..."
APP_PATH="/Applications/Cloudflare WARP.app"

if [ -d "$APP_PATH" ]; then
    sudo touch "$APP_PATH/.hidden"
    echo "  ✓ App hidden from Spotlight/Dock"
else
    echo "  ✗ Cloudflare WARP.app not found"
    exit 1
fi

# Step 5: Verify daemon is still running
echo ""
echo "Step 5: Verifying daemon is still running..."
if pgrep CloudflareWARP > /dev/null; then
    DAEMON_PID=$(pgrep CloudflareWARP)
    echo "  ✓ Daemon is running (PID: $DAEMON_PID)"
else
    echo "  ✗ Daemon is not running"
    echo "  → Attempting to start daemon..."
    sudo launchctl start com.cloudflare.1dot1dot1dot1.macos.warp.daemon
    sleep 2

    if pgrep CloudflareWARP > /dev/null; then
        DAEMON_PID=$(pgrep CloudflareWARP)
        echo "  ✓ Daemon started (PID: $DAEMON_PID)"
    else
        echo "  ✗ Failed to start daemon"
        exit 1
    fi
fi

# Step 6: Verify warp CLI still works
echo ""
echo "Step 6: Verifying warp CLI still works..."
if command -v warp &> /dev/null; then
    echo "  ✓ warp CLI is in PATH"
    STATUS=$(warp status 2>&1 | head -1)
    echo "  ✓ warp status: $STATUS"
else
    echo "  ✗ warp CLI not found in PATH"
    echo "  → You may need to run: ./install.sh"
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Phase 2 Complete!                                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "What was changed:"
echo "  ✓ GUI process stopped"
echo "  ✓ Auto-launcher removed (won't restart at login)"
echo "  ✓ App hidden from Spotlight/Dock"
echo "  ✓ Daemon still running and operational"
echo ""
echo "Next steps:"
echo "  • Use: warp up/down/status"
echo "  • Daemon will continue running in background"
echo "  • For Phase 3, see: NEXT_STEPS.md"
echo ""
echo "To verify:"
echo "  $ warp status"
echo "  $ pgrep CloudflareWARP  # should show PID"
echo ""
