# =================================================================================
# Find-Spec.ps1
# Специализированный AI-поисковик спецификаций по SKU или модели.
# Автор: hypo69
# Дата создания: 20/08/2025
# =================================================================================
<#
.SYNOPSIS
    Утилита для быстрого поиска технических характеристик по названию продукта.
.DESCRIPTION
    Просто введите название продукта, его модель или артикул (SKU).
    Скрипт использует Gemini AI для поиска спецификаций в интернете и выводит
    их в удобной интерактивной таблице. Позволяет выбирать элементы из таблицы
    для последующих уточняющих запросов (например, для сравнения).
    
    Рабочие файлы хранятся в директории .gemini:
    - Системный промпт: .\.gemini\GEMINI.md
    - Файл помощи:      .\.gemini\ShowHelp.md
    - История чата:   .\.gemini\.chat_history\
.PARAMETER Model
    Позволяет выбрать модель: 'gemini-2.5-flash' (быстрая, по умолчанию) или 'gemini-2.5-pro' (более мощная).
.EXAMPLE
    .\Find-Spec.ps1
    # Запускает утилиту. Далее просто введите в консоль:
    # > Gigabyte A520M K V2
    # > schneider A9R212240
.NOTES
    Требуется, чтобы Gemini CLI был установлен и доступен в системной переменной PATH.
    Командлет Out-ConsoleGridView доступен в PowerShell 7+.
#>
[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Выберите модель: 'gemini-2.5-flash' (по умолчанию) или 'gemini-2.5-pro'.")]
    [ValidateSet('gemini-2.5-flash', 'gemini-2.5-pro')]
    [string]$Model = 'gemini-2.5-flash'
)

# --- Шаг 1: Настройка ---
$env:GEMINI_API_KEY = "AIzaSyCY8Nk46H8v3Rt4b02oMLU7gDbqT1xU6wU"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
# ---  ---
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
# --- КОНЕЦ ИЗМЕНЕНИЯ ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName


# --- ФУНКЦИИ ---
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}

function Show-History {
    if (-not (Test-Path $historyFilePath)) { Write-Host "История текущей сессии пуста." -ForegroundColor Yellow; return }
    Write-Host "`n--- История текущей сессии ---" -ForegroundColor Cyan; Get-Content -Path $historyFilePath; Write-Host "------------------------------------`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $historyFilePath) {
        try {
            Remove-Item -Path $historyFilePath -Force -ErrorAction Stop
            Write-Host "История текущей сессии ($historyFileName) была удалена." -ForegroundColor Yellow
        }
        catch { Write-Warning "Не удалось удалить файл истории: $_" }
    }
    else { Write-Host "История текущей сессии пуста, удалять нечего." -ForegroundColor Yellow }
}

function Show-Help {
    $helpFilePath = Join-Path $scriptRoot ".gemini/ShowHelp.md"
    if (Test-Path $helpFilePath) {
        $helpText = Get-Content -Path $helpFilePath -Raw
        Write-Host $helpText
    }
    else {
        Write-Warning "Файл справки .gemini/ShowHelp.md не найден."
    }
}

function Command-Handler {
    param([string]$Command)

    switch ($Command) {
        '?' { Show-Help; return 'continue' }
        'history' { Show-History; return 'continue' }
        ('clear', 'clear-history') { Clear-History; return 'continue' }
        'gemini help' {
            Write-Host "`n--- Справка Gemini CLI ---`n" -ForegroundColor Cyan
            & gemini --help
            Write-Host "`n--------------------------`n" -ForegroundColor Cyan
            return 'continue'
        }
        ('exit', 'quit') { return 'break' }
        default {
            return $null
        }
    }
}

function Invoke-GeminiPrompt {
    param([string]$Prompt, [string]$Model)
    try {
        $output = & gemini -m $Model -p $Prompt 2>&1
        if (-not $?) { $output | ForEach-Object { Write-Warning $_.ToString() }; return $null }
        $outputString = ($output -join [Environment]::NewLine).Trim()
        $cleanedOutput = $outputString -replace "(?m)^Data collection is disabled\.`r?`n" , ""
        $cleanedOutput = $cleanedOutput -replace "(?m)^Loaded cached credentials\.`r?`n", ""
        return $cleanedOutput.Trim()
    }
    catch { Write-Error "Критическая ошибка при вызове Gemini CLI: $_"; return $null }
}

# --- Отображение выбранных данных в консольной таблице ---
function Show-SelectionTable {
    param([array]$SelectedData)
    
    if ($null -eq $SelectedData -or $SelectedData.Count -eq 0) {
        return
    }
    
    Write-Host "`n--- ВЫБРАННЫЕ ДАННЫЕ ---" -ForegroundColor Yellow
    
    # Если выбран только один элемент, обернуть в массив для единообразной обработки
    if ($SelectedData -isnot [array]) {
        $SelectedData = @($SelectedData)
    }
    
    # Получить все уникальные свойства из выбранных объектов
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # Если есть свойства, показать таблицу
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    }
    else {
        # Если нет определенных свойств, показать как простой список
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
    
    Write-Host "-------------------------" -ForegroundColor Yellow
    Write-Host "Выбрано элементов: $($SelectedData.Count)" -ForegroundColor Magenta
    Write-Host ""
}


# --- Шаг 2: Проверка окружения ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } catch { Write-Error "Команда 'gemini' не найдена..."; return }
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { Write-Warning "Файл системного промпта .gemini/GEMINI.md не найден. Ответы модели могут быть непредсказуемыми."; }
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { Write-Warning "Файл справки .gemini/ShowHelp.md не найден. Команда '?' не будет работать."; }


# --- Шаг 3: Основная логика ---
Write-Host "AI-поисковик спецификаций. Модель: '$Model'." -ForegroundColor Green
Write-Host "Файл сессии будет сохранен в: $historyFilePath" -ForegroundColor Yellow
Write-Host "Введите 'exit' для выхода или '?' для помощи."
    
$selectionContextJson = $null 
    
while ($true) {
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [Выборка активна] :) > "
    }
    else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    $UserPrompt = Read-Host
        
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }

    if ([string]::IsNullOrWhiteSpace($UserPrompt)) { continue }
    
    Write-Host "Идет поиск и обработка запроса..." -ForegroundColor Gray
        
    $historyContent = ""
    if (Test-Path $historyFilePath) { $historyContent = Get-Content -Path $historyFilePath -Raw -ErrorAction SilentlyContinue }
        
    $fullPrompt = @"
### ИСТОРИЯ ДИАЛОГА (КОНТЕКСТ)
$historyContent
"@
        
    if ($selectionContextJson) {
        $selectionBlock = @"

### ДАННЫЕ ИЗ ВЫБОРКИ (ДЛЯ АНАЛИЗА)
$selectionContextJson
"@
        $fullPrompt += $selectionBlock
        $selectionContextJson = $null 
    }

    $fullPrompt += @"

### НОВАЯ ЗАДАЧА
$UserPrompt
"@

    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
        
    if ($ModelResponse) {
        $jsonToParse = $null
        $jsonPattern = '(?s)```json\s*(.*?)\s*```'
            
        if ($ModelResponse -match $jsonPattern) { $jsonToParse = $matches[1] }
        else { $jsonToParse = $ModelResponse }
            
        try {
            $jsonObject = $jsonToParse | ConvertFrom-Json
            Write-Host "`n--- Gemini (объект JSON) ---`n" -ForegroundColor Green
                
            $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Выберите строки для следующего запроса (OK) или закройте (Cancel)" -OutputMode Multiple
                
            if ($null -ne $gridSelection) {
                Show-SelectionTable -SelectedData $gridSelection
                
                $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
                Write-Host "Выборка сохранена. Добавьте ваш следующий запрос (например, 'сравни их')." -ForegroundColor Magenta
            }
        }
        catch {
            Write-Host $ModelResponse -ForegroundColor Cyan
        }
            
        Add-History -UserPrompt $UserPrompt -ModelResponse $ModelResponse
    }
}

Write-Host "Завершение работы." -ForegroundColor Green