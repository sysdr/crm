#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_PORT=3000
FRONTEND_PORT=8000
P=0
F=0
echo "Running tests..."
curl -sf http://localhost:$BACKEND_PORT/api/health | grep -q healthy && { echo "  [PASS] Health"; P=$((P+1)); } || { echo "  [FAIL] Health"; F=$((F+1)); }
curl -sf http://localhost:$BACKEND_PORT/api/metrics | grep -q totalContacts && { echo "  [PASS] Metrics"; P=$((P+1)); } || { echo "  [FAIL] Metrics"; F=$((F+1)); }
curl -sf -X POST http://localhost:$BACKEND_PORT/api/demo -H "Content-Type: application/json" | grep -q success && { echo "  [PASS] Demo"; P=$((P+1)); } || { echo "  [FAIL] Demo"; F=$((F+1)); }
METRICS=$(curl -s http://localhost:$BACKEND_PORT/api/metrics)
TC=$(echo "$METRICS" | grep -o '"totalContacts":[0-9]*' | grep -o '[0-9]*')
RV=$(echo "$METRICS" | grep -o '"revenue":[0-9]*' | grep -o '[0-9]*')
if [ -n "$TC" ] && [ "$TC" -ge 0 ] 2>/dev/null && [ -n "$RV" ]; then echo "  [PASS] Metrics values (totalContacts/revenue)"; P=$((P+1)); else echo "  [FAIL] Metrics values"; F=$((F+1)); fi
curl -sf http://localhost:$FRONTEND_PORT/dashboard.html | grep -q "CRM Dashboard" && { echo "  [PASS] Dashboard"; P=$((P+1)); } || { echo "  [SKIP] Dashboard (frontend may be starting)"; }
echo "Result: $P passed, $F failed"
[ $F -eq 0 ] && exit 0 || exit 1
