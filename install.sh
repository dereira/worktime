#!/bin/bash

set -e

INSTALL_DIR="$HOME/.worktime"
BIN_DIR="$HOME/bin"
CURRENT_DIR="$(dirname "$0")"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

mkdir -p "$INSTALL_DIR"
mkdir -p "$LAUNCH_AGENTS_DIR"

echo "Installing worktime tracker..."
cp "$CURRENT_DIR/worktime.py" "$INSTALL_DIR/worktime.py"
chmod +x "$INSTALL_DIR/worktime.py"
ln -sf "$INSTALL_DIR/worktime.py" "$BIN_DIR/worktime"
echo "Symlink created in $BIN_DIR"

echo "Installing screen lock monitor..."
cp "$CURRENT_DIR/screen-lock-monitor.swift" "$INSTALL_DIR/screen-lock-monitor.swift"
chmod +x "$INSTALL_DIR/screen-lock-monitor.swift"
ln -sf "$INSTALL_DIR/screen-lock-monitor.swift" "$BIN_DIR/screen-lock-monitor"
echo "Symlink created in $BIN_DIR"

echo "Setting up login/logout agent..."
cp "$CURRENT_DIR/dev.danielpereira.events.plist" "$LAUNCH_AGENTS_DIR/"
chmod 644 "$LAUNCH_AGENTS_DIR/dev.danielpereira.events.plist"
launchctl load "$LAUNCH_AGENTS_DIR/dev.danielpereira.events.plist"

echo "Worktime tracker installed successfully!"
echo ""
echo "You can now use 'worktime' commands:"
echo "  worktime start   - Start tracking time"
echo "  worktime stop    - Stop tracking time"
echo "  worktime status  - Show today's work duration"
echo "  worktime report  - Show a work time report"
echo ""
echo "Automatic tracking on login and logout has been set up."
