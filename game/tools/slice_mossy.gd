# Slices the Mossy Tileset originals (art/mossy/, outside the game project)
# into game-ready terrain blocks: crops each block region, trims transparent
# borders and downscales to game scale. Outputs to assets/tilesets/mossy/.
# Run: godot --headless -s res://tools/slice_mossy.gd
extends SceneTree

# Source block regions on the 3584x3584 sheet (generous crops; trimmed after).
# [name, x, y, w, h, target_width]
const BLOCKS := [
	["panel", 0, 0, 1460, 1510, 288],        # big square block (nine-patch source)
	["column", 1500, 30, 440, 1300, 96],     # tall column
	["bar", 230, 1480, 1060, 430, 144],      # horizontal bar / shelf
	["block", 1490, 1480, 460, 430, 96],     # small square block
]


func _init() -> void:
	var src_path: String = ProjectSettings.globalize_path("res://").path_join("../art/mossy/tileset.png")
	var sheet := Image.load_from_file(src_path)
	if sheet == null:
		push_error("cannot load " + src_path)
		quit(1)
		return
	sheet.convert(Image.FORMAT_RGBA8)
	for def in BLOCKS:
		var crop := sheet.get_region(Rect2i(def[1], def[2], def[3], def[4]))
		var used := crop.get_used_rect()
		if used.size.x > 0:
			crop = crop.get_region(used)
		var scale := float(def[5]) / float(crop.get_width())
		crop.resize(int(crop.get_width() * scale), int(crop.get_height() * scale),
			Image.INTERPOLATE_LANCZOS)
		var dst := "res://assets/tilesets/mossy/%s.png" % def[0]
		var abs_dst := ProjectSettings.globalize_path(dst)
		DirAccess.make_dir_recursive_absolute(abs_dst.get_base_dir())
		crop.save_png(abs_dst)
		print("  sliced ", dst, " (", crop.get_width(), "x", crop.get_height(), ")")
	quit()
