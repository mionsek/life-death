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

**Status:** 🔄 Propozycja gotowa — czeka na akceptację

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

### OQ-11 🟡 Widok kamery — podział ekranu czy osobny?
**Pytanie:** Skoro każdy ma swój telefon — co widzi każdy gracz?

**Opcje:**
- A) Każdy widzi cały poziom (wspólna kamera, prosta)
- B) Każdy śledzi swoją postać (osobna kamera per gracz) — potrzeba synchronizacji stanu
- C) Hybryda: podzielony widok tylko gdy gracze są daleko od siebie

**Status:** ❓ Otwarte

---

### OQ-12 🟢 Komunikacja w grze między graczami
**Pytanie:** Czy gracze mogą się komunikować w grze?

**Opcje:**
- Emotes / ikony (serce, kciuk, alert)
- Ping na mapie ("idź tu")
- Brak komunikacji in-game (używają własnego telefonu do rozmowy)

**Status:** ❓ Otwarte

---

### OQ-13 🟡 Sterowanie
**Pytanie:** Jak będzie wyglądać sterowanie na telefonie?

**Propozycja:**
- Lewy kciuk: D-pad / joystick do poruszania
- Prawy kciuk: przycisk skoku + akcja
- Ewentualnie: swipe gestures dla specjalnych zdolności

**Status:** ❓ Otwarte

---

## GRAFIKA / DŹWIĘK

### OQ-14 🟢 Kto tworzy grafikę?
**Pytanie:** Czy grafikę tworzymy sami, zlecamy, czy używamy AI + ręczne poprawki?

**Workflow propozycja:**
1. Generuj koncepty przez Midjourney/DALL-E (prompt: "pixel art 16-bit [temat], game asset, transparent background")
2. Importuj do Aseprite, dopracuj piksele ręcznie
3. Stwórz spójny tileset
4. Animuj klatka po klatce w Aseprite

**Status:** ❓ Otwarte

---

### OQ-15 🟢 Muzyka i efekty dźwiękowe
**Pytanie:** Skąd pochodzi muzyka i SFX?

**Darmowe zasoby:**
- [OpenGameArt.org](https://opengameart.org) — darmowe assety CC
- [Freesound.org](https://freesound.org) — darmowe SFX
- [itch.io](https://itch.io/game-assets/free) — paczki game assets
- **AI:** Suno, Udio (generowanie muzyki), ElevenLabs (głos/narracja)

**Status:** ❓ Otwarte

---

## UWAGI DO PRZYSZŁYCH SESJI

- [ ] Zdecydować stos technologiczny (OQ-02) przed jakimkolwiek prototypowaniem
- [ ] Zdecydować protokół offline (OQ-01) — zależy od stosu tech
- [ ] Stworzyć listę 15+ zagadek słownych
- [ ] Narysować szkic mapy poziomów (drzewo)
- [ ] Zdecydować ile przeszkód specyficznych (minimum 5-6 par)
- [ ] Przemyśleć fabułę/lore: czy jest cutscenka startowa? Dlaczego kostucha i strażniczka razem?
