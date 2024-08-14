from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/learn', methods=['POST'])
def learn():
    data = request.json
    user_preferences = data.get('preferences', {})
    
    # Placeholder for preference learning logic
    response = {
        "preferences": user_preferences,
        "learning": "This is where the preference learning results will go."
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
