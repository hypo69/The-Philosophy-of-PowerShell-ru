function Invoke-Gemini {
    <#
    .SYNOPSIS
        Отправляет текстовый промпт в Gemini CLI и возвращает его ответ.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Prompt
    )

    process {
        try {
            # Проверяем, доступна ли команда gemini
            $geminiCommand = Get-Command gemini -ErrorAction Stop
        }
        catch {
            Write-Error "Команда 'gemini' не найдена. Убедитесь, что Gemini CLI установлен."
            return
        }

        Write-Verbose "Отправка промпта в Gemini CLI..."

        # Запускаем gemini в неинтерактивном режиме с нашим промптом
        $output = & $geminiCommand.Source -p $Prompt 2>&1

        if (-not $?) {
            Write-Warning "Команда gemini завершилась с ошибкой."
            $output | ForEach-Object { Write-Warning $_.ToString() }
            return
        }

        # Возвращаем чистый вывод
        return $output
    }
}