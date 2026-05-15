# Life & Death — Game Design Document (GDD)

> **Status:** Draft v0.2 — iteracyjne uzupełnianie  
> **Ostatnia aktualizacja:** 2026-05-15  
> **Język dokumentu:** Polski (treści w grze: Angielski + Polski do wyboru)

---

## 1. Przegląd Projektu

| Pole | Wartość |
|------|---------|
| Tytuł roboczy | **Life & Death** |
| Gatunek | 2D Platformer / Kooperacyjna układanka |
| Platformy | Android (priorytet), iOS |
| Tryb gry | 2 graczy — lokalny offline (WiFi Direct + Bluetooth fallback) |
| Silnik | **Godot 4** (GDScript) |
| Monetyzacja | Darmowa + reklamy; opcja bez reklam za 20 zł |
| Inspiracja | Fireboy and Watergirl, It Takes Two |
| Styl graficzny | 2D Pixel Art |
| Języki | Angielski (domyślny), Polski |

---

## 2. Koncepcja i Fabuła

### 2.1 Motyw przewodni
Gra opiera się na odwiecznym kontraście: **Życia i Śmierci**. Dwoje graczy wcielają się w postacie, które pozornie są swoimi przeciwieństwami — jednak tylko razem mogą pokonać każdy poziom. Bez współpracy żadna ze stron nie może wygrać.

### 2.2 Postacie

#### Kostucha (Grim Reaper) — Gracz 1
- Symbol śmierci, mroku i przemijalności
- Kolory: czarne, szare, fioletowe, ciemnoczerwone
- Zbiera: **Czaszki** (waluta)
- Ikonografika: kosa, kości, cień, dym

#### Strażniczka Życia (Guardian of Life) — Gracz 2
- Symbol życia, natury i odrodzenia
- Kolory: białe, złote, zielone, błękitne
- Zbiera: **Aureole / Serca** (waluta)
- Ikonografika: skrzydła, kwiaty, światło, rosa

---

## 3. Mechaniki Postaci

### 3.1 Zdolności wspólne (obaj gracze)
- Chodzenie, bieganie
- Skakanie (pojedyncze, ewentualnie podwójne — do ustalenia)
- Zbieranie monet (własna waluta)
- Interakcja z obiektami (dźwignie, przyciski, drzwi)

### 3.2 Zdolności unikalne — Kostucha
| Zdolność | Opis |
|----------|------|
| Odporność na ogień / lawę | Może chodzić po ławie i przez ogień bez obrażeń |
| Widoczność w mroku | W ciemnych strefach widzi normalnie |
| Podatność | Kwiaty / natura (spowalniają), chmury (śmiertelną przepaść) |

### 3.4 Zdolności unikalne — Strażniczka Życia
| Zdolność | Opis |
|----------|------|
| Chodzenie po chmurach | Może stąpać po chmurach jak po ziemi |
| Bezpieczna w kwiatach / naturze | Kwiaty i rośliny jej nie spowalniają |
| Podatność | Ogień / lawa (śmiertelne), ciemne strefy (brak widoczności = śmierć) |

### 3.5 Przeszkody wspólne (niebezpieczne dla obu)
| Przeszkoda | Opis mechaniki |
|-----------|----------------|
| Zamknięta brama / drzwi | Jeden gracz ciągnie dźwignię, drugi przechodzi |
| Ruchome kolce | Śmiertelne dla obu, wymagają synchronizacji |
| Spadające platformy | Uruchamiają się po wejściu — oboje muszą zdążyć |

> 📄 Pełna lista rozwijana w OPEN_QUESTIONS.md #OQ-03

---

## 4. Mapa Poziomów — Drzewo Świata

### 4.1 Struktura Świata

Mapa poziomów podzielona jest na **3 strefy**, ułożone pionowo:

```
        ☁️  NIEBO (Heaven)     ← Kostucha ma trudniej
       /
🌍 ZIEMIA (Earth)              ← Równa trudność dla obu
       \
        🔥 PIEKŁO (Hell)       ← Strażniczka ma trudniej
```

### 4.2 Progresja

- Gracze zaczynają w strefie **Ziemi**
- Po ukończeniu poziomów Ziemi odblokowują się ścieżki do **Nieba** i **Piekła**
- Wybór ścieżki: decyzja obu graczy przed rozgrywką
- **Ukończenie gry wymaga pokonania WSZYSTKICH poziomów** we wszystkich strefach
- Drzewo poziomów: nieliniowe — można wybierać kolejność w ramach strefy, ale strefy mają zależności

### 4.3 System Drzewa Poziomów (przykład)
```
ZIEMIA: L1 → L2 → L3 → [rozwidlenie]
                              ├── NIEBO: N1 → N2 → N3 → BOSS_NIEBO
                              └── PIEKŁO: P1 → P2 → P3 → BOSS_PIEKŁO
```

### 4.3 Liczba poziomów
- **Ziemia:** 20 poziomów (trudność równa dla obu postaci)
- **Niebo:** 20 poziomów (trudniejsze dla Kostuchy)
- **Piekło:** 20 poziomów (trudniejsze dla Strażniczki)
- **Łącznie: 60 poziomów**

### 4.4 Poziomy Klucza (wymagane do ukończenia gry)
Specjalne poziomy, w których **oboje gracze muszą zebrać klucze**:
- Klucz Nieba: zbiera Strażniczka (Aureola-klucz) → otwiera Bramę Nieba
- Klucz Piekła: zbiera Kostucha (Czaszka-klucz) → otwiera Bramę Piekła
- Oboje muszą być przy odpowiedniej bramie jednocześnie, żeby ją otworzyć

---

## 5. System Monet i Sklepu

### 5.1 Waluty
| Waluta | Postać | Ikona |
|--------|--------|-------|
| Czaszki | Kostucha | 💀 |
| Aureole / Serca | Strażniczka | 👼 / ❤️ |

- Każdy gracz zbiera swoją walutę niezależnie
- Monety pojawiają się na planszy, często w trudno dostępnych miejscach
- Waluta każdego gracza jest osobna — nie ma wymiany

### 5.2 Sklep (Shop)
Dostępny między poziomami. Ulepszenia są **nieznacznie** wpływające na rozgrywkę (pay-to-comfort, nie pay-to-win):

| Ulepszenie | Opis | Poziomy |
|-----------|------|---------|
| Szybkość | Zwiększa prędkość poruszania | 1–3 |
| Wyskok | Wyższy / dalszy skok | 1–3 |
| Czasowa nieśmiertelność | 10 sekund odporności na śmiertelne przeszkody (nawet te specyficzne dla postaci); raz na poziom | 1–3 |

---

## 6. Pułapki i Przeszkody

### 6.1 Pułapki wspólne (niebezpieczne dla obu)
- Ruchome kolce
- Spadające platformy
- Wiatr / prąd powietrza przesuwający postacie
- Strefy czasowe (np. podłoga, która zapada się po 3 sekundach)

### 6.2 Pułapki specyficzne
| Przeszkoda | Niebezpieczna dla |
|-----------|------------------|
| Ogień / Lawa | Strażniczka Życia |
| Woda święcona / Jasne wiązki światła | Kostucha |
| Ciemne strefy (brak widoczności) | Strażniczka |
| Zatruty grunt | Kostucha (?) |

### 6.3 Zagadki
Zagadki blokują przejście do następnego obszaru. **Nie występują w początkowych poziomach** — wprowadzane stopniowo. Nie każdy poziom je zawiera.

**Mechanika:**
- Format: **4 opcje do wyboru** (A/B/C/D) — kliknięcie odpowiedzi
- **Limit czasu: 5–10 sekund** — po upływie brama zamyka się bezpowrotnie (konieczny reset poziomu)
- Dostępne w języku **EN i PL** (zależnie od ustawionego języka)

#### Typ A — Zagadki słowne (riddles)
- Przykład: *"What lives when fed, dies when given drink?"* → A) Water B) **Fire** C) Air D) Earth
- Głównie w strefie Nieba

#### Typ B — Działania matematyczne
- Na drzwiach/tablicy pojawia się równanie — gracz wybiera wynik z 4 opcji
- Przykład: `6 × 7 = ?` → A) 36 B) 48 C) **42** D) 56
- Głównie w strefie Piekła

#### Typ C — Zagadki kooperacyjne
- Oboje gracze muszą stać na płytach / nacisnąć przyciski jednocześnie
- Jeden przytrzymuje dźwignię, drugi przechodzi przez otwarte drzwi
- Występują we wszystkich strefach

> 📄 Pełna baza zagadek: `docs/PUZZLES.md` (do stworzenia)

---

## 7. Tryb Multiplayer — Offline

### 7.1 Wymagania
- Brak połączenia z internetem (lot samolotem, brak zasięgu)
- Oboje gracze na swoich telefonach
- Minimalne opóźnienie

### 7.2 Architektura
| Platforma | Technologia |
|-----------|-------------|
| Android | WiFi Direct (Wi-Fi P2P API) + Bluetooth fallback |
| iOS | Multipeer Connectivity Framework (WiFi Direct / BT / lokalny WiFi) |

**Działa w trybie lotniczym:** Bluetooth w trybie lotniczym jest aktywny — oboje mogą grać na pokładzie samolotu.

### 7.3 Flow połączenia (wstępny)
1. Jeden gracz wybiera "Hostuj grę" → generuje kod/QR
2. Drugi gracz wybiera "Dołącz do gry" → skanuje kod lub wpisuje ręcznie
3. Oboje widzą ekran oczekiwania → "Gotowy?" → Start

---

## 8. Zapis Progresu

### 8.1 Wymagania
- Możliwość zapisania stanu gry i powrotu po czasie
- Oboje gracze muszą mieć możliwość wznowienia tej samej sesji
- Działanie offline

### 8.2 System Pair ID
- Przy pierwszym połączeniu dwóch urządzeń generowany jest unikalny **Pair ID** (UUID)
- Pair ID zapisywany na obu telefonach lokalnie
- Zapis przypisany do Pair ID — para A+B ma swój zapis, A+C zaczyna od nowa
- Host przechowuje dane zapisu, synchronizuje z gościem przy połączeniu

**Co jest zapisywane:** ukończone poziomy, monety, zakupy w sklepie, bieżący poziom

> 📄 Szczegóły techniczne: OPEN_QUESTIONS.md #OQ-09

---

## 9. Grafika i Styl Wizualny

### 9.1 Styl
- **2D Pixel Art** — klasyczny styl retro
- Rozdzielczość pikseli: 16x16 lub 32x32 per kafelek (do ustalenia)
- Paleta kolorów: kontrast między strefami (Ziemia = zielono-brązowa, Niebo = biało-złota, Piekło = czerwono-czarna)

### 9.2 Narzędzia do tworzenia grafiki
#### Dedykowane edytory Pixel Art
| Narzędzie | Cena | Opis |
|-----------|------|------|
| **Aseprite** | ~$20 | Najlepszy edytor pixel art, animacje, tilesety |
| **Libresprite** | Free | Fork Aseprite (open source) |
| **Piskel** | Free | Online, prosto w przeglądarce |
| **GraphicsGale** | Free | Windows, świetny dla animacji |

#### AI do generowania grafiki 2D / Pixel Art
| Narzędzie | Opis |
|-----------|------|
| **Midjourney** | Generowanie grafik prompt-based, można wyspecyfikować "pixel art style 16-bit" |
| **DALL-E 3** | Wbudowany w ChatGPT, łatwy w użyciu, dobry dla konceptów |
| **Stable Diffusion** (+ LoRA pixel art) | Open source, darmowy, modele wyspecjalizowane w pixel art |
| **Adobe Firefly** | Wbudowany w Adobe, dobry dla spójnych stylów |
| **Leonardo.ai** | Darmowe kredyty, dobre dla game assets |
| **Itch.io asset packs** | Gotowe darmowe/płatne zestawy pixel art do gier |

> 💡 **Sugerowany workflow:** Generuj koncepty przez Midjourney/DALL-E → dopracuj w Aseprite → zanimuj manualnie lub przez DragonBones/Spine

---

## 10. Stos Technologiczny (propozycje)

> ⚠️ **Decyzja kluczowa:** patrz OQ-02

### Opcja A — Unity (C#)
- Najlepsze wsparcie dla gier mobilnych 2D
- Ogromna społeczność i zasoby
- Gotowe pluginy do Bluetooth
- Bezpłatny (personal), płatny (powyżej $200k przychodu)

### Opcja B — Godot 4 (GDScript / C#)
- Całkowicie darmowy, open source
- Świetny dla 2D pixel art
- Mniejsza społeczność niż Unity, ale rośnie dynamicznie
- Bluetooth wymaga pluginu lub własnej implementacji

### Opcja C — Flutter + Flame
- Flutter = cross-platform mobile
- Flame = lekki silnik 2D na bazie Fluttera
- Bluetooth: flutter_blue lub flutter_nearby_connections
- Dobry dla małych-średnich gier 2D

---

## 11. Monetyzacja

| Model | Szczegóły |
|-------|----------|
| Cena bazowa | **Darmowa** |
| Reklamy | Po ukończeniu każdego poziomu LUB po każdej śmierci (Google AdMob / App Store Ads) |
| Zakup premium | **20 zł** jednorazowo — usuwa wszystkie reklamy na stałe |
| Sklep in-game | Monety zdobywane wyłącznie grą, brak mikropłatności |

---

## 12. Referencje i Inspiracje

| Tytuł | Co zapożyczyć |
|-------|--------------|
| **Fireboy and Watergirl** | Mechanika kooperacji, strefy charakteru, klucze/drzwi |
| **It Takes Two** | Głęboka kooperacja, unikalne mechniki per poziom |
| **Portal 2 Co-op** | Zagadki wymagające synchronizacji |
| **Hollow Knight** | Klimat pixel art, mapa poziomów |
| **Cuphead** | Estetyka, trudność poziomów |
