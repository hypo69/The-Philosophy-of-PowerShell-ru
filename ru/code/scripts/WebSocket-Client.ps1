# =================================================================================
# WebSocket-Client.ps1 — Универсальный WebSocket-клиент для получения данных в реальном времени
# Windows PowerShell >= 5.1
# Автор: hypo69
# Дата создания: 13/09/2025
# =================================================================================

# =================================================================================
# ЛИЦЕНЗИЯ (MIT)
# =================================================================================
<#
Лицензия MIT: https://opensource.org/licenses/MIT
#>

function Start-WebSocketClient {
<#
.SYNOPSIS
    Универсальный WebSocket-клиент с поддержкой переподключений и логированием.

.DESCRIPTION
    Эта функция подключается к WebSocket-серверу, отправляет подписку на поток данных
    и выводит входящие сообщения в консоль. В случае разрыва соединения клиент автоматически
    переподключается через заданный интервал.

.PARAMETER Url
    URL WebSocket-сервера (например: "wss://streamer.cryptocompare.com/v2?api_key=ВАШ_API_KEY").

.PARAMETER SubscribeMessage
    Сообщение подписки в формате JSON, которое будет отправлено серверу после подключения.

.PARAMETER ReconnectDelay
    Задержка в секундах перед попыткой переподключения после разрыва соединения.
    По умолчанию 5 секунд.

.EXAMPLE
    $Url = "wss://streamer.cryptocompare.com/v2?api_key=ВАШ_API_KEY"
    $SubscribeMessage = '{"action":"SubAdd","subs":["5~CCCAGG~BTC~USD"]}'
    Start-WebSocketClient -Url $Url -SubscribeMessage $SubscribeMessage -ReconnectDelay 5
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, HelpMessage = "Укажите URL WebSocket-сервера.")]
        [string]$Url,

        [Parameter(Mandatory, HelpMessage = "Сообщение подписки в формате JSON.")]
        [string]$SubscribeMessage,

        [Parameter(Mandatory = $false, HelpMessage = "Задержка переподключения (сек).")]
        [int]$ReconnectDelay = 5
    )

    # Бесконечный цикл для автоматического переподключения
    while ($true) {
        try {
            # Создаем WebSocket
            $ws = [System.Net.WebSockets.ClientWebSocket]::new()
            $uri = [Uri] $Url

            # Подключение
            $ws.ConnectAsync($uri, [Threading.CancellationToken]::None).Wait()
            Write-Host "✅ Соединение установлено с $Url" -ForegroundColor Green

            # Отправка сообщения подписки
            if ($SubscribeMessage) {
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($SubscribeMessage)
                $buffer = [System.ArraySegment[byte]]::new($bytes)
                $ws.SendAsync($buffer, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).Wait()
                Write-Host "➡ Подписка отправлена: $SubscribeMessage" -ForegroundColor Cyan
            }

            # Буфер для приема данных
            $bufferSize = 1024
            $buffer = New-Object byte[] $bufferSize
            $segment = [System.ArraySegment[byte]]::new($buffer)

            # Получение сообщений в реальном времени
            while ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
                $receiveTask = $ws.ReceiveAsync($segment, [Threading.CancellationToken]::None)
                $receiveTask.Wait()
                $message = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $receiveTask.Result.Count)
                Write-Host "📩 Получено: $message"
            }
        }
        catch {
            Write-Host "⚠ Ошибка: $_" -ForegroundColor Red
        }

        Write-Host "⏳ Переподключение через $ReconnectDelay секунд..." -ForegroundColor Yellow
        Start-Sleep -Seconds $ReconnectDelay
    }
}

# =================================================================================
# --- ПРИМЕР ИСПОЛЬЗОВАНИЯ ---
# =================================================================================
# Раскомментируйте и замените API_KEY своим ключом Cryptocompare
# $Url = "wss://streamer.cryptocompare.com/v2?api_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# $SubscribeMessage = '{"action":"SubAdd","subs":["5~CCCAGG~BTC~USD"]}'
# Start-WebSocketClient -Url $Url -SubscribeMessage $SubscribeMessage -ReconnectDelay 5
