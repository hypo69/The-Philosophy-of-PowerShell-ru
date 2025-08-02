function Backup-FolderToZip {
    param([string]$SourcePath, [string]$DestinationPath)
    if (-not (Test-Path $SourcePath)) { Write-Error "Исходная папка не найдена."; return }
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $archiveFileName = "Backup_{0}_{1}.zip" -f (Split-Path $SourcePath -Leaf), $timestamp
    $fullArchivePath = Join-Path $DestinationPath $archiveFileName
    if (-not (Test-Path $DestinationPath)) { New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null }
    Compress-Archive -Path "$SourcePath\*" -DestinationPath $fullArchivePath -Force
    Write-Host "Резервное копирование завершено: $fullArchivePath" -ForegroundColor Green
}