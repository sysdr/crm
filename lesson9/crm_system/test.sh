#!/bin/bash
set -e
BACKEND_PORT="${BACKEND_PORT:-8080}"
P=0
F=0
echo "Testing CRM backend on port $BACKEND_PORT..."
curl -sf http://localhost:$BACKEND_PORT/api/metrics | grep -q totalContacts && { echo "  [PASS] Metrics"; P=$((P+1)); } || { echo "  [FAIL] Metrics"; F=$((F+1)); }
curl -sf -X POST http://localhost:$BACKEND_PORT/api/demo -H "Content-Type: application/json" | grep -q success && { echo "  [PASS] Demo"; P=$((P+1)); } || { echo "  [FAIL] Demo"; F=$((F+1)); }
curl -sf http://localhost:$BACKEND_PORT/contacts | grep -q "\[" && { echo "  [PASS] Contacts"; P=$((P+1)); } || { echo "  [FAIL] Contacts"; F=$((F+1)); }
echo "--- $P passed, $F failed ---"
[ $F -eq 0 ] || exit 1
