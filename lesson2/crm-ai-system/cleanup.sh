#!/bin/bash

# CRM AI System Cleanup Script
# Stops containers and removes unused Docker resources

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "🧹 CRM AI System Cleanup"
echo "========================"

# --- 1. Stop running services ---
echo ""
echo "📍 Stopping services..."
if [ -f "stop.sh" ]; then
    ./stop.sh 2>/dev/null || true
fi

# Kill any remaining node processes
pkill -f "node.*crm-ai-system" 2>/dev/null || true
pkill -f "react-scripts" 2>/dev/null || true
echo "✅ Services stopped"

# --- 2. Stop Docker containers for this project ---
echo ""
echo "🐳 Stopping Docker containers..."
if command -v docker &> /dev/null; then
    # Stop containers from docker-compose
    if [ -f "docker-compose.yml" ]; then
        docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
    fi
    
    # Stop any containers with crm-ai-system in name
    docker ps -a --filter "name=crm" -q | xargs -r docker stop 2>/dev/null || true
    echo "✅ Docker containers stopped"
else
    echo "⚠️  Docker not available, skipping..."
fi

# --- 3. Remove Docker resources ---
echo ""
echo "🗑️  Removing unused Docker resources..."
if command -v docker &> /dev/null; then
    # Remove stopped containers
    echo "  - Removing stopped containers..."
    docker container prune -f 2>/dev/null || true
    
    # Remove unused images
    echo "  - Removing unused images..."
    docker image prune -f 2>/dev/null || true
    
    # Remove unused volumes
    echo "  - Removing unused volumes..."
    docker volume prune -f 2>/dev/null || true
    
    # Remove unused networks
    echo "  - Removing unused networks..."
    docker network prune -f 2>/dev/null || true
    
    # Remove build cache
    echo "  - Removing build cache..."
    docker builder prune -f 2>/dev/null || true
    
    echo "✅ Docker resources cleaned"
else
    echo "⚠️  Docker not available, skipping..."
fi

# --- 4. Remove node_modules ---
echo ""
echo "📦 Removing node_modules..."
rm -rf "${SCRIPT_DIR}/frontend/node_modules" 2>/dev/null || true
rm -rf "${SCRIPT_DIR}/backend/node_modules" 2>/dev/null || true
echo "✅ node_modules removed"

# --- 5. Remove Python cache files ---
echo ""
echo "🐍 Removing Python cache files..."
find "${SCRIPT_DIR}" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "${SCRIPT_DIR}" -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find "${SCRIPT_DIR}" -type d -name "venv" -exec rm -rf {} + 2>/dev/null || true
find "${SCRIPT_DIR}" -type d -name ".venv" -exec rm -rf {} + 2>/dev/null || true
find "${SCRIPT_DIR}" -type f -name "*.pyc" -delete 2>/dev/null || true
find "${SCRIPT_DIR}" -type f -name "*.pyo" -delete 2>/dev/null || true
echo "✅ Python cache files removed"

# --- 6. Remove log files ---
echo ""
echo "📄 Removing log files..."
rm -f "${SCRIPT_DIR}/backend/backend.log" 2>/dev/null || true
rm -f "${SCRIPT_DIR}/frontend/frontend.log" 2>/dev/null || true
rm -f "${SCRIPT_DIR}/backend/backend.pid" 2>/dev/null || true
rm -f "${SCRIPT_DIR}/frontend/frontend.pid" 2>/dev/null || true
echo "✅ Log files removed"

# --- 7. Remove package-lock files (optional, uncomment if needed) ---
# echo ""
# echo "🔒 Removing lock files..."
# rm -f "${SCRIPT_DIR}/frontend/package-lock.json" 2>/dev/null || true
# rm -f "${SCRIPT_DIR}/backend/package-lock.json" 2>/dev/null || true
# echo "✅ Lock files removed"

echo ""
echo "========================================"
echo "🎉 Cleanup complete!"
echo "========================================"
echo ""
echo "To reinstall dependencies:"
echo "  cd backend && npm install"
echo "  cd frontend && npm install"
