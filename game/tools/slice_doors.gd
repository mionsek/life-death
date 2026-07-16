# Slices the user's "drzwi, dzwignie" sheet (assets/sprites/) into game-ready
# animation strips: the 4 portcullis frames and the 4 lever frames. Removes the
# white background (including the door opening, so the level shows through),
# aligns every frame on a common box so the stone frame never jitters, and
# writes horizontal sprite sheets.
# Run: godot --headless -s res://tools/slice_doors.gd
extends SceneTree

const SRC := "res://assets/sprites/drzwi, dzwignie.png"
# Dedicated 4-frame lever sheet (handle sweeps left -> right).
const SRC_LEVER := "res://assets/sprites/dzwignie.png"

# Content band for the doors on the combined 1536x1024 sheet (skips the text).
const DOOR_BAND := Vector2i(195, 585)

# Pixels this close to white (min channel) become transparent; soft edge below.
const WHITE_HI := 0.80
const WHITE_LO := 0.66

const DOOR_FRAME_H := 112     # target height per door frame (px)
const LEVER_FRAME_H := 48     # target height per lever frame (px)


func _init() -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(SRC))
	if img == null:
		push_error("cannot load " + SRC)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	_knock_out_white(img)
	_slice_row(img, DOOR_BAND, "res://assets/sprites/doors/door_frames.png", DOOR_FRAME_H)
	_slice_door_layers(img, DOOR_BAND, DOOR_FRAME_H)

	# Levers come from their own clean 4-frame sheet. They are split into equal
	# quarters (not tight-cropped per frame) so the base stays fixed while the
	# handle sweeps — a per-frame crop would recentre and make the base jitter.
	var lever := Image.load_from_file(ProjectSettings.globalize_path(SRC_LEVER))
	if lever == null:
		push_error("cannot load " + SRC_LEVER)
		quit(1)
		return
	lever.convert(Image.FORMAT_RGBA8)
	_knock_out_white(lever)
	_slice_even(lever, 4, "res://assets/sprites/doors/lever_frames.png", LEVER_FRAME_H)
	quit()


# White background -> transparent, with a soft edge so cut lines stay clean.
func _knock_out_white(img: Image) -> void:
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			var m: float = minf(c.r, minf(c.g, c.b))
			if m >= WHITE_HI:
				c.a = 0.0
			elif m > WHITE_LO:
				c.a = (WHITE_HI - m) / (WHITE_HI - WHITE_LO)
			img.set_pixel(x, y, c)


# Splits a clean sheet into `count` equal-width cells and stacks them into a
# horizontal strip, sharing one vertical crop (union of all content) so every
# frame keeps its horizontal position — the base stays put, the handle sweeps.
func _slice_even(img: Image, count: int, dst: String, frame_h: int) -> void:
	var used := img.get_used_rect()
	if used.size.y <= 0:
		push_warning("slice_doors: empty lever sheet")
		return
	var cell_w := img.get_width() / count
	var sheet := Image.create(cell_w * count, used.size.y, false, Image.FORMAT_RGBA8)
	for i in count:
		var region := img.get_region(Rect2i(i * cell_w, used.position.y, cell_w, used.size.y))
		sheet.blit_rect(region, Rect2i(0, 0, cell_w, used.size.y), Vector2i(i * cell_w, 0))
	var scale := float(frame_h) / float(used.size.y)
	var frame_w := int(round(cell_w * scale))
	sheet.resize(frame_w * count, frame_h, Image.INTERPOLATE_LANCZOS)
	var abs_dst := ProjectSettings.globalize_path(dst)
	DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
	sheet.save_png(abs_dst)
	print("  sliced ", dst, " (", sheet.get_width(), "x", sheet.get_height(),
		", ", count, " frames)")


# Splits the door art into separately-animated layers so the gate can slide
# smoothly and the character can pass through the doorway (in front of the left
# jamb, behind the right one). All layers share the same canvas size and origin,
# so the scene just stacks them at one position:
#   door_back  = left jamb        (drawn behind the character)
#   door_front = right jamb + lintel, light socket darkened (drawn in front)
#   door_light = the indicator light, greyscale (tinted red/green at runtime)
#   door_gate  = the red portcullis curtain (slides up via shader)
func _slice_door_layers(img: Image, band: Vector2i, target_h: int) -> void:
	var cells := _find_columns(img, band)
	if cells.size() < 4:
		push_warning("slice_doors: need 4 door frames for layers, got %d" % cells.size())
		return
	var closed := _cell_image(img, band, cells[0])
	var opened := _cell_image(img, band, cells[3])
	var w := maxi(closed.get_width(), opened.get_width())
	var h := maxi(closed.get_height(), opened.get_height())
	closed = _place(closed, w, h)
	opened = _place(opened, w, h)

	var cx := w / 2
	# Skip transparent top padding to the lintel top, then find where the centre
	# opens up (lintel bottom = start of the doorway opening).
	var lintel_top := 0
	while lintel_top < h and opened.get_pixel(cx, lintel_top).a < 0.3:
		lintel_top += 1
	var lintel_bottom := lintel_top
	while lintel_bottom < h and opened.get_pixel(cx, lintel_bottom).a >= 0.3:
		lintel_bottom += 1
	# inner edges of the two pillars, sampled across the opening
	var my := (lintel_bottom + h) / 2
	var runs := _opaque_runs(opened, my)
	if runs.is_empty():
		push_warning("slice_doors: could not read door pillars")
		return
	var x1: int = runs[0].y            # inner edge of the left pillar
	var x2: int = runs[runs.size() - 1].x   # inner edge of the right pillar
	# light bounding box: bright pixels in the top-right of the lintel
	var light_rect := _light_bbox(opened, cx, lintel_bottom)

	# --- build the four same-size layers ---
	var back := Image.create(w, h, false, Image.FORMAT_RGBA8)
	back.blit_rect(opened, Rect2i(0, 0, x1, h), Vector2i(0, 0))

	var front := Image.create(w, h, false, Image.FORMAT_RGBA8)
	front.blit_rect(opened, Rect2i(x1, 0, w - x1, h), Vector2i(x1, 0))
	var socket := opened.get_pixel(cx, (lintel_top + lintel_bottom) / 2)   # dark lintel colour
	for y in range(light_rect.position.y, light_rect.end.y):
		for x in range(light_rect.position.x, light_rect.end.x):
			if front.get_pixel(x, y).a > 0.0:
				front.set_pixel(x, y, socket)

	var light := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in range(light_rect.position.y, light_rect.end.y):
		for x in range(light_rect.position.x, light_rect.end.x):
			var c := opened.get_pixel(x, y)
			if c.a > 0.3:
				var lum: float = maxf(c.r, maxf(c.g, c.b))
				light.set_pixel(x, y, Color(lum, lum, lum, c.a))

	var gate := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in range(lintel_bottom, h):
		for x in range(x1, x2):
			var c := closed.get_pixel(x, y)
			if c.a > 0.3:
				gate.set_pixel(x, y, c)

	var out := "res://assets/sprites/doors/"
	_save_scaled(back, target_h, out + "door_back.png")
	_save_scaled(front, target_h, out + "door_front.png")
	_save_scaled(light, target_h, out + "door_light.png")
	_save_scaled(gate, target_h, out + "door_gate.png")
	print("  door layers: size %dx%d, lintel_bottom=%.3f, opening x[%d..%d]"
		% [w, h, float(lintel_bottom) / float(h), x1, x2])


# Crops one detected cell to its tight content box.
func _cell_image(img: Image, band: Vector2i, cell: Vector2i) -> Image:
	var region := img.get_region(Rect2i(cell.x, band.x, cell.y - cell.x, band.y - band.x))
	var used := region.get_used_rect()
	if used.size.x > 0 and used.size.y > 0:
		region = region.get_region(used)
	return region


# Places a cell bottom-centred on a w x h transparent canvas (shared alignment).
func _place(cell: Image, w: int, h: int) -> Image:
	var canvas := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var ox := (w - cell.get_width()) / 2
	var oy := h - cell.get_height()
	canvas.blit_rect(cell, Rect2i(0, 0, cell.get_width(), cell.get_height()), Vector2i(ox, oy))
	return canvas


# Opaque horizontal runs on row y, as Vector2i(start_x, end_x).
func _opaque_runs(img: Image, y: int) -> Array:
	var runs := []
	var start := -1
	for x in img.get_width():
		var solid := img.get_pixel(x, y).a > 0.3
		if solid and start == -1:
			start = x
		elif not solid and start != -1:
			runs.append(Vector2i(start, x))
			start = -1
	if start != -1:
		runs.append(Vector2i(start, img.get_width()))
	return runs


# Bounding box of the bright indicator light in the top-right of the lintel.
func _light_bbox(img: Image, cx: int, lintel_bottom: int) -> Rect2i:
	var minx := img.get_width()
	var miny := lintel_bottom
	var maxx := 0
	var maxy := 0
	var found := false
	for y in lintel_bottom:
		for x in range(cx, img.get_width()):
			var c := img.get_pixel(x, y)
			if c.a > 0.3 and maxf(c.r, maxf(c.g, c.b)) > 0.45:
				found = true
				minx = mini(minx, x); miny = mini(miny, y)
				maxx = maxi(maxx, x); maxy = maxi(maxy, y)
	if not found:
		return Rect2i(0, 0, 0, 0)
	return Rect2i(minx, miny, maxx - minx + 1, maxy - miny + 1)


# Scales an image to target_h (keeping aspect) and saves it.
func _save_scaled(img: Image, target_h: int, dst: String) -> void:
	var scale := float(target_h) / float(img.get_height())
	img.resize(int(round(img.get_width() * scale)), target_h, Image.INTERPOLATE_LANCZOS)
	var abs_dst := ProjectSettings.globalize_path(dst)
	DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
	img.save_png(abs_dst)
	print("  saved ", dst, " (", img.get_width(), "x", img.get_height(), ")")


# Detects the 4 content columns inside a y-band, crops each to a shared box and
# assembles a horizontal N-frame sheet scaled to frame_h.
func _slice_row(img: Image, band: Vector2i, dst: String, frame_h: int) -> void:
	var cells := _find_columns(img, band)
	if cells.size() != 4:
		push_warning("slice_doors: expected 4 columns in band %s, got %d" % [band, cells.size()])
	# Per-cell tight crop, then a common frame size (max extents) for alignment.
	var crops: Array[Image] = []
	var max_w := 0
	var max_h := 0
	for cell in cells:
		var region := img.get_region(Rect2i(cell.x, band.x, cell.y - cell.x, band.y - band.x))
		var used := region.get_used_rect()
		if used.size.x > 0 and used.size.y > 0:
			region = region.get_region(used)
		crops.append(region)
		max_w = maxi(max_w, region.get_width())
		max_h = maxi(max_h, region.get_height())
	# Compose onto equal cells (bottom-aligned: the stone base stays put).
	var sheet := Image.create(max_w * crops.size(), max_h, false, Image.FORMAT_RGBA8)
	for i in crops.size():
		var c: Image = crops[i]
		var ox := i * max_w + (max_w - c.get_width()) / 2
		var oy := max_h - c.get_height()
		sheet.blit_rect(c, Rect2i(0, 0, c.get_width(), c.get_height()), Vector2i(ox, oy))
	# Scale so each frame is frame_h tall; force the width to an exact multiple
	# of the frame count so Sprite2D.hframes cuts clean, equal cells.
	var scale := float(frame_h) / float(max_h)
	var frame_w := int(round(max_w * scale))
	sheet.resize(frame_w * crops.size(), frame_h, Image.INTERPOLATE_LANCZOS)
	var abs_dst := ProjectSettings.globalize_path(dst)
	DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
	sheet.save_png(abs_dst)
	print("  sliced ", dst, " (", sheet.get_width(), "x", sheet.get_height(),
		", ", crops.size(), " frames)")


# Splits a y-band into contiguous columns that contain ink (non-transparent),
# ignoring thin gaps. Returns an array of Vector2i(x_start, x_end).
func _find_columns(img: Image, band: Vector2i) -> Array:
	var w := img.get_width()
	var has_ink := PackedByteArray()
	has_ink.resize(w)
	for x in w:
		var count := 0
		for y in range(band.x, band.y):
			if img.get_pixel(x, y).a > 0.3:
				count += 1
		has_ink[x] = 1 if count > 3 else 0
	var cols := []
	var start := -1
	var gap := 0
	const MAX_GAP := 24    # bridge small internal gaps (e.g. door opening edges)
	const MIN_WIDTH := 40
	for x in w:
		if has_ink[x] == 1:
			if start == -1:
				start = x
			gap = 0
		elif start != -1:
			gap += 1
			if gap > MAX_GAP:
				if x - gap - start >= MIN_WIDTH:
					cols.append(Vector2i(start, x - gap))
				start = -1
				gap = 0
	if start != -1 and w - start >= MIN_WIDTH:
		cols.append(Vector2i(start, w))
	return cols
