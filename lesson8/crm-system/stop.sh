#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"
BACKEND_PORT=5000
FRONTEND_PORT=8000
for port in $BACKEND_PORT $FRONTEND_PORT; do
    pid=$(lsof -i :$port -sTCP:LISTEN -t 2>/dev/null || true)
    if [ -n "$pid" ]; then kill $pid 2>/dev/null; echo "Stopped process on port $port (PID $pid)"; fi
done
[ -f "$BACKEND_DIR/backend.pid" ] && kill $(cat "$BACKEND_DIR/backend.pid") 2>/dev/null; rm -f "$BACKEND_DIR/backend.pid"
[ -f "$FRONTEND_DIR/frontend.pid" ] && kill $(cat "$FRONTEND_DIR/frontend.pid") 2>/dev/null; rm -f "$FRONTEND_DIR/frontend.pid"
echo "Stopped."
