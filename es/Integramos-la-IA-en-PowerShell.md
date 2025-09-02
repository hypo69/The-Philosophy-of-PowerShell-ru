# Integramos la IA en PowerShell

#### **¿Qué es Gemini CLI?**

Ya he hablado en detalle sobre **Gemini CLI** en [Gemini CLI: Introducción y primeros pasos](https://pikabu.ru/series/geminicli_48168). Pero si se lo perdió, aquí tiene una breve introducción.

En resumen, **Gemini CLI** es una interfaz de línea de comandos para interactuar con los modelos de IA de Google. Lo inicia en su terminal y se convierte en un chat que, a diferencia de las versiones web, tiene acceso a su sistema de archivos.

**Características clave:**
*   **Comprende el código:** Puede analizar sus scripts, encontrar errores en ellos y sugerir correcciones.
*   **Genera código:** Puede pedirle que escriba un script de PowerShell para resolver su problema, y lo hará.
*   **Funciona con archivos:** Puede leer archivos, crear nuevos y realizar cambios en los existentes.
*   **Ejecuta comandos:** Puede ejecutar comandos de shell, como `git` o `npm`.

Para nuestros propósitos, lo más importante es que Gemini CLI puede funcionar en **modo no interactivo**. Es decir, podemos pasarle un mensaje como argumento de línea de comandos, y simplemente devolverá una respuesta, sin iniciar su chat interactivo. Esta es precisamente la capacidad que utilizaremos.

#### **Instalación y configuración**

Para empezar, necesitamos preparar nuestro entorno. Esto se hace una sola vez.

**Paso 1: Instalar Node.js**
Gemini CLI es una aplicación escrita en Node.js (un entorno popular para JavaScript). Así que primero, necesitamos instalar Node.js.
1.  Vaya al sitio web oficial: [https://nodejs.org/](https://nodejs.org/)
2.  Descargue e instale la versión **LTS**. Esta es la opción más estable y recomendada. Simplemente siga las instrucciones del instalador.
3.  Después de la instalación, abra una nueva ventana de PowerShell y verifique que todo funciona:
    ```powershell
    node -v
    npm -v
    ```
    Debería ver versiones, por ejemplo, `v20.12.2` y `10.5.0`.

**Paso 2: Instalar Gemini CLI**
Ahora que tenemos `npm` (el gestor de paquetes para Node.js), la instalación de Gemini CLI se reduce a un solo comando. Ejecútelo en PowerShell:
```powershell
npm install -g @google/gemini-cli
```
El indicador `-g` significa "instalación global", lo que hará que el comando `gemini` esté disponible desde cualquier lugar de su sistema.

**Paso 3: Autenticación**
La primera vez que inicie Gemini CLI, le pedirá que inicie sesión en su cuenta de Google. Esto es necesario para que pueda usar su cuota gratuita.
1.  Simplemente ingrese el comando en PowerShell:
    ```powershell
    gemini
    ```
2.  Le preguntará sobre el inicio de sesión. Seleccione "Iniciar sesión con Google".
3.  Su navegador abrirá una ventana estándar de inicio de sesión de Google. Inicie sesión en su cuenta y otorgue los permisos necesarios.
4.  Después de eso, verá un mensaje de bienvenida de Gemini en la consola. ¡Felicidades, está listo para trabajar! Puede escribir `/quit` para salir de su chat.

#### **Filosofía de PowerShell: El terrible `Invoke-Expression`**

Antes de juntar todo, familiaricémonos con uno de los cmdlets más peligrosos de PowerShell: `Invoke-Expression`, o su alias corto `iex`.

`Invoke-Expression` toma una cadena de texto y la ejecuta como si fuera un comando escrito en la consola.

**Ejemplo:**
```powershell
$commandString = "Get-Process -Name 'chrome'"
Invoke-Expression -InputObject $commandString
```
Este comando hará lo mismo que una simple llamada a `Get-Process -Name 'chrome'`.

**¿Por qué es peligroso?** Porque ejecutar una cadena que no controla (por ejemplo, obtenida de Internet o de una IA) es un enorme agujero de seguridad. Si la IA devuelve por error o maliciosamente el comando `Remove-Item -Path C:\ -Recurse -Force`, `iex` lo ejecutará sin dudarlo.

Para nuestra tarea, crear un puente gestionado y controlado entre una consulta en lenguaje natural y su ejecución, es perfectamente adecuado. Lo usaremos con precaución, plenamente conscientes de los riesgos.

#### **Juntando todo: El cmdlet `Invoke-Gemini`**
Escribamos una función simple de PowerShell que nos permita enviar mensajes con un solo comando.

Copie este código y péguelo en su ventana de PowerShell para que esté disponible en la sesión actual.

```powershell
function Invoke-Gemini {
    <#
    .SYNOPSIS
        Envía un mensaje de texto a Gemini CLI y devuelve su respuesta.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Prompt
    )

    process {
        try {
            # Comprobar si el comando gemini está disponible
            $geminiCommand = Get-Command gemini -ErrorAction Stop
        }
        catch {
            Write-Error "No se encontró el comando 'gemini'. Asegúrese de que Gemini CLI esté instalado."
            return
        }

        Write-Verbose "Enviando mensaje a Gemini CLI..."
        
        # Ejecutar gemini en modo no interactivo con nuestro mensaje
        $output = & $geminiCommand.Source -p $Prompt 2>&1

        if (-not $?) {
            Write-Warning "El comando gemini finalizó con un error."
            $output | ForEach-Object { Write-Warning $_.ToString() }
            return
        }

        # Devolver salida limpia
        return $output
    }
}
```

#### **¡Probemos la magia!**


Hagámosle una pregunta general directamente desde nuestra consola de PowerShell.

```powershell
Invoke-Gemini -Prompt "Háblame de las cinco últimas tendencias en aprendizaje automático"
```


**¡Felicidades!** Acaba de integrar con éxito la IA en PowerShell.

En el próximo artículo, le explicaré cómo usar Gemini CLI para ejecutar scripts y automatizar tareas.
