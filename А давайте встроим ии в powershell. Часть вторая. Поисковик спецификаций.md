# А давайте встроим ии в powershell. Часть вторая. Поисковик спецификаций

В прошлый раз мы увидели, как с помощью powershell можем взаимодействовать с моделью Gemini через интерфейс командной строки. В этой статье я покажу как извлечь пользу из наших знаний. Мы превратим нашу консоль в интерактивный справочник, который на вход будет принимать идентификатор компонента (марка, модель, категория, артикул и т. п.), а возвращать интерактивную таблицу с характеристиками, полученную от модели Gemini.

Инженеры, разработчики и другие специалисты сталкиваются с тем, что нужно узнать точные параметры, например материнской платы, автомата в электрощитке или сетевого коммутатора. Наш справочник всегда будет под рукой и по запросу соберет информацию, уточнит параметры в интернете и вернет искомую таблицу. В таблице можно выбрать необходимый параметр/ы и по необходимости продолжить углубленный поиск. В дальнейшем мы научимся передавать результат по конвейеру для дальнейшей обработки: экспорта в таблицу Excel, Google таблицу, хранения в базе данных или передачи в другую программу  В случае неудачи модель посоветует, какие параметры надо уточнить. Впрочем, смотрите сами:

[video](https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f" type="video/mp4">
  Your browser does not support the video tag.
</video>

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


# --- ФУНКЦИИ ---
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    # --- ИЗМЕНЕНИЕ: Использование новой переменной ---
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    # --- КОНЕЦ ИЗМЕНЕНИЯ ---
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}

function Show-History {
    if (-not (Test-Path $historyFilePath)) { Write-Host "История текущей сессии пуста." -ForegroundColor Yellow; return }
    Write-Host "`n--- История текущей сессии ---" -ForegroundColor Cyan; Get-Content -Path $historyFilePath; Write-Host "------------------------------------`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $historyFilePath) {
        try {
            Remove-Item -Path $historyFilePath -Force -ErrorAction Stop
            Write-Host "История текущей сессии ($historyFileName) была удалена." -ForegroundColor Yellow
        }
        catch { Write-Warning "Не удалось удалить файл истории: $_" }
    }
    else { Write-Host "История текущей сессии пуста, удалять нечего." -ForegroundColor Yellow }
}

function Show-Help {
    $helpFilePath = Join-Path $scriptRoot ".gemini/ShowHelp.md"
    if (Test-Path $helpFilePath) {
        $helpText = Get-Content -Path $helpFilePath -Raw
        Write-Host $helpText
    }
    else {
        Write-Warning "Файл справки .gemini/ShowHelp.md не найден."
    }
}

function Command-Handler {
    param([string]$Command)

    switch ($Command) {
        '?' { Show-Help; return 'continue' }
        'history' { Show-History; return 'continue' }
        ('clear', 'clear-history') { Clear-History; return 'continue' }
        'gemini help' {
            Write-Host "`n--- Справка Gemini CLI ---`n" -ForegroundColor Cyan
            & gemini --help
            Write-Host "`n--------------------------`n" -ForegroundColor Cyan
            return 'continue'
        }
        ('exit', 'quit') { return 'break' }
        default {
            return $null
        }
    }
}

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

# --- НОВАЯ ФУНКЦИЯ: Отображение выбранных данных в консольной таблице ---
function Show-SelectionTable {
    param([array]$SelectedData)
    
    if ($null -eq $SelectedData -or $SelectedData.Count -eq 0) {
        return
    }
    
    Write-Host "`n--- ВЫБРАННЫЕ ДАННЫЕ ---" -ForegroundColor Yellow
    
    # Если выбран только один элемент, обернуть в массив для единообразной обработки
    if ($SelectedData -isnot [array]) {
        $SelectedData = @($SelectedData)
    }
    
    # Получить все уникальные свойства из выбранных объектов
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # Если есть свойства, показать таблицу
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    }
    else {
        # Если нет определенных свойств, показать как простой список
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
    
    Write-Host "-------------------------" -ForegroundColor Yellow
    Write-Host "Выбрано элементов: $($SelectedData.Count)" -ForegroundColor Magenta
    Write-Host ""
}


# --- Шаг 2: Проверка окружения ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } catch { Write-Error "Команда 'gemini' не найдена..."; return }
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { Write-Warning "Файл системного промпта .gemini/GEMINI.md не найден. Ответы модели могут быть непредсказуемыми."; }
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { Write-Warning "Файл справки .gemini/ShowHelp.md не найден. Команда '?' не будет работать."; }


# --- Шаг 3: Основная логика ---
Write-Host "AI-поисковик спецификаций. Модель: '$Model'." -ForegroundColor Green
Write-Host "Файл сессии будет сохранен в: $historyFilePath" -ForegroundColor Yellow
Write-Host "Введите 'exit' для выхода или '?' для помощи."
    
$selectionContextJson = $null 
    
while ($true) {
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [Выборка активна] :) > "
    }
    else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    $UserPrompt = Read-Host
        
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }

    if ([string]::IsNullOrWhiteSpace($UserPrompt)) { continue }
    
    Write-Host "Идет поиск и обработка запроса..." -ForegroundColor Gray
        
    $historyContent = ""
    if (Test-Path $historyFilePath) { $historyContent = Get-Content -Path $historyFilePath -Raw -ErrorAction SilentlyContinue }
        
    $fullPrompt = @"
### ИСТОРИЯ ДИАЛОГА (КОНТЕКСТ)
$historyContent
"@
        
    if ($selectionContextJson) {
        $selectionBlock = @"

### ДАННЫЕ ИЗ ВЫБОРКИ (ДЛЯ АНАЛИЗА)
$selectionContextJson
"@
        $fullPrompt += $selectionBlock
        $selectionContextJson = $null 
    }

    $fullPrompt += @"

### НОВАЯ ЗАДАЧА
$UserPrompt
"@

    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
        
    if ($ModelResponse) {
        $jsonToParse = $null
        $jsonPattern = '(?s)```json\s*(.*?)\s*```'
            
        if ($ModelResponse -match $jsonPattern) { $jsonToParse = $matches[1] }
        else { $jsonToParse = $ModelResponse }
            
        try {
            $jsonObject = $jsonToParse | ConvertFrom-Json
            Write-Host "`n--- Gemini (объект JSON) ---`n" -ForegroundColor Green
                
            $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Выберите строки для следующего запроса (OK) или закройте (Cancel)" -OutputMode Multiple
                
            if ($null -ne $gridSelection) {
                # --- ИЗМЕНЕНИЕ: Показать выбранные данные в консольной таблице ---
                Show-SelectionTable -SelectedData $gridSelection
                # --- КОНЕЦ ИЗМЕНЕНИЯ ---
                
                $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
                Write-Host "Выборка сохранена. Добавьте ваш следующий запрос (например, 'сравни их')." -ForegroundColor Magenta
            }
        }
        catch {
            Write-Host $ModelResponse -ForegroundColor Cyan
        }
            
        Add-History -UserPrompt $UserPrompt -ModelResponse $ModelResponse
    }
}

Write-Host "Завершение работы." -ForegroundColor Green
```

# А давайте встроим ИИ в PowerShell. Часть вторая. Поисковик спецификаций (продолжение)

## С чего все начинается: API ключ и базовая настройка

Самое важное в нашем скрипте - это блок инициализации. Без него ничего работать не будет:

```powershell
# --- Шаг 1: Настройка ---
$env:GEMINI_API_KEY = "AIzaSyCbq8bkt5Xr2hlE-73MIXFpdFYH-rLBd0k"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName
```

**Что здесь критически важно:**

1. **API ключ Gemini** - без него скрипт просто не запустится. Это ваш "пропуск" к возможностям AI.
2. **Структура папок** - скрипт создает организованную файловую систему для хранения всех данных.
3. **Уникальное имя сессии** - каждый запуск создает отдельный файл истории с временной меткой.

**Где взять API ключ:** Идите на [Google AI Studio](https://makersuite.google.com/), создайте проект и сгенерируйте ключ. Он бесплатный для базового использования.

## Проверка окружения - что должно быть установлено

Следующий критически важный блок:

```powershell
# --- Шаг 2: Проверка окружения ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } 
catch { Write-Error "Команда 'gemini' не найдена..."; return }
```

**Что нужно установить перед использованием:**

1. **Gemini CLI** - основной инструмент для работы с AI. Скачайте с официального сайта Google.
2. **PowerShell 7+** - для работы `Out-ConsoleGridView`. В Windows PowerShell 5.1 этот командлет недоступен.

**Проверка установки:**
```powershell
# Проверяем Gemini CLI
gemini --version

# Проверяем Out-ConsoleGridView 
Get-Command Out-ConsoleGridView
```

## Основная функция - мост к искусственному интеллекту

Сердце всей системы - функция `Invoke-GeminiPrompt`:

```powershell
function Invoke-GeminiPrompt {
    param([string]$Prompt, [string]$Model)
    try {
        # Вызываем Gemini CLI и захватываем все выводы
        $output = & gemini -m $Model -p $Prompt 2>&1
        
        # Проверяем успешность выполнения
        if (-not $?) { 
            $output | ForEach-Object { Write-Warning $_.ToString() }
            return $null 
        }
        
        # Очищаем вывод от служебных сообщений
        $outputString = ($output -join [Environment]::NewLine).Trim()
        $cleanedOutput = $outputString -replace "(?m)^Data collection is disabled\.`r?`n" , ""
        $cleanedOutput = $cleanedOutput -replace "(?m)^Loaded cached credentials\.`r?`n", ""
        
        return $cleanedOutput.Trim()
    }
    catch { 
        Write-Error "Критическая ошибка при вызове Gemini CLI: $_"
        return $null 
    }
}
```

**Почему эта функция так важна:**
- Она скрывает сложности взаимодействия с CLI
- Автоматически очищает служебные сообщения, которые мешают парсингу JSON
- Обрабатывает все возможные ошибки
- Возвращает чистый результат, готовый к обработке

## Структура конфигурационных файлов

Скрипт опирается на три ключевых файла в папке `.gemini/`:

### `.gemini/GEMINI.md` - системный промпт (самый важный!)

Этот файл определяет, КАК будет вести себя AI. Примерное содержание:

```markdown
# Системный промпт для поисковика спецификаций

Ты - специализированный помощник для поиска технических характеристик компонентов и оборудования.

## Правила работы:
1. ВСЕГДА возвращай результат в формате JSON массива объектов
2. Каждый объект должен содержать поля:
   - "name": полное название компонента
   - "manufacturer": производитель
   - "category": категория товара
   - "specifications": объект с техническими характеристиками
   - "price_range": примерный диапазон цен в USD
   - "availability": статус доступности

3. При поиске используй актуальные данные из интернета
4. Если информация неточная, указывай это в поле "notes"
5. При невозможности найти данные, возвращай объект с полем "error" и предложениями по уточнению запроса

## Пример ответа:
```json
[
  {
    "name": "Intel Core i5-12400F",
    "manufacturer": "Intel",
    "category": "CPU",
    "specifications": {
      "cores": 6,
      "threads": 12,
      "base_clock": "2.5 GHz",
      "boost_clock": "4.4 GHz",
      "socket": "LGA1700"
    },
    "price_range": "$150-180",
    "availability": "В наличии"
  }
]
```

**Почему этот файл критичен:** Без правильного системного промпта AI будет отвечать в произвольном формате, и парсинг JSON будет постоянно ломаться.

### `.gemini/ShowHelp.md` - справка пользователя

```markdown
# AI-поисковик технических спецификаций

## Как пользоваться:
Просто введите название, модель или артикул компонента:

### Примеры запросов:
- `Intel Core i7-13700K` - процессор Intel
- `Gigabyte B650 AORUS ELITE AX` - материнская плата  
- `RTX 4070 Ti Super` - видеокарта
- `Schneider Electric A9C21834` - автоматический выключатель
- `Cisco WS-C2960-24TT-L` - сетевой коммутатор

### Доступные команды:
- `?` - показать эту справку
- `history` - посмотреть историю текущей сессии
- `clear` - очистить историю сессии
- `gemini help` - справка по Gemini CLI
- `exit` или `quit` - выйти из программы

### Работа с результатами:
1. После поиска откроется интерактивная таблица
2. Выберите интересующие строки (Ctrl+Click для множественного выбора)
3. Нажмите OK - выбранные данные отобразятся в консоли
4. Теперь можно задать уточняющий вопрос: "сравни их", "найди аналоги", "где купить дешевле"

### Советы:
- Указывайте максимально точное название или артикул
- Для неизвестных компонентов добавляйте категорию: "реле времени ABB"
- Используйте английские названия для зарубежных брендов
```

## Основной цикл программы - как все работает

```powershell
while ($true) {
    # 1. Показываем приглашение с индикацией состояния
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [Выборка активна] :) > "
    } else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    
    # 2. Получаем ввод пользователя
    $UserPrompt = Read-Host
    
    # 3. Обрабатываем служебные команды
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }
    
    # 4. Формируем полный контекст для AI
    $fullPrompt = "### ИСТОРИЯ ДИАЛОГА\n$historyContent"
    if ($selectionContextJson) {
        $fullPrompt += "\n### ДАННЫЕ ИЗ ВЫБОРКИ\n$selectionContextJson"
    }
    $fullPrompt += "\n### НОВАЯ ЗАДАЧА\n$UserPrompt"
    
    # 5. Отправляем запрос в AI
    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
    
    # 6. Пытаемся распарсить как JSON и показать таблицу
    try {
        $jsonObject = $jsonToParse | ConvertFrom-Json
        $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Выберите строки..." -OutputMode Multiple
        
        if ($null -ne $gridSelection) {
            Show-SelectionTable -SelectedData $gridSelection
            $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
        }
    }
    catch {
        # Не JSON - показываем как обычный текст
        Write-Host $ModelResponse -ForegroundColor Cyan
    }
    
    # 7. Сохраняем в историю
    Add-History -UserPrompt $UserPrompt -ModelResponse $ModelResponse
}
```

**Ключевая идея:** Каждый запрос включает всю предыдущую историю + выбранные данные. Так AI "помнит" контекст разговора.

## Вспомогательные функции

### Управление историей - зачем это нужно

```powershell
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}
```

**Почему история критична:** AI-модели не имеют памяти между запросами. Мы создаем "искусственную память", передавая всю историю с каждым новым вопросом.

### Красивое отображение выбранных данных

```powershell
function Show-SelectionTable {
    param([array]$SelectedData)
    
    # Автоматически определяем структуру данных
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # Показываем в оптимальном формате
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    } else {
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
}
```

**Зачем нужна эта функция:** После выбора в `Out-ConsoleGridView` пользователь не видит, что именно выбрал. Функция решает эту проблему, показывая выбранные данные в консоли.

## Практический пример использования

1. **Запускаем скрипт:**
   ```powershell
   .\Find-Spec.ps1
   ```

2. **Ищем компонент:**
   ```
   🤖AI :) > RTX 4070 Ti Super
   ```

3. **Получаем таблицу, выбираем интересующие модели**

4. **Задаем уточняющий вопрос:**
   ```
   🤖AI [Выборка активна] :) > сравни производительность в играх
   ```

5. **Получаем детальное сравнение на основе выбранных данных**

В следующей части мы рассмотрим расширение функциональности и интеграцию с внешними системами.