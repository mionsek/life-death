# Life & Death — Otwarte Pytania i Kwestie do Rozstrzygnięcia

> Każda kwestia ma priorytet: 🔴 Blokujący | 🟡 Ważny | 🟢 Może poczekać  
> Status: ❓ Otwarte | 🔄 W toku | ✅ Zamknięte

---

## TECHNOLOGIA

### OQ-01 🔴 Protokół komunikacji offline (Bluetooth vs WiFi Direct)
**Pytanie:** Jakiego protokołu użyć do połączenia 2 graczy bez internetu?

**Opcje:**
- **Bluetooth Classic** — prosty UX ("znajdź urządzenia"), ~10m zasięgu, latencja ~20-50ms
- **BLE (Bluetooth Low Energy)** — energooszczędny, ale ograniczona przepustowość
- **WiFi Direct** — szybszy, ale trudniejszy do sparowania, ~100m zasięgu
- **Lokalny hotspot** — najszybszy, ale wymaga od jednego gracza wyłączenia internetu

**Kontekst:** Gra musi działać na pokładzie samolotu (tryb lotniczy). Bluetooth działa w trybie lotniczym — WiFi Direct na Androidzie też działa bez połączenia z internetem.

**Rekomendacja do dyskusji:** WiFi Direct (szybszy, niższe opóźnienia) z fallbackiem na Bluetooth.

**Status:** ❓ Otwarte

---

### OQ-02 🔴 Silnik / Stos technologiczny
**Pytanie:** Którą technologię wybrać do budowy gry?

| Opcja | Zalety | Wady | Trudność |
|-------|--------|------|---------|
| Unity (C#) | Ogromna społeczność, świetne 2D, pluginy Bluetooth | Cięższy, licencja | ⭐⭐⭐ |
| Godot 4 (GDScript) | Darmowy, lekki, pixel art-friendly | Mniejsza społeczność, Bluetooth = plugin | ⭐⭐ |
| Flutter + Flame | Dobry dla mobile, jeden język (Dart) | Mniej zasobów dla gier | ⭐⭐ |
| React Native + Phaser | JS/TS, web-based game | Słabsza wydajność dla gier | ⭐ |

**Pytanie pomocnicze:** Czy masz doświadczenie z którymkolwiek z tych środowisk?

**Status:** ❓ Otwarte

---

### OQ-03 🟡 Pełna lista przeszkód specyficznych dla postaci
**Pytanie:** Jakie konkretnie elementy planszy są bezpieczne dla jednej postaci, a śmiertelne dla drugiej?

**Propozycja bazowa:**
| Element | Kostucha | Strażniczka |
|---------|----------|-------------|
| Ogień / Lawa | ✅ Bezpieczne | ☠️ Śmiertelne |
| Chmury | ☠️ Przepada | ✅ Chodzi po nich |
| Woda święcona / Blask | ☠️ Śmiertelne | ✅ Bezpieczne |
| Ciemne strefy (mrok) | ✅ Bezpieczne | ☠️ Widoczność |
| Kwiaty / natura | ☠️ Spowalnia? | ✅ Bezpieczne |
| Trucizna | ? | ? |
| Lód / Zimno | ? | ? |
| Elektryczność | ? | ? |

**Status:** ❓ Otwarte — potrzeba minimum 5-6 typów przeszkód

---

### OQ-04 🟡 Mechanika śmierci i respawnu
**Pytanie:** Co się dzieje gdy postać trafi na śmiertelną przeszkodę?

**Opcje:**
- A) Checkpoint: wraca do ostatniego punktu kontrolnego, druga osoba czeka
- B) Wspólny reset: oboje cofają się do checkpointu
- C) System żyć (np. 3 życia na poziom)
- D) Brak lives — możesz próbować ile razy chcesz

**Status:** ❓ Otwarte

---

### OQ-05 🟡 Ile poziomów łącznie?
**Pytanie:** Jaka jest planowana liczba poziomów?

**Propozycja:**
- Ziemia: 5-7 poziomów
- Niebo: 5 poziomów + 1 boss
- Piekło: 5 poziomów + 1 boss
- Łącznie: ~17-19 poziomów + 2 bossów

**Status:** ❓ Otwarte

---

### OQ-06 🟡 Walki z bossem (Boss Fight)
**Pytanie:** Czy będą bossowie na końcu każdej strefy?

**Propozycja:**
- Boss Nieba: "Archanioł" — trudniejszy dla Kostuchy
- Boss Piekła: "Arcydemon" — trudniejszy dla Strażniczki
- Finałowy boss (ziemia?): wymaga idealnej kooperacji obu postaci

**Status:** ❓ Otwarte

---

### OQ-07 🟢 Trzecia zdolność w sklepie
**Pytanie:** Co byłoby trzecią dostępną opcją w sklepie obok szybkości i wyskoku?

**Propozycje:**
- Czasowy nieśmiertelność / tarcza (np. 5 sekund na poziom)
- Dodatkowe życie
- Podgląd trasy (mapa poziomu na chwilę)
- Teleportacja krótka (dash)
- Magnetyzm monet (zbieranie z większej odległości)

**Status:** ❓ Otwarte

---

## ROZGRYWKA

### OQ-08 🟡 Liczba i typy zagadek na poziom
**Pytanie:** Ile zagadek planujemy per poziom i jakiego typu?

**Propozycja:** 1-2 zagadki per poziom, rotacja typów:
- Typ A (słowne): głównie w Niebie (filozoficzne, duchowe)
- Typ B (matematyczne): głównie w Piekle (zimne, logiczne)
- Typ C (kooperacyjne): wszędzie
- Typ D (środowiskowe): głównie w Ziemi

**Baza zagadek słownych do rozbudowania:**
1. "Co żyje gdy jesz, umiera gdy pijesz?" → Ogień
2. "Jestem przed tobą, za tobą, ale nie możesz mnie dotknąć" → Przyszłość
3. "Im więcej oddajesz, tym więcej masz" → Miłość / Wiedza
4. *(dodaj więcej)*

**Status:** ❓ Otwarte

---

### OQ-09 🔴 System zapisu progresu — synchronizacja
**Pytanie:** Jak synchronizować zapis między dwoma urządzeniami?

**Problem:** Gracze rozchodzą się, każdy ma swój telefon. Jak wznowić tę samą sesję?

**Opcje:**
- A) Jedno urządzenie jest "masterem" zapisu — drugie pobiera przy połączeniu
- B) Oboje eksportują kod sesji (ciąg znaków) i porównują przy starcie
- C) Zapis QR-code — jeden skanuje od drugiego
- D) Plik zapisu przez share (AirDrop, Bluetooth Share)

**Status:** ❓ Otwarte

---

### OQ-10 🟢 Model monetyzacji
**Pytanie:** Czy gra będzie płatna, darmowa, czy freemium?

**Opcje:**
- Free z opcjonalnymi skórkami kosmetycznymi (nie wpływają na gameplay)
- One-time purchase (~$2-5)
- Free z reklamami między poziomami (opt-out za opłatą)

**Status:** ❓ Otwarte

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
