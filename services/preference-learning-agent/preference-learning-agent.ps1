# Preference Learning Agent PowerShell Script

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

function Write-Log {
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

# Initialize in-memory preference store (or connect to a database)
$preferenceStore = @{}

function Save-Preferences {
    param (
        [string]$userId,
        [hashtable]$preferences
    )
    $preferenceStore[$userId] = $preferences
    Write-Log "Preferences saved for user ${userId}: $(${preferences} | ConvertTo-Json -Depth 3)" "INFO"
}

function Get-Preferences {
    param (
        [string]$userId
    )
    if ($preferenceStore.ContainsKey($userId)) {
        return $preferenceStore[$userId]
    } else {
        return @{}
    }
}

# Placeholder for preference learning model initialization
function Initialize-PreferenceLearningModel {
    Write-Log "Initializing Preference Learning model..." "INFO"
    # Here you would load your machine learning model or set up your preference learning logic
    Write-Log "Preference Learning model initialized." "INFO"
}

# Function to simulate learning from interaction data
function Invoke-Interactions {
    param (
        [string]$userId,
        [array]$interactionData
    )
    Write-Log "Learning from interactions for user ${userId}: $($interactionData | ConvertTo-Json -Depth 3)" "INFO"
    # This is where the preference learning would occur. Replace this with actual learning code.
    # For demonstration, we'll just log the interaction data.
    return @{
        "status" = "Learning completed"
        "user_id" = $userId
        "updated_preferences" = $preferenceStore[$userId]  # Assuming learning updates the preferences
    }
}

# Initialize the Preference Learning model
Initialize-PreferenceLearningModel

# Start the REST API
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://${config.api.host}:${config.api.port}/")
$listener.Start()

Write-Log "Preference Learning Agent is running at http://${config.api.host}:${config.api.port}" "INFO"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $response.ContentType = "application/json"

    try {
        switch ($request.HttpMethod) {
            "GET" {
                if ($request.RawUrl -eq "/preferences") {
                    # Return user preferences
                    $queryParams = $request.Url.Query
                    $userId = $queryParams.Substring($queryParams.IndexOf("=") + 1)
                    $responseContent = Get-Preferences -userId $userId | ConvertTo-Json -Depth 3
                    $response.StatusCode = 200
                } else {
                    # Unknown endpoint
                    $response.StatusCode = 404
                    $responseContent = '{"error": "Endpoint not found"}'
                }
            }
            "POST" {
                if ($request.RawUrl -eq "/preferences") {
                    # Save user preferences
                    $body = Get-Content -Raw -Path $request.InputStream
                    $preferenceRequest = $body | ConvertFrom-Json
                    Save-Preferences -userId $preferenceRequest.user_id -preferences $preferenceRequest.preferences
                    $responseContent = '{"status": "Preferences saved successfully"}'
                    $response.StatusCode = 200
                } elseif ($request.RawUrl -eq "/train") {
                    # Train the model with user interaction data
                    $body = Get-Content -Raw -Path $request.InputStream
                    $trainingRequest = $body | ConvertFrom-Json
                    $responseContent = Train-From-Interactions -userId $trainingRequest.user_id -interactionData $trainingRequest.interaction_data | ConvertTo-Json -Depth 3
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
        Write-Log "Error: $_" "ERROR"
    }

    $responseContentBytes = [System.Text.Encoding]::UTF8.GetBytes($responseContent)
    $response.OutputStream.Write($responseContentBytes, 0, $responseContentBytes.Length)
    $response.OutputStream.Close()
}

$listener.Stop()
Write-Log "Preference Learning Agent stopped." "INFO"