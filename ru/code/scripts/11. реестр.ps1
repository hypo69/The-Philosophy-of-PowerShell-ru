# =================================================================================
# 11. реестр.ps1 — Скрипт для работы с реестром Windows
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Демонстрирует различные способы работы с реестром Windows с помощью PowerShell, включая проверку автозагрузки, истории USB, настроек безопасности, установленных программ и сетевых настроек.

.DESCRIPTION
    PowerShell является мощным инструментом для работы с реестром Windows. Этот скрипт показывает несколько полезных вещей, которые можно проверить в реестре для аудита безопасности и стабильности системы.

.EXAMPLE
    PS C:\> .\11. реестр.ps1
    # Запускает скрипт для работы с реестром.
#>

# 1. Проверка программ автозагрузки (Startup)
Write-Host "\n--- 1. Проверка программ автозагрузки (Startup) ---" -ForegroundColor Yellow
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

# 2. Аудит истории USB-устройств
Write-Host "\n--- 2. Аудит истории USB-устройств ---" -ForegroundColor Yellow
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*"

# 3. Проверка настроек системы и безопасности
Write-Host "\n--- 3. Проверка настроек системы и безопасности ---" -ForegroundColor Yellow
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System").EnableLUA

# 4. Инвентаризация установленных программ
Write-Host "\n--- 4. Инвентаризация установленных программ ---" -ForegroundColor Yellow
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion

# 5. Проверка сетевых настроек
Write-Host "\n--- 5. Проверка сетевых настроек ---" -ForegroundColor Yellow
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\*"
