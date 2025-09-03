# Herramientas de química para PowerShell (con Gemini AI)

**Herramientas de química** es un módulo de PowerShell que proporciona el comando `Start-ChemistryExplorer` para la exploración interactiva de elementos químicos utilizando Google Gemini AI.

Esta herramienta transforma su consola en una referencia inteligente, permitiéndole consultar listas de elementos por categoría, verlos en una tabla filtrable conveniente (`Out-ConsoleGridView`) y obtener información adicional sobre cada uno.

 *(Se recomienda reemplazar con una animación GIF real del funcionamiento del script)*

## 🚀 Instalación y configuración

### Requisitos previos

1.  **PowerShell 7.2+**.
2.  **Node.js (LTS):** [Instalar desde aquí](https://nodejs.org/).
3.  **Google Gemini CLI:** Asegúrese de que el CLI esté instalado y autenticado.
    ```powershell
    # 1. Instalar Gemini CLI
    npm install -g @google/gemini-cli

    # 2. Primera ejecución para iniciar sesión en la cuenta de Google
    gemini
    ```

### Guía de instalación paso a paso

#### Paso 1: Cree la estructura de carpetas correcta (¡Obligatorio!)

Este es el paso más importante. Para que PowerShell pueda encontrar su módulo, debe estar en una carpeta con **exactamente el mismo nombre** que el módulo en sí.

1.  Encuentre su carpeta de módulos personales de PowerShell.
    ```powershell
    # Este comando mostrará la ruta, normally C:\Users\SuNombre\Documents\PowerShell\Modules
    $moduleBasePath = Split-Path $PROFILE.CurrentUserAllHosts
    $moduleBasePath
    ```2.  Cree una carpeta para nuestro módulo llamada `Chemistry` en ella.
    ```powershell
    $modulePath = Join-Path $moduleBasePath "Chemistry"
    if (-not (Test-Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }
    ```
3.  Descargue y coloque los siguientes archivos del repositorio en esta carpeta (`Chemistry`):
    *   `Chemistry.psm1` (código principal del módulo)
    *   `Chemistry.GEMINI.md` (archivo de instrucciones de IA)
    *   `Chemistry.psd1` (archivo de manifiesto, opcional pero recomendado)

Su estructura de archivos final debería verse así:
```
...\Documents\PowerShell\Modules\
└── Chemistry\                <-- Carpeta del módulo
    ├── Chemistry.psd1        <-- Manifiesto (opcional)
    ├── Chemistry.psm1        <-- Código principal
    └── Chemistry.GEMINI.md   <-- Instrucciones de IA
```

#### Paso 2: Desbloquear archivos

Si descargó archivos de Internet, Windows podría bloquearlos. Ejecute este comando para resolver el problema:
```powershell
Get-ChildItem -Path $modulePath | Unblock-File
```

#### Paso 3: Importar y probar el módulo

Reinicie PowerShell. El módulo debería cargarse automáticamente. Para asegurarse de que el comando esté disponible, ejecute:
```powershell
Get-Command -Module Chemistry
```
La salida debería ser:
```
CommandType     Name                    Version    Source
-----------     ----                    -------    ------
Function        Start-ChemistryExplorer 1.0.0      Chemistry
```

## 💡 Uso

Después de la instalación, simplemente ejecute el comando en su consola:
```powershell
Start-ChemistryExplorer
```
El script lo saludará y le pedirá que ingrese una categoría de elementos químicos.
> `Iniciando referencia interactiva del químico...`
> `Ingrese la categoría de elementos (por ejemplo, 'gases nobles') o 'salir'`
> `> gases nobles`

Después de eso, aparecerá una ventana interactiva `Out-ConsoleGridView` con una lista de elementos. Seleccione uno de ellos, y Gemini le contará datos interesantes al respecto.

## 🛠️ Solución de problemas

*   **Error "módulo no encontrado"**:
    1.  **Reinicie PowerShell.** Esto resuelve el problema en el 90% de los casos.
    2.  Vuelva a verificar el **Paso 1**. El nombre de la carpeta (`Chemistry`) y el nombre del archivo (`Chemistry.psm1` o `Chemistry.psd1`) deben ser correctos.

*   **Comando `Start-ChemistryExplorer` no encontrado después de la importación**:
    1.  Asegúrese de que su archivo `Chemistry.psm1` tenga la línea `Export-ModuleMember -Function Start-ChemistryExplorer` al final.
    2.  Si está utilizando un manifiesto (`.psd1`), asegúrese de que el campo `FunctionsToExport = 'Start-ChemistryExplorer'` esté rellenado en él.
```