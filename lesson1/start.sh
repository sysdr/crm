#!/bin/bash

# --- Console Dashboard Styling ---
GREEN='33[0;32m'
YELLOW='33[0;33m'
BLUE='33[0;34m'
RED='33[0;31m'
NC='33[0m' # No Color

function print_header() {
    echo -e "n${BLUE}=====================================================${NC}"
    echo -e "${BLUE}  AI-Powered CRM System - Day 1 Setup & Verification ${NC}"
    echo -e "${BLUE}=====================================================${NC}n"
}

function print_section() {
    echo -e "n${YELLOW}--- $1 ---${NC}"
}

function print_status() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# --- 1. Dependency Installation & Check ---
print_header
print_section "1. Checking Dependencies (Docker, Node.js, npm)"

# Check for Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker Desktop from https://www.docker.com/products/docker-desktop/ and restart your terminal."
fi
print_status "Docker found."

# Check for Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js (LTS recommended) from https://nodejs.org/ and restart your terminal."
fi
print_status "Node.js found."

# Check for npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install Node.js (npm comes with it) from https://nodejs.org/ and restart your terminal."
fi
print_status "npm found."

# --- 2. Project & File Structure Setup ---
print_section "2. Setting up Project Structure"

PROJECT_ROOT="crm-project"
SERVICE_DIR="$PROJECT_ROOT/services/hello-crm"

# Clean up previous runs if any
if [ -d "$PROJECT_ROOT" ]; then
    print_status "Found existing '$PROJECT_ROOT'. Cleaning up..."
    ./stop.sh > /dev/null 2>&1
    rm -rf "$PROJECT_ROOT"
    print_status "Cleaned up previous '$PROJECT_ROOT'."
fi

mkdir -p "$SERVICE_DIR" || print_error "Failed to create directory $SERVICE_DIR"
print_status "Created project directory: $SERVICE_DIR"

# --- 3. Generate Source Code (Hello CRM Express Server) ---
print_section "3. Generating Source Code for Hello CRM Service"

# package.json
cat <<EOF > "$SERVICE_DIR/package.json"
{
  "name": "hello-crm-service",
  "version": "1.0.0",
  "description": "First microservice for the AI-Powered CRM system.",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOF
print_status "Generated $SERVICE_DIR/package.json"

# server.js
cat <<EOF > "$SERVICE_DIR/server.js"
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello CRM! This is your first microservice running. Welcome to the future of customer relations.');
});

app.listen(port, () => {
  console.log(`Hello CRM service listening at http://localhost:${port}`);
});
EOF
print_status "Generated $SERVICE_DIR/server.js"

# Dockerfile
cat <<EOF > "$SERVICE_DIR/Dockerfile"
# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install any needed packages
RUN npm install --omit=dev

# Copy the rest of the application code
COPY . .

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Run the application
CMD [ "npm", "start" ]
EOF
print_status "Generated $SERVICE_DIR/Dockerfile"

# --- 4. Build, Test, and Launch (Without Docker - Local) ---
print_section "4. Running Hello CRM Service Locally (Without Docker)"

cd "$SERVICE_DIR" || print_error "Failed to change directory to $SERVICE_DIR"

print_status "Installing Node.js dependencies..."
npm install > /dev/null || print_error "Failed to install Node.js dependencies."
print_status "Node.js dependencies installed."

print_status "Starting Hello CRM service locally..."
node server.js &
LOCAL_PID=$!
sleep 3 # Give the server a moment to start

echo -e "${BLUE}Local service should be running at http://localhost:3000${NC}"
echo -e "${BLUE}Verifying local service with curl...${NC}"

LOCAL_RESPONSE=$(curl -s http://localhost:3000)
if [[ "$LOCAL_RESPONSE" == *"Hello CRM"* ]]; then
    print_status "Local service verification successful! Response: '$LOCAL_RESPONSE'"
else
    print_error "Local service verification failed. Response: '$LOCAL_RESPONSE'"
fi

print_status "Stopping local service (PID: $LOCAL_PID)..."
kill $LOCAL_PID
wait $LOCAL_PID 2>/dev/null
print_status "Local service stopped."

# --- 5. Build, Test, and Launch (With Docker) ---
print_section "5. Running Hello CRM Service with Docker"

print_status "Building Docker image 'hello-crm-service'..."
docker build -t hello-crm-service . > /dev/null || print_error "Failed to build Docker image."
print_status "Docker image 'hello-crm-service' built successfully."

print_status "Running Docker container 'hello-crm-container' on port 3000..."
docker run -d -p 3000:3000 --name hello-crm-container hello-crm-service > /dev/null || print_error "Failed to run Docker container."
sleep 5 # Give the container a moment to start

echo -e "${BLUE}Docker container should be running at http://localhost:3000${NC}"
echo -e "${BLUE}Verifying Docker service with curl...${NC}"

DOCKER_RESPONSE=$(curl -s http://localhost:3000)
if [[ "$DOCKER_RESPONSE" == *"Hello CRM"* ]]; then
    print_status "Docker service verification successful! Response: '$DOCKER_RESPONSE'"
else
    print_error "Docker service verification failed. Response: '$DOCKER_RESPONSE'"
fi

# --- 6. Demo and Verify Functionality (CLI Dashboard) ---
print_section "6. CLI Dashboard: Live Status & Manual Verification"

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}  CRM Day 1 Status Report                           ${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo -e "Container Name: hello-crm-container"
echo -e "Container ID:   $(docker ps -q -f name=hello-crm-container)"
echo -e "Image Used:     hello-crm-service"
echo -e "Exposed Port:   3000"
echo -e "Status:         $(docker ps -f name=hello-crm-container --format '{{.Status}}')"
echo -e "n${GREEN}To manually verify, open your browser or run curl:${NC}"
echo -e "  ${YELLOW}http://localhost:3000${NC}"
echo -e "  ${YELLOW}curl http://localhost:3000${NC}"
echo -e "n${BLUE}Use './stop.sh' to clean up all services and project files.${NC}"
echo -e "${BLUE}=====================================================${NC}n"

cd - > /dev/null # Go back to original directory
print_status "Setup and verification complete!"