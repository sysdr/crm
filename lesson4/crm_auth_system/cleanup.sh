#!/bin/bash
# CRM Auth System Cleanup Script
# This script stops all services and removes unused Docker resources

set -e

echo "🧹 Starting CRM Auth System Cleanup..."

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --- Stop Node.js Process ---
echo -e "\n📍 Stopping Node.js process..."
if [ -f .node_pid ]; then
    NODE_PID=$(cat .node_pid)
    if kill -0 $NODE_PID 2>/dev/null; then
        echo "Stopping Node.js process (PID: $NODE_PID)..."
        kill $NODE_PID 2>/dev/null || true
        sleep 2
        # Force kill if still running
        if kill -0 $NODE_PID 2>/dev/null; then
            kill -9 $NODE_PID 2>/dev/null || true
        fi
        echo "✅ Node.js process stopped."
    else
        echo "Node.js process not running."
    fi
    rm -f .node_pid
else
    echo "No Node.js PID file found."
    # Try to find and kill any node processes running app.js
    pkill -f "node src/app.js" 2>/dev/null || true
fi

# --- Stop Docker Containers ---
echo -e "\n📍 Stopping Docker containers..."
if command -v docker-compose &> /dev/null; then
    if [ -f docker-compose.yml ]; then
        docker-compose down -v 2>/dev/null || true
        echo "✅ Docker containers stopped and volumes removed."
    else
        echo "No docker-compose.yml found."
    fi
else
    echo "docker-compose not installed."
fi

# --- Remove Unused Docker Resources ---
echo -e "\n📍 Cleaning up Docker resources..."
if command -v docker &> /dev/null; then
    # Remove stopped containers
    echo "Removing stopped containers..."
    docker container prune -f 2>/dev/null || true
    
    # Remove unused networks
    echo "Removing unused networks..."
    docker network prune -f 2>/dev/null || true
    
    # Remove unused volumes
    echo "Removing unused volumes..."
    docker volume prune -f 2>/dev/null || true
    
    # Remove dangling images
    echo "Removing dangling images..."
    docker image prune -f 2>/dev/null || true
    
    # Optionally remove all unused images (uncomment if needed)
    # echo "Removing all unused images..."
    # docker image prune -a -f 2>/dev/null || true
    
    echo "✅ Docker cleanup complete."
else
    echo "Docker not installed."
fi

# --- Remove Cache and Temporary Files ---
echo -e "\n📍 Removing cache and temporary files..."

# Remove node_modules
if [ -d "node_modules" ]; then
    echo "Removing node_modules..."
    rm -rf node_modules
    echo "✅ node_modules removed."
fi

# Remove Python cache files
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "venv" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".venv" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true

# Remove Istio files
find . -type f -name "istio*.yaml" -delete 2>/dev/null || true
find . -type f -name "istio*.yml" -delete 2>/dev/null || true

# Remove package-lock.json (optional - uncomment if needed)
# rm -f package-lock.json

echo "✅ Cache and temporary files removed."

# --- Summary ---
echo -e "\n========================================="
echo "🎉 Cleanup Complete!"
echo "========================================="
echo ""
echo "Removed:"
echo " - Node.js processes"
echo " - Docker containers and volumes"
echo " - Unused Docker resources"
echo " - node_modules directory"
echo " - Python cache files"
echo " - Istio configuration files"
echo ""
echo "To reinstall dependencies, run:"
echo "  npm install"
echo ""
echo "To restart the system, run:"
echo "  bash startup.sh"
