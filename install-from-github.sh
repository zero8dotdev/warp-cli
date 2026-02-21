#!/bin/bash

# Install Cloudflare WARP CLI directly from GitHub
# Usage: curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    cat << 'EOF'

╔════════════════════════════════════════════════════════════╗
║         Cloudflare WARP CLI - GitHub Installer            ║
║                Install in 2-3 minutes                      ║
╚════════════════════════════════════════════════════════════╝

EOF
}

print_step() {
    local step=$1
    local description=$2
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}Step $step:${NC} $description"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Ask for sudo password upfront
request_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "This installation requires elevated privileges (sudo)."
        sudo -v || {
            echo -e "${RED}✗ Sudo access denied${NC}"
            exit 1
        }
    fi
}

# Check prerequisites
check_prerequisites() {
    print_step "1" "Checking Prerequisites"

    # Check for Cloudflare WARP app
    if [ ! -d "/Applications/Cloudflare WARP.app" ]; then
        echo -e "${YELLOW}⚠ Cloudflare WARP app not found${NC}"
        echo ""
        echo "You need to install Cloudflare WARP first:"
        echo "  https://apps.apple.com/app/cloudflare-warp/id1423210915"
        echo ""
        echo "Would you like to open the App Store now? (y/n)"

        if [ -t 0 ]; then
            read -p "  " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Opening App Store..."
                open "macappstore://apps.apple.com/app/cloudflare-warp/id1423210915"
                echo ""
                echo "After installing Cloudflare WARP, run this command again:"
                echo "  curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash"
                exit 0
            fi
        fi

        echo "Please install Cloudflare WARP from:"
        echo "  https://apps.apple.com/app/cloudflare-warp/id1423210915"
        echo ""
        echo "Then run this command again:"
        echo "  curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash"
        exit 0
    fi
    echo "✓ Cloudflare WARP app found"

    # Check for Rust/Cargo
    if ! command -v cargo &> /dev/null; then
        echo -e "${YELLOW}⚠ Rust/Cargo not found${NC}"
        echo ""
        echo "Installing Rust (required for building)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
        source $HOME/.cargo/env
        echo "✓ Rust installed"
    else
        RUST_VERSION=$(rustc --version)
        echo "✓ $RUST_VERSION"
    fi

    # Check for git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}✗ git not found${NC}"
        echo "Please install git: brew install git"
        exit 1
    fi
    echo "✓ git found"

    echo ""
}

# Clone and prepare
clone_repo() {
    print_step "2" "Downloading from GitHub"

    TEMP_DIR=$(mktemp -d)
    echo "✓ Using temporary directory: $TEMP_DIR"

    cd "$TEMP_DIR"

    echo "✓ Cloning repository..."
    git clone https://github.com/zero8dotdev/warp-cli.git 2>&1 | grep -E "(Cloning|Resolving)" || true

    cd warp-cli
    echo "✓ Repository ready"
    echo ""
}

# Build
build() {
    print_step "3" "Building from Source"

    echo "✓ Checking Cargo..."
    RUST_VERSION=$(rustc --version)
    echo "  $RUST_VERSION"

    echo ""
    echo "✓ Building in release mode..."
    echo "  (This may take 1-2 minutes on first build...)"

    cargo build --release 2>&1 | tail -5

    if [ ! -x "target/release/warp" ]; then
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi

    BINARY_SIZE=$(du -h target/release/warp | cut -f1)
    echo "✓ Build successful ($BINARY_SIZE binary)"
    echo ""
}

# Extract binaries
extract_binaries() {
    print_step "4" "Setting Up Daemon"

    echo "✓ Extracting warp-cli from WARP app..."
    bash scripts/extract-warp.sh

    echo "✓ Configuring daemon..."
    bash scripts/setup-daemon.sh

    echo ""
}

# Install
install_binary() {
    print_step "5" "Installing warp CLI"

    INSTALL_PATH="/usr/local/bin"

    echo "✓ Installing to $INSTALL_PATH..."

    if [ ! -w "$INSTALL_PATH" ]; then
        sudo install -m 755 target/release/warp "$INSTALL_PATH/warp"
    else
        install -m 755 target/release/warp "$INSTALL_PATH/warp"
    fi

    echo "✓ Installed to /usr/local/bin/warp"
    echo ""
}

# Verify
verify_installation() {
    print_step "6" "Verifying Installation"

    if ! command -v warp &> /dev/null; then
        echo -e "${RED}✗ warp command not found in PATH${NC}"
        exit 1
    fi

    echo "✓ warp command found"

    if warp --version > /dev/null 2>&1; then
        WARP_VERSION=$(warp --version)
        echo "✓ Version: $WARP_VERSION"
    fi

    if warp status > /dev/null 2>&1; then
        echo "✓ CLI is functional"
    fi

    echo ""
}

# Cleanup
cleanup() {
    print_step "7" "Cleaning Up"

    echo "✓ Removing temporary files..."
    cd /
    rm -rf "$TEMP_DIR"
    echo "✓ Cleanup complete"
    echo ""
}

# Summary
print_summary() {
    cat << 'EOF'

╔════════════════════════════════════════════════════════════╗
║          Installation Complete! ✓                         ║
╚════════════════════════════════════════════════════════════╝

📦 Installed:
  ✓ warp CLI tool
  ✓ warp-cli binary
  ✓ CloudflareWARP daemon
  ✓ launchd configuration

🎯 Quick Start:
  $ warp status              # Check connection status
  $ warp up                  # Connect to WARP
  $ warp down                # Disconnect from WARP
  $ warp --help              # Show all commands

📚 Documentation:
  https://github.com/zero8dotdev/warp-cli

════════════════════════════════════════════════════════════

EOF
    echo "✓ All systems go! Start using: warp status"
    echo ""
}

# Error handler
on_error() {
    local line_number=$1
    echo ""
    echo -e "${RED}✗ Installation failed at line $line_number${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Ensure Cloudflare WARP is installed from App Store"
    echo "  2. Check your internet connection"
    echo "  3. Try again: curl -fsSL https://raw.githubusercontent.com/zero8dotdev/warp-cli/main/install-from-github.sh | bash"
    echo ""
    cleanup
}

# Main
main() {
    print_banner

    trap 'on_error ${LINENO}' ERR

    # Request sudo upfront so password is cached
    request_sudo

    check_prerequisites
    clone_repo
    build
    extract_binaries
    install_binary
    verify_installation
    cleanup
    print_summary
}

# Handle interruption
trap 'echo -e "\n${RED}✗ Installation cancelled${NC}\n"; exit 130' INT

# Run
main "$@"
