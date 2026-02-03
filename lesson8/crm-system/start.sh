#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"
BACKEND_PORT=5000
FRONTEND_PORT=8000
echo "Starting CRM (Day 8)..."
if lsof -i :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Backend already running on port $BACKEND_PORT. Stop first: $SCRIPT_DIR/stop.sh"
    exit 1
fi
if lsof -i :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Frontend already running on port $FRONTEND_PORT. Stop first: $SCRIPT_DIR/stop.sh"
    exit 1
fi
echo "Starting backend (http://localhost:$BACKEND_PORT)..."
(cd "$BACKEND_DIR" && nohup ./venv/bin/gunicorn --bind "0.0.0.0:$BACKEND_PORT" "src.app:app" > backend.log 2>&1 & echo $! > backend.pid)
sleep 2
echo "Starting frontend (http://localhost:$FRONTEND_PORT)..."
(nohup python3 -m http.server $FRONTEND_PORT --directory "$FRONTEND_DIR" > "$FRONTEND_DIR/frontend.log" 2>&1 & echo $! > "$FRONTEND_DIR/frontend.pid")
echo "Dashboard: http://localhost:$FRONTEND_PORT/dashboard.html"
echo "To stop: $SCRIPT_DIR/stop.sh"
