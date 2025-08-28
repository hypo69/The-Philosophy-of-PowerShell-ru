B-bye, PowerShell 2.0.

### Microsoft Finally Says Goodbye to PowerShell 2.0 in Windows

**Microsoft Corporation has announced the complete removal of the deprecated Windows PowerShell 2.0 component from Windows 11 and Windows Server 2025 operating systems, starting August 2025. This step is part of a global strategy to enhance security, simplify the PowerShell ecosystem, and eliminate legacy code.**

Windows PowerShell 2.0, first introduced in Windows 7, was officially deprecated in 2017 but remained available as an optional component to ensure backward compatibility. Now, Microsoft is taking a decisive step, completely excluding it from future releases.

**Timeline of Changes**

The removal process will occur in stages:

*   **July 2025:** PowerShell 2.0 has already been removed from Windows Insider preview builds.
*   **August 2025:** The component will be removed from Windows 11, version 24H2.
*   **September 2025:** PowerShell 2.0 will be excluded from Windows Server 2025.

All subsequent releases of these operating systems will ship without PowerShell 2.0.

**Why is PowerShell 2.0 being phased out?**

The primary reason for removal is security considerations. PowerShell 2.0 lacks key security features introduced in later versions, such as:

*   Integration with the Anti-Malware Scan Interface (AMSI).
*   Enhanced script block logging.
*   Constrained Language Mode.

These omissions made PowerShell 2.0 an attractive target for attackers who could use it to bypass modern security systems. Additionally, removing the deprecated component will allow Microsoft to reduce code base complexity and simplify support for the PowerShell ecosystem.

**What does this mean for users and administrators?**

For most users, this change will go unnoticed, as modern PowerShell versions, such as PowerShell 5.1 and PowerShell 7.x, remain available and fully supported. However, organizations and developers using outdated scripts or software that explicitly depend on PowerShell 2.0 need to take action.

**Transition Recommendations**

Microsoft strongly recommends:

*   **Migrate scripts and tools to newer PowerShell versions.** PowerShell 5.1 provides high backward compatibility with almost all commands and modules. PowerShell 7.x offers cross-platform capabilities and many modern features.
*   **Update or replace outdated software.** If an old application or installer requires PowerShell 2.0, a newer version of the product must be found. This also applies to some Microsoft server products (Exchange, SharePoint, SQL) for which updated versions are available that work with modern PowerShell.

**Affected Windows Versions**

The removal of PowerShell 2.0 will affect the following operating system versions:

*   Windows 11 (Home, Pro, Enterprise, Education, SE, Multi-Session, IoT Enterprise) version 24H2.
*   Windows Server 2025.

Earlier versions of Windows 11, such as 23H2, will apparently retain PowerShell 2.0 as an optional component.

This step by Microsoft marks the end of an era in Windows administration, emphasizing the company's commitment to a more secure and modern computing environment.