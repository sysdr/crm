#!/bin/bash
# Start server from project directory (full path); avoid duplicate services
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$APP_DIR"
if pgrep -f "node.*app\.js" >/dev/null 2>&1; then
  echo "Server already running (skip duplicate). Use stop.sh first to restart."
  exit 0
fi
echo "Starting CRM server from $APP_DIR..."
node src/app.js
