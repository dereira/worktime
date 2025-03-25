# WorkTime

A simple, lightweight macOS application to track your working hours automatically.

## Overview

WorkTime is a terminal-based time tracking tool for macOS that helps you monitor how much time you spend working on your computer. It automatically tracks your work sessions based on:

- System login/logout events
- Screen lock/unlock events
- System sleep/wake events

All data is stored locally on your machine in JSON format.

## Features

- 🚀 Automatically starts tracking when you log in or unlock your screen
- ⏹️ Automatically stops tracking when you log out, lock your screen, or put your computer to sleep
- 📊 Generates reports of your work time by day
- 💻 Simple command-line interface for checking status and reports
- 🔒 All data stored locally in your home directory

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/worktime.git
cd worktime

# Run the installer
chmod +x install.sh
./install.sh

# Optional: Set up sleep/wake tracking
brew install sleepwatcher
chmod +x install_sleepwatcher.sh
./install_sleepwatcher.sh
```

## Usage

WorkTime is designed to run automatically in the background, but you can also control it manually with these commands:

```bash
# Start tracking a work session
worktime start

# Stop the current work session
worktime stop

# Check your work duration for today
worktime status

# Generate a report of recent work days
worktime report
```

## How It Works

WorkTime consists of several components:

1. **Main Python Script (`worktime.py`)**: Handles time tracking logic and data storage
2. **Screen Lock Monitor (`screen-lock-monitor.swift`)**: Swift script that detects screen lock/unlock events
3. **LaunchAgent (`dev.danielpereira.events.plist`)**: Configures the screen lock monitor to run automatically
4. **Sleep/Wake Scripts**: Optional scripts that track when your computer sleeps and wakes

All work sessions are logged in `~/.worktime/timelogs.json`.

## File Structure

```
.
├── worktime.py             # Main tracking script
├── screen-lock-monitor.swift # Screen lock/unlock detection
├── dev.danielpereira.events.plist # Launch agent configuration
├── wake.sh                 # Script run when system wakes
├── sleep.sh                # Script run when system sleeps
└── install.sh              # Installation script
```

## Customization

You can modify the behavior by editing the configuration in `worktime.py` or changing the event triggers in the LaunchAgent plist file.

## Requirements

- macOS 10.13 or later
- Python 3.6 or later
- Swift 5.0 or later
- Optional: sleepwatcher (if using sleep/wake tracking)

## License

This project is licensed under the terms of the LICENSE file included in the repository.

---

## Technical Details

- WorkTime uses JSON for data storage, located in `~/.worktime/timelogs.json`
- Screen lock detection uses macOS Distributed Notification Center
- The screen lock monitor is written in Swift for native macOS integration
- The core time tracking functionality is written in Python for ease of maintenance