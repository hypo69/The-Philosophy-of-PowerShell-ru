# =================================================================================
# 10. аудит ситемы.ps1 — Скрипт аудита пользователей и их прав
# PowerShell >= 5.1
# Автор: hypo69
# Версия: 0.1.0
# Дата создания: 02/09/2025
# =================================================================================

# Лицензия: MIT — https://opensource.org/licenses/MIT

<#
.SYNOPSIS
    Получает информацию обо всех пользователях в системе, включая скрытые и встроенные учётные записи, а также их права и членство в группах.

.DESCRIPTION
    Этот скрипт идеально подходит для администраторов, которым нужно быстро получить полный список всех учётных записей в системе и проверить их права. Позволяет убедиться, что нет несанкционированных учётных записей.

.EXAMPLE
    PS C:\> .\10. аудит ситемы.ps1
    # Запускает скрипт аудита пользователей и их прав.
#>

Write-Host "--- Аудит пользователей и их прав ---" -ForegroundColor Green

# Получаем всех пользователей, включая скрытые
# `-Filter *` позволяет получить все учётные записи
$users = Get-LocalUser -Filter *

if ($users.Count -eq 0) {
    Write-Host "Пользователи в системе не найдены." -ForegroundColor Red
} else {
    foreach ($user in $users) {
        Write-Host "`nИмя пользователя: $($user.Name)" -ForegroundColor Yellow
        Write-Host "  Полное имя: $($user.FullName)" -ForegroundColor Cyan
        Write-Host "  Описание: $($user.Description)" -ForegroundColor Cyan
        Write-Host "  Включен: $($user.Enabled)" -ForegroundColor Cyan
        Write-Host "  Скрыт: $($user.Hidden)" -ForegroundColor Cyan

        # Проверяем, является ли пользователь администратором
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")
        $userGroups = Get-LocalGroup -Member $user

        $isAdmin = $userGroups | Where-Object { $_.Name -eq "Администраторы" -or $_.Name -eq "Administrators" }
        if ($isAdmin) {
            Write-Host "  Является администратором: Да" -ForegroundColor Red
        } else {
            Write-Host "  Является администратором: Нет" -ForegroundColor Green
        }
        
        # Выводим все группы, в которые входит пользователь
        Write-Host "  Членство в группах:" -ForegroundColor Cyan
        foreach ($group in $userGroups) {
            Write-Host "    - $($group.Name)" -ForegroundColor Green
        }
    }
}

Write-Host "`n--- Аудит завершён ---" -ForegroundColor Green
