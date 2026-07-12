extends Control

# World map — a faithful rendition of the hand-drawn design: a 1280x720 canvas
# split into three wavy bands (Heaven / Earth / Hell) with the level graph
# flowing left→right. The canvas is larger than the screen, so it can be
# dragged (and zoomed with the mouse wheel); the view starts centered on the
# next level to play. Completing a level lights up its successors, exactly as
# defined in LevelManager.LEVEL_GRAPH.

const MAP_BG := preload("res://assets/background/bg1.png")
const NODE_TEXTURES := {
	"earth": preload("res://assets/gen/ui/node_earth.png"),
	"heaven": preload("res://assets/gen/ui/node_heaven.png"),
	"hell": preload("res://assets/gen/ui/node_hell.png"),
}

const CANVAS_SIZE := Vector2(1280, 720)
const MIN_ZOOM := 0.5
const MAX_ZOOM := 1.6

const PATH_GOLD := Color(0.88, 0.68, 0.2)
const PATH_DARK := Color(0.24, 0.15, 0.05)
const PATH_LOCKED := Color(0.55, 0.47, 0.35, 0.5)
const TINT_LOCKED := Color(0.45, 0.45, 0.5, 0.9)
const TINT_PLANNED := Color(0.28, 0.28, 0.33, 0.55)

var _canvas: Control
var _zoom: float = 0.5
var _dragging: bool = false


func _ready() -> void:
	$BtnBack.pressed.connect(_on_back_pressed)
	_build_canvas()
	_canvas.scale = Vector2(_zoom, _zoom)
	_center_on_next_level.call_deferred()


# ------------------------------------------------------------- map canvas ---

# Builds the pannable canvas: background, curved paths, level nodes, captions.
func _build_canvas() -> void:
	_canvas = Control.new()
	_canvas.name = "Canvas"
	_canvas.size = CANVAS_SIZE
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_canvas)
	move_child(_canvas, 0)   # under the fixed UI (title, back button)

	var bg := TextureRect.new()
	bg.texture = MAP_BG
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.size = CANVAS_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.add_child(bg)

	for data in LevelManager.get_all_levels():
		for next_id in data.next_ids:
			var next_data = LevelManager.get_level(next_id)
			if next_data:
				_add_path(data.map_pos, next_data.map_pos,
					LevelManager.get_level_status(next_id) != "locked")
	for data in LevelManager.get_all_levels():
		_add_node(data)


# Adds one curved two-tone path between two nodes (dark outline under gold).
func _add_path(from: Vector2, to: Vector2, open: bool) -> void:
	var points := _curve_points(from, to)
	var under := Line2D.new()
	under.points = points
	under.width = 7.0
	under.default_color = PATH_DARK
	under.begin_cap_mode = Line2D.LINE_CAP_ROUND
	under.end_cap_mode = Line2D.LINE_CAP_ROUND
	_canvas.add_child(under)
	var over := Line2D.new()
	over.points = points
	over.width = 3.0
	over.default_color = PATH_GOLD if open else PATH_LOCKED
	over.begin_cap_mode = Line2D.LINE_CAP_ROUND
	over.end_cap_mode = Line2D.LINE_CAP_ROUND
	_canvas.add_child(over)


# Samples a gentle quadratic arc between two points (hand-drawn feel).
func _curve_points(from: Vector2, to: Vector2) -> PackedVector2Array:
	var mid := (from + to) / 2.0
	var perp := (to - from).orthogonal().normalized()
	var control := mid + perp * (to - from).length() * 0.12
	var points := PackedVector2Array()
	for i in 13:
		var t := i / 12.0
		points.append(from.lerp(control, t).lerp(control.lerp(to, t), t))
	return points


# Adds one clickable level node with its zone icon, state tint and number.
func _add_node(data) -> void:
	var status: String = LevelManager.get_level_status(data.id)
	var playable: bool = LevelManager.is_level_playable(data.id)
	var tex: Texture2D = NODE_TEXTURES[data.zone]
	var btn := TextureButton.new()
	btn.name = "Level_%d" % data.id
	btn.texture_normal = tex
	btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex_size: Vector2 = tex.get_size()
	btn.position = data.map_pos - tex_size / 2.0
	btn.pivot_offset = tex_size / 2.0

	if not playable:
		btn.modulate = TINT_PLANNED    # sketched but not built yet
		btn.disabled = true
	else:
		match status:
			"locked":
				btn.modulate = TINT_LOCKED
				btn.disabled = true
			"unlocked":
				btn.modulate = Color(1.15, 1.15, 1.15)
				_add_pulse(btn)        # "play me next"
			"completed":
				btn.modulate = Color.WHITE
	if not btn.disabled:
		var level_id: int = data.id
		btn.pressed.connect(func(): _on_level_selected(level_id))

	var lbl := Label.new()
	lbl.text = ("✓" if status == "completed" else "") + str(data.index)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.position = Vector2(0, tex_size.y - 3.0)
	lbl.size = Vector2(tex_size.x, 10)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(lbl)
	_canvas.add_child(btn)


# Gentle pulse marking levels that are ready to play.
func _add_pulse(btn: TextureButton) -> void:
	var tween := btn.create_tween().set_loops()
	tween.tween_property(btn, "scale", Vector2(1.18, 1.18), 0.55)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.55)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# ---------------------------------------------------------- pan & zoom ------

# Drag to pan; mouse wheel to zoom around the cursor.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(1.1, event.position)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(1.0 / 1.1, event.position)
	elif event is InputEventMouseMotion and _dragging:
		_canvas.position += event.relative
		_clamp_canvas()


# Zooms the canvas keeping the point under the cursor stationary.
func _apply_zoom(factor: float, pivot: Vector2) -> void:
	var new_zoom: float = clampf(_zoom * factor, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(new_zoom, _zoom):
		return
	var local := (pivot - _canvas.position) / _zoom
	_zoom = new_zoom
	_canvas.scale = Vector2(_zoom, _zoom)
	_canvas.position = pivot - local * _zoom
	_clamp_canvas()


# Keeps the canvas covering the screen (centers axes smaller than the view).
func _clamp_canvas() -> void:
	var view: Vector2 = size
	var span: Vector2 = CANVAS_SIZE * _zoom
	for axis in 2:
		if span[axis] <= view[axis]:
			_canvas.position[axis] = (view[axis] - span[axis]) / 2.0
		else:
			_canvas.position[axis] = clampf(_canvas.position[axis], view[axis] - span[axis], 0.0)


# Starts the view centered on the first unlocked, playable, uncompleted level.
func _center_on_next_level() -> void:
	var target: Vector2 = CANVAS_SIZE / 2.0
	for data in LevelManager.get_all_levels():
		if LevelManager.get_level_status(data.id) == "unlocked" \
				and LevelManager.is_level_playable(data.id):
			target = data.map_pos
			break
	_canvas.position = size / 2.0 - target * _zoom
	_clamp_canvas()


# ----------------------------------------------------------------- actions ---

# Starts loading the selected level.
func _on_level_selected(level_id: int) -> void:
	LevelManager.load_level(level_id)


# Returns to the main menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
