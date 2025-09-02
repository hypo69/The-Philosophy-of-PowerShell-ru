# =================================================================================
# 7. установленные приложения.ps1 — Скрипт инвентаризации установленных приложений
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Получает полный список всех установленных программ, включая их версии и даты установки, из реестра Windows.

.DESCRIPTION
    Этот скрипт просканирует реестр Windows, чтобы найти все установленные программы, и представит их в удобном для чтения виде. Полезен для аудита лицензий, проверки на наличие нежелательных программ или просто для получения полного списка всего, что установлено на компьютере.

.EXAMPLE
    PS C:\> .\7. установленные приложения.ps1
    # Запускает скрипт инвентаризации установленных приложений.
#>

Write-Host "--- Список установленных приложений ---" -ForegroundColor Green

# Определяем ключи реестра для поиска
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Создаём пустой массив для хранения данных о приложениях
$applications = @()

# Перебираем ключи реестра
foreach ($path in $regPaths) {
    if (Test-Path $path) {
        $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Get-ItemProperty -ErrorAction SilentlyContinue
        
        foreach ($item in $items) {
            # Фильтруем, чтобы исключить элементы, не являющиеся приложениями
            if ($item.DisplayName -and $item.SystemComponent -ne 1) {
                $appName = $item.DisplayName
                $appVersion = $item.DisplayVersion
                $publisher = $item.Publisher
                $installDate = $item.InstallDate

                # Добавляем информацию в массив
                $applications += [PSCustomObject]@{
                    Name = $appName
                    Version = $appVersion
                    Publisher = $publisher
                    InstallDate = $installDate
                }
            }
        }
    }
}

# Сортируем и выводим список
$applications | Sort-Object Name | Format-Table -AutoSize

Write-Host "`n--- Инвентаризация завершена ---" -ForegroundColor Green
