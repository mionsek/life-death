# Procedural pixel-art asset generator for Life & Death.
# Run headless:  godot --headless -s res://tools/generate_assets.gd
# Regenerates every sprite/tile/background PNG under res://assets/gen/.
# Art direction: 2D pixel art, 3-zone palette (Earth green/brown, Heaven white/gold,
# Hell red/black) per docs/GAME_DESIGN.md §9.
extends SceneTree

const OUT := "res://assets/gen/"

# ---------------------------------------------------------------- helpers ---

func _make(w: int, h: int) -> Image:
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	return im


func _px(im: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < im.get_width() and y < im.get_height():
		im.set_pixel(x, y, c)


func _rect(im: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			_px(im, xx, yy, c)


# Draws an ASCII pixel map onto the image. '.' and ' ' are transparent (skip).
func _map(im: Image, rows: Array, legend: Dictionary, ox: int = 0, oy: int = 0) -> void:
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			var ch := row[x]
			if ch == "." or ch == " ":
				continue
			if legend.has(ch):
				_px(im, ox + x, oy + y, legend[ch])


func _save(im: Image, rel: String) -> void:
	var abs_path := ProjectSettings.globalize_path(OUT + rel)
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	var err := im.save_png(abs_path)
	if err != OK:
		push_error("save failed: %s (%d)" % [rel, err])
	else:
		print("  wrote ", rel)


# Deterministic hash noise in [0,1) — stable across runs so PNGs don't churn in git.
func _noise(x: int, y: int, seed_v: int = 0) -> float:
	var n := x * 374761393 + y * 668265263 + seed_v * 1442695041
	n = (n ^ (n >> 13)) * 1274126177
	return float((n ^ (n >> 16)) & 0xffff) / 65536.0


# ------------------------------------------------------------- characters ---

# Frame order in both sheets: idle0 idle1 walk0 walk1 walk2 walk3 jump  (24x32 each)
const FRAME_W := 24
const FRAME_H := 32

const REAPER_LEGEND := {
	"k": Color("181423"), "K": Color("262038"), "L": Color("3a3154"),
	"s": Color("e8e4da"), "E": Color("9b30ff"), "g": Color("0c0a14"),
	"h": Color("6b5233"), "H": Color("8a6b42"),
	"b": Color("aebcc4"), "B": Color("d8e4ea"),
}

# Head, hood, scythe and torso — shared by every frame (rows 0..19).
const REAPER_TOP := [
	"........bbbbbbbbbbhH....",
	"......bbbbBBBBBBBBhH....",
	".....bbb..........hH....",
	"....bb...kkkkk....hH....",
	"....b...kkkkkkk...hH....",
	"...kkkkkkkkkkkkk..hH....",
	"...kkgggssssgggkk.hH....",
	"..kkggssssssssggk.hH....",
	"..kkggsEssssEssgk.hH....",
	"..kkggssssssssggk.hH....",
	"..kkkgggsssssggkk.hH....",
	"...kkkkkgggggkkk..hH....",
	"...KKKKKKKKKKKK...hH....",
	"..KKKKKKKKKKKKK...hH....",
	"..KKKKKKKKKKKKKK..hH....",
	".KKKKKKKKKKKKKKK..hH....",
	".KKKKKKKKKKKKKKKkkhH....",
	".KKKKKKKKKKKKKKK..hH....",
	".KKKKKKKKKKKKKKKK.hH....",
	".KKKKKKKKKKKKKKKK.hH....",
]

# Ragged cloak hem variants (rows 20..27).
const REAPER_BOTTOM_NEUTRAL := [
	"KKKKKKKKKKKKKKKKK.hH....",
	"KKKKKKKKKKKKKKKKK.hH....",
	"kKKKKKKKKKKKKKKKk.hH....",
	"kKKKKKKKKKKKKKKKk.hH....",
	"kKKKKKKKKKKKKKKKk.hH....",
	"kKK.KKKK.KKKK.KKk.hH....",
	".KK..KKK..KK...KK.hH....",
	"..K...K....K......hH....",
]
const REAPER_BOTTOM_SWAY := [
	"KKKKKKKKKKKKKKKKK.hH....",
	"KKKKKKKKKKKKKKKKK.hH....",
	"kKKKKKKKKKKKKKKKk.hH....",
	"kKKKKKKKKKKKKKKKk.hH....",
	"kKKKKKKKKKKKKKKKk.hH....",
	"kK.KKKK.KKKK.KKKk.hH....",
	".K..KK...KKK..KK..hH....",
	".....K....K....K..hH....",
]
const REAPER_BOTTOM_FLARE := [
	"KKKKKKKKKKKKKKKKK.hH....",
	"kKKKKKKKKKKKKKKKKkhH....",
	"kKKKKKKKKKKKKKKKKkhH....",
	"kKKKKKKKKKKKKKKKKkhH....",
	"kKKK.KKKK.KKKK.KKkhH....",
	"kKK...KK...KK...K.hH....",
	".K....K.....K.....hH....",
	"..................hH....",
]


func _reaper_frame(bottom: Array, dy: int) -> Image:
	var im := _make(FRAME_W, FRAME_H)
	_map(im, REAPER_TOP, REAPER_LEGEND, 0, dy)
	_map(im, bottom, REAPER_LEGEND, 0, 20 + dy)
	return im


const GUARD_LEGEND := {
	"W": Color("f5f2e8"), "w": Color("ddd6c2"), "G": Color("e6b83c"),
	"o": Color("f0c8a0"), "O": Color("d8a878"), "y": Color("eecb62"),
	"Y": Color("c9a63e"), "A": Color("ffe680"), "e": Color("2e5e40"),
	"F": Color("cfe4f2"), "f": Color("a8c8e0"), "v": Color("7ec87e"),
}

# Halo, hair, face, torso and dress — shared by every frame (rows 0..26).
const GUARD_BODY := [
	"........AAAAAAAA........",
	"........................",
	".........yyyyyy.........",
	"........yyyyyyyy........",
	".......yyyyyyyyyy.......",
	".......yyooooooyy.......",
	".......Yyoeooeoyy.......",
	".......Yyooooooyy.......",
	"........yOooooOy........",
	".........oooooo.........",
	"........WWWWWW..........",
	".......WWWWWWWW.........",
	"......oWWWWWWWWo........",
	"......ovvvvvvvvo........",
	".......WWWWWWWW.........",
	"......WWWWWWWWWW........",
	"......WWWWwWWWWW........",
	".....WWWWWwWWWWWW.......",
	".....WWWWWwWWWWWW.......",
	"....WWWWWWwWWWWWWW......",
	"....WWWWWWwWWWWWWW......",
	"...WWWWWWWwWWWWWWWW.....",
	"...WWWWWWWwWWWWWWWW.....",
	"..WWWWWWWWwWWWWWWWWW....",
	"..WWWWWWWWwWWWWWWWWW....",
	"..GGGGGGGGGGGGGGGGGG....",
	"..GGGGGGGGGGGGGGGGGG....",
]

const GUARD_WINGS := [
	"..F..................F..",
	".FFF................FFF.",
	".FFFF..............FFFF.",
	"FFFFF..............FFFFF",
	"FFFFf..............fFFFF",
	"FFFf................fFFF",
	"fFFf................fFFf",
	"fFf..................fFf",
	".ff..................ff.",
]

const GUARD_LEGS_IDLE := [
	".......oo....oo.........",
	".......oo....oo.........",
	".......OO....OO.........",
]
const GUARD_LEGS_WALK_A := [
	"......oo......oo........",
	".....oo........oo.......",
	".....OO........OO.......",
]
const GUARD_LEGS_WALK_B := [
	".......oo....oo.........",
	"........oo..oo..........",
	"........OO..OO..........",
]


func _guardian_frame(wing_dy: int, legs: Array, dy: int) -> Image:
	var im := _make(FRAME_W, FRAME_H)
	_map(im, GUARD_WINGS, GUARD_LEGEND, 0, 8 + wing_dy + dy)   # wings behind body
	_map(im, GUARD_BODY, GUARD_LEGEND, 0, dy)
	_map(im, legs, GUARD_LEGEND, 0, 27 + dy)
	return im


func _gen_characters() -> void:
	# Reaper: idle bobs, walk sways the ragged hem, jump flares the cloak.
	var rframes: Array[Image] = [
		_reaper_frame(REAPER_BOTTOM_NEUTRAL, 0),
		_reaper_frame(REAPER_BOTTOM_NEUTRAL, 1),
		_reaper_frame(REAPER_BOTTOM_NEUTRAL, 0),
		_reaper_frame(REAPER_BOTTOM_SWAY, 1),
		_reaper_frame(REAPER_BOTTOM_NEUTRAL, 0),
		_reaper_frame(REAPER_BOTTOM_SWAY, 0),
		_reaper_frame(REAPER_BOTTOM_FLARE, -1),
	]
	var sheet := _make(FRAME_W * rframes.size(), FRAME_H)
	for i in rframes.size():
		sheet.blit_rect(rframes[i], Rect2i(0, 0, FRAME_W, FRAME_H), Vector2i(i * FRAME_W, 0))
	_save(sheet, "characters/reaper_sheet.png")

	# Guardian: wings flap on walk/jump, legs alternate.
	var gframes: Array[Image] = [
		_guardian_frame(0, GUARD_LEGS_IDLE, 0),
		_guardian_frame(1, GUARD_LEGS_IDLE, 1),
		_guardian_frame(-1, GUARD_LEGS_WALK_A, 0),
		_guardian_frame(1, GUARD_LEGS_WALK_B, 1),
		_guardian_frame(-1, GUARD_LEGS_WALK_A, 0),
		_guardian_frame(1, GUARD_LEGS_WALK_B, 1),
		_guardian_frame(-2, GUARD_LEGS_WALK_A, -1),
	]
	sheet = _make(FRAME_W * gframes.size(), FRAME_H)
	for i in gframes.size():
		sheet.blit_rect(gframes[i], Rect2i(0, 0, FRAME_W, FRAME_H), Vector2i(i * FRAME_W, 0))
	_save(sheet, "characters/guardian_sheet.png")


# ------------------------------------------------------------------ tiles ---

const TILE := 16

func _tile_grass(im: Image, ox: int) -> void:
	var dirt := Color("6b4a2a")
	var dirt_d := Color("55381f")
	var grass := Color("4f9e3c")
	var grass_l := Color("6fc251")
	for y in TILE:
		for x in TILE:
			var c := dirt if _noise(ox + x, y, 1) > 0.25 else dirt_d
			if y < 4:
				c = grass if _noise(ox + x, y, 2) > 0.3 else grass_l
			elif y == 4:
				c = grass if _noise(ox + x, y, 3) > 0.5 else dirt
			_px(im, ox + x, y, c)


func _tile_dirt(im: Image, ox: int) -> void:
	var dirt := Color("6b4a2a")
	var dirt_d := Color("55381f")
	var stonebit := Color("7d6547")
	for y in TILE:
		for x in TILE:
			var n := _noise(ox + x, y, 4)
			var c := dirt
			if n < 0.18:
				c = dirt_d
			elif n > 0.93:
				c = stonebit
			_px(im, ox + x, y, c)


func _tile_stone(im: Image, ox: int, base: Color, dark: Color, light: Color, seed_v: int) -> void:
	for y in TILE:
		for x in TILE:
			var c := base
			# brick pattern: mortar every 4 rows, offset joints
			if y % 8 == 7 or ((x + (4 if (y / 8) % 2 == 1 else 0)) % 8 == 7):
				c = dark
			elif _noise(ox + x, y, seed_v) > 0.9:
				c = light
			elif _noise(ox + x, y, seed_v + 1) < 0.08:
				c = dark
			_px(im, ox + x, y, c)


func _tile_wood(im: Image, ox: int) -> void:
	var wood := Color("8a5a2a")
	var wood_d := Color("6e4520")
	var wood_l := Color("a5723a")
	for y in TILE:
		for x in TILE:
			var c := wood
			if y % 5 == 4:
				c = wood_d
			elif _noise(ox + x, y, 7) > 0.85:
				c = wood_l
			elif _noise(0, y, 8) > 0.7 and x % 7 == 3:
				c = wood_d
			_px(im, ox + x, y, c)


func _tile_cloud(im: Image, ox: int) -> void:
	var puff := Color("dcecff")
	var shade := Color("a8c8ec")
	var deep := Color("7ea6d8")
	for y in TILE:
		for x in TILE:
			# puffy top silhouette via noise threshold; denser toward bottom
			var edge := 2.0 + 2.0 * _noise(ox + x, 0, 9)
			if y < int(edge):
				continue
			var c := puff
			if y > 11:
				c = deep
			elif y > 8 and _noise(ox + x, y, 10) > 0.5:
				c = shade
			_px(im, ox + x, y, c)


func _tile_gold(im: Image, ox: int) -> void:
	var gold := Color("e0b33c")
	var gold_d := Color("b58a24")
	var gold_l := Color("f5d878")
	for y in TILE:
		for x in TILE:
			var c := gold
			if x == 0 or y == 0:
				c = gold_l
			elif x == TILE - 1 or y == TILE - 1:
				c = gold_d
			elif (x + y) % 8 == 3:
				c = gold_l   # diagonal shine
			elif _noise(ox + x, y, 11) < 0.06:
				c = gold_d
			_px(im, ox + x, y, c)


func _tile_marble(im: Image, ox: int) -> void:
	var base := Color("e8ecf4")
	var vein := Color("b8c4dc")
	var lightc := Color("ffffff")
	for y in TILE:
		for x in TILE:
			var c := base
			if _noise(ox + x + y * 2, y, 12) < 0.12:
				c = vein
			elif _noise(ox + x, y, 13) > 0.94:
				c = lightc
			if y == TILE - 1:
				c = vein
			_px(im, ox + x, y, c)


func _tile_basalt(im: Image, ox: int) -> void:
	_tile_stone(im, ox, Color("3a3038"), Color("241c26"), Color("52444e"), 14)


func _tile_lava(im: Image, ox: int, phase: int) -> void:
	var hot := Color("ffdf5e")
	var mid := Color("ff8a1e")
	var deep := Color("d4380e")
	var dark := Color("9c1e08")
	for y in TILE:
		for x in TILE:
			var wave := int(2.0 * _noise((ox + x + phase * 3) / 3, 0, 15))
			var c := deep
			if y <= wave:
				c = hot
			elif y <= wave + 2:
				c = mid
			elif _noise(ox + x + phase * 5, y, 16) > 0.82:
				c = mid
			elif _noise(ox + x + phase * 7, y, 17) < 0.1:
				c = dark
			_px(im, ox + x, y, c)


func _tile_obsidian(im: Image, ox: int) -> void:
	var base := Color("1c1622")
	var sheen := Color("42335c")
	var crack := Color("0d0a12")
	for y in TILE:
		for x in TILE:
			var c := base
			if (x + y * 2) % 11 == 5 and _noise(ox + x, y, 18) > 0.4:
				c = sheen
			elif _noise(ox + x, y, 19) < 0.07:
				c = crack
			_px(im, ox + x, y, c)


func _gen_tiles() -> void:
	# Each zone sheet: 4 tiles of 16x16 in one row (64x16).
	var earth := _make(TILE * 4, TILE)
	_tile_grass(earth, 0)
	_tile_dirt(earth, TILE)
	_tile_stone(earth, TILE * 2, Color("8a8a92"), Color("62626c"), Color("aaaab4"), 5)
	_tile_wood(earth, TILE * 3)
	_save(earth, "tiles/earth_tiles.png")

	var heaven := _make(TILE * 4, TILE)
	_tile_cloud(heaven, 0)
	_tile_gold(heaven, TILE)
	_tile_marble(heaven, TILE * 2)
	_tile_gold(heaven, TILE * 3)
	_save(heaven, "tiles/heaven_tiles.png")

	var hell := _make(TILE * 4, TILE)
	_tile_basalt(hell, 0)
	_tile_lava(hell, TILE, 0)
	_tile_lava(hell, TILE * 2, 1)
	_tile_obsidian(hell, TILE * 3)
	_save(hell, "tiles/hell_tiles.png")

	# Single-tile PNGs — used by Sprite2D region tiling on platforms.
	for def in [
		["grass", 0, earth], ["dirt", 1, earth], ["stone", 2, earth], ["wood", 3, earth],
		["cloud", 0, heaven], ["gold", 1, heaven], ["marble", 2, heaven],
		["basalt", 0, hell], ["lava0", 1, hell], ["lava1", 2, hell], ["obsidian", 3, hell],
	]:
		var single := _make(TILE, TILE)
		single.blit_rect(def[2], Rect2i(def[1] * TILE, 0, TILE, TILE), Vector2i.ZERO)
		_save(single, "tiles/%s.png" % def[0])

	# Holy light beam texture (32 wide, tiles vertically): bright core, soft edges.
	var beam := _make(32, TILE)
	for y in TILE:
		for x in 32:
			var d := absf(x - 15.5) / 16.0
			var a := clampf(1.05 - d * 1.6, 0.0, 1.0)
			if a <= 0.02:
				continue
			var shimmer := 0.85 + 0.15 * _noise(x, y, 31)
			_px(beam, x, y, Color(1.0, 0.98, 0.8, a * 0.75 * shimmer))
	_save(beam, "tiles/light_beam.png")


# -------------------------------------------------------------- obstacles ---

func _gen_door() -> void:
	# 24x80 stone gate slab with gold emblem.
	var im := _make(24, 80)
	var stone := Color("7a7a84")
	var stone_d := Color("585862")
	var stone_l := Color("9a9aa6")
	var gold := Color("e0b33c")
	for y in 80:
		for x in 24:
			var c := stone
			if x == 0 or x == 23 or y == 0 or y == 79:
				c = stone_d
			elif x == 1 or y == 1:
				c = stone_l
			elif y % 16 == 8 or ((x + (6 if (y / 16) % 2 == 1 else 0)) % 12 == 6):
				c = stone_d
			elif _noise(x, y, 20) < 0.05:
				c = stone_d
			_px(im, x, y, c)
	# gold emblem: small diamond at the center
	for dy in range(-4, 5):
		var w := 4 - absi(dy)
		for dx in range(-w, w + 1):
			_px(im, 12 + dx, 38 + dy, gold)
	_save(im, "obstacles/door.png")


func _gen_lever() -> void:
	# 16x32; stick tilts left (idle, red knob) or right (active, green knob).
	for variant in ["idle", "active"]:
		var im := _make(16, 32)
		var base := Color("6e6e78")
		var base_d := Color("4e4e58")
		var stick := Color("8a6b42")
		var knob := Color("d43a2a") if variant == "idle" else Color("3ac84a")
		_rect(im, 2, 26, 12, 6, base)
		_rect(im, 2, 26, 12, 1, base_d)
		_rect(im, 3, 25, 10, 1, base_d)
		for i in 14:
			var x := (12 - i * 8 / 14) if variant == "idle" else (4 + i * 8 / 14)
			_px(im, x, 25 - i, stick)
			_px(im, x + 1, 25 - i, stick)
		var kx := 4 if variant == "idle" else 10
		_rect(im, kx - 1, 9, 4, 4, knob)
		_px(im, kx, 10, Color(1, 1, 1, 0.75))
		_save(im, "obstacles/lever_%s.png" % variant)


func _gen_panel() -> void:
	# 24x40 dark stone tablet with a gold '?'.
	var im := _make(24, 40)
	var slab := Color("2e2e48")
	var slab_d := Color("1e1e34")
	var slab_l := Color("44446a")
	var gold := Color("f0c84a")
	for y in 40:
		for x in 24:
			var c := slab
			if x == 0 or x == 23 or y == 0 or y == 39:
				c = slab_d
			elif x == 1 or y == 1:
				c = slab_l
			elif _noise(x, y, 21) < 0.05:
				c = slab_d
			_px(im, x, y, c)
	var q := [
		".XXXX.",
		"X....X",
		".....X",
		"....X.",
		"...X..",
		"...X..",
		"......",
		"...X..",
	]
	_map(im, q, {"X": gold}, 9, 12)
	_save(im, "obstacles/panel.png")


func _gen_portal() -> void:
	# 48x40 swirling oval, 2 animation frames; drawn white so the game tints it
	# per target character (modulate).
	for phase in 2:
		var im := _make(48, 40)
		var cx := 24.0
		var cy := 20.0
		for y in 40:
			for x in 48:
				var dx := (x - cx) / 22.0
				var dy := (y - cy) / 18.0
				var d := sqrt(dx * dx + dy * dy)
				if d > 1.0:
					continue
				var ang := atan2(dy, dx)
				var swirl := sin(ang * 3.0 + d * 9.0 + float(phase) * PI)
				var c: Color
				if d > 0.86:
					c = Color(1, 1, 1, 0.95)
				elif swirl > 0.45:
					c = Color(1, 1, 1, 0.8)
				elif swirl < -0.6:
					c = Color(0.85, 0.85, 0.85, 0.55)
				else:
					c = Color(1, 1, 1, 0.28)
				_px(im, x, y, c)
		_save(im, "obstacles/portal_%d.png" % phase)


func _gen_seesaw() -> void:
	# Plank 160x12 wood + metal caps, pivot 12x14 stone wedge.
	var im := _make(160, 12)
	var wood := Color("8a5a2a")
	var wood_d := Color("6e4520")
	var wood_l := Color("a5723a")
	var metal := Color("9aa2ac")
	for y in 12:
		for x in 160:
			var c := wood
			if y == 0 or y == 11:
				c = wood_d
			elif y == 1:
				c = wood_l
			elif x % 20 == 10:
				c = wood_d
			elif _noise(x, y, 22) > 0.92:
				c = wood_l
			_px(im, x, y, c)
	_rect(im, 0, 0, 3, 12, metal)
	_rect(im, 157, 0, 3, 12, metal)
	_save(im, "obstacles/plank.png")

	var pv := _make(12, 14)
	var stone := Color("6e6e78")
	var stone_d := Color("4e4e58")
	for y in 14:
		var w := 2 + y * 10 / 14
		for x in 12:
			if absi(x - 6) <= w / 2:
				_px(pv, x, y, stone if x != 6 - w / 2 and x != 6 + w / 2 else stone_d)
	_save(pv, "obstacles/pivot.png")


# ------------------------------------------------------------ collectibles ---

const SKULL_MAP := [
	"....XXXXXXXX....",
	"..XXWWWWWWWWXX..",
	".XWWWWWWWWWWWWX.",
	".XWWWWWWWWWWWWX.",
	"XWWWWWWWWWWWWWWX",
	"XWWEEWWWWWWEEWWX",
	"XWWEPWWWWWWEPWWX",
	"XWWEEWWWWWWEEWWX",
	"XWWWWWWNNWWWWWWX",
	".XWWWWWNNWWWWWX.",
	".XXWWWWWWWWWWXX.",
	"...XWTWTWTWTX...",
	"...XWTWTWTWTX...",
	"....XXXXXXXX....",
	"................",
	"................",
]
const SKULL_LEGEND := {
	"X": Color("2a2438"), "W": Color("f0ece0"), "E": Color("1a1426"),
	"P": Color("9b30ff"), "N": Color("c8c0ae"), "T": Color("d8d2c2"),
}

const HALO_MAP := [
	"................",
	"................",
	"....GGGGGGGG....",
	"..GGYYYYYYYYGG..",
	".GYYSSYYYYYYYYG.",
	".GYSYYYYYYYYYYG.",
	".GYYYYYYYYYYYYG.",
	"..GGYYYYYYYYGG..",
	"....GGGGGGGG....",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]
const HALO_LEGEND := {
	"G": Color("b58a24"), "Y": Color("ffd94a"), "S": Color("fff2b8"),
}


func _gen_collectibles() -> void:
	# 16x16 skull (Reaper's currency) and halo (Guardian's currency).
	var skull := _make(16, 16)
	_map(skull, SKULL_MAP, SKULL_LEGEND)
	_save(skull, "collectibles/skull.png")

	var halo := _make(16, 16)
	_map(halo, HALO_MAP, HALO_LEGEND)
	_save(halo, "collectibles/halo.png")


# --------------------------------------------------------------------- ui ---

func _gen_gems() -> void:
	# 28x28 hex gem (regular levels) + 36x36 diamond (arm-end milestones).
	# Drawn near-white; the map tints them per zone via modulate.
	var im := _make(28, 28)
	var base := Color("d8d8e0")
	var lightc := Color("f8f8fc")
	var dark := Color("a8a8b4")
	var edge := Color("64646e")
	for y in 28:
		for x in 28:
			var inside := absf(x - 13.5) / 12.5 + absf(y - 13.5) / 12.5 * 0.72 <= 1.0
			if not inside:
				continue
			var c := base
			if x + y < 20:
				c = lightc
			elif x + y > 34:
				c = dark
			_px(im, x, y, c)
	for y in 28:
		for x in 28:
			var inside := absf(x - 13.5) / 12.5 + absf(y - 13.5) / 12.5 * 0.72 <= 1.0
			var edge_out := absf(x - 13.5) / 12.5 + absf(y - 13.5) / 12.5 * 0.72 > 0.86
			if inside and edge_out:
				_px(im, x, y, edge)
	_rect(im, 8, 7, 3, 2, Color(1, 1, 1, 0.9))
	_save(im, "ui/gem.png")

	var big := _make(36, 36)
	for y in 36:
		for x in 36:
			var inside := absf(x - 17.5) / 16.5 + absf(y - 17.5) / 16.5 <= 1.0
			if not inside:
				continue
			var c := base
			if y < 14:
				c = lightc if x < 22 else base
			elif x + y > 44:
				c = dark
			var edge_out := absf(x - 17.5) / 16.5 + absf(y - 17.5) / 16.5 > 0.88
			if edge_out:
				c = edge
			_px(big, x, y, c)
	_rect(big, 11, 8, 4, 2, Color(1, 1, 1, 0.9))
	_save(big, "ui/gem_big.png")


func _gen_map_bg() -> void:
	# 1280x720 world-map canvas background: three horizontal bands with wavy
	# borders (Heaven ~top 30%, Earth+grass in the middle, Hell at the bottom),
	# matching the hand-drawn map design. PLACEHOLDER — the final art will be a
	# custom image with the same size and band split; drop it over this file.
	var w := 1280
	var h := 720
	var im := _make(w, h)
	var sky_top := Color("f8f2da")
	var sky_bot := Color("cfe0f2")
	var grass := Color("5f9c46")
	var earth_c := Color("6b4a2a")
	var earth_d := Color("4c3018")
	var hell_g := Color("7a2410")
	var hell_c := Color("2a0c08")
	for x in w:
		# wavy band borders like the sketch
		var border1 := 250.0 + 18.0 * sin(x * 0.012) + 8.0 * sin(x * 0.031 + 2.0)
		var border2 := 505.0 + 16.0 * sin(x * 0.010 + 4.0) + 7.0 * sin(x * 0.027)
		for y in h:
			var c: Color
			if y < border1:
				c = sky_top.lerp(sky_bot, y / border1)
			elif y < border1 + 14.0:
				c = grass   # grassy rim where Earth meets the sky
			elif y < border2:
				var t := (y - border1) / (border2 - border1)
				c = earth_c.lerp(earth_d, t)
			elif y < border2 + 10.0:
				c = hell_g  # glowing rim where Hell begins
			else:
				var t2 := (y - border2) / (h - border2)
				c = hell_g.lerp(hell_c, t2)
			var n := (_noise(x, y, 23) - 0.5) * 0.05
			_px(im, x, y, Color(c.r + n, c.g + n, c.b + n))
	# clouds in the heaven band
	for i in 9:
		var cx := 40 + int(_noise(i, 0, 24) * 1200.0)
		var cy := 30 + int(_noise(i, 1, 24) * 150.0)
		for dy in range(-7, 8):
			for dx in range(-26, 27):
				if dx * dx / 676.0 + dy * dy / 49.0 <= 1.0:
					_px(im, cx + dx, cy + dy, Color(1, 1, 1, 0.5))
	# embers in the hell band
	for i in 70:
		var ex := int(_noise(i, 2, 25) * 1280.0)
		var ey := 540 + int(_noise(i, 3, 25) * 175.0)
		_px(im, ex, ey, Color(1.0, 0.55, 0.2, 0.8))
	_save(im, "ui/map_bg.png")


# 12x12 zone motifs stamped in the middle of the round map nodes.
const MOTIF_LEAF := [
	"........X...",
	".......XX...",
	"..X...XLX...",
	"..XX.XLLX...",
	"..XLXLLLX...",
	"..XLLLLX....",
	"..XLLLLX....",
	".XLLLLX.....",
	".XLLLX......",
	".XLLX.......",
	".XXX........",
	"............",
]
const MOTIF_CLOUD := [
	"............",
	"............",
	"....XXX.....",
	"...XLLLX....",
	"..XLLLLLXX..",
	".XLLLLLLLLX.",
	"XLLLLLLLLLLX",
	"XLLLLLLLLLLX",
	".XXXXXXXXXX.",
	"............",
	"............",
	"............",
]
const MOTIF_FLAME := [
	".....X......",
	".....XX.....",
	"....XLX.....",
	"....XLLX....",
	"...XLLLX....",
	"...XLLLLX...",
	"..XLLYLLX...",
	"..XLYYYLX...",
	"..XLYYYLLX..",
	"...XLYYLX...",
	"....XLLX....",
	".....XX.....",
]


const LOCK_MAP := [
	"....XXXX....",
	"...XX..XX...",
	"...X....X...",
	"...X....X...",
	"..XXXXXXXX..",
	"..XWWWWWWX..",
	"..XWWKKWWX..",
	"..XWWKKWWX..",
	"..XWWWKWWX..",
	"..XWWWWWWX..",
	"..XXXXXXXX..",
]
const LOCK_LEGEND := {
	"X": Color("14121a"), "W": Color("e8e4da"), "K": Color("14121a"),
}


func _gen_lock() -> void:
	# 12x11 padlock stamped on locked level bubbles.
	var im := _make(12, 11)
	_map(im, LOCK_MAP, LOCK_LEGEND)
	_save(im, "ui/lock.png")


func _gen_map_nodes() -> void:
	# 30x30 round level nodes, one per zone (like the circled numbers on the
	# sketch): coloured disc + dark rim + zone motif. States (locked/unlocked/
	# completed/planned) are tinted at runtime via modulate.
	var defs := [
		["node_earth", Color("6fbf4e"), Color("3d7a2a"), MOTIF_LEAF, Color("2e5c1f"), Color("9fe07f")],
		["node_heaven", Color("f5e3a8"), Color("c2a44e"), MOTIF_CLOUD, Color("a8863c"), Color("fffbe8")],
		["node_hell", Color("d84a2a"), Color("7a1e10"), MOTIF_FLAME, Color("5c150a"), Color("ffb44a")],
	]
	for def in defs:
		var im := _make(30, 30)
		var base: Color = def[1]
		var rim: Color = def[2]
		for y in 30:
			for x in 30:
				var dx := x - 14.5
				var dy := y - 14.5
				var d := sqrt(dx * dx + dy * dy)
				if d > 14.5:
					continue
				var c := base
				if d > 12.8:
					c = rim
				elif dx + dy < -9.0:
					c = base.lightened(0.25)   # top-left sheen
				elif dx + dy > 11.0:
					c = base.darkened(0.18)
				_px(im, x, y, c)
		_map(im, def[3], {"X": def[4], "L": def[5], "Y": Color("fff0a0")}, 9, 9)
		_save(im, "ui/%s.png" % def[0])


# ------------------------------------------------------------ backgrounds ---

func _gen_zone_backgrounds() -> void:
	# 320x180 parallax-style backdrops, stretched to the level size in scenes.
	# Earth: morning sky over rolling hills.
	var im := _make(320, 180)
	var top := Color("9ec8ea")
	var horizon := Color("d8ecc8")
	var hill1 := Color("6aa050")
	var hill2 := Color("4f8140")
	for y in 180:
		var t := float(y) / 179.0
		for x in 320:
			_px(im, x, y, top.lerp(horizon, t))
	for x in 320:
		var h1 := 120 + int(18.0 * sin(x * 0.030) + 8.0 * sin(x * 0.011 + 2.0))
		var h2 := 140 + int(14.0 * sin(x * 0.022 + 4.0))
		for y in range(h1, 180):
			_px(im, x, y, hill1)
		for y in range(h2, 180):
			_px(im, x, y, hill2)
	for i in 5:
		var cxx := 30 + i * 65 + int(_noise(i, 0, 26) * 30.0)
		var cyy := 22 + int(_noise(i, 1, 26) * 34.0)
		for dy in range(-4, 5):
			for dx in range(-12, 13):
				if dx * dx / 144.0 + dy * dy / 16.0 <= 1.0:
					_px(im, cxx + dx, cyy + dy, Color(1, 1, 1, 0.85))
	_save(im, "bg/earth_bg.png")

	# Heaven: golden-white glow with cloud bands.
	im = _make(320, 180)
	var htop := Color("fdf6df")
	var hbot := Color("cfe0f2")
	for y in 180:
		var t := float(y) / 179.0
		for x in 320:
			var c := htop.lerp(hbot, t)
			_px(im, x, y, c)
	# sun glow top center
	for y in 70:
		for x in 320:
			var d := sqrt(pow((x - 160.0) / 90.0, 2.0) + pow((y - 6.0) / 55.0, 2.0))
			if d < 1.0:
				var g := Color(1.0, 0.95, 0.75, (1.0 - d) * 0.8)
				var base := im.get_pixel(x, y)
				_px(im, x, y, base.blend(g))
	for band in 4:
		var by := 55 + band * 32
		for x in 320:
			var wob := int(5.0 * sin(x * 0.05 + band * 1.7))
			for dy in 6:
				if _noise(x, band * 10 + dy, 27) > 0.25:
					_px(im, x, by + wob + dy, Color(1, 1, 1, 0.55))
	_save(im, "bg/heaven_bg.png")

	# Hell: black-red cavern with magma glow rising from below.
	im = _make(320, 180)
	var ht := Color("1a0a10")
	var hm := Color("4a1410")
	var hb := Color("8a2c10")
	for y in 180:
		var t := float(y) / 179.0
		for x in 320:
			var c := ht.lerp(hm, t) if t < 0.7 else hm.lerp(hb, (t - 0.7) / 0.3)
			var n := (_noise(x, y, 28) - 0.5) * 0.05
			_px(im, x, y, Color(c.r + n, c.g + n * 0.5, c.b))
	# stalactites
	for i in 12:
		var sx := 10 + i * 26 + int(_noise(i, 0, 29) * 14.0)
		var slen := 12 + int(_noise(i, 1, 29) * 22.0)
		for dy in slen:
			var w := (slen - dy) * 3 / slen
			for dx in range(-w, w + 1):
				_px(im, sx + dx, dy, Color("120608"))
	# embers
	for i in 50:
		var exx := int(_noise(i, 2, 30) * 320.0)
		var eyy := 90 + int(_noise(i, 3, 30) * 90.0)
		_px(im, exx, eyy, Color(1.0, 0.6, 0.2, 0.6 + 0.4 * _noise(i, 4, 30)))
	_save(im, "bg/hell_bg.png")


# ------------------------------------------------------------------- main ---

func _init() -> void:
	print("Generating pixel-art assets → %s" % OUT)
	_gen_characters()
	_gen_tiles()
	_gen_door()
	_gen_lever()
	_gen_panel()
	_gen_portal()
	_gen_seesaw()
	_gen_collectibles()
	_gen_gems()
	_gen_map_bg()
	_gen_map_nodes()
	_gen_lock()
	_gen_zone_backgrounds()
	print("Done.")
	quit()
