# La Filosofía de PowerShell.
## Parte 0.
¿Qué había antes de PowerShell?
En 1981, se lanzó MS-DOS 1.0 con el intérprete de comandos `COMMAND.COM`. Para la automatización de tareas, se utilizaban **archivos por lotes (`.bat`)**, simples archivos de texto con una secuencia de comandos de consola. Este fue un ascetismo sorprendente en la línea de comandos en comparación con los sistemas compatibles con POSIX, donde el **shell Bourne (`sh`)** existía desde 1979.

### 📅 Estado del mercado de los shells en el momento del lanzamiento de MS-DOS 1.0 (agosto de 1981)

Aquí hay una tabla resumen de los sistemas operativos populares de la época y su compatibilidad con los shells (`sh`, `csh`, etc.):

| Sistema operativo | Compatibilidad con shells (`sh`, `csh`, etc.) | Comentario |
|---|---|---|
| **UNIX Versión 7 (V7)** | `sh` | El último UNIX clásico de Bell Labs, muy extendido |
| **UNIX/32V** | `sh`, `csh` | Versión de UNIX para la arquitectura VAX |
| **4BSD / 3BSD** | `sh`, `csh` | Rama universitaria de UNIX de Berkeley |
| **UNIX System III** | `sh` | La primera versión comercial de AT&T, predecesora de System V |
| **Xenix (de Microsoft)** | `sh` | Una versión con licencia de UNIX, vendida por Microsoft desde 1980 |
| **IDRIS** | `sh` | Un sistema operativo similar a UNIX para PDP-11 e Intel |
| **Coherent (Mark Williams)** | `sh` (similar) | Una alternativa económica a UNIX para PC |
| **CP/M (Digital Research)** | ❌ (Sin `sh`, solo una CLI muy básica) | No es UNIX, el sistema operativo más popular para PC de 8 bits |
| **MS-DOS 1.0** | ❌ (solo `COMMAND.COM`) | Shell de comandos mínimo, sin scripts ni tuberías |

---

### 💡 ¿Qué son `sh`, `csh`?

* `sh` — **Bourne Shell**, el principal intérprete de scripts de UNIX desde 1977.
* `csh` — **C Shell**, un shell mejorado con una sintaxis similar a la de C y comodidades para el trabajo interactivo.
* Estos shells **admitían redirecciones, tuberías, variables, funciones y condiciones**, todo lo que convirtió a UNIX en una potente herramienta de automatización.

---

Microsoft se centró en los **PC IBM de 16 bits baratos**, que tenían **poca memoria** (normalmente entre 64 y 256 KB), carecían de multitarea y estaban pensados para **uso doméstico y de oficina**, no para servidores. UNIX era caro, requería una arquitectura y unos conocimientos complejos, mientras que los contables e ingenieros, que no eran administradores de sistemas, necesitaban un sistema operativo rápido y sencillo.

En lugar del complejo `sh`, la interfaz de DOS proporcionaba un único archivo, command.com, con un escaso conjunto de comandos internos [ (dir, copy, del, etc.)](https://www.techgeekbuzz.com/blog/dos-commands/){:target="_blank"} sin funciones, bucles ni módulos.

También había comandos externos: archivos ejecutables independientes (.exe o .com). Ejemplos: FORMAT.COM, XCOPY.EXE, CHKDSK.EXE, EDIT.COM.
Los scripts de ejecución se escribían en un archivo de texto con la extensión .bat (archivo por lotes).

Ejemplos de archivos de configuración:

- AUTOEXEC.BAT

```bash
:: ------------------------------------------------------------------------------
:: AUTOEXEC.BAT — Configuración y arranque automáticos de Windows 3.11
:: Autor: hypo69
:: Año: aproximadamente 1993
:: Propósito: Inicializa el entorno DOS, carga los controladores de red e inicia Windows 3.11
:: ------------------------------------------------------------------------------
@ECHO OFF

:: Establecer el símbolo del sistema
PROMPT $p$g

:: Establecer variables de entorno
SET TEMP=C:\TEMP
PATH=C:\DOS;C:\WINDOWS

:: Cargar controladores y utilidades en la memoria alta
LH C:\DOS\SMARTDRV.EXE       :: Caché de disco
LH C:\DOS\MOUSE.COM          :: Controlador del ratón

:: Cargar servicios de red (relevante para Windows para Trabajo en Grupo 3.11)
IF EXIST C:\NET\NET.EXE LH C:\NET\NET START

:: Iniciar Windows automáticamente
WIN
```
- CONFIG.SYS
```bash
:: ------------------------------------------------------------------------------
:: CONFIG.SYS — Configuración de la memoria y los controladores de DOS para Windows 3.11
:: Autor: hypo69
:: Año: aproximadamente 1993
:: Propósito: Inicializa los controladores de memoria, configura los parámetros del sistema
:: ------------------------------------------------------------------------------
DEVICE=C:\DOS\HIMEM.SYS
DEVICE=C:\DOS\EMM386.EXE NOEMS
DOS=HIGH,UMB
FILES=40
BUFFERS=30
DEVICEHIGH=C:\DOS\SETVER.EXE
```

Paralelamente a DOS, Microsoft comenzó a desarrollar casi de inmediato un núcleo fundamentalmente nuevo.

El núcleo [**Windows NT**](https://www.wikiwand.com/ru/articles/Windows_NT){:target="_blank"} (Nueva Tecnología) apareció por primera vez con el lanzamiento del sistema operativo:

> **Windows NT 3.1 — 27 de julio de 1993**

---

* **El desarrollo comenzó**: en **1988** bajo la dirección de **Dave Cutler** (un exingeniero de DEC y creador de VMS) con el objetivo de crear un sistema operativo completamente nuevo, seguro, portátil y multitarea, no compatible con MS-DOS a nivel de núcleo.
* **NT 3.1**: se llamó así para enfatizar la compatibilidad con **Windows 3.1** a nivel de interfaz, pero era una **arquitectura completamente nueva**.

---

#### 🧠 Lo que aportó el núcleo NT:

| Característica | Descripción |
|---|---|
| **Arquitectura de 32 bits** | A diferencia de MS-DOS y Windows 3.x, que eran de 16 bits. |
| **Multitarea** | Verdadera multitarea apropiativa. |
| **Memoria protegida** | Los programas no podían dañar la memoria de los demás. |
| **Modularidad** | Arquitectura del núcleo de varias capas: HAL, Ejecutivo, Núcleo, controladores. |
| **Compatibilidad con multiplataforma** | NT 3.1 se ejecutaba en x86, MIPS y Alpha. |
| **Compatibilidad con POSIX** | NT venía con un **subsistema POSIX**, certificado según POSIX.1. |

---

#### 📜 El linaje de NT:

| Versión de NT | Año | Comentario |
|---|---|---|
| NT 3.1 | 1993 | Primer lanzamiento de NT |
| NT 3.5 / 3.51 | 1994–1995 | Mejoras, optimización |
| NT 4.0 | 1996 | Interfaz de Windows 95, pero núcleo de NT |
| Windows 2000 | 2000 | NT 5.0 |
| Windows XP | 2001 | NT 5.1 |
| Windows Vista | 2007 | NT 6.0 |
| Windows 10 | 2015 | NT 10.0 |
| Windows 11 | 2021 | También NT 10.0 (marketing 😊) |

---

Diferencia en las capacidades del sistema operativo:

| Característica | **MS-DOS** (1981) | **Windows NT** (1993) |
|---|---|---|
| **Tipo de sistema** | Monolítico, monotarea | Micronúcleo/híbrido, multitarea |
| **Arquitectura** | 16 bits | 32 bits (con compatibilidad con 64 bits desde NT 5.2 / XP x64) |
| **Multitarea** | ❌ Ausente (un proceso a la vez) | ✅ Multitarea apropiativa |
| **Memoria protegida** | ❌ No | ✅ Sí (cada proceso en su propio espacio de direcciones) |
| **Modo multiusuario** | ❌ No | ✅ Parcialmente (en NT Workstation/Server) |
| **Compatibilidad con POSIX** | ❌ No | ✅ Subsistema POSIX integrado en NT 3.1–5.2 |
| **Portabilidad del núcleo** | ❌ Solo x86 | ✅ x86, MIPS, Alpha, PowerPC |
| **Controladores** | Acceso directo al hardware | A través de HAL y controladores en modo núcleo |
| **Nivel de acceso de las aplicaciones** | Aplicaciones = nivel de sistema | Niveles de usuario/núcleo separados |
| **Seguridad** | ❌ Ausente | ✅ Modelo de seguridad: SID, ACL, tokens de acceso |
| **Estabilidad** | ❌ La dependencia de un programa = fallo del sistema operativo | ✅ Aislamiento de procesos, protección del núcleo |

---

¡Pero había un gran PERO! No se prestó la debida atención a las herramientas de automatización y administración hasta 2002.

---
 
Microsoft utilizó enfoques, estrategias y herramientas completamente diferentes para la administración. Todo esto era **disperso**, a menudo orientado a la GUI y no siempre automatizable.

---

##### 📌 Lista de algunas herramientas:

| Herramienta | Propósito |
|---|---|
| `cmd.exe` | Intérprete de comandos mejorado (reemplazo de `COMMAND.COM`) |
| `.bat`, `.cmd` | Scripts de línea de comandos |
| **Windows Script Host (WSH)** | Compatibilidad con VBScript y JScript para la automatización |
| `reg.exe` | Administrar el registro desde la línea de comandos |
| `net.exe` | Trabajar con usuarios, redes, impresoras |
| `sc.exe` | Administrar servicios |
| `tasklist`, `taskkill` | Administrar procesos |
| `gpedit.msc` | Directiva de grupo (local) |
| `MMC` | Consola con complementos para la administración |
| `WMI` | Acceder a la información del sistema (a través de `wmic`, VBScript o COM) |
| `WbemTest.exe` | GUI para probar consultas WMI |
| `eventvwr` | Ver registros de eventos |
| `perfmon` | Supervisar recursos |

##### 🛠 Ejemplos de automatización:

* Archivos VBScript (`*.vbs`) para administrar usuarios, redes, impresoras y servicios.
* `WMIC`: interfaz de línea de comandos para WMI (p. ej.: `wmic process list brief`).
* Scripts `.cmd` con llamadas a `net`, `sc`, `reg`, `wmic`, etc.

---

### ⚙️ Windows Scripting Host (WSH)

* Apareció por primera vez en **Windows 98**, se utilizó activamente en **Windows 2000 y XP**.
* Permitía ejecutar archivos VBScript y JScript desde la línea de comandos:

  ```vbscript
  Set objShell = WScript.CreateObject("WScript.Shell")
  objShell.Run "notepad.exe"
  ```

---
## Parte 1.

Solo en 2002 la empresa formuló el proyecto <a href="https://learn.microsoft.com/en-us/powershell/scripting/developer/monad-manifesto?view=powershell-7.5" target="_blank">Monad</a>, que más tarde se convirtió en PowerShell:

Inicio del desarrollo: aproximadamente en 2002

Anuncio público: 2003, como "Monad Shell"

Primeras versiones beta: aparecieron en 2005

Lanzamiento final (PowerShell 1.0): noviembre de 2006

 El autor y arquitecto jefe del proyecto Monad / PowerShell es Jeffrey Snover
 <a href="https://www.wikiwand.com/en/articles/Jeffrey_Snover" target="_blank"> (Jeffrey Snover)</a>
 
Hoy en día, PowerShell Core se ejecuta en
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/windows-core.md" target="_blank">Windows</a>
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/macos.md" target="_blank">macOS</a>
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/linux.md" target="_blank">Linux</a>

 
Paralelamente, se estaba desarrollando el framework .NET y PowerShell estaba profundamente integrado en él. En los próximos capítulos, mostraré ejemplos.

¡Y ahora, lo más importante!

La principal ventaja de PowerShell en comparación con los shells de comandos clásicos es que funciona con *objetos*, no con texto. Cuando se ejecuta un comando, no devuelve solo texto, sino un objeto estructurado (o una colección de objetos) que tiene propiedades y métodos claramente definidos.

Vea cómo PowerShell supera a los shells clásicos gracias al **trabajo con objetos**

### 📁 La forma antigua: `dir` y el análisis manual

En **CMD** (tanto en el antiguo `COMMAND.COM` como en `cmd.exe`), el comando `dir` devuelve el resultado como texto sin formato. Salida de ejemplo:

```
24.07.2025  21:15         1.428  my_script.js
25.07.2025  08:01         3.980  report.html
```

Supongamos que desea extraer el **nombre del archivo** y el **tamaño** de cada archivo. Tendría que analizar las cadenas manualmente:
```cmd
for /f "tokens=5,6" %a in ('dir ^| findstr /R "[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]"') do @echo %a %b
```

* Esto es terriblemente difícil de leer, depende de la configuración regional, el formato de la fecha y la fuente. Y se rompe con los espacios en los nombres.

---

### ✅ PowerShell: objetos en lugar de texto

#### ✔ Ejemplo simple y legible:

```powershell
Get-ChildItem | Select-Object Name, Length
```

**Resultado:**

```
Name          Length
----          ------
my_script.js   1428
report.html    3980
```

* `Get-ChildItem` devuelve una **matriz de objetos de archivo/carpeta**
* `Select-Object` le permite obtener fácilmente las **propiedades** requeridas

---

### 🔍 ¿Qué devuelve realmente `Get-ChildItem`?

```powershell
$item = Get-ChildItem -Path .\my_script.js
$item | Get-Member
```

**Resultado:**

```
TypeName: System.IO.FileInfo

Name         MemberType     Definition
----         ---------      ----------
Length       Property       long Length {get;}
Name         Property       string Name {get;}
CreationTime Property       datetime CreationTime {get;set;}
Delete       Method         void Delete()
...
```

PowerShell devuelve **objetos `System.IO.FileInfo`**, que tienen:

* 🧱 Propiedades (`Name`, `Length`, `CreationTime`, `Extension`, …)
* 🛠 Métodos (`Delete()`, `CopyTo()`, `MoveTo()`, etc.)

Usted trabaja **con objetos completos**, no con cadenas.

---

### Sintaxis "Verbo-Sustantivo":

PowerShell utiliza una **sintaxis de comandos estricta y lógica**:
`Verbo-Sustantivo`

| Verbo | Qué hace |
|---|---|
| `Get-` | Obtener |
| `Set-` | Establecer |
| `New-` | Crear |
| `Remove-` | Eliminar |
| `Start-` | Iniciar |
| `Stop-` | Detener |

| Sustantivo | Sobre qué funciona |
|---|---|
| `Process` | Proceso |
| `Service` | Servicio |
| `Item` | Archivo/carpeta |
| `EventLog` | Registros de eventos |
| `Computer` | Ordenador |

#### 🔄 Ejemplos:

| Qué hacer | Comando |
|---|---|
| Obtener procesos | `Get-Process` |
| Detener un servicio | `Stop-Service` |
| Crear un nuevo archivo | `New-Item` |
| Obtener el contenido de la carpeta | `Get-ChildItem` |
| Eliminar un archivo | `Remove-Item` |

➡ Incluso si **no conoce el comando exacto**, puede **adivinarlo** por el significado, y casi siempre acertará.

---

El cmdlet `Get-Help` es su principal ayudante.

1.  **Obtener ayuda sobre la propia ayuda:**
    ```powershell
    Get-Help Get-Help
    ```
2.  **Obtener ayuda básica sobre el comando para trabajar con procesos:**
    ```powershell
    Get-Help Get-Process
    ```
3.  **Ver ejemplos de uso de este comando:**
    ```powershell
    Get-Help Get-Process -Examples
    ```
    Este es un parámetro increíblemente útil que a menudo proporciona soluciones listas para usar para sus tareas.
4.  **Obtener la información más detallada sobre el comando:**
    ```powershell
    Get-Help Get-Process -Full
    ```
En la siguiente parte: la canalización o cadena de comandos (PipeLines)
