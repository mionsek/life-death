# Slices the user's "button-on-off" sheet into the pressure plate's two states
# (up = unpressed, down = pressed).
#
# Unlike the door/lever sheets this one sits on a soft grey gradient with a
# coloured glow above each button, so a white/threshold cut does not work.
# Instead the background is flood-filled inward from the borders comparing each
# pixel to the one it spread from: that follows the smooth gradient and the
# glow, but stops dead at the button's crisp dark outline.
#
# Both states are written on one shared canvas, bottom-aligned and centred on
# the stone base, so swapping the sprites never shifts the plate — only the
# dome visibly sinks.
# Run: godot --headless -s res://tools/slice_button.gd
extends SceneTree

const SRC := "res://assets/sprites/button-on-off.png"
const OUT_DIR := "res://assets/sprites/buttons/"
# Per-step colour tolerance (0-255) when spreading through the background.
# Kept tight: the outline is anti-aliased, and a loose tolerance lets the fill
# walk down that ramp into the (also grey) stone base.
const FILL_TOL := 10
# The button's dark outline acts as a wall the fill may never cross. Without it
# the glow above the dome is a smooth bridge straight into the red cap.
const OUTLINE_MAX := 46
# Target height of the taller (unpressed) state, in game pixels.
const TARGET_H := 22


func _init() -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(SRC))
	if img == null:
		push_error("cannot load " + SRC)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	_cut_background(img)
	# The backdrop's dark vignette is darker than the outline threshold, so the
	# wall rule protected it from the fill. The buttons never touch the border,
	# so anything still reaching it is background.
	_clear_border_blobs(img)
	# Stray specks survive inside the glow; left in place they inflate the crop
	# box and squash the button when it is scaled to the target height.
	_remove_specks(img, 2000)
	_defringe(img, 3)

	var cells := _find_columns(img)
	if cells.size() != 2:
		push_error("slice_button: expected 2 buttons, found %d" % cells.size())
		quit(1)
		return

	# tight crop each state, then share one canvas so they line up
	var crops: Array[Image] = []
	var max_w := 0
	var max_h := 0
	for cell in cells:
		var region := img.get_region(Rect2i(cell.x, 0, cell.y - cell.x, img.get_height()))
		# Godot's get_used_rect() counts any alpha above zero, and the cut leaves
		# a few all-but-invisible pixels around the glow — enough to blow the box
		# up and squash the button on scaling. Measure solid pixels instead.
		var used := _solid_bbox(region, 0.5)
		if used.size.x > 0 and used.size.y > 0:
			region = region.get_region(used)
		crops.append(region)
		max_w = maxi(max_w, region.get_width())
		max_h = maxi(max_h, region.get_height())

	var scale := float(TARGET_H) / float(max_h)
	var names := ["button_up.png", "button_down.png"]
	for i in crops.size():
		var canvas := Image.create(max_w, max_h, false, Image.FORMAT_RGBA8)
		var c: Image = crops[i]
		# bottom-aligned + centred: the stone base stays put, the dome sinks
		canvas.blit_rect(c, Rect2i(0, 0, c.get_width(), c.get_height()),
			Vector2i((max_w - c.get_width()) / 2, max_h - c.get_height()))
		canvas.resize(int(round(max_w * scale)), TARGET_H, Image.INTERPOLATE_LANCZOS)
		var dst: String = OUT_DIR + names[i]
		var abs_dst := ProjectSettings.globalize_path(dst)
		DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
		canvas.save_png(abs_dst)
		print("  saved ", dst, " (", canvas.get_width(), "x", canvas.get_height(), ")")
	quit()


# Flood-fills the background inward from every border pixel. Each step compares
# against the pixel it spread from, so smooth gradients (grey backdrop, glow,
# drop shadow) are consumed while the button's hard outline blocks the fill.
func _cut_background(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	var bg := PackedByteArray()
	bg.resize(w * h)
	var stack := PackedInt32Array()
	for x in w:
		stack.append(x)
		stack.append((h - 1) * w + x)
	for y in h:
		stack.append(y * w)
		stack.append(y * w + w - 1)
	while stack.size() > 0:
		var idx := stack[stack.size() - 1]
		stack.remove_at(stack.size() - 1)
		if bg[idx] == 1:
			continue
		bg[idx] = 1
		var o := idx * 4
		var cr := data[o]
		var cg := data[o + 1]
		var cb := data[o + 2]
		var px := idx % w
		var py := idx / w
		for d in 4:
			var nx: int = px + [1, -1, 0, 0][d]
			var ny: int = py + [0, 0, 1, -1][d]
			if nx < 0 or ny < 0 or nx >= w or ny >= h:
				continue
			var nidx: int = ny * w + nx
			if bg[nidx] == 1:
				continue
			var no: int = nidx * 4
			var nr := int(data[no])
			var ng := int(data[no + 1])
			var nb := int(data[no + 2])
			if maxi(nr, maxi(ng, nb)) < OUTLINE_MAX:
				continue    # the button's outline — a wall
			if absi(nr - int(cr)) <= FILL_TOL \
					and absi(ng - int(cg)) <= FILL_TOL \
					and absi(nb - int(cb)) <= FILL_TOL:
				stack.append(nidx)
	for i in w * h:
		if bg[i] == 1:
			data[i * 4 + 3] = 0
	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)


# Bounding box of pixels at or above min_alpha (ignores near-invisible leftovers).
func _solid_bbox(img: Image, min_alpha: float) -> Rect2i:
	var minx := img.get_width()
	var miny := img.get_height()
	var maxx := -1
	var maxy := -1
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a < min_alpha:
				continue
			minx = mini(minx, x)
			miny = mini(miny, y)
			maxx = maxi(maxx, x)
			maxy = maxi(maxy, y)
	if maxx < 0:
		return Rect2i(0, 0, 0, 0)
	return Rect2i(minx, miny, maxx - minx + 1, maxy - miny + 1)


# Clears every still-opaque region that reaches the image border.
func _clear_border_blobs(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	var seen := PackedByteArray()
	seen.resize(w * h)
	var stack := PackedInt32Array()
	for x in w:
		stack.append(x)
		stack.append((h - 1) * w + x)
	for y in h:
		stack.append(y * w)
		stack.append(y * w + w - 1)
	while stack.size() > 0:
		var idx := stack[stack.size() - 1]
		stack.remove_at(stack.size() - 1)
		if seen[idx] == 1 or data[idx * 4 + 3] < 80:
			continue
		seen[idx] = 1
		data[idx * 4 + 3] = 0
		var px := idx % w
		var py := idx / w
		for d in 4:
			var nx: int = px + [1, -1, 0, 0][d]
			var ny: int = py + [0, 0, 1, -1][d]
			if nx < 0 or ny < 0 or nx >= w or ny >= h:
				continue
			stack.append(ny * w + nx)
	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)


# Clears opaque blobs smaller than min_area, leaving only the real buttons.
func _remove_specks(img: Image, min_area: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	var seen := PackedByteArray()
	seen.resize(w * h)
	for start in w * h:
		if seen[start] == 1 or data[start * 4 + 3] < 80:
			continue
		var blob := PackedInt32Array()
		var stack := PackedInt32Array([start])
		seen[start] = 1
		while stack.size() > 0:
			var idx := stack[stack.size() - 1]
			stack.remove_at(stack.size() - 1)
			blob.append(idx)
			var px := idx % w
			var py := idx / w
			for d in 4:
				var nx: int = px + [1, -1, 0, 0][d]
				var ny: int = py + [0, 0, 1, -1][d]
				if nx < 0 or ny < 0 or nx >= w or ny >= h:
					continue
				var nidx: int = ny * w + nx
				if seen[nidx] == 1 or data[nidx * 4 + 3] < 80:
					continue
				seen[nidx] = 1
				stack.append(nidx)
		if blob.size() < min_area:
			for idx in blob:
				data[idx * 4 + 3] = 0
	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)


# Bleeds opaque colours outward so the cut edges take the art's colour instead
# of the grey backdrop (otherwise they shimmer as a halo when the camera moves).
func _defringe(img: Image, passes: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for _p in passes:
		var src := img.duplicate() as Image
		for y in h:
			for x in w:
				var c := src.get_pixel(x, y)
				if c.a >= 0.9:
					continue
				var r := 0.0
				var g := 0.0
				var b := 0.0
				var n := 0.0
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var nx := x + dx
						var ny := y + dy
						if nx < 0 or ny < 0 or nx >= w or ny >= h:
							continue
						var nc := src.get_pixel(nx, ny)
						if nc.a >= 0.9:
							r += nc.r
							g += nc.g
							b += nc.b
							n += 1.0
				if n > 0.0:
					img.set_pixel(x, y, Color(r / n, g / n, b / n, c.a))


# Contiguous columns that contain opaque pixels, as Vector2i(x_start, x_end).
func _find_columns(img: Image) -> Array:
	var w := img.get_width()
	var has_ink := PackedByteArray()
	has_ink.resize(w)
	for x in w:
		for y in img.get_height():
			if img.get_pixel(x, y).a > 0.3:
				has_ink[x] = 1
				break
	var cols := []
	var start := -1
	var gap := 0
	const MAX_GAP := 24
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
