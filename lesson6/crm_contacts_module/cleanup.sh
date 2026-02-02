#!/bin/bash

# CRM Contacts Module - Cleanup Script
# This script stops all services and removes unused Docker resources

set -e

echo "========================================"
echo "  CRM Contacts Module - Cleanup Script"
echo "========================================"
echo ""

# --- Stop Application Services ---
echo "1. Stopping application services..."
pkill -f "uvicorn app.main" 2>/dev/null && echo "   Stopped uvicorn" || echo "   No uvicorn process running"
pkill -f "uvicorn" 2>/dev/null || true

# --- Stop Docker Containers ---
echo ""
echo "2. Stopping Docker containers..."
docker stop crm_postgres 2>/dev/null && echo "   Stopped crm_postgres" || echo "   crm_postgres not running"

# --- Remove Docker Containers ---
echo ""
echo "3. Removing Docker containers..."
docker rm crm_postgres 2>/dev/null && echo "   Removed crm_postgres" || echo "   crm_postgres already removed"

# --- Remove Unused Docker Resources ---
echo ""
echo "4. Cleaning up Docker resources..."

echo "   Removing unused containers..."
docker container prune -f 2>/dev/null || true

echo "   Removing unused images..."
docker image prune -f 2>/dev/null || true

echo "   Removing unused volumes..."
docker volume prune -f 2>/dev/null || true

echo "   Removing unused networks..."
docker network prune -f 2>/dev/null || true

# --- Remove Python Cache Files ---
echo ""
echo "5. Removing Python cache files..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true
echo "   Cache files removed"

# --- Remove Virtual Environment (Optional) ---
echo ""
read -p "6. Remove virtual environment (venv)? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf venv 2>/dev/null && echo "   Removed venv" || echo "   No venv found"
else
    echo "   Skipped venv removal"
fi

# --- Summary ---
echo ""
echo "========================================"
echo "  Cleanup Complete!"
echo "========================================"
echo ""
echo "Remaining Docker resources:"
docker ps -a 2>/dev/null | grep -E "(crm|postgres)" || echo "  No CRM-related containers"
echo ""
echo "To completely remove the postgres image, run:"
echo "  docker rmi postgres:13"
echo ""
