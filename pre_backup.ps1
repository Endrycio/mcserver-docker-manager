$serverFolder = "C:\Path\to\backup" # this folder is the one getting copied
$backupFolder = "C:\Path\to\backup" # this folder is the save file location

$foldersToBackup = @("world", "world_nether", "world_the_end") # folders to back up
# files to back up:
$filesToBackup = @("bukkit.yml", "server.properties", "spigot.yml", "serverstart.bat", "serverteststart.bat", "usercache.json", ".mc-health.env", ".rcon-cli.env", ".rcon-cli.yaml", "wepif.yml", "ops.json", "banned-ips.json", "banned-players.json", "commands.yml", "server-icon.png")

$timestamp      = Get-Date -Format "yyyyMMdd_HHmmss"
$tempBackupRoot = "$backupFolder\temp_$timestamp"
$serverBackup   = Join-Path $tempBackupRoot "Server"
$zipFile        = "$backupFolder\pre_backup_$timestamp.zip"

New-Item -ItemType Directory -Path $serverBackup -Force | Out-Null

foreach ($folder in $foldersToBackup) {
    $src = Join-Path $serverFolder $folder
    $dst = Join-Path $serverBackup $folder
    if (Test-Path $src) { Copy-Item $src -Destination $dst -Recurse }
}

foreach ($file in $filesToBackup) {
    $src = Join-Path $serverFolder $file
    if (Test-Path $src) { Copy-Item $src -Destination $serverBackup }
}

$srcPlugins = Join-Path $serverFolder "plugins"
$dstPlugins = Join-Path $serverBackup "plugins"
if (Test-Path $srcPlugins) {
    Get-ChildItem -Path $srcPlugins -Recurse -File | Where-Object {
        $_.Extension -ne ".jar" -and -not ($_.FullName -like "*\Test\*")
    } | ForEach-Object {
        $relPath   = $_.FullName.Substring($srcPlugins.Length).TrimStart('\')
        $dstPath   = Join-Path $dstPlugins $relPath
        $dstFolder = Split-Path $dstPath
        if (-not (Test-Path $dstFolder)) {
            New-Item -ItemType Directory -Path $dstFolder -Force | Out-Null
        }
        Copy-Item $_.FullName -Destination $dstPath -Force
    }
}

Compress-Archive -Path "$tempBackupRoot\*" -DestinationPath $zipFile
Remove-Item $tempBackupRoot -Recurse -Force -ErrorAction SilentlyContinue

$existingBackups = Get-ChildItem -Path $backupFolder -Filter "pre_backup_*.zip" | Sort-Object LastWriteTime
if ($existingBackups.Count -gt 9) {
    $oldest = $existingBackups | Select-Object -First 1
    Remove-Item -Path $oldest.FullName -Force
}
