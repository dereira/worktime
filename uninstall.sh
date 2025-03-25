#!/usr/bin/env bash

set -e

INSTALL_DIR="$HOME/.worktime"
BIN_DIR="$HOME/bin"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

read -p "Are you sure you want to uninstall worktime tracker, this will remove the current data? [y/N] " -n 1 -r

echo "Uninstalling worktime tracker..."

rm -rf "$INSTALL_DIR"
rm -f "$BIN_DIR/worktime"
rm -f "$BIN_DIR/screen-lock-monitor"
rm -f "$LAUNCH_AGENTS_DIR/dev.danielpereira.events.plist"
launchctl unload "$LAUNCH_AGENTS_DIR/dev.danielpereira.events.plist"

echo "Worktime tracker uninstalled successfully!"
