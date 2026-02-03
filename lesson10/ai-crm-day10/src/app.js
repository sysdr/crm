const path = require('path');
const express = require('express');
const dotenv = require('dotenv');
const leadRoutes = require('./routes/leadRoutes');
const errorHandler = require('./middleware/errorHandler');

dotenv.config({ path: path.join(__dirname, '..', 'config', 'config.env') });

const app = express();
app.locals.leads = [];
app.locals.metrics = {
  totalLeads: 0,
  activeDeals: 0,
  revenue: 0,
  conversionRate: 0,
  newLeads: 0,
  closedDeals: 0,
  pendingTasks: 0,
  customerSatisfaction: 0,
  lastUpdated: new Date().toISOString(),
};

function syncMetricsFromLeads() {
  const leads = app.locals.leads || [];
  app.locals.metrics.totalLeads = leads.length;
  app.locals.metrics.lastUpdated = new Date().toISOString();
}

app.use(express.json());

app.get('/api/metrics', (req, res) => {
  syncMetricsFromLeads();
  res.json(app.locals.metrics);
});

app.post('/api/demo', (req, res) => {
  const samples = [
    { name: 'Demo Lead One', email: 'demo1@example.com', source: 'Website', notes: 'Demo' },
    { name: 'Demo Lead Two', email: 'demo2@example.com', source: 'Referral', notes: 'Demo' },
    { name: 'Demo Lead Three', email: 'demo3@example.com', source: 'Advertisement', notes: 'Demo' },
    { name: 'Demo Lead Four', email: 'demo4@example.com', source: 'Website', notes: 'Demo' },
    { name: 'Demo Lead Five', email: 'demo5@example.com', source: 'Other', notes: 'Demo' },
  ];
  samples.forEach((s, i) => {
    app.locals.leads.push({
      id: 'lead-demo-' + Date.now() + '-' + i,
      ...s,
      createdAt: new Date().toISOString(),
    });
  });
  const m = app.locals.metrics;
  m.activeDeals = Math.floor(Math.random() * 10) + 5;
  m.revenue = Math.floor(Math.random() * 50000) + 10000;
  m.conversionRate = Math.min(100, Math.floor(Math.random() * 30) + 40);
  m.newLeads = Math.floor(Math.random() * 20) + 10;
  m.closedDeals = Math.floor(Math.random() * 5) + 1;
  m.pendingTasks = Math.floor(Math.random() * 15) + 5;
  m.customerSatisfaction = Math.min(100, Math.floor(Math.random() * 20) + 75);
  syncMetricsFromLeads();
  res.json({ success: true, message: 'Demo data generated', metrics: app.locals.metrics });
});

app.use('/api/v1/leads', leadRoutes);
app.use(express.static(path.join(__dirname, '..', 'public')));

app.all('*', (req, res, next) => {
  res.status(404).json({
    status: 'fail',
    message: 'Can\'t find ' + req.originalUrl + ' on this server!',
    errorCode: 'NOT_FOUND',
  });
});

app.use(errorHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('Server running on port ' + PORT);
});
