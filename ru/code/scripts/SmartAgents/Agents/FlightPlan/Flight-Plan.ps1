# =================================================================================
# Flight-Plan.ps1 (Библиотека для модуля SmartAgents)
# Автор: hypo69
# =================================================================================

function Start-FlightPlanAgent {
    [CmdletBinding()]
    param(
        # --- ИСПРАВЛЕНО: Модель по умолчанию теперь 'flash', как вы указали. ---
        [ValidateSet('gemini-2.5-pro', 'gemini-2.5-flash')]
        [string]$Model = 'gemini-2.5-flash',
        [string]$ApiKey
    )
    
    $agentRoot = $PSScriptRoot 
    $Config = New-GeminiConfig -AppName 'AI-планировщик перелетов' -Emoji '✈️' -SessionPrefix 'flight_session' -AgentRoot $agentRoot

    # --- Вложенные функции, специфичные для этого агента ---
    function Show-FlightHelp {
        $helpFilePath = Join-Path $Config.ConfigDir "ShowHelp.md"
        if (Test-Path $helpFilePath) {
            Get-Content -Path $helpFilePath -Raw | Write-Host
        } else {
            Write-Warning "Файл справки не найден: $helpFilePath"
        }
    }

    # --- ИСПРАВЛЕНО: Восстановлено читаемое форматирование ---
    function Show-History {
        param([string]$HistoryFilePath)
        if (-not (Test-Path $HistoryFilePath)) {
            Write-ColoredMessage "История сессии пуста." -Color $Config.Color.Warning
            return
        }
        Get-Content $HistoryFilePath | ForEach-Object {
            $entry = $_ | ConvertFrom-Json
            if ($entry.user) {
                Write-ColoredMessage "USER: $($entry.user)" -Color $Config.Color.Info
            }
            if ($entry.model) {
                Write-ColoredMessage "MODEL: $($entry.model)" -Color 'White'
            }
        }
    }

    # --- ИСПРАВЛЕНО: Восстановлено читаемое форматирование ---
    function Clear-History {
        param([string]$HistoryFilePath)
        if (Test-Path $HistoryFilePath) {
            Remove-Item $HistoryFilePath -Force
        }
        Write-ColoredMessage "История сессии очищена." -Color $Config.Color.Warning
    }
    
    # --- ИСПРАВЛЕНО: Восстановлено читаемое форматирование ---
    function Command-Handler-Flight {
        param([string]$Command, [string]$HistoryFilePath)
        switch ($Command.Trim().ToLower()) {
            '?'         { Show-FlightHelp; return 'continue' }
            'history'   { Show-History -HistoryFilePath $HistoryFilePath; return 'continue' }
            'clear'     { Clear-History -HistoryFilePath $HistoryFilePath; return 'continue' }
            'exit'      { return 'break' }
            'quit'      { return 'break' }
            default     { return $null }
        }
    }

    try {
        $historyFilePath = Initialize-GeminiSession -Config $Config -ApiKey $ApiKey
    } catch {
        Write-ColoredMessage "Ошибка инициализации: $($_.Exception.Message)" -Color $Config.Color.Error
        return
    }

    Write-Host "`nДобро пожаловать в $($Config.AppName)! Модель: '$Model'. Введите '?' для помощи, 'exit' для выхода.`n"
    $selectionContextJson = $null 
    
    while ($true) {
        $promptText = if ($selectionContextJson) { "$($Config.Emoji)AI [Выборка активна] :) > " } else { "$($Config.Emoji)AI :) > " }
        Write-ColoredMessage -Message $promptText -Color $Config.Color.Prompt -NoNewline
        $UserPrompt = Read-Host
        
        $commandResult = Command-Handler-Flight -Command $UserPrompt -HistoryFilePath $historyFilePath
        if ($commandResult -eq 'break') { break }
        if ($commandResult -eq 'continue') { continue }
        if ([string]::IsNullOrWhiteSpace($UserPrompt)) { continue }

        Write-ColoredMessage "Идет поиск маршрутов..." -Color $Config.Color.Processing
        
        $historyContent = if (Test-Path $historyFilePath) { Get-Content -Path $historyFilePath -Raw } else { "" }
        $fullPrompt = "### ИСТОРИЯ`n$historyContent`n"
        if ($selectionContextJson) {
            $fullPrompt += "### ВЫБОРКА`n$selectionContextJson`n"
            $selectionContextJson = $null
        }
        $fullPrompt += "### НОВЫЙ ЗАПРОС`n$UserPrompt"
        
        $ModelResponse = Invoke-GeminiAPI -Prompt $fullPrompt -Model $Model -Config $Config
        
        if ($ModelResponse) {
            $jsonObject = ConvertTo-JsonData -GeminiResponse $ModelResponse
            if ($jsonObject) {
                Write-ColoredMessage "`n--- Gemini (объект JSON) ---`n" -Color $Config.Color.Success
                $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Выберите маршруты для следующего запроса" -OutputMode Multiple
                if ($gridSelection) {
                    $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
                    Write-ColoredMessage "Выборка сохранена. Добавьте ваш следующий запрос." -Color $Config.Color.Selection
                }
            } else {
                Write-ColoredMessage $ModelResponse -Color 'White'
            }
            Add-ChatHistory -HistoryFilePath $historyFilePath -UserPrompt $UserPrompt -ModelResponse $ModelResponse
        }
    }
    Write-ColoredMessage "Завершение работы." -Color $Config.Color.Success
}