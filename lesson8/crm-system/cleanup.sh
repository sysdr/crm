#!/bin/bash
# Cleanup: stop CRM and Docker, then remove unused Docker resources and project artifacts.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"
BACKEND_DIR="${PROJECT_ROOT}/backend"
FRONTEND_DIR="${PROJECT_ROOT}/frontend"

echo "=== Cleanup: Stopping services and removing artifacts ==="

# 1. Stop CRM services (backend on 5000, frontend on 8000)
echo "Stopping CRM services..."
[ -f "$BACKEND_DIR/backend.pid" ] && kill $(cat "$BACKEND_DIR/backend.pid") 2>/dev/null || true
[ -f "$FRONTEND_DIR/frontend.pid" ] && kill $(cat "$FRONTEND_DIR/frontend.pid") 2>/dev/null || true
rm -f "$BACKEND_DIR/backend.pid" "$FRONTEND_DIR/frontend.pid"
pkill -f "gunicorn.*src.app:app" 2>/dev/null || true
pkill -f "http.server.*8000" 2>/dev/null || true
echo "  CRM services stopped."

# 2. Stop Docker containers and remove unused Docker resources (if Docker is available)
if command -v docker &>/dev/null; then
    echo "Stopping Docker containers..."
    docker stop $(docker ps -aq) 2>/dev/null || true
    echo "Removing unused Docker resources (containers, networks, images, volumes)..."
    docker system prune -af --volumes 2>/dev/null || true
    echo "  Docker cleanup done."
else
    echo "  Docker not in PATH; skipping Docker cleanup."
fi

# 3. Remove node_modules, venv, .pytest_cache, .pyc, __pycache__, Istio-related files
echo "Removing project artifacts..."
[ -d "$BACKEND_DIR/node_modules" ] && rm -rf "$BACKEND_DIR/node_modules" && echo "  Removed backend/node_modules"
[ -d "$FRONTEND_DIR/node_modules" ] && rm -rf "$FRONTEND_DIR/node_modules" && echo "  Removed frontend/node_modules"
[ -d "$BACKEND_DIR/venv" ] && rm -rf "$BACKEND_DIR/venv" && echo "  Removed backend/venv"
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 8 -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 8 -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 8 -type f -name "*.pyc" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 8 -type d -name "*istio*" -exec rm -rf {} + 2>/dev/null || true
echo "  Artifact removal done."

echo "=== Cleanup complete ==="
