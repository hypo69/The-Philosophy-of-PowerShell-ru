# =================================================================================
# 12. аудит реестра.ps1 — Скрипт аудита реестра
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Выполняет комплексный аудит реестра Windows, проверяя автозагрузку, статус UAC, версию Windows и историю подключенных USB-устройств.

.DESCRIPTION
    Этот скрипт выполняет четыре ключевые проверки: автозагрузка, настройки безопасности (UAC), информация о системе и история USB-устройств. Требует прав администратора.

.EXAMPLE
    PS C:\> .\12. аудит реестра.ps1
    # Запускает скрипт аудита реестра.
#>

Write-Host "--- Комплексный аудит реестра Windows ---" -ForegroundColor Green
Write-Host "Скрипт проверяет ключевые области реестра для получения информации о системе и безопасности." -ForegroundColor Cyan

# 1. Проверка программ в автозагрузке
Write-Host "`n[1] Проверка программ в автозагрузке" -ForegroundColor Yellow
$autoRunPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $autoRunPaths) {
    if (Test-Path -Path $path) {
        Write-Host "  - Проверка ключа: $path" -ForegroundColor Cyan
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            $name = $_.PSChildName
            $value = $_.$name
            if ($value) {
                Write-Host "    - Название: $name" -ForegroundColor Magenta
                Write-Host "      Путь:   $value" -ForegroundColor Magenta
            }
        }
    }
}


# 2. Проверка настроек безопасности (UAC)
Write-Host "`n[2] Проверка настроек безопасности" -ForegroundColor Yellow
$uacStatus = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System").EnableLUA
if ($uacStatus -eq 1) {
    Write-Host "  - UAC (User Account Control): ВКЛЮЧЁН" -ForegroundColor Green
} else {
    Write-Host "  - UAC (User Account Control): ОТКЛЮЧЁН" -ForegroundColor Red
}


# 3. Получение информации о версии Windows
Write-Host "`n[3] Информация о системе" -ForegroundColor Yellow
$osInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
Write-Host "  - Версия ОС: $($osInfo.ProductName) $($osInfo.CurrentVersion)" -ForegroundColor Cyan
Write-Host "  - Сборка ОС: $($osInfo.BuildLabEx)" -ForegroundColor Cyan


# 4. Аудит истории подключений USB-устройств
Write-Host "`n[4] История подключений USB-устройств" -ForegroundColor Yellow
Write-Host "  (Требует прав администратора)" -ForegroundColor Red
try {
    $usbDevices = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*"
    if ($usbDevices.Count -gt 0) {
        $usbDevices | ForEach-Object {
            Write-Host "  - Устройство: $($_.PSChildName)" -ForegroundColor Magenta
            Write-Host "    Описание: $($_.FriendlyName)" -ForegroundColor Magenta
        }
    } else {
        Write-Host "  - USB-устройства не найдены в реестре." -ForegroundColor Green
    }
} catch {
    Write-Host "  - Ошибка: Не удалось получить доступ к ключу USB-устройств. Запустите скрипт с правами администратора." -ForegroundColor Red
}


Write-Host "`n--- Аудит завершён ---" -ForegroundColor Green
