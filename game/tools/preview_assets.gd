# Dev helper: upscales generated sprites (nearest-neighbour) into one contact
# sheet so pixel art can be reviewed comfortably.
# Run: godot --headless -s res://tools/preview_assets.gd -- <out_dir>
extends SceneTree

const SOURCES := [
	"res://assets/gen/characters/reaper_sheet.png",
	"res://assets/gen/characters/guardian_sheet.png",
	"res://assets/gen/tiles/earth_tiles.png",
	"res://assets/gen/tiles/heaven_tiles.png",
	"res://assets/gen/tiles/hell_tiles.png",
	"res://assets/gen/obstacles/door.png",
	"res://assets/gen/obstacles/lever_idle.png",
	"res://assets/gen/obstacles/lever_active.png",
	"res://assets/gen/obstacles/panel.png",
	"res://assets/gen/obstacles/portal_0.png",
	"res://assets/gen/obstacles/plank.png",
	"res://assets/gen/ui/gem.png",
	"res://assets/gen/ui/gem_big.png",
]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out_dir: String = args[0] if args.size() > 0 else "user://preview"
	DirAccess.make_dir_recursive_absolute(out_dir)
	for src in SOURCES:
		var im := Image.load_from_file(ProjectSettings.globalize_path(src))
		if im == null:
			continue
		var scale := 6
		im.resize(im.get_width() * scale, im.get_height() * scale, Image.INTERPOLATE_NEAREST)
		var fname: String = String(src).get_file().get_basename() + "_x6.png"
		im.save_png(out_dir.path_join(fname))
		print("  preview ", fname)
	# big images: plain copy
	for src in ["res://assets/gen/ui/map_bg.png", "res://assets/gen/bg/earth_bg.png",
			"res://assets/gen/bg/heaven_bg.png", "res://assets/gen/bg/hell_bg.png"]:
		var im := Image.load_from_file(ProjectSettings.globalize_path(src))
		if im == null:
			continue
		im.resize(im.get_width() * 2, im.get_height() * 2, Image.INTERPOLATE_NEAREST)
		im.save_png(out_dir.path_join(src.get_file()))
		print("  preview ", src.get_file())
	quit()
