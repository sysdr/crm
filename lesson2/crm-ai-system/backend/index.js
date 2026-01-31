const express = require('express');
const cors = require('cors');
const app = express();
const port = 3001;

// CORS configuration: Allow requests from the React frontend
app.use(cors({
    origin: ['http://localhost:3000', 'http://127.0.0.1:3000']
}));

app.use(express.json());

// In-memory metrics store (simulating a database)
let metrics = {
    totalCustomers: 0,
    activeDeals: 0,
    revenue: 0,
    conversionRate: 0,
    newLeads: 0,
    closedDeals: 0,
    pendingTasks: 0,
    customerSatisfaction: 0,
    lastUpdated: new Date().toISOString()
};

// GET endpoint to return current metrics
app.get('/api/metrics', (req, res) => {
    console.log('Received request for /api/metrics');
    res.json(metrics);
});

// POST endpoint to update metrics (for demo purposes)
app.post('/api/metrics', (req, res) => {
    console.log('Updating metrics:', req.body);
    metrics = { ...metrics, ...req.body, lastUpdated: new Date().toISOString() };
    res.json(metrics);
});

// POST endpoint to simulate demo activity
app.post('/api/demo', (req, res) => {
    console.log('Running demo simulation...');
    
    // Simulate realistic CRM activity
    metrics.totalCustomers += Math.floor(Math.random() * 10) + 5;
    metrics.activeDeals += Math.floor(Math.random() * 5) + 2;
    metrics.revenue += Math.floor(Math.random() * 50000) + 10000;
    metrics.conversionRate = Math.min(100, Math.floor(Math.random() * 30) + 40);
    metrics.newLeads += Math.floor(Math.random() * 20) + 10;
    metrics.closedDeals += Math.floor(Math.random() * 3) + 1;
    metrics.pendingTasks = Math.floor(Math.random() * 15) + 5;
    metrics.customerSatisfaction = Math.min(100, Math.floor(Math.random() * 20) + 75);
    metrics.lastUpdated = new Date().toISOString();
    
    console.log('Demo metrics updated:', metrics);
    res.json({ success: true, message: 'Demo data generated', metrics });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Legacy endpoint for backward compatibility
app.get('/message', (req, res) => {
    console.log('Received request for /message');
    res.json({ text: 'Hello from CRM Backend!' });
});

// Start the Express server
const server = app.listen(port, () => {
    console.log(`CRM Backend service listening at http://localhost:${port}`);
    console.log('Available endpoints:');
    console.log('  GET  /api/metrics - Get current metrics');
    console.log('  POST /api/metrics - Update metrics');
    console.log('  POST /api/demo    - Generate demo data');
    console.log('  GET  /api/health  - Health check');
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});
