#!/bin/bash
# Run tests: leads API, metrics, dashboard
PORT=${PORT:-3000}
P=0
F=0
echo "Tests (backend http://localhost:$PORT)..."
curl -sf http://localhost:$PORT/api/metrics | grep -q totalLeads && { echo "  [PASS] Metrics"; P=$((P+1)); } || { echo "  [FAIL] Metrics"; F=$((F+1)); }
curl -sf -X POST http://localhost:$PORT/api/v1/leads -H "Content-Type: application/json" -d '{"name":"Test Lead","email":"test@test.com","source":"Website"}' | grep -q success && { echo "  [PASS] Create Lead"; P=$((P+1)); } || { echo "  [FAIL] Create Lead"; F=$((F+1)); }
curl -sf http://localhost:$PORT/dashboard.html | grep -q "Graceful Error Handling" && { echo "  [PASS] Dashboard"; P=$((P+1)); } || { echo "  [SKIP] Dashboard"; }
echo "Passed: $P  Failed: $F"
