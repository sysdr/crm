#!/bin/bash

# --- CRM Database Stop Script ---
# This script stops and removes the PostgreSQL container

DB_CONTAINER_NAME="crm-postgres"

# Use Docker from Windows if in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    DOCKER="/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe"
else
    DOCKER="docker"
fi

echo "==================================================="
echo " Stopping AI CRM Database (Day 3)"
echo "==================================================="

# Check if container exists
if "$DOCKER" ps -a --format '{{.Names}}' | grep -q "^${DB_CONTAINER_NAME}$"; then
    echo "Stopping container '$DB_CONTAINER_NAME'..."
    "$DOCKER" stop $DB_CONTAINER_NAME
    
    echo "Removing container '$DB_CONTAINER_NAME'..."
    "$DOCKER" rm $DB_CONTAINER_NAME
    
    echo "Container '$DB_CONTAINER_NAME' stopped and removed."
else
    echo "Container '$DB_CONTAINER_NAME' is not running."
fi

echo "==================================================="
echo " Database stopped successfully"
echo "==================================================="
