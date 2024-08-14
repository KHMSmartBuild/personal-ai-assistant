# Variables
$BackupDir = "C:\backups"
$Date = Get-Date -Format "yyyyMMddHHmmss"
$BackupFile = "$BackupDir\postgres_backup_$Date.sql"

# Create backup directory if it doesn't exist
if (-Not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir
}

# Backup command
docker exec -t postgres pg_dumpall -c -U user | Out-File -FilePath $BackupFile -Encoding utf8

Write-Host "Backup completed: $BackupFile"
