#!/bin/bash

echo "=== CRM Auth Service Cleanup Script ==="
echo ""

# Stop the Go application if running
echo "1. Stopping application processes..."
if [ -f .app_pid ]; then
    PID=$(cat .app_pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID 2>/dev/null
        echo "   Stopped process with PID: $PID"
    fi
    rm -f .app_pid
fi
pkill -f "crm-auth-service" 2>/dev/null && echo "   Stopped crm-auth-service processes" || echo "   No crm-auth-service processes running"

# Stop and remove Docker containers
echo ""
echo "2. Stopping Docker containers..."
docker stop crm-auth-service-container 2>/dev/null && echo "   Stopped crm-auth-service-container" || echo "   Container not running"
docker rm crm-auth-service-container 2>/dev/null && echo "   Removed crm-auth-service-container" || echo "   Container not found"

# Remove Docker image
echo ""
echo "3. Removing Docker images..."
docker rmi crm-auth-service-image 2>/dev/null && echo "   Removed crm-auth-service-image" || echo "   Image not found"

# Clean up unused Docker resources
echo ""
echo "4. Cleaning unused Docker resources..."
echo "   Removing dangling images..."
docker image prune -f 2>/dev/null

echo "   Removing unused volumes..."
docker volume prune -f 2>/dev/null

echo "   Removing unused networks..."
docker network prune -f 2>/dev/null

echo "   Removing build cache..."
docker builder prune -f 2>/dev/null

# Optional: Full system prune (uncomment if needed)
# echo ""
# echo "5. Full Docker system prune..."
# docker system prune -af --volumes 2>/dev/null

# Clean up local build artifacts
echo ""
echo "5. Cleaning local build artifacts..."
rm -f crm-auth-service 2>/dev/null && echo "   Removed compiled binary" || echo "   No binary found"
rm -f .app_pid 2>/dev/null

# Clean Go cache (optional)
# go clean -cache -modcache

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "Remaining Docker resources:"
docker system df 2>/dev/null || echo "Docker not available"
