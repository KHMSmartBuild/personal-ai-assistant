from flask import Flask, request, jsonify

app = Flask(__name__)

feedback_store = []

@app.route('/feedback', methods=['POST'])
def collect_feedback():
    feedback = request.json.get("feedback", "")
    
    # Store the feedback (in a real application, you might save this to a database)
    feedback_store.append(feedback)
    
    # Placeholder for triggering improvement processes based on feedback
    improvement_action = "Improvement model executed"
    
    response = {
        "status": "Feedback received",
        "feedback": feedback,
        "action": improvement_action
    }
    return jsonify(response)

@app.route('/feedbacks', methods=['GET'])
def get_feedbacks():
    return jsonify({"feedbacks": feedback_store})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005)
