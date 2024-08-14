param (
    [string]$BackupFile
)

if (-Not $BackupFile) {
    Write-Host "Usage: .\db_restore.ps1 <backup_file>"
    exit
}

# Restore command
Get-Content $BackupFile | docker exec -i postgres psql -U user -d ai_assistant

Write-Host "Restore completed from: $BackupFile"
