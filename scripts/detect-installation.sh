#!/bin/bash

# detect-installation.sh
# Detects the current state of Cloudflare WARP installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WARP_APP_PATH="/Applications/Cloudflare WARP.app"
WARP_CLI_PATH="/usr/local/bin/warp-cli"
WARP_DEX_PATH="/usr/local/bin/warp-dex"
DAEMON_LABEL="com.cloudflare.1dot1dot1dot1.macos.warp.daemon"
DAEMON_PLIST="/Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist"

# State tracking
WARP_APP_INSTALLED=false
WARP_CLI_INSTALLED=false
DAEMON_INSTALLED=false
DAEMON_RUNNING=false
SOCKET_EXISTS=false

# Check if Cloudflare WARP app is installed
check_warp_app() {
    if [ -d "$WARP_APP_PATH" ]; then
        WARP_APP_INSTALLED=true
        return 0
    fi
    return 1
}

# Check if warp-cli is available
check_warp_cli() {
    if command -v warp-cli &> /dev/null; then
        WARP_CLI_INSTALLED=true
        return 0
    fi
    return 1
}

# Check if daemon is configured
check_daemon_installed() {
    if [ -f "$DAEMON_PLIST" ]; then
        DAEMON_INSTALLED=true
        return 0
    fi
    return 1
}

# Check if daemon is running
check_daemon_running() {
    if pgrep -x "CloudflareWARP" > /dev/null 2>&1; then
        DAEMON_RUNNING=true
        return 0
    fi
    return 1
}

# Check if IPC socket exists
check_socket() {
    if [ -S "/var/run/warp_service" ]; then
        SOCKET_EXISTS=true
        return 0
    fi
    return 1
}

# Get version info
get_version_info() {
    if [ "$WARP_APP_INSTALLED" = true ]; then
        defaults read "$WARP_APP_PATH/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "unknown"
    else
        echo "not installed"
    fi
}

# Get warp-cli version
get_warp_cli_version() {
    if [ "$WARP_CLI_INSTALLED" = true ]; then
        warp-cli --version 2>/dev/null | head -1 || echo "unknown"
    else
        echo "not installed"
    fi
}

# Get daemon status
get_daemon_status() {
    if [ "$DAEMON_RUNNING" = true ]; then
        echo "running"
    elif [ "$DAEMON_INSTALLED" = true ]; then
        echo "installed but not running"
    else
        echo "not installed"
    fi
}

# Print human-readable report
print_human_report() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           Cloudflare WARP Installation Detection           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # Cloudflare WARP App
    echo -n "Cloudflare WARP App:      "
    if [ "$WARP_APP_INSTALLED" = true ]; then
        echo -e "${GREEN}✓ Installed${NC} at $WARP_APP_PATH"
        echo "  Version: $(get_version_info)"
    else
        echo -e "${RED}✗ Not found${NC}"
    fi

    # warp-cli
    echo ""
    echo -n "warp-cli binary:          "
    if [ "$WARP_CLI_INSTALLED" = true ]; then
        echo -e "${GREEN}✓ Available${NC}"
        CLI_PATH=$(which warp-cli)
        echo "  Location: $CLI_PATH"
        echo "  Version: $(get_warp_cli_version)"
    else
        echo -e "${RED}✗ Not found${NC}"
    fi

    # Daemon
    echo ""
    echo -n "Daemon configuration:     "
    if [ "$DAEMON_INSTALLED" = true ]; then
        echo -e "${GREEN}✓ Configured${NC}"
        echo "  Plist: $DAEMON_PLIST"
    else
        echo -e "${RED}✗ Not configured${NC}"
    fi

    # Daemon status
    echo ""
    echo -n "Daemon status:            "
    case "$(get_daemon_status)" in
        running)
            DAEMON_PID=$(pgrep -x "CloudflareWARP")
            echo -e "${GREEN}✓ Running${NC} (PID: $DAEMON_PID)"
            ;;
        "installed but not running")
            echo -e "${YELLOW}⚠ Stopped${NC}"
            ;;
        "not installed")
            echo -e "${RED}✗ Not running${NC}"
            ;;
    esac

    # IPC Socket
    echo ""
    echo -n "IPC Socket:               "
    if [ "$SOCKET_EXISTS" = true ]; then
        echo -e "${GREEN}✓ Ready${NC} at /var/run/warp_service"
    else
        echo -e "${RED}✗ Not available${NC}"
    fi

    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo ""
}

# Print JSON report
print_json_report() {
    cat << EOF
{
  "warp_app": {
    "installed": $([ "$WARP_APP_INSTALLED" = true ] && echo "true" || echo "false"),
    "path": "$WARP_APP_PATH",
    "version": "$(get_version_info)"
  },
  "warp_cli": {
    "installed": $([ "$WARP_CLI_INSTALLED" = true ] && echo "true" || echo "false"),
    "path": "$(command -v warp-cli 2>/dev/null || echo "not found")",
    "version": "$(get_warp_cli_version)"
  },
  "daemon": {
    "installed": $([ "$DAEMON_INSTALLED" = true ] && echo "true" || echo "false"),
    "running": $([ "$DAEMON_RUNNING" = true ] && echo "true" || echo "false"),
    "plist": "$DAEMON_PLIST",
    "pid": $(pgrep -x "CloudflareWARP" 2>/dev/null || echo "null")
  },
  "socket": {
    "exists": $([ "$SOCKET_EXISTS" = true ] && echo "true" || echo "false"),
    "path": "/var/run/warp_service"
  },
  "readiness": {
    "can_extract": $([ "$WARP_APP_INSTALLED" = true ] && echo "true" || echo "false"),
    "can_use_existing": $([ "$WARP_CLI_INSTALLED" = true ] && [ "$DAEMON_RUNNING" = true ] && echo "true" || echo "false"),
    "fully_operational": $([ "$DAEMON_RUNNING" = true ] && [ "$SOCKET_EXISTS" = true ] && echo "true" || echo "false")
  }
}
EOF
}

# Main execution
main() {
    # Run all checks
    check_warp_app
    check_warp_cli
    check_daemon_installed
    check_daemon_running
    check_socket

    # Output report
    if [ "${1:-human}" = "json" ]; then
        print_json_report
    else
        print_human_report
    fi

    # Exit with status based on readiness
    if [ "$DAEMON_RUNNING" = true ] && [ "$SOCKET_EXISTS" = true ]; then
        exit 0  # Ready to use
    elif [ "$WARP_APP_INSTALLED" = true ]; then
        exit 1  # Can extract
    else
        exit 2  # Need to install
    fi
}

# Run main
main "$@"
