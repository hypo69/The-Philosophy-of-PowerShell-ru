#requires -Version 5.1

# =================================================================================
# system_monitor.ps1 — Скрипт для создания отчета о состоянии системы
# Windows PowerShell >= 5.1.
# Запускать от имени администратора для полного доступа к службам и процессам.
# Автор: hypo69
# Дата создания: 12/06/2025 
# =================================================================================

# =================================================================================
# ЛИЦЕНЗИЯ (MIT)
# =================================================================================
<#
Copyright (c) 2025 hypo69

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

<#
.SYNOPSIS
    Скрипт для создания отчета о состоянии системы.
.DESCRIPTION
    Собирает информацию о процессах, службах и дисковом пространстве и генерирует отчеты.
.PARAMETER OutputPath
    Путь для сохранения отчетов. По умолчанию 'C:\Temp'.
.EXAMPLE
    .\system_monitor.ps1 -OutputPath "C:\Reports"
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\Temp"
)

#===================================================================
#               ОПРЕДЕЛЕНИЕ ФУНКЦИЙ
#===================================================================

function Export-Results {
    param(
        $Processes,
        $Services,
        $OutputPath
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

    # Экспорт в CSV
    # Добавим проверку, что переменные не пустые, чтобы избежать ошибок
    if ($Processes) {
        $Processes | Select-Object -First 20 | Export-Csv (Join-Path $OutputPath "processes_$timestamp.csv") -NoTypeInformation
    }
    if ($Services) {
        $Services | Export-Csv (Join-Path $OutputPath "services_$timestamp.csv") -NoTypeInformation
    }

    # Создание красивого HTML-отчета
    $htmlReportPath = Join-Path $OutputPath "report_$timestamp.html"
    $processesHtml = $Processes | Select-Object -First 10 Name, Id, CPU | ConvertTo-Html -Fragment -PreContent "<h2>Топ-10 процессов по CPU</h2>"
    $servicesHtml = $Services | ConvertTo-Html -Fragment -PreContent "<h2>Статистика служб</h2>"

    $head = "<title>Отчет о системе</title><style>body{font-family:sans-serif;}table,th,td{border:1px solid #999;border-collapse:collapse;}th,td{padding:5px;}</style>"
    ConvertTo-Html -Head $head -Body "<h1>Отчет о системе от $(Get-Date)</h1> $($processesHtml) $($servicesHtml)" | Out-File $htmlReportPath
}


# ===================================================================
#               ОСНОВНОЙ БЛОК СКРИПТА
# ===================================================================

# --- Блок 1: Подготовка ---
Write-Host "Подготовка к созданию отчета..." -ForegroundColor Cyan
if (!(Test-Path $OutputPath)) {
    # Создаем директорию, если она не существует
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# --- Блок 2: Сбор данных ---
Write-Host "Сбор информации о системе..." -ForegroundColor Green
$processes = Get-Process | Sort-Object CPU -Descending
$services = Get-Service -ErrorAction SilentlyContinue | Group-Object Status | Select-Object Name, Count

# --- Блок 3: Вызов функции для экспорта ---
Write-Host "Экспорт результатов..." -ForegroundColor Cyan
Export-Results -Processes $processes -Services $services -OutputPath $OutputPath

Write-Host "`nОтчеты успешно сохранены в папке $OutputPath" -ForegroundColor Magenta