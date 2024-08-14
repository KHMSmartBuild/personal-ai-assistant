# PowerShell Script to Test Task Management Agent

# Define the base URL for the Task Management Agent
$baseUrl = "http://localhost:5023"

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

# Test 1: Check if the service is running by accessing the root endpoint
Test-Endpoint -url "$baseUrl/"

# Test 2: Create a new task
$newTask = @{
    "task_name" = "Sample Task"
    "action" = "create"
}
Test-Endpoint -url "$baseUrl/tasks" -method "POST" -body $newTask

# Test 3: Update the task
$updateTask = @{
    "task_name" = "Sample Task"
    "action" = "update"
}
Test-Endpoint -url "$baseUrl/tasks" -method "POST" -body $updateTask

# Test 4: Delete the task
$deleteTask = @{
    "task_name" = "Sample Task"
    "action" = "delete"
}
Test-Endpoint -url "$baseUrl/tasks" -method "POST" -body $deleteTask

# Test 5: Check API error handling by sending a malformed request
$malformedData = "this is not a valid JSON"
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/tasks" -Method "POST" -Body $malformedData -ContentType "application/json"
    Write-Host "Malformed Request Test: Unexpected Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Malformed Request Test: Failed as expected"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"

# Test 6: Check API response when unknown endpoint is hit
Test-Endpoint -url "$baseUrl/unknown-endpoint" -method "GET"
