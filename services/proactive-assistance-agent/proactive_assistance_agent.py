from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/assist', methods=['POST'])
def assist_user():
    context = request.json.get("context", "")
    
    # Placeholder for proactive assistance logic
    suggestion = "Based on your context, we suggest you do X."
    
    response = {
        "context": context,
        "suggestion": suggestion
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5006)
