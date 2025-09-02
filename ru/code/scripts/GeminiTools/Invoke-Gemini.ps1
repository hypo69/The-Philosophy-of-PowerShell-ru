#requires -Version 7.2

# =================================================================================
# GeminiTools.psm1 — Модуль PowerShell для интеграции с Google Gemini CLI
# PowerShell >= 7.2
# Автор: hypo69
# Дата создания: 20/08/2025
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

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# --- НАЧАЛО БЛОКА: ОПРЕДЕЛЕНИЕ ФУНКЦИЙ МОДУЛЯ ---

function Invoke-Gemini {
    <#
    .SYNOPSIS
        Универсальный командлет для взаимодействия с Google Gemini CLI.
    .DESCRIPTION
        Работает в трех режимах:
        1. Интерактивный чат (без параметров): Запускает интерактивный чат с Gemini в консоли.
        2. Прямой запрос (-Prompt): Отправляет один текстовый промпт и получает ответ.
        3. Специализированный режим (-Mode): Запускает предопределенные интерактивные сценарии.
           На данный момент доступен режим 'Chemistry' для запуска справочника химика.
    .PARAMETER Prompt
        Текстовый запрос, который вы хотите отправить в Gemini.
    .PARAMETER AsJson
        Если указан, командлет попросит Gemini вернуть ответ в формате JSON и преобразует его в объект PowerShell.
    .PARAMETER Mode
        Запускает командлет в специальном интерактивном режиме. Доступные значения: 'Chemistry'.
    .PARAMETER Interactive
        Служебный параметр для активации интерактивного режима по умолчанию.
    .EXAMPLE
        PS C:\> Invoke-Gemini
        # Запускает интерактивный чат, пока пользователь не введет 'exit' или 'выход'.

    .EXAMPLE
        PS C:\> Invoke-Gemini -Prompt "Напиши PowerShell-скрипт для пинга google.com"
        # Отправляет один запрос и возвращает ответ от ИИ.

    .EXAMPLE
        PS C:\> Invoke-Gemini -Mode Chemistry
        # Запускает интерактивный справочник химика, который использует Out-ConsoleGridView.
    .NOTES
        Для работы этого модуля требуется, чтобы Google Gemini CLI был установлен
        и доступен в системной переменной PATH.
        Для режима 'Chemistry' в папке модуля должен находиться файл 'Chemistry.GEMINI.md'.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param(
        # Набор параметров для прямого запроса
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Prompt')]
        [string]$Prompt,

        [Parameter(ParameterSetName = 'Prompt')]
        [switch]$AsJson,
        
        # Набор параметров для специальных режимов
        [Parameter(Mandatory = $true, ParameterSetName = 'Mode')]
        [ValidateSet('Chemistry')]
        [string]$Mode,

        # Набор параметров для интерактивного режима (по умолчанию)
        [Parameter(Mandatory = $false, ParameterSetName = 'Interactive')]
        [switch]$Interactive
    )

    # Внутренняя функция для отправки запроса, чтобы не дублировать код
    function _Invoke-GeminiInternal {
        param([string]$InternalPrompt, [switch]$InternalAsJson)
        
        try { $geminiCommand = Get-Command gemini -ErrorAction Stop } catch { Write-Error "Команда 'gemini' не найдена."; return }

        $finalPrompt = $InternalPrompt
        if ($InternalAsJson) {
            $finalPrompt = "$InternalPrompt. Ответь ТОЛЬКО валидным JSON, без дополнительного текста или markdown-разметки."
        }
        
        $rawOutput = & $geminiCommand.Source -p $finalPrompt 2>&1
        if (-not $?) { Write-Warning "Команда gemini завершилась с ошибкой."; $rawOutput | ForEach-Object { Write-Warning $_.ToString() }; return }
        $fullOutput = $rawOutput -join [Environment]::NewLine
        
        if ($InternalAsJson) {
            $jsonMatch = $fullOutput | Select-String -Pattern '(?s)({.*})|(\[.*\])'; if ($jsonMatch) { try { return $jsonMatch.Matches[0].Value | ConvertFrom-Json } catch { Write-Warning "Не удалось преобразовать ответ Gemini в JSON."; return $fullOutput } } else { Write-Warning "В ответе Gemini не найдена JSON-структура."; return $fullOutput }
        }
        
        return ($fullOutput -replace '(?s)```[a-zA-Z]*\r?\n(.*?)\r?\n```', '$1').Trim()
    }

    # Основной переключатель режимов
    switch ($PSCmdlet.ParameterSetName) {
        'Prompt' {
            return _Invoke-GeminiInternal -InternalPrompt $Prompt -InternalAsJson $AsJson
        }

        'Mode' {
            if ($Mode -eq 'Chemistry') {
                # Загрузка промпта из файла
                $promptFilePath = Join-Path $PSScriptRoot "Chemistry.GEMINI.md"
                if (-not (Test-Path $promptFilePath)) {
                    Write-Error "Файл с инструкциями не найден по пути: $promptFilePath"
                    return
                }
                $systemPrompt = Get-Content -Path $promptFilePath -Raw
                
                Write-Host "Запуск интерактивного справочника химика..." -ForegroundColor Yellow
                while ($true) {
                    $category = Read-Host "`nВведите категорию элементов (например, 'благородные газы') или 'выход'"
                    if ($category -eq 'выход' -or [string]::IsNullOrWhiteSpace($category)) { break }
                    
                    $chemPrompt = "$systemPrompt`n`nЗапрос пользователя: '$category'"
                    Write-Host "`nЗапрашиваю список у Gemini..." -ForegroundColor Cyan
                    
                    $elements = _Invoke-GeminiInternal -InternalPrompt $chemPrompt -InternalAsJson
                    
                    if ($elements) {
                        $selectedElement = $elements | Out-ConsoleGridView -Title "Элементы категории '$category'" -OutputMode Single
                        
                        if ($selectedElement) {
                            $factsPrompt = "Расскажи 3 самых интересных факта об элементе '$($selectedElement.name)' (символ $($selectedElement.symbol))."
                            Write-Host "`nЗапрашиваю интересные факты..." -ForegroundColor Cyan
                            $interestingFacts = _Invoke-GeminiInternal -InternalPrompt $factsPrompt
                            Write-Host "`n--- Факты от Gemini ---`n$interestingFacts"
                        }
                    }
                    else { Write-Warning "Не удалось получить данные от Gemini." }
                }
                Write-Host "`nСправочник закрыт." -ForegroundColor Yellow
            }
        }
        
        'Interactive' {
            Write-Host "Запуск интерактивного чата с Gemini. Введите 'exit' или 'выход' для завершения." -ForegroundColor Yellow
            while($true) {
                $chatPrompt = Read-Host "PS Gemini>"
                if ($chatPrompt -in ('exit', 'выход') -or [string]::IsNullOrWhiteSpace($chatPrompt)) { break }
                $response = _Invoke-GeminiInternal -InternalPrompt $chatPrompt
                Write-Host "`n$response`n" -ForegroundColor Green
            }
            Write-Host "Интерактивный чат завершен."
        }
    }
}

# --- КОНЕЦ БЛОКА: ОПРЕДЕЛЕНИЕ ФУНКЦИЙ МОДУЛЯ ---

# ЕСЛИ МОДУЛ, то экспортируем нашу функцию, чтобы она была видна при импорте модуля
# Export-ModuleMember -Function Invoke-Gemini