#!/bin/bash
# Install script for SendIt CLI

set -e

echo "Installing SendIt CLI..."

# Check for Ruby
if ! command -v ruby &> /dev/null; then
    echo "Error: Ruby is not installed. Please install Ruby 2.7 or later."
    exit 1
fi

# Check for Bundler
if ! command -v bundle &> /dev/null; then
    echo "Error: Bundler is not installed. Install with: gem install bundler"
    exit 1
fi

# Install location
INSTALL_DIR="/usr/local"
BIN_DIR="$INSTALL_DIR/bin"
LIB_DIR="$INSTALL_DIR/lib/scli"

# Copy files
echo "Copying files..."
sudo mkdir -p "$LIB_DIR"
sudo cp -r lib/* "$LIB_DIR/"
sudo cp bin/scli "$BIN_DIR/scli"
sudo chmod +x "$BIN_DIR/scli"

# Update the executable to use installed library path
sudo sed -i "s|require_relative '../lib/scli'|require '/usr/local/lib/scli/scli'|" "$BIN_DIR/scli"

# Install gem dependencies
echo "Installing dependencies..."
sudo gem install --no-document tty-prompt tty-spinner tty-box oauth typhoeus nostr ruby-dbus

echo "Installation complete!"
echo "Run 'scli \"Your message\"' to get started."
