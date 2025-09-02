@{

# Версия вашего модуля. Следуйте семантическому версионированию (Major.Minor.Patch).
ModuleVersion = '1.0.0'

# Уникальный идентификатор модуля. Сгенерируйте его ОДИН РАЗ командой `New-Guid` в PowerShell.
GUID = 'ВАШ_GUID_ЗДЕСЬ'

# Автор модуля
Author = 'hypo69'

# Компания (опционально)
CompanyName = 'N/A'

# Авторские права
Copyright = '(c) 2025 hypo69. All rights reserved.'

# Описание, которое будет видно в PowerShell Gallery и при вызове Get-Module
Description = 'PowerShell-модуль для интерактивного изучения химических элементов с помощью Google Gemini AI. Предоставляет командлет Start-ChemistryExplorer.'

# Минимальная требуемая версия PowerShell
PowerShellVersion = '7.2'

# Имя основного файла скриптового модуля, который будет загружен.
# Это "сердце" вашего модуля.
RootModule = 'Chemistry.psm1'

# Список функций, которые будут экспортированы и доступны пользователю.
FunctionsToExport = @(
    'Start-ChemistryExplorer'
)

# Список командлетов для экспорта (у нас их нет).
CmdletsToExport = @()

# Список переменных для экспорта (у нас их нет).
VariablesToExport = @()

# Список псевдонимов для экспорта (у нас их нет).
AliasesToExport = @()

# Список личных данных для публикации (можно оставить пустыми).
PrivateData = @{
    PSData = @{
        # Теги для поиска в PowerShell Gallery
        Tags = @('Gemini', 'AI', 'Chemistry', 'Education', 'Tools')

        # Лицензия
        LicenseUri = 'https://opensource.org/licenses/MIT'

        # Ссылка на иконку (опционально)
        # IconUri = ''

        # Ссылка на репозиторий проекта
        # ProjectUri = ''

        # Заметки о выпуске
        # ReleaseNotes = 'Первая версия модуля.'
    }
}

}