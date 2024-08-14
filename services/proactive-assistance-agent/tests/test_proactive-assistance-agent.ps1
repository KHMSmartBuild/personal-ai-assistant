# PowerShell Script to Test Proactive Assistance Agent

# Define the base URL for the Proactive Assistance Agent
$baseUrl = "http://localhost:5013"

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

# Test 2: Simulate an event-based trigger
$eventTriggerData = @{
    "event_type" = "context_change"
    "user_id" = "user123"
    "new_context" = "Office"
}
Test-Endpoint -url "$baseUrl/trigger" -method "POST" -body $eventTriggerData

# Test 3: Check time-based trigger function (if applicable)
# Since time-based triggers usually run in intervals, you might want to check the logs for their execution.
Write-Host "To test time-based triggers, please check the logs for scheduled triggers."

# Test 4: Load and verify the configuration file
$configFile = "C:\path\to\your\config.yaml"
if (Test-Path $configFile) {
    Write-Host "Configuration File Test: Found"
    $configContent = Get-Content $configFile -Raw
    Write-Host "Configuration Content: $configContent"
} else {
    Write-Host "Configuration File Test: Not Found"
}
Write-Host "--------------------------------------------"

# Test 5: Check API error handling by sending a malformed request
$malformedData = "this is not a valid JSON"
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/trigger" -Method "POST" -Body $malformedData -ContentType "application/json"
    Write-Host "Malformed Request Test: Unexpected Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Malformed Request Test: Failed as expected"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"

# Test 6: Check API response when unknown endpoint is hit
Test-Endpoint -url "$baseUrl/unknown-endpoint" -method "GET"
