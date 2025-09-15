#!/bin/bash

set -e

REPO="rmitchellscott/rm-battery-logger"
INSTALL_DIR="/home/root/rm-battery-logger"

echo "================================"
echo "rm-battery-logger installer"
echo "================================"
echo ""

# Check if we're on a reMarkable device
if [[ ! -d "/sys/class/power_supply" ]]; then
    echo "Error: This script should be run on a reMarkable device"
    exit 1
fi

# Get latest release version from GitHub
echo "Fetching latest release..."
LATEST_VERSION=$(wget -qO- "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$LATEST_VERSION" ]]; then
    echo "Error: Could not fetch latest release version"
    echo "Please check your internet connection"
    exit 1
fi

echo "Latest version: $LATEST_VERSION"

# Check if already installed
if [[ -d "$INSTALL_DIR" ]]; then
    echo ""
    echo "rm-battery-logger is already installed in $INSTALL_DIR"
    read -p "Do you want to overwrite the existing installation? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi

    # Stop the logger if it's running
    if [[ -f "$INSTALL_DIR/stop_logger.sh" ]]; then
        echo "Stopping existing logger..."
        "$INSTALL_DIR/stop_logger.sh" 2>/dev/null || true
    fi

    echo "Removing existing installation..."
    rm -rf "$INSTALL_DIR"
fi

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download the release
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_VERSION/rm-battery-logger.tar.gz"
echo "Downloading from $DOWNLOAD_URL..."

if ! wget -q "$DOWNLOAD_URL" -O rm-battery-logger.tar.gz; then
    echo "Error: Failed to download release"
    rm -rf "$INSTALL_DIR"
    exit 1
fi

# Extract the archive
echo "Extracting files..."
if ! tar -xzf rm-battery-logger.tar.gz; then
    echo "Error: Failed to extract files"
    rm -rf "$INSTALL_DIR"
    exit 1
fi

# Clean up archive
rm rm-battery-logger.tar.gz

# Make scripts executable
echo "Setting permissions..."
chmod +x *.sh

# Verify installation
if [[ ! -f "battery_logger.sh" ]] || [[ ! -f "start_logger.sh" ]] || [[ ! -f "stop_logger.sh" ]]; then
    echo "Error: Installation verification failed - missing files"
    rm -rf "$INSTALL_DIR"
    exit 1
fi

echo ""
echo "================================"
echo "Installation complete!"
echo "================================"
echo ""
echo "rm-battery-logger has been installed to: $INSTALL_DIR"
echo ""
echo "Usage:"
echo "  Start logging:  $INSTALL_DIR/start_logger.sh"
echo "  Stop logging:   $INSTALL_DIR/stop_logger.sh"
echo "  Check version:  $INSTALL_DIR/battery_logger.sh -v"
echo ""
echo "Log files will be saved to: $INSTALL_DIR/battery_log_YYYY-MM-DD.csv"
echo ""
echo "To start logging now, run:"
echo "  $INSTALL_DIR/start_logger.sh"