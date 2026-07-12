extends Control

# World map — a faithful rendition of the hand-drawn design: a 1280x720 canvas
# split into three wavy bands (Heaven / Earth / Hell) with the level graph
# flowing left→right. The canvas is larger than the screen, so it can be
# dragged (and zoomed with the mouse wheel); the view starts centered on the
# next level to play. Completing a level lights up its successors, exactly as
# defined in LevelManager.LEVEL_GRAPH.

const MAP_BG := preload("res://assets/background/bg1.png")
const NODE_BUBBLE := preload("res://assets/bubble_transparent.png")

const MAP_PATHS_SCRIPT := preload("res://scripts/ui/map_paths.gd")

const LOCK_ICON := preload("res://assets/gen/ui/lock.png")

# Bubble size on the canvas and zone tints applied via modulate:
# heaven keeps the bubble's pure white-blue look, earth is clearly green,
# hell clearly red.
const NODE_SIZE := Vector2(58, 58)
const ZONE_TINTS := {
	"earth": Color(0.35, 1.0, 0.3),
	"heaven": Color.WHITE,
	"hell": Color(1.0, 0.35, 0.25),
}

const CANVAS_SIZE := Vector2(1280, 720)
const MIN_ZOOM := 0.5
const MAX_ZOOM := 1.6

const TINT_PLANNED := Color(0.28, 0.28, 0.33, 0.55)

var _canvas: Control
# Starts zoomed-in enough for comfortable finger navigation on a phone;
# pinch (or mouse wheel) zooms out to the 0.5 full-map overview.
var _zoom: float = 0.85
var _dragging: bool = false
# Active touch points (index -> position) for one-finger pan / two-finger pinch.
var _touches: Dictionary = {}
# Runtime-densified copy of the bubble art (the source is very translucent).
var _bubble_tex: Texture2D


func _ready() -> void:
	$BtnBack.pressed.connect(_on_back_pressed)
	_bubble_tex = _densify_bubble()
	_build_canvas()
	_canvas.scale = Vector2(_zoom, _zoom)
	_center_on_next_level.call_deferred()


# Stacks the bubble's alpha (equivalent to layering it three times) so nodes
# stay readable over the detailed map art, without touching the source file.
func _densify_bubble() -> Texture2D:
	var img: Image = NODE_BUBBLE.get_image()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			c.a = 1.0 - pow(1.0 - c.a, 3.0)
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


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

	var trails := Control.new()
	trails.name = "Paths"
	trails.set_script(MAP_PATHS_SCRIPT)
	trails.size = CANVAS_SIZE
	trails.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for data in LevelManager.get_all_levels():
		for next_id in data.next_ids:
			var next_data = LevelManager.get_level(next_id)
			if next_data:
				trails.paths.append({
					"points": _curve_points(data.map_pos, next_data.map_pos),
					"open": LevelManager.get_level_status(next_id) != "locked",
				})
	_canvas.add_child(trails)

	for data in LevelManager.get_all_levels():
		_add_node(data)


# Samples a gentle quadratic arc between two points (hand-drawn feel).
func _curve_points(from: Vector2, to: Vector2) -> PackedVector2Array:
	var mid := (from + to) / 2.0
	var perp := (to - from).orthogonal().normalized()
	var control := mid + perp * (to - from).length() * 0.12
	var points := PackedVector2Array()
	for i in 25:
		var t := i / 24.0
		points.append(from.lerp(control, t).lerp(control.lerp(to, t), t))
	return points


# Adds one clickable level bubble with its zone/state tint and centered number.
func _add_node(data) -> void:
	var status: String = LevelManager.get_level_status(data.id)
	var playable: bool = LevelManager.is_level_playable(data.id)
	var zone_tint: Color = ZONE_TINTS[data.zone]
	var btn := TextureButton.new()
	btn.name = "Level_%d" % data.id
	btn.texture_normal = _bubble_tex
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_SCALE
	btn.size = NODE_SIZE
	btn.position = data.map_pos - NODE_SIZE / 2.0
	btn.pivot_offset = NODE_SIZE / 2.0

	if not playable:
		btn.modulate = TINT_PLANNED    # sketched but not built yet
		btn.disabled = true
	else:
		match status:
			"locked":
				# very dark on purpose — locked must read at a glance
				btn.modulate = zone_tint.darkened(0.72)
				btn.disabled = true
			"unlocked":
				btn.modulate = zone_tint
				_add_pulse(btn)        # "play me next"
			"completed":
				btn.modulate = zone_tint.lightened(0.35)
	if not btn.disabled:
		var level_id: int = data.id
		btn.pressed.connect(func(): _on_level_selected(level_id))

	if not btn.disabled:
		var lbl := Label.new()
		lbl.text = ("✓" if status == "completed" else "") + str(data.index)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		lbl.size = NODE_SIZE
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(lbl)
	_canvas.add_child(btn)

	if btn.disabled:
		# Every non-playable bubble (locked or planned) shows only a padlock.
		# Added as a canvas sibling so it stays at full brightness on top of
		# the darkened bubble.
		var lock := TextureRect.new()
		lock.texture = LOCK_ICON
		lock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		lock.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		lock.size = NODE_SIZE
		lock.position = data.map_pos - NODE_SIZE / 2.0
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_canvas.add_child(lock)


# Slow, subtle breathing pulse marking levels that are ready to play.
func _add_pulse(btn: TextureButton) -> void:
	var tween := btn.create_tween().set_loops()
	tween.tween_property(btn, "scale", Vector2(1.07, 1.07), 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(btn, "scale", Vector2.ONE, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# ---------------------------------------------------------- pan & zoom ------

# Touch: one finger pans, two fingers pinch-zoom.
# Mouse (desktop): drag pans, wheel zooms around the cursor.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
		else:
			_touches.erase(event.index)
	elif event is InputEventScreenDrag:
		if _touches.size() >= 2 and _touches.has(event.index):
			# pinch: zoom by the change of distance to the other finger
			var other_index := -1
			for idx in _touches.keys():
				if idx != event.index:
					other_index = idx
					break
			var other: Vector2 = _touches[other_index]
			var old_dist: float = _touches[event.index].distance_to(other)
			var new_dist: float = event.position.distance_to(other)
			_touches[event.index] = event.position
			if old_dist > 1.0:
				_apply_zoom(new_dist / old_dist, (event.position + other) / 2.0)
		elif _touches.has(event.index):
			_touches[event.index] = event.position
			_canvas.position += event.relative
			_clamp_canvas()
	elif event is InputEventMouseButton and _touches.is_empty():
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(1.1, event.position)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(1.0 / 1.1, event.position)
	elif event is InputEventMouseMotion and _dragging and _touches.is_empty():
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
