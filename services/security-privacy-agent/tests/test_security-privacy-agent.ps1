# PowerShell Script to Test Security and Privacy Agent

# Define the base URL for the Security and Privacy Agent
$baseUrl = "http://localhost:5022"

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

# Test 2: Verify JWT token
$jwtToken = "your_jwt_token_here"
$tokenData = @{
    "token" = $jwtToken
}
Test-Endpoint -url "$baseUrl/verify-token" -method "POST" -body $tokenData

# Test 3: Encrypt some data
$plaintextData = @{
    "plaintext" = "This is some sensitive information."
}
Test-Endpoint -url "$baseUrl/encrypt" -method "POST" -body $plaintextData

# Test 4: Decrypt the encrypted data
$encryptedData = "your_encrypted_data_here"  # Replace with actual encrypted data from Test 3
$encryptedPayload = @{
    "encrypted_data" = $encryptedData
}
Test-Endpoint -url "$baseUrl/decrypt" -method "POST" -body $encryptedPayload

# Test 5: Check API error handling by sending a malformed request
$malformedData = "this is not a valid JSON"
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/encrypt" -Method "POST" -Body $malformedData -ContentType "application/json"
    Write-Host "Malformed Request Test: Unexpected Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Malformed Request Test: Failed as expected"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"

# Test 6: Check API response when unknown endpoint is hit
Test-Endpoint -url "$baseUrl/unknown-endpoint" -method "GET"
