# Slices the user's "drzwi, dzwignie" sheet (assets/sprites/) into game-ready
# animation strips: the 4 portcullis frames and the 4 lever frames. Removes the
# white background (including the door opening, so the level shows through),
# aligns every frame on a common box so the stone frame never jitters, and
# writes horizontal sprite sheets.
# Run: godot --headless -s res://tools/slice_doors.gd
extends SceneTree

const SRC := "res://assets/sprites/drzwi, dzwignie.png"

# Content bands on the 1536x1024 sheet (chosen to skip the title/number text).
const DOOR_BAND := Vector2i(195, 585)
const LEVER_BAND := Vector2i(755, 990)

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
	_slice_row(img, LEVER_BAND, "res://assets/sprites/doors/lever_frames.png", LEVER_FRAME_H)
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
