# Integration Test Script for AI Assistant Microservices

# Define the base URLs for the different services
$taskManagementUrl = "http://localhost:5023"
$nlpAgentUrl = "http://localhost:5024"
$routineDetectionUrl = "http://localhost:5025"
$securityPrivacyUrl = "http://localhost:5022"

# Helper function to send HTTP requests and print the result
function Test-Endpoint {
    param (
        [string]$url,
        [string]$method = "GET",
        [hashtable]$body = @{}
    )

    Write-Host "Testing $method $url"

    try {
        if ($method -eq "GET") {
            $response = Invoke-RestMethod -Uri $url -Method $method
        } elseif ($method -eq "POST") {
            $response = Invoke-RestMethod -Uri $url -Method $method -Body ($body | ConvertTo-Json) -ContentType "application/json"
        }
        Write-Host "Response Status: Success"
        Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
    } catch {
        Write-Host "Response Status: Failed"
        Write-Host "Error: $_"
    }
    Write-Host "--------------------------------------------"
}

# Test 1: Integration between NLP Agent and Task Management
Write-Host "Test 1: NLP Agent -> Task Management Integration"
$nlpData = @{
    "text" = "Remind me to finish the report by tomorrow."
    "intent" = "create_task"
}
Test-Endpoint -url "$nlpAgentUrl/process" -method "POST" -body $nlpData

$taskData = @{
    "task_name" = "Finish the report"
    "due_date" = "2024-08-15T17:00:00Z"
    "action" = "create"
}
Test-Endpoint -url "$taskManagementUrl/tasks" -method "POST" -body $taskData

# Test 2: Integration between Routine Detection and Task Management
Write-Host "Test 2: Routine Detection -> Task Management Integration"
$routineData = @{
    "activities" = @(
        @{
            "type" = "work"
            "timestamp" = "2024-08-15T09:00:00Z"
        }
    )
}
Test-Endpoint -url "$routineDetectionUrl/detect" -method "POST" -body $routineData

$taskCheckData = @{
    "task_name" = "Morning routine task check"
    "action" = "check_status"
}
Test-Endpoint -url "$taskManagementUrl/tasks/status" -method "POST" -body $taskCheckData

# Test 3: Integration between Security & Privacy and Task Management
Write-Host "Test 3: Security & Privacy -> Task Management Integration"
$jwtToken = "your_jwt_token_here"
$tokenData = @{
    "token" = $jwtToken
}
Test-Endpoint -url "$securityPrivacyUrl/verify-token" -method "POST" -body $tokenData

if ($?) {
    Write-Host "JWT Token verified successfully. Proceeding with task creation..."
    $secureTaskData = @{
        "task_name" = "Secure task creation"
        "action" = "create"
        "token" = $jwtToken
    }
    Test-Endpoint -url "$taskManagementUrl/tasks" -method "POST" -body $secureTaskData
} else {
    Write-Host "JWT Token verification failed. Task creation aborted."
}

# Test 4: Check error handling and service availability
Write-Host "Test 4: Error Handling and Service Availability"
$invalidEndpoint = "invalid-endpoint"
Test-Endpoint -url "$taskManagementUrl/$invalidEndpoint" -method "GET"

$malformedData = "this is not a valid JSON"
Test-Endpoint -url "$taskManagementUrl/tasks" -method "POST" -body $malformedData
