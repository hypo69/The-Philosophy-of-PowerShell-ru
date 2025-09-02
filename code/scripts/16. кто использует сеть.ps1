# =================================================================================
# 16. кто использует сеть.ps1 — Скрипт мониторинга сетевых подключений
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Выводит список всех приложений, которые в данный момент используют сеть, с указанием их имени, локального и удалённого IP-адресов, а также локального и удалённого портов.

.DESCRIPTION
    Этот скрипт использует командлет Get-NetTCPConnection для получения информации о текущих сетевых соединениях и Get-Process для сопоставления этих соединений с запущенными приложениями. Полезен для выявления программ, активно использующих сетевое соединение.

.EXAMPLE
    PS C:\> .\16. кто использует сеть.ps1
    # Запускает скрипт мониторинга сетевых подключений.
#>

Write-Host "--- Мониторинг сетевых подключений ---" -ForegroundColor Green
Write-Host "Получение списка активных сетевых соединений..." -ForegroundColor Yellow

# Получаем все активные TCP-соединения
$connections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -or $_.State -eq 'SynSent' }

# Создаём пустой массив для хранения информации
$networkApps = @()

if ($connections.Count -eq 0) {
    Write-Host "`nАктивных сетевых соединений не найдено." -ForegroundColor Red
} else {
    foreach ($conn in $connections) {
        # Получаем информацию о процессе по его PID
        $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue

        # Если процесс найден, добавляем его в массив
        if ($process) {
            $networkApps += [PSCustomObject]@{
                ProcessName = $process.ProcessName
                LocalAddress = $conn.LocalAddress
                LocalPort = $conn.LocalPort
                RemoteAddress = $conn.RemoteAddress
                RemotePort = $conn.RemotePort
                State = $conn.State
            }
        }
    }
}

# Сортируем по имени процесса и выводим результат в виде таблицы
if ($networkApps.Count -gt 0) {
    Write-Host "`nНайденные приложения, использующие сеть:`n" -ForegroundColor Cyan
    $networkApps | Sort-Object ProcessName | Format-Table -AutoSize
}

Write-Host "`n--- Мониторинг завершён ---" -ForegroundColor Green
