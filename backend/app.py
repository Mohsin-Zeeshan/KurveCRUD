# =======================
# Imports & App Setup
# =======================
from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3
import os

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter frontend

# Database file path
DB_PATH = 'customers.db'


# ============================
# Database Setup
# ============================

def init_db():
    """Create the customers table if it doesn't exist"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create customers table with id (unique identifier to each customer), name, age, and email
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            email TEXT NOT NULL
        )
    ''')
    
    # Check if table is empty and add some sample data if so 
    cursor.execute('SELECT COUNT(*) FROM customers')
    count = cursor.fetchone()[0]
    
    if count == 0:
        
        sample_customers = [
            ('Conor McGregor', 25, 'conor@gmail.com'),
            ('Khabib Nurmagomedov', 30, 'khabib@outlook.com'),
            ('Floyd Mayweather', 35, 'floyd@hotmail.com'),
            ('Alex Pereira', 28, 'alex@yahoo.com'),
            ('Dana White', 42, 'dana@gmail.com')
        ]
        cursor.executemany('INSERT INTO customers (name, age, email) VALUES (?, ?, ?)', sample_customers)
    
    conn.commit()
    conn.close()

# =======================
# GET: Get All Customers
# =======================

@app.route('/api/customers', methods=['GET'])
def get_customers():
    """Get all customers from the database"""
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM customers')
        customers = cursor.fetchall()
        
        # Convert to list of dictionaries
        customer_list = []
        for customer in customers:
            customer_list.append({
                'id': customer[0],
                'name': customer[1],
                'age': customer[2],
                'email': customer[3]
            })
        
        conn.close()
        return jsonify(customer_list)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
# =======================
# POST: Create a Customer
# =======================

@app.route('/api/customers', methods=['POST'])
def create_customer():
    """Create a new customer"""
    try:
        data = request.json
        
        # Check that all fields have to an input
        if not all(key in data for key in ['name', 'age', 'email']):
            return jsonify({'error': 'Missing required fields'}), 400
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Insert the new customer into the database

        cursor.execute('''
            INSERT INTO customers (name, age, email) 
            VALUES (?, ?, ?)
        ''', (data['name'], data['age'], data['email']))
        
        conn.commit()
        customer_id = cursor.lastrowid
        conn.close()
        
        # Return the new customer
        return jsonify({
            'id': customer_id,
            'name': data['name'],
            'age': data['age'],
            'email': data['email']
        }), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
# ========================
# DELETE: Delete Customer
# ========================

@app.route('/api/customers/<int:customer_id>', methods=['DELETE'])
def delete_customer(customer_id):
    """Delete a customer by ID"""
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Delete the selected customer
        cursor.execute('DELETE FROM customers WHERE id = ?', (customer_id,))
        
        if cursor.rowcount == 0:
            conn.close()
            return jsonify({'error': 'Customer not found'}), 404
        
        conn.commit()
        conn.close()
        
        return jsonify({'message': 'Customer deleted successfully'}), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
# =========================
# PUT: Update a Customer
# =========================

@app.route('/api/customers/<int:customer_id>', methods=['PUT'])
def update_customer(customer_id):
    """Update a customer's data"""
    try:
        data = request.json
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Prepare query components
        update_fields = []
        values = []
        
        if 'name' in data:
            update_fields.append('name = ?')
            values.append(data['name'])
        if 'age' in data:
            update_fields.append('age = ?')
            values.append(data['age'])
        if 'email' in data:
            update_fields.append('email = ?')
            values.append(data['email'])
        
        # If no fields were provided, return error        
        if not update_fields:
            return jsonify({'error': 'No fields to update'}), 400
        
        # Add customer ID to the end of values
        values.append(customer_id)
        query = f"UPDATE customers SET {', '.join(update_fields)} WHERE id = ?"
        
        cursor.execute(query, values)
        
        if cursor.rowcount == 0:
            conn.close()
            return jsonify({'error': 'Customer not found'}), 404
        
        conn.commit()
        conn.close()
        
        return jsonify({'message': 'Customer updated successfully'}), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Initialize database on startup
    init_db()
    
    