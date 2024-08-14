from flask import Flask, request, jsonify
from cryptography.fernet import Fernet
import os

app = Flask(__name__)

# Generate a key for encryption and decryption
# You should save this key securely and load it in a secure manner in production
key = os.environ.get('SECURITY_KEY', Fernet.generate_key())
cipher_suite = Fernet(key)

@app.route('/secure', methods=['POST'])
def secure_data():
    data = request.json.get("sensitive_data", "")
    
    # Encrypt the sensitive data
    encrypted_data = cipher_suite.encrypt(data.encode())
    
    # In a real application, you'd store the encrypted data securely
    response = {
        "status": "Data secured",
        "encrypted_data": encrypted_data.decode()
    }
    return jsonify(response)

@app.route('/retrieve', methods=['POST'])
def retrieve_data():
    encrypted_data = request.json.get("encrypted_data", "")
    
    # Decrypt the sensitive data
    decrypted_data = cipher_suite.decrypt(encrypted_data.encode()).decode()
    
    response = {
        "status": "Data retrieved",
        "decrypted_data": decrypted_data
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004)
