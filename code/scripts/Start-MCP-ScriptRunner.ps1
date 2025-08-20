# =================================================================================
# MCP-СЕРВЕР ДЛЯ ПОИСКА И ЗАПУСКА POWERSHELL-СКРИПТОВ
# Требует установленного модуля Pode.
# =================================================================================

Import-Module Pode

# --- НАСТРОЙКА ---
# Укажите папку, где хранятся ваши PowerShell-скрипты
$ScriptLibraryPath = "C:\Scripts"
# Порт, на котором будет работать наш MCP-сервер
$McpPort = 8090
# -----------------

# Запускаем веб-сервер Pode
Start-PodeServer -ScriptBlock {
    # Указываем Pode слушать на всех IP-адресах на указанном порту
    Add-PodeEndpoint -Address * -Port $McpPort -Protocol Http

    # =================================================================================
    # Определяем инструмент "run-script" для нашего MCP-сервера
    # =================================================================================
    Add-PodeRoute -Method Post -Path '/run-script' -ScriptBlock {
        # Получаем тело JSON-запроса от gemini
        $requestBody = $WebEvent.Data
        $query = $requestBody.query
        
        Write-Host "Получен запрос на поиск и запуск скрипта по запросу: '$query'"

        # --- Логика поиска скрипта ---
        $foundScript = $null
        try {
            # Ищем скрипты, где в Synopsis или Description есть ключевые слова из запроса
            $scriptFiles = Get-ChildItem -Path $ScriptLibraryPath -Filter "*.ps1" -Recurse
            
            # Используем Select-String для поиска по содержимому (описанию)
            # Это простой, но эффективный метод
            $matchingFiles = $scriptFiles | Select-String -Pattern $query -SimpleMatch
            
            if ($matchingFiles) {
                # Берем первый найденный скрипт
                $foundScript = Get-Item -Path ($matchingFiles | Select-Object -First 1).Path
                Write-Host "Найден подходящий скрипт: $($foundScript.FullName)"
            }
        }
        catch {
            Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Ошибка при поиске скриптов: $($_.Exception.Message)" }
            return
        }
        
        if (-not $foundScript) {
            Write-PodeJsonResponse -StatusCode 404 -Value @{ error = "Скрипт по запросу '$query' не найден." }
            return
        }

        # --- Логика запуска скрипта ---
        try {
            Write-Host "Запуск скрипта: $($foundScript.FullName)"
            # Запускаем найденный скрипт. Перенаправляем все потоки, чтобы собрать весь вывод.
            $output = & $foundScript.FullName *>&1 | Out-String

            # Проверяем, была ли ошибка при выполнении
            if ($LASTEXITCODE -ne 0 -or $? -eq $false) {
                 throw "Скрипт завершился с ошибкой."
            }
            
            # Возвращаем успешный результат в gemini
            Write-PodeJsonResponse -Value @{ 
                result = "Скрипт '$($foundScript.Name)' успешно выполнен."
                output = $output
            }
        }
        catch {
             Write-PodeJsonResponse -StatusCode 500 -Value @{ 
                error = "Ошибка при выполнении скрипта '$($foundScript.Name)': $($_.Exception.Message)"
                output = $output
            }
        }
    }
}