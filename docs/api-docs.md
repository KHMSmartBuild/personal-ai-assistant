# API Documentation

## Overview

This document provides detailed information about the API endpoints available in the AI Assistant system. Each service has its own set of endpoints, which are described below.

---

## NLP Agent

### Endpoint: `/analyze`

- **Method**: POST
- **Description**: Analyzes the input text and returns an analysis result.
- **Request Body**:

        {
        "query": "What's the weather like today?"
        }

- **Response**:

    {

        "query": "What's the weather like today?",

        "analysis": "This is where the analysis results will go."
    }

## Routine Detection Agent

- **Endpoint**: /detect

- **Method**: POST

- **Description**: Detects user routines based on input data.

- **Request Body**:

        {
        "routine_data": 
        ["Wake up at 7 AM", 
        "Go to the gym"]
        }

- **Response**:

        {
        "routine_data": 
        ["Wake up at 7 AM", "Go to the gym"],
        "detection": 
        "This is where the routine detection results will go."
        }

## Security and Privacy Agent

- **Endpoint**: /secure

- **Method**: POST

- **Description**: Secures sensitive data by encrypting it.

- **Request Body**:

        {
        "sensitive_data": "My secret data"
        }

- **Response**:

        {
        "status": "Data secured",
        "encrypted_data": "gAAAAABh..."
        }

- **Endpoint**: /retrieve
- **Method**: POST
- **Description**: Decrypts previously secured data.
- **Request Body**

        `{
        "encrypted_data": "gAAAAABh..."
        }`

- **Response**:

        {
        "status": "Data retrieved",
        "decrypted_data": "My secret data"
        }

## Feedback and Improvement Agent

- **Endpoint**: /feedback
- **Method**: POST
- **Description**: Collects user feedback and triggers improvement actions.
- **Request Body**:

        {
        "feedback": "Great job!"
        }
- **Response**:

        {
        "status": "Feedback received",
        "feedback": "Great job!",
        "action": "Improvement model executed"
        }
- **Endpoint**: /feedbacks
- **Method**: GET
    Description: Retrieves all collected feedback.
- **Response**:

        {
        "feedbacks": ["Great job!"]
        }

## Proactive Assistance Agent

- **Endpoint**: /assist
-**Method**: POST
- **Description**: Provides proactive assistance based on user context.
- **Request Body**:

        {
        "context": "User is feeling stressed"
        }
- **Response**:

        {
        "context": "User is feeling stressed",
        "suggestion": "Based on your context, we suggest you do X."
        }

## Task Management Agent

- **Endpoint**: /tasks
- **Method**: POST
- **Description**: Creates a new task for the user.
- **Request Body**:

        {
        "task_name": "Finish the report"
        }
- **Response**:

        {
        "task_name": "Finish the report",
        "status": "Task created"
        }
