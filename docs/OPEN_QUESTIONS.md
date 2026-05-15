# Life & Death — Otwarte Pytania i Kwestie do Rozstrzygnięcia

> Każda kwestia ma priorytet: 🔴 Blokujący | 🟡 Ważny | 🟢 Może poczekać  
> Status: ❓ Otwarte | 🔄 W toku | ✅ Zamknięte

---

## TECHNOLOGIA

### OQ-01 ✅ Protokół komunikacji offline (Bluetooth vs WiFi Direct)
**Decyzja:** WiFi Direct (priorytet) + Bluetooth jako fallback.

**Implementacja per platforma:**
| Platforma | Technologia |
|-----------|-------------|
| Android | WiFi Direct (Wi-Fi P2P) — natywne API |
| iOS | Multipeer Connectivity Framework — Apple's odpowiednik, automatycznie używa WiFi Direct / Bluetooth / lokalnego WiFi zależnie od dostępności |

> ⚠️ **Uwaga iOS:** Nie ma bezpośredniego WiFi Direct API na iOS — Multipeer Connectivity działa offline i jest dostępne w trybie lotniczym (używa Bluetooth gdy WiFi niedostępne). Działa między dwoma iPhone'ami bez internetu. ✅

**Status:** ✅ Zamknięte

---

### OQ-02 ✅ Silnik / Stos technologiczny
**Decyzja:** **Godot 4** (język: GDScript)

**Uzasadnienie wyboru dla osoby bez doświadczenia:**
- GDScript to język podobny do Pythona — czytelny, prosty, łatwy do nauki
- Godot jest darmowy i otwartoźródłowy (żadnych opłat licencyjnych)
- Natywne wsparcie dla 2D pixel art (wbudowany tilemap, animacje, kamera)
- Lżejszy edytor niż Unity — mniej przytłaczający na start
- Export do Android i iOS wbudowany w edytor
- Pluginy do WiFi Direct / Bluetooth (np. `godot-multiplayer-p2p`)

> ℹ️ Copilot będzie pomagać na każdym etapie — od instalacji Godot po pisanie każdej sceny.

**Status:** ✅ Zamknięte

---

### OQ-03 � Pełna lista przeszkód specyficznych dla postaci
**Aktualna lista (zatwierdzona):**
| Element | Kostucha | Strażniczka |
|---------|----------|-------------|
| Ogień / Lawa | ✅ Bezpieczne | ☠️ Śmiertelne |
| Chmury | ☠️ Przepada | ✅ Chodzi po nich |
| Ciemne strefy (mrok) | ✅ Bezpieczne | ☠️ Brak widoczności (śmiertelne) |
| Kwiaty / natura | ☠️ Spowalnia | ✅ Bezpieczne |

**Przeszkody wspólne (niebezpieczne dla obu):**
| Element | Opis |
|---------|------|
| Zamknięta brama / drzwi | Jeden gracz musi pociągnąć dźwignię, żeby drugi przeszedł |
| Ruchome kolce | Śmiertelne dla obu, wymagają synchronizacji |
| Spadające platformy | Uruchamiają się po wejściu — oboje muszą zdążyć |

**Propozycje do rozważenia (nie zatwierdzone):**
- Woda święcona / Blask — śmiertelne dla Kostuchy (element Nieba)
- Lód — spowalnia Strażniczkę (element Piekła?)
- Elektryczność — śmiertelna dla obu, ale Kostucha może ją zablokować?

**Status:** 🔄 W toku — lista bazowa zatwierdzona, do rozbudowania przy projektowaniu poziomów

---

### OQ-04 ✅ Mechanika śmierci i respawnu
**Decyzja:**
- Gdy jedna postać ginie → gra zatrzymuje się (freeze)
- Ekran: opcja **Reset poziomu** lub **Wyjdź do menu głównego**
- Brak systemu żyć — nieograniczona liczba prób
- Brak checkpointów wewnątrz poziomu — reset zawsze od początku poziomu

**Status:** ✅ Zamknięte

---

### OQ-05 ✅ Ile poziomów łącznie?
**Decyzja:** **60 poziomów** — po 20 na każdą strefę:
- Ziemia (Earth): 20 poziomów — równa trudność
- Niebo (Heaven): 20 poziomów — trudniejsze dla Kostuchy
- Piekło (Hell): 20 poziomów — trudniejsze dla Strażniczki

**Status:** ✅ Zamknięte

---

### OQ-06 � Walki z bossem (Boss Fight)
**Decyzja:** Brak bossów w obecnym planie — odkładamy do późniejszej decyzji.

> Można rozważyć specjalny "poziom finałowy" (nie boss fight, ale szczególnie wymagający poziom kooperacyjny) po ukończeniu wszystkich 60 poziomów — do decyzji w przyszłości.

**Status:** 🔄 Odłożone

---

### OQ-07 ✅ Trzecia zdolność w sklepie
**Decyzja:** **Czasowa nieśmiertelność (10 sekund)**
- Pozwala przejść przez przeszkodę normalnie śmiertelną dla danej postaci
- Przykład: Kostucha przez 10 sekund może chodzić po chmurach; Strażniczka przez ogień
- Używalne raz per poziom (po zakupie)
- Aktywowane przyciskiem — gracz decyduje kiedy użyć

**Status:** ✅ Zamknięte

---

## ROZGRYWKA

### OQ-08 ✅ Zagadki — zasady i mechanika
**Decyzja:**
- Zagadki **nie** pojawiają się w pierwszych poziomach — wprowadzane stopniowo od późniejszych etapów
- Rozmieszczenie losowe — nie każdy poziom ma zagadkę
- Format: **4 opcje do wyboru** (A/B/C/D) — gracz klika poprawną odpowiedź
- **Limit czasu: 5–10 sekund** — po upływie czasu brama/portal zamykają się bezpowrotnie (blokada do końca poziomu lub konieczność resetu)
- Każda zagadka ma wersję **EN i PL** (zależnie od wybranego języka)

**Typy zagadek per strefa:**
| Typ | Strefa | Opis |
|-----|--------|------|
| Słowne (riddles) | Niebo | Filozoficzne, duchowe, o życiu |
| Matematyczne | Piekło | Działania, logika, liczby |
| Kooperacyjne (obaj gracze) | Wszędzie | Oboje stoją na przyciskach, odpowiadają jednocześnie |

**Baza zagadek słownych (do rozbudowania w osobnym pliku):**
1. PL: "Co żyje gdy jesz, umiera gdy pijesz?" / EN: "What lives when fed, dies when given drink?" → Ogień / Fire
2. PL: "Im więcej oddajesz, tym więcej masz" / EN: "The more you give, the more you have" → Miłość / Love
3. PL: "Jestem zawsze przed tobą, nigdy za tobą" / EN: "Always in front of you, never behind" → Przyszłość / Future

> 📄 Pełna baza zagadek zostanie zapisana w `docs/PUZZLES.md`

**Status:** ✅ Zamknięte

---

### OQ-09 � System zapisu progresu — synchronizacja
**Wymaganie kluczowe:** Zapis jest przypisany do konkretnej **pary urządzeń** — A+B mają swój zapis, A+C zaczynają od nowa.

**Proponowane rozwiązanie — System Pair ID:**
1. Przy **pierwszym połączeniu** dwóch urządzeń → generowany jest unikalny **Pair ID** (UUID na podstawie ID obu urządzeń)
2. Pair ID zapisywany lokalnie na **obu** telefonach
3. Każdy slot zapisu jest powiązany z Pair ID
4. Przy kolejnym połączeniu: urządzenia wymieniają Pair ID
   - Zgodne → wczytanie wspólnego zapisu ✅
   - Niezgodne (inna para) → nowa gra, brak dostępu do cudzego zapisu ✅
5. Dane zapisu trzyma **host** (gracz który hostuje sesję), synchronizuje z gościem przy połączeniu

**Co jest zapisywane:**
- Ukończone poziomy (per strefa)
- Zebrane monety (osobno per gracz)
- Zakupione ulepszenia (osobno per gracz)
- Bieżący poziom (jeśli przerwano w trakcie)

**Status:** ✅ Zamknięte

---

### OQ-10 ✅ Model monetyzacji
**Decyzja:** **Darmowa z reklamami + opcja usunięcia reklam**

| Element | Szczegóły |
|---------|----------|
| Cena bazowa | Darmowa |
| Reklamy | Po ukończeniu każdego poziomu LUB po każdej śmierci |
| Opcja premium | Jednorazowy zakup: **20 zł** — usuwa wszystkie reklamy |
| Sklep in-game | Bez zmian — monety zdobywane grą, brak mikropłatności |

> ℹ️ Reklamy: Google AdMob (Android) + App Tracking Transparency (iOS). Zakup "bez reklam" przez Google Play Billing / App Store In-App Purchase.

**Status:** ✅ Zamknięte

---

## UX / INTERFEJS

### OQ-11 ✅ Widok kamery
**Decyzja:** Każdy gracz śledzi **swoją postać** na własnym ekranie.
- Widoczny obszar: duży (~50% mapy poziomu) — gracz widzi otoczenie, może obserwować teren przed sobą
- Kamera: płynnie podąża za postacią gracza
- Oba telefony renderują ten sam stan gry, każdy z własnym centrum kamery
- Synchronizacja: pozycje obu postaci przesyłane między urządzeniami w czasie rzeczywistym

**Status:** ✅ Zamknięte

---

### OQ-12 ✅ Komunikacja w grze między graczami
**Decyzja:** Brak jakiejkolwiek komunikacji in-game.
- Gracze komunikują się poza grą (rozmowa, telefon)
- Upraszcza implementację i UI

**Status:** ✅ Zamknięte

---

### OQ-13 ✅ Sterowanie
**Decyzja:** Wirtualny D-pad + przyciski akcji.
- Lewy kciuk: D-pad (lewo/prawo) lub analogowy joystick
- Prawy kciuk: przycisk **Skok** + przycisk **Akcja** (interakcja z dźwignią, aktywacja nieśmiertelności itp.)
- Swipe gestures: opcjonalnie do rozważenia w późniejszym etapie

**Status:** ✅ Zamknięte

---

## GRAFIKA / DŹWIĘK

### OQ-14 ✅ Kto tworzy grafikę?
**Decyzja:** Grafika tworzona samodzielnie z pomocą AI.

**Workflow:**
1. Generuj koncepty przez Midjourney / DALL-E 3 (prompt: `"pixel art 16-bit [temat], game asset, transparent background"`)
2. Importuj do **Aseprite**, dopracuj piksele ręcznie, dostosuj paletę
3. Stwórz spójny tileset per strefa (Ziemia / Niebo / Piekło)
4. Animuj klatka po klatce w Aseprite

**Narzędzia:**
| Narzędzie | Rola | Koszt |
|-----------|------|-------|
| Midjourney / DALL-E 3 | Generowanie konceptów i bazy grafik | Płatne (subskrypcja) |
| Aseprite | Edycja, tileset, animacje pixel art | ~$20 |
| Libresprite | Alternatywa dla Aseprite | Darmowy |
| Leonardo.ai | Alternatywa z darmowymi kredytami | Darmowy (limit) |

**Status:** ✅ Zamknięte

---

### OQ-15 ✅ Muzyka i efekty dźwiękowe
**Decyzja:** Tylko źródła pozwalające na **komercyjne użycie** — lub muzyka zrobiona samodzielnie.

**Opcje z licencją komercyjną:**
| Źródło | Typ | Licencja komercyjna | Uwagi |
|--------|-----|--------------------|---------|
| [OpenGameArt.org](https://opengameart.org) | Muzyka + SFX | ✅ CC0 / CC-BY | Sprawdzaj licencję per utwór — tylko CC0 lub CC-BY |
| [Freesound.org](https://freesound.org) | SFX | ✅ CC0 wymagane | Filtruj: `License: Creative Commons 0` |
| [itch.io — asset packs](https://itch.io/game-assets) | Muzyka + SFX | ✅ (płatne paczki) | Wiele paczek z jawną licencją komercyjną |
| **Suno** (AI muzyka) | Muzyka | ✅ Plan Pro/Premier | Plan darmowy NIE pozwala na komercję; płatny — tak |
| **Udio** (AI muzyka) | Muzyka | ✅ Plan płatny | Sprawdź TOS przy użyciu komercyjnym |
| **FamiStudio / BeepBox** | Tworzenie chiptune | ✅ Własna muzyka | Darmowe narzędzia do tworzenia muzyki 8-bit |
| **LMMS** | DAW do tworzenia muzyki | ✅ Własna muzyka | Darmowy, dobry dla retro brzmień |

> ⚠️ **Zasada:** Jeśli nie masz 100% pewności co do licencji komercyjnej — nie używamy. Bezpieczniej stworzyć własną muzykę w FamiStudio/LMMS lub kupić licencjonowaną paczkę.

**Rekomendacja:** Chiptune/pixel muzyka pasuje do stylu gry — **FamiStudio** (darmowy, specjalnie do muzyki NES/chiptune) + SFX z OpenGameArt CC0.

**Status:** ✅ Zamknięte

---

## UWAGI DO PRZYSZŁYCH SESJI

### Zamknięte kwestie blokujące ✅
- OQ-01 WiFi Direct + BT fallback
- OQ-02 Godot 4 (GDScript)
- OQ-04 Śmierć = reset poziomu, bez żyć
- OQ-05 60 poziomów (20 per strefa)
- OQ-07 Sklep: szybkość / wyskok / nieśmiertelność 10s
- OQ-08 Zagadki: 4 opcje, limit czasu, EN+PL
- OQ-09 Pair ID save
- OQ-10 Free + reklamy + 20 zł premium
- OQ-11 Kamera per gracz, ~50% mapy
- OQ-12 Brak komunikacji in-game
- OQ-13 D-pad + Skok + Akcja
- OQ-14 Grafika własna + AI (Aseprite + Midjourney)
- OQ-15 Muzyka CC0 / własna (FamiStudio)

### Jeszcze do omówienia
- [ ] OQ-03 — rozbudowa listy przeszkód specyficznych przy projektowaniu poziomów
- [ ] OQ-06 — poziom finałowy (zamiast bossa)?
- [ ] Fabuła / lore: cutscenka startowa? Dlaczego kostucha i strażniczka razem?
- [ ] Szkic drzewa poziomów (mapa świata)
- [ ] Baza zagadek — `docs/PUZZLES.md`
- [ ] Instalacja Godot 4 i setup projektu (Faza 1)
