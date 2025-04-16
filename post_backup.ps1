$serverFolder = "C:\Path\to\backup" # this folder is the one getting copied
$backupFolder = "C:\Path\to\backup" # this folder is the save file location

$foldersToBackup = @("world", "world_nether", "world_the_end") # folders to back up
# files to back up:
$filesToBackup = @("bukkit.yml", "server.properties", "spigot.yml", "serverstart.bat", "serverteststart.bat", "usercache.json", ".mc-health.env", ".rcon-cli.env", ".rcon-cli.yaml", "wepif.yml", "ops.json", "banned-ips.json", "banned-players.json", "commands.yml", "server-icon.png")

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$tempBackupRoot = "$backupFolder\temp_post_$timestamp"
$serverBackupFolder = Join-Path $tempBackupRoot "Server"
$logsBackupFolder = Join-Path $tempBackupRoot "Logs"
$logFilePath = Join-Path $logsBackupFolder "backup_log.txt"
$zipFilePath = "$backupFolder\post_backup_$timestamp.zip"

New-Item -ItemType Directory -Path $logsBackupFolder -Force | Out-Null
New-Item -ItemType Directory -Path $serverBackupFolder -Force | Out-Null
New-Item -ItemType File -Path $logFilePath -Force | Out-Null

function Write-Log {
    param ([string]$message)
    if ($logFilePath) {
        $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        try {
            "[$timeStamp] $message" | Out-File -Append -FilePath $logFilePath
        } catch {
            Write-Host "ERROR Logging: $($_.Exception.Message)"
        }
    }
}

Write-Log "Post-back-up started on $timestamp"

foreach ($folder in $foldersToBackup) {
    $source = Join-Path $serverFolder $folder
    $dest = Join-Path $serverBackupFolder $folder
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Recurse
        Write-Log "Map '$folder' copied."
    } else {
        Write-Log "Map '$folder' not found."
    }
}

foreach ($file in $filesToBackup) {
    $source = Join-Path $serverFolder $file
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $serverBackupFolder
        Write-Log "File '$file' copied."
    } else {
        Write-Log "File '$file' not found."
    }
}

$sourcePlugins = Join-Path $serverFolder "plugins"
$destPlugins = Join-Path $serverBackupFolder "plugins"
if (Test-Path $sourcePlugins) {
    Get-ChildItem -Path $sourcePlugins -Recurse -File | Where-Object {
        $_.Extension -ne ".jar" -and -not ($_.FullName -like "*\Test\*")
    } | ForEach-Object {
        $relativePath = $_.FullName.Substring($sourcePlugins.Length).TrimStart('\')
        $targetPath = Join-Path $destPlugins $relativePath
        $targetDir = Split-Path $targetPath
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        Copy-Item -Path $_.FullName -Destination $targetPath -Force
        Write-Log "Copied: plugins\$relativePath"
    }
    Write-Log "Copied folder Plugins without .jar and/or 'Test' folder."
} else {
    Write-Log "'Plugins' not found."
}

Write-Log "Files copied, zipping..."
$logFilePath = $null

Compress-Archive -Path "$tempBackupRoot\*" -DestinationPath $zipFilePath
Write-Host "Server Saved: $zipFilePath"

Remove-Item -Path $tempBackupRoot -Recurse -Force -ErrorAction Continue

$existingBackups = Get-ChildItem -Path $backupFolder -Filter "post_backup_*.zip" | Sort-Object LastWriteTime
if ($existingBackups.Count -gt 9) {
    $oldest = $existingBackups | Select-Object -First 1
    Remove-Item -Path $oldest.FullName -Force
    Write-Host "Back-up deleted: $($oldest.Name)"
}
