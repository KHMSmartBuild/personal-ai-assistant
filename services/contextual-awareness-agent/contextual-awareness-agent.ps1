# Contextual Awareness Agent PowerShell Script

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

# Initialize context
$currentContext = @{}

function Update-Context {
    param (
        [hashtable]$newContext
    )
    foreach ($key in $newContext.Keys) {
        $currentContext[$key] = $newContext[$key]
    }
    Log-Message "Context updated: $($currentContext | ConvertTo-Json -Depth 3)" "INFO"
}

# Start the REST API
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://$($config.api.host):$($config.api.port)/")
$listener.Start()

Log-Message "Contextual Awareness Agent is running at http://$($config.api.host):$($config.api.port)" "INFO"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $response.ContentType = "application/json"

    try {
        switch ($request.HttpMethod) {
            "GET" {
                if ($request.RawUrl -eq "/context") {
                    # Return the current context
                    $response.StatusCode = 200
                    $responseContent = $currentContext | ConvertTo-Json -Depth 3
                } else {
                    # Unknown endpoint
                    $response.StatusCode = 404
                    $responseContent = '{"error": "Endpoint not found"}'
                }
            }
            "POST" {
                if ($request.RawUrl -eq "/context") {
                    # Update the context with new data
                    $body = Get-Content -Raw -Path $request.InputStream
                    $newContext = $body | ConvertFrom-Json
                    Update-Context -newContext $newContext
                    $response.StatusCode = 200
                    $responseContent = '{"status": "Context updated successfully"}'
                } elseif ($request.RawUrl -eq "/notify") {
                    # Handle notifications (e.g., send a reminder)
                    $body = Get-Content -Raw -Path $request.InputStream
                    $notification = $body | ConvertFrom-Json
                    Log-Message "Notification received: $($notification.message)" "INFO"
                    $response.StatusCode = 200
                    $responseContent = '{"status": "Notification sent"}'
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
        Log-Message "Error: $_" "ERROR"
    }

    $responseContentBytes = [System.Text.Encoding]::UTF8.GetBytes($responseContent)
    $response.OutputStream.Write($responseContentBytes, 0, $responseContentBytes.Length)
    $response.OutputStream.Close()
}

$listener.Stop()
Log-Message "Contextual Awareness Agent stopped." "INFO"
