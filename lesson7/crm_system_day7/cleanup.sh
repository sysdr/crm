#!/bin/bash
# Cleanup script: stop containers and remove unused Docker resources, volumes, containers, images.
# Also removes node_modules, venv, .pytest_cache, .pyc, and Istio-related files from this project.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"
BACKEND_DIR="${PROJECT_ROOT}/backend"
FRONTEND_DIR="${PROJECT_ROOT}/frontend"

echo "=== Cleanup: Stopping services and removing artifacts ==="

# 1. Stop CRM services (backend, frontend)
echo "Stopping CRM services..."
[ -f "$BACKEND_DIR/backend.pid" ] && kill $(cat "$BACKEND_DIR/backend.pid") 2>/dev/null || true
[ -f "$FRONTEND_DIR/frontend.pid" ] && kill $(cat "$FRONTEND_DIR/frontend.pid") 2>/dev/null || true
rm -f "$BACKEND_DIR/backend.pid" "$FRONTEND_DIR/frontend.pid"
pkill -f "node.*crm_system_day7/backend/server.js" 2>/dev/null || true
echo "  CRM services stopped."

# 2. Stop Docker containers and remove unused Docker resources (if Docker is available)
if command -v docker &>/dev/null; then
    echo "Stopping Docker containers..."
    docker stop $(docker ps -q) 2>/dev/null || true
    [ -f "$PROJECT_ROOT/docker-compose.yml" ] && docker compose -f "$PROJECT_ROOT/docker-compose.yml" down 2>/dev/null || true
    echo "Removing unused Docker resources (containers, images, volumes)..."
    docker system prune -af --volumes 2>/dev/null || true
    echo "  Docker cleanup done."
else
    echo "  Docker not in PATH; skipping Docker cleanup."
fi

# 3. Remove node_modules, venv, .pytest_cache, .pyc, Istio files from this project
echo "Removing project artifacts..."
[ -d "$BACKEND_DIR/node_modules" ] && rm -rf "$BACKEND_DIR/node_modules" && echo "  Removed backend/node_modules"
[ -d "$FRONTEND_DIR/node_modules" ] && rm -rf "$FRONTEND_DIR/node_modules" && echo "  Removed frontend/node_modules"
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 10 -type d -name "venv" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 10 -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.pyc" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 10 \( -path "*istio*" -o -name "*istio*" \) 2>/dev/null | while read -r f; do rm -rf "$f"; done
echo "  Artifact removal done."

echo "=== Cleanup complete ==="
