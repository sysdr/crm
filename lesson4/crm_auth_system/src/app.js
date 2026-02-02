const express = require('express');
const path = require('path');
const { initializeDb, query } = require('./db');
const { registerUser, loginUser, authenticateToken } = require('./authController');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Metrics tracking
let metrics = {
  totalLogins: 0,
  activeTokens: 0,
  apiRequests: 0,
  startTime: Date.now()
};

// Middleware to count API requests
app.use((req, res, next) => {
  metrics.apiRequests++;
  next();
});

app.use(express.json()); // Middleware to parse JSON body
app.use(express.static(path.join(__dirname, '../public'))); // Serve static files

// --- Dashboard Route ---
app.get('/dashboard', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/dashboard.html'));
});

// --- API Routes ---
app.post('/register', registerUser);

// Wrap login to track metrics
app.post('/login', (req, res, next) => {
  const originalJson = res.json.bind(res);
  res.json = (data) => {
    if (data && data.token) {
      metrics.totalLogins++;
      metrics.activeTokens++;
    }
    return originalJson(data);
  };
  loginUser(req, res, next);
});

// A simple protected route to demonstrate token usage
app.get('/profile', authenticateToken, (req, res) => {
  res.json({ message: `Welcome to your profile, ${req.user.username}!`, user: req.user });
});

// --- Metrics API ---
app.get('/api/metrics', async (req, res) => {
  try {
    const result = await query('SELECT COUNT(*) as count FROM users');
    const totalUsers = parseInt(result.rows[0].count);
    
    res.json({
      totalUsers,
      totalLogins: metrics.totalLogins,
      activeTokens: metrics.activeTokens,
      apiRequests: metrics.apiRequests,
      uptime: Math.floor((Date.now() - metrics.startTime) / 1000)
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch metrics' });
  }
});

// --- Users API ---
app.get('/api/users', async (req, res) => {
  try {
    const result = await query('SELECT id, username, created_at FROM users ORDER BY id DESC LIMIT 20');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Root route redirects to dashboard
app.get('/', (req, res) => {
  res.redirect('/dashboard');
});

// Start the server
async function startServer() {
  await initializeDb(); // Ensure DB table exists
  app.listen(PORT, () => {
    console.log(`✅ CRM Auth Service running on http://localhost:${PORT}`);
    console.log(`📊 Dashboard available at http://localhost:${PORT}/dashboard`);
    console.log('Endpoints:');
    console.log(' - GET  /dashboard');
    console.log(' - POST /register {username, password}');
    console.log(' - POST /login {username, password}');
    console.log(' - GET  /profile (requires JWT)');
    console.log(' - GET  /api/metrics');
    console.log(' - GET  /api/users');
  });
}

startServer();
