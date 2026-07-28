# Jak zbudować poziom własnoręcznie (w edytorze Godota)

> Instrukcja krok po kroku. Wzorzec do podglądania: `game/scenes/levels/earth/Level_Earth_01.tscn`
> (otwórz obok swojej sceny i porównuj). Testowanie: otwórz swoją scenę i wciśnij **F6**.

---

## 1. Start — szkielet sceny

1. W edytorze: **Scena → Nowa scena** → typ korzenia **Node2D** (prawym → „Zmień typ" jeśli trzeba).
2. Nazwij korzeń np. `Level_Earth_07` i zapisz do `game/scenes/levels/earth/Level_Earth_07.tscn`
   (nazwa pliku MUSI pasować do wzorca `Level_<Strefa>_<NR>.tscn` — tak znajduje go mapa świata).
3. Kliknij korzeń → w Inspektorze **Script → Załaduj** → `res://scripts/levels/level_base.gd`.
4. W Inspektorze ustaw **Level Size** — rozmiar świata poziomu w pikselach, np. `(1280, 720)`.
   Poziom powinien być większy niż ekran (640×360) — kamera podąża za graczem,
   a minimapa po kliknięciu pokaże całość.

### Węzły OBOWIĄZKOWE (poziom bez nich się wysypie)

Przeciągnij te sceny z panelu Plików do drzewa sceny (jako dzieci korzenia) i nazwij DOKŁADNIE tak:

| Węzeł | Scena | Uwagi |
|-------|-------|-------|
| `Player` | `scenes/characters/Player.tscn` | Kostucha — ustaw pozycję startową |
| `Guardian` | `scenes/characters/Guardian.tscn` | Strażniczka — obok |
| `TouchControls` | `scenes/ui/TouchControls.tscn` | zaznacz „Visible = off" |
| `TouchControlsP2` | `scenes/ui/TouchControlsP2.tscn` | j.w. |
| `DeathScreen` | `scenes/ui/DeathScreen.tscn` | j.w. |
| `WorldEnv` | zwykły **TextureRect** | rozciągnij na cały poziom (0,0 → level_size); tekstury NIE ustawiaj — gra sama wstawi wycinek mapy świata |
| `ExitPortalPlayer` | `scenes/obstacles/ExitPortal.tscn` | w Inspektorze `Target Character = Player` |
| `ExitPortalGuardian` | `scenes/obstacles/ExitPortal.tscn` | `Target Character = Guardian` |

Minimapa i HUD monet dodają się same — nic nie rób.

---

## 2. Teren — malowanie kafelkami (najszybsza droga)

Podłogi, ściany, półki i filary rysujesz **pędzlem**, a nie stawiając węzły jeden
po drugim. Kolizja powstaje przy tym sama — nie dodajesz żadnego `StaticBody2D`.

1. Dodaj do korzenia węzeł **TileMapLayer**, nazwij `Terrain`.
2. W Inspektorze **Tile Set** → przeciągnij `res://assets/tilesets/earth/earth_terrain.tres`.
3. Ustaw **Z Index = −1** (postacie mają 0, więc chodzą PRZED terenem).
4. Na dolnym panelu wejdź w zakładkę **TileMap → Terrains**, wybierz teren
   **„Ziemia"** i maluj. Godot **sam dobiera** rogi, krawędzie i zaślepki —
   rysujesz bryłę, a wykończenie robi się samo.

Kafel ma **32×32 px**, więc siatka trzyma poziom w ryzach: skok w górę to ~4
kafle, komfortowy odstęp półek 3–4 kafle. Poziom 1280×720 = 40×22 kafli.

> Podglądówka wszystkich 16 kafli z nazwami: `docs/terrain_tiles_reference.png`.
> Atlas powstaje z `assets/sprites/earth_tileset_src.png` przez
> `tools/slice_terrain.gd`, a `.tres` przez `tools/build_terrain_tileset.gd` —
> uruchamiaj je tylko, gdy podmieniasz grafikę źródłową.

---

## 2b. Obudowa ręczna (styl „Ziemia" — zamknięte pudło)

> Kafelki z pkt 2 zastępują to przy zwykłym terenie. Ten sposób zostaje dla
> wielkich jednolitych ścian i elementów, które nie leżą na siatce 32 px.

Każda ściana = **StaticBody2D** + **CollisionShape2D** (fizyka) + **NinePatchRect** (wygląd).

1. Dodaj `StaticBody2D`, nazwij np. `BorderTop`. W Inspektorze:
   **Collision → Layer = tylko 3** (world), **Mask = nic**.
2. Dodaj mu dziecko `CollisionShape2D` → Shape → **Nowy RectangleShape2D** →
   rozmiar np. `(1440, 40)` (dłuższy niż poziom, 40 grubości). Ustaw na krawędzi poziomu
   (środek ściany na linii krawędzi, np. górna: pozycja `(640, 0)`).
3. Dodaj mu dziecko `NinePatchRect`:
   - **Texture** = `res://assets/tilesets/mossy/panel.png`
   - **Patch Margin**: Left/Top/Right = `32`, Bottom = `36` (to szerokość mszystego brzegu)
   - Rozciągnij tak, żeby do wnętrza poziomu wystawało ~26 px mchu, a reszta ciała
     bloku wisiała POZA poziomem (patrz BorderTop we wzorcu: offsety `-180 → +26` w pionie).
4. Powtórz ×4 (góra/dół/lewo/prawo). Rogi mogą na siebie nachodzić — mech się ładnie zlewa.

> **Niebo (plan):** tam NIE zamykamy dołu — zamiast dolnej ściany daj **KillZone** (pkt 5),
> żeby spadnięcie = śmierć.

---

## 3. Wnętrze — półki, kolumny, klocki

Ta sama trójca: `StaticBody2D` (Layer 3) + `CollisionShape2D` + wygląd.

| Element | Tekstura | Wygląd | Kolizja |
|---------|----------|--------|---------|
| Półka | `mossy/bar.png` | **TextureRect** w naturalnym rozmiarze 144×59 | Rectangle `140×24`, środek ~22 px poniżej górnej krawędzi tekstury (postać „stoi w trawie") |
| Kolumna / filar | `mossy/column.png` | **NinePatchRect**, margin L/R = 22, T/B = 40, szerokość ≥ 60 px | Rectangle węższy o ~16 px od wizualu |
| Duży prostokąt | `mossy/panel.png` | **NinePatchRect**, marginesy 32/32/32/36, dowolny rozmiar ≥ 70×70 | j.w. |
| Klocek | `mossy/block.png` | **TextureRect** 96×102 | Rectangle ~80×80 |

**Zasada:** kolizja zawsze odrobinę MNIEJSZA niż grafika — mech to miękki brzeg.

**Metryki skoku** (żeby dało się grać): skok w górę **≤ 130 px**, w dal **≤ 200 px**.
Odstęp pionowy między półkami rób 90–120 px.

---

## 4. Elementy specjalne (gotowe sceny — przeciągnij i ustaw)

| Scena | Po co | Co ustawić w Inspektorze |
|-------|-------|--------------------------|
| `obstacles/Door.tscn` | brama (otwiera ją dźwignia lub płyta) | `Door Id` np. `"gate_07"` — drzwi mają 80 px wysokości, stawiaj na podłodze |
| `obstacles/Lever.tscn` | dźwignia — otwiera bramę NA STAŁE | `Target Door Id` = ten sam co w drzwiach |
| `obstacles/PressurePlate.tscn` | płyta naciskowa — brama otwarta TYLKO gdy ktoś stoi | `Target Door Id`; **para płyt po obu stronach drzwi** = przechodzenie na zmianę |
| `obstacles/MovingPlatform.tscn` | winda / patrol | `Travel` (wektor, np. `(0,-260)` = 260 px w górę), `Period` (sekundy pełnego cyklu), `Phase` (0–1, przesunięcie cyklu) |
| `obstacles/CrumblingPlatform.tscn` | krusząca się platforma: dotyk → 0,5 s trzęsienia → spada → wraca po 3 s | pozycja; opcjonalnie `Shake Time` / `Respawn Time` |
| `obstacles/OneWayPlatform.tscn` | półka jednokierunkowa — wskakujesz od dołu, lądujesz na górze | tylko pozycja |
| `obstacles/Seesaw.tscn` | huśtawka fizyczna | tylko pozycja |
| `obstacles/Skull.tscn` | 💀 moneta Kostuchy (1–5 szt.) | tylko pozycja — kładź na trasie Kostuchy (może w lawie!) |
| `obstacles/Heart.tscn` | ❤️ moneta Strażniczki (1–5 szt.) | na trasie Strażniczki (np. na chmurach) |

> 🎨 **Kolory par:** drzwi i wszystkie ich wyzwalacze (dźwignie, płyty) automatycznie
> barwią się TYM SAMYM kolorem wyliczonym z `Door Id` — gracz od razu widzi, co co
> otwiera. Nic nie konfigurujesz; wystarczy zgodne `Door Id`/`Target Door Id`.

> 🤝 **Head-boost:** postać stojąca na głowie partnera zostaje wystrzelona w górę
> (wyżej niż zwykły skok) i zachowuje sterowanie w locie — projektuj półki
> osiągalne TYLKO tak (np. nasza `OneWayStep` w Earth_01 na wys. 560).

Portale są zablokowane, dopóki postać nie zbierze wszystkich swoich monet — poziom
kończy się, gdy obie postacie z kompletami staną w swoich portalach.

---

## 5. Strefy zabójcze i specjalne

### Lawa (zabija tylko Strażniczkę)
1. `Area2D` → **Layer = nic, Mask = tylko 2** (guardian).
2. Dziecko `CollisionShape2D` (prostokąt, np. 120×24) — połóż NA podłodze.
3. Wygląd: `Sprite2D`, tekstura `assets/gen/tiles/lava0.png`, w Inspektorze
   **Region → włącz**, rozmiar regionu = rozmiar strefy, **Texture → Repeat = Enabled**.
4. Podłącz sygnał: zakładka **Węzeł → Sygnały** → `body_entered` → połącz z korzeniem
   sceny, metoda `_on_hazard_entered`.

### Święte światło (zabija tylko Kostuchę — Niebo)
Jak lawa, ale: **Mask = tylko 1**, do Area2D podepnij skrypt
`res://scripts/systems/light_zone.gd` (sygnału NIE łączysz — skrypt sam zabija),
wygląd: `assets/gen/tiles/light_beam.png` (pionowy region).

### Chmura (chodzi po niej tylko Strażniczka)
`StaticBody2D` z **Layer = tylko 4** (cloud), Mask = nic. Wygląd: `assets/gen/tiles/cloud.png`
(Sprite2D z regionem jak lawa).

### KillZone (przepaść — śmierć obu)
`Area2D` → **Mask = 1 i 2**, prostokąt POD poziomem (np. y = level_size.y + 70),
sygnał `body_entered` → `_on_hazard_entered`. Na Ziemi to tylko siatka bezpieczeństwa;
w Niebie to główna mechanika spadania.

---

## 6. Warstwy kolizji — ściąga

| # | Nazwa | Kto/co |
|---|-------|--------|
| 1 | player | Kostucha |
| 2 | guardian | Strażniczka |
| 3 | world | podłogi, ściany, półki, drzwi |
| 4 | cloud | chmury (tylko Strażniczka) |

Postacie: Kostucha Layer 1 / Mask 3+2; Strażniczka Layer 2 / Mask 3+4+1 (kolidują ze sobą).

---

## 7. Rejestracja poziomu na mapie świata

Nowy numer poziomu (np. Earth 7) jest już zaplanowany na mapie? Sprawdź
`game/scripts/systems/level_manager.gd` → `LEVEL_GRAPH`. Jeśli wpis o Twojej
strefie+numerze istnieje — po zapisaniu sceny poziom automatycznie stanie się
grywalny (kłódka zniknie). Jeśli nie — dopisz wpis (pozycja na mapie + `next`)
albo powiedz mi, ja dopiszę.

---

## 8. Checklista przed testem (F6)

- [ ] Korzeń ma skrypt `level_base.gd` i ustawiony `Level Size`
- [ ] Wszystkie węzły obowiązkowe z pkt 1 (nazwy DOKŁADNIE takie)
- [ ] Obudowa nie ma dziur (chyba że celowo — Niebo)
- [ ] KillZone jest (nawet w zamkniętym poziomie — siatka bezpieczeństwa)
- [ ] Po 2–3 💀 i ❤️, każda dostępna dla właściwej postaci
- [ ] Skoki ≤ 130 px w górę; obie postacie DOJDĄ do swoich portali
- [ ] Dźwignia/zagadka nie tworzy zakleszczenia (każdy gate otwierany z miejsca
      dostępnego PRZED nim)
- [ ] F6: przejdź poziom OBIEMA postaciami (WASD = Strażniczka, strzałki = Kostucha)
