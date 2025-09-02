# Integramos la IA en PowerShell. Parte Dos: El Buscador de Especificaciones

La última vez, vimos cómo podemos interactuar con el modelo Gemini a través de la interfaz de línea de comandos usando PowerShell. En este artículo, les mostraré cómo beneficiarse de nuestro conocimiento. Convertiremos nuestra consola en una guía de referencia interactiva que tomará un identificador de componente (marca, modelo, categoría, número de pieza, etc.) como entrada y devolverá una tabla interactiva con las especificaciones obtenidas del modelo Gemini.

Ingenieros, desarrolladores y otros especialistas a menudo se enfrentan a la necesidad de conocer los parámetros exactos de, por ejemplo, una placa base, un disyuntor en un cuadro eléctrico o un conmutador de red. Nuestra guía de referencia estará siempre a mano y, previa solicitud, recopilará información, aclarará parámetros en Internet y devolverá la tabla deseada. En la tabla, podrá seleccionar los parámetros necesarios y, si es preciso, continuar con una búsqueda más profunda. Más adelante, aprenderemos a pasar el resultado por la tubería para su posterior procesamiento: exportación a una hoja de cálculo de Excel o Google, almacenamiento en una base de datos o transferencia a otro programa. En caso de fallo, el modelo aconsejará qué parámetros deben aclararse. Pero véanlo ustedes mismos:

[vídeo](https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Cómo funciona el Buscador de Especificaciones impulsado por IA: del lanzamiento al resultado

Analicemos el ciclo de vida completo de nuestro script: qué sucede desde el momento de su lanzamiento hasta la obtención de los resultados.

## Inicialización: Preparación para el trabajo

El script acepta un parámetro `$Model` con validación: puede elegir 'gemini-2.5-flash' (el modelo rápido predeterminado) o 'gemini-2.5-pro' (más potente). Al iniciar, el script primero configura el entorno de trabajo. Establece la clave API para acceder a Gemini AI, define la carpeta actual como directorio base y crea una estructura para almacenar archivos. Para cada sesión, se crea un archivo con una marca de tiempo, por ejemplo, `ai_session_2025-08-26_14-30-15.jsonl`. Este es el historial de diálogo.

A continuación, el sistema verifica que todas las herramientas necesarias estén instaladas. Busca el CLI de Gemini en el sistema y verifica los archivos de configuración en la carpeta `.gemini/`. El archivo `GEMINI.md` es particularmente importante: contiene el prompt del sistema para el modelo y es cargado automáticamente por el CLI de Gemini al inicio. Esta es la ubicación estándar para las instrucciones del sistema. También se verifica el archivo `ShowHelp.md`, que contiene información de ayuda. Si falta algo crítico, el script advierte al usuario o termina.

## Inicio del modo interactivo

Después de una inicialización exitosa, el script muestra un mensaje de bienvenida que indica el modelo seleccionado ("Buscador de Especificaciones de IA. Modelo: 'gemini-2.5-flash'."), la ruta al archivo de sesión e instrucciones para los comandos. Luego, entra en modo interactivo: muestra un prompt y espera la entrada del usuario. El prompt se ve como `🤖AI :) > ` y cambia a `🤖AI [Selección activa] :) > ` cuando el sistema tiene datos para analizar.

## Procesamiento de la entrada del usuario

Cada entrada del usuario se verifica primero para comandos de servicio mediante la función `Command-Handler`. Esta función reconoce comandos como `?` (ayuda del archivo ShowHelp.md), `history` (mostrar historial de sesión), `clear` y `clear-history` (borrar el archivo de historial), `gemini help` (ayuda del CLI), y `exit` y `quit` (salir). Si es un comando de servicio, se ejecuta inmediatamente sin contactar a la IA, y el bucle continúa.

Si es una consulta regular, el sistema comienza a construir el contexto para enviar a Gemini. Lee el historial completo de la sesión actual del archivo JSONL (si existe), agrega un bloque con datos de la selección anterior (si hay una selección activa) y combina todo esto con la nueva consulta del usuario en un prompt estructurado con las secciones "HISTORIAL DE DIÁLOGO", "DATOS DE LA SELECCIÓN" y "NUEVA TAREA". Después de su uso, los datos de selección se borran.

## Interacción con la Inteligencia Artificial

El prompt formado se envía a Gemini a través de la línea de comandos con la llamada `& gemini -m $Model -p $Prompt 2>&1`. El sistema captura toda la salida (incluidos los errores a través de `2>&1`), verifica el código de retorno y limpia el resultado de los mensajes de servicio del CLI ("La recopilación de datos está deshabilitada" y "Credenciales en caché cargadas"). Si ocurre un error en esta etapa, el usuario recibe una advertencia, pero el script continúa ejecutándose.

## Procesamiento de la respuesta de la IA

El sistema intenta interpretar la respuesta recibida de la IA como JSON. Primero, busca un bloque de código en el formato ```json...```, extrae el contenido e intenta analizarlo. Si no hay tal bloque, analiza toda la respuesta. Si el análisis es exitoso, los datos se muestran en una tabla interactiva `Out-ConsoleGridView` con el título "Seleccionar filas para la siguiente consulta (OK) o cerrar (Cancelar)" y la selección múltiple habilitada. Si el JSON no se reconoce (error de análisis), la respuesta se muestra como texto sin formato en azul.

## Trabajar con la selección de datos

Cuando el usuario selecciona filas en la tabla y hace clic en OK, el sistema realiza varias acciones. Primero, se llama a la función `Show-SelectionTable`, que analiza la estructura de los datos seleccionados: si son objetos con propiedades, identifica todos los campos únicos y muestra los datos usando `Format-Table` con ajuste automático de tamaño y ajuste de línea. Si son valores simples, los muestra como una lista numerada. Luego, muestra un contador de los elementos seleccionados y el mensaje "Selección guardada. Agregue su próxima consulta (por ejemplo, 'compárelos')."

Los datos seleccionados se convierten a un JSON comprimido con una profundidad de anidamiento de 10 niveles y se guardan en la variable `$selectionContextJson` para su uso en solicitudes posteriores a la IA.

## Mantenimiento del historial

Cada par "consulta de usuario - respuesta de IA" se guarda en el archivo de historial en formato JSONL. Esto asegura la continuidad del diálogo: la IA "recuerda" toda la conversación anterior y puede referirse a temas discutidos previamente.

## El ciclo continúa

Después de procesar la solicitud, el sistema vuelve a esperar una nueva entrada. Si el usuario tiene una selección activa, esto se refleja en el prompt de la línea de comandos. El ciclo continúa hasta que el usuario ingresa un comando de salida.

## Ejemplo práctico de funcionamiento

Imagine que un usuario ejecuta el script y escribe "RTX 4070 Ti Super":

1.  **Preparación del contexto:** El sistema toma el prompt del sistema del archivo, agrega el historial (actualmente vacío) y la nueva consulta.
2.  **Solicitud a la IA:** El prompt completo se envía a Gemini con una solicitud para encontrar las especificaciones de las tarjetas de video.
3.  **Recuperación de datos:** La IA devuelve un JSON con una matriz de objetos que contienen información sobre varios modelos de RTX 4070 Ti Super.
4.  **Tabla interactiva:** El usuario ve una tabla con fabricantes, especificaciones y precios, y selecciona 2-3 modelos de interés.
5.  **Visualización de la selección:** Aparece una tabla con los modelos seleccionados en la consola, y el prompt cambia a `[Selección activa]`.
6.  **Refinar consulta:** El usuario escribe "comparar su rendimiento en juegos".
7.  **Análisis contextual:** La IA recibe la consulta inicial, los modelos seleccionados y la nueva pregunta, proporcionando una comparación detallada de esas tarjetas específicas.

## Terminación

Cuando se ingresa `exit` o `quit`, el script termina correctamente, habiendo guardado todo el historial de la sesión en un archivo. El usuario puede volver a este diálogo en cualquier momento viendo el contenido del archivo correspondiente en la carpeta `.chat_history`.

Toda esta lógica compleja está oculta al usuario detrás de una interfaz de línea de comandos simple. La persona simplemente hace preguntas y recibe respuestas estructuradas, mientras que el sistema se encarga de todo el trabajo de mantener el contexto, analizar datos y administrar el estado del diálogo.

---

## Paso 1: Configuración

```powershell
# --- Paso 1: Configuración ---
$env:GEMINI_API_KEY = "AIzaSyCbq8bkt5Xr2hlE-73MIXFpdFYH-rLBd0k"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
# --- CAMBIO: Variable renombrada ---
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
# --- FIN DEL CAMBIO ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName
```

**Propósito de las líneas:**

- `$env:GEMINI_API_KEY = "..."` - establece la clave API para acceder a Gemini AI.
- `if (-not $env:GEMINI_API_KEY)` - verifica la presencia de la clave y termina el script si falta.
- `$scriptRoot = Get-Location` - obtiene el directorio de trabajo actual.
- `$HistoryDir = Join-Path...` - forma la ruta a la carpeta para almacenar el historial de diálogos (`.gemini/.chat_history`).
- `$timestamp = Get-Date...` - crea una marca de tiempo en el formato `2025-08-26_14-30-15`.
- `$historyFileName = "ai_session_$timestamp.jsonl"` - genera un nombre de archivo de sesión único.
- `$historyFilePath = Join-Path...` - crea la ruta completa al archivo de historial de la sesión actual.

## Verificación del entorno - Qué debe instalarse

```powershell
# --- Paso 2: Verificación del entorno ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } 
catch { Write-Error "El comando 'gemini' no se encontró..."; return }

if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { 
    Write-Warning "El archivo de prompt del sistema .gemini/GEMINI.md no se encontró..." 
}
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { 
    Write-Warning "El archivo de ayuda .gemini/ShowHelp.md no se encontró..." 
}
```

**Qué se verifica:**

- La presencia de **Gemini CLI** en el sistema: el script no funcionará sin él.
- El archivo **GEMINI.md**: contiene el prompt del sistema (instrucciones para la IA).
- El archivo **ShowHelp.md**: ayuda al usuario (el comando `?`).

## Función principal para interactuar con la IA

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
    catch { Write-Error "Error crítico al llamar a Gemini CLI: $_"; return $null }
}
```

**Tareas de la función:**
- Llama al CLI de Gemini con el modelo y el prompt especificados.
- Captura toda la salida (incluidos los errores).
- Limpia el resultado de los mensajes de servicio del CLI.
- Devuelve la respuesta limpia de la IA o `$null` en caso de error.

## Funciones de gestión del historial

```powershell
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}

function Show-History {
    if (-not (Test-Path $historyFilePath)) { Write-Host "El historial de la sesión actual está vacío." -ForegroundColor Yellow; return }
    Write-Host "`n--- Historial de la sesión actual ---" -ForegroundColor Cyan
    Get-Content -Path $historyFilePath
    Write-Host "------------------------------------`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $historyFilePath) {
        Remove-Item -Path $historyFilePath -Force -ErrorAction Stop
        Write-Host "El historial de la sesión actual ($historyFileName) ha sido eliminado." -ForegroundColor Yellow
    }
}
```

**Propósito:**
- `Add-History`: guarda pares "pregunta-respuesta" en formato JSONL.
- `Show-History`: muestra el contenido del archivo de historial.
- `Clear-History`: elimina el archivo de historial de la sesión actual.

## Función para mostrar datos seleccionados

```powershell
function Show-SelectionTable {
    param([array]$SelectedData)
    
    if ($null -eq $SelectedData -or $SelectedData.Count -eq 0) { return }
    
    Write-Host "`n--- DATOS SELECCIONADOS ---" -ForegroundColor Yellow
    
    # Obtener todas las propiedades únicas de los objetos seleccionados
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # Mostrar una tabla o una lista
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    } else {
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
    
    Write-Host "-------------------------" -ForegroundColor Yellow
    Write-Host "Elementos seleccionados: $($SelectedData.Count)" -ForegroundColor Magenta
}
```

**Tarea de la función:** Después de seleccionar elementos en `Out-ConsoleGridView`, los muestra en la consola como una tabla ordenada, para que el usuario pueda ver exactamente lo que se eligió.

## Bucle de trabajo principal

```powershell
while ($true) {
    # Mostrar prompt con indicador de estado
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [Selección activa] :) > "
    } else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    
    $UserPrompt = Read-Host
    
    # Manejar comandos de servicio
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }
    
    # Formar el prompt completo con contexto
    $fullPrompt = @"
### HISTORIAL DE DIÁLOGO (CONTEXTO)
$historyContent

### DATOS DE LA SELECCIÓN (PARA ANÁLISIS)
$selectionContextJson

### NUEVA TAREA
$UserPrompt
"@
    
    # Llamar a la IA y procesar la respuesta
    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
    
    # Intentar analizar JSON y mostrar la tabla interactiva
    try {
        $jsonObject = $jsonToParse | ConvertFrom-Json
        $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Seleccionar filas..." -OutputMode Multiple
        
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

**Características clave:**
- El indicador `[Selección activa]` muestra que hay datos para analizar.
- Cada consulta incluye el historial completo del diálogo para mantener el contexto.
- La IA recibe tanto el historial como los datos seleccionados por el usuario.
- El resultado se intenta mostrar como una tabla interactiva.
- Si el análisis de JSON falla, se muestra texto sin formato.

## Estructura de archivos de trabajo

El script crea la siguiente estructura:
```
├── Find-Spec.ps1
├── .gemini/
│   ├── GEMINI.md              # Prompt del sistema para la IA
│   ├── ShowHelp.md            # Ayuda del usuario
│   └── .chat_history/         # Carpeta con el historial de sesiones
│       ├── ai_session_2025-08-26_10-15-30.jsonl
│       └── ai_session_2025-08-26_14-22-45.jsonl
```

El archivo `GEMINI.md` en la carpeta `.gemini/` es la ubicación estándar para el prompt del sistema para el CLI de Gemini. En cada ejecución, el modelo carga automáticamente las instrucciones de este archivo, lo que define su comportamiento y el formato de sus respuestas.

En la siguiente parte, examinaremos el contenido de los archivos de configuración y ejemplos de uso práctico.