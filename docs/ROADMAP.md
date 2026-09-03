# Life & Death — Roadmap i Plan Realizacji

> Ten dokument jest aktualizowany po każdej sesji. Status: ✅ Zrobione | 🔄 W toku | ⬜ Do zrobienia

---

## STATUS PROJEKTU — 2026-09-03

> Stan zweryfikowany na commicie `4e42d1b` (merge brancha `027-tileset-terrain`).
> Liczby pochodzą z uruchomionego pakietu testów i z przeglądu kodu, nie z opisów commitów.

| Faza | Status | Opis |
|------|--------|------|
| Faza 0 — Decyzje | ✅ Zakończona | OQ zamknięte poza OQ-03 (lista przeszkód, rozbudowywana) i OQ-06 (bossowie, odłożone) |
| Faza 1 — Setup / Prototyp | ✅ Zakończona | Ruch, skok, 2 graczy, śmierć/reset, multiplayer LAN; brak testu na 2 fizycznych telefonach |
| Faza 2 — Core Gameplay | ✅ W praktyce zamknięta | Umiejętności (warstwy kolizji), przeszkody Tier 1, monety, zapis — działają we wszystkich strefach |
| Faza 3 — Treść i poziomy | 🔄 W toku | 14 scen poziomów z 42 węzłów mapy (Ziemia 01–06, Niebo 01–04, Piekło 01–04); sklep nierozpoczęty |
| Faza 4 — Grafika/Audio | 🔄 W toku | Assety ręcznie rysowane zastępują proceduralne (drzwi, dźwignia, przycisk, huśtawka, teren); 4 SFX, 0 muzyki |
| Faza 5 — Polish i testy | 🔄 Częściowo | 133 testy GUT w 27 skryptach, wszystkie przechodzą; CI (GitHub Actions) |
| Faza 6 — iOS Port | ⬜ Nie rozpoczęta | — |

### Ostatnio zrobione (przez branche PR 001–013)
- ✅ `001`–`005` — setup, ruch gracza, drugi gracz (Guardian), śmierć/reset, sprite'y
- ✅ `006-character-abilities` — umiejętności przez warstwy/maski kolizji (FireZone, CloudPlatform)
- ✅ `007` — multiplayer LAN: ENet (port 7777) + auto-discovery UDP (7778), `NetworkManager`
- ✅ `008-level-system` — `LevelManager`, rejestr 60 poziomów (earth/heaven/hell × 20)
- ✅ `009-save-system` — `SaveManager`, zapis JSON + Pair ID (UUID v4)
- ✅ `010`–`011` — poprawki Earth-01, poziomy Earth 02–06
- ✅ `012-obstacles` — ExitPortal, Door, Lever, PuzzlePanel, Seesaw + wspólna baza `DoorTrigger`
- ✅ **CI**: `.github/workflows/tests.yml` uruchamia GUT headless; runner `run_tests.ps1`
- ✅ `013-worldmap-heaven-hell`:
  - **Mapa świata jako drzewo binarne obrócone o 90°** (LevelSelect): korzeń (start)
    z lewej, gałęzie rozdzielają się w prawo — górne dziecko wspina się ku Niebu
    (im wyżej, tym trudniej dla Kostuchy), dolne schodzi ku Piekłu (analogicznie
    dla Strażniczki); wiersze 0/±1 = Ziemia; poziom odblokowuje dzieci w grafie
    (`LEVEL_GRAPH`)
  - **Zagadki wycofane z poziomów** (decyzja 2026-07-12): wszystkie `PuzzlePanel`
    w scenach zastąpione dźwigniami; mechanika i testy pozostają w kodzie
  - **Fix crash rejestru**: rejestr zawiera wszystkie 42 węzły `LEVEL_GRAPH`
    (są widoczne na mapie), ale `load_level` sprawdza `ResourceLoader.exists()`
    i odmawia z ostrzeżeniem zamiast crashować, gdy sceny jeszcze nie ma
  - **Niebo 01–04** (pionowe 640×720, chmury + święte światło `LightZone` zabijające
    tylko Kostuchę) i **Piekło 01–04** (poziome 1280×360, lawa, wysoka trasa Strażniczki);
    wszystkie z interlockiem kooperacyjnym (panel↔dźwignia otwierają bramy partnera)
  - **Flagowy level design**: `docs/LEVEL_DESIGN/heaven_01.md` — „Wrota Niebios"
  - **Pixel-art assety generowane proceduralnie** (`game/tools/generate_assets.gd`):
    postacie z animacjami (idle/walk/jump), tilesety 3 stref, przeszkody, portale,
    tła, mapa świata; podpięte do wszystkich scen (retekstura Ziemi 01–06)
  - **Kamera oddalona** (zoom 0.8) z limitami do granic poziomu (`level_size`)
  - **Minimapa** w rogu (żywy podgląd przez współdzielony World2D + kropki graczy);
    klik ⇒ pełna mapa poziomu, ponowny klik ⇒ powrót do rogu
  - Ziemia 03–06: stare pojedyncze wyjścia zastąpione podwójnymi portalami per postać
  - Testy: 86 (nowe: graf poziomów, LightZone, ładowanie wszystkich 14 poziomów świata)

### Ostatnio zrobione (cd.)
- ✅ `014-coins-gate` — **monety jako wymóg ukończenia poziomu**:
  - Czaszki (Kostucha) i Aureole (Strażniczka) — 2–3 na poziom, rozmieszczone
    na trasach postaci (czaszki m.in. w lawie, aureole na chmurach)
  - HUD w lewym górnym rogu: `💀 0/3` / `😇 2/2`; zielony gdy komplet
  - Portal postaci **zablokowany** (przyciemniony, z licznikiem) dopóki postać
    nie zbierze całego setu; poziom kończy się dopiero z oboma kompletami
  - `Collectible` (baza), sceny `Skull`/`Halo`, `CoinHud`; testy 96
  - Naprawa retekstury: tła WorldEnv i wizualizacje z cyframi (LavaVis1 itd.)

### Ostatnio zrobione (cd. 2)
- ✅ `015-worldmap-polish` — **mapa świata wg odręcznego szkicu**: graf 42 poziomów
  w 3 pasmach na kanwie 1280×720 (`bg1.png`), bąbelki z tintami stref, kropkowane
  ścieżki, kłódki na niedostępnych poziomach, pan/pinch-zoom pod telefon,
  mini-minimapa 46px rozwijana tapnięciem
- ✅ `016-level-backdrops` — **tła poziomów jako wycinki mapy świata**: każdy poziom
  dostaje fragment `bg1.png` wycentrowany na swojej pozycji z `LEVEL_GRAPH`
  (`level_base._setup_background()`, `BG_CROP_FRACTION` steruje zoomem);
  `bg1.png` podniesiony do 3072×2048

### Ostatnio zrobione (cd. 3)
- ✅ `021-tutorials-settings` — **żywe instrukcje, języki PL/EN, ustawienia, pauza**:
  - **Live-instrukcje przeszkód** (`TutorialManager`): gdy przeszkoda danego typu
    (lawa, święte światło, chmury, ruchome/kruszące/jednokierunkowe platformy,
    płyty, dźwignie, drzwi, huśtawka, portale, czaszki, serduszka) pierwszy raz
    pojawia się w kadrze kamery — gra pauzuje i tłumaczy mechanikę; „widziane"
    zapisywane w `user://tutorials_seen.json` (raz na instalację)
  - **i18n PL/EN** (`i18n/translations.csv` + TranslationServer); menu, ekran
    śmierci, pauza, ustawienia i instrukcje przetłumaczone
  - **Ustawienia** (`Settings` autoload → `user://settings.cfg`): dźwięk, muzyka
    (busy SFX/Music), język; dostępne z menu głównego i z pauzy
  - **Menu pauzy (Escape)**: wznów / restart / ustawienia / mapa świata;
    restart w multi tylko dla hosta, z potwierdzeniem u partnera (RPC)

### Ostatnio zrobione (cd. 4) — dźwięk i assety rysowane ręcznie (022–027)
- ✅ `022-audio-sfx` — autoload `AudioFx` + busy `SFX`/`Music`
  (`default_bus_layout.tres`); 4 efekty: dźwignia/płyta (`Door_Switch_01`),
  brama (`Gate_Open_01`), ukończenie poziomu (`Level_Complete_01`),
  wybór na mapie (`Menu_Select_02`)
- ✅ `023-tutorials-assets` — **pierwsze assety z odręcznych rysunków**:
  - **Drzwi warstwowe**: `door_back` / `door_gate` / `door_front` / `door_light`
    + `shaders/door_gate.gdshader` — krata zjeżdża w górę, a postać przechodzi
    przez prześwit pomiędzy warstwami (efekt głębi)
  - **Dźwignia**: `lever_base` + `lever_handle` — obraca się sama rączka wokół
    przegubu, płynnie zamiast skokowo
  - **Baner „Level Complete"** (`scenes/ui/LevelComplete.tscn`) na 3 s przed
    powrotem na mapę; jingiel gra nad zamrożonym banerem, nie po nim
  - **Tutoriale**: cieńszy pierścień reflektora + blokada lekcji, gdy którykolwiek
    bohater jest w powietrzu; `TutorialManager.enabled` ustawione na `false`
    na czas playtestów
  - `tools/slice_doors.gd` — wycinanie i odszumianie sprite'ów ze skanu rysunku
- ✅ `024-lever-pivot` — rączka dźwigni zakotwiczona w czarnej kropce podstawy
  (`tools/find_anchor.gd`, podgląd `tools/LeverPreview.tscn`), poprawiona grafika drzwi
- ✅ `025-button-asset` — kamienny przycisk płyty naciskowej (`button_up`/`button_down`
  cięte przez `tools/slice_button.gd`), rysowany za postacią
- ✅ `026-seesaw-asset` — huśtawka: obracająca się belka na nieruchomej podstawie
  (`tools/slice_seesaw.gd`). Fizyka: `TORQUE` 2.5 → 6.0 plus nowy `IMPACT_IMPULSE`
  (1.8), więc skok na ramię realnie przechyla deskę. Skok postaci:
  `jump_velocity` −550 → −520 (~138 px zamiast ~154)
- ✅ `027-tileset-terrain` — **malowalny tileset terenu z autotilingiem**:
  `tools/slice_terrain.gd` zamienia odręczny arkusz w atlas 4×4 indeksowany maską
  sąsiadów (16 wariantów; 5 cienkich ról składanych z ćwiartek),
  `tools/build_terrain_tileset.gd` generuje `assets/tilesets/earth/earth_terrain.tres`
  z peering bits i pełną kolizją 32×32 na każdym kaflu — malowany poziom jest solidny
  bez dodatkowych węzłów; instrukcja w `LEVEL_BUILDING.md` §2 + podglądówka
  `docs/terrain_tiles_reference.png`

### Do zrobienia — następne kroki

**Zaległości z ostatnich branchy (potwierdzone w kodzie):**
- ⬜ **Włączyć z powrotem tutoriale** — `TutorialManager.enabled = false` od `023`
  („na czas playtestów"); cały system działa, ale nic się nie wyświetla w grze
- ⬜ **Użyć tilesetu terenu w poziomach** — `earth_terrain.tres` nie jest podpięty
  do żadnej sceny (znają go tylko narzędzia); Ziemia 01–06 nadal stoi na ręcznych
  `StaticBody2D` + `NinePatchRect`. Tileset istnieje tylko dla Ziemi — Niebo i Piekło
  nie mają swoich
- ⬜ **Skok jeszcze niżej** (zgłoszone 2026-07-21): `jump_velocity` = −520 (~138 px).
  Nadal za wysoko — docelowo niżej, ale to **wymusza rewizję rozstawienia półek**:
  `LEVEL_BUILDING.md` projektuje skoki do 130 px, więc trzeba obniżyć ten limit
  razem ze skokiem. Zrobić przed budowaniem właściwych poziomów
- ⬜ **Więcej dźwięków** (zgłoszone 2026-07-15): są 4 efekty, brakuje m.in. skoku,
  śmierci, zbierania czaszek/serc, odbicia postaci, kruszenia platform.
  `assets/audio/music/` jest **puste** — 0 muzyki, choć bus `Music` i przełącznik
  w ustawieniach już działają
- ⬜ **Minimapa — do poprawy** (zgłoszone 2026-07-13): działa, ale jakość/UX
  wymaga dopracowania
- ⬜ **Restart w multi — test na 2 urządzeniach** (flow RPC host→klient
  zaimplementowany w `pause_menu.gd`, przetestowany tylko offline/lokalnie)

**Treść i systemy:**
- ⬜ **Poziomy: 14 scen z 42 węzłów mapy** — brakuje Ziemi 07–11 (5), Nieba 05–16 (12)
  i Piekła 05–15 (11), czyli 28 węzłów widocznych na mapie bez sceny. Docelowo
  OQ-05 mówi o 60 poziomach, więc graf też jest niepełny
- ⬜ **Sklep** (ulepszenia: szybkość / wyskok / 10 s nietykalności) — nierozpoczęty;
  wymaga decyzji, czym się płaci, skoro monety są teraz wymogiem ukończenia poziomu
  (np. suma zebranych narastająco)
- ⬜ **Zagadki** — `PuzzlePanel` + testy zostają w kodzie, ale **żadna scena poziomu
  go nie używa** (wycofane 2026-07-12). Baza treści: `docs/PUZZLES.md`. Do decyzji,
  czy wracają w innej formie
- ⬜ Synchronizacja blokady panelu zagadki po sieci (timeout tylko lokalny)
- ⬜ **Przeszkody z OQ-03 bez implementacji**: mrok (śmiertelny dla Strażniczki),
  woda, kwiaty spowalniające Kostuchę, ruchome kolce. Zaimplementowane są lawa
  (`fire_zone.gd`), święte światło (`light_zone.gd`) i chmury
- ⬜ **Bossowie** — OQ-06 nadal odłożone, decyzja niepodjęta
- ⬜ **Dokumentacja poziomów** — `docs/LEVEL_DESIGN/` zawiera tylko `heaven_01.md`
  na 14 istniejących poziomów
- ⬜ **Publikacja** (Faza 5.4) i **port iOS** (Faza 6) — nierozpoczęte

**Zamknięte:**
- ✅ ~~Przenieść zmiany z drugiego laptopa~~ — scalone 2026-07-14 (branche
  017–020: czaszki + serduszka, tileset Mossy, odbijanie postaci, przeszkody
  Tier 1)
- ✅ ~~Ekran ustawień~~ — zrobiony w `021-tutorials-settings` (dźwięk/muzyka/język,
  dostępny z menu i z pauzy)

---

> **WAŻNE:** Sekcje „Faza 0–6" niżej to **pierwotny plan z fazy planowania**. Bieżący
> stan opisuje część „STATUS PROJEKTU" na górze — checkboxy niżej zostały odhaczone
> na podstawie przeglądu kodu (`[~]` = zrobione inaczej niż planowano albo świadomie
> odrzucone).  
> Ten dokument jest aktualizowany po każdej sesji.

---

## Faza 0 — Decyzje Architektoniczne
**Status: ✅ ZAKOŃCZONA**

### 0.1 Decyzje podjęte
- [x] **OQ-02** — Silnik: **Godot 4** (GDScript)
- [x] **OQ-01** — Protokół: WiFi Direct + Bluetooth fallback
- [x] **OQ-04** — Śmierć: freeze + reset poziomu, bez limitu żyć
- [x] **OQ-09** — Zapis: system Pair ID
- [x] **OQ-11** — Kamera per gracz (~50% mapy)
- [x] OQ-05, 07, 08, 10, 12, 13, 14, 15 — patrz OPEN_QUESTIONS.md
- [~] **OQ-03** — lista przeszkód: baza zatwierdzona, status „🔄 W toku"
  (mrok, woda, kwiaty, kolce wciąż bez implementacji)
- [~] **OQ-06** — bossowie: status „🔄 Odłożone", decyzji nadal nie ma

### 0.2 Deliverables
- [~] `OPEN_QUESTIONS.md` — zamknięte wszystkie poza OQ-03 i OQ-06 (patrz wyżej)
- [x] Decyzje tech zapisane w GDD i OQ
- [x] Szkic mapy poziomów — odręczny szkic przeniesiony do `LEVEL_GRAPH` (42 węzły)
  i ekranu `LevelSelect` w branchu `015-worldmap-polish`
- [x] Baza zagadek (`docs/PUZZLES.md`) — 11 zagadek spisanych; same panele wycofane z gry

---

## Faza 1 — Prototyp Proof of Concept
**Status: ✅ ZAKOŃCZONA** — poza testami na fizycznych urządzeniach (1.4)

### 1.1 Setup projektu
- [x] Instalacja Godot 4.6.2
- [x] Konfiguracja projektu (360×640, GL Compatibility, GDScript)
- [x] Repozytorium git + GitHub
- [x] Struktura katalogów projektu
- [x] GUT v9.6.0 (testy jednostkowe)
- [x] Scena `MainMenu.tscn` + testy
- [x] Kod scalony do `master` (praca idzie branchami `NNN-nazwa` scalanymi merge commitem)

### 1.2 Mechanika podstawowa (jeden gracz, jeden poziom testowy)
- [x] Gracz może się poruszać (lewo/prawo) — `scripts/characters/player.gd`
- [x] Gracz może skakać (`jump_velocity`, coyote-free, tylko z podłoża)
- [x] Kolizje z podłogą i ścianami (`CharacterBody2D` + warstwy kolizji)
- [x] Prosta kamera śledząca gracza (`Camera2D` w scenie postaci, limity do `level_size`)
- [x] Sterowanie dotykowe (`TouchControls.tscn` + `TouchControlsP2.tscn`)

### 1.3 Mechanika 2 graczy (offline)
- [x] Implementacja połączenia — ENet (7777) + auto-discovery UDP (7778), `NetworkManager`
- [x] Synchronizacja pozycji obu graczy w czasie rzeczywistym (RPC)
- [ ] Test latencji — cel: < 100ms (niezmierzony)
- [x] Gracz 1 widzi Gracza 2 na swoim ekranie i odwrotnie (`Lobby.tscn` + gra w sieci)

### 1.4 Testowanie kluczowe
- [ ] Test na 2 fizycznych telefonach Android
- [ ] Test w trybie lotniczym (WiFi/komórkowe OFF)

**Milestone:** Dwóch graczy chodzi po platformie w tym samym czasie offline ✅
(zweryfikowane lokalnie/dwie instancje; nie na dwóch telefonach)

---

## Faza 2 — Core Gameplay
**Status: ✅ W praktyce zamknięta** — otwarte zostają tylko przeszkody, których
nie ma jeszcze w kodzie (mrok, woda) i wycofane zagadki

### 2.1 Postać — Kostucha
- [x] Sprite (proceduralny `AnimatedSprite2D`, do podmiany na rysunki użytkownika)
- [x] Odporność na ogień/lawę (`fire_zone.gd` zabija tylko Strażniczkę)
- [ ] Interakcja z „Mroczną Strefą" — brak implementacji mroku
- [x] Animacja chodzenia, skakania, stania (`idle` / `walk` / `jump`)

### 2.2 Postać — Strażniczka Życia
- [x] Sprite (`Guardian.tscn`)
- [x] Chodzenie po chmurach (warstwy kolizji; chmury w Ziemi i Niebie)
- [ ] Odporność na wodę — brak wody w grze
- [x] Animacja chodzenia, skakania, stania

### 2.3 Środowisko — Poziom Testowy (Ziemia)
- [x] Tileset: platformy, podłoga, tło (Mossy + malowalny `earth_terrain.tres` z `027`)
- [x] Elementy ognia (śmiertelne dla Strażniczki) — `FireZone`
- [x] Chmury (dostępne tylko dla Strażniczki)
- [~] Klucz do zebrania per postać — **zastąpione monetami** (czaszki/serca), kluczy nie ma
- [x] Drzwi wymagające współpracy — dźwignia/płyta jednej postaci otwiera bramę drugiej
- [~] Checkpoint — **odrzucone decyzją OQ-04** (reset zawsze od początku poziomu)
- [x] Cel (koniec poziomu) — `ExitPortal` per postać

### 2.4 System monet
- [x] Czaszki rozlokowane na poziomie (`Skull.tscn`, dla Kostuchy)
- [x] Serca rozlokowane na poziomie (`Heart.tscn`, dla Strażniczki — nazwa „aureole"
  z pierwotnego planu, w kodzie to serduszka)
- [x] Licznik monet na HUD (`CoinHud`), portal zablokowany do skompletowania setu

### 2.5 Zagadka (jeden typ)
- [x] Wyświetlenie pytania w grze (`PuzzlePanel`, 4 opcje + limit czasu)
- [~] Klawiatura wirtualna — niepotrzebna, wybrano wariant A/B/C/D
- [x] Walidacja odpowiedzi → otwiera drzwi (server-authoritative przez `DoorTrigger`)
- ⚠️ **Wycofane z poziomów 2026-07-12** — kod i testy zostają, żadna scena nie używa panelu

**Milestone:** Jeden kompletny poziom — od startu do mety ✅ (14 poziomów gotowych)

---

## Faza 3 — Treść i Poziomy
**Cel:** Wszystkie poziomy, mapa świata, sklep (2–3 miesiące)

### 3.1 Mapa Świata
- [x] Ekran drzewa poziomów (`LevelSelect.tscn`) — 42 węzły na `bg1.png`, pan + pinch-zoom
- [x] Wizualizacja odblokowanych i zablokowanych poziomów (kłódki, przyciemnione bąbelki)
- [ ] Wybór kolejnego poziomu przez oboje graczy — `level_select.gd` nie ma żadnego RPC,
  wybór jest lokalny

### 3.2 Poziomy — Ziemia (docelowo 11 węzłów w grafie)
- [ ] Zaprojektowanie layoutów na papierze — brak dokumentów dla Ziemi
- [x] Implementacja: **6 z 11** (Earth 01–06); brakuje 07–11
- [ ] Wzrastająca trudność — niesprawdzone w playtestach
- [~] Mix zagadek — zagadki wycofane; zostaje interlock kooperacyjny (dźwignia/płyta ↔ brama)

### 3.3 Poziomy — Niebo (16 węzłów w grafie)
- [ ] Dedykowany tileset Nieba — brak; sceny używają assetów proceduralnych i `Mossy`
- [x] Unikalne przeszkody Nieba — `LightZone` (święte światło zabija tylko Kostuchę)
- [~] Zagadki słowne — treści w `PUZZLES.md`, ale panele wycofane ze scen
- [ ] Boss Nieba — OQ-06 odłożone
- [x] Implementacja: **4 z 16** (Heaven 01–04)

### 3.4 Poziomy — Piekło (15 węzłów w grafie)
- [ ] Dedykowany tileset Piekła — brak
- [x] Unikalne przeszkody Piekła — lawa (`FireZone`, śmiertelna dla Strażniczki)
- [~] Zagadki matematyczne — treści w `PUZZLES.md`, panele wycofane ze scen
- [ ] Boss Piekła — OQ-06 odłożone
- [x] Implementacja: **4 z 15** (Hell 01–04)

### 3.5 Sklep
**Nierozpoczęty** — w repo nie ma ani sceny, ani skryptu sklepu.
- [ ] Ekran sklepu (dostępny między poziomami)
- [ ] Zakup szybkości (3 poziomy)
- [ ] Zakup wyskoku (3 poziomy)
- [ ] Zakup 3. zdolności (po podjęciu decyzji OQ-07)
- [ ] Trwałe zapisanie zakupów
- [ ] **Decyzja blokująca:** czym się płaci, skoro monety są wymogiem ukończenia poziomu

### 3.6 System zapisu i wczytywania
- [x] Zapis stanu gry lokalnie — `SaveManager`, `user://save_data.json` + Pair ID (UUID v4)
- [ ] Synchronizacja zapisu między urządzeniami — ani `NetworkManager`, ani `Lobby`
  nie wymieniają danych zapisu
- [~] Ekran wznowienia gry — osobnego ekranu nie ma; postęp wczytuje się sam przy starcie
  (`LevelManager._ready` → `SaveManager.load_progress`), a „Start" prowadzi wprost na mapę

**Milestone:** Wszystkie strefy grywalne ✅ (14 poziomów), sklep ⬜, save/load lokalnie ✅

---

## Faza 4 — Grafika i Audio (równolegle z Fazą 3)
**Cel:** Finalna oprawa wizualna i dźwiękowa

> **Pipeline assetów (ustalony w branchach 023–027):** użytkownik rysuje ręcznie
> arkusz (skan / zdjęcie do `assets/sprites/*_src.png`), a skrypt w `game/tools/`
> wycina z niego, czyści i normalizuje gotowe sprite'y (`slice_doors.gd`,
> `slice_button.gd`, `slice_seesaw.gd`, `slice_terrain.gd`). Assety proceduralne
> z `generate_assets.gd` są tymczasowe i wypierane kolejnymi rysunkami.

### 4.1 Grafika
- [ ] Finalne sprite'y: Kostucha (chodzenie, skok, stanie, śmierć) — nadal proceduralne
- [ ] Finalne sprite'y: Strażniczka — nadal proceduralne
- [~] Tileset: Ziemia — `earth_terrain.tres` z ręcznego arkusza gotowy (`027`),
  ale jeszcze nieużyty w żadnej scenie
- [ ] Tileset: Niebo (finalna wersja)
- [ ] Tileset: Piekło (finalna wersja)
- [x] Ikony HUD — czaszki i serca z rysunków użytkownika (`assets/collectibles/`)
- [x] Ekran tytułowy / menu (`MainMenu.tscn`)
- [x] Ekran mapy poziomów (`LevelSelect.tscn` na `bg1.png` 3072×2048)
- [x] Przeszkody z ręcznych rysunków: drzwi, dźwignia, przycisk płyty, huśtawka

### 4.2 Animacje
- [x] Animacje postaci — `idle` / `walk` / `jump` (klatki proceduralne, nie Aseprite);
  brak animacji śmierci
- [~] Animacje środowiska — animowane są przeszkody (brama drzwi na shaderze,
  obrót dźwigni i huśtawki), nie ogień/woda/chmury
- [ ] Efekty cząsteczkowe (śmierć, zbieranie monet) — w projekcie nie ma
  ani jednego węzła `Particles2D`

### 4.3 Audio
- [ ] Muzyka tła per strefa (Ziemia, Niebo, Piekło) — `assets/audio/music/` jest puste
- [~] SFX: są 4 (dźwignia/płyta, brama, ukończenie poziomu, wybór w menu);
  brakuje skoku, zbierania monety, śmierci, odbicia, kruszenia platform
- [x] Opcja wyciszenia — `SettingsMenu` przełącza busy `SFX` i `Music`

---

## Faza 5 — Polish i Testy (1 miesiąc)
**Cel:** Gotowy produkt do publikacji

### 5.1 Balansowanie
- [ ] Testowanie trudności każdego poziomu z realnymi graczami
- [ ] Dostosowanie liczby monet, zagadek, pułapek
- [ ] Balans sklepu (czy ulepszenia są zbyt silne?)

### 5.2 UI / UX
- [x] Ekran ustawień — `SettingsMenu.tscn` (język PL/EN, dźwięk, muzyka);
  sterowania nie da się przemapować
- [~] Tutorial — zamiast poziomu 0 są kontekstowe lekcje `TutorialManager`,
  **wyłączone flagą `enabled = false`** od brancha `023`
- [~] Ekrany — „Game Over" jako `DeathScreen.tscn`, „Level Complete" jako baner
  3-sekundowy; ekranu „All Done!" po ostatnim poziomie nie ma
- [ ] Animacje przejść między ekranami — zmiany scen to gołe `change_scene_to_file`;
  tweeny są tylko wewnątrz ekranów (fade banera, pulsowanie bąbelka na mapie)

### 5.3 Testy
- [x] Testy automatyczne — 133 testy GUT w 27 skryptach, wszystkie przechodzą
  (`run_tests.ps1`, CI `.github/workflows/tests.yml`)
- [ ] Testy na różnych urządzeniach Android (minimum 3 różne)
- [ ] Testy na iOS (jeśli na tym etapie)
- [ ] Test offline / tryb lotniczy (kilkugodzinna sesja)
- [ ] Test wydajności (FPS minimum 60 na mid-range Android)

### 5.4 Publikacja
- [ ] Konto Google Play Developer ($25 jednorazowo)
- [ ] Ikona aplikacji (512x512)
- [ ] Screenshots i grafika store
- [ ] Opis gry (EN + PL)
- [ ] Privacy Policy (wymagana przez Google Play)
- [ ] Budowanie .apk / .aab (Android App Bundle)
- [ ] Submission do Google Play

---

## Faza 6 — iOS Port (opcjonalnie, po Androidzie)
- [ ] Konfiguracja Xcode
- [ ] Konto Apple Developer ($99/rok)
- [ ] Dostosowanie sterowania dla iOS
- [ ] Testy na iPhone/iPad
- [ ] Submission do App Store

---

## Szacowany Harmonogram (orientacyjny)

| Faza | Czas | Kiedy |
|------|------|-------|
| 0 — Decyzje | 1–2 tygodnie | Teraz |
| 1 — Prototyp | 2–4 tygodnie | Po fazie 0 |
| 2 — Core | 4–8 tygodni | Po fazie 1 |
| 3 — Treść | 8–12 tygodni | Po fazie 2 |
| 4 — Grafika/Audio | Równolegle z 3 | — |
| 5 — Polish | 4 tygodnie | Po fazie 3+4 |
| 6 — iOS | 2–4 tygodnie | Po fazie 5 |

> ⚠️ Harmonogram jest orientacyjny i zależy od dostępnego czasu oraz liczby zaangażowanych osób.

---

## Struktura Katalogów Projektu (stan faktyczny)

```
life-death\
├── docs\
│   ├── GAME_DESIGN.md            ← Główny dokument projektu
│   ├── OPEN_QUESTIONS.md         ← Kwestie do rozstrzygnięcia
│   ├── ROADMAP.md                ← Ten plik
│   ├── LEVEL_BUILDING.md         ← Instrukcja budowania poziomów w edytorze
│   ├── PUZZLES.md                ← Baza zagadek (panele wycofane z gry)
│   ├── terrain_tiles_reference.png
│   └── LEVEL_DESIGN\
│       └── heaven_01.md          ← jedyny opis poziomu (z 14 istniejących)
├── art\                          ← Referencje i skany rysunków (poza projektem Godota)
├── game\                         ← Projekt Godot 4.6
│   ├── assets\  (audio, background, collectibles, gen, sprites, tilesets)
│   ├── i18n\    (translations.csv → PL/EN)
│   ├── scenes\  (characters, levels\earth|heaven|hell, obstacles, ui)
│   ├── scripts\ (characters, levels, obstacles, systems, ui)
│   ├── shaders\, tests\ (unit + integration), tools\ (slicery assetów)
│   └── addons\gut\
└── run_tests.ps1                 ← Headless GUT runner (CI: .github/workflows/tests.yml)
```
