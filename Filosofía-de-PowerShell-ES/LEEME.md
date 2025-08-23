![1](assets/cover.png)
# La Filosofía de PowerShell

&nbsp;&nbsp;&nbsp;&nbsp;El objetivo de esta serie no es crear otra referencia de cmdlets. 
La idea clave que desarrollaré a lo largo de todos los capítulos es la transición del pensamiento en texto al **pensamiento en objetos**. 
En lugar de trabajar con cadenas sin estructura, le enseñaré cómo operar con objetos completos con sus propiedades y métodos, 
pasándolos a través de la canalización, como en una línea de montaje en una fábrica.


&nbsp;&nbsp;&nbsp;&nbsp;Esta serie le ayudará a ir más allá de la simple escritura de comandos y a adquirir un enfoque de ingeniería consciente de PowerShell,
como una potente herramienta para diseccionar el sistema operativo.

---

## 🗺️ Tabla de contenidos

### **Sección I: Fundamentos y conceptos básicos**

*   **[Parte 0: ¿Qué había antes de PowerShell?](./01.md)**
    *   Excursión histórica: `COMMAND.COM`, `AUTOEXEC.BAT`, `CONFIG.SYS`.
    *   Comparación con el mundo UNIX (`sh`, `csh`).
    *   Evolución de Windows: núcleo NT y herramientas de administración dispares.

*   **[Parte 1: Primer lanzamiento y conceptos clave](./01.md)**
    *   El proyecto Monad y el nacimiento de PowerShell.
    *   **Idea principal:** Objetos en lugar de texto.
    *   Sintaxis "Verbo-Sustantivo".
    *   Su principal asistente: `Get-Help`.

*   **[Parte 2: Canalización, variables y exploración de objetos](./02.md)**
    *   Principios de funcionamiento de la canalización (`|`).
    *   Trabajar con variables (`$var`, `$_`).
    *   Análisis de objetos con `Get-Member`.
    *   *Ejemplo de código: [system_monitor.ps1](./code/02/system_monitor.ps1)*


*   **[Parte 3: Navegación y gestión del sistema de archivos](./03.md)**
    *   El concepto de proveedores (`PSDrives`): sistema de archivos, registro, certificados.
    *   Operadores de comparación y lógica.
    *   Introducción a las funciones.
    *   *Ejemplos de código: [Find-DuplicateFiles.ps1](./code/03/Find-DuplicateFiles.ps1), [Backup-FolderToZip.ps1](./code/03/Backup-FolderToZip.ps1)*

*   **[Parte 4: Trabajo interactivo: `Out-ConsoleGridView`, `F7History` y `ConsoleGuiTools`**






    *   `Where-Object`: Un tamiz para objetos.
    *   `Sort-Object`: Ordenación de datos.
    *   `Select-Object`: Selección de propiedades y creación de campos calculados.

*   **[Parte 5: Variables y tipos de datos básicos](./05.md)**
    *   Variables como objetos `PSVariable`.
    *   Ámbitos.
    *   Trabajar con cadenas, matrices y tablas hash.

### **Sección III: De scripts a herramientas profesionales**

*   **[Parte 6: Conceptos básicos de scripting. Archivos `.ps1` y política de ejecución](./06.md)**
    *   Transición de la consola interactiva a los archivos `.ps1`.
    *   Políticas de ejecución (`Execution Policy`): qué son y cómo configurarlas.

*   **[Parte 7: Construcciones lógicas y bucles](./07.md)**
    *   Toma de decisiones: `If / ElseIf / Else` y `Switch`.
    *   Repetición de acciones: bucles `ForEach`, `For`, `While`.

*   **[Parte 8: Funciones — creación de sus propios cmdlets](./08.md)**
    *   Anatomía de una función avanzada: `[CmdletBinding()]`, `[Parameter()]`.
    *   Creación de ayuda (`Comment-Based Help`).
    *   Procesamiento de canalizaciones: bloques `begin`, `process`, `end`.

*   **[Parte 9: Trabajar con datos: CSV, JSON, XML](./09.md)**
    *   Importación y exportación de datos tabulares con `Import-Csv` y `Export-Csv`.
    *   Trabajar con API: `ConvertTo-Json` y `ConvertFrom-Json`.
    *   Conceptos básicos de trabajo con XML.

*   **[Parte 10: Módulos y PowerShell Gallery](./10.md)**
    *   Organización de código en módulos: `.psm1` y `.psd1`.
    *   Importación de módulos y exportación de funciones.
    *   Uso de la biblioteca global `PowerShell Gallery`.

### **Sección IV: Técnicas avanzadas y proyecto final**

*   **[Parte 11: Gestión remota y tareas en segundo plano](./11.md)**
    *   Conceptos básicos de PowerShell Remoting (WinRM).
    *   Sesiones interactivas (`Enter-PSSession`).
    *   Gestión masiva con `Invoke-Command`.
    *   Ejecución de operaciones de larga duración en segundo plano (`Start-Job`).

*   **[Parte 12: Introducción a la GUI en PowerShell con Windows Forms](./12.md)**
    *   Creación de ventanas, botones y etiquetas.
    *   Manejo de eventos (clic de botón).

*   **[Parte 13: Proyecto "Monitor de CPU" — Diseño de la interfaz](./13.md)**
    *   Diseño de la interfaz gráfica de usuario.
    *   Configuración del elemento `Chart` para mostrar gráficos.

*   **[Parte 14: Proyecto "Monitor de CPU" — Recopilación de datos y lógica](./14.md)**
    *   Obtención de métricas de rendimiento con `Get-Counter`.
    *   Uso de un temporizador para actualizar datos en tiempo real.

*   **[Parte 15: Proyecto "Monitor de CPU" — Ensamblaje final y próximos pasos](./15.md)**
    *   Adición de manejo de errores (`Try...Catch`).
    *   Resumen e ideas para un mayor desarrollo.

---

## 🎯 ¿Para quién es esta serie?

*   **Para principiantes** que desean establecer una base sólida y correcta en el aprendizaje de PowerShell, evitando errores comunes.
*   **Para administradores de Windows experimentados** que están acostumbrados a `cmd.exe` o VBScript y desean sistematizar sus conocimientos cambiando a una herramienta moderna y más potente.
*   **Para todos** los que quieran aprender a pensar no en comandos, sino en sistemas, y crear scripts de automatización elegantes, fiables y fáciles de mantener.

## ✍️ Comentarios y participación

&nbsp;&nbsp;&nbsp;&nbsp;Si encuentra un error, un error tipográfico o tiene una sugerencia para mejorar alguna parte, no dude en crear un **Issue** en este repositorio.

## 📜 Licencia

&nbsp;&nbsp;&nbsp;&nbsp;Todo el código y los textos de este repositorio se distribuyen bajo la **[licencia MIT](./LICENSE)**. Puede usar, modificar y distribuir libremente los materiales con atribución.
