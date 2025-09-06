B-bye, PowerShell 2.0.

### Microsoft ostatecznie żegna się z PowerShell 2.0 w systemie Windows

**Korporacja Microsoft ogłosiła całkowite usunięcie przestarzałego komponentu Windows PowerShell 2.0 z systemów operacyjnych Windows 11 i Windows Server 2025, począwszy od sierpnia 2025 roku. Krok ten jest częścią globalnej strategii mającej na celu zwiększenie bezpieczeństwa, uproszczenie ekosystemu PowerShell i pozbycie się przestarzałego kodu.**

Windows PowerShell 2.0, po raz pierwszy wprowadzony w systemie Windows 7, został oficjalnie uznany za przestarzały już w 2017 roku, jednak pozostawał dostępny jako dodatkowy komponent w celu zapewnienia zgodności wstecznej. Teraz Microsoft podejmuje zdecydowany krok, całkowicie wykluczając go z przyszłych wydań.

**Oś czasu zmian**

Proces usuwania będzie przebiegał etapami:

*   **Lipiec 2025:** PowerShell 2.0 został już usunięty z wstępnych kompilacji Windows Insider.
*   **Sierpień 2025:** Komponent zostanie usunięty z systemu Windows 11, wersja 24H2.
*   **Wrzesień 2025:** PowerShell 2.0 zostanie wykluczony z systemu Windows Server 2025.

Wszystkie kolejne wydania tych systemów operacyjnych będą dostarczane bez PowerShell 2.0.

**Dlaczego PowerShell 2.0 odchodzi w przeszłość?**

Głównym powodem usunięcia są względy bezpieczeństwa. W PowerShell 2.0 brakuje kluczowych funkcji zabezpieczeń, które pojawiły się w późniejszych wersjach, takich jak:

*   Integracja z interfejsem do skanowania złośliwego oprogramowania (AMSI).
*   Rozszerzone logowanie bloków skryptów.
*   Tryb języka ograniczonego (Constrained Language Mode).

Te braki sprawiły, że PowerShell 2.0 stał się atrakcyjnym celem dla cyberprzestępców, którzy mogli go wykorzystać do omijania nowoczesnych systemów zabezpieczeń. Ponadto usunięcie przestarzałego komponentu pozwoli Microsoft zmniejszyć złożoność bazy kodu i uprościć wsparcie ekosystemu PowerShell.

**Co to oznacza dla użytkowników i administratorów?**

Dla większości użytkowników ta zmiana pozostanie niezauważona, ponieważ nowoczesne wersje PowerShell, takie jak PowerShell 5.1 i PowerShell 7.x, pozostają dostępne i są w pełni obsługiwane. Jednak organizacje i deweloperzy korzystający z przestarzałych skryptów lub oprogramowania, które wyraźnie zależą od PowerShell 2.0, muszą podjąć działania.

**Zalecenia dotyczące migracji**

Microsoft zdecydowanie zaleca:

*   **Migrację skryptów i narzędzi do nowszych wersji PowerShell.** PowerShell 5.1 zapewnia wysoką zgodność wsteczną z niemal wszystkimi poleceniami i modułami. PowerShell 7.x oferuje wieloplatformowość i wiele nowoczesnych funkcji.
*   **Aktualizację lub wymianę przestarzałego oprogramowania.** Jeśli stara aplikacja lub instalator wymaga PowerShell 2.0, należy znaleźć nowszą wersję produktu. Dotyczy to również niektórych produktów serwerowych Microsoft (Exchange, SharePoint, SQL), dla których istnieją zaktualizowane wersje, działające z nowoczesnym PowerShell.

**Dotknięte wersje systemu Windows**

Usunięcie PowerShell 2.0 dotknie następujących wersji systemów operacyjnych:

*   Windows 11 (Home, Pro, Enterprise, Education, SE, Multi-Session, IoT Enterprise) wersja 24H2.
*   Windows Server 2025.

Wcześniejsze wersje systemu Windows 11, takie jak 23H2, najwyraźniej zachowają PowerShell 2.0 jako opcjonalny komponent.

Ten krok Microsoft oznacza koniec całej epoki w administrowaniu systemem Windows, podkreślając zaangażowanie firmy w bezpieczniejsze i bardziej nowoczesne środowisko obliczeniowe.