#!/bin/bash
# Stop CRM and Docker containers; remove unused Docker resources (images, volumes, containers).
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Stopping CRM Node process..."
pkill -f "node.*${SCRIPT_DIR}.*app\.js" 2>/dev/null || true
pkill -f "node src/app\.js" 2>/dev/null || true

echo "Stopping Docker containers..."
docker stop ai-crm-day10-container 2>/dev/null || true
docker rm ai-crm-day10-container 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

echo "Removing unused Docker resources..."
docker system prune -af --volumes 2>/dev/null || true

echo "Cleanup finished."
