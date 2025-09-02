# =================================================================================
# 5. мониторинг системы.ps1 — Скрипт мониторинга ресурсов
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Проверяет текущее использование ЦП и ОЗУ, затем выводит результат в консоль.

.DESCRIPTION
    Этот скрипт проверяет текущее использование процессора и оперативной памяти, а затем выводит результат в удобочитаемом формате. Полезен для быстрой проверки загрузки системы, не открывая Диспетчер задач.

.EXAMPLE
    PS C:\> .\5. мониторинг системы.ps1
    # Запускает скрипт мониторинга ресурсов.
#>

# Get-WmiObject -Query - это удобный инструмент для получения данных
# о производительности системы.

Write-Host "--- Мониторинг системы ---" -ForegroundColor Green

# Получаем информацию об использовании процессора
$cpu = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
Write-Host "Загрузка ЦП: $cpu %" -ForegroundColor Yellow

# Получаем информацию об использовании оперативной памяти
$ram = Get-WmiObject Win32_OperatingSystem
$totalRam = [math]::Round($ram.TotalVisibleMemorySize / 1KB, 2)
$freeRam = [math]::Round($ram.FreePhysicalMemory / 1KB, 2)
$usedRam = [math]::Round(($totalRam - $freeRam), 2)
$usedRamPercentage = [math]::Round(($usedRam / $totalRam) * 100, 2)

Write-Host "Всего ОЗУ: $totalRam МБ" -ForegroundColor Cyan
Write-Host "Свободно ОЗУ: $freeRam МБ" -ForegroundColor Cyan
Write-Host "Использовано ОЗУ: $usedRam МБ ($usedRamPercentage %)" -ForegroundColor Cyan

Write-Host "------------------------" -ForegroundColor Green
