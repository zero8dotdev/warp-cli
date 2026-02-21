#!/bin/bash

# setup-daemon.sh
# Sets up the Cloudflare WARP daemon via launchd

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DAEMON_PLIST="/Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist"
DAEMON_LABEL="com.cloudflare.1dot1dot1dot1.macos.warp.daemon"
WARP_APP_PATH="/Applications/Cloudflare WARP.app"
DAEMON_BINARY="$WARP_APP_PATH/Contents/Resources/CloudflareWARP"

print_header() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        Setting Up Cloudflare WARP Daemon                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

check_prerequisites() {
    echo "✓ Checking prerequisites..."

    if [ ! -x "$DAEMON_BINARY" ]; then
        echo -e "${RED}✗ Error: CloudflareWARP daemon not found or not executable${NC}"
        echo "  Expected at: $DAEMON_BINARY"
        exit 1
    fi

    echo "  ✓ CloudflareWARP daemon found and executable"
    echo ""
}

check_existing_daemon() {
    echo "✓ Checking for existing daemon..."

    if [ -f "$DAEMON_PLIST" ]; then
        echo "  → Daemon plist already exists"
        echo "  → Current configuration:"

        # Show current status
        if launchctl list "$DAEMON_LABEL" > /dev/null 2>&1; then
            DAEMON_PID=$(launchctl list "$DAEMON_LABEL" | grep -o "\"PID\" = [0-9]*" | grep -o "[0-9]*" || echo "unknown")
            echo "    Status: Running (PID: $DAEMON_PID)"
        else
            echo "    Status: Not running"
        fi

        # Offer to reload
        read -p "  Reload daemon configuration? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "  → Reloading daemon..."
            sudo launchctl unload "$DAEMON_PLIST" 2>/dev/null || true
            sleep 1
            sudo launchctl load "$DAEMON_PLIST"
            echo "  ✓ Daemon reloaded"
        fi
        return 0
    fi

    echo "  → No existing daemon configuration found"
    return 1
}

load_daemon() {
    echo "✓ Loading daemon..."

    if [ ! -f "$DAEMON_PLIST" ]; then
        echo -e "${RED}✗ Error: Daemon plist not found${NC}"
        echo "  Expected at: $DAEMON_PLIST"
        exit 1
    fi

    # Check if we need sudo (we do)
    if [ "$EUID" -ne 0 ] && [ ! -w "$DAEMON_PLIST" ]; then
        echo "  → Requires sudo to load daemon"
        sudo launchctl load "$DAEMON_PLIST" || {
            echo -e "${RED}✗ Failed to load daemon with launchctl${NC}"
            exit 1
        }
    else
        launchctl load "$DAEMON_PLIST" || {
            echo -e "${RED}✗ Failed to load daemon with launchctl${NC}"
            exit 1
        }
    fi

    sleep 2
    echo "  ✓ Daemon loaded"
}

verify_daemon() {
    echo "✓ Verifying daemon..."

    # Check if process is running
    if pgrep -x "CloudflareWARP" > /dev/null; then
        DAEMON_PID=$(pgrep -x "CloudflareWARP")
        echo "  ✓ Process running (PID: $DAEMON_PID)"
    else
        echo -e "  ${YELLOW}⚠ Warning: Process not running yet${NC}"
        echo "  → Waiting for daemon to start..."
        sleep 3

        if pgrep -x "CloudflareWARP" > /dev/null; then
            DAEMON_PID=$(pgrep -x "CloudflareWARP")
            echo "  ✓ Process started (PID: $DAEMON_PID)"
        else
            echo -e "  ${RED}✗ Daemon failed to start${NC}"
            echo "  → Check logs with: log stream --predicate 'eventMessage contains[cd] warp'"
            exit 1
        fi
    fi

    # Check if IPC socket is available
    sleep 1
    if [ -S "/var/run/warp_service" ]; then
        echo "  ✓ IPC socket ready at /var/run/warp_service"
    else
        echo -e "  ${YELLOW}⚠ Warning: IPC socket not yet available${NC}"
        echo "  → It may appear shortly as the daemon initializes"
    fi

    echo ""
}

# Main execution
main() {
    print_header
    check_prerequisites

    if check_existing_daemon; then
        verify_daemon
    else
        load_daemon
        verify_daemon
    fi

    echo "════════════════════════════════════════════════════════════"
    echo "✓ Daemon setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Run: ./install-complete.sh"
    echo "  2. Or test: warp status"
    echo ""
}

# Handle Ctrl+C
trap 'echo -e "\n${RED}✗ Setup cancelled${NC}"; exit 130' INT

main "$@"
