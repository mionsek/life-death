# Life & Death — Baza Zagadek

> Referowany w `ROADMAP.md` i `GAME_DESIGN.md`.
> Zagadki są prezentowane w grze przez `PuzzlePanel` (`game/scripts/obstacles/puzzle_panel.gd`).

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

| id | Strefa | Typ | Pytanie | Opcje (A/B/C/D) | Poprawna | Trudność |
|----|--------|-----|---------|-----------------|----------|----------|
| earth-riddle-01 | earth | word | Co żyje, gdy je, a ginie, gdy pije? | Woda / Ogień / Wiatr / Ziemia | B (Ogień) | 2 |
| earth-math-01 | earth | math | `6 × 7 = ?` | 36 / 48 / 42 / 56 | C (42) | 1 |
| _..._ | | | | | | |

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
