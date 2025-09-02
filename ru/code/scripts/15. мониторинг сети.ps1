# =================================================================================
# 15. мониторинг сети.ps1 — Скрипт мониторинга сети
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Проверяет доступность нескольких ключевых серверов в сети с помощью ping и сообщает о среднем времени отклика, а также собирает статистику сетевых интерфейсов.

.DESCRIPTION
    Этот скрипт можно использовать для проверки доступности сетевых узлов и сбора базовой статистики сетевого трафика. Он идеально подходит для быстрого выявления проблем с сетью.

.EXAMPLE
    PS C:\> .\15. мониторинг сети.ps1
    # Запускает скрипт мониторинга сети.
#>

Write-Host "--- Мониторинг сети ---" -ForegroundColor Green

# 1. Проверка доступности хостов с помощью Test-Connection
$hosts = "google.com", "bing.com", "192.168.1.1" # Замените IP-адрес на свой локальный сервер

Write-Host "`nПроверка доступности хостов:`n"

foreach ($host in $hosts) {
    Write-Host "Пингуем: $host" -ForegroundColor Cyan
    $pingResult = Test-Connection -ComputerName $host -Count 4 -Quiet
    
    if ($pingResult) {
        $averageTime = (Test-Connection -ComputerName $host -Count 4 | Measure-Object -Property ResponseTime -Average).Average
        Write-Host "Узел $host доступен. Среднее время отклика: $([math]::Round($averageTime, 2)) мс." -ForegroundColor Green
    } else {
        Write-Host "Узел $host недоступен." -ForegroundColor Red
    }
}

# 2. Получение статистики по сетевым интерфейсам
Write-Host "`nСетевая статистика:`n"

$networkInterfaces = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" }

if ($networkInterfaces) {
    foreach ($interface in $networkInterfaces) {
        Write-Host "Интерфейс: $($interface.Name)" -ForegroundColor Yellow
        $statistics = Get-NetAdapterStatistics -Name $interface.Name

        Write-Host "  Отправлено байт: $($statistics.BytesSent)" -ForegroundColor Cyan
        Write-Host "  Получено байт: $($statistics.BytesReceived)" -ForegroundColor Cyan
    }
} else {
    Write-Host "Активные сетевые интерфейсы не найдены." -ForegroundColor Red
}

Write-Host "`n--- Мониторинг завершён ---" -ForegroundColor Green
