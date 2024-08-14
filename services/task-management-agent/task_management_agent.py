from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/tasks', methods=['POST'])
def create_task():
    data = request.json
    task_name = data.get('task_name', '')
    
    # Placeholder for task creation logic
    response = {
        "task_name": task_name,
        "status": "Task created"
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003)
