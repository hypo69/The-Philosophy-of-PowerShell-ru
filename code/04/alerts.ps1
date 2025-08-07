# =================================================================================
# УНИВЕРСАЛЬНАЯ СИСТЕМА ОПОВЕЩЕНИЙ В POWERSHELL
# Подходит для CI/CD, мониторинга, автоматизации
# Совместимо с Windows PowerShell >= 5.1 и PowerShell Core 7+
# Поддержка отправки уведомлений: Telegram, Email, трей, лог-файл
# Версия: 1.0
# Автор: hypo69
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

function Send-Alert {
    [CmdletBinding()]
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Type = "Info",
        [switch]$Tray,
        [string]$TelegramToken,
        [string]$TelegramChatId,
        [string]$EmailTo,
        [string]$EmailFrom,
        [string]$SmtpServer,
        [int]$SmtpPort = 587,
        [string]$EmailSubject = "PowerShell Alert",
        [string]$LogPath
    )

    if ($LogPath) {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        "$timestamp [$Type] $Message" | Out-File -FilePath $LogPath -Append -Encoding utf8
    }

    if ($Tray) {
        $balloonType = switch ($Type) {
            "Info" { [System.Windows.Forms.ToolTipIcon]::Info }
            "Warning" { [System.Windows.Forms.ToolTipIcon]::Warning }
            "Error" { [System.Windows.Forms.ToolTipIcon]::Error }
        }

        Add-Type -AssemblyName System.Windows.Forms
        $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
        $notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
        $notifyIcon.Visible = $true
        $notifyIcon.ShowBalloonTip(5000, "$Type", "$Message", $balloonType)
        Start-Sleep -Seconds 6
        $notifyIcon.Dispose()
    }

    if ($TelegramToken -and $TelegramChatId) {
        $uri = "https://api.telegram.org/bot$TelegramToken/sendMessage"
        $params = @{
            chat_id = $TelegramChatId
            text    = "$Type: $Message"
        }
        Invoke-RestMethod -Uri $uri -Method Post -Body $params | Out-Null
    }

    if ($EmailTo -and $EmailFrom -and $SmtpServer) {
        $smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
        $smtp.EnableSsl = $true
        $smtp.Send($EmailFrom, $EmailTo, $EmailSubject, "$Type: $Message")
    }
}

# ==============================
# Пример использования в CI/CD:
# ==============================

try {
    # Ваш код, например, деплой, тест, мониторинг
    throw "Имитация сбоя"
}
catch {
    Send-Alert -Message "Ошибка выполнения: $($_.Exception.Message)" -Type Error -Tray `
        -TelegramToken "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11" `
        -TelegramChatId "987654321" `
        -EmailTo "admin@example.com" -EmailFrom "ci@example.com" -SmtpServer "smtp.example.com" `
        -LogPath "$PSScriptRoot\alerts.log"
}
