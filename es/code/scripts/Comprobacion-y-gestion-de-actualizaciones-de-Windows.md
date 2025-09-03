La comprobación y gestión de las actualizaciones de Windows es una tarea importante para mantener la seguridad y estabilidad del sistema.
Desafortunadamente, PowerShell estándar no tiene cmdlets incorporados para esto. Pero existe un excelente módulo de terceros llamado **`PSWindowsUpdate`**, que se ha convertido en una especie de estándar.

Con la ayuda de Gemini CLI, podemos generar un script que utiliza este módulo para realizar todas las operaciones necesarias.

### **Paso 1: Instalar el módulo `PSWindowsUpdate`**

Antes de ejecutar el script, debe instalar este módulo. Esto se hace una vez.

Abra PowerShell como administrador y ejecute el siguiente comando:

```powershell
Install-Module -Name PSWindowsUpdate
```

Si ve un error de que "PowerShellGet" está obsoleto, o una advertencia sobre un "repositorio de confianza", simplemente siga las instrucciones en la consola. Lo más probable es que deba confirmar la instalación.

### **Paso 2: Script para comprobar e instalar actualizaciones**

Después de instalar el módulo, puede usar este script para comprobar si hay actualizaciones y, si es necesario, instalarlas.

**Escenario:** Desea comprobar rápidamente si hay nuevas actualizaciones de Windows y obtener un informe.

**Comando que puede usar en Gemini CLI:**

```powershell
gemini-cli "Escriba un script de PowerShell que utilice el módulo PSWindowsUpdate. El script debe comprobar si hay actualizaciones de Windows disponibles, mostrar una lista de ellas y, a continuación, si se encuentran actualizaciones, pedir al usuario que las instale."
```

**Ejemplo de script generado:**

```powershell
# Requires -Module PSWindowsUpdate

Write-Host "--- Comprobación e instalación de actualizaciones de Windows ---" -ForegroundColor Green

# 1. Comprobar si hay actualizaciones disponibles
Write-Host "`nComprobando si hay actualizaciones disponibles..." -ForegroundColor Yellow
$availableUpdates = Get-WUList

if ($availableUpdates.Count -eq 0) {
    Write-Host "`nNo se encontraron actualizaciones. Su sistema está actualizado." -ForegroundColor Green
} else {
    Write-Host "`nSe encontraron las siguientes actualizaciones:" -ForegroundColor Yellow
    $availableUpdates | Format-Table -AutoSize

    # 2. Ofrecer instalar actualizaciones
    $installChoice = Read-Host "`n¿Instalar las actualizaciones encontradas? (S/N)"

    if ($installChoice -eq 'S' -or $installChoice -eq 's') {
        Write-Host "`nIniciando la instalación de actualizaciones..." -ForegroundColor Yellow
        
        # Descargar e instalar actualizaciones
        Install-WindowsUpdate -AcceptAll -AutoReboot
        
        Write-Host "`nProceso de instalación completado. Es posible que se requiera un reinicio." -ForegroundColor Green
    } else {
        Write-Host "`nInstalación cancelada. Las actualizaciones no se instalarán." -ForegroundColor Red
    }
}

Write-Host "`n--- Completado ---" -ForegroundColor Green
```

### ¿Cómo funciona?

  * **`Get-WUList`**: Este es un cmdlet clave del módulo `PSWindowsUpdate`. Busca actualizaciones disponibles al igual que el Centro de actualizaciones de Windows estándar.
  * **`Read-Host`**: Este comando permite que el script interactúe con usted, solicitando confirmación antes de instalar las actualizaciones.
  * **`Install-WindowsUpdate -AcceptAll -AutoReboot`**: Si acepta, este cmdlet inicia el proceso de instalación.
      * `-AcceptAll`: Acepta automáticamente los acuerdos de licencia.
      * `-AutoReboot`: Reinicia automáticamente el equipo si es necesario para completar la instalación. Puede eliminar esta bandera si desea reiniciar manualmente.

Este script le brinda control total sobre el proceso de actualización de Windows, lo que lo convierte en una excelente herramienta para la administración del sistema.
