#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "🚀 Starting CRM AI System..."

# Check for existing processes
if pgrep -f "node.*index.js" > /dev/null 2>&1; then
    echo "⚠️  Backend may already be running. Check with: pgrep -f 'node.*index.js'"
fi

# Start backend
echo "Starting backend service (http://localhost:3001)..."
cd backend
node index.js > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid
cd "${SCRIPT_DIR}"
echo "Backend PID: ${BACKEND_PID}"

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
        echo "✅ Backend is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Backend failed to start within 30 seconds"
        exit 1
    fi
    sleep 1
done

# Start frontend
echo "Starting frontend development server (http://localhost:3000)..."
cd frontend
BROWSER=none npm start > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid
cd "${SCRIPT_DIR}"
echo "Frontend PID: ${FRONTEND_PID}"

echo ""
echo "✅ CRM AI System is starting!"
echo "   Backend:  http://localhost:3001"
echo "   Frontend: http://localhost:3000"
echo ""
echo "📊 API Endpoints:"
echo "   GET  /api/metrics - Get current metrics"
echo "   POST /api/demo    - Generate demo data"
echo "   GET  /api/health  - Health check"
echo ""
echo "To stop: ${SCRIPT_DIR}/stop.sh"
