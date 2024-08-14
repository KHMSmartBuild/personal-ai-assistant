# PowerShell Script to Test NLP Agent

# Define the base URL for the NLP Agent
$baseUrl = "http://localhost:5000"

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

# Test 2: Check NLP processing endpoint with a simple text
$nlpRequestData = @{
    "text" = "Hello, how are you today?"
}
Test-Endpoint -url "$baseUrl/process" -method "POST" -body $nlpRequestData

# Test 3: Post a more complex NLP request and check the response
$nlpComplexData = @{
    "text" = "What is the weather like in New York tomorrow?"
}
Test-Endpoint -url "$baseUrl/process" -method "POST" -body $nlpComplexData

# Test 4: Test the model information endpoint
Test-Endpoint -url "$baseUrl/model-info"

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
$configFile = "config/config.yaml"
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
    $response = Invoke-RestMethod -Uri "$baseUrl/process" -Method "POST" -Body $malformedData -ContentType "application/json"
    Write-Host "Malformed Request Test: Unexpected Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Malformed Request Test: Failed as expected"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"
