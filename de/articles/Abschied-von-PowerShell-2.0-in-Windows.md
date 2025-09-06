B-bye, PowerShell 2.0.

### Microsoft verabschiedet sich endgültig von PowerShell 2.0 in Windows

**Die Microsoft Corporation hat die vollständige Entfernung der veralteten Komponente Windows PowerShell 2.0 aus den Betriebssystemen Windows 11 und Windows Server 2025 ab August 2025 angekündigt. Dieser Schritt ist Teil einer globalen Strategie zur Verbesserung der Sicherheit, Vereinfachung des PowerShell-Ökosystems und Beseitigung von veraltetem Code.**

Windows PowerShell 2.0, das erstmals in Windows 7 eingeführt wurde, wurde bereits 2017 offiziell als veraltet eingestuft, blieb jedoch als optionale Komponente zur Gewährleistung der Abwärtskompatibilität verfügbar. Nun unternimmt Microsoft einen entscheidenden Schritt und schließt es vollständig aus zukünftigen Releases aus.

**Chronologie der Änderungen**

Der Entfernungsprozess wird schrittweise erfolgen:

*   **Juli 2025:** PowerShell 2.0 wurde bereits aus den Vorabversionen von Windows Insider entfernt.
*   **August 2025:** Die Komponente wird aus Windows 11, Version 24H2, entfernt.
*   **September 2025:** PowerShell 2.0 wird aus Windows Server 2025 ausgeschlossen.

Alle nachfolgenden Versionen dieser Betriebssysteme werden ohne PowerShell 2.0 ausgeliefert.

**Warum verschwindet PowerShell 2.0?**

Der Hauptgrund für die Entfernung sind Sicherheitsbedenken. In PowerShell 2.0 fehlen wichtige Schutzfunktionen, die in späteren Versionen hinzugefügt wurden, wie zum Beispiel:

*   Integration mit der Schnittstelle zur Überprüfung auf Malware (AMSI).
*   Erweiterte Protokollierung von Skriptblöcken.
*   Eingeschränkter Sprachmodus (Constrained Language Mode).

Diese Mängel machten PowerShell 2.0 zu einem attraktiven Ziel für Angreifer, die es nutzen konnten, um moderne Schutzsysteme zu umgehen. Darüber hinaus wird die Entfernung der veralteten Komponente Microsoft ermöglichen, die Komplexität der Codebasis zu reduzieren und die Unterstützung des PowerShell-Ökosystems zu vereinfachen.

**Was bedeutet das für Benutzer und Administratoren?**

Für die meisten Benutzer wird diese Änderung unbemerkt bleiben, da moderne PowerShell-Versionen wie PowerShell 5.1 und PowerShell 7.x weiterhin verfügbar und vollständig unterstützt werden. Organisationen und Entwickler, die veraltete Skripte oder Software verwenden, die explizit von PowerShell 2.0 abhängen, müssen jedoch Maßnahmen ergreifen.

**Empfehlungen für den Übergang**

Microsoft empfiehlt dringend:

*   **Skripte und Tools auf neuere PowerShell-Versionen zu migrieren.** PowerShell 5.1 bietet eine hohe Abwärtskompatibilität mit praktisch allen Befehlen und Modulen. PowerShell 7.x bietet plattformübergreifende Kompatibilität und viele moderne Funktionen.
*   **Veraltete Software zu aktualisieren oder zu ersetzen.** Wenn eine alte Anwendung oder ein Installationsprogramm PowerShell 2.0 erfordert, muss eine neuere Version des Produkts gefunden werden. Dies gilt auch für einige Microsoft-Serverprodukte (Exchange, SharePoint, SQL), für die aktualisierte Versionen existieren, die mit modernem PowerShell funktionieren.

**Betroffene Windows-Versionen**

Die Entfernung von PowerShell 2.0 betrifft die folgenden Versionen von Betriebssystemen:

*   Windows 11 (Home, Pro, Enterprise, Education, SE, Multi-Session, IoT Enterprise) Version 24H2.
*   Windows Server 2025.

Frühere Versionen von Windows 11, wie 23H2, werden PowerShell 2.0 anscheinend als optionale Komponente beibehalten.

Dieser Schritt von Microsoft markiert das Ende einer ganzen Ära in der Windows-Administration und unterstreicht das Engagement des Unternehmens für eine sicherere und modernere Computerumgebung.