# PowerShell Script to Test Routine Detection Agent

# Define the base URL for the Routine Detection Agent
$baseUrl = "http://localhost:5021"

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

# Test 2: Simulate a routine detection request
$routineDetectionData = @{
    "activities" = @(
        @{
            "type" = "work"
            "timestamp" = "2024-08-15T09:00:00Z"
        },
        @{
            "type" = "exercise"
            "timestamp" = "2024-08-15T17:00:00Z"
        }
    )
}
Test-Endpoint -url "$baseUrl/detect" -method "POST" -body $routineDetectionData

# Test 3: Check if the configuration file loads correctly
$configFile = "config/config.yaml"
if (Test-Path $configFile) {
    Write-Host "Configuration File Test: Found"
    $configContent = Get-Content $configFile -Raw
    Write-Host "Configuration Content: $configContent"
} else {
    Write-Host "Configuration File Test: Not Found"
}
Write-Host "--------------------------------------------"

# Test 4: Check API error handling by sending a malformed request
$malformedData = "this is not a valid JSON"
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/detect" -Method "POST" -Body $malformedData -ContentType "application/json"
    Write-Host "Malformed Request Test: Unexpected Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Malformed Request Test: Failed as expected"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"

# Test 5: Check API response when unknown endpoint is hit
Test-Endpoint -url "$baseUrl/unknown-endpoint" -method "GET"
