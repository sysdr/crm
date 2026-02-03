#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"
BACKEND_DIR="${PROJECT_ROOT}/backend"
FRONTEND_DIR="${PROJECT_ROOT}/frontend"
BACKEND_PORT=3000
FRONTEND_PORT=8000

echo "Starting CRM (Lesson 7)..."
if lsof -i :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Backend already running on port $BACKEND_PORT. Stop first: ${PROJECT_ROOT}/stop.sh"
    exit 1
fi
if lsof -i :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Frontend already running on port $FRONTEND_PORT. Stop first: ${PROJECT_ROOT}/stop.sh"
    exit 1
fi

echo "Starting backend (http://localhost:$BACKEND_PORT)..."
(cd "$BACKEND_DIR" && nohup node server.js > backend.log 2>&1 & echo $! > backend.pid)
sleep 2
echo "Starting frontend (http://localhost:$FRONTEND_PORT)..."
(cd / && nohup python3 -m http.server $FRONTEND_PORT --directory "$FRONTEND_DIR" > "$FRONTEND_DIR/frontend.log" 2>&1 & echo $! > "$FRONTEND_DIR/frontend.pid")
echo "Dashboard: http://localhost:$FRONTEND_PORT/dashboard.html"
echo "Contacts:  http://localhost:$FRONTEND_PORT/index.html"
echo "To stop: ${PROJECT_ROOT}/stop.sh"
