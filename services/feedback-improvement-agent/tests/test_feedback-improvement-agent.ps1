# PowerShell Script to Test Feedback and Improvement Agent

# Define the base URL for the Feedback and Improvement Agent
$baseUrl = "http://localhost:5005"

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

# Test 2: Check feedback retrieval endpoint
Test-Endpoint -url "$baseUrl/feedbacks"

# Test 3: Post new feedback and check the response
$feedbackData = @{
    "feedback" = "Great job on the recent update!";
    "user" = "user123";
    "rating" = 5
}
Test-Endpoint -url "$baseUrl/feedback" -method "POST" -body $feedbackData

# Test 4: Test the improvement trigger endpoint
$improvementData = @{
    "trigger" = "performance";
    "description" = "The system could be more responsive during peak hours."
}
Test-Endpoint -url "$baseUrl/improvement" -method "POST" -body $improvementData

# Test 5: Check if security (JWT) is enabled
# Note: This part assumes JWT is implemented. Adjust as needed.
$jwtToken = "your_jwt_token_here"
$headers = @{ "Authorization" = "Bearer $jwtToken" }
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/secure-endpoint" -Headers $headers
    Write-Host "JWT Token Test: Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "JWT Token Test: Failed"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"

# Test 6: Load and verify the configuration file
$configFile = "C:\path\to\your\config.yaml"
if (Test-Path $configFile) {
    Write-Host "Configuration File Test: Found"
    $configContent = Get-Content $configFile -Raw
    Write-Host "Configuration Content: $configContent"
} else {
    Write-Host "Configuration File Test: Not Found"
}
Write-Host "--------------------------------------------"

# Test 7: Check API error handling by sending a malformed request
$malformedData = "this is not a valid JSON"
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/feedback" -Method "POST" -Body $malformedData -ContentType "application/json"
    Write-Host "Malformed Request Test: Unexpected Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Malformed Request Test: Failed as expected"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"
