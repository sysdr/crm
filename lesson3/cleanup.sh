#!/bin/bash

# --- CRM Database Cleanup Script ---
# This script stops containers and removes all unused Docker resources

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Define variables
DB_CONTAINER_NAME="crm-postgres"

# Use Docker from Windows if in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    DOCKER="/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe"
else
    DOCKER="docker"
fi

echo "==================================================="
echo " CRM Database Cleanup Script (Day 3)"
echo "==================================================="

# --- 1. Stop the CRM container ---
echo ""
echo "--- Stopping CRM Container ---"
if "$DOCKER" ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER_NAME}$"; then
    echo "Stopping container '$DB_CONTAINER_NAME'..."
    "$DOCKER" stop $DB_CONTAINER_NAME
    echo "Container stopped."
else
    echo "Container '$DB_CONTAINER_NAME' is not running."
fi

# --- 2. Remove the CRM container ---
echo ""
echo "--- Removing CRM Container ---"
if "$DOCKER" ps -a --format '{{.Names}}' | grep -q "^${DB_CONTAINER_NAME}$"; then
    echo "Removing container '$DB_CONTAINER_NAME'..."
    "$DOCKER" rm $DB_CONTAINER_NAME
    echo "Container removed."
else
    echo "Container '$DB_CONTAINER_NAME' does not exist."
fi

# --- 3. Remove all stopped containers ---
echo ""
echo "--- Removing All Stopped Containers ---"
STOPPED=$("$DOCKER" ps -aq -f status=exited)
if [ -n "$STOPPED" ]; then
    "$DOCKER" rm $STOPPED
    echo "Stopped containers removed."
else
    echo "No stopped containers to remove."
fi

# --- 4. Remove unused images ---
echo ""
echo "--- Removing Unused (Dangling) Images ---"
DANGLING=$("$DOCKER" images -q -f dangling=true)
if [ -n "$DANGLING" ]; then
    "$DOCKER" rmi $DANGLING
    echo "Dangling images removed."
else
    echo "No dangling images to remove."
fi

# --- 5. Remove unused volumes ---
echo ""
echo "--- Removing Unused Volumes ---"
"$DOCKER" volume prune -f

# --- 6. Remove unused networks ---
echo ""
echo "--- Removing Unused Networks ---"
"$DOCKER" network prune -f

# --- 7. Docker system prune (comprehensive cleanup) ---
echo ""
echo "--- Docker System Prune ---"
"$DOCKER" system prune -f

# --- 8. Show cleanup results ---
echo ""
echo "==================================================="
echo " Cleanup Results"
echo "==================================================="
echo ""
echo "--- Remaining Containers ---"
"$DOCKER" ps -a
echo ""
echo "--- Remaining Images ---"
"$DOCKER" images
echo ""
echo "--- Remaining Volumes ---"
"$DOCKER" volume ls
echo ""
echo "==================================================="
echo " Cleanup completed!"
echo "==================================================="
