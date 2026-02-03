#!/bin/bash
# Cleanup: stop CRM containers, then remove unused Docker resources (containers, volumes, images).
# Also removes node_modules, venv, .pytest_cache, .pyc, __pycache__, and Istio-related dirs from project.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"

echo "=== Cleanup: Stopping services and removing Docker resources ==="

# 1. Stop CRM containers (docker compose and any leftover containers by name)
echo "Stopping CRM containers..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" down 2>/dev/null || true
docker rm -f crm-postgres crm-backend-app 2>/dev/null || true
[ -f "$PROJECT_ROOT/backend_pid.txt" ] && kill $(cat "$PROJECT_ROOT/backend_pid.txt") 2>/dev/null || true
rm -f "$PROJECT_ROOT/backend_pid.txt"
echo "  Containers stopped."

# 2. Remove unused Docker resources (containers, networks, images, volumes)
if command -v docker &>/dev/null && docker info &>/dev/null; then
    echo "Removing unused Docker resources (containers, networks, images, volumes)..."
    docker system prune -af --volumes 2>/dev/null || true
    echo "  Docker cleanup done."
else
    echo "  Docker not available; skipping Docker prune."
fi

# 3. Remove node_modules, venv, .pytest_cache, .pyc, __pycache__, Istio-related files from project
echo "Removing project artifacts..."
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 6 -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 6 -type d -name "venv" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 6 -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 6 -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 6 -type f -name "*.pyc" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 6 -type d -iname "*istio*" -exec rm -rf {} + 2>/dev/null || true
echo "  Artifact removal done."

echo "=== Cleanup complete ==="
