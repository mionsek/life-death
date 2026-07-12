extends CanvasLayer

# Live minimap — a tiny square in the top-left corner. It renders the actual
# level through a SubViewport that shares the main World2D, so platforms,
# obstacles and both characters are always up to date. Tapping the square
# expands the map to fill the whole screen; tapping again collapses it.

const CORNER_SIZE := Vector2(46, 46)
const CORNER_MARGIN := 8.0
const EXPANDED_FRACTION := 1.0

const PLAYER_DOT := Color(0.62, 0.32, 1.0)
const GUARDIAN_DOT := Color(1.0, 0.8, 0.25)

# World-space rectangle of the level shown on the map.
var _bounds: Rect2 = Rect2(0, 0, 640, 360)
# Tracked characters (CharacterBody2D), drawn as coloured dots.
var _players: Array = []
var _expanded: bool = false

@onready var _frame: Control = $Frame
@onready var _view: SubViewport = $Frame/ViewContainer/View
@onready var _cam: Camera2D = $Frame/ViewContainer/View/Cam
@onready var _overlay: Control = $Frame/Overlay


func _ready() -> void:
	_view.world_2d = get_viewport().world_2d
	_frame.gui_input.connect(_on_frame_input)
	_overlay.draw.connect(_draw_overlay)
	_apply_layout()


# Called by level_base after instancing.
func setup(bounds: Rect2, players: Array) -> void:
	_bounds = bounds
	_players = players
	_apply_layout()


func _process(_delta: float) -> void:
	_overlay.queue_redraw()


# Toggles between corner minimap and the full-level map.
func _on_frame_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_expanded = not _expanded
		_apply_layout()


# Positions the frame (corner or centered) and refits the map camera.
func _apply_layout() -> void:
	var screen: Vector2 = get_viewport().get_visible_rect().size
	if _expanded:
		var target := screen * EXPANDED_FRACTION
		# keep the level aspect ratio inside the expanded frame
		var s: float = minf(target.x / _bounds.size.x, target.y / _bounds.size.y)
		_frame.size = _bounds.size * s
		_frame.position = (screen - _frame.size) / 2.0
	else:
		_frame.size = CORNER_SIZE
		_frame.position = Vector2(CORNER_MARGIN, CORNER_MARGIN)
	_fit_camera()


# Centers the map camera on the level and zooms it out to fit the whole level.
func _fit_camera() -> void:
	_cam.position = _bounds.get_center()
	var vs: Vector2 = _frame.size
	if _bounds.size.x <= 0.0 or _bounds.size.y <= 0.0:
		return
	var z: float = minf(vs.x / _bounds.size.x, vs.y / _bounds.size.y)
	_cam.zoom = Vector2(z, z)


# Draws the frame border and one dot per tracked character.
func _draw_overlay() -> void:
	_overlay.draw_rect(Rect2(Vector2.ZERO, _frame.size), Color(0, 0, 0, 0.85), false, 2.0)
	var s: float = minf(_frame.size.x / _bounds.size.x, _frame.size.y / _bounds.size.y)
	var offset: Vector2 = (_frame.size - _bounds.size * s) / 2.0
	for p in _players:
		if not is_instance_valid(p):
			continue
		var local: Vector2 = (p.position - _bounds.position) * s + offset
		local = local.clamp(Vector2(3, 3), _frame.size - Vector2(3, 3))
		var dot := GUARDIAN_DOT if p.name == "Guardian" else PLAYER_DOT
		_overlay.draw_circle(local, 3.0, Color(0, 0, 0, 0.9))
		_overlay.draw_circle(local, 2.2, dot)
