# Security and Privacy Agent PowerShell Script

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
# Example usage of $jwtSecretKey
$jwtSecretKey = "your-secret-key"

# Function to create a JWT token
function New-JwtToken {
    param (
        [string]$key,
        [hashtable]$payload
    )

    # Example payload encoding (simplified)
    $header = @{ alg = "HS256"; typ = "JWT" }
    $headerJson = $header | ConvertTo-Json -Compress
    $payloadJson = $payload | ConvertTo-Json -Compress

    $headerEncoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($headerJson))
    $payloadEncoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($payloadJson))

    $signature = [System.Convert]::ToBase64String(
        [System.Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($key)).ComputeHash(
            [Text.Encoding]::UTF8.GetBytes("$headerEncoded.$payloadEncoded")
        )
    )

    return "$headerEncoded.$payloadEncoded.$signature"
}

# Example payload
$payload = @{
    sub = "1234567890"
    name = "John Doe"
    admin = $true
}

# Create a JWT token using the secret key
$token = New-JwtToken -key $jwtSecretKey -payload $payload
Write-Output $token
# Initialize security settings
$jwtSecretKey = $config.security.jwt_secret_key
$enableHttps = $config.security.enable_https
$sslCertFile = $config.security.ssl_cert_file
$sslKeyFile = $config.security.ssl_key_file

# Function to verify JWT tokens

function VerifyJwtToken {
    param (
        [string]$token
    )
    try {
        $decodedToken = [System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler]::new().ReadJwtToken($token)
        if ($decodedToken) {
            Write-LogMessage "JWT Token verification successful." "INFO"
            return $true
        }} catch {
        Write-LogMessage "JWT Token verification failed: $_" "ERROR"
        return $false
    }
}


# Function to encrypt data
function Protect-Data {
    param (
        [string]$data
    )
    $encryptedData = ConvertTo-SecureString $data -AsPlainText -Force | ConvertFrom-SecureString
    Write-LogMessage "Data encrypted successfully." "INFO"
    return $encryptedData
}

# Function to decrypt data
function Invoke-Decryption {
    param (
        [string]$encryptedData
    )
    $decryptedData = ConvertTo-SecureString $encryptedData | ConvertFrom-SecureString -AsPlainText
    Write-LogMessage "Data decrypted successfully." "INFO"
    return $decryptedData
}

# Start the REST API
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://$($config.api.host):$($config.api.port)/")

if ($enableHttps) {
    $listener.Prefixes.Add("https://$($config.api.host):$($config.api.port)/")
    $listener.SslConfiguration.ServerCertificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($sslCertFile, $sslKeyFile)
}

$listener.Start()

Write-LogMessage "Security and Privacy Agent is running at http://$($config.api.host):$($config.api.port)" "INFO"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $response.ContentType = "application/json"

    try {
        switch ($request.HttpMethod) {
            "POST" {
                if ($request.RawUrl -eq "/verify-token") {
                    # Verify JWT token
                    $body = Get-Content -Raw -Path $request.InputStream
                    $tokenData = $body | ConvertFrom-Json
                    $isValid = Verify-JwtToken -token $tokenData.token
                    if ($isValid) {
                        $responseContent = '{"status": "Token is valid"}'
                        $response.StatusCode = 200
                    } else {
                        $responseContent = '{"status": "Token is invalid"}'
                        $response.StatusCode = 401
                    }
                } elseif ($request.RawUrl -eq "/encrypt") {
                    # Encrypt data
                    $body = Get-Content -Raw -Path $request.InputStream
                    $data = $body | ConvertFrom-Json
                    $encryptedData = Encrypt-Data -data $data.plaintext
                    $responseContent = '{"encrypted_data": "' + $encryptedData + '"}'
                    $response.StatusCode = 200
                } elseif ($request.RawUrl -eq "/decrypt") {
                    # Decrypt data
                    $body = Get-Content -Raw -Path $request.InputStream
                    $data = $body | ConvertFrom-Json
                    $decryptedData = Decrypt-Data -encryptedData $data.encrypted_data
                    $responseContent = '{"decrypted_data": "' + $decryptedData + '"}'
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
Write-LogMessage "Security and Privacy Agent stopped." "INFO"
