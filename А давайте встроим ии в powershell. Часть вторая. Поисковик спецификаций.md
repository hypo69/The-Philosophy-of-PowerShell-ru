# А давайте встроим ии в powershell. Часть вторая. Поисковик спецификаций

В прошлый раз мы увидели, как с помощью powershell можем взаимодействовать с моделью Gemini через интерфейс командной строки. В этой статье я покажу как извлечь пользу из наших знаний. Мы превратим нашу консоль в интерактивный справочник, который на вход будет принимать идентификатор компонента (марка, модель, категория, артикул и т. п.), а возвращать интерактивную таблицу с характеристиками, полученную от модели Gemini.

Инженеры, разработчики и другие специалисты сталкиваются с тем, что нужно узнать точные параметры, например материнской платы, автомата в электрощитке или сетевого коммутатора. Наш справочник всегда будет под рукой и по запросу соберет информацию, уточнит параметры в интернете и вернет искомую таблицу. В таблице можно выбрать необходимый параметр/ы и по необходимости продолжить углубленный поиск. В дальнейшем мы научимся передавать результат по конвейеру для дальнейшей обработки: экспорта в таблицу Excel, Google таблицу, хранения в базе данных или передачи в другую программу  В случае неудачи модель посоветует, какие параметры надо уточнить. Впрочем, смотрите сами:

[video](https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Шаг 1: Настройка

```powershell
# --- Шаг 1: Настройка ---
$env:GEMINI_API_KEY = "AIzaSyCbq8bkt5Xr2hlE-73MIXFpdFYH-rLBd0k"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
# --- ИЗМЕНЕНИЕ: Переменная переименована ---
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
# --- КОНЕЦ ИЗМЕНЕНИЯ ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName
```

**Назначение строк:**

- `$env:GEMINI_API_KEY = "..."` - устанавливает API ключ для доступа к Gemini AI
- `if (-not $env:GEMINI_API_KEY)` - проверяет наличие ключа, завершает работу если его нет
- `$scriptRoot = Get-Location` - получает текущую рабочую директорию
- `$HistoryDir = Join-Path...` - формирует путь к папке для хранения истории диалогов (`.gemini/.chat_history`)
- `$timestamp = Get-Date...` - создает временную метку в формате `2025-08-26_14-30-15`
- `$historyFileName = "ai_session_$timestamp.jsonl"` - генерирует уникальное имя файла сессии
- `$historyFilePath = Join-Path...` - создает полный путь к файлу истории текущей сессии

## Проверка окружения - что должно быть установлено

```powershell
# --- Шаг 2: Проверка окружения ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } 
catch { Write-Error "Команда 'gemini' не найдена..."; return }

if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { 
    Write-Warning "Файл системного промпта .gemini/GEMINI.md не найден..." 
}
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { 
    Write-Warning "Файл справки .gemini/ShowHelp.md не найден..." 
}
```

**Что проверяется:**

- Наличие **Gemini CLI** в системе - без него скрипт не работает
- Файл **GEMINI.md** - содержит системный промпт (инструкции для AI)
- Файл **ShowHelp.md** - справка для пользователя (команда `?`)

## Основная функция взаимодействия с AI

```powershell
function Invoke-GeminiPrompt {
    param([string]$Prompt, [string]$Model)
    try {
        $output = & gemini -m $Model -p $Prompt 2>&1
        if (-not $?) { $output | ForEach-Object { Write-Warning $_.ToString() }; return $null }
        
        $outputString = ($output -join [Environment]::NewLine).Trim()
        $cleanedOutput = $outputString -replace "(?m)^Data collection is disabled\.`r?`n" , ""
        $cleanedOutput = $cleanedOutput -replace "(?m)^Loaded cached credentials\.`r?`n", ""
        
        return $cleanedOutput.Trim()
    }
    catch { Write-Error "Критическая ошибка при вызове Gemini CLI: $_"; return $null }
}
```

**Задачи функции:**
- Вызывает Gemini CLI с указанной моделью и промптом
- Захватывает все выводы (включая ошибки)
- Очищает результат от служебных сообщений CLI
- Возвращает чистый ответ AI или `$null` при ошибке

## Функции управления историей

```powershell
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}

function Show-History {
    if (-not (Test-Path $historyFilePath)) { Write-Host "История текущей сессии пуста." -ForegroundColor Yellow; return }
    Write-Host "`n--- История текущей сессии ---" -ForegroundColor Cyan
    Get-Content -Path $historyFilePath
    Write-Host "------------------------------------`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $historyFilePath) {
        Remove-Item -Path $historyFilePath -Force -ErrorAction Stop
        Write-Host "История текущей сессии ($historyFileName) была удалена." -ForegroundColor Yellow
    }
}
```

**Назначение:**
- `Add-History` - сохраняет пары "вопрос-ответ" в JSONL формате
- `Show-History` - показывает содержимое файла истории
- `Clear-History` - удаляет файл истории текущей сессии

## Новая функция отображения выбранных данных

```powershell
function Show-SelectionTable {
    param([array]$SelectedData)
    
    if ($null -eq $SelectedData -or $SelectedData.Count -eq 0) { return }
    
    Write-Host "`n--- ВЫБРАННЫЕ ДАННЫЕ ---" -ForegroundColor Yellow
    
    # Получить все уникальные свойства из выбранных объектов
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # Показать таблицу или список
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    } else {
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
    
    Write-Host "-------------------------" -ForegroundColor Yellow
    Write-Host "Выбрано элементов: $($SelectedData.Count)" -ForegroundColor Magenta
}
```

**Задача функции:** После выбора элементов в `Out-ConsoleGridView` показывает их в консоли в виде аккуратной таблицы, чтобы пользователь видел, что именно выбрал.

## Основной рабочий цикл

```powershell
while ($true) {
    # Показ приглашения с индикацией состояния
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [Выборка активна] :) > "
    } else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    
    $UserPrompt = Read-Host
    
    # Обработка служебных команд
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }
    
    # Формирование полного промпта с контекстом
    $fullPrompt = @"
### ИСТОРИЯ ДИАЛОГА (КОНТЕКСТ)
$historyContent

### ДАННЫЕ ИЗ ВЫБОРКИ (ДЛЯ АНАЛИЗА)
$selectionContextJson

### НОВАЯ ЗАДАЧА
$UserPrompt
"@
    
    # Вызов AI и обработка ответа
    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
    
    # Попытка парсинга JSON и показ интерактивной таблицы
    try {
        $jsonObject = $jsonToParse | ConvertFrom-Json
        $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Выберите строки..." -OutputMode Multiple
        
        if ($null -ne $gridSelection) {
            Show-SelectionTable -SelectedData $gridSelection
            $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
        }
    }
    catch {
        Write-Host $ModelResponse -ForegroundColor Cyan
    }
    
    Add-History -UserPrompt $UserPrompt -ModelResponse $ModelResponse
}
```

**Ключевые особенности:**
- Индикатор `[Выборка активна]` показывает, что есть данные для анализа
- Каждый запрос включает всю историю диалога для поддержания контекста
- AI получает и историю, и выбранные пользователем данные
- Результат пытается отобразиться как интерактивная таблица
- При неудаче парсинга JSON показывается обычный текст

## Структура рабочих файлов

Скрипт создает следующую структуру:
```
├── Find-Spec.ps1
├── .gemini/
│   ├── GEMINI.md              # Системный промпт для AI
│   ├── ShowHelp.md            # Справка пользователя  
│   └── .chat_history/         # Папка с историей сессий
│       ├── ai_session_2025-08-26_10-15-30.jsonl
│       └── ai_session_2025-08-26_14-22-45.jsonl
```

В следующей части мы рассмотрим содержимое конфигурационных файлов и примеры практического использования.