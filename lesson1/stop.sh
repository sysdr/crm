#!/bin/bash

# --- Console Dashboard Styling ---
GREEN='33[0;32m'
YELLOW='33[0;33m'
BLUE='33[0;34m'
RED='33[0;31m'
NC='33[0m' # No Color

function print_header() {
    echo -e "n${BLUE}=====================================================${NC}"
    echo -e "${BLUE}  AI-Powered CRM System - Day 1 Cleanup              ${NC}"
    echo -e "${BLUE}=====================================================${NC}n"
}

function print_section() {
    echo -e "n${YELLOW}--- $1 ---${NC}"
}

function print_status() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_info() {
    echo -e "${BLUE}* $1${NC}"
}

print_header
print_section "1. Stopping and Removing Docker Container"

CONTAINER_NAME="hello-crm-container"
IMAGE_NAME="hello-crm-service"
PROJECT_ROOT="crm-project"

# Stop and remove the container
if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    print_info "Stopping Docker container '$CONTAINER_NAME'..."
    docker stop "$CONTAINER_NAME" > /dev/null
    print_status "Container '$CONTAINER_NAME' stopped."
fi

if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
    print_info "Removing Docker container '$CONTAINER_NAME'..."
    docker rm "$CONTAINER_NAME" > /dev/null
    print_status "Container '$CONTAINER_NAME' removed."
fi

# Remove the Docker image
if docker images -q "$IMAGE_NAME" | grep -q .; then
    print_info "Removing Docker image '$IMAGE_NAME'..."
    docker rmi "$IMAGE_NAME" > /dev/null
    print_status "Image '$IMAGE_NAME' removed."
fi



echo -e "n${BLUE}=====================================================${NC}"
echo -e "${BLUE}  Cleanup complete! System is back to a clean state.  ${NC}"
echo -e "${BLUE}=====================================================${NC}n"