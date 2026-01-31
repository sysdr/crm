import React, { useState, useEffect, useCallback } from 'react';
import './App.css';

function App() {
  const [metrics, setMetrics] = useState({
    totalCustomers: 0,
    activeDeals: 0,
    revenue: 0,
    conversionRate: 0,
    newLeads: 0,
    closedDeals: 0,
    pendingTasks: 0,
    customerSatisfaction: 0,
    lastUpdated: null
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [demoRunning, setDemoRunning] = useState(false);
  
  const backendUrl = process.env.REACT_APP_BACKEND_URL || 'http://localhost:3001';

  const fetchMetrics = useCallback(async () => {
    try {
      const response = await fetch(`${backendUrl}/api/metrics`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      setMetrics(data);
      setError(null);
    } catch (err) {
      console.error("Failed to fetch metrics:", err);
      setError('Failed to connect to backend. Is the server running?');
    } finally {
      setLoading(false);
    }
  }, [backendUrl]);

  const runDemo = async () => {
    setDemoRunning(true);
    try {
      const response = await fetch(`${backendUrl}/api/demo`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      setMetrics(data.metrics);
      setError(null);
    } catch (err) {
      console.error("Failed to run demo:", err);
      setError('Failed to run demo');
    } finally {
      setDemoRunning(false);
    }
  };

  useEffect(() => {
    fetchMetrics();
    // Auto-refresh every 10 seconds
    const interval = setInterval(fetchMetrics, 10000);
    return () => clearInterval(interval);
  }, [fetchMetrics]);

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount);
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'Never';
    return new Date(dateString).toLocaleString();
  };

  if (loading) {
    return (
      <div className="App">
        <div className="loading">Loading CRM Dashboard...</div>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>🎯 AI-Powered CRM Dashboard</h1>
        <p className="subtitle">Real-time Business Intelligence</p>
      </header>
      
      <div className="lesson-info">
        <h3>📚 Lesson 2: Full-Stack Integration</h3>
        <p><strong>Goal:</strong> Build a complete React + Node.js application with real-time data flow.</p>
        <div className="learn-points">
          <span>✓ REST API design</span>
          <span>✓ Frontend-Backend communication</span>
          <span>✓ Docker containerization</span>
          <span>✓ Environment configuration</span>
        </div>
      </div>
      
      {error && <div className="error-banner">{error}</div>}
      
      <main className="dashboard">
        <div className="metrics-grid">
          <div className="metric-card primary">
            <div className="metric-icon">👥</div>
            <div className="metric-value">{metrics.totalCustomers}</div>
            <div className="metric-label">Total Customers</div>
          </div>
          
          <div className="metric-card success">
            <div className="metric-icon">💰</div>
            <div className="metric-value">{formatCurrency(metrics.revenue)}</div>
            <div className="metric-label">Total Revenue</div>
          </div>
          
          <div className="metric-card info">
            <div className="metric-icon">📊</div>
            <div className="metric-value">{metrics.activeDeals}</div>
            <div className="metric-label">Active Deals</div>
          </div>
          
          <div className="metric-card warning">
            <div className="metric-icon">📈</div>
            <div className="metric-value">{metrics.conversionRate}%</div>
            <div className="metric-label">Conversion Rate</div>
          </div>
          
          <div className="metric-card">
            <div className="metric-icon">🔥</div>
            <div className="metric-value">{metrics.newLeads}</div>
            <div className="metric-label">New Leads</div>
          </div>
          
          <div className="metric-card success">
            <div className="metric-icon">✅</div>
            <div className="metric-value">{metrics.closedDeals}</div>
            <div className="metric-label">Closed Deals</div>
          </div>
          
          <div className="metric-card info">
            <div className="metric-icon">📝</div>
            <div className="metric-value">{metrics.pendingTasks}</div>
            <div className="metric-label">Pending Tasks</div>
          </div>
          
          <div className="metric-card primary">
            <div className="metric-icon">⭐</div>
            <div className="metric-value">{metrics.customerSatisfaction}%</div>
            <div className="metric-label">Customer Satisfaction</div>
          </div>
        </div>
        
        <div className="actions">
          <button 
            className="demo-button" 
            onClick={runDemo} 
            disabled={demoRunning}
          >
            {demoRunning ? '⏳ Generating...' : '🚀 Run Demo (Generate Data)'}
          </button>
          <button 
            className="refresh-button" 
            onClick={fetchMetrics}
          >
            🔄 Refresh Metrics
          </button>
        </div>
        
        <div className="last-updated">
          Last Updated: {formatDate(metrics.lastUpdated)}
        </div>
      </main>
      
      <footer className="App-footer">
        <p>CRM AI System - Day 2 Lesson</p>
      </footer>
    </div>
  );
}

export default App;
