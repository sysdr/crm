#!/bin/bash

# --- CRM Database Setup Script ---
# This script sets up a PostgreSQL database for the AI CRM,
# creates a 'users' table, inserts a sample user, and verifies the setup.

# Define variables
DB_CONTAINER_NAME="crm-postgres"

# Use Docker from Windows if in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    DOCKER="/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe"
else
    DOCKER="docker"
fi
DB_USER="crmuser"
DB_PASSWORD="crmpassword"
DB_NAME="crm_db"
DB_PORT="5432"
POSTGRES_IMAGE="postgres:14-alpine"

echo "==================================================="
echo " Starting AI CRM Database Setup (Day 3)"
echo "==================================================="

# --- 1. Check for Docker ---
echo "Checking for Docker..."
if ! "$DOCKER" --version &> /dev/null
then
    echo "Docker is not available. Please ensure Docker Desktop is running."
    echo "  - macOS: https://docs.docker.com/desktop/install/mac-install/"
    echo "  - Windows: https://docs.docker.com/desktop/install/windows-install/"
    echo "  - Linux: https://docs.docker.com/engine/install/ubuntu/"
    exit 1
fi
echo "Docker found."

# --- 2. Stop and remove any existing container ---
echo "Stopping and removing any existing '$DB_CONTAINER_NAME' container..."
"$DOCKER" stop $DB_CONTAINER_NAME &> /dev/null
"$DOCKER" rm $DB_CONTAINER_NAME &> /dev/null
echo "Cleaned up old container (if any)."

# --- 3. Start PostgreSQL in Docker ---
echo "Starting PostgreSQL container '$DB_CONTAINER_NAME'..."
"$DOCKER" run --name $DB_CONTAINER_NAME \
           -e POSTGRES_USER=$DB_USER \
           -e POSTGRES_PASSWORD=$DB_PASSWORD \
           -e POSTGRES_DB=$DB_NAME \
           -p $DB_PORT:$DB_PORT \
           -d $POSTGRES_IMAGE

if [ $? -ne 0 ]; then
    echo "Failed to start PostgreSQL container. Exiting."
    exit 1
fi

echo "PostgreSQL container '$DB_CONTAINER_NAME' started on port $DB_PORT."
echo "Waiting for PostgreSQL to be ready (this might take a few seconds)..."
sleep 10 # Give PostgreSQL time to initialize

# --- 4. Connect to PostgreSQL and execute DDL/DML ---
echo "Connecting to PostgreSQL and setting up the 'users' table..."

# Create users table
"$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME <<EOF
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
EOF

if [ $? -ne 0 ]; then
    echo "Failed to create 'users' table. Exiting."
    "$DOCKER" stop $DB_CONTAINER_NAME
    "$DOCKER" rm $DB_CONTAINER_NAME
    exit 1
fi
echo "Table 'users' created or already exists."

# Insert a sample user
echo "Inserting a sample user (alice@example.com)..."
"$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME <<EOF
INSERT INTO users (email, password_hash)
VALUES ('alice@example.com', 'hashed_password_for_alice')
ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash, updated_at = CURRENT_TIMESTAMP;
EOF

if [ $? -ne 0 ]; then
    echo "Failed to insert sample user. Exiting."
    "$DOCKER" stop $DB_CONTAINER_NAME
    "$DOCKER" rm $DB_CONTAINER_NAME
    exit 1
fi
echo "Sample user 'alice@example.com' inserted/updated."

# --- 5. Verify functionality (CLI Dashboard) ---
echo "==================================================="
echo "        CRM Database Status Dashboard"
echo "==================================================="

echo "--- PostgreSQL Container Status ---"
"$DOCKER" ps -f name=$DB_CONTAINER_NAME

echo -e "\n--- Database Connection Info ---"
echo "Host: localhost"
echo "Port: $DB_PORT"
echo "User: $DB_USER"
echo "DB Name: $DB_NAME"

echo -e "\n--- 'users' Table Schema ---"
"$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "\\d users"

echo -e "\n--- Sample User Data ---"
"$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "SELECT id, email, created_at, updated_at FROM users;"

echo -e "\n==================================================="
echo "Database setup complete! You can connect using:"
echo "  psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME"
echo "  Password: $DB_PASSWORD"
echo "To stop the database, run: ./stop.sh"
echo "==================================================="