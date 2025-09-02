# =================================================================================
# 6. продвинутый мониторинг системы.ps1 — Скрипт мониторинга производительности и событий
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Собирает данные о производительности ЦП, ОЗУ, дисков за последние 60 секунд и проверяет журнал событий на наличие ошибок, сохраняя результаты в текстовый файл.

.DESCRIPTION
    Этот скрипт не просто показывает текущие значения, а собирает данные, анализирует их и создаёт более подробный отчёт. Он использует Performance Counters для сбора детальной информации и проверяет Журнал событий Windows на наличие ошибок.

.EXAMPLE
    PS C:\> .\6. продвинутый мониторинг системы.ps1
    # Запускает скрипт мониторинга производительности и событий.
#>

# Установка пути к файлу отчёта
$reportPath = "C:\PerformanceReports\performance_report.txt"

# Создаём директорию, если она не существует
if (-not (Test-Path $reportPath)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $reportPath)
}

Write-Host "--- Запуск расширенного мониторинга системы ---" -ForegroundColor Green

# 1. Сбор данных о производительности за последние 60 секунд
$cpuData = Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 60
$ramData = Get-Counter -Counter "\Memory\% Committed Bytes In Use" -SampleInterval 1 -MaxSamples 60
$diskData = Get-Counter -Counter "\LogicalDisk(C:)\% Free Space" -SampleInterval 1 -MaxSamples 60

# 2. Формирование отчёта о производительности
$reportContent = "--- Отчёт о производительности (" + (Get-Date) + ") ---`n`n"
$reportContent += "Средняя загрузка ЦП за 60 секунд: " + ([math]::Round($cpuData.CounterSamples | Measure-Object -Property CookedValue -Average).Average, 2) + " %`n"
$reportContent += "Среднее использование ОЗУ за 60 секунд: " + ([math]::Round($ramData.CounterSamples | Measure-Object -Property CookedValue -Average).Average, 2) + " %`n"
$reportContent += "Среднее свободное место на диске C: за 60 секунд: " + ([math]::Round($diskData.CounterSamples | Measure-Object -Property CookedValue -Average).Average, 2) + " %`n"

# 3. Проверка журнала событий Windows на наличие ошибок за последние 24 часа
$eventLogErrors = Get-WinEvent -FilterHashtable @{Logname='System'; Level=2; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue

$reportContent += "`n--- Ошибки в журнале событий (последние 24 часа) ---`n"

if ($eventLogErrors) {
    $eventLogErrors | ForEach-Object {
        $reportContent += "Время: $($_.TimeCreated), Источник: $($_.ProviderName), Сообщение: $($_.Message.Trim().Split("`n")[0])`n"
    }
} else {
    $reportContent += "Ошибок не найдено.`n"
}

# 4. Сохранение отчёта в файл
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8 -Append

Write-Host "Отчёт сохранён в $reportPath" -ForegroundColor Green
