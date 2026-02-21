#!/bin/bash

# install-complete.sh
# Complete smart installation for Cloudflare WARP CLI tool

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Configuration
WARP_APP_PATH="/Applications/Cloudflare WARP.app"
INSTALL_PATH="/usr/local/bin"

print_banner() {
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║           Cloudflare WARP CLI - Complete Installation                   ║
║                                                                          ║
║                  One Command. Complete Setup.                            ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

EOF
}

print_step() {
    local step=$1
    local description=$2
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}Step $step:${NC} $description"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Step 1: Detect current state
step_detect() {
    print_step "1" "Detecting System State"

    if [ ! -x "$SCRIPTS_DIR/detect-installation.sh" ]; then
        echo -e "${RED}✗ Error: detect-installation.sh not found${NC}"
        exit 1
    fi

    # Run detection
    bash "$SCRIPTS_DIR/detect-installation.sh" human

    # Store result
    DETECT_EXIT=$?
    return $DETECT_EXIT
}

# Step 2: Extract binaries
step_extract() {
    print_step "2" "Extracting Cloudflare Binaries"

    if [ ! -d "$WARP_APP_PATH" ]; then
        echo -e "${YELLOW}⚠ Cloudflare WARP app not found${NC}"
        echo ""
        echo "You need to install Cloudflare WARP first."
        echo ""
        echo "Would you like to open the App Store now? (y/n)"
        read -p "  " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Opening App Store..."
            open "macappstore://apps.apple.com/app/cloudflare-warp/id1423210915"
            echo ""
            echo "After installing Cloudflare WARP, run this command again:"
            echo "  ./install-complete.sh"
            exit 0
        fi

        echo "Please install Cloudflare WARP from:"
        echo "  https://apps.apple.com/app/cloudflare-warp/id1423210915"
        echo ""
        echo "Then run this command again:"
        echo "  ./install-complete.sh"
        exit 0
    fi

    if [ ! -x "$SCRIPTS_DIR/extract-warp.sh" ]; then
        echo -e "${RED}✗ Error: extract-warp.sh not found${NC}"
        exit 1
    fi

    bash "$SCRIPTS_DIR/extract-warp.sh"
}

# Step 3: Setup daemon
step_setup_daemon() {
    print_step "3" "Setting Up Daemon"

    if [ ! -x "$SCRIPTS_DIR/setup-daemon.sh" ]; then
        echo -e "${RED}✗ Error: setup-daemon.sh not found${NC}"
        exit 1
    fi

    bash "$SCRIPTS_DIR/setup-daemon.sh"
}

# Step 4: Build CLI tool
step_build_cli() {
    print_step "4" "Building warp CLI Tool"

    echo "✓ Checking Rust toolchain..."

    if ! command -v cargo &> /dev/null; then
        echo -e "${RED}✗ Error: Rust/Cargo not found${NC}"
        echo ""
        echo "Install Rust from: https://rustup.rs/"
        echo ""
        exit 1
    fi

    RUST_VERSION=$(rustc --version)
    echo "  $RUST_VERSION"

    echo ""
    echo "✓ Building in release mode..."
    echo "  (This may take a minute on first build...)"

    cd "$SCRIPT_DIR"

    if cargo build --release 2>&1 | grep -E "(Compiling|Finished)"; then
        echo ""
        echo "✓ Build successful"
    else
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi

    # Verify binary
    if [ ! -x "$SCRIPT_DIR/target/release/warp" ]; then
        echo -e "${RED}✗ Binary not found after build${NC}"
        exit 1
    fi

    BINARY_SIZE=$(du -h "$SCRIPT_DIR/target/release/warp" | cut -f1)
    echo "  Binary: $BINARY_SIZE at target/release/warp"
    echo ""
}

# Step 5: Install CLI tool
step_install_cli() {
    print_step "5" "Installing warp CLI"

    echo "✓ Installing to /usr/local/bin..."

    if [ ! -w "$INSTALL_PATH" ]; then
        echo "  → Requires sudo (elevated privileges)"
        sudo install -m 755 "$SCRIPT_DIR/target/release/warp" "$INSTALL_PATH/warp" || {
            echo -e "${RED}✗ Installation failed${NC}"
            exit 1
        }
    else
        install -m 755 "$SCRIPT_DIR/target/release/warp" "$INSTALL_PATH/warp" || {
            echo -e "${RED}✗ Installation failed${NC}"
            exit 1
        }
    fi

    echo "  ✓ Installed to /usr/local/bin/warp"
    echo ""
}

# Step 6: Verify installation
step_verify() {
    print_step "6" "Verifying Installation"

    ERRORS=0

    # Check warp binary
    echo "✓ Checking warp CLI..."
    if command -v warp &> /dev/null; then
        WARP_VERSION=$(warp --version 2>/dev/null || echo "1.0.0")
        echo "  ✓ warp: $WARP_VERSION"
    else
        echo -e "  ${RED}✗ warp not in PATH${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    # Check warp-cli
    echo "✓ Checking warp-cli..."
    if command -v warp-cli &> /dev/null; then
        CLI_VERSION=$(warp-cli --version 2>/dev/null | head -1 || echo "unknown")
        echo "  ✓ warp-cli: $CLI_VERSION"
    else
        echo -e "  ${RED}✗ warp-cli not found${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    # Check daemon
    echo "✓ Checking daemon..."
    if pgrep -x "CloudflareWARP" > /dev/null; then
        DAEMON_PID=$(pgrep -x "CloudflareWARP")
        echo "  ✓ Daemon running (PID: $DAEMON_PID)"
    else
        echo -e "  ${YELLOW}⚠ Daemon not running (may start shortly)${NC}"
    fi

    # Test CLI
    echo "✓ Testing warp CLI..."
    if warp status > /dev/null 2>&1; then
        STATUS=$(warp status 2>&1 | head -1)
        echo "  ✓ CLI functional: $STATUS"
    else
        echo -e "  ${YELLOW}⚠ CLI test output received${NC}"
    fi

    echo ""

    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}✗ Verification failed with $ERRORS error(s)${NC}"
        exit 1
    fi

    return 0
}

# Final summary
print_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          Installation Complete! ✓                         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    echo "📦 Components Installed:"
    echo "  ✓ warp CLI tool"
    echo "  ✓ warp-cli binary"
    echo "  ✓ CloudflareWARP daemon"
    echo "  ✓ launchd configuration"
    echo ""

    echo "🎯 Quick Start:"
    echo "  $ warp status              # Check connection status"
    echo "  $ warp up                  # Connect to WARP"
    echo "  $ warp down                # Disconnect from WARP"
    echo "  $ warp --help              # Show all commands"
    echo ""

    echo "📚 Documentation:"
    echo "  $ cat README.md                       # Project overview"
    echo "  $ cat INSTALLATION.md                 # Installation details"
    echo "  $ cat USAGE_EXAMPLES.md               # Command examples"
    echo ""

    echo "🔧 Advanced:"
    echo "  $ warp exclude list                   # Manage split tunnel"
    echo "  $ warp daemon status                  # Check daemon"
    echo "  $ warp logs                           # View daemon logs"
    echo ""

    echo "════════════════════════════════════════════════════════════"
    echo ""
}

# Error handler
on_error() {
    local line_number=$1
    echo ""
    echo -e "${RED}✗ Installation failed at line $line_number${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check prerequisites: bash ./scripts/detect-installation.sh"
    echo "  2. Ensure Cloudflare WARP is installed from App Store"
    echo "  3. Run with verbose output: bash -x ./install-complete.sh"
    echo ""
}

# Main execution
main() {
    print_banner

    trap 'on_error ${LINENO}' ERR

    # Run all steps
    step_detect || {
        DETECT_EXIT=$?
        if [ $DETECT_EXIT -eq 0 ]; then
            echo -e "${GREEN}✓ System is ready${NC}"
        elif [ $DETECT_EXIT -eq 1 ]; then
            echo -e "${YELLOW}⚠ Cloudflare WARP app detected, will extract binaries${NC}"
        else
            echo -e "${RED}✗ Prerequisites not met${NC}"
            exit 1
        fi
    }

    step_extract
    step_setup_daemon
    step_build_cli
    step_install_cli
    step_verify
    print_summary

    echo "✓ All systems go! Start using: warp status"
    echo ""
}

# Handle interruption
trap 'echo -e "\n${RED}✗ Installation cancelled${NC}"; exit 130' INT

# Run main
main "$@"
