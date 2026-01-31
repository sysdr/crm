#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🎮 Running CRM Dashboard Demo..."
echo ""

# Run demo 5 times to populate data
for i in {1..5}; do
    echo "Demo run $i/5..."
    curl -s -X POST http://localhost:3001/api/demo -H "Content-Type: application/json" > /dev/null
    sleep 1
done

echo ""
echo "📊 Current Metrics:"
curl -s http://localhost:3001/api/metrics | python3 -m json.tool 2>/dev/null || curl -s http://localhost:3001/api/metrics

echo ""
echo "✅ Demo complete! Open http://localhost:3000 to see the dashboard."
