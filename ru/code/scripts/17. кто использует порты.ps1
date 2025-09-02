# =================================================================================
# 17. кто использует порты.ps1 — Скрипт проверки состояния портов
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Выводит список всех прослушиваемых TCP-портов и процессов, которые их используют, а затем проверяет доступность нескольких популярных портов.

.DESCRIPTION
    Этот скрипт даст вам полную картину состояния портов в вашей системе. Он полезен для выявления занятых портов и проверки доступности других портов для внешних соединений.

.EXAMPLE
    PS C:\> .\17. кто использует порты.ps1
    # Запускает скрипт проверки состояния портов.
#>

Write-Host "--- Мониторинг прослушиваемых и доступных портов ---" -ForegroundColor Green

# 1. Проверка прослушиваемых (открытых и занятых) портов
Write-Host "`nЧасть 1: Список прослушиваемых портов (открытых и занятых):`n" -ForegroundColor Yellow

$listenPorts = Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' }

if ($listenPorts.Count -eq 0) {
    Write-Host "  Прослушиваемых портов не найдено." -ForegroundColor Green
} else {
    $listenPorts | ForEach-Object {
        $process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        $processName = if ($process) { $process.ProcessName } else { "N/A" }
        
        Write-Host "  - Порт $($_.LocalPort) | Процесс: $processName | Адрес: $($_.LocalAddress)" -ForegroundColor Cyan
    }
}

# 2. Проверка доступности популярных, но не занятых портов
Write-Host "`n`nЧасть 2: Проверка доступности портов (свободных, но потенциально открытых):`n" -ForegroundColor Yellow

# Список портов для проверки. Можно добавить свои порты.
$portsToCheck = 22, 80, 443, 8080

foreach ($port in $portsToCheck) {
    Write-Host "  Проверка порта $port..." -ForegroundColor Cyan
    
    # Test-NetConnection сработает, если порт открыт и доступен.
    $testResult = Test-NetConnection -ComputerName localhost -Port $port -InformationLevel "Detailed" -ErrorAction SilentlyContinue

    if ($testResult -and $testResult.TcpTestSucceeded) {
        Write-Host "  - Порт $port открыт и доступен." -ForegroundColor Red
        Write-Host "    Подключение успешно к $($testResult.RemoteAddress):$($testResult.RemotePort)" -ForegroundColor Magenta
    } else {
        Write-Host "  - Порт $port закрыт или недоступен." -ForegroundColor Green
    }
}

Write-Host "`n--- Мониторинг завершён ---" -ForegroundColor Green
