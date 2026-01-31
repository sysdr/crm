#!/bin/bash

# --- CRM Database Demo Script ---
# This script demonstrates the database functionality with sample data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Define variables
DB_CONTAINER_NAME="crm-postgres"
DB_USER="crmuser"
DB_PASSWORD="crmpassword"
DB_NAME="crm_db"

# Use Docker from Windows if in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    DOCKER="/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe"
else
    DOCKER="docker"
fi

echo "==================================================="
echo " CRM Database Demo (Day 3)"
echo "==================================================="

# Check if container is running
if ! "$DOCKER" ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER_NAME}$"; then
    echo "Error: Container '$DB_CONTAINER_NAME' is not running."
    echo "Please run ./setup.sh first"
    exit 1
fi

echo ""
echo "--- Adding Demo Users ---"

# Insert demo users
"$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME <<EOF
INSERT INTO users (email, password_hash)
VALUES 
    ('bob@example.com', 'hashed_password_bob'),
    ('carol@example.com', 'hashed_password_carol'),
    ('david@example.com', 'hashed_password_david'),
    ('emma@example.com', 'hashed_password_emma'),
    ('frank@example.com', 'hashed_password_frank')
ON CONFLICT (email) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;
EOF

echo "Demo users added/updated."

echo ""
echo "==================================================="
echo "        CRM Database Dashboard"
echo "==================================================="

echo ""
echo "--- Database Statistics ---"
TOTAL_USERS=$("$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM users;")
LATEST_USER=$("$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -t -c "SELECT email FROM users ORDER BY created_at DESC LIMIT 1;")
OLDEST_USER=$("$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -t -c "SELECT email FROM users ORDER BY created_at ASC LIMIT 1;")

echo "  Total Users: $(echo $TOTAL_USERS | tr -d ' ')"
echo "  Newest User: $(echo $LATEST_USER | tr -d ' ')"
echo "  Oldest User: $(echo $OLDEST_USER | tr -d ' ')"

echo ""
echo "--- All Users ---"
"$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "SELECT id, email, created_at, updated_at FROM users ORDER BY created_at;"

echo ""
echo "--- Container Status ---"
"$DOCKER" ps -f name=$DB_CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "==================================================="
echo " Demo completed successfully!"
echo "==================================================="
