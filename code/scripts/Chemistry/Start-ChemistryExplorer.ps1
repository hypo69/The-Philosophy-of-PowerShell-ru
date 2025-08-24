# =================================================================================
# Start-ChemistryExplorer.ps1
# Запускает интерактивный чат с Gemini AI, специализированный для химии.
# Автор: hypo69
# Дата создания: 20/08/2025
# =================================================================================
<#
.SYNOPSIS
    Запускает простой и надежный интерактивный чат с Gemini AI,
    используя системные инструкции из файла GEMINI.md.
.DESCRIPTION
    Этот скрипт предоставляет прямой доступ к Gemini CLI в виде интерактивного чата.
    В зависимости от инструкций в GEMINI.md, ответы могут быть в виде текста или JSON,
    который скрипт автоматически форматирует для удобного вывода.
.EXAMPLE
    PS C:\> .\Start-ChemistryExplorer.ps1
    # Запускает интерактивный чат.
.NOTES
    Требуется, чтобы Gemini CLI был установлен и доступен в системной переменной PATH.
    Для корректной работы в директории запуска должен находиться файл GEMINI.md.
#>
[CmdletBinding()]
param()

$env:GEMINI_API_KEY = "AIzaSyCY8Nk46H8v3Rt4b02oMLU7gDbqT1xU6wU"

# --- Вспомогательная функция для общения с Gemini ---
function Invoke-GeminiPrompt {
    param(
        [string]$Prompt
    )
    
    try {
        $geminiCommand = Get-Command gemini -ErrorAction Stop
    }
    catch {
        Write-Error "Команда 'gemini' не найдена. Убедитесь, что Gemini CLI установлен."
        return $null
    }

    Write-Verbose "Отправка промпта в Gemini CLI..."
    
    $output = & $geminiCommand.Source -p $Prompt 2>&1

    if (-not $?) {
        Write-Warning "Команда gemini завершилась с ошибкой."
        $output | ForEach-Object { Write-Warning $_.ToString() }
        return $null
    }
    
    # "Чистим" вывод от возможных служебных сообщений Gemini
    $outputString = ($output -join [Environment]::NewLine).Trim()
    $cleanedOutput = $outputString -replace "(?m)^Data collection is disabled\.`r?`n" , ""
    $cleanedOutput = $cleanedOutput -replace "(?m)^Loaded cached credentials\.`r?`n", ""
    
    return $cleanedOutput.Trim()
}

# --- Основной цикл интерактивного чата ---
Write-Host "Запуск интерактивного ассистента Gemini..." -ForegroundColor Cyan
Write-Host "Введите химический символ (Fe, H) для получения JSON или любой другой вопрос."
Write-Host "Для выхода введите 'выход'."

while ($true) {
    $userInput = Read-Host "PS Химик>"
    if ($userInput -eq 'выход' -or [string]::IsNullOrWhiteSpace($userInput)) {
        break
    }
    
    Write-Host "`nЗапрашиваю ответ у Gemini..." -ForegroundColor Magenta
    
    $response = Invoke-GeminiPrompt -Prompt $userInput
    
    if ($response) {
        # Пытаемся преобразовать ответ в объект, предполагая, что это "псевдо-JSON"
        try {
            # Заменяем ':' на '=', чтобы ConvertFrom-StringData сработал
            $formattedData = $response -replace ':', '='
            $object = $formattedData | ConvertFrom-StringData
            
            # Если в объекте есть хотя бы одно свойство, считаем, что это JSON
            if ($object.Keys.Count -gt 0) {
                 Write-Host "`n--- Свойства элемента ---" -ForegroundColor Green
                 $object | Out-ConsoleGridView
            }
            else {
                # Если не получилось, считаем это обычным текстом
                throw "Не JSON"
            }
        }
        catch {
            # Если преобразование не удалось, просто выводим текстовый ответ
            Write-Host "`n--- Ответ от Gemini ---"
            Write-Host $response
        }
    }
    else {
        # Предупреждение уже будет выведено из Invoke-GeminiPrompt
    }
}

Write-Host "`nАссистент завершил работу." -ForegroundColor Yellow