extends Node

# Live obstacle tutorials: the first time an obstacle type scrolls into view,
# the game pauses and a popup explains it (translated via TUT_* keys). Seen
# types persist in user://tutorials_seen.json, so each lesson shows only once
# per install. In multiplayer the popup is local to each device — every player
# learns at their own pace without freezing the partner.

const SEEN_PATH: String = "user://tutorials_seen.json"
const POPUP_SCENE := preload("res://scenes/ui/TutorialPopup.tscn")
# How often (seconds) visible obstacles are checked.
const CHECK_INTERVAL: float = 0.25
# Extra margin (px) around the view so obstacles trigger right at the edge.
const VIEW_MARGIN: float = 8.0
# A lesson triggers only when a hero is this close to the obstacle (px),
# besides it being on screen — walking past matters, not seeing from afar.
const PROXIMITY_RADIUS: float = 130.0

# Toggle for tests / speedruns; popups are skipped entirely when false.
var enabled: bool = true

var _seen: Dictionary = {}
# Pending {type, node} entries for the currently tracked level.
var _pending: Array[Dictionary] = []
var _camera: Camera2D = null
# The two characters — a lesson needs one of them near the obstacle.
var _heroes: Array[Node2D] = []
var _timer: float = 0.0
# The popup currently on screen — no new lessons trigger while it lives.
var _active_popup: Node = null


func _ready() -> void:
	_load_seen()


# Called by level_base once the level tree is ready: collects every known
# obstacle that still needs its tutorial and starts watching the camera.
func track_level(level_root: Node, camera: Camera2D) -> void:
	_pending.clear()
	_camera = camera
	_heroes.clear()
	if not enabled or camera == null:
		return
	for hero_name in ["Player", "Guardian"]:
		var hero := level_root.get_node_or_null(hero_name)
		if hero is Node2D:
			_heroes.append(hero)
	_collect(level_root)


func _collect(node: Node) -> void:
	var type := classify(node)
	if type != "" and not was_seen(type):
		_pending.append({"type": type, "node": node})
	for child in node.get_children():
		_collect(child)


# Maps a scene node to a tutorial type ("" = not a tutorialised obstacle).
func classify(node: Node) -> String:
	if node is Collectible:
		return "heart" if node.target_character == "Guardian" else "skull"
	if node is MovingPlatform:
		return "moving_platform"
	if node is CrumblingPlatform:
		return "crumbling_platform"
	if node is PressurePlate:
		return "pressure_plate"
	if node is Lever:
		return "lever"
	if node is Door:
		return "door"
	if node is Seesaw:
		return "seesaw"
	if node is ExitPortal:
		return "portal"
	var script: Script = node.get_script()
	if script != null:
		var path := script.resource_path
		if "fire_zone" in path:
			return "lava"
		if "light_zone" in path:
			return "holy_light"
	# Newer levels wire lava areas straight to the level script — recognise
	# them by name instead (LavaPool, LavaPool2, ...).
	if node is Area2D and node.name.begins_with("Lava"):
		return "lava"
	if node is StaticBody2D:
		if node.name.begins_with("Cloud"):
			return "cloud"
		for child in node.get_children():
			if child is CollisionShape2D and child.one_way_collision:
				return "one_way"
	return ""


func was_seen(type: String) -> bool:
	return _seen.get(type, false)


func mark_seen(type: String) -> void:
	_seen[type] = true
	_save_seen()


# Forgets all lessons (future settings option / fresh save).
func reset_seen() -> void:
	_seen.clear()
	_save_seen()


# Polls visibility a few times per second. Never triggers while the game is
# paused (own popup, pause menu or death screen) — lessons queue one at a time.
func _process(delta: float) -> void:
	if _active_popup != null and is_instance_valid(_active_popup):
		return
	_active_popup = null
	if get_tree().paused:
		return
	if _pending.is_empty() or _camera == null or not is_instance_valid(_camera):
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = CHECK_INTERVAL
	if not _heroes_grounded():
		return
	var view := _view_rect()
	for entry in _pending:
		var node: Node = entry.node
		if not is_instance_valid(node):
			continue
		if was_seen(entry.type):
			continue
		if view.has_point(node.global_position) and _near_heroes(node.global_position):
			_show_tutorial(entry.type, node)
			break
	_pending = _pending.filter(
		func(e): return is_instance_valid(e.node) and not was_seen(e.type))


# Pausing mid-jump is jarring — no lesson fires while any hero is airborne;
# the pending obstacle simply waits for the next check after landing.
func _heroes_grounded() -> bool:
	for hero in _heroes:
		if not is_instance_valid(hero):
			continue
		if hero is CharacterBody2D and not hero.is_on_floor():
			return false
	return true


# Whether any hero stands close enough to the obstacle for the lesson to
# matter. Levels without hero nodes (tests, tools) fall back to view-only.
func _near_heroes(pos: Vector2) -> bool:
	var any_valid := false
	for hero in _heroes:
		if not is_instance_valid(hero):
			continue
		any_valid = true
		if hero.global_position.distance_to(pos) <= PROXIMITY_RADIUS:
			return true
	return not any_valid


# The world-space rectangle currently visible through the camera.
func _view_rect() -> Rect2:
	var size: Vector2 = _camera.get_viewport_rect().size / _camera.zoom
	return Rect2(_camera.get_screen_center_position() - size / 2.0, size) \
		.grow(VIEW_MARGIN)


# Pauses the game and shows the popup with its spotlight aimed at the
# obstacle; the popup unpauses on dismiss.
func _show_tutorial(type: String, target: Node = null) -> void:
	mark_seen(type)
	var popup := POPUP_SCENE.instantiate()
	get_tree().root.add_child(popup)
	popup.setup(type, target if target is Node2D else null)
	_active_popup = popup
	get_tree().paused = true


func _load_seen() -> void:
	if not FileAccess.file_exists(SEEN_PATH):
		return
	var file := FileAccess.open(SEEN_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_seen = parsed


func _save_seen() -> void:
	var file := FileAccess.open(SEEN_PATH, FileAccess.WRITE)
	if file == null:
		push_error("TutorialManager: cannot write %s" % SEEN_PATH)
		return
	file.store_string(JSON.stringify(_seen))
	file.close()
