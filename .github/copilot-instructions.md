# Copilot Instructions — Life & Death

## Język komunikacji
Komunikacja z użytkownikiem odbywa się **wyłącznie po polsku**, chyba że użytkownik jawnie poprosi o odpowiedź po angielsku.

## Planowanie przed implementacją
**Zanim zaczniesz cokolwiek implementować** — przedstaw plan działania (co, jak, w jakiej kolejności).
Implementuj dopiero po jawnej akceptacji użytkownika słowem **"implementuj"** lub równoznacznym.

## Jakość kodu
- Kod pisany zgodnie z **najnowszymi standardami** danego języka / silnika (Godot 4 / GDScript)
- **Brak duplikacji kodu** — wspólna logika wydzielana do funkcji pomocniczych / autoloadów
- Każda metoda opatrzona **krótkim, zwięzłym komentarzem** opisującym jej cel (1 linijka)
- Kod i komentarze w kodzie pisane po **angielsku**

## Testowanie
Każda zmiana musi być **w pełni przetestowana**:
- Testy jednostkowe (unit tests) tam gdzie to możliwe
- Testy integracyjne dla interakcji między systemami
- Przed zgłoszeniem zmiany upewnij się, że wszystkie testy przechodzą

## Biblioteki i narzędzia
Można instalować potrzebne biblioteki, pluginy, extensions — z krótkim uzasadnieniem dlaczego są potrzebne.

## Branche git
Składnia nazwy brancha: `NNN-short-english-description`
- Numer porządkowy (3 cyfry), myślnik, opis w języku angielskim, słowa rozdzielone myślnikami
- Przykłady: `001-project-setup`, `005-adding-levels`, `012-bluetooth-multiplayer`
- Nazwy branchy zawsze po **angielsku**
