Adiós, PowerShell 2.0.

### Microsoft finalmente se despide de PowerShell 2.0 en Windows

**Microsoft ha anunciado la eliminación completa del componente obsoleto Windows PowerShell 2.0 de los sistemas operativos Windows 11 y Windows Server 2025, a partir de agosto de 2025. Este paso forma parte de una estrategia global para mejorar la seguridad, simplificar el ecosistema de PowerShell y eliminar el código heredado.**

Windows PowerShell 2.0, introducido por primera vez en Windows 7, fue oficialmente obsoleto en 2017, pero siguió estando disponible como componente opcional para garantizar la compatibilidad con versiones anteriores. Ahora, Microsoft da un paso decisivo al excluirlo por completo de futuras versiones.

**Cronología de los cambios**

El proceso de eliminación se llevará a cabo en etapas:

*   **Julio de 2025:** PowerShell 2.0 ya se ha eliminado de las compilaciones preliminares de Windows Insider.
*   **Agosto de 2025:** El componente se eliminará de Windows 11, versión 24H2.
*   **Septiembre de 2025:** PowerShell 2.0 se excluirá de Windows Server 2025.

Todas las versiones posteriores de estos sistemas operativos se enviarán sin PowerShell 2.0.

**¿Por qué se está eliminando PowerShell 2.0?**

La razón principal de su eliminación son las preocupaciones de seguridad. PowerShell 2.0 carece de características de seguridad clave introducidas en versiones posteriores, como:

*   Integración con la interfaz de análisis de malware (AMSI).
*   Registro mejorado de bloques de script.
*   Modo de lenguaje restringido.

Estas omisiones hicieron de PowerShell 2.0 un objetivo atractivo para los atacantes que podían usarlo para eludir los sistemas de seguridad modernos. Además, la eliminación del componente obsoleto permitirá a Microsoft reducir la complejidad de la base de código y simplificar el soporte para el ecosistema de PowerShell.

**¿Qué significa esto para los usuarios y administradores?**

Para la mayoría de los usuarios, este cambio pasará desapercibido, ya que las versiones modernas de PowerShell, como PowerShell 5.1 y PowerShell 7.x, siguen estando disponibles y totalmente compatibles. Sin embargo, las organizaciones y los desarrolladores que utilicen scripts o software heredados que dependan explícitamente de PowerShell 2.0 deben tomar medidas.

**Recomendaciones de migración**

Microsoft recomienda encarecidamente:

*   **Migrar scripts y herramientas a versiones más recientes de PowerShell.** PowerShell 5.1 proporciona una alta compatibilidad con versiones anteriores con casi todos los comandos y módulos. PowerShell 7.x ofrece capacidades multiplataforma y muchas características modernas.
*   **Actualizar o reemplazar software obsoleto.** Si una aplicación o instalador antiguo requiere PowerShell 2.0, se debe encontrar una versión más nueva del producto. Esto también se aplica a algunos productos de servidor de Microsoft (Exchange, SharePoint, SQL) para los que hay versiones actualizadas disponibles que funcionan con PowerShell moderno.

**Versiones de Windows afectadas**

La eliminación de PowerShell 2.0 afectará a las siguientes versiones del sistema operativo:

*   Windows 11 (Home, Pro, Enterprise, Education, SE, Multi-Session, IoT Enterprise) versión 24H2.
*   Windows Server 2025.

Las versiones anteriores de Windows 11, como la 23H2, aparentemente conservarán PowerShell 2.0 como un componente opcional.

Este paso de Microsoft marca el final de una era en la administración de Windows, lo que subraya el compromiso de la compañía con un entorno informático más seguro y moderno.
