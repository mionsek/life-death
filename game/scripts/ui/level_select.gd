extends Control

# World map drawn as a binary tree rotated 90°: the root level sits on the
# left and every branch splits rightward — the upper child climbs toward
# Heaven, the lower one descends toward Hell. Golden paths connect the level
# gems; completing a level lights up its children.

const MAP_BG := preload("res://assets/gen/ui/map_bg.png")
const GEM := preload("res://assets/gen/ui/gem.png")
const GEM_BIG := preload("res://assets/gen/ui/gem_big.png")

# Screen-space mapping of LevelManager map units (x = tree depth, y = row).
const ORIGIN := Vector2(80, 180)
const SPACING := Vector2(115, 38)

const ZONE_COLORS := {
	"earth": Color(0.45, 0.85, 0.35),
	"heaven": Color(1.0, 0.85, 0.4),
	"hell": Color(1.0, 0.35, 0.25),
}
const LOCKED_TINT := Color(0.32, 0.32, 0.38, 0.9)
const PATH_GOLD := Color(0.88, 0.68, 0.2)
const PATH_DARK := Color(0.28, 0.17, 0.05)
const PATH_LOCKED := Color(0.45, 0.38, 0.28, 0.6)

var _buttons: Dictionary = {}


func _ready() -> void:
	$BtnBack.pressed.connect(_on_back_pressed)
	_build_map()


# Converts LevelManager map units to screen pixels.
func _map_to_screen(map_pos: Vector2) -> Vector2:
	return ORIGIN + map_pos * SPACING


# Creates one gem button per level in the world graph.
func _build_map() -> void:
	for data in LevelManager.get_all_levels():
		var status: String = LevelManager.get_level_status(data.id)
		var is_milestone: bool = data.next_ids.is_empty() and data.index > 1
		var tex := GEM_BIG if is_milestone else GEM
		var btn := TextureButton.new()
		btn.name = "Level_%d" % data.id
		btn.texture_normal = tex
		btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var tex_size: Vector2 = tex.get_size()
		btn.position = _map_to_screen(data.map_pos) - tex_size / 2.0
		btn.pivot_offset = tex_size / 2.0
		var zone_color: Color = ZONE_COLORS[data.zone]
		match status:
			"locked":
				btn.modulate = LOCKED_TINT
				btn.disabled = true
			"unlocked":
				btn.modulate = zone_color
				_add_pulse(btn)
			"completed":
				btn.modulate = zone_color.lightened(0.25)
		if not btn.disabled:
			var level_id: int = data.id
			btn.pressed.connect(func(): _on_level_selected(level_id))

		# Level number below the gem (checkmark prefix when completed).
		var lbl := Label.new()
		lbl.text = ("✓" if status == "completed" else "") + str(data.index)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		lbl.position = Vector2(0, tex_size.y - 2.0)
		lbl.size = Vector2(tex_size.x, 10)
		btn.add_child(lbl)
		add_child(btn)
		_buttons[data.id] = btn


# Gentle glow pulse marking levels that are ready to play.
func _add_pulse(btn: TextureButton) -> void:
	var tween := btn.create_tween().set_loops()
	tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.55)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.55)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# Paints the background, the golden paths and the zone captions (under buttons).
func _draw() -> void:
	draw_texture_rect(MAP_BG, Rect2(Vector2.ZERO, size), false)
	for data in LevelManager.get_all_levels():
		var from := _map_to_screen(data.map_pos)
		for next_id in data.next_ids:
			var next_data = LevelManager.get_level(next_id)
			if next_data == null:
				continue
			var to := _map_to_screen(next_data.map_pos)
			var open := LevelManager.get_level_status(next_id) != "locked"
			draw_line(from, to, PATH_DARK, 7.0)
			draw_line(from, to, PATH_GOLD if open else PATH_LOCKED, 3.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(14, 26), "NIEBO", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.92, 0.6, 0.9))
	draw_string(font, Vector2(14, 186), "ZIEMIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.7, 0.9, 0.5, 0.9))
	draw_string(font, Vector2(14, 310), "PIEKŁO", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.5, 0.35, 0.9))


# Starts loading the selected level.
func _on_level_selected(level_id: int) -> void:
	LevelManager.load_level(level_id)


# Returns to the main menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
