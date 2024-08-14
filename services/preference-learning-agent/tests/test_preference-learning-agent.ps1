# PowerShell Script to Test Preference Learning Agent

# Define the base URL for the Preference Learning Agent
$baseUrl = "http://localhost:5006"

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

# Test 2: Check user preferences retrieval
$userPreferencesRequestData = @{
    "user_id" = "user123"
}
Test-Endpoint -url "$baseUrl/preferences" -method "POST" -body $userPreferencesRequestData

# Test 3: Post new preferences and check the response
$newPreferencesData = @{
    "user_id" = "user123";
    "preferences" = @{
        "theme" = "dark";
        "notifications" = "enabled";
        "language" = "en-US"
    }
}
Test-Endpoint -url "$baseUrl/preferences" -method "POST" -body $newPreferencesData

# Test 4: Check the model training endpoint
$trainingData = @{
    "user_id" = "user123";
    "interaction_data" = @(
        @{
            "action" = "click";
            "item" = "article";
            "timestamp" = "2024-08-14T10:00:00Z"
        },
        @{
            "action" = "view";
            "item" = "video";
            "timestamp" = "2024-08-14T11:00:00Z"
        }
    )
}
Test-Endpoint -url "$baseUrl/train" -method "POST" -body $trainingData

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
    $response = Invoke-RestMethod -Uri "$baseUrl/preferences" -Method "POST" -Body $malformedData -ContentType "application/json"
    Write-Host "Malformed Request Test: Unexpected Success"
    Write-Host "Response Body: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Malformed Request Test: Failed as expected"
    Write-Host "Error: $_"
}
Write-Host "--------------------------------------------"
