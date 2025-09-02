# Filosofía PowerShell.

## Parte 4: Trabajo interactivo: `Out-ConsoleGridView`, alertas.

- En la [primera parte](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/01.md) definimos dos conceptos clave de PowerShell: la tubería y el objeto.

- En la [segunda parte](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/02.md) expliqué qué son los objetos y la tubería.

- En la [tercera parte](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/03.md) nos familiarizamos con el sistema de archivos y los proveedores.

- Hoy veremos el trabajo interactivo con datos en la consola, así como las alertas y notificaciones.

### Capítulo uno: Trabajo interactivo con datos en la consola.

#### `Out-ConsoleGridView`. GUI en la consola de PowerShell.

**❗ Importante:** Todas las herramientas descritas a continuación requieren **PowerShell 7.2 o posterior**.

`Out-ConsoleGridView` es una tabla interactiva, directamente en la consola de PowerShell, que permite:
- ver datos en formato de tabla;
- filtrar y ordenar columnas;
- seleccionar filas con el cursor – para pasarlas por la tubería;
- y mucho más.

`Out-ConsoleGridView` forma parte del módulo `Microsoft.PowerShell.ConsoleGuiTools`. Para usarlo, primero debe instalar este módulo.

Para instalar el módulo, ejecute el siguiente comando en PowerShell:
```powershell
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
```
![Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser](assets/04/1.png)

`Install-Module` descarga e instala el módulo especificado desde el repositorio en el sistema. Análogos: `pip install` en `Python` o `npm install` en `Node.js`.

📎 Parámetros clave de `Install-Module`

------------------------------------------------------------------------------------------------------------------------------------------------------
| Parámetro | Descripción | 
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------- | 
| `-Name` | Nombre del módulo a instalar. | 
| `-Scope` | Ámbito de instalación: `AllUsers` (predeterminado, requiere derechos de administrador) o `CurrentUser` (no requiere derechos de administrador). | 
| `-Repository` | Especifica el repositorio, por ejemplo `PSGallery`. | 
| `-Force` | Instalación forzada sin confirmación. | 
| `-AllowClobber` | Permite sobrescribir comandos existentes. | 
| `-AcceptLicense` | Acepta automáticamente la licencia del módulo. | 
| `-RequiredVersion` | Instala una versión específica del módulo. |

Después de la instalación, puede pasar cualquier salida a `Out-ConsoleGridView` para un trabajo interactivo.

```powershell   
# Ejemplo clásico: mostrar una lista de procesos en una tabla interactiva
Get-Process | Out-ConsoleGridView
```

[1](https://github.com/user-attachments/assets/5828dd51-cfb8-4904-87be-796ccc8395be)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/5828dd51-cfb8-4904-87be-796ccc8395be" type="video/mp4">
  Your browser does not support the video tag.
</video>

**Interfaz:**
*   **Filtrado:** Simplemente comience a escribir texto, y la lista se filtrará sobre la marcha.
*   **Navegación:** Use las teclas de flecha para moverse por la lista.
*   **Selección:** Presione `Espacio` para seleccionar/deseleccionar un elemento.
*   **Selección múltiple:** `Ctrl+A` para seleccionar todos los elementos, `Ctrl+D` para deseleccionar todo.
*   **Confirmación:** Presione `Enter` para devolver los objetos seleccionados.
*   **Cancelación:** Presione `ESC` para cerrar la ventana sin devolver datos.

## Qué puede hacer `Out-ConsoleGridView`:

* Mostrar datos tabulares directamente en la consola en forma de tabla interactiva con navegación por filas y columnas.
* Ordenar columnas presionando teclas.
* Filtrar datos usando la búsqueda.
* Seleccionar una o varias filas con devolución del resultado.
* Trabajar en una consola limpia sin ventanas GUI.
* Admitir una gran cantidad de filas con desplazamiento.
* Admitir varios tipos de datos (cadenas, números, fechas, etc.).

--- 

## Ejemplos de uso de `Out-ConsoleGridView`

### Uso básico: mostrar una tabla con la opción de selección interactiva. (casilla de verificación)

```powershell
Import-Module Microsoft.PowerShell.ConsoleGuiTools

$data = Get-Process | Select-Object -First 30 -Property Id, ProcessName, CPU, WorkingSet

# Mostrar tabla con opciones de filtrado, ordenación y selección de filas
$selected = $data | Out-ConsoleGridView -Title "Select process(es)" -OutputMode Multiple

$selected | Format-Table -AutoSize
```

[2](https://github.com/user-attachments/assets/3f1a2a62-066f-4dbb-947a-9b26095da356)

<video>
  <source src="https://github.com/user-attachments/assets/3f1a2a62-066f-4dbb-947a-9b26095da356" type="video/mp4">
  Your browser does not support the video tag.
</video>

Se muestra una lista de procesos en una tabla interactiva de consola. Se puede filtrar por nombre, ordenar columnas y seleccionar procesos. Los procesos seleccionados se devuelven a la variable `$selected`.

--- 

### Selección de una sola fila con devolución obligatoria del resultado. (radio)

```powershell
$choice = Get-Service | Select-Object -First 20 | Out-ConsoleGridView -Title "Select a service" -OutputMode Single

Write-Host "You selected service: $($choice.Name)"
```

[](https://github.com/user-attachments/assets/5ee8fb92-8e18-496a-9db7-2d86b243742e)

<video>
  <source src="https://github.com/user-attachments/assets/5ee8fb92-8e18-496a-9db7-2d86b243742e" type="video/mp4">
  Your browser does not support the video tag.
</video>

El usuario selecciona una sola fila (servicio). `-OutputMode Single` prohíbe seleccionar varias.

--- 

### Filtrado y ordenación de grandes matrices

```powershell
$data = 1..1000 | ForEach-Object { 
    [PSCustomObject]@{ 
        Number = $_ 
        Square = $_ * $_ 
        Cube    = $_ * $_ * $_ 
    } 
}

$data | Out-ConsoleGridView -Title "Numbers and powers"  -OutputMode Multiple
```

Muestra una tabla de 1000 filas con números y sus potencias.

### **Gestión interactiva de procesos:**

Puede seleccionar varios procesos para detener. El parámetro `-OutputMode Multiple` indica que queremos devolver todos los elementos seleccionados.

```powershell
# Pasar los resultados por la tubería.
# Detener los procesos seleccionados con el parámetro -WhatIf para una vista previa.
# Para ello, definiremos la variable $procsToStop
$procsToStop = Get-Process | Out-ConsoleGridView -OutputMode Multiple
    
# Si se seleccionó algo, pasar los objetos por la tubería
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```

### **Selección de archivos para archivar:**
Encontraremos todos los archivos `.log` en la carpeta, seleccionaremos los necesarios y crearemos un archivo a partir de ellos.

```powershell
$filesToArchive = Get-ChildItem -Path C:\Logs -Filter "*.log" -Recurse | Out-ConsoleGridView -OutputMode Multiple
```

❗ Tenga cuidado con la recursión

```powershell
if ($filesToArchive) {
    Compress-Archive -Path $filesToArchive.FullName -DestinationPath C:\Temp\LogArchive.zip
    
    # Agregar un mensaje de éxito
    Write-Host "✅ ¡Archivado completado con éxito!" -ForegroundColor Green
}
```

### **Selección de un elemento para análisis detallado:**

#### Patrón "Drill-Down" — de una lista general a detalles con `Out-ConsoleGridView`

A menudo, al trabajar con objetos del sistema, nos enfrentamos a un dilema:
1.  Si solicitamos **todas las propiedades** para **todos los objetos** (`Get-NetAdapter | Format-List *`), la salida será enorme e ilegible.
2.  Si mostramos una **tabla concisa**, perderemos detalles importantes.
3.  A veces, intentar obtener todos los datos a la vez puede provocar un error si uno de los objetos contiene valores incorrectos.

La solución a este problema es el patrón **"Drill-Down"** (detallado o "profundización"). Su esencia es simple:

*   **Paso 1 (Resumen):** Mostrar al usuario una lista de elementos limpia, concisa y segura para la **selección**.
*   **Paso 2 (Detalle):** Una vez que el usuario ha seleccionado un elemento específico, mostrarle **toda la información disponible** sobre ese elemento.

#### Ejemplo práctico: Creación de un explorador de adaptadores de red

Implementaremos este patrón usando el comando `Get-NetAdapter`.

**Tarea:** Primero, mostrar una lista concisa de adaptadores de red. Después de seleccionar uno, abrir una segunda ventana con todas sus propiedades.

**Código listo para usar:**
```powershell
# --- Etapa 1: Selección del adaptador de la lista concisa ---
$adapterList = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed
$selectedAdapter = $adapterList | Out-ConsoleGridView -Title "ETAPA 1: Seleccione un adaptador de red"

# --- Etapa 2: Mostrar información detallada o mensaje de cancelación ---
if ($null -ne $selectedAdapter) {
    # Obtener TODAS las propiedades para el adaptador SELECCIONADO
    $detailedInfoObject = Get-NetAdapter -Name $selectedAdapter.Name | Select-Object *

    # Usar nuestro truco con .psobject.Properties para transformar el objeto en una tabla conveniente "Nombre-Valor"
    $detailedInfoForGrid = $detailedInfoObject.psobject.Properties | Select-Object Name, Value
    
    # Abrir la SEGUNDA ventana GridView con la información completa
    $detailedInfoForGrid | Out-ConsoleGridView -Title "ETAPA 2: Información completa sobre '$($selectedAdapter.Name)'"
} else {
    Write-Host "Operación cancelada. No se seleccionó ningún adaptador." -ForegroundColor Yellow
}
```

#### Desglose paso a paso

1.  **Creación de una lista "segura":**
    `$adapterList = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed`
    No pasamos la salida de `Get-NetAdapter` directamente. En su lugar, creamos nuevos objetos "limpios" usando `Select-Object`, incluyendo solo las propiedades que necesitamos para la descripción general. Esto garantiza que los datos problemáticos que causaron el error serán descartados.

2.  **Primera ventana interactiva:**
    `$selectedAdapter = $adapterList | Out-ConsoleGridView ...`
    El script muestra la primera ventana y **detiene su ejecución**, esperando su selección. Tan pronto como seleccione una fila y presione `Enter`, el objeto correspondiente a esa fila se escribirá en la variable `$selectedAdapter`.

3.  **Verificación de la selección:**
    `if ($null -ne $selectedAdapter)`
    Esta es una verificación críticamente importante. Si el usuario presiona `Esc` o cierra la ventana, la variable `$selectedAdapter` estará vacía (`$null`). Esta verificación evita que el resto del código se ejecute y que ocurran errores.

4.  **Obtención de información completa:**
    `$detailedInfoObject = Get-NetAdapter -Name $selectedAdapter.Name`
    Aquí está el punto clave del patrón. Volvemos a llamar a `Get-NetAdapter`, pero esta vez solicitamos **solo un** objeto por su nombre, que tomamos del elemento seleccionado en la primera etapa. Ahora obtenemos el objeto completo con todas sus propiedades.

5.  **Transformación para la segunda ventana:**
    `$detailedInfoForGrid = $detailedInfoObject.psobject.Properties | ...`
    Usamos el potente truco que ya conoce para "desplegar" este objeto complejo único en una larga lista de pares "Nombre de propiedad" | "Valor", lo que es ideal para mostrar en una tabla.

6.  **Segunda ventana interactiva:**
    `$detailedInfoForGrid | Out-ConsoleGridView ...`
    Aparece una segunda ventana en la pantalla, esta vez con información exhaustiva sobre el adaptador que seleccionó.

--- 

### Ejemplo con título y sugerencias personalizados

Mostrar el registro de eventos de Windows en una tabla interactiva con el título "System Events".

```powershell
Get-EventLog -LogName System -Newest 50 |\
    Select-Object TimeGenerated, EntryType, Source, Message |\
    Out-ConsoleGridView -Title "System Events"  -OutputMode Multiple
```
Este código obtiene los 50 eventos más recientes del registro del sistema de Windows, selecciona solo cuatro propiedades clave de cada evento (hora, tipo, origen y mensaje) y los muestra en la ventana `Out-ConsoleGridView`.

----

### Información del sistema.

[1](https://github.com/user-attachments/assets/1e53a339-56f9-4add-8053-86d94dbc8e06)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1e53a339-56f9-4add-8053-86d94dbc8e06" type="video/mp4">
  Your browser does not support the video tag.
</video>

código del script para obtener información del sistema:
[Get-SystemMonitor.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/04/Get-SystemMonitor.ps1)

### Creación del cmdlet 'Get-SystemMonitor'

#### Paso 1: Configuración de la variable `PATH`

1.  **Cree una carpeta permanente para sus herramientas,** si aún no lo ha hecho. Por ejemplo:
    `C:\PowerShell\Scripts`

2.  **Coloque su archivo** `Get-SystemMonitor.ps1` en esta carpeta.

3.  **Agregue esta carpeta a la variable del sistema `PATH`**,

#### Paso 2: Configuración del alias en el perfil de PowerShell

Ahora que el sistema sabe dónde encontrar su script por su nombre completo, podemos crear un alias corto para él.

1.  **Abra su archivo de perfil de PowerShell**:
    ```powershell
    notepad $PROFILE
    ```

2.  **Agregue la siguiente línea:**
    ```powershell
    # Alias para el monitor del sistema
    Set-Alias -Name sysmon -Value "Get-SystemMonitor.ps1"
    ```

    **Tenga en cuenta el punto clave:** Dado que la carpeta con el script ya está en `PATH`, ¡ya **no necesitamos especificar la ruta completa** al archivo! Simplemente nos referimos a su nombre. Esto hace que su perfil sea más limpio y confiable. Si alguna vez mueve la carpeta `C:\PowerShell\Scripts`, solo necesitará actualizar la variable `PATH`, y su archivo de perfil permanecerá sin cambios.

#### Reinicie PowerShell

Cierre **todas** las ventanas de PowerShell abiertas y abra una nueva. Esto es necesario para que el sistema aplique los cambios tanto en la variable `PATH` como en su perfil.

---


### Resultado: Lo que obtiene

Después de realizar estos pasos, podrá llamar a su script **de dos maneras desde cualquier lugar del sistema**:

1.  **Por nombre completo (confiable, para usar en otros scripts):**
    ```powershell
    Get-SystemMonitor.ps1
    Get-SystemMonitor.ps1 -Resource storage
    ```

2.  **Por alias corto (conveniente, para trabajo interactivo):**
    ```powershell
    sysmon
    sysmon -Resource memory
    ```

Ha "registrado" con éxito su script en el sistema de la manera más profesional y flexible.

¿Útil? Suscríbase.
¿Le gustó? — ponga «+»
¡Buena suerte! 🚀

Otros artículos sobre PowerShell:
```