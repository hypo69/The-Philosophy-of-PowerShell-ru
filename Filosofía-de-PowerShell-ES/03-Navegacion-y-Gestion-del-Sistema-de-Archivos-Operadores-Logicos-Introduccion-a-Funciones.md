# Filosofía PowerShell.

### **Parte 3: Navegación y gestión del sistema de archivos. Operadores lógicos. Introducción a las funciones.**

En la [parte anterior](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/01.md), exploramos las tuberías y los objetos de proceso abstractos. Ahora, apliquemos nuestros conocimientos sobre tuberías y objetos a una de las tareas más comunes para un usuario o administrador: trabajar con el sistema de archivos. En PowerShell, este trabajo se basa en los mismos principios: los comandos devuelven objetos que pueden pasarse por la tubería para su posterior procesamiento.

***

### **1. Concepto de PowerShell Drives (PSDrives)**

Antes de empezar a trabajar con archivos, es importante entender el concepto de **PowerShell-unidades (PSDrives)**. A diferencia de `cmd.exe`, donde las unidades son solo letras `C:`, `D:` y así sucesivamente, en PowerShell, una "unidad" es una abstracción para acceder a cualquier almacenamiento de datos jerárquico.

```powershell
Get-PSDrive
```
El resultado mostrará no solo las unidades físicas, sino también las pseudo-unidades:

| Nombre | Proveedor | Raíz | Descripción |
|------|----------|------|----------|
| Alias | Alias | Alias:\ | Alias de comandos |
| C | FileSystem | C:\ | Unidad local C |
| Cert | Certificate | Cert:\ | Almacén de certificados |
| Env | Environment | Env:\ | Variables de entorno |
| Function | Function | Function:\ | Funciones cargadas |
| HKCU | Registry | HKEY_CURRENT_USER | Rama del registro |
| HKLM | Registry | HKEY_LOCAL_MACHINE | Rama del registro |
| Variable | Variable | Variable:\ | Variables de sesión |
| WSMan | WSMan | WSMan:\ | Configuración de WinRM |

Esta unificación significa que puede "entrar" en el registro (`Set-Location HKLM:`) y obtener una lista de sus claves con el mismo comando `Get-ChildItem` que usa para obtener una lista de archivos en la unidad C:. Este es un concepto increíblemente potente.

#### **Ejemplos de trabajo con diferentes proveedores**

*   **Almacén de certificados (Cert:)**
    Permite trabajar con certificados digitales como si fueran archivos en carpetas.

    **Tarea:** Encontrar todos los certificados SSL en la máquina local cuya fecha de vencimiento sea dentro de los próximos 30 días.
    ```powershell
    # Ir al almacén de certificados del equipo local
    Set-Location Cert:\LocalMachine\My

    # Encontrar certificados cuya fecha de finalización sea anterior a hoy + 30 días
    Get-ChildItem | Where-Object { $_.NotAfter -lt (Get-Date).AddDays(30) } | Select-Object Subject, NotAfter, Thumbprint
    ```

*   **Variables de entorno (Env:)**
    Proporciona acceso a las variables de entorno de Windows (`%PATH%`, `%windir%`, etc.) como si fueran archivos.

    **Tarea:** Obtener la ruta de la carpeta del sistema Windows y agregarle la ruta a `System32`.
    ```powershell
    # Obtener el valor de la variable windir
    $windowsPath = (Get-Item Env:windir).Value
    # O más simplemente: $windowsPath = $env:windir

    # Construir la ruta completa de forma segura
    $system32Path = Join-Path -Path $windowsPath -ChildPath "System32"
    Write-Host $system32Path
    # Resultado: C:\WINDOWS\System32
    ```

*   **Registro de Windows (HKCU: y HKLM:)**
    Imagine que el registro es solo otro sistema de archivos. Las ramas son carpetas y los parámetros son propiedades de esas carpetas.

    **Tarea:** Averiguar el nombre completo de la versión de Windows instalada desde el registro.
    ```powershell
    # Ir a la rama del registro deseada
    Set-Location "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

    # Obtener la propiedad (parámetro del registro) llamada "ProductName"
    Get-ItemProperty -Path . -Name "ProductName"
    # Resultado: ProductName : Windows 11 Pro
    ```

*   **Funciones cargadas (Function:)**
    Muestra todas las funciones disponibles en la sesión actual de PowerShell, como si fueran archivos.

    **Tarea:** Encontrar todas las funciones cargadas cuyo nombre contenga la palabra "Help" y ver el código de una de ellas.
    ```powershell
    # Buscar funciones por máscara
    Get-ChildItem Function: | Where-Object { $_.Name -like "*Help*" }

    # Obtener el código completo (definición) de la función Get-Help
    (Get-Item Function:Get-Help).Definition
    ```

*   **Variables de sesión (Variable:)**
    Permite administrar todas las variables (`$myVar`, `$PROFILE`, `$Error`, etc.) definidas en la sesión actual.

    **Tarea:** Encontrar todas las variables relacionadas con la versión de PowerShell (`$PSVersionTable`, `$PSHOME`, etc.).
    ```powershell
    # Encontrar todas las variables que comienzan con "PS"
    Get-ChildItem Variable:PS*

    # Obtener el valor de una variable específica
    Get-Variable -Name "PSVersionTable"
    ```
---

### 2. **Navegación y análisis**

#### **Conceptos básicos de navegación**

```powershell
# Saber dónde estamos (devuelve un objeto PathInfo)
Get-Location          # Alias: gl, pwd

# Ir a la raíz de la unidad C:
Set-Location C:\      # Alias: sl, cd

# Ir a la carpeta de inicio del usuario actual
Set-Location ~

# Mostrar el contenido de la carpeta actual (devuelve una colección de objetos)
Get-ChildItem         # Alias: gci, ls, dir
```

```powershell
# **Búsqueda recursiva**
# Encontrar el archivo hosts en el sistema, ignorando los errores "Acceso denegado"
Get-ChildItem C:\ -Filter "hosts" -Recurse -ErrorAction SilentlyContinue
```
**Clave `-Recurse` (Recursivo):** Hace que el cmdlet trabaje no solo con el elemento especificado, sino también con todo su contenido.

**Clave `-ErrorAction SilentlyContinue`:** Instrucción para ignorar errores y continuar trabajando en silencio.

#### **Análisis del espacio en disco**
Un ejemplo clásico del poder de la tubería: encontrar, ordenar, formatear y seleccionar.
```powershell
Get-ChildItem C:\Users -File -Recurse -ErrorAction SilentlyContinue | \
    Sort-Object Length -Descending | \
    Select-Object FullName, @{Name="Size(MB)"; Expression={[math]::Round($_.Length/1MB,2)}} | \
    Select-Object -First 20
```

###### **Consejo para introducir comandos largos.**
> PowerShell permite dividirlos en varias líneas para facilitar la lectura.
> 
> *   **Después del operador de tubería (`|`):** Esta es la forma más común y conveniente. Simplemente presione `Enter` después del símbolo `|`. PowerShell verá que el comando no está completo y esperará la continuación en la siguiente línea.
> *   **En cualquier otro lugar:** Use el carácter de acento grave (backtick) `` ` `` al final de la línea, y luego presione `Enter`. Este carácter le dice a PowerShell: "El comando continuará en la siguiente línea".
> *   **En editores (ISE, VS Code):** La combinación de teclas `Shift+Enter` generalmente inserta automáticamente un salto de línea sin ejecutar el comando.

#### **Filtrado de contenido y operadores lógicos**

```powershell
# Encontrar todos los archivos .exe. El parámetro -Filter funciona muy rápidamente.
Get-ChildItem C:\Windows -Filter "*.exe"
```

`Get-ChildItem` devuelve una colección de objetos. Podemos pasarla por la tubería a `Where-Object` para un filtrado posterior.

```powershell
# Mostrar solo archivos
Get-ChildItem C:\Windows | Where-Object { $_.PSIsContainer -eq $false }
```
Este comando nos introduce a uno de los conceptos fundamentales en los scripts de PowerShell: los **operadores de comparación**.

#### **Operadores de comparación y lógica**

Son claves especiales para comparar valores. Siempre comienzan con un guion (`-`) y son la base para filtrar datos en `Where-Object` y construir lógica en `if`.

| Operador | Descripción | Ejemplo en la tubería |
| :--- | :--- | :--- |
| `-eq` | Igual (EQual) | `$_.Name -eq "svchost.exe"` |
| `-ne` | No igual (Not Equal) | `$_.Status -ne "Running"` |
| `-gt` | Mayor que (Greater Than) | `$_.Length -gt 1MB` |
| `-ge` | Mayor o igual (Greater or Equal) | `$_.Handles -ge 500` |
| `-lt` | Menor que (Less Than) | `$_.LastWriteTime -lt (Get-Date).AddDays(-30)`|
| `-le` | Menor o igual (Less or Equal) | `$_.Count -le 1` |
| `-like` | Similar a (con comodines `*`, `?`)| `$_.Name -like "win*"` |
| `-notlike`| No similar a | `$_.Name -notlike "*.tmp"` |
| `-in` | El valor está contenido en la colección | `$_.Extension -in ".log", ".txt"` |
| `-and` | Lógico Y (ambas condiciones son verdaderas) | |
| `-or` | Lógico O (al menos una condición es verdadera) | |
| `-not` | Lógico NO (invierte la condición) | |

El tema de los operadores lógicos es muy extenso y le dedicaré una parte separada (o incluso dos). Por ahora, armados con estos operadores, podemos **filtrar, ordenar y seleccionar los archivos y carpetas que necesitamos**, utilizando todo el poder de la tubería de objetos.

#### **Ejemplos de uso en el sistema de archivos**

*   **Encontrar un archivo por nombre exacto (sensible a mayúsculas y minúsculas):**
    ```powershell
    Get-ChildItem C:\Windows\System32 -Recurse | Where-Object { $_.Name -eq "kernel32.dll" }
    ```

*   **Encontrar todos los archivos que comienzan con "host", pero que no son carpetas:**
    ```powershell
    Get-ChildItem C:\Windows\System32\drivers\etc | Where-Object { ($_.Name -like "host*") -and (-not $_.PSIsContainer) }
    ```

*   **Encontrar todos los archivos de registro (.log) cuyo tamaño supere los 50 megabytes:**
    ```powershell
    Get-ChildItem C:\Windows\Logs -Filter "*.log" -Recurse | Where-Object { $_.Length -gt 50MB }
    ```

*   **Encontrar todos los archivos temporales (.tmp) y archivos de copia de seguridad (.bak) para limpiar:**
    El operador `-in` es mucho más elegante aquí que varias condiciones con `-or`.
    ```powershell
    $extensionsToDelete = ".tmp", ".bak", ".old"
    Get-ChildItem C:\Temp -Recurse | Where-Object { $_.Extension -in $extensionsToDelete }
    ```

*   **Encontrar todos los archivos de Word (.docx) creados en la última semana:**
    ```powershell
    $oneWeekAgo = (Get-Date).AddDays(-7)
    Get-ChildItem C:\Users\MyUser\Documents -Filter "*.docx" -Recurse | Where-Object { $_.CreationTime -ge $oneWeekAgo }
    ```

*   **Encontrar archivos vacíos (tamaño 0 bytes) que no son carpetas:**
    ```powershell
    Get-ChildItem C:\Downloads -Recurse | Where-Object { ($_.Length -eq 0) -and (-not $_.PSIsContainer) }
    ```

*   **Encontrar todos los archivos ejecutables (.exe) que fueron modificados este año, pero NO este mes:**
    Este ejemplo complejo demuestra el poder de combinar operadores.
    ```powershell
    Get-ChildItem "C:\Program Files" -Filter "*.exe" -Recurse | Where-Object {
        ($_.LastWriteTime.Year -eq (Get-Date).Year) -and ($_.LastWriteTime.Month -ne (Get-Date).Month)
    }
    ```
*(Nota: los paréntesis `()` alrededor de cada condición se utilizan para agrupar y mejorar la legibilidad, especialmente en casos complejos).*

Tenga cuidado con la recursión:
Muchos archivos/carpetas: `-Recurse` puede entrar recursivamente en decenas de miles de elementos.
Enlaces simbólicos / enlaces cíclicos: pueden causar una recursión infinita.
Archivos sin permisos de acceso: pueden bloquear la ejecución.

### 4. **Creación, gestión y eliminación segura**

#### **Creación, copia y movimiento**
```powershell
New-Item -Path "C:\Temp\MyFolder" -ItemType Directory
Add-Content -Path "C:\Temp\MyFolder\MyFile.txt" -Value "Primera línea"
Copy-Item -Path "C:\Temp\MyFolder" -Destination "C:\Temp\MyFolder_Copy" -Recurse
```

#### **Eliminación segura**
`Remove-Item` es un cmdlet potencialmente peligroso, por lo que PowerShell tiene mecanismos de protección incorporados.
> **Clave `-WhatIf` (¿Qué pasaría si?):** Su mejor amigo. **No ejecuta** el comando, sino que solo muestra un mensaje en la consola sobre **lo que sucedería**.

```powershell
# VERIFICACIÓN SEGURA antes de eliminar
Remove-Item C:\Temp\MyFolder -Recurse -Force -WhatIf
# Resultado: What if: Performing the operation "Remove Directory" on target "C:\Temp\MyFolder".

# Solo después de asegurarse de que todo es correcto, se elimina -WhatIf y se EJECUTA el comando
Remove-Item C:\Temp\MyFolder -Recurse -Force
```
---

### **Introducción a las funciones**

Cuando una línea de código se convierte en un conjunto complejo de comandos que desea usar una y otra vez, llega el momento de crear **funciones**.

#### **Cómo usar y guardar funciones**

Hay tres formas principales de hacer que sus funciones estén disponibles:

**Método 1: Temporal (para pruebas)**
Puede escribir en la consola o simplemente copiar y pegar todo el código de la función en la consola de PowerShell. La función estará disponible hasta que se cierre esa ventana.

**Método 2: Permanente, pero manual (a través de un archivo `.ps1`)**
Esta es la forma más común de organizar y compartir herramientas. Guarda la función en un archivo `.ps1` y la carga en la sesión cuando la necesita.
> **Dot Sourcing (`. .
script.ps1`):** Este comando especial ejecuta el script en el *contexto actual*, haciendo que todas sus funciones y variables estén disponibles en su consola.

**Método 3: Automático (a través del perfil de PowerShell)**
Esta es la forma más potente para sus herramientas personales de uso frecuente.
> **¿Qué es un perfil de PowerShell?** Es un script `.ps1` especial que PowerShell ejecuta automáticamente cada vez que se inicia. Todo lo que coloque en este archivo (alias, variables y, por supuesto, funciones) estará disponible en cada una de sus sesiones de forma predeterminada.

##### **Ejemplo 1: Búsqueda de archivos duplicados**

Repasemos todos los pasos con el ejemplo de la función `Find-DuplicateFiles`.

**Paso 1: Definir el código de la función**
```powershell
$functionCode = @'
function Find-DuplicateFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    Get-ChildItem $Path -File -Recurse -ErrorAction SilentlyContinue | \
        Group-Object Name, Length | \
        Where-Object { $_.Count -gt 1 } | \
        ForEach-Object {
            # ESTA ES LA LÍNEA CORREGIDA:
            # Dentro del operador $() las variables no se escapan.
            Write-Host "Duplicados encontrados: $($_.Name)" -ForegroundColor Yellow
            $_.Group | Select-Object FullName, Length, LastWriteTime
        }
}
'@
```

**Paso 2 (Opción A): Guardar en un archivo separado para carga manual**
```powershell
# Guardar
Set-Content -Path ".\Find-DuplicateFiles.ps1" -Value $functionCode
# Cargar 
. .\Find-DuplicateFiles.ps1
```
> Dot Sourcing (. .\Find-DuplicateFiles.ps1): Este comando especial ejecuta el script en el contexto actual, haciendo que todas sus funciones y variables estén disponibles en su consola.
```powershell
# Llamar
Find-DuplicateFiles -Path "C:\Users\$env:USERNAME\Downloads"
```

**Paso 2 (Opción B): Agregar al perfil para carga automática**
Hagamos que esta función esté siempre disponible.
> ¿Qué es un perfil de PowerShell? Es un script .ps1 especial que PowerShell ejecuta automáticamente cada vez que se inicia. Todo lo que coloque en este archivo (alias, variables y funciones) estará disponible en cada una de sus sesiones de forma predeterminada.
1.  **Encontrar la ruta al archivo de perfil.** PowerShell lo almacena en la variable `$PROFILE`.
    ```powershell
    $PROFILE
    ```
2.  **Crear el archivo de perfil si no existe.**
    ```powershell
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Type File -Force
    }
    ```
3.  **Agregar el código de nuestra función al final del archivo de perfil.**
    ```powershell
    Add-Content -Path $PROFILE -Value $functionCode
    ```
4.  **Reinicie PowerShell** (o ejecute `. $PROFILE`), y ahora su comando `Find-DuplicateFiles` estará siempre disponible, al igual que `Get-ChildItem`.

##### **Ejemplo 2: Creación de un archivo ZIP de copia de seguridad**

**Código para el archivo `Backup-FolderToZip.ps1`:**
```powershell
function Backup-FolderToZip {
    param([string]$SourcePath, [string]$DestinationPath)
    if (-not (Test-Path $SourcePath)) { Write-Error "La carpeta de origen no se encontró."; return }
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $archiveFileName = "Backup_{0}_{1}.zip" -f (Split-Path $SourcePath -Leaf), $timestamp
    $fullArchivePath = Join-Path $DestinationPath $archiveFileName
    if (-not (Test-Path $DestinationPath)) { New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null }
    Compress-Archive -Path "$SourcePath\*" -DestinationPath $fullArchivePath -Force
    Write-Host "Copia de seguridad completada: $fullArchivePath" -ForegroundColor Green
}
```

Un análisis detallado de las funciones se realizará en las siguientes partes.

---

### **Referencia de cmdlets para trabajar con el sistema de archivos**

#### **1. Cmdlets básicos**
Esta lista incluye los 12 cmdlets más necesarios, que cubren el 90% de las tareas diarias.

| Cmdlet | Propósito principal | Ejemplo de uso |
| :--- | : | : |
| `Get-ChildItem`| Obtener la lista de archivos y carpetas. | `Get-ChildItem C:\Windows` |
| `Set-Location` | Moverse a otro directorio. | `Set-Location C:\Temp` |
| `Get-Location` | Mostrar el directorio actual. | `Get-Location` |
| `New-Item` | Crear un nuevo archivo o carpeta. | `New-Item "report.docx" -Type File`|
| `Remove-Item` | Eliminar un archivo o carpeta. | `Remove-Item "old_log.txt"` |
| `Copy-Item` | Copiar un archivo o carpeta. | `Copy-Item "file.txt" -Dest "D:\"` |
| `Move-Item` | Mover un archivo o carpeta. | `Move-Item "report.docx" -Dest "C:\Archive"` |
| `Rename-Item` | Renombrar un archivo o carpeta. | `Rename-Item "old.txt" -NewName "new.txt"` |
| `Get-Content` | Leer el contenido de un archivo. | `Get-Content "config.ini"` |
| `Set-Content` | Escribir/sobrescribir el contenido de un archivo. | `"data" | Set-Content "file.txt"` |
| `Add-Content` | Agregar contenido al final de un archivo. | `Get-Date | Add-Content "log.txt"` |
| `Test-Path` | Comprobar si existe un archivo o carpeta. | `Test-Path "C:\Temp"` |

¿Necesita **leer el contenido** de un archivo de texto? Use `Get-Content`.
¿Necesita **sobrescribir completamente un archivo** con contenido nuevo? Use `Set-Content`.
¿Necesita **agregar una línea a un archivo de registro**, sin borrar los datos antiguos? Use `Add-Content`.
¿Necesita **verificar si un archivo existe** antes de escribir? Use `Test-Path`.

#### **2. Cmdlets especializados para tareas avanzadas**
Cuando los cmdlets básicos no son suficientes, PowerShell ofrece herramientas más especializadas. No duplican los cmdlets básicos, sino que amplían sus capacidades.

*   **Trabajo con rutas (Path)**
    *   **`Join-Path`**: Une de forma segura partes de una ruta, insertando automáticamente `\`.
    *   **`Split-Path`**: Divide una ruta en partes (carpeta, nombre de archivo, extensión).
    *   **`Resolve-Path`**: Convierte una ruta relativa (por ejemplo, `.` o `..iles`) en una ruta completa y absoluta.

*   **Trabajo con propiedades y contenido (Item Properties and Content)**
    *   **`Get-ItemProperty`**: Obtiene las propiedades de un archivo específico (por ejemplo, `IsReadOnly`, `CreationTime`).
    *   **`Set-ItemProperty`**: Modifica las propiedades de un archivo o carpeta.
    *   **`Clear-Content`**: Elimina todo el contenido de un archivo, pero deja el archivo vacío.

*   **Navegación avanzada (Location Stack)**
    *   **`Push-Location`**: "Recuerda" el directorio actual y se mueve a uno nuevo.
    *   **`Pop-Location`**: Vuelve al directorio que `Push-Location` "recordó".

*   **Gestión de permisos de acceso (ACL)**
    *   **`Get-Acl`**: Obtiene la lista de permisos de acceso (ACL) para un archivo o carpeta.
    *   **`Set-Acl`**: Establece los permisos de acceso para un archivo o carpeta (operación compleja).

¿Necesita **cambiar un atributo de archivo**, por ejemplo, hacerlo "solo lectura"? Use `Set-ItemProperty`.
¿Necesita **limpiar completamente un archivo de registro**, sin eliminarlo? Use `Clear-Content`.
¿Necesita **cambiar temporalmente a otra carpeta** en un script y luego volver de forma garantizada? Use `Push-Location` y `Pop-Location`.
¿Necesita **saber quién tiene permisos** para acceder a una carpeta? Use `Get-Acl`.

En la siguiente parte, aprenderemos a trabajar con otros almacenes de datos, como el registro de Windows, utilizando los mismos enfoques, profundizaremos en el concepto de funciones, examinaremos los operadores lógicos y aprenderemos a interactuar de forma interactiva con el shell.

Filosofía PowerShell en github:
[Historia y primer cmdlet](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/01.md)

Parte 2: [Tubería (Pipeline), variables, Get-Member, archivo .ps1 y exportación de resultados.](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/02.md)
Ejemplos para la segunda parte:
[system_monitor.ps1](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/code/02/system_monitor.ps1)

Parte 3: [Navegación y gestión del sistema de archivos.](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/03.md)

Ejemplos para la tercera parte:
[Find-DuplicateFiles.ps1](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/code/03/Find-DuplicateFiles.ps1)
[Backup-FolderToZip]()