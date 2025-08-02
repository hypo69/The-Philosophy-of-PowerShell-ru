# system_monitor.ps1
#requires -Version 5.1

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
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# --- Блок 2: Сбор данных ---
Write-Host "Сбор информации..." -ForegroundColor Green
$processes = Get-Process | Sort-Object CPU -Descending
$services = Get-Service -ErrorAction SilentlyContinue | Group-Object Status | Select-Object Name, Count

# --- Блок 3: Вызов функции для экспорта ---
Export-Results -Processes $processes -Services $services -OutputPath $OutputPath

Write-Host "Отчеты успешно сохранены в папке $OutputPath" -ForegroundColor Magenta