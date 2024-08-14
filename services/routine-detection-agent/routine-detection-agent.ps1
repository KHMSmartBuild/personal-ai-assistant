# Routine Detection Agent PowerShell Script

# Import necessary modules
Import-Module WebAdministration

# Load Configuration
$configFilePath = "config/config.yaml"
if (-Not (Test-Path $configFilePath)) {
    Write-Host "Configuration file not found at $configFilePath"
    exit 1
}

$config = ConvertFrom-Yaml (Get-Content $configFilePath -Raw)

# Set up logging
$logFile = $config.logging.log_file_path
$logLevel = $config.logging.level

function Write-LogMessage {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    if ($level -ge $logLevel) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp [$level] $message"
        Add-Content -Path $logFile -Value $logEntry
        Write-Host $logEntry
    }
}

# Initialize data sources
# Remove the assignment to the 'dataSources' variable
$config.data_sources | Where-Object { $_.enabled }

# Placeholder for routine detection logic
function Find-Routines {
    param (
        [array]$activities
    )
    Write-LogMessage "Detecting routines from provided activities..." "INFO"
    # Implement your routine detection logic here
    # For demonstration, we'll just log the received activities
    $routines = @()  # Replace this with actual routine detection logic
    foreach ($activity in $activities) {
        Write-LogMessage "Processing activity: $($activity | ConvertTo-Json -Depth 3)" "INFO"
        # Add your detection logic here
        $routines += "Dummy Routine Detected"  # Placeholder
    }
    return $routines
}

# Function to handle routine detection request
function Invoke-RoutineDetectionRequest {
    param (
        [hashtable]$requestData
    )
    Write-LogMessage "Received routine detection request with data: $($requestData | ConvertTo-Json -Depth 3)" "INFO"
    $activities = $requestData.activities
    $routines = Detect-Routines -activities $activities
    return $routines
}

# Start the REST API
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://$($config.api.host):$($config.api.port)/")
$listener.Start()

Write-LogMessage "Routine Detection Agent is running at http://$($config.api.host):$($config.api.port)" "INFO"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $response.ContentType = "application/json"

    try {
        switch ($request.HttpMethod) {
            "POST" {
                if ($request.RawUrl -eq "/detect") {
                    # Handle routine detection request
                    $body = Get-Content -Raw -Path $request.InputStream
                    $requestData = $body | ConvertFrom-Json
                    $routines = Handle-RoutineDetectionRequest -requestData $requestData
                    $responseContent = $routines | ConvertTo-Json -Depth 3
                    $response.StatusCode = 200
                } else {
                    # Unknown endpoint
                    $response.StatusCode = 404
                    $responseContent = '{"error": "Endpoint not found"}'
                }
            }
            default {
                # Unsupported method
                $response.StatusCode = 405
                $responseContent = '{"error": "Method not allowed"}'
            }
        }
    } catch {
        # Handle errors
        $response.StatusCode = 500
        $responseContent = '{"error": "Internal server error"}'
        Write-LogMessage "Error: $_" "ERROR"
    }

    $responseContentBytes = [System.Text.Encoding]::UTF8.GetBytes($responseContent)
    $response.OutputStream.Write($responseContentBytes, 0, $responseContentBytes.Length)
    $response.OutputStream.Close()
}

$listener.Stop()
Write-LogMessage "Routine Detection Agent stopped." "INFO"
