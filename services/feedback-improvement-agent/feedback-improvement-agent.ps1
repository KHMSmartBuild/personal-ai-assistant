# Feedback and Improvement Agent PowerShell Script

# Import necessary modules
Import-Module WebAdministration

# Load Configuration
$configFilePath = "C:\path\to\your\config.yaml"
if (-Not (Test-Path $configFilePath)) {
    Write-Host "Configuration file not found at $configFilePath"
    exit 1
}

$config = ConvertFrom-Yaml (Get-Content $configFilePath -Raw)

# Set up logging
$logFile = $config.logging.log_file_path
$logLevel = $config.logging.level

function Write-Log-Message {
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

# Initialize in-memory feedback store (or connect to a database)
$feedbackStore = @()

function Save-Feedback {
    param (
        [hashtable]$feedback
    )
    $feedbackStore += $feedback
    Log-Message "Feedback saved: $($feedback | ConvertTo-Json -Depth 3)" "INFO"
}

function Get-All-Feedback {
    return $feedbackStore
}

# Start the REST API
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://$($config.api.host):$($config.api.port)/")
$listener.Start()

Log-Message "Feedback and Improvement Agent is running at http://$($config.api.host):$($config.api.port)" "INFO"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $response.ContentType = "application/json"

    try {
        switch ($request.HttpMethod) {
            "GET" {
                if ($request.RawUrl -eq "/feedbacks") {
                    # Return all feedback
                    $response.StatusCode = 200
                    $responseContent = Get-All-Feedback | ConvertTo-Json -Depth 3
                } else {
                    # Unknown endpoint
                    $response.StatusCode = 404
                    $responseContent = '{"error": "Endpoint not found"}'
                }
            }
            "POST" {
                if ($request.RawUrl -eq "/feedback") {
                    # Save new feedback
                    $body = Get-Content -Raw -Path $request.InputStream
                    $feedback = $body | ConvertFrom-Json
                    Save-Feedback -feedback $feedback
                    $response.StatusCode = 200
                    $responseContent = '{"status": "Feedback saved successfully"}'
                } elseif ($request.RawUrl -eq "/improvement") {
                    # Handle improvement trigger
                    $body = Get-Content -Raw -Path $request.InputStream
                    $improvement = $body | ConvertFrom-Json
                    Log-Message "Improvement triggered: $($improvement.description)" "INFO"
                    $response.StatusCode = 200
                    $responseContent = '{"status": "Improvement triggered"}'
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
Log-Message "Feedback and Improvement Agent stopped." "INFO"
