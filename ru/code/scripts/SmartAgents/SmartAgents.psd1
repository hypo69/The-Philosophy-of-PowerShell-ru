@{
    # Версия вашего модуля.
    ModuleVersion = '1.0.0'

    # Уникальный идентификатор модуля.
    GUID = '8f4e9d6d-2c7b-4a0e-8f1d-9c3e4b7a6d5c'

    # Автор модуля.
    Author = 'hypo69'

    # Описание функциональности модуля.
    Description = 'Фреймворк для создания специализированных AI-агентов (FindSpec, FlightPlan) в PowerShell.'

    # Главный файл модуля, который содержит основную логику.
    RootModule = 'SmartAgents.psm1'

    # Функции, которые будут доступны пользователю после импорта модуля.
    FunctionsToExport = @(
        'Start-FindSpecAgent',
        'Start-FlightPlanAgent'
    )

    # --- ДОБАВЛЕННЫЙ БЛОК ---
    # Псевдонимы (короткие команды) для экспортируемых функций.
    AliasesToExport = @(
        'find-spec',
        'flight-plan'
    )

    # Оставляем пустыми, т.к. не экспортируем командлеты или переменные.
    CmdletsToExport = @()
    VariablesToExport = @()

    # Приватные данные, включая теги для PowerShell Gallery.
    PrivateData = @{
        PSData = @{
            Tags = @('AI', 'Gemini', 'Automation', 'PowerShell', 'Agent')
        }
    }
}