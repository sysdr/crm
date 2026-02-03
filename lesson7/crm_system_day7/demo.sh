#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_PORT=3000
FRONTEND_PORT=8000
echo "Running demo (update metrics)..."
for i in 1 2 3 4 5; do curl -s -X POST http://localhost:$BACKEND_PORT/api/demo -H "Content-Type: application/json" >/dev/null; sleep 0.5; done
echo "Metrics:"
curl -s http://localhost:$BACKEND_PORT/api/metrics | python3 -m json.tool 2>/dev/null || curl -s http://localhost:$BACKEND_PORT/api/metrics
echo "Dashboard: http://localhost:$FRONTEND_PORT/dashboard.html"
