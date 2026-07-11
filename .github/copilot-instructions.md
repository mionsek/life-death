# Copilot Instructions — Life & Death

## Język komunikacji
Komunikacja z użytkownikiem odbywa się **wyłącznie po polsku**, chyba że użytkownik jawnie poprosi o odpowiedź po angielsku.

## Planowanie przed implementacją
**Zanim zaczniesz cokolwiek implementować** — przedstaw plan działania (co, jak, w jakiej kolejności).
Implementuj dopiero po jawnej akceptacji użytkownika słowem **"implementuj"** lub równoznacznym.

## Jakość kodu
- Kod pisany zgodnie z **najnowszymi standardami** danego języka / silnika (Godot 4 / GDScript)
- **Brak duplikacji kodu** — wspólna logika wydzielana do funkcji pomocniczych / autoloadów / klas bazowych
- Każda metoda opatrzona **krótkim, zwięzłym komentarzem** opisującym jej cel (1 linijka)
- Kod i komentarze w kodzie pisane po **angielsku**
- **Statyczne typowanie** wszędzie (typowane zmienne, parametry, `-> void` / typy zwracane)
- `class_name` (PascalCase) dla typów wielokrotnego użytku; prywatne pola/metody z prefiksem `_`

## Konwencja podłączania sygnałów
- Sygnały podłączamy **w kodzie w `_ready()`** (`signal.connect(_handler)`) — to domyślna konwencja.
- Połączenia w scenie (`[connection]` w `.tscn`) dopuszczalne tam, gdzie test jednostkowy buduje
  uproszczone drzewo węzłów i podłączenie w kodzie by go wywróciło (np. `Seesaw` i jego czujniki `Plank`).

## Synchronizacja multiplayer
- Stan zmieniany przez rozgrywkę musi być **server-authoritative** w trybie `CONNECTED`:
  żądanie → serwer → broadcast (`@rpc`). Wzorzec: `door.gd`, `door_trigger.gd`, `seesaw.gd`.
- W trybie offline logika wykonuje się lokalnie (sprawdzaj `NetworkManager.state`).

## Testowanie
Każda zmiana musi być **w pełni przetestowana**:
- Testy jednostkowe (unit tests) tam gdzie to możliwe — `game/tests/unit/`
- Testy integracyjne dla interakcji między systemami — `game/tests/integration/`
- Uruchamianie: `./run_tests.ps1` (Windows) lub GUT headless; CI robi to na każdym push/PR
- Przed zgłoszeniem zmiany upewnij się, że **wszystkie testy przechodzą**

## Biblioteki i narzędzia
Można instalować potrzebne biblioteki, pluginy, extensions — z krótkim uzasadnieniem dlaczego są potrzebne.

## Branche git
Składnia nazwy brancha: `NNN-short-english-description`
- Numer porządkowy (3 cyfry), myślnik, opis w języku angielskim, słowa rozdzielone myślnikami
- Przykłady: `001-project-setup`, `005-adding-levels`, `012-bluetooth-multiplayer`
- Nazwy branchy zawsze po **angielsku**
- Po zmergowaniu PR **nie usuwamy** brancha — zostawiamy go w repozytorium
