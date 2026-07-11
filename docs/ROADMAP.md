# Life & Death — Roadmap i Plan Realizacji

> Ten dokument jest aktualizowany po każdej sesji. Status: ✅ Zrobione | 🔄 W toku | ⬜ Do zrobienia

---

## STATUS PROJEKTU — 2026-07-10

| Faza | Status | Opis |
|------|--------|------|
| Faza 0 — Decyzje | ✅ Zakończona | Wszystkie OQ zamknięte |
| Faza 1 — Setup / Prototyp | ✅ Zakończona | Ruch, 2 graczy, śmierć/reset, multiplayer LAN |
| Faza 2 — Core Gameplay | 🔄 W toku | Umiejętności (warstwy kolizji), przeszkody, zapis — działają na Ziemi |
| Faza 3 — Treść i poziomy | 🔄 W toku | Ziemia 01–06; Niebo/Piekło jeszcze puste; sklep do zrobienia |
| Faza 4 — Grafika/Audio | ⬜ Nie rozpoczęta | Audio pipeline pusty |
| Faza 5 — Polish i testy | 🔄 Częściowo | GUT unit + integracja, CI (GitHub Actions) |
| Faza 6 — iOS Port | ⬜ Nie rozpoczęta | — |

### Ostatnio zrobione (przez branche PR 001–012)
- ✅ `001`–`005` — setup, ruch gracza, drugi gracz (Guardian), śmierć/reset, sprite'y
- ✅ `006-character-abilities` — umiejętności przez warstwy/maski kolizji (FireZone, CloudPlatform)
- ✅ `007` — multiplayer LAN: ENet (port 7777) + auto-discovery UDP (7778), `NetworkManager`
- ✅ `008-level-system` — `LevelManager`, rejestr 60 poziomów (earth/heaven/hell × 20)
- ✅ `009-save-system` — `SaveManager`, zapis JSON + Pair ID (UUID v4)
- ✅ `010`–`011` — poprawki Earth-01, poziomy Earth 02–06
- ✅ `012-obstacles` — ExitPortal, Door, Lever, PuzzlePanel, Seesaw + wspólna baza `DoorTrigger`
  - Przeszkody otwierające drzwi synchronizowane po sieci (server-authoritative)
  - Seesaw: model torque z ograniczeniem kąta (±25°)
  - Testy jednostkowe wszystkich przeszkód + pierwsze testy integracyjne
- ✅ **CI**: `.github/workflows/tests.yml` uruchamia GUT headless; runner `run_tests.ps1`

### Do zrobienia — następne kroki
- ⬜ Poziomy Niebo/Piekło (katalogi `scenes/levels/{heaven,hell}` puste)
- ⬜ Baza zagadek — patrz `docs/PUZZLES.md` (szkielet utworzony)
- ⬜ Mechanika limitu czasu bramek/portali (OQ, `OPEN_QUESTIONS.md`)
- ⬜ Sklep (ulepszenia: szybkość / wyskok / 10s nietykalności) + HUD monet
- ⬜ Ekran ustawień (`MainMenu.gd:24` — TODO)

---

> **WAŻNE:** Żadna implementacja nie jest uruchamiana dopóki nie zostaną zamknięte kwestie blokujące (🔴) z OPEN_QUESTIONS.md  
> Ten dokument będzie aktualizowany po każdej sesji planowania.

---

## Faza 0 — Decyzje Architektoniczne
**Status: ✅ ZAKOŃCZONA**

### 0.1 Decyzje podjęte
- [x] **OQ-02** — Silnik: **Godot 4** (GDScript)
- [x] **OQ-01** — Protokół: WiFi Direct + Bluetooth fallback
- [x] **OQ-04** — Śmierć: freeze + reset poziomu, bez limitu żyć
- [x] **OQ-09** — Zapis: system Pair ID
- [x] **OQ-11** — Kamera per gracz (~50% mapy)
- [x] OQ-03, 05, 06, 07, 08, 10, 12, 13, 14, 15 — patrz OPEN_QUESTIONS.md

### 0.2 Deliverables
- [x] `OPEN_QUESTIONS.md` — wszystkie kwestie zamknięte
- [x] Decyzje tech zapisane w GDD i OQ
- [ ] Szkic mapy poziomów (drzewo) — do zrobienia
- [ ] Baza zagadek (`docs/PUZZLES.md`) — do zrobienia

---

## Faza 1 — Prototyp Proof of Concept
**Status: 🔄 W TOKU** (PR #1 otwarty)

### 1.1 Setup projektu
- [x] Instalacja Godot 4.6.2
- [x] Konfiguracja projektu (360×640, GL Compatibility, GDScript)
- [x] Repozytorium git + GitHub
- [x] Struktura katalogów projektu
- [x] GUT v9.6.0 (testy jednostkowe)
- [x] Scena `MainMenu.tscn` + testy
- [ ] **Merge PR #1** do `master`

### 1.2 Mechanika podstawowa (jeden gracz, jeden poziom testowy)
- [ ] Gracz może się poruszać (lewo/prawo)
- [ ] Gracz może skakać
- [ ] Kolizje z podłogą i ścianami
- [ ] Prosta kamera śledząca gracza
- [ ] Sterowanie dotykowe (wirtualny D-pad)

### 1.3 Mechanika 2 graczy (offline)
- [ ] Implementacja połączenia WiFi Direct / Bluetooth
- [ ] Synchronizacja pozycji obu graczy w czasie rzeczywistym
- [ ] Test latencji — cel: < 100ms
- [ ] Gracz 1 widzi Gracza 2 na swoim ekranie i odwrotnie

### 1.4 Testowanie kluczowe
- [ ] Test na 2 fizycznych telefonach Android
- [ ] Test w trybie lotniczym (WiFi/komórkowe OFF)

**Milestone:** Dwóch graczy chodzi po platformie w tym samym czasie offline ✅

---

## Faza 2 — Core Gameplay
**Cel:** Kompletna mechanika postaci i jeden grywalny poziom (1–2 miesiące)

### 2.1 Postać — Kostucha
- [ ] Sprite placeholder (możemy użyć prostej ikony na start)
- [ ] Odporność na ogień/lawę
- [ ] Interakcja z "Mroczną Strefą"
- [ ] Animacja chodzenia, skakania, stania

### 2.2 Postać — Strażniczka Życia
- [ ] Sprite placeholder
- [ ] Chodzenie po chmurach
- [ ] Odporność na wodę
- [ ] Animacja chodzenia, skakania, stania

### 2.3 Środowisko — Poziom Testowy (Ziemia)
- [ ] Tileset: platformy, podłoga, tło
- [ ] Elementy ognia (śmiertelne dla Strażniczki)
- [ ] Chmury (dostępne tylko dla Strażniczki)
- [ ] Klucz do zebrania per postać
- [ ] Drzwi wymagające obu kluczy
- [ ] Checkpoint (punkt zapisu postępu)
- [ ] Cel (koniec poziomu)

### 2.4 System monet
- [ ] Czaszki rozlokowane na poziomie (dla Kostuchy)
- [ ] Aureole rozlokowane na poziomie (dla Strażniczki)
- [ ] Licznik monet na HUD

### 2.5 Zagadka (jeden typ)
- [ ] Wyświetlenie pytania w grze
- [ ] Klawiatura wirtualna do wpisania odpowiedzi
- [ ] Walidacja odpowiedzi → otwiera drzwi / usuwa blokadę

**Milestone:** Jeden kompletny poziom — od startu do mety, z kluczami i jedną zagadką ✅

---

## Faza 3 — Treść i Poziomy
**Cel:** Wszystkie poziomy, mapa świata, sklep (2–3 miesiące)

### 3.1 Mapa Świata
- [ ] Ekran drzewa poziomów (Ziemia / Niebo / Piekło)
- [ ] Wizualizacja odblokowanych i zablokowanych poziomów
- [ ] Wybór kolejnego poziomu przez oboje graczy (decyzja wspólna)

### 3.2 Poziomy — Ziemia (5-7 sztuk)
- [ ] Zaprojektowanie layoutów (na papierze najpierw)
- [ ] Implementacja per poziom
- [ ] Wzrastająca trudność
- [ ] Mix zagadek: kooperacyjne + matematyczne + środowiskowe

### 3.3 Poziomy — Niebo (5 + boss)
- [ ] Tileset: chmury, złote platformy, białe tła
- [ ] Unikalne przeszkody Nieba (trudniejsze dla Kostuchy)
- [ ] Zagadki słowne (filozoficzne)
- [ ] Boss Nieba

### 3.4 Poziomy — Piekło (5 + boss)
- [ ] Tileset: skały, lawa, ogień, ciemność
- [ ] Unikalne przeszkody Piekła (trudniejsze dla Strażniczki)
- [ ] Zagadki matematyczne
- [ ] Boss Piekła

### 3.5 Sklep
- [ ] Ekran sklepu (dostępny między poziomami)
- [ ] Zakup szybkości (3 poziomy)
- [ ] Zakup wyskoku (3 poziomy)
- [ ] Zakup 3. zdolności (po podjęciu decyzji OQ-07)
- [ ] Trwałe zapisanie zakupów

### 3.6 System zapisu i wczytywania
- [ ] Zapis stanu gry lokalnie
- [ ] Synchronizacja zapisu między urządzeniami przy połączeniu
- [ ] Ekran wznowienia gry

**Milestone:** Wszystkie strefy grywalne, sklep działa, save/load działa ✅

---

## Faza 4 — Grafika i Audio (równolegle z Fazą 3)
**Cel:** Finalna oprawa wizualna i dźwiękowa

### 4.1 Grafika
- [ ] Finalne sprite'y: Kostucha (chodzenie, skok, stanie, śmierć)
- [ ] Finalne sprite'y: Strażniczka (chodzenie, skok, stanie, śmierć)
- [ ] Tileset: Ziemia (finalna wersja)
- [ ] Tileset: Niebo (finalna wersja)
- [ ] Tileset: Piekło (finalna wersja)
- [ ] Ikony HUD (czaszki, aureole, życia)
- [ ] Ekran tytułowy
- [ ] Ekran menu
- [ ] Ekran mapy poziomów

### 4.2 Animacje
- [ ] Animacje postaci (klatka po klatce w Aseprite)
- [ ] Animacje środowiska (ogień, woda, chmury)
- [ ] Efekty cząsteczkowe (śmierć, zbieranie monet)

### 4.3 Audio
- [ ] Muzyka tła per strefa (Ziemia, Niebo, Piekło) — 3 tracki
- [ ] SFX: skok, zbieranie monety, śmierć, otwieranie drzwi, zagadka rozwiązana
- [ ] Opcja wyciszenia (settings)

---

## Faza 5 — Polish i Testy (1 miesiąc)
**Cel:** Gotowy produkt do publikacji

### 5.1 Balansowanie
- [ ] Testowanie trudności każdego poziomu z realnymi graczami
- [ ] Dostosowanie liczby monet, zagadek, pułapek
- [ ] Balans sklepu (czy ulepszenia są zbyt silne?)

### 5.2 UI / UX
- [ ] Ekran ustawień (język, dźwięk, sterowanie)
- [ ] Tutorial (poziom 0 / instrukcja)
- [ ] Ekrany "Game Over", "Level Complete", "All Done!"
- [ ] Animacje przejść między ekranami

### 5.3 Testy
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

## Struktura Katalogów Projektu (docelowa)

```
C:\Apps\Life_Death\
├── docs\
│   ├── GAME_DESIGN.md       ← Główny dokument projektu
│   ├── OPEN_QUESTIONS.md    ← Kwestie do rozstrzygnięcia
│   ├── ROADMAP.md           ← Ten plik
│   ├── TECH_STACK.md        ← (do stworzenia po decyzji OQ-02)
│   ├── LEVEL_DESIGN\        ← Szkice i opisy per poziom
│   │   ├── earth_01.md
│   │   ├── heaven_01.md
│   │   └── hell_01.md
│   └── PUZZLES.md           ← Baza zagadek
├── game\                    ← (do stworzenia) Kod gry
│   └── [projekt Unity/Godot/Flutter]
└── assets\                  ← (do stworzenia) Grafika, audio
    ├── sprites\
    ├── tilesets\
    └── audio\
```
