#!/bin/bash
echo "🛑 Stopping CRM Auth System..."

# Stop Docker containers
if docker-compose ps -q 2>/dev/null | grep -q .; then
    echo "Stopping Docker containers..."
    docker-compose down
    echo "Docker containers stopped."
else
    echo "No Docker containers running."
fi

# Stop any running Node.js process
if [ -f .node_pid ]; then
    NODE_PID=$(cat .node_pid)
    if kill -0 $NODE_PID 2>/dev/null; then
        echo "Stopping Node.js process (PID: $NODE_PID)..."
        kill $NODE_PID
        rm -f .node_pid
        echo "Node.js process stopped."
    else
        rm -f .node_pid
        echo "Node.js process not running."
    fi
else
    echo "No Node.js PID file found."
fi

echo "✅ Cleanup complete."
