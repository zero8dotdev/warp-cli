#!/bin/bash
# Install warp CLI to /usr/local/bin

set -e

BINARY_PATH="$(cd "$(dirname "$0")" && pwd)/target/release/warp"
INSTALL_PATH="/usr/local/bin/warp"

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    echo "Run 'cargo build --release' first"
    exit 1
fi

echo "Installing warp CLI..."
sudo install -m 755 "$BINARY_PATH" "$INSTALL_PATH"
echo "✓ Installed to $INSTALL_PATH"
echo ""
echo "Verify installation:"
warp --version
