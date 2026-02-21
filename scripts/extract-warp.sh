#!/bin/bash

# extract-warp.sh
# Extracts warp-cli and daemon binaries from Cloudflare WARP app

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
WARP_APP_PATH="/Applications/Cloudflare WARP.app"
RESOURCES_PATH="$WARP_APP_PATH/Contents/Resources"
INSTALL_PATH="/usr/local/bin"

# Source detection script to check current state
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-installation.sh" json > /dev/null 2>&1 || true

print_header() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        Extracting Cloudflare WARP Binaries                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

check_prerequisites() {
    echo "✓ Checking prerequisites..."

    if [ ! -d "$WARP_APP_PATH" ]; then
        echo -e "${RED}✗ Error: Cloudflare WARP app not found at $WARP_APP_PATH${NC}"
        echo "  Please install Cloudflare WARP from the App Store first."
        exit 1
    fi

    if [ ! -d "$RESOURCES_PATH" ]; then
        echo -e "${RED}✗ Error: Resources directory not found${NC}"
        exit 1
    fi

    if [ ! -x "$RESOURCES_PATH/warp-cli" ]; then
        echo -e "${RED}✗ Error: warp-cli binary not found or not executable${NC}"
        exit 1
    fi

    if [ ! -x "$RESOURCES_PATH/CloudflareWARP" ]; then
        echo -e "${RED}✗ Error: CloudflareWARP daemon binary not found${NC}"
        exit 1
    fi

    echo "  ✓ Cloudflare WARP app found"
    echo "  ✓ warp-cli binary found ($(du -h "$RESOURCES_PATH/warp-cli" | cut -f1))"
    echo "  ✓ CloudflareWARP daemon found ($(du -h "$RESOURCES_PATH/CloudflareWARP" | cut -f1))"
    echo ""
}

extract_warp_cli() {
    echo "✓ Extracting warp-cli..."

    if [ -f "$INSTALL_PATH/warp-cli" ]; then
        echo "  → warp-cli already exists at $INSTALL_PATH/warp-cli"
        echo "  → Skipping (use --force to overwrite)"
        return 0
    fi

    # Check if we need sudo
    if [ ! -w "$INSTALL_PATH" ]; then
        echo "  → Requires sudo to write to $INSTALL_PATH"
        sudo cp "$RESOURCES_PATH/warp-cli" "$INSTALL_PATH/warp-cli" || {
            echo -e "${RED}✗ Failed to copy warp-cli${NC}"
            exit 1
        }
        sudo chmod 755 "$INSTALL_PATH/warp-cli"
    else
        cp "$RESOURCES_PATH/warp-cli" "$INSTALL_PATH/warp-cli"
        chmod 755 "$INSTALL_PATH/warp-cli"
    fi

    echo "  ✓ Extracted to $INSTALL_PATH/warp-cli"
}

extract_daemon() {
    echo "✓ Extracting CloudflareWARP daemon..."

    DAEMON_PATH="$RESOURCES_PATH/CloudflareWARP"
    DAEMON_DEST="$WARP_APP_PATH/Contents/Resources/CloudflareWARP"

    # Daemon should already be in place, but verify it's there and executable
    if [ ! -x "$DAEMON_PATH" ]; then
        echo -e "${RED}✗ Daemon binary not executable${NC}"
        exit 1
    fi

    echo "  ✓ Daemon verified at $DAEMON_PATH (executable)"
}

verify_extraction() {
    echo "✓ Verifying extraction..."

    ERRORS=0

    # Check warp-cli
    if command -v warp-cli &> /dev/null; then
        CLI_VERSION=$(warp-cli --version 2>/dev/null | head -1 || echo "unknown")
        echo "  ✓ warp-cli: $CLI_VERSION"
    else
        echo -e "  ${RED}✗ warp-cli not in PATH${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    # Check daemon
    if [ -x "$RESOURCES_PATH/CloudflareWARP" ]; then
        echo "  ✓ CloudflareWARP: $(du -h "$RESOURCES_PATH/CloudflareWARP" | cut -f1)"
    else
        echo -e "  ${RED}✗ CloudflareWARP not executable${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}✗ Verification failed with $ERRORS error(s)${NC}"
        exit 1
    fi

    echo ""
}

# Main execution
main() {
    print_header
    check_prerequisites
    extract_warp_cli
    extract_daemon
    verify_extraction

    echo "════════════════════════════════════════════════════════════"
    echo "✓ Extraction complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Run: ./scripts/setup-daemon.sh"
    echo "  2. Then: ./install-complete.sh"
    echo ""
}

# Handle Ctrl+C
trap 'echo -e "\n${RED}✗ Extraction cancelled${NC}"; exit 130' INT

main "$@"
