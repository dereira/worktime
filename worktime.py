#!/usr/bin/env python3
"""
WorkTime - A simple terminal app to track working hours on macOS.

Usage:
  worktime start     # Start tracking (usually run at login)
  worktime stop      # Stop tracking (run at logout or manually)
  worktime status    # Show today's work duration
  worktime report    # Show a report of recent work days
"""

import datetime
import json
import logging
import sys
import time
from pathlib import Path

# Configuration
DATA_DIR = Path.home() / ".worktime"
LOG_FILE = DATA_DIR / "timelogs.json"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger("worktime")


def ensure_data_dir():
    """Create data directory if it doesn't exist"""
    if not DATA_DIR.exists():
        DATA_DIR.mkdir(parents=True)

    if not LOG_FILE.exists():
        with open(LOG_FILE, "w") as f:
            json.dump({}, f)


def load_logs():
    """Load time logs from file"""
    ensure_data_dir()
    try:
        with open(LOG_FILE, "r") as f:
            return json.load(f)
    except json.JSONDecodeError:
        return {}


def save_logs(logs):
    """Save time logs to file"""
    with open(LOG_FILE, "w") as f:
        json.dump(logs, f, indent=2)


def get_today_date():
    """Get today's date in YYYY-MM-DD format"""
    return datetime.datetime.now().strftime("%Y-%m-%d")


def format_duration(seconds):
    """Format duration in seconds to hours and minutes"""
    hours, remainder = divmod(seconds, 3600)
    minutes, _ = divmod(remainder, 60)
    return f"{int(hours)}h {int(minutes)}m"


def start_tracking():
    """Start tracking work time"""
    logs = load_logs()
    today = get_today_date()

    if today not in logs:
        logs[today] = []

    if logs[today] and "end" not in logs[today][-1]:
        logger.warning("You already have an active work session")
        return

    logs[today].append({"start": time.time()})
    save_logs(logs)
    logger.info(f"Started tracking at {datetime.datetime.now().strftime('%H:%M:%S')}")


def stop_tracking():
    """Stop tracking work time"""
    logs = load_logs()
    today = get_today_date()

    if today not in logs or not logs[today]:
        logger.warning("No active work session found, starting a new one")
        return

    if "end" in logs[today][-1]:
        logger.warning("No active work session found")
        return

    logs[today][-1]["end"] = time.time()
    duration = logs[today][-1]["end"] - logs[today][-1]["start"]
    save_logs(logs)

    logger.info(f"Stopped tracking. Session duration: {format_duration(duration)}")


def show_status():
    """Show today's work duration"""
    logs = load_logs()
    today = get_today_date()

    if today not in logs or not logs[today]:
        logger.warning("No work tracked today")
        return

    total_seconds = 0
    active_session = False

    for session in logs[today]:
        if "end" in session:
            total_seconds += session["end"] - session["start"]
        else:
            active_session = True
            total_seconds += time.time() - session["start"]

    status_prefix = "Currently working" if active_session else "Worked"
    logger.info(f"{status_prefix} today: {format_duration(total_seconds)}")


def show_report(days=7):
    """Show a report of recent work days"""
    logs = load_logs()

    dates = sorted(logs.keys(), reverse=True)

    if not dates:
        print("No work logs found")
        return

    print(f"\nWork time report (last {min(days, len(dates))} days):\n")
    print(f"{'Date':<12} {'Duration':<10} {'Sessions':<8}")
    print("-" * 30)

    for date in dates[:days]:
        total_seconds = 0
        sessions = 0

        for session in logs[date]:
            sessions += 1
            if "end" in session:
                total_seconds += session["end"] - session["start"]
            else:
                total_seconds += time.time() - session["start"]

        print(f"{date:<12} {format_duration(total_seconds):<10} {sessions:<8}")

    print("\n")


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print(__doc__)
        return

    command = sys.argv[1].lower()

    if command == "start":
        start_tracking()
    elif command == "stop":
        stop_tracking()
    elif command == "status":
        show_status()
    elif command == "report":
        show_report()
    else:
        print("Unknown command. Available commands: start, stop, status, report")
        print(__doc__)


if __name__ == "__main__":
    main()
