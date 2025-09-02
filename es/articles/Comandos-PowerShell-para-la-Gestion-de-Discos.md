### Diagnóstico y recuperación de discos con PowerShell

PowerShell le permite automatizar las comprobaciones, realizar diagnósticos remotos y crear scripts flexibles para la supervisión. Esta guía le guiará desde las comprobaciones básicas hasta el diagnóstico y la recuperación de discos en profundidad.

**Versión:** Esta guía es relevante para **Windows 10/11** y **Windows Server 2016+**.

### Cmdlets clave para la gestión de discos

| Cmdlet | Propósito |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Información sobre discos físicos (modelo, estado de salud). |
| **`Get-Disk`** | Información sobre discos a nivel de dispositivo (estado en línea/fuera de línea, estilo de partición). |
| **`Get-Partition`** | Información sobre particiones en discos. |
| **`Get-Volume`** | Información sobre volúmenes lógicos (letras de unidad, sistema de archivos, espacio libre). |
| **`Repair-Volume`** | Comprobar y reparar volúmenes lógicos (análogo a `chkdsk`). |
| **`Get-StoragePool`** | Se utiliza para trabajar con espacios de almacenamiento (Storage Spaces). |

---

### Paso 1: Comprobación básica del estado del sistema

Comience con una evaluación general del estado del subsistema de disco.

#### Visualización de todos los discos conectados

El comando `Get-Disk` proporciona información resumida sobre todos los discos que ve el sistema operativo.

```powershell
Get-Disk
```

Verá una tabla con los números de disco, sus tamaños, estado (`Online` o `Offline`) y estilo de partición (`MBR` o `GPT`).

**Ejemplo:** Encontrar todos los discos que están fuera de línea.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Comprobación del estado físico del disco

El cmdlet `Get-PhysicalDisk` accede al estado del hardware.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Preste especial atención al campo `HealthStatus`. Puede tomar los siguientes valores:
*   **Healthy:** El disco está bien.
*   **Warning:** Hay problemas, se requiere atención (por ejemplo, se superaron los umbrales S.M.A.R.T.).
*   **Unhealthy:** El disco está en un estado crítico y puede fallar.

---

### Paso 2: Análisis y recuperación de volúmenes lógicos

Después de comprobar el estado físico, pasamos a la estructura lógica: volúmenes y el sistema de archivos.

#### Información sobre volúmenes lógicos

El comando `Get-Volume` muestra todos los volúmenes montados en el sistema.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Campos clave:
*   `DriveLetter` — Letra de la unidad (C, D, etc.).
*   `FileSystem` — Tipo de sistema de archivos (NTFS, ReFS, FAT32).
*   `HealthStatus` — Estado del volumen.
*   `SizeRemaining` y `Size` — Espacio libre y total.

#### Comprobación y reparación de un volumen (análogo a `chkdsk`)

El cmdlet `Repair-Volume` es un reemplazo moderno de la utilidad `chkdsk`.

**1. Comprobación de un volumen sin reparaciones (solo escaneo)**

Este modo es seguro para ejecutar en un sistema en funcionamiento; solo busca errores.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Escaneo completo y corrección de errores**

Este modo es análogo a `chkdsk C: /f`. Bloquea el volumen durante la operación, por lo que se requerirá un reinicio para la unidad del sistema.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Importante:** Si ejecuta este comando para la unidad del sistema (C:), PowerShell programará una comprobación en el próximo arranque del sistema. Para ejecutarlo inmediatamente, reinicie su computadora.

**Ejemplo:** Comprobar y reparar automáticamente todos los volúmenes cuyo estado no sea `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Reparando volumen $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Paso 3: Diagnóstico en profundidad y S.M.A.R.T.

Si las comprobaciones básicas no revelaron problemas, pero persisten las sospechas, puede profundizar.

#### Análisis de registros del sistema

Los errores del subsistema de disco a menudo se registran en el registro del sistema de Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
Para una búsqueda más precisa, puede filtrar por origen del evento:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Comprobación del estado S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) es una tecnología de autodiagnóstico de discos. PowerShell le permite obtener estos datos.

**Método 1: Uso de WMI (para compatibilidad)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
Si `PredictFailure = True`, el disco predice una falla inminente. Esta es una señal para un reemplazo inmediato.

**Método 2: Enfoque moderno a través de módulos CIM y Storage**

Una forma más moderna y detallada es usar el cmdlet `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
Este cmdlet proporciona información valiosa como el desgaste (relevante para SSD), la temperatura y el número de errores de lectura/escritura.

---

### Escenarios prácticos para un administrador de sistemas

Aquí hay algunos ejemplos listos para usar para tareas cotidianas.

**1. Obtener un informe breve sobre el estado de todos los discos físicos.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Crear un informe CSV sobre el espacio libre en todos los volúmenes.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Encontrar todas las particiones en un disco específico (por ejemplo, disco 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Ejecutar el diagnóstico del disco del sistema con reinicio posterior.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```