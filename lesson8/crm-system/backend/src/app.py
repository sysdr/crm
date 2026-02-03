from flask import Flask, request, jsonify
from flask_cors import CORS
from .database import get_db_connection, init_db
import os
import sqlite3

app = Flask(__name__)
CORS(app)  # Allow frontend (e.g. localhost:8000) to fetch /api/metrics and /api/demo

# In-memory metrics (totalLeads/totalContacts synced from DB; rest updated by /api/demo)
_metrics = {
    "totalLeads": 0,
    "totalContacts": 0,
    "activeDeals": 0,
    "revenue": 0,
    "conversionRate": 0,
    "newLeads": 0,
    "closedDeals": 0,
    "pendingTasks": 0,
    "customerSatisfaction": 0,
    "lastUpdated": None,
}

def _sync_metrics_from_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM leads")
    _metrics["totalLeads"] = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM contacts")
    _metrics["totalContacts"] = cur.fetchone()[0]
    from datetime import datetime
    _metrics["lastUpdated"] = datetime.utcnow().isoformat() + "Z"
    conn.close()

# Initialize database on startup
with app.app_context():
    init_db()

@app.route('/')
def health_check():
    return jsonify({"status": "CRM Backend is running", "day": "8"})

@app.route('/leads', methods=['POST'])
def create_lead():
    data = request.get_json()
    if not data or not data.get('name') or not data.get('email'):
        return jsonify({"error": "Name and email are required"}), 400

    name = data['name']
    email = data['email']
    phone = data.get('phone')
    company = data.get('company')
    source = data.get('source', 'Web Form')
    status = data.get('status', 'New')

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO leads (name, email, phone, company, source, status) VALUES (?, ?, ?, ?, ?, ?)",
            (name, email, phone, company, source, status)
        )
        conn.commit()
        lead_id = cursor.lastrowid
        return jsonify({"message": "Lead created successfully", "lead_id": lead_id}), 201
    except sqlite3.IntegrityError:
        conn.rollback()
        return jsonify({"error": "Lead with this email already exists"}), 409
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/leads', methods=['GET'])
def get_leads():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, email, phone, company, source, status, created_at FROM leads ORDER BY created_at DESC")
    leads = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return jsonify(leads), 200

@app.route('/leads/<int:lead_id>/convert', methods=['POST'])
def convert_lead(lead_id):
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM leads WHERE id = ?", (lead_id,))
        row = cursor.fetchone()
        lead = dict(row) if row else None

        if not lead:
            return jsonify({"error": f"Lead with ID {lead_id} not found"}), 404

        status = lead.get("status") or "New"
        if status == "Converted":
            cursor.execute("SELECT id FROM contacts WHERE lead_id = ?", (lead_id,))
            contact_row = cursor.fetchone()
            contact_id = contact_row["id"] if contact_row else "N/A"
            return jsonify({
                "message": f"Lead with ID {lead_id} is already converted.",
                "contact_id": contact_id
            }), 200

        if status in ("New", "Qualified"):
            cursor.execute(
                "INSERT INTO contacts (lead_id, name, email, phone, company, status) VALUES (?, ?, ?, ?, ?, ?)",
                (
                    lead["id"],
                    lead["name"],
                    lead["email"],
                    lead.get("phone"),
                    lead.get("company"),
                    "Active",
                ),
            )
            contact_id = cursor.lastrowid
            cursor.execute(
                "UPDATE leads SET status = 'Converted', updated_at = CURRENT_TIMESTAMP WHERE id = ?",
                (lead_id,),
            )
            conn.commit()
            return jsonify({
                "message": f"Lead {lead_id} converted to Contact {contact_id} successfully.",
                "contact_id": contact_id
            }), 200

        return jsonify({
            "error": f"Lead with ID {lead_id} cannot be converted from status '{status}'"
        }), 400

    except sqlite3.IntegrityError:
        try:
            conn.rollback()
        except Exception:
            pass
        return jsonify({
            "error": "A contact with this email or lead_id already exists. Check for duplicate conversions."
        }), 409
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/contacts', methods=['GET'])
def get_contacts():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, lead_id, name, email, phone, company, status, created_at FROM contacts ORDER BY created_at DESC")
    contacts = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return jsonify(contacts), 200

@app.route('/api/metrics', methods=['GET'])
def get_metrics():
    _sync_metrics_from_db()
    return jsonify(_metrics), 200

@app.route('/api/demo', methods=['POST'])
def run_demo():
    samples = [
        {"name": "Demo Lead One", "email": "demolead1@example.com", "phone": "555-0101", "company": "Demo Co", "source": "Web"},
        {"name": "Demo Lead Two", "email": "demolead2@example.com", "phone": "555-0102", "company": "Demo Co", "source": "Referral"},
        {"name": "Demo Lead Three", "email": "demolead3@example.com", "phone": "555-0103", "company": "Demo Co", "source": "Web"},
    ]
    conn = get_db_connection()
    cursor = conn.cursor()
    for s in samples:
        try:
            cursor.execute(
                "INSERT INTO leads (name, email, phone, company, source, status) VALUES (?, ?, ?, ?, ?, ?)",
                (s["name"], s["email"], s.get("phone"), s.get("company"), s.get("source", "Web Form"), "New")
            )
        except sqlite3.IntegrityError:
            pass
    conn.commit()
    conn.close()
    _metrics["activeDeals"] = __import__("random").randint(5, 15)
    _metrics["revenue"] = __import__("random").randint(10000, 60000)
    _metrics["conversionRate"] = min(100, __import__("random").randint(40, 70))
    _metrics["newLeads"] = __import__("random").randint(10, 30)
    _metrics["closedDeals"] = __import__("random").randint(1, 6)
    _metrics["pendingTasks"] = __import__("random").randint(5, 20)
    _metrics["customerSatisfaction"] = min(100, __import__("random").randint(75, 95))
    _sync_metrics_from_db()
    return jsonify({"success": True, "message": "Demo data generated", "metrics": _metrics}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=os.environ.get('PORT', 5000), debug=True)
