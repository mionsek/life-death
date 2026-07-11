# Heaven 01 — „Wrota Niebios" (flagowy level design)

> Scena: `game/scenes/levels/heaven/Level_Heaven_01.tscn` · Rozmiar świata: **640×720** (pion, wspinaczka)
> Strefa: Niebo — pierwsza brama; wprowadza mechaniki Nieba w bezpiecznym tempie.
> Trudność: ★★☆☆☆ (wejściowa) — ale już z pełnym interlockiem kooperacyjnym.

## 1. Cel designu

1. Nauczyć zasadę Nieba: **chmury noszą tylko Strażniczkę**, **święte światło zabija tylko Kostuchę**.
2. Wymusić PRAWDZIWĄ kooperację przez **podwójny interlock** (patrz §4) — żaden gracz nie
   przejdzie sam.
3. Pokazać pion: kamera oddalona + minimapa mają tu sens (2 ekrany wysokości).

## 2. Trasy graczy

```
   [SZCZYT y=140]  ⚪portal G (240)      ⚪portal P (400)
        C5 ─────────╮        ☀BEAM (x≈310–342, y 160–280)
   G:  C4 ── D2🚪 ──╯         │   M4b ← detour Kostuchy (y=200)
        C3 [LEVER g1]         │  M4 ──╯   (y=280)
        C2                    M3 [LEVER l1] (y=360)
        C1                    M2 ── D1🚪 (y=480)
   G: chmury (lewa)           M1        (y=580)
   ─────────────── ZIEMIA (złoto, y=660) ───────────────
      spawn G (150)   huśtawka (320)   spawn P (420)
```

- **Kostucha (Player)** — prawa strona, marmurowe platformy M1→M2→M3→M4→M4b→szczyt.
- **Strażniczka (Guardian)** — lewa strona, schody z chmur C1→C2→C3→C4→C5→szczyt.
- Huśtawka na starcie: zabawka fizyczna / nauka mechaniki (bez gate'owania postępu).

## 3. Beaty poziomu (od dołu)

| # | y | Wydarzenie | Uczy |
|---|---|-----------|------|
| 1 | 660 | Start na złotej ziemi, huśtawka pośrodku | sterowanie, seesaw |
| 2 | 570–580 | Rozwidlenie: chmury (lewo/G) vs marmur (prawo/P) | chmury tylko dla G |
| 3 | 480 | **D1** zamyka trasę P na M2 | czekaj na partnera |
| 4 | 380–420 | **Dźwignia G** na C3 → otwiera D1 | koop: Życie ratuje Śmierć |
| 5 | 360 | **Dźwignia P** na M3 → otwiera D2 na trasie G | koop: Śmierć ratuje Życie |
| 6 | 160–280 | **Święte światło** blokuje skok P „na wprost" → detour M4b | światło zabija tylko P |
| 7 | 140 | Szczyt, 2 portale — obaj muszą stać jednocześnie | zasada wyjścia |

## 4. Interlock kooperacyjny (anty-deadlock)

```
G dochodzi do C3 (dźwignia G) ──otwiera──►  D1 (trasa P)
P dochodzi do M3 (dźwignia P) ──otwiera──►  D2 (trasa G)
```
- G osiąga swoją dźwignię **bez** przechodzenia przez D2 (D2 jest wyżej, między C4 a C5) ✓
- P osiąga swoją dźwignię **dopiero po** otwarciu D1 ✓
- Kolejność wymuszona: `dźwignia G → D1 → dźwignia P → D2` — brak możliwości
  zakleszczenia, brak możliwości pominięcia partnera.

> ℹ️ Pierwotnie D1 otwierał panel zagadki; zagadki zostały na razie wycofane
> z poziomów (mechanika `PuzzlePanel` pozostaje w kodzie — patrz `docs/PUZZLES.md`).

## 5. Zabójcze strefy

| Strefa | Pozycja | Zabija | Wizual |
|--------|---------|--------|--------|
| Święte światło | kolumna x 310–342, y 160–280 | tylko Kostuchę | `light_beam.png` (tiled, pulsujący) |

Brak killzone dna — ziemia ciągła; upadek = strata czasu, nie życie (poziom wejściowy).

## 6. Metryki skoku (sanity-check)

- Skok: wys. ~150 px, zasięg ~220 px (v=-550, g=980, speed=200)
- Największy wymagany skok pionowy: 120 px (M2→M3) ✓
- Największy wymagany skok poziomy: 160 px (M4b→szczyt) ✓
- Odstępy chmur G: ≤110 px pionowo ✓

## 7. Progresja trudności w strefie

| Level | Beams | Chmury vs marmur | Dźwignie | Nowość |
|-------|-------|------------------|---------|--------|
| **H01** | 1 statyczny | 50/50 | 2 | wszystkie mechaniki, łagodnie |
| H02 | 2 | 60/40 | 2 | wąskie kolumny marmuru |
| H03 | 3 | 70/30 | 2 | dłuższe sekwencje bez ziemi |
| H04 | 4 | 80/20 | 2 | mini-platformy 64 px, szczyt-diament |
