# Filosofía de PowerShell.
## Parte 2: La canalización, las variables, Get-Member, los archivos *.ps1* y la exportación de resultados
**❗ Importante:**
Estoy escribiendo sobre PS7 (PowerShell 7). Es diferente de PS5 (PowerShell 5). A partir de la versión 7, PS se convirtió en multiplataforma. Debido a esto, el comportamiento de algunos comandos ha cambiado.

En la primera parte, establecimos un principio clave: PowerShell funciona con **objetos**, no con texto. Esta publicación está dedicada a algunas herramientas importantes de PowerShell: aprenderemos a pasar objetos a través de la **canalización**, a analizarlos con **`Get-Member`**, a guardar los resultados en **variables** y a automatizar todo esto en **archivos de script (`.ps1`)** con la **exportación** de resultados a formatos convenientes.

### 1. ¿Qué es la canalización (`|`)?
La canalización en PowerShell es un mecanismo para pasar objetos .NET completos (no solo texto) de un comando a otro, donde cada cmdlet posterior recibe objetos estructurados con todas sus propiedades y métodos.

El símbolo `|` (barra vertical) es el operador de canalización. Su trabajo es tomar el resultado (salida) del comando a su izquierda и pasarlo como entrada al comando a su derecha.

`Comando 1 (crea objetos)` → `|` → `Comando 2 (recibe y procesa objetos)` → `|` → `Comando 3 (recibe objetos procesados)` → | ...

#### La canalización clásica de UNIX: un flujo de texto

En `bash`, se pasa un **flujo de bytes** a través de la canalización, que generalmente se interpreta como texto.

```bash
# Encontrar todos los procesos 'nginx' y contarlos
ps -ef | grep 'nginx' | wc -l
```
Aquí, `ps` genera texto, `grep` filtra este texto y `wc` cuenta las líneas. Cada utilidad no sabe nada sobre los "procesos"; solo funciona con cadenas.

#### La canalización de PowerShell: un flujo de objetos
**Ejemplo:** Obtengamos todos los procesos, ordenémoslos por uso de CPU y seleccionemos los 5 más "hambrientos".

```powershell
Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5
```
![1](assets/02/1.png)

Aquí, `Get-Process` crea **objetos** de proceso. `Sort-Object` recibe estos **objetos** y los ordena por la propiedad `CPU`. `Select-Object` recibe los **objetos** ordenados y selecciona los primeros 5.

Probablemente haya notado palabras en el comando que comienzan con un guión (-): -Property, -Descending, -First. Estos son parámetros.
Los parámetros son configuraciones, modificadores e instrucciones para un cmdlet. Le permiten controlar **CÓMO** un comando hará su trabajo. Sin parámetros, un comando funciona en su modo predeterminado, pero con parámetros, le da instrucciones específicas.

Tipos principales de parámetros:

- Parámetro con un valor: requiere información adicional.

    `-Property CPU`: le estamos diciendo a Sort-Object por qué propiedad ordenar. CPU es el valor del parámetro.
    
    `-First 5`: le estamos diciendo a Select-Object cuántos objetos seleccionar. 5 es el valor del parámetro.

- Parámetro de modificador (bandera): no requiere un valor. Su mera presencia en el comando habilita o deshabilita un determinado comportamiento.

   `-Descending`: esta bandera le dice a Sort-Object que invierta el orden de clasificación (de mayor a menor). No necesita un valor adicional, es una instrucción en sí misma.

```powershell
Get-Process -Name 'svchost' | Measure-Object
```
![1](assets/02/2.png)
Este comando responde a una pregunta muy simple:
**"¿Cuántos procesos llamados `svchost.exe` se están ejecutando actualmente en mi sistema?"**

#### Desglose paso a paso

##### **Paso 1: `Get-Process -Name 'svchost'`**

Esta parte del comando consulta al sistema operativo y le pide que encuentre **todos** los procesos en ejecución cuyo nombre de archivo ejecutable sea `svchost.exe`.
A diferencia de los procesos como `notepad` (de los cuales suele haber uno o dos), siempre hay **muchos** procesos `svchost` en el sistema. El comando devolverá una **matriz (colección) de objetos**, donde cada objeto es un proceso `svchost` separado y completo con su propia ID única, uso de memoria, etc.
PowerShell ha encontrado, por ejemplo, 90 procesos `svchost` en el sistema y ahora tiene una colección de 90 objetos.

##### **Paso 2: `|` (operador de canalización)**

Este símbolo toma la colección de 90 objetos `svchost` obtenidos en el primer paso y comienza a pasarlos **uno por uno** a la entrada del siguiente comando.

##### **Paso 3: `Measure-Object`**

Como llamamos a `Measure-Object` sin parámetros (como `-Property`, `-Sum`, etc.), realiza su operación **predeterminada**: simplemente cuenta el número de "elementos" que se le pasaron.
Uno, dos, tres... Después de que se hayan contado todos los objetos, `Measure-Object` crea su **propio objeto de resultado**, que tiene una propiedad `Count` igual al número final.


**`Count: 90`** — esta es la respuesta a nuestra pregunta. Hay 90 procesos `svchost` en ejecución.
Los otros campos están vacíos porque no le pedimos a `Measure-Object` que realizara cálculos más complejos.


#### Ejemplo con `svchost` y parámetros

Cambiemos nuestra tarea. Ahora no solo queremos contar los procesos de `svchost`, sino también averiguar **cuánta RAM total (en megabytes) consumen en conjunto**.

Para hacer esto, necesitaremos parámetros:
*   `-Property WorkingSet64`: esta instrucción le dice a `Measure-Object`: "De cada objeto `svchost` que te llegue, toma el valor numérico de la propiedad `WorkingSet64` (este es el uso de la memoria en bytes)".
*   `-Sum`: esta instrucción de bandera dice: "Suma todos estos valores que tomaste de la propiedad `WorkingSet64`".

Nuestro nuevo comando se verá así:
```powershell
Get-Process -Name 'svchost' | Measure-Object -Property WorkingSet64 -Sum
```
![3](assets/02/3.png)

1.  `Get-Process` encontrará el número de objetos `svchost`.
2.  La canalización `|` los pasará a `Measure-Object`.
3.  Pero ahora `Measure-Object` funciona de manera diferente:
    *   Toma el primer objeto `svchost`, mira su propiedad `.WorkingSet64` (por ejemplo, `25000000` bytes) y recuerda este número.
    *   Toma el segundo objeto, mira su `.WorkingSet64` (por ejemplo, `15000000` bytes) y lo suma al anterior.
    *   ...y así sucesivamente para todos los objetos.
4.  Como resultado, `Measure-Object` creará un objeto de resultado, pero ahora será diferente.


*   **`Count: 92`**: el número de objetos.
*   **`Sum: 1661890560`**: esta es la suma total de todos los valores de `WorkingSet64` en bytes.
*   **`Property: WorkingSet64`**: este campo ahora también está lleno; nos informa qué propiedad se utilizó para los cálculos.




### 2. Variables (regulares y la especial `$_`)

Una variable es un almacenamiento con nombre en la memoria que contiene algún valor.

Este valor puede ser cualquier cosa: texto, un número, una fecha o, lo que es más importante para PowerShell, un objeto completo o incluso una colección de objetos. Un nombre de variable en PowerShell siempre comienza con un signo de dólar ($).
Ejemplos: $name, $counter, $processList.

¿La variable especial $_?

$_ es la abreviatura de "el objeto actual" o "esta cosa de aquí".
Imagine una cinta transportadora en una fábrica. Diferentes partes (objetos) se mueven a lo largo de ella.

$_ es la parte misma que está justo frente a usted (o frente al robot de procesamiento).

La fuente (Get-Process) vierte una caja entera de partes (todos los procesos) en la cinta transportadora.

La canalización (|) hace que estas partes se muevan a lo largo de la cinta una por una.

El controlador (Where-Object o ForEach-Object) es un robot que mira cada parte.

La variable $_ es la parte misma que se encuentra actualmente en las "manos" del robot.

Cuando el robot termina con una parte, la cinta transportadora le alimenta la siguiente, y $_ ahora apuntará a ella.



Calculemos cuánta memoria total usan los procesos de `svchost` y mostremos el resultado en el monitor.
```powershell
# 1. Ejecute el comando y guarde su objeto de resultado complejo en la variable $svchostMemory
$svchostMemory = Get-Process -Name svchost | Measure-Object -Property WorkingSet64 -Sum

# 2. Ahora podemos trabajar con el objeto guardado. Obtengamos la propiedad Sum de él
$memoryInMB = $svchostMemory.Sum / 1MB

# 3. Muestre el resultado en la pantalla usando la nueva variable
Write-Host "Todos los procesos de svchost están usando $memoryInMB MB de memoria."
```
![3](assets/02/4.png)

*   `Write-Host` es un cmdlet especializado cuyo único propósito es **mostrar texto directamente al usuario en la consola**.

*   Una cadena entre comillas dobles: `"..."` es una cadena de texto que pasamos al cmdlet `Write-Host` como argumento. ¿Por qué comillas dobles y no comillas simples?
    
    En PowerShell, hay dos tipos de comillas:
    
    *   **Simples (`'...'`)**: crean una **cadena literal**. Todo lo que está dentro de ellas se trata como texto sin formato, sin excepciones.
    *   **Dobles (`"..."`)**: crean una **cadena expandible (o sustituible)**. PowerShell "escanea" dicha cadena en busca de variables (que comienzan con `$`) y sustituye sus valores en su lugar.

* `$memoryInMB`. Esta es la variable en la que **en el paso anterior** de nuestro script pusimos el resultado de los cálculos. Cuando `Write-Host` recibe una cadena entre comillas dobles, se produce un proceso llamado **"Expansión de cadena"**:
    1.  PowerShell ve el texto `"Todos los procesos de svchost están usando "`.
    2.  Luego encuentra la construcción `$memoryInMB`. Entiende que esto no es solo texto, sino una variable.
    3.  Busca en la memoria, encuentra el valor almacenado en `$memoryInMB` (por ejemplo, `1585.52`).
    4.  **Sustituye este valor** directamente en la cadena.
    5.  Luego agrega el resto del texto: `" MB de memoria."`.
    6.  Como resultado, la cadena ya ensamblada se pasa a `Write-Host`: `"Todos los procesos de svchost están usando 1585.52 MB de memoria."`.



Inicie el Bloc de notas:
 1. Busque el proceso del Bloc de notas y guárdelo en la variable $notepadProcess
 ```powershell
$notepadProcess = Get-Process -Name notepad
```

 2. Acceda a la propiedad 'Id' de este objeto a través del punto y muéstrela
 ```powershell
Write-Host "El ID del proceso 'Bloc de notas' es: $($notepadProcess.Id)"
```
![5](assets/02/5.png)

**❗ Importante:**
    Write-Host "rompe" la canalización. El texto que genera no se puede pasar más adelante en la canalización para su procesamiento. Solo está destinado a la visualización.

### 3. Get-Member (el inspector de objetos)

Sabemos que los objetos "fluyen" a través de la canalización. Pero, ¿cómo sabemos de qué están hechos? ¿Qué propiedades tienen y qué acciones (métodos) se pueden realizar en ellos?

El cmdlet **`Get-Member`** (alias: `gm`) es la principal herramienta de investigación.
Antes de trabajar con un objeto, páselo por `Get-Member` para ver todas sus capacidades.

Analicemos los objetos que crea `Get-Process`:
```powershell
Get-Process | Get-Member
```
![6](assets/02/6.png)

*Analicemos cada parte de la salida de Get-Member.*

`TypeName: System.Diagnostics.Process`: este es el "nombre de tipo" completo y oficial del objeto de la biblioteca .NET. Este es su "pasaporte".
Esta línea le indica que todos los objetos devueltos por Get-Process son objetos de tipo System.Diagnostics.Process.
Esto garantiza que todos tendrán el mismo conjunto de propiedades y métodos.
Puede [buscar en Google](https://www.google.com/search?q=System.Diagnostics.Process+site%3Amicrosoft.com) "System.Diagnostics.Process" para encontrar la documentación oficial de Microsoft con información aún más detallada.



- Columna 1: `Name`

Este es un **nombre** simple y legible por humanos de una propiedad, método u otro "miembro" de un objeto. Este es el nombre que usará en su código para acceder a los datos o realizar acciones.



- Columna 2: `MemberType` (tipo de miembro)

Esta es la columna más importante de entender. Clasifica **qué** es cada miembro. Este es su "título de trabajo" que le dice **CÓMO** usarlo.

*   **`Property` (propiedad):** una **característica** o **porción de datos** almacenada dentro de un objeto. Puede "leer" su valor.
    *   *Ejemplos de la captura de pantalla:* `BasePriority`, `HandleCount`, `ExitCode`. Estos son solo datos que se pueden ver.

*   **`Method` (método):** una **ACCIÓN** que se puede realizar en un objeto. Los métodos siempre se llaman con paréntesis `()`.
    *   *Ejemplos de la captura de pantalla:* `Kill`, `Refresh`, `WaitForExit`. Escribiría `$process.Kill()` o `$process.Refresh()`.

*   **`AliasProperty` (propiedad de alias):** un **alias amigable** para otra propiedad más larga. PowerShell los agrega por conveniencia y brevedad.
    *   *Ejemplos de la captura de pantalla:* `WS` es un alias corto para `WorkingSet64`. `Name` es para `ProcessName`. `VM` es para `VirtualMemorySize64`.

*   **`Event` (evento):** una **NOTIFICACIÓN** de que algo ha sucedido, a la que puede "suscribirse".
    *   *Ejemplo de la captura de pantalla:* `Exited`. Su script puede "escuchar" este evento para realizar alguna acción inmediatamente después de que finalice el proceso.

*   **`CodeProperty` y `NoteProperty`:** tipos especiales de propiedades, a menudo agregados por el propio PowerShell por conveniencia. Una `CodeProperty` calcula su valor "sobre la marcha", y una `NoteProperty` es una propiedad de nota simple agregada a un objeto.

- Columna 3: `Definition` (definición)

Esta es la **definición técnica** o "firma" del miembro. Le da los detalles exactos para su uso. Su contenido depende del `MemberType`:

*   **Para `AliasProperty`:** muestra **a qué es igual el alias**. ¡Esto es increíblemente útil!
    *   *Ejemplo de la captura de pantalla:* `WS = WorkingSet64`. Puede ver de inmediato que `WS` es solo una notación corta para `WorkingSet64`.

*   **Para `Property`:** muestra el **tipo de datos** almacenado в la propiedad (p. ej., `int` para un entero, `string` para texto, `datetime` para una fecha y hora), y qué puede hacer con él (`{get;}` - solo lectura, `{get;set;}` - lectura y escritura).
    *   *Ejemplo de la captura de pantalla:* `int BasePriority {get;}`. Esta es una propiedad de entero que solo se puede leer.

*   **Para `Method`:** muestra lo que devuelve el método (p. ej., `void` - nada, `bool` - verdadero/falso) y qué **parámetros** (datos de entrada) acepta entre paréntesis.
    *   *Ejemplo de la captura de pantalla:* `void Kill()`. Esto significa que el método `Kill` no devuelve nada y se puede llamar sin parámetros. También hay una segunda versión `void Kill(bool entireProcessTree)` que acepta un valor booleano (verdadero/falso).

#### En forma de tabla

| Columna | ¿Qué es? | Ejemplo de la captura de pantalla | ¿Para qué? |
|---|---|---|---|
| **Name** | El nombre que usa en su código. | `Kill`, `WS`, `Name` | para acceder a una propiedad o método (`$process.WS`, `$process.Kill()`). |
| **MemberType**| El tipo de miembro (datos, acción, etc.). | `Method`, `Property`, `AliasProperty` | **cómo** usarlo (leer un valor o llamar con `()`). |
| **Definition** | Detalles técnicos. | `WS = WorkingSet64`, `void Kill()` | qué se esconde detrás de un alias y qué parámetros necesita un método. |



#### Ejemplo: Trabajar con ventanas de procesos

##### 1. El problema:
"He abierto muchas ventanas del Bloc de notas. ¿Cómo puedo minimizar mediante programación todas menos la principal y luego cerrar solo la que tiene la palabra 'Sin título' en su título?"

##### 2. Investigación con `Get-Member`:
Necesitamos encontrar propiedades relacionadas con la ventana y su título.

```powershell
Get-Process -Name notepad | Get-Member
```
**Análisis del resultado de `Get-Member`:**
*   Al desplazarse por las propiedades, encontramos `MainWindowTitle`. El tipo es `string`. ¡Genial, este es el título de la ventana principal!
*   En los métodos, vemos `CloseMainWindow()`. Esta es una forma más "suave" de cerrar una ventana que `Kill()`.
*   También en los métodos, está `WaitForInputIdle()`. Suena interesante; quizás ayude a esperar hasta que el proceso esté listo para la interacción.

![7](assets/02/7.png)

`Get-Member` nos mostró la propiedad `MainWindowTitle`, que es la clave para resolver el problema y nos permite interactuar con los procesos en función del estado de sus ventanas, y no solo por su nombre.

##### 3. La solución:
Ahora podemos construir una lógica basada en el título de la ventana.

```powershell
# 1. Encontrar todos los procesos del Bloc de notas
$notepads = Get-Process -Name notepad

# 2. Recorrer cada uno y verificar el título
foreach ($pad in $notepads) {
    # Para cada proceso ($pad), verifique su propiedad MainWindowTitle
    if ($pad.MainWindowTitle -like '*Untitled*') {
        Write-Host "Se encontró un Bloc de notas sin guardar (ID: $($pad.Id)). Cerrando su ventana..."
        # $pad.CloseMainWindow() # Descomente para cerrar realmente
        Write-Host "La ventana '$($pad.MainWindowTitle)' se habría cerrado." -ForegroundColor Yellow
    } else {
        Write-Host "Omitiendo el Bloc de notas con el título: $($pad.MainWindowTitle)"
    }
}
```

![8](assets/02/8.png)

![9](assets/02/9.png)


---

#### Ejemplo: Encontrar el proceso principal

##### 1. El problema:
"A veces veo muchos procesos secundarios `chrome.exe` en el sistema. ¿Cómo puedo saber cuál es el proceso principal, el proceso "padre" que los inició a todos?"

##### 2. Investigación con `Get-Member`:
Necesitamos encontrar algo que vincule un proceso con otro.

```powershell
Get-Process -Name chrome | Select-Object -First 1 | Get-Member
```
![10](assets/02/10.png)

**Análisis del resultado de `Get-Member`:**
*   Al examinar cuidadosamente la lista, encontramos una propiedad de tipo `CodeProperty` llamada `Parent`.
*   Su `Definition` es `System.Diagnostics.Process Parent{get=GetParentProcess;}`.
Esta es una propiedad calculada que, cuando se accede a ella, devuelve el **objeto del proceso principal**.

##### 3. La solución:
Ahora podemos escribir un script que, para cada proceso de `chrome`, mostrará información sobre su padre.

```powershell
# 1. Obtener todos los procesos de chrome
$chromeProcesses = Get-Process -Name chrome

# 2. Para cada uno de ellos, mostrar información sobre él y su padre
$chromeProcesses | Select-Object -First 5 | ForEach-Object {
    # Obtener el proceso principal
    $parent = $_.Parent
    
    # Formatear una salida agradable
    Write-Host "Proceso:" -ForegroundColor Green
    Write-Host "  - Nombre: $($_.ProcessName), ID: $($_.Id)"
    Write-Host "Su padre:" -ForegroundColor Yellow
    Write-Host "  - Nombre: $($parent.ProcessName), ID: $($parent.Id)"
    Write-Host "-----------------------------"
}
```
![11](assets/02/11.png)

![12](assets/02/12.png)

Podemos ver de inmediato que los procesos con los ID 4756, 7936, 8268 y 9752 fueron iniciados por el proceso con el ID 14908. También podemos notar un caso interesante con el ID de proceso: 7252, cuyo proceso principal no se determinó (quizás el padre ya había finalizado en el momento de la verificación). La modificación del script con una verificación if ($parent) maneja este caso de forma ordenada sin causar un error.
Get-Member nos ayudó a descubrir la propiedad "oculta" Parent, que proporciona potentes capacidades para analizar la jerarquía de procesos.

#### 4. El archivo *.ps1* (creación de scripts)

Cuando su cadena de comandos se vuelve útil, querrá guardarla para un uso repetido. Para eso están los **scripts**: archivos de texto con la extensión **`.ps1`**.

##### Permiso para ejecutar scripts
De forma predeterminada, Windows prohíbe la ejecución de scripts locales. Para solucionar esto **para el usuario actual**, ejecute lo siguiente una vez en PowerShell **como administrador**:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Esta es una configuración segura que le permite ejecutar sus propios scripts y scripts firmados por un editor de confianza.

##### Script de ejemplo `system_monitor.ps1`
Cree un archivo con este nombre y pegue el código a continuación. Este script recopila información del sistema y genera informes.

```powershell
# system_monitor.ps1
#requires -Version 5.1

<#
.SYNOPSIS
    Un script para crear un informe de estado del sistema.
.DESCRIPTION
    Recopila información sobre procesos, servicios y espacio en disco y genera informes.
.PARAMETER OutputPath
    La ruta para guardar los informes. El valor predeterminado es 'C:\Temp'.
.EXAMPLE
    .\system_monitor.ps1 -OutputPath "C:\Reports"
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\Temp"
)

# --- Bloque 1: Preparación ---
Write-Host "Preparando la creación del informe..." -ForegroundColor Cyan
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# --- Bloque 2: Recopilación de datos ---
Write-Host "Recopilando información..." -ForegroundColor Green
$processes = Get-Process | Sort-Object CPU -Descending
$services = Get-Service | Group-Object Status | Select-Object Name, Count

# --- Bloque 3: Llamar a la función de exportación (ver la siguiente sección) ---
Export-Results -Processes $processes -Services $services -OutputPath $OutputPath

Write-Host "Informes guardados correctamente en la carpeta $OutputPath" -ForegroundColor Magenta
```
*Nota: La función `Export-Results` se definirá en la siguiente sección como un ejemplo de buena práctica.*

#### 5. Exportar resultados

Los datos sin procesar son buenos, pero a menudo deben presentarse en una forma que sea conveniente para una persona u otro programa. PowerShell ofrece muchos cmdlets para exportar.

| Método | Comando | Descripción |
|---|---|---|
| **Texto sin formato** | `... \| Out-File C:\Temp\data.txt` | Redirige la representación de texto a un archivo. |
| **CSV (para Excel)** | `... \| Export-Csv C:\Temp\data.csv -NoTypeInfo` | Exporta objetos a CSV. `-NoTypeInfo` elimina la primera línea de servicio. |
| **Informe HTML** | `... \| ConvertTo-Html -Title "Informe"` | Crea código HTML a partir de objetos. |
| **JSON (para API, web)** | `... \| ConvertTo-Json` | Convierte objetos a formato JSON. |
| **XML (formato nativo de PowerShell)** | `... \| Export-Clixml C:\Temp\data.xml` | Guarda objetos con todos los tipos de datos. Se pueden restaurar perfectamente a través de `Import-Clixml`. |

##### Adición al script: función de exportación
Agreguemos una función a nuestro script `system_monitor.ps1` que se encargará de la exportación. Coloque este código **antes** de la llamada a `Export-Results`.

```powershell
function Export-Results {
    param(
        $Processes,
        $Services,
        $OutputPath
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

    # Exportar a CSV
    $Processes | Select-Object -First 20 | Export-Csv (Join-Path $OutputPath "processes_$timestamp.csv") -NoTypeInformation
    $Services | Export-Csv (Join-Path $OutputPath "services_$timestamp.csv") -NoTypeInformation

    # Crear un bonito informe HTML
    $htmlReportPath = Join-Path $OutputPath "report_$timestamp.html"
    $processesHtml = $Processes | Select-Object -First 10 Name, Id, CPU | ConvertTo-Html -Fragment -PreContent "<h2>Los 10 procesos principales por CPU</h2>"
    $servicesHtml = $Services | ConvertTo-Html -Fragment -PreContent "<h2>Estadísticas de servicio</h2>"

    ConvertTo-Html -Head "<title>Informe del sistema</title>" -Body "<h1>Informe del sistema de $(Get-Date)</h1> $($processesHtml) $($servicesHtml)" | Out-File $htmlReportPath
}
```
Ahora nuestro script no solo recopila datos, sino que también los guarda ordenadamente en dos formatos: CSV para análisis y HTML para una visualización rápida.

#### Conclusión

1.  **La canalización (`|`)** es la herramienta principal para combinar comandos y procesar objetos.
2.  **`Get-Member`** es un analizador de objetos que muestra de qué están hechos.
3.  **Las variables (`$var`, `$_`)** le permiten guardar datos y hacer referencia al objeto actual en la canalización.
4.  **Los archivos `.ps1`** convierten los comandos en herramientas de automatización reutilizables.
5.  **Los cmdlets de exportación** (`Export-Csv`, `ConvertTo-Html`) exportan datos en el formato apropiado.

**En la siguiente parte, aplicaremos este conocimiento para navegar y administrar el sistema de archivos, explorando los objetos `System.IO.DirectoryInfo` y `System.IO.FileInfo`.**
