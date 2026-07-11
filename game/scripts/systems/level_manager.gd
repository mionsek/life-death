extends Node

# World-map level registry organised as a directed graph (tree with branches).
# Earth levels run horizontally from the central hub; Heaven branches upward
# (harder for the Reaper the higher you go) and Hell branches downward
# (harder for the Guardian the deeper you go). Completing a level unlocks
# every level connected to it by an outgoing edge.

# Represents a single level entry with zone, graph position and completion state.
class LevelData:
	var id: int
	var zone: String       # "earth", "heaven", "hell"
	var index: int         # position within the zone (1-based)
	var scene_path: String
	var unlocked: bool
	var completed: bool
	var map_pos: Vector2   # world-map coordinates in map units (y < 0 = heaven, y > 0 = hell)
	var next_ids: Array    # ids unlocked when this level is completed

	func _init(p_id: int, p_zone: String, p_index: int, p_scene: String,
			p_unlocked: bool, p_map_pos: Vector2, p_next: Array) -> void:
		id = p_id
		zone = p_zone
		index = p_index
		scene_path = p_scene
		unlocked = p_unlocked
		completed = false
		map_pos = p_map_pos
		next_ids = p_next


# Emitted after a level is marked as completed and its successors are unlocked.
signal level_completed(level_id: int)
# Emitted when a level scene is about to load.
signal level_loading(level_id: int)

const ZONES: Array[String] = ["earth", "heaven", "hell"]

# Id ranges per zone — kept stable for save compatibility:
# earth = 1..20, heaven = 21..40, hell = 41..60.
const HEAVEN_ID_OFFSET: int = 20
const HELL_ID_OFFSET: int = 40

# The world-map graph. Only levels listed here exist in the game.
# Format: zone, index, map position (map units, y up = heaven), successor ids.
# Map shape mirrors the reference: central hub with radiating arms.
const LEVEL_GRAPH: Array[Dictionary] = [
	# --- Earth: horizontal spine through the hub (equal difficulty) ---
	{"zone": "earth", "index": 1, "pos": Vector2(0.0, 0.0), "next": [2, 5]},     # hub / start
	{"zone": "earth", "index": 2, "pos": Vector2(1.0, 0.0), "next": [3]},
	{"zone": "earth", "index": 3, "pos": Vector2(2.0, 0.0), "next": [4, 21]},    # gateway to Heaven
	{"zone": "earth", "index": 4, "pos": Vector2(3.0, 0.0), "next": []},
	{"zone": "earth", "index": 5, "pos": Vector2(-1.0, 0.0), "next": [6, 41]},   # gateway to Hell
	{"zone": "earth", "index": 6, "pos": Vector2(-2.0, 0.0), "next": []},
	# --- Heaven: zig-zag arm climbing up; the higher, the harder for the Reaper ---
	{"zone": "heaven", "index": 1, "pos": Vector2(2.35, -0.9), "next": [22]},
	{"zone": "heaven", "index": 2, "pos": Vector2(1.75, -1.7), "next": [23]},
	{"zone": "heaven", "index": 3, "pos": Vector2(2.45, -2.5), "next": [24]},
	{"zone": "heaven", "index": 4, "pos": Vector2(1.9, -3.3), "next": []},       # summit diamond
	# --- Hell: zig-zag arm descending; the deeper, the harder for the Guardian ---
	{"zone": "hell", "index": 1, "pos": Vector2(-1.35, 0.9), "next": [42]},
	{"zone": "hell", "index": 2, "pos": Vector2(-0.75, 1.7), "next": [43]},
	{"zone": "hell", "index": 3, "pos": Vector2(-1.45, 2.5), "next": [44]},
	{"zone": "hell", "index": 4, "pos": Vector2(-0.9, 3.3), "next": []},         # abyss diamond
]

# All levels indexed by their id.
var _levels: Dictionary = {}
# The id of the level currently being played.
var current_level_id: int = 0


func _ready() -> void:
	_build_level_registry()
	SaveManager.load_progress()


# Returns the stable id for a zone + index pair.
static func make_level_id(zone: String, index: int) -> int:
	match zone:
		"heaven":
			return HEAVEN_ID_OFFSET + index
		"hell":
			return HELL_ID_OFFSET + index
		_:
			return index


# Populates the level registry from the world-map graph definition.
func _build_level_registry() -> void:
	_levels.clear()
	for def in LEVEL_GRAPH:
		var zone: String = def["zone"]
		var index: int = def["index"]
		var id := make_level_id(zone, index)
		var scene := "res://scenes/levels/%s/Level_%s_%02d.tscn" % [zone, zone.capitalize(), index]
		var unlocked := (zone == "earth" and index == 1)
		_levels[id] = LevelData.new(id, zone, index, scene, unlocked, def["pos"], def["next"])


# Loads the given level scene (single-player or multiplayer host only).
# Refuses gracefully when the scene file does not exist yet.
func load_level(level_id: int) -> void:
	if not _levels.has(level_id):
		push_error("LevelManager: unknown level id %d" % level_id)
		return
	var data: LevelData = _levels[level_id]
	if not ResourceLoader.exists(data.scene_path):
		push_warning("LevelManager: scene for level %d not created yet (%s)" % [level_id, data.scene_path])
		return
	current_level_id = level_id
	level_loading.emit(level_id)
	get_tree().change_scene_to_file(data.scene_path)


# Marks the level as completed, unlocks its graph successors, auto-saves and emits the signal.
func complete_level(level_id: int) -> void:
	if not _levels.has(level_id):
		push_error("LevelManager: unknown level id %d" % level_id)
		return
	_levels[level_id].completed = true
	for next_id in _levels[level_id].next_ids:
		if _levels.has(next_id):
			_levels[next_id].unlocked = true
	SaveManager.save_progress()
	level_completed.emit(level_id)


# Returns the status of a level: "locked", "unlocked", or "completed".
func get_level_status(level_id: int) -> String:
	if not _levels.has(level_id):
		return "locked"
	var data: LevelData = _levels[level_id]
	if data.completed:
		return "completed"
	if data.unlocked:
		return "unlocked"
	return "locked"


# Returns all LevelData entries for the given zone ("earth"/"heaven"/"hell").
func get_zone_levels(zone: String) -> Array:
	var result: Array = []
	for data in _levels.values():
		if data.zone == zone:
			result.append(data)
	result.sort_custom(func(a, b): return a.index < b.index)
	return result


# Returns every level in the registry (unsorted).
func get_all_levels() -> Array:
	return _levels.values()


# Returns the LevelData for an id, or null when it does not exist.
func get_level(level_id: int):
	return _levels.get(level_id)


# Returns true if the given level id exists in the registry.
func has_level(level_id: int) -> bool:
	return _levels.has(level_id)


# Returns true when the level's scene file exists and can be played.
func is_level_playable(level_id: int) -> bool:
	if not _levels.has(level_id):
		return false
	return ResourceLoader.exists(_levels[level_id].scene_path)
