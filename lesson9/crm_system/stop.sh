#!/bin/bash
set -e
cd "$(dirname "$0")"
echo "Stopping CRM services..."
docker compose down 2>/dev/null || true
docker rm -f crm-postgres crm-backend-app 2>/dev/null || true
if [ -f backend_pid.txt ]; then
  kill $(cat backend_pid.txt) 2>/dev/null || true
  rm -f backend_pid.txt
fi
echo "Done."
