# Prepares the seesaw's two pieces for the mechanic that already exists: the
# wooden beam (rotates) and the stone mount (stays put).
#
# The sources are delivered as separate files with real transparency, so there
# is nothing to cut apart — the job is to trim, bring both to one scale, and
# work out where they join.
#
# They join at the mount's bolt: the beam turns about its own centre, so the
# bolt has to sit exactly there. The bolt is found as the round cap above the
# mount's neck (its narrowest row before the triangle flares out), and the
# printed offsets place both sprites with that point at the node origin.
# Run: godot --headless -s res://tools/slice_seesaw.gd
extends SceneTree

const SRC_BEAM := "res://assets/sprites/seesaw_beam_src.png"
const SRC_MOUNT := "res://assets/sprites/seesaw_mount_src.png"
const OUT_DIR := "res://assets/sprites/seesaw/"
# The beam collision is 160 wide, so match the art to it.
const TARGET_BEAM_W := 160


func _init() -> void:
	var beam := _load(SRC_BEAM)
	var mount := _load(SRC_MOUNT)
	if beam == null or mount == null:
		quit(1)
		return

	# Trim both to their content.
	beam = beam.get_region(_solid_bbox(beam))
	mount = mount.get_region(_solid_bbox(mount))

	# One scale for both, taken from the beam, so they keep their drawn
	# proportions relative to each other.
	var scale := float(TARGET_BEAM_W) / float(beam.get_width())
	_resize(beam, scale)
	_resize(mount, scale)

	var bolt := _bolt_centre(mount)
	# The beam turns about its own centre; the mount hangs from the bolt.
	var beam_off := -Vector2(beam.get_width(), beam.get_height()) / 2.0
	var mount_off := -bolt

	_save(beam, OUT_DIR + "seesaw_plank.png")
	_save(mount, OUT_DIR + "seesaw_base.png")
	print("  bolt centre in mount: (%.1f, %.1f)" % [bolt.x, bolt.y])
	print("  PlankVis: centered=false, offset = (%.1f, %.1f)" % [beam_off.x, beam_off.y])
	print("  Pivot:    centered=false, offset = (%.1f, %.1f)" % [mount_off.x, mount_off.y])
	quit()


# Centre of the mount's bolt: the cap above the neck, where the silhouette is
# at its narrowest before the triangle widens out.
func _bolt_centre(img: Image) -> Vector2:
	var w := img.get_width()
	var h := img.get_height()
	var widths := PackedInt32Array()
	widths.resize(h)
	for y in h:
		var count := 0
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				count += 1
		widths[y] = count
	# Scanning down, the silhouette widens to the bolt's diameter, pinches in at
	# the neck, then flares into the triangle. The bolt therefore runs from the
	# first opaque row down to that pinch, and its centre is halfway between —
	# taking the widest row instead lands on the bottom of the cap, which hangs
	# the beam too low.
	var top := 0
	while top < h and widths[top] == 0:
		top += 1
	var maxw := 0
	var neck := h - 1
	for y in range(top, h):
		if widths[y] > maxw:
			maxw = widths[y]
		elif widths[y] < maxw - 1:
			neck = y
			break
	var mid_y := int((top + neck) / 2.0)
	# Centre of the opaque span across the bolt.
	var x0 := w
	var x1 := -1
	for y in range(top, neck + 1):
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				x0 = mini(x0, x)
				x1 = maxi(x1, x)
	if x1 < 0:
		return Vector2(w / 2.0, 0.0)
	return Vector2((x0 + x1) / 2.0, float(mid_y))


func _load(path: String) -> Image:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null:
		push_error("cannot load " + path)
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img


func _resize(img: Image, scale: float) -> void:
	img.resize(maxi(int(round(img.get_width() * scale)), 1),
		maxi(int(round(img.get_height() * scale)), 1), Image.INTERPOLATE_LANCZOS)


func _save(img: Image, dst: String) -> void:
	var abs_dst := ProjectSettings.globalize_path(dst)
	DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
	img.save_png(abs_dst)
	print("  saved ", dst, " (", img.get_width(), "x", img.get_height(), ")")


# Bounding box of solid pixels.
func _solid_bbox(img: Image) -> Rect2i:
	var minx := img.get_width()
	var miny := img.get_height()
	var maxx := -1
	var maxy := -1
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a < 0.5:
				continue
			minx = mini(minx, x)
			miny = mini(miny, y)
			maxx = maxi(maxx, x)
			maxy = maxi(maxy, y)
	if maxx < 0:
		return Rect2i(0, 0, img.get_width(), img.get_height())
	return Rect2i(minx, miny, maxx - minx + 1, maxy - miny + 1)
