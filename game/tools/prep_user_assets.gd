# Prepares user-delivered art for in-game use without touching the originals:
# - strips the solid black background to transparency
# - trims empty borders and downscales to a game-friendly size (nearest)
# Run: godot --headless -s res://tools/prep_user_assets.gd
extends SceneTree

const JOBS := [
	# [source, destination, target_size]
	["res://assets/skull.png", "res://assets/collectibles/skull.png", 64],
	["res://assets/heart.png", "res://assets/collectibles/heart.png", 64],
]

# Pixels darker than this (max channel) become fully transparent.
const BLACK_THRESHOLD := 0.10


func _init() -> void:
	for job in JOBS:
		_process_asset(job[0], job[1], job[2])
	quit()


func _process_asset(src: String, dst: String, target: int) -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(src))
	if img == null:
		push_error("cannot load " + src)
		return
	img.convert(Image.FORMAT_RGBA8)
	# knock out the black background
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if maxf(c.r, maxf(c.g, c.b)) < BLACK_THRESHOLD:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	# trim transparent borders
	var used := img.get_used_rect()
	if used.size.x > 0 and used.size.y > 0:
		img = img.get_region(used)
	# downscale, preserving the pixel-art look
	var scale := float(target) / float(maxi(img.get_width(), img.get_height()))
	img.resize(int(img.get_width() * scale), int(img.get_height() * scale),
		Image.INTERPOLATE_NEAREST)
	var abs_dst := ProjectSettings.globalize_path(dst)
	DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
	img.save_png(abs_dst)
	print("  prepared ", dst, " (", img.get_width(), "x", img.get_height(), ")")
