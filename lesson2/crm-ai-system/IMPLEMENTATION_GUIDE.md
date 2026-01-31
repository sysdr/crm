# CRM AI System - Implementation Guide

## Lesson 2: Full-Stack Integration

---

## Overview

This project demonstrates building a complete full-stack web application with a **React frontend** and **Node.js/Express backend**. The application is a CRM (Customer Relationship Management) dashboard that displays real-time business metrics.

### Learning Objectives

By completing this lesson, you will understand:

| Concept | Description |
|---------|-------------|
| **REST API Design** | Creating endpoints for CRUD operations |
| **Frontend-Backend Communication** | Using `fetch` API for HTTP requests |
| **State Management** | React hooks (`useState`, `useEffect`, `useCallback`) |
| **CORS Configuration** | Enabling cross-origin requests |
| **Docker Containerization** | Multi-stage builds and docker-compose |
| **Environment Configuration** | Using `.env` files for configuration |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      USER BROWSER                           │
│                    http://localhost:3000                    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   FRONTEND (React)                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  App.js                                              │   │
│  │  - Displays 8 metric cards                          │   │
│  │  - Auto-refreshes every 10 seconds                  │   │
│  │  - Demo button to generate data                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                    fetch() API                              │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  BACKEND (Node.js/Express)                  │
│                    http://localhost:3001                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  REST API Endpoints:                                 │   │
│  │  GET  /api/metrics  - Retrieve metrics              │   │
│  │  POST /api/metrics  - Update metrics                │   │
│  │  POST /api/demo     - Generate demo data            │   │
│  │  GET  /api/health   - Health check                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│              In-Memory Data Store                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
crm-ai-system/
├── backend/
│   ├── index.js          # Express server with REST API
│   ├── package.json      # Node.js dependencies
│   └── Dockerfile        # Backend container config
│
├── frontend/
│   ├── src/
│   │   ├── App.js        # Main React component
│   │   └── App.css       # Dashboard styling
│   ├── public/           # Static assets
│   ├── .env              # Environment variables
│   ├── Dockerfile        # Multi-stage frontend build
│   └── nginx.conf        # Production server config
│
├── docker-compose.yml    # Container orchestration
├── start.sh              # Start services locally
├── stop.sh               # Stop services
├── test.sh               # Run API tests
├── demo.sh               # Generate demo data
├── cleanup.sh            # Clean up resources
└── .gitignore            # Git ignore rules
```

---

## API Reference

### GET `/api/metrics`

Returns current CRM metrics.

**Response:**
```json
{
  "totalCustomers": 57,
  "activeDeals": 18,
  "revenue": 182443,
  "conversionRate": 58,
  "newLeads": 156,
  "closedDeals": 13,
  "pendingTasks": 8,
  "customerSatisfaction": 77,
  "lastUpdated": "2026-01-31T04:42:35.054Z"
}
```

### POST `/api/demo`

Generates random demo data to simulate CRM activity.

**Response:**
```json
{
  "success": true,
  "message": "Demo data generated",
  "metrics": { ... }
}
```

### GET `/api/health`

Health check endpoint for monitoring.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-01-31T04:42:35.054Z"
}
```

---

## Quick Start

### Prerequisites

- Node.js 18+ installed
- npm (comes with Node.js)
- Docker (optional, for containerization)

### Installation

```bash
# 1. Navigate to project directory
cd crm-ai-system

# 2. Install backend dependencies
cd backend && npm install && cd ..

# 3. Install frontend dependencies
cd frontend && npm install && cd ..
```

### Running Locally

```bash
# Start both services
./start.sh

# Open browser to http://localhost:3000
```

### Running with Docker

```bash
# Build and start containers
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

---

## Key Implementation Details

### 1. Backend: Express Server Setup

```javascript
// index.js - Core setup
const express = require('express');
const cors = require('cors');
const app = express();

// Enable CORS for frontend
app.use(cors({
    origin: ['http://localhost:3000']
}));

app.use(express.json());
```

**Key Points:**
- CORS middleware allows frontend to make requests
- `express.json()` parses JSON request bodies
- In-memory store simulates a database

### 2. Frontend: React State Management

```javascript
// App.js - State and data fetching
const [metrics, setMetrics] = useState({...});
const [loading, setLoading] = useState(true);

const fetchMetrics = useCallback(async () => {
  const response = await fetch(`${backendUrl}/api/metrics`);
  const data = await response.json();
  setMetrics(data);
}, [backendUrl]);

useEffect(() => {
  fetchMetrics();
  const interval = setInterval(fetchMetrics, 10000);
  return () => clearInterval(interval);
}, [fetchMetrics]);
```

**Key Points:**
- `useCallback` memoizes the fetch function
- `useEffect` runs on mount and sets up auto-refresh
- Cleanup function clears interval on unmount

### 3. Docker: Multi-Stage Build (Frontend)

```dockerfile
# Stage 1: Build
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
```

**Key Points:**
- Stage 1 builds the React app
- Stage 2 uses nginx to serve static files
- Final image is small (~25MB vs ~1GB)

### 4. Environment Configuration

```bash
# frontend/.env
REACT_APP_BACKEND_URL=http://localhost:3001
```

**Key Points:**
- React requires `REACT_APP_` prefix for env vars
- Never commit sensitive data to `.env`
- Use `.env.example` for templates

---

## Dashboard Metrics

| Metric | Icon | Description |
|--------|------|-------------|
| Total Customers | 👥 | Number of registered customers |
| Total Revenue | 💰 | Cumulative revenue in USD |
| Active Deals | 📊 | Deals currently in pipeline |
| Conversion Rate | 📈 | Lead to customer conversion % |
| New Leads | 🔥 | Recently acquired leads |
| Closed Deals | ✅ | Successfully closed deals |
| Pending Tasks | 📝 | Tasks awaiting completion |
| Customer Satisfaction | ⭐ | CSAT score percentage |

---

## Testing

Run the test script to verify API functionality:

```bash
./test.sh
```

**Test Cases:**
1. Backend health check
2. Metrics API returns data
3. Demo endpoint generates data
4. Metrics have non-zero values
5. Frontend accessibility

---

## Available Scripts

| Script | Purpose |
|--------|---------|
| `./start.sh` | Start backend and frontend services |
| `./stop.sh` | Stop all running services |
| `./test.sh` | Run API tests |
| `./demo.sh` | Generate demo data (5 iterations) |
| `./check-services.sh` | Check service status and ports |
| `./cleanup.sh` | Stop containers, remove Docker resources |

---

## Troubleshooting

### Port Already in Use

```bash
# Check what's using the port
lsof -i :3001
lsof -i :3000

# Kill process by PID
kill <PID>
```

### Backend Not Responding

```bash
# Check if backend is running
curl http://localhost:3001/api/health

# View backend logs
cat backend/backend.log
```

### CORS Errors

Ensure the backend CORS config includes your frontend URL:
```javascript
app.use(cors({
    origin: ['http://localhost:3000', 'http://127.0.0.1:3000']
}));
```

---

## Next Steps

After completing this lesson, consider:

1. **Add Database** - Replace in-memory store with MongoDB/PostgreSQL
2. **Authentication** - Add JWT-based user authentication
3. **Real-time Updates** - Implement WebSockets for live data
4. **Testing** - Add Jest unit tests and Cypress E2E tests
5. **CI/CD** - Set up GitHub Actions for automated deployment

---

## Resources

- [Express.js Documentation](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

---

*CRM AI System - Lesson 2 | Full-Stack Integration*
