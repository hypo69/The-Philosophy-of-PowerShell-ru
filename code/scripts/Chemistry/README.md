# Chemistry Tools for PowerShell (with Gemini AI)

**Chemistry Tools** — это PowerShell-модуль, который предоставляет команду `Start-ChemistryExplorer` для интерактивного изучения химических элементов с помощью Google Gemini AI.

Этот инструмент превращает вашу консоль в интеллектуальный справочник, позволяя запрашивать списки элементов по категориям, просматривать их в удобной фильтруемой таблице (`Out-ConsoleGridView`) и получать дополнительную информацию по каждому из них.

 *(Рекомендуется заменить на реальную GIF-анимацию работы скрипта)*

## 🚀 Установка и настройка

### Предварительные требования

1.  **PowerShell 7.2+**.
2.  **Node.js (LTS):** [Установить отсюда](https://nodejs.org/).
3.  **Google Gemini CLI:** Убедитесь, что CLI установлен и аутентифицирован.
    ```powershell
    # 1. Установка Gemini CLI
    npm install -g @google/gemini-cli

    # 2. Первый запуск для входа в аккаунт Google
    gemini
    ```

### Пошаговая инструкция по установке

#### Шаг 1: Создайте правильную структуру папок (Обязательно!)

Это самый важный шаг. Чтобы PowerShell мог найти ваш модуль, он должен находиться в папке с **точно таким же именем**, как и сам модуль.

1.  Найдите вашу папку для личных модулей PowerShell.
    ```powershell
    # Эта команда покажет путь, обычно это C:\Users\Имя\Documents\PowerShell\Modules
    $moduleBasePath = Split-Path $PROFILE.CurrentUserAllHosts
    $moduleBasePath
    ```2.  Создайте в ней папку для нашего модуля с именем `Chemistry`.
    ```powershell
    $modulePath = Join-Path $moduleBasePath "Chemistry"
    if (-not (Test-Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }
    ```
3.  Скачайте и поместите в эту папку (`Chemistry`) следующие файлы из репозитория:
    *   `Chemistry.psm1` (основной код модуля)
    *   `Chemistry.GEMINI.md` (файл с инструкциями для ИИ)
    *   `Chemistry.psd1` (файл манифеста, опционально, но рекомендуется)

Ваша финальная структура файлов должна выглядеть так:
```
...\Documents\PowerShell\Modules\
└── Chemistry\                <-- Папка модуля
    ├── Chemistry.psd1        <-- Манифест (опционально)
    ├── Chemistry.psm1        <-- Основной код
    └── Chemistry.GEMINI.md   <-- Инструкции для ИИ
```

#### Шаг 2: Разблокируйте файлы

Если вы скачали файлы из интернета, Windows может их заблокировать. Выполните эту команду, чтобы решить проблему:
```powershell
Get-ChildItem -Path $modulePath | Unblock-File
```

#### Шаг 3: Импортируйте и проверьте модуль

Перезапустите PowerShell. Модуль должен загрузиться автоматически. Чтобы убедиться, что команда доступна, выполните:
```powershell
Get-Command -Module Chemistry
```
Вывод должен быть таким:
```
CommandType     Name                    Version    Source
-----------     ----                    -------    ------
Function        Start-ChemistryExplorer 1.0.0      Chemistry
```

## 💡 Использование

После установки просто запустите команду в вашей консоли:
```powershell
Start-ChemistryExplorer
```
Скрипт поприветствует вас и предложит ввести категорию химических элементов.
> `Запуск интерактивного справочника химика...`
> `Введите категорию элементов (например, 'благородные газы') или 'выход'`
> `> благородные газы`

После этого появится интерактивное окно `Out-ConsoleGridView` со списком элементов. Выберите один из них, и Gemini расскажет вам о нем интересные факты.

## 🛠️ Решение проблем

*   **Ошибка "модуль не найден"**:
    1.  **Перезапустите PowerShell.** Это решает проблему в 90% случаев.
    2.  Перепроверьте **Шаг 1**. Имя папки (`Chemistry`) и имя файла (`Chemistry.psm1` или `Chemistry.psd1`) должны быть правильными.

*   **Команда `Start-ChemistryExplorer` не найдена после импорта**:
    1.  Убедитесь, что в конце вашего файла `Chemistry.psm1` есть строка `Export-ModuleMember -Function Start-ChemistryExplorer`.
    2.  Если вы используете манифест (`.psd1`), убедитесь, что в нем заполнено поле `FunctionsToExport = 'Start-ChemistryExplorer'`.