# Turns the user's hand-drawn terrain sheet into a tidy autotile atlas.
#
# The source is not a neat grid — the artist drew example islands and platforms,
# so the useful tiles sit scattered across 18x13 cells with a lot of empty ones.
# Each drawn cell's ROLE is readable from its neighbours inside the shape it was
# drawn in: a cell with nothing above but filled below/left/right is a top edge,
# a cell with nothing above and nothing left is a top-left corner, and so on.
#
# That gives the classic 16-piece "match sides" set (4 neighbours -> 16 combos),
# which is exactly what Godot's terrain autotiling wants. The tiles are copied
# into a fixed 4x4 atlas indexed by that bitmask, so build_terrain_tileset.gd
# can wire the peering bits without any hand-tuning.
# Run: godot --headless -s res://tools/slice_terrain.gd
extends SceneTree

const SRC := "res://assets/sprites/earth_tileset_src.png"
const DST := "res://assets/tilesets/earth/earth_terrain.png"
const TILE := 32
# A cell counts as drawn above this fraction of opaque pixels. Grass overhangs
# into the cell above, so this sits well clear of a few stray pixels.
const OCCUPIED_MIN := 0.20

# Neighbour bits: the atlas is indexed by these so the mask IS the tile index.
const N := 1
const E := 2
const S := 4
const W := 8


func _init() -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(SRC))
	if img == null:
		push_error("cannot load " + SRC)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	var cols := img.get_width() / TILE
	var rows := img.get_height() / TILE

	# --- which cells are drawn, and how solid each one is ---
	var fill := []
	for ty in rows:
		var line := []
		for tx in cols:
			line.append(_opacity(img, tx, ty))
		fill.append(line)

	# --- pick one representative cell per neighbour signature ---
	var best := {}          # mask -> {pos, score}
	for ty in rows:
		for tx in cols:
			if fill[ty][tx] < OCCUPIED_MIN:
				continue
			var mask := 0
			if _drawn(fill, tx, ty - 1, rows, cols):
				mask |= N
			if _drawn(fill, tx + 1, ty, rows, cols):
				mask |= E
			if _drawn(fill, tx, ty + 1, rows, cols):
				mask |= S
			if _drawn(fill, tx - 1, ty, rows, cols):
				mask |= W
			# Prefer samples taken deep inside the shape. The artist paints a dark
			# shadow under the grass line, so a cell picked from the row right
			# below a grass top drags that stripe into the tile — an interior
			# tile would then show a black bar across every wall. Depth wins over
			# raw coverage; for roles that are open upwards depth is always 0, so
			# they fall back to coverage as before.
			var depth := 0
			while _drawn(fill, tx, ty - depth - 1, rows, cols) and depth < 4:
				depth += 1
			var score: float = float(depth) + fill[ty][tx]
			# The sheet holds two variants of every surface: grassy tops and bare
			# dirt for island undersides. A tile with open sky above has to be the
			# grassy one (bare dirt is the more solid of the two, so on coverage
			# alone it would always win); a tile with something stacked on top has
			# to be the bare one, or tufts sprout inside the rock.
			var grass := _greenness(img, tx, ty)
			score += (-10.0 if (mask & N) != 0 else 10.0) * grass
			if not best.has(mask) or score > best[mask].score:
				best[mask] = {"pos": Vector2i(tx, ty), "score": score}

	# --- report, then compose the 4x4 atlas indexed by mask ---
	var atlas := Image.create(TILE * 4, TILE * 4, false, Image.FORMAT_RGBA8)
	var missing := []
	for mask in 16:
		var cell := Vector2i(mask % 4, mask / 4)
		if not best.has(mask):
			missing.append(mask)
			continue
		var src: Vector2i = best[mask].pos
		atlas.blit_rect(img, Rect2i(src * TILE, Vector2i(TILE, TILE)), cell * TILE)
		print("  %-22s <- source cell %s" % [_role_name(mask), src])

	# The artist drew no one-tile-thin pieces, so the thin roles (a lone block,
	# a 1-tile column, a 1-tile bar) have no example. Each quadrant of a tile
	# only depends on the two sides touching it, so they are assembled from the
	# quadrants of the nine solid roles, which all do exist.
	for mask in missing:
		_assemble(atlas, img, best, mask)
		print("  %-22s <- assembled from quadrants" % _role_name(mask))

	var abs_dst := ProjectSettings.globalize_path(DST)
	DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
	atlas.save_png(abs_dst)
	print("  saved ", DST, " (", atlas.get_width(), "x", atlas.get_height(), ")")
	_write_proof(atlas)
	quit()


# Renders a sample layout — a wide ledge, a lone block, a column and a thin bar —
# by running the same neighbour logic a TileMap would. If the seams line up here
# they line up in game.
func _write_proof(atlas: Image) -> void:
	var plan := [
		"..........",
		"..####....",
		"..........",
		".#...#..##",
		".....#....",
		"#####...##",
		"#####.....",
	]
	var h := plan.size()
	var w: int = (plan[0] as String).length()
	var out := Image.create(w * TILE, h * TILE, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			if (plan[y] as String)[x] != "#":
				continue
			var mask := 0
			if _plan_at(plan, x, y - 1):
				mask |= N
			if _plan_at(plan, x + 1, y):
				mask |= E
			if _plan_at(plan, x, y + 1):
				mask |= S
			if _plan_at(plan, x - 1, y):
				mask |= W
			var cell := Vector2i(mask % 4, mask / 4)
			out.blit_rect(atlas, Rect2i(cell * TILE, Vector2i(TILE, TILE)),
				Vector2i(x, y) * TILE)
	out.save_png(ProjectSettings.globalize_path("res://_terrain_proof.png"))
	print("  wrote res://_terrain_proof.png (visual seam check)")


func _plan_at(plan: Array, x: int, y: int) -> bool:
	if y < 0 or y >= plan.size():
		return false
	var row: String = plan[y]
	if x < 0 or x >= row.length():
		return false
	return row[x] == "#"


# Builds one missing tile quadrant by quadrant. A quadrant is decided purely by
# the two sides that touch it: with both neighbours present it is interior, with
# one it is that edge, with neither it is the corner. Each is copied from the
# role that already shows that exact situation, so the seams line up.
func _assemble(atlas: Image, img: Image, best: Dictionary, mask: int) -> void:
	var half := TILE / 2
	var quads := [
		# [offset in tile, vertical side, horizontal side, edge-role when only
		#  the vertical side is present, edge-role when only the horizontal one
		#  is, corner-role when neither is]
		[Vector2i(0, 0), N, W, N | S | W, E | S | W, E | S],           # top-left
		[Vector2i(half, 0), N, E, N | S | E, E | S | W, S | W],        # top-right
		[Vector2i(0, half), S, W, N | S | W, N | E | W, N | E],        # bottom-left
		[Vector2i(half, half), S, E, N | S | E, N | E | W, N | W],     # bottom-right
	]
	var cell := Vector2i(mask % 4, mask / 4)
	for q in quads:
		var offset: Vector2i = q[0]
		var has_v: bool = (mask & int(q[1])) != 0
		var has_h: bool = (mask & int(q[2])) != 0
		var role: int
		if has_v and has_h:
			role = N | E | S | W          # interior
		elif has_v:
			role = q[3]
		elif has_h:
			role = q[4]
		else:
			role = q[5]
		if not best.has(role):
			push_warning("slice_terrain: no source for role %s" % _role_name(role))
			continue
		var src: Vector2i = best[role].pos
		atlas.blit_rect(img,
			Rect2i(src * TILE + offset, Vector2i(half, half)),
			cell * TILE + offset)


# Fraction of green (grass) pixels in the upper third of a cell.
func _greenness(img: Image, tx: int, ty: int) -> float:
	var green := 0
	var total := 0
	for y in TILE / 3:
		for x in TILE:
			var c := img.get_pixel(tx * TILE + x, ty * TILE + y)
			total += 1
			if c.a > 0.5 and c.g > c.r + 0.08 and c.g > c.b + 0.08:
				green += 1
	return float(green) / float(total)


# Fraction of opaque pixels in a cell.
func _opacity(img: Image, tx: int, ty: int) -> float:
	var count := 0
	for y in TILE:
		for x in TILE:
			if img.get_pixel(tx * TILE + x, ty * TILE + y).a > 0.5:
				count += 1
	return float(count) / float(TILE * TILE)


# Whether a neighbour cell is part of a drawn shape (outside = not drawn).
func _drawn(fill: Array, tx: int, ty: int, rows: int, cols: int) -> bool:
	if tx < 0 or ty < 0 or tx >= cols or ty >= rows:
		return false
	return fill[ty][tx] >= OCCUPIED_MIN


# Human-readable role for a neighbour mask, for the console report.
func _role_name(mask: int) -> String:
	match mask:
		0: return "single"
		N: return "bottom_cap"
		E: return "left_cap"
		N | E: return "corner_bottom_left"
		S: return "top_cap"
		N | S: return "vertical_middle"
		E | S: return "corner_top_left"
		N | E | S: return "edge_left"
		W: return "right_cap"
		N | W: return "corner_bottom_right"
		E | W: return "horizontal_middle"
		N | E | W: return "edge_bottom"
		S | W: return "corner_top_right"
		N | S | W: return "edge_right"
		E | S | W: return "edge_top"
		_: return "fill"
