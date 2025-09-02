function Invoke-CliCommand {
    <#
    .SYNOPSIS
        Надежно выполняет любую внешнюю команду (CLI) и возвращает структурированный результат.
    .DESCRIPTION
        Эта функция служит универсальной "оберткой" для запуска исполняемых файлов (.exe).
        Она правильно обрабатывает аргументы, перехватывает и разделяет стандартный вывод (stdout)
        и вывод ошибок (stderr), а также анализирует код завершения ($LASTEXITCODE).

        Вместо простого текста функция возвращает объект PowerShell с полями:
        - ExitCode: Код завершения процесса. 0 обычно означает успех.
        - Output: Массив строк из стандартного вывода (stdout).
        - Errors: Массив строк из вывода ошибок (stderr).
        - Success: $true, если ExitCode равен 0 и нет ошибок, иначе $false.
    .PARAMETER Command
        Имя или путь к исполняемому файлу (например, 'gemini', 'git', 'ping.exe').
    .PARAMETER Arguments
        Массив аргументов для передачи в команду. Каждый аргумент и его значение должны быть
        отдельными элементами массива для корректной обработки пробелов.
    .EXAMPLE
        PS C:\> Invoke-CliCommand -Command git -Arguments "status", "--short"

        ExitCode : 0
        Output   : { M my-script.ps1}
        Errors   : {}
        Success  : True
    .EXAMPLE
        PS C:\> $result = Invoke-CliCommand -Command gemini -Arguments "/mcp", "status"
        if (-not $result.Success) {
            Write-Warning "Команда gemini завершилась с ошибкой. Код: $($result.ExitCode)"
            $result.Errors | ForEach-Object { Write-Warning $_ }
        }
    .NOTES
        Эта функция является фундаментальным блоком для построения надежных
        сценариев автоматизации, которые зависят от внешних CLI-инструментов.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments
    )

    try {
        # Проверяем, доступна ли команда
        if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
            throw "Команда '$Command' не найдена. Убедитесь, что она установлена и ее путь добавлен в переменную PATH."
        }

        Write-Verbose "Выполнение команды: $Command $($Arguments -join ' ')"

        # Используем оператор & для вызова. Перенаправляем поток ошибок (2) во временный файл.
        # Стандартный вывод (1) будет пойман PowerShell напрямую.
        $tempErrorFile = New-TemporaryFile
        $output = & $Command @Arguments 2> $tempErrorFile.FullName

        # Получаем код выхода последней внешней команды
        $exitCode = $LASTEXITCODE

        # Читаем содержимое файла с ошибками
        $errors = Get-Content -Path $tempErrorFile.FullName

        # Формируем и возвращаем структурированный объект
        return [PSCustomObject]@{
            ExitCode = $exitCode
            Output   = $output
            Errors   = $errors
            Success  = ($exitCode -eq 0 -and $errors.Count -eq 0)
        }
    }
    catch {
        # Обработка ошибок самого нашего скрипта (например, команда не найдена)
        return [PSCustomObject]@{
            ExitCode = -1
            Output   = @()
            Errors   = @("Критическая ошибка в Invoke-CliCommand: $($_.Exception.Message)")
            Success  = $false
        }
    }
    finally {
        # Очищаем за собой временный файл
        if ($tempErrorFile -and (Test-Path $tempErrorFile.FullName)) {
            Remove-Item $tempErrorFile.FullName -Force
        }
    }
}