# =================================================================================
# 19. SMART.ps1 — Скрипт проверки S.M.A.R.T. статуса дисков
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Проверяет S.M.A.R.T. статус всех физических дисков в системе, выводя их модель, серийный номер и общий статус здоровья.

.DESCRIPTION
    Этот скрипт получает общую информацию о состоянии S.M.A.R.T. для всех физических дисков в системе. Полезен для предотвращения потери данных и предсказания возможного сбоя диска.

.EXAMPLE
    PS C:\> .\19. SMART.ps1
    # Запускает скрипт проверки S.M.A.R.T. статуса дисков.
#>

Write-Host "--- Проверка S.M.A.R.T. статуса дисков ---" -ForegroundColor Green

# Получаем все физические диски в системе
$disks = Get-PhysicalDisk

if (-not $disks) {
    Write-Host "Физические диски не найдены." -ForegroundColor Red
    return
}

# Перебираем каждый диск и выводим его S.M.A.R.T. статус
foreach ($disk in $disks) {
    Write-Host "`nДиск: $($disk.FriendlyName)" -ForegroundColor Yellow
    Write-Host "  Модель: $($disk.Model)" -ForegroundColor Cyan
    Write-Host "  Серийный номер: $($disk.SerialNumber)" -ForegroundColor Cyan

    # Получаем информацию о надёжности и S.M.A.R.T.
    $reliability = $disk | Get-StorageReliabilityCounter

    # Проверка общего статуса здоровья
    if ($disk.HealthStatus -eq "OK") {
        Write-Host "  Статус здоровья: $($disk.HealthStatus)" -ForegroundColor Green
    } elseif ($disk.HealthStatus -eq "Warning" -or $disk.HealthStatus -eq "Caution") {
        Write-Host "  Статус здоровья: $($disk.HealthStatus)" -ForegroundColor Yellow
        Write-Host "  ВНИМАНИЕ: Обнаружены потенциальные проблемы с диском. Рекомендуется создать резервную копию данных." -ForegroundColor Yellow
    } else {
        Write-Host "  Статус здоровья: $($disk.HealthStatus)" -ForegroundColor Red
        Write-Host "  ОШИБКА: Диск может выйти из строя. Немедленно создайте резервную копию и замените диск!" -ForegroundColor Red
    }

    # Вывод некоторых ключевых атрибутов S.M.A.R.T.
    Write-Host "  Ключевые показатели S.M.A.R.T.:" -ForegroundColor Cyan
    Write-Host "    Температура: $($reliability.Temperature) °C" -ForegroundColor Magenta
    Write-Host "    Количество часов работы: $($reliability.PowerOnHours) ч" -ForegroundColor Magenta
    Write-Host "    Ошибки чтения: $($reliability.ReadErrorsCorrected)" -ForegroundColor Magenta
    Write-Host "    Ошибки записи: $($reliability.WriteErrorsCorrected)" -ForegroundColor Magenta
}

Write-Host "`n--- Проверка S.M.A.R.T. завершена ---" -ForegroundColor Green
