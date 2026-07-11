# Life & Death — Baza Zagadek

> Referowany w `ROADMAP.md` i `GAME_DESIGN.md`.
> Zagadki są prezentowane w grze przez `PuzzlePanel` (`game/scripts/obstacles/puzzle_panel.gd`).

> ⚠️ **STATUS (2026-07-12): zagadki wycofane z poziomów.** Decyzja projektowa —
> obecna forma (4 opcje + limit czasu) nie spodobała się w testach. Wszystkie
> `PuzzlePanel` w scenach zostały zastąpione dźwigniami (interlock kooperacyjny
> bez zmian). Mechanika `PuzzlePanel` + testy pozostają w kodzie; tabela niżej
> to baza treści na wypadek powrotu zagadek w innej formie.

## Mechanika (zgodna z GDD 6.3 / OQ-08)

- **4 opcje A/B/C/D** — gracz klika poprawną odpowiedź (`@export options: PackedStringArray`, `correct_index`).
- **Limit czasu** (`@export time_limit`, domyślnie 8 s) — odliczanie startuje po wejściu w strefę panelu.
  Po upływie czasu panel **blokuje się bezpowrotnie** (`is_locked()`), a powiązane drzwi zostają zamknięte
  do resetu poziomu.
- Poprawna odpowiedź otwiera drzwi (`target_door_id`) — aktywacja jest **server-authoritative** (przez bazę `DoorTrigger`).
- Błędna odpowiedź → komunikat, można próbować dalej aż do upływu czasu.

> ⚠️ Do zrobienia: synchronizacja stanu **zablokowania** (timeout) po sieci — obecnie zsynchronizowane
> jest tylko rozwiązanie (otwarcie drzwi); timer/lock działają lokalnie na urządzeniu interagującego gracza.
> Lokalizacja (i18n) EN/PL — teksty są obecnie zaszyte per instancja w scenie.

## Format wpisu

Każda zagadka: **id**, **strefa** (earth/heaven/hell), **typ**, **pytanie**, **4 opcje**, **index poprawnej**, **trudność** (1–5).

| id | Strefa | Typ | Pytanie | Opcje (A/B/C/D) | Poprawna | Trudność | Użyta w |
|----|--------|-----|---------|-----------------|----------|----------|---------|
| earth-riddle-01 | earth | word | Co żyje, gdy je, a ginie, gdy pije? | Woda / Ogień / Wiatr / Ziemia | B (Ogień) | 2 | Earth 02 |
| earth-math-01 | earth | math | `6 × 7 = ?` | 36 / 48 / 42 / 56 | C (42) | 1 | — |
| heaven-riddle-01 | heaven | word | Im więcej oddajesz, tym więcej masz | Złoto / Miłość / Czas / Woda | B (Miłość) | 2 | Heaven 01 (10 s) |
| heaven-riddle-02 | heaven | word | Jestem zawsze przed tobą, nigdy za tobą | Cień / Przeszłość / Przyszłość / Sen | C (Przyszłość) | 2 | Heaven 02 (8 s) |
| heaven-math-01 | heaven | math | `12 × 4 = ?` | 44 / 48 / 52 / 36 | B (48) | 2 | Heaven 03 (8 s) |
| heaven-math-02 | heaven | math | `7 × 8 = ?` | 54 / 58 / 48 / 56 | D (56) | 2 | Heaven 04 (6 s) |
| hell-math-01 | hell | math | `6 + 7 = ?` | 12 / 14 / 13 / 15 | C (13) | 1 | Hell 01 (10 s) |
| hell-math-02 | hell | math | `9 × 6 = ?` | 52 / 54 / 56 / 48 | B (54) | 2 | Hell 02 (8 s) |
| hell-math-03 | hell | math | `8 × 7 = ?` | 54 / 58 / 64 / 56 | D (56) | 2 | Hell 03 (8 s) |
| hell-math-04 | hell | math | `17 × 4 = ?` | 64 / 68 / 72 / 76 | B (68) | 3 | Hell 04 (6 s) |
| hell-math-05 | hell | math | `96 ÷ 8 = ?` | 14 / 16 / 12 / 11 | C (12) | 3 | Hell 04 (6 s) |

## Typy zagadek (wg GAME_DESIGN / OPEN_QUESTIONS)

- **math** — działania matematyczne (głównie Piekło, rosnąca trudność).
- **word** — zagadki słowne / filozoficzne (głównie Niebo).
- **coop** — kooperacyjne: rozwiązanie wymaga obu postaci (np. dźwignia + panel, przyciski jednocześnie).

## Przykłady zagadek słownych (z OQ-08, do rozbudowania)

1. PL: „Co żyje, gdy je, a ginie, gdy pije?" / EN: "What lives when fed, dies when given drink?" → **Ogień / Fire**
2. PL: „Im więcej oddajesz, tym więcej masz" / EN: "The more you give, the more you have" → **Miłość / Love**
3. PL: „Jestem zawsze przed tobą, nigdy za tobą" / EN: "Always in front of you, never behind" → **Przyszłość / Future**

## Do rozstrzygnięcia

- **Źródło danych** — czy zagadki jako zasób (`.tres`/JSON) ładowany do `PuzzlePanel`, czy konfigurowane
  per instancja w scenie (`@export`). Obecnie: per instancja.
- **Rozmieszczenie** — zagadki nie pojawiają się w pierwszych poziomach; wprowadzane stopniowo, nie każdy poziom.
