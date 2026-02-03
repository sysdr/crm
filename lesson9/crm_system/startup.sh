#!/bin/bash
set -e
cd "$(dirname "$0")"
echo "Starting CRM services..."
docker compose up -d
echo "Backend: http://localhost:8080  Dashboard: http://localhost:8080/dashboard.html"
