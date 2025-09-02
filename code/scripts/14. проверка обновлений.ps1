# =================================================================================
# 14. проверка обновлений.ps1 — Скрипт для проверки и установки обновлений Windows
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Проверяет наличие доступных обновлений Windows и предлагает их установить.

.DESCRIPTION
    Этот скрипт использует модуль PSWindowsUpdate для проверки наличия доступных обновлений Windows,
    выводит их список, а затем, если обновления найдены, предлагает пользователю установить их.

.EXAMPLE
    PS C:\> .\14. проверка обновлений.ps1
    # Запускает скрипт для проверки и установки обновлений.
#>

# Requires -Module PSWindowsUpdate

Write-Host "--- Проверка и установка обновлений Windows ---" -ForegroundColor Green

# 1. Проверка наличия доступных обновлений
Write-Host "`nПроверка доступных обновлений..." -ForegroundColor Yellow
$availableUpdates = Get-WUList

if ($availableUpdates.Count -eq 0) {
    Write-Host "`nОбновления не найдены. Ваша система актуальна." -ForegroundColor Green
} else {
    Write-Host "`nНайдены следующие обновления:" -ForegroundColor Yellow
    $availableUpdates | Format-Table -AutoSize

    # 2. Предложение установить обновления
    $installChoice = Read-Host "`nУстановить найденные обновления? (Y/N)"

    if ($installChoice -eq 'Y' -or $installChoice -eq 'y') {
        Write-Host "`nЗапуск установки обновлений..." -ForegroundColor Yellow
        
        # Загрузка и установка обновлений
        Install-WindowsUpdate -AcceptAll -AutoReboot
        
        Write-Host "`nПроцесс установки завершён. Перезагрузка может потребоваться." -ForegroundColor Green
    } else {
        Write-Host "`nУстановка отменена. Обновления не будут установлены." -ForegroundColor Red
    }
}

Write-Host "`n--- Завершено ---" -ForegroundColor Green
