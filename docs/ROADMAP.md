# Life & Death — Roadmap i Plan Realizacji

> **WAŻNE:** Żadna implementacja nie jest uruchamiana dopóki nie zostaną zamknięte kwestie blokujące (🔴) z OPEN_QUESTIONS.md  
> Ten dokument będzie aktualizowany po każdej sesji planowania.

---

## Faza 0 — Decyzje Architektoniczne (TERAZ)
**Cel:** Zamknąć wszystkie blokujące pytania zanim napisze się choć linię kodu.

### 0.1 Decyzje do podjęcia (kolejność ważności)
- [ ] **OQ-02** — Wybór silnika / stosu technologicznego
- [ ] **OQ-01** — Protokół komunikacji offline (Bluetooth / WiFi Direct)
- [ ] **OQ-04** — Mechanika śmierci i respawnu
- [ ] **OQ-09** — System synchronizacji zapisu
- [ ] **OQ-11** — Widok kamery (wspólny vs osobny per gracz)

### 0.2 Deliverables fazy 0
- [ ] Uzupełniony `OPEN_QUESTIONS.md` (zamknięte kwestie 🔴)
- [ ] Decyzja o stosie tech zapisana w `TECH_STACK.md`
- [ ] Szkic mapy poziomów (nawet ołówkiem/zdjęcie)
- [ ] Lista 15+ zagadek do puli

---

## Faza 1 — Prototyp Proof of Concept
**Cel:** Minimalny działający prototyp z core mechaniką (2 tygodnie–1 miesiąc)

### 1.1 Setup projektu
- [ ] Instalacja wybranego silnika
- [ ] Konfiguracja projektu (Android target)
- [ ] Repozytorium git (GitHub/GitLab)
- [ ] Podstawowa struktura katalogów projektu

### 1.2 Mechanika podstawowa (jeden gracz, jeden poziom testowy)
- [ ] Gracz może się poruszać (lewo/prawo)
- [ ] Gracz może skakać
- [ ] Kolizje z podłogą i ścianami
- [ ] Prosta kamera śledząca gracza
- [ ] Sterowanie dotykowe (wirtualny D-pad)

### 1.3 Mechanika 2 graczy (offline)
- [ ] Implementacja połączenia Bluetooth/WiFi Direct
- [ ] Synchronizacja pozycji obu graczy w czasie rzeczywistym
- [ ] Test latencji — czy gra jest "grywalna" z tym opóźnieniem?
- [ ] Screen: Gracz 1 widzi Gracza 2, Gracz 2 widzi Gracza 1

### 1.4 Testowanie kluczowe
- [ ] Test na 2 fizycznych telefonach Android
- [ ] Zmierzone opóźnienie (cel: < 100ms)
- [ ] Test w trybie lotniczym (WiFi/komórkowe OFF, tylko Bluetooth)

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
