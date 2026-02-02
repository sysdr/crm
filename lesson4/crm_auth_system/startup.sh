#!/bin/bash
echo "🚀 Starting CRM Auth System..."

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Start Docker containers
echo "Starting Docker containers..."
docker-compose --env-file .env up --build -d

echo "Waiting for services to be healthy..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ CRM Auth System is running!"
    echo "Service available at http://localhost:3000"
    echo ""
    echo "Endpoints:"
    echo " - POST /register {username, password}"
    echo " - POST /login {username, password}"
    echo " - GET /profile (requires JWT)"
else
    echo "❌ Failed to start services. Check docker-compose logs."
    docker-compose logs
fi
