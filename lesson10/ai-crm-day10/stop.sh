#!/bin/bash
# Stop any running node server and Docker container (no duplicate services)
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
pkill -f "node.*${APP_DIR}.*app\.js" 2>/dev/null || true
pkill -f "node src/app\.js" 2>/dev/null || true
docker stop ai-crm-day10-container 2>/dev/null || true
docker rm ai-crm-day10-container 2>/dev/null || true
echo "Stopped CRM services."
