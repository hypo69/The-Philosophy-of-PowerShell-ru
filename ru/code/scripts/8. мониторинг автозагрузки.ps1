# =================================================================================
# 8. мониторинг автозагрузки.ps1 — Скрипт проверки автозагрузки
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Проверяет все места автозагрузки в Windows: ключи реестра, папки автозагрузки, планировщик задач и службы с автоматическим запуском, выводя полный список найденных элементов.

.DESCRIPTION
    Этот скрипт можно использовать для быстрого аудита того, что запускается вместе с системой. Полезен для диагностики замедления загрузки системы или проверки на наличие нежелательного ПО в автозапуске.

.EXAMPLE
    PS C:\> .\8. мониторинг автозагрузки.ps1
    # Запускает скрипт проверки автозагрузки.
#>

Write-Host "--- Аудит автозагрузки системы ---" -ForegroundColor Green

# 1. Проверка ключей реестра
Write-Host "`nПрограммы в реестре:`n" -ForegroundColor Yellow

$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Get-ItemProperty -Path $path | ForEach-Object {
            $name = $_.PSChildName
            $value = $_.$name
            if ($value) {
                Write-Host "  - $name: $value (Путь: $path)" -ForegroundColor Cyan
            }
        }
    }
}

# 2. Проверка папок автозагрузки
Write-Host "`nПрограммы в папках 'Автозагрузка':`n" -ForegroundColor Yellow

$startupPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($path in $startupPaths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path | ForEach-Object {
            Write-Host "  - $($_.Name) (Путь: $($_.FullName))" -ForegroundColor Cyan
        }
    }
}

# 3. Проверка запланированных задач
Write-Host "`nЗадачи в планировщике, запускаемые при старте/входе:`n" -ForegroundColor Yellow

Get-ScheduledTask | Where-Object { $_.State -eq 'Ready' -and ($_.Triggers.Enabled -contains $true -and ($_.Triggers.GetType().Name -eq "logontrigger" -or $_.Triggers.GetType().Name -eq "boottrigger")) } | ForEach-Object {
    Write-Host "  - $($_.TaskName) (Действие: $($_.Actions.Execute))" -ForegroundColor Cyan
}

# 4. Проверка служб с типом запуска "Автоматически"
Write-Host "`nСлужбы с автоматическим запуском:`n" -ForegroundColor Yellow

Get-Service | Where-Object { $_.StartType -eq "Automatic" -and $_.Status -ne "Running" } | ForEach-Object {
    Write-Host "  - $($_.DisplayName) (Имя: $($_.Name))" -ForegroundColor Yellow
}

Get-Service | Where-Object { $_.StartType -eq "Automatic" -and $_.Status -eq "Running" } | ForEach-Object {
    Write-Host "  - $($_.DisplayName) (Имя: $($_.Name))" -ForegroundColor Green
}

Write-Host "`n--- Аудит завершён ---" -ForegroundColor Green
