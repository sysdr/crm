#!/bin/bash

echo "🔍 Checking CRM AI System Services..."
echo ""

# Check for duplicate backend processes
echo "Backend processes (port 3001):"
BACKEND_PROCS=$(pgrep -f "node.*index.js" 2>/dev/null)
if [ -n "$BACKEND_PROCS" ]; then
    echo "$BACKEND_PROCS" | while read pid; do
        echo "  PID: $pid"
    done
    BACKEND_COUNT=$(echo "$BACKEND_PROCS" | wc -l)
    if [ "$BACKEND_COUNT" -gt 1 ]; then
        echo "  ⚠️  WARNING: Multiple backend processes detected!"
    fi
else
    echo "  No backend processes running"
fi

echo ""

# Check for duplicate frontend processes
echo "Frontend processes (port 3000):"
FRONTEND_PROCS=$(pgrep -f "react-scripts" 2>/dev/null)
if [ -n "$FRONTEND_PROCS" ]; then
    echo "$FRONTEND_PROCS" | while read pid; do
        echo "  PID: $pid"
    done
    FRONTEND_COUNT=$(echo "$FRONTEND_PROCS" | wc -l)
    if [ "$FRONTEND_COUNT" -gt 1 ]; then
        echo "  ⚠️  WARNING: Multiple frontend processes detected!"
    fi
else
    echo "  No frontend processes running"
fi

echo ""

# Check port usage
echo "Port usage:"
echo "  Port 3000 (Frontend):"
lsof -i :3000 2>/dev/null | grep LISTEN || echo "    Not in use"
echo "  Port 3001 (Backend):"
lsof -i :3001 2>/dev/null | grep LISTEN || echo "    Not in use"

echo ""

# Service health
echo "Service Health:"
if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
    echo "  ✅ Backend: Healthy"
else
    echo "  ❌ Backend: Not responding"
fi

if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "  ✅ Frontend: Accessible"
else
    echo "  ❌ Frontend: Not accessible"
fi
