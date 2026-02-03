const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors'); // Import cors middleware

const app = express();
const PORT = process.env.PORT || 3000;
const DB_PATH = './crm.db';

// Initialize SQLite database
const db = new sqlite3.Database(DB_PATH, (err) => {
    if (err) {
        console.error('Error opening database:', err.message);
    } else {
        console.log('Connected to the SQLite database.');
        db.run(`
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                phone TEXT
            )
        `, (err) => {
            if (err) {
                console.error('Error creating contacts table:', err.message);
            } else {
                console.log('Contacts table ensured.');
            }
        });
    }
});

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(express.json()); // For parsing application/json

// Simple email check: has @ with something before and a dot after (no regex escaping issues)
function isValidEmail(str) {
    if (typeof str !== 'string') return false;
    const s = str.trim();
    if (!s) return false;
    const at = s.indexOf('@');
    return at > 0 && at < s.length - 1 && s.includes('.', at + 1) && s.lastIndexOf('.') > at;
}

// Handle JSON parse errors (empty or invalid body) so we return JSON 400
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        return res.status(400).json({ message: 'Invalid JSON body. Send JSON with name and email.' });
    }
    next(err);
});

// --- API Endpoints (from Day 6) ---

// GET all contacts
app.get('/api/contacts', (req, res) => {
    db.all("SELECT * FROM contacts", [], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ message: "success", data: rows });
    });
});

// GET a single contact by ID
app.get('/api/contacts/:id', (req, res) => {
    const { id } = req.params;
    db.get("SELECT * FROM contacts WHERE id = ?", [id], (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        if (row) {
            res.json({ message: "success", data: row });
        } else {
            res.status(404).json({ message: "Contact not found" });
        }
    });
});

// POST a new contact
app.post('/api/contacts', (req, res) => {
    const body = req.body || {};
    const name = (body.name != null ? String(body.name) : '').trim();
    const email = (body.email != null ? String(body.email) : '').trim();
    const phone = (body.phone != null ? String(body.phone) : '').trim();

    // Server-side validation
    if (!name || !email) {
        return res.status(400).json({ message: "Name and Email are required fields." });
    }
    if (!isValidEmail(email)) {
        return res.status(400).json({ message: "Invalid email format." });
    }

    db.run(`INSERT INTO contacts (name, email, phone) VALUES (?, ?, ?)`,
        [name, email, phone],
        function(err) {
            if (err) {
                if (err.message.includes('UNIQUE constraint failed: contacts.email')) {
                    return res.status(409).json({ message: "A contact with this email already exists." });
                }
                res.status(500).json({ error: err.message });
                return;
            }
            res.status(201).json({
                message: "Contact created successfully",
                data: { id: this.lastID, name, email, phone }
            });
        }
    );
});

// PUT (Update) a contact
app.put('/api/contacts/:id', (req, res) => {
    const { id } = req.params;
    const body = req.body || {};
    const name = (body.name != null ? String(body.name) : '').trim();
    const email = (body.email != null ? String(body.email) : '').trim();
    const phone = (body.phone != null ? String(body.phone) : '').trim();

    // Server-side validation for update
    if (!name || !email) {
        return res.status(400).json({ message: "Name and Email are required fields for update." });
    }
    if (!isValidEmail(email)) {
        return res.status(400).json({ message: "Invalid email format." });
    }

    db.run(
        `UPDATE contacts SET name = ?, email = ?, phone = ? WHERE id = ?`,
        [name, email, phone, id],
        function(err) {
            if (err) {
                if (err.message.includes('UNIQUE constraint failed: contacts.email')) {
                    return res.status(409).json({ message: "Another contact with this email already exists." });
                }
                res.status(500).json({ error: err.message });
                return;
            }
            if (this.changes === 0) {
                res.status(404).json({ message: "Contact not found or no changes made." });
            } else {
                res.json({ message: "Contact updated successfully", data: { id, name, email, phone } });
            }
        }
    );
});

// DELETE a contact
app.delete('/api/contacts/:id', (req, res) => {
    const { id } = req.params;
    db.run("DELETE FROM contacts WHERE id = ?", id, function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        if (this.changes === 0) {
            res.status(404).json({ message: "Contact not found" });
        } else {
            res.json({ message: "Contact deleted successfully" });
        }
    });
});

// In-memory metrics (totalContacts synced from DB on each request)
let metrics = {
    totalContacts: 0,
    activeDeals: 0,
    revenue: 0,
    conversionRate: 0,
    newLeads: 0,
    closedDeals: 0,
    pendingTasks: 0,
    customerSatisfaction: 0,
    lastUpdated: new Date().toISOString()
};

function syncMetricsFromDb(cb) {
    db.get("SELECT COUNT(*) as count FROM contacts", [], (err, row) => {
        if (err) { if (cb) cb(err); return; }
        metrics.totalContacts = row ? row.count : 0;
        metrics.lastUpdated = new Date().toISOString();
        if (cb) cb();
    });
}

// GET metrics (totalContacts from DB, rest from memory)
app.get('/api/metrics', (req, res) => {
    syncMetricsFromDb(() => res.json(metrics));
});

// POST /api/demo - add sample contacts and update metrics (so dashboard is non-zero)
app.post('/api/demo', (req, res) => {
    const samples = [
        { name: "Demo User One", email: "demo1@example.com", phone: "555-0101" },
        { name: "Demo User Two", email: "demo2@example.com", phone: "555-0102" },
        { name: "Demo User Three", email: "demo3@example.com", phone: "555-0103" },
        { name: "Demo User Four", email: "demo4@example.com", phone: "555-0104" },
        { name: "Demo User Five", email: "demo5@example.com", phone: "555-0105" }
    ];
    let inserted = 0;
    function insertNext(i) {
        if (i >= samples.length) {
            metrics.activeDeals = Math.floor(Math.random() * 10) + 5;
            metrics.revenue = Math.floor(Math.random() * 50000) + 10000;
            metrics.conversionRate = Math.min(100, Math.floor(Math.random() * 30) + 40);
            metrics.newLeads = Math.floor(Math.random() * 20) + 10;
            metrics.closedDeals = Math.floor(Math.random() * 5) + 1;
            metrics.pendingTasks = Math.floor(Math.random() * 15) + 5;
            metrics.customerSatisfaction = Math.min(100, Math.floor(Math.random() * 20) + 75);
            metrics.lastUpdated = new Date().toISOString();
            syncMetricsFromDb(() => {
                res.json({ success: true, message: "Demo data generated", metrics });
            });
            return;
        }
        const s = samples[i];
        db.run("INSERT OR IGNORE INTO contacts (name, email, phone) VALUES (?, ?, ?)", [s.name, s.email, s.phone], function(err) {
            if (!err && this.changes > 0) inserted++;
            insertNext(i + 1);
        });
    }
    insertNext(0);
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Start the server
app.listen(PORT, () => {
    console.log(`Backend server running on port ${PORT}`);
});

// Close the database connection when the app terminates
process.on('SIGINT', () => {
    db.close((err) => {
        if (err) {
            console.error(err.message);
        }
        console.log('Closed the database connection.');
        process.exit(0);
    });
});
