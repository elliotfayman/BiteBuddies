import cv2
#import pytesseract
from PIL import Image
from flask import Flask, request, jsonify
import numpy as np
import requests
from werkzeug.utils import secure_filename
import os
import sqlite3

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False
app.config['DEBUG'] = True

# create database table if it does not exist
def create_table():
    conn = sqlite3.connect('accounts.db')
    cur = conn.cursor()
    cur.execute('''CREATE TABLE IF NOT EXISTS accounts
               (id INTEGER PRIMARY KEY AUTOINCREMENT,
               name TEXT NOT NULL,
               password TEXT NOT NULL,
               receipts BLOB);''')
    conn.commit()
    cur.close()
    conn.close()


def preprocess_image(image):
    # Convert to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Apply adaptive thresholding
    thresh = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 11, 2)

    # Invert the image
    thresh = cv2.bitwise_not(thresh)

    return thresh

@app.route('/extract_text', methods=['POST'])
def extract_text():
    # Get the uploaded image
    file = request.files['image']
    if not file:
        return jsonify({'error': 'No image file provided'})

    # Load the image and preprocess it
    image = cv2.imdecode(np.fromstring(file.read(), np.uint8), cv2.IMREAD_UNCHANGED)
    processed_image = preprocess_image(image)

    # Run OCR on the image
    text = pytesseract.image_to_string(Image.fromarray(processed_image))

    # Extract the text and return it as a JSON response
    return jsonify({'text': text})

@app.route('/get_recipes', methods=['GET'])
def get_recipes():
    url = "https://api.spoonacular.com/recipes/findByIngredients"
    foods = request.args.get('foods')
    params = {
    "apiKey": "***REMOVED***", 
    "ingredients": foods, 
    "number": 10, 
    "ranking": 1
    }

    # Make the API request
    response = requests.get(url, params=params)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the JSON response
        recipes = response.json()
        names = []
        for recipe in recipes:
            names.append(recipe['title'])
        return jsonify({'recipes': names})
    else:
        print("Error: ", response.status_code)
        return jsonify({'ERROR': recipes})
    
# endpoint for creating a new account
@app.route('/account', methods=['POST'])
def create_account():
    name = request.json.get('name')
    password = request.json.get('password')
    receipts = request.json.get('receipts')

    conn = sqlite3.connect('accounts.db')
    cur = conn.cursor()
    cur.execute('''INSERT INTO accounts (name, password, receipts)
                   VALUES (?, ?, ?)''', (name, password, receipts))
    conn.commit()
    new_id = cur.lastrowid
    cur.close()
    conn.close()

    return jsonify({'id': new_id}), 201

# endpoint for retrieving an account by id
@app.route('/account/<int:id>', methods=['GET'])
def get_account(id):
    conn = sqlite3.connect('accounts.db')
    cur = conn.cursor()
    cur.execute('SELECT * FROM accounts WHERE id = ?', (id,))
    account = cur.fetchone()
    cur.close()
    conn.close()

    if account:
        return jsonify({'id': account[0], 'name': account[1], 'password': account[2], 'receipts': account[3]})
    else:
        return jsonify({'error': 'Account not found'}), 404

# endpoint for updating an account by id
@app.route('/account/<int:id>', methods=['PUT'])
def update_account(id):
    name = request.json.get('name')
    password = request.json.get('password')
    receipts = request.json.get('receipts')

    conn = sqlite3.connect('accounts.db')
    cur = conn.cursor()
    cur.execute('''UPDATE accounts SET name = ?, password = ?, receipts = ?
                   WHERE id = ?''', (name, password, receipts, id))
    conn.commit()
    cur.close()
    conn.close()

    return jsonify({'id': id}), 200

# endpoint for deleting an account by id
@app.route('/account/<int:id>', methods=['DELETE'])
def delete_account(id):
    conn = sqlite3.connect('accounts.db')
    cur = conn.cursor()
    cur.execute('DELETE FROM accounts WHERE id = ?', (id,))
    conn.commit()
    cur.close()
    conn.close()

    return jsonify({'result': True}), 204


if __name__ == '__main__':
    create_table()
    app.run(debug=True)
