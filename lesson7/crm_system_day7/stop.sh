#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"
BACKEND_DIR="${PROJECT_ROOT}/backend"
FRONTEND_DIR="${PROJECT_ROOT}/frontend"

echo "Stopping CRM (Lesson 7)..."
[ -f "$BACKEND_DIR/backend.pid" ] && kill $(cat "$BACKEND_DIR/backend.pid") 2>/dev/null || true
[ -f "$FRONTEND_DIR/frontend.pid" ] && kill $(cat "$FRONTEND_DIR/frontend.pid") 2>/dev/null || true
rm -f "$BACKEND_DIR/backend.pid" "$FRONTEND_DIR/frontend.pid"
pkill -f "node.*crm_system_day7/backend/server.js" 2>/dev/null || true
echo "Stopped."
