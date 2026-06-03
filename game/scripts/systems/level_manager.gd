extends Node

# Represents a single level entry with zone, index and completion state.
class LevelData:
	var id: int
	var zone: String       # "earth", "heaven", "hell"
	var index: int         # position within the zone (1-based)
	var scene_path: String
	var unlocked: bool
	var completed: bool

	func _init(p_id: int, p_zone: String, p_index: int, p_scene: String, p_unlocked: bool = false) -> void:
		id = p_id
		zone = p_zone
		index = p_index
		scene_path = p_scene
		unlocked = p_unlocked
		completed = false


# Emitted after a level is marked as completed and next level is unlocked.
signal level_completed(level_id: int)
# Emitted when a level scene is about to load.
signal level_loading(level_id: int)

const ZONES: Array[String] = ["earth", "heaven", "hell"]
const EARTH_COUNT: int = 20
const HEAVEN_COUNT: int = 20
const HELL_COUNT: int = 20

# All levels indexed by their id (1-based).
var _levels: Dictionary = {}
# The id of the level currently being played.
var current_level_id: int = 0


func _ready() -> void:
	_build_level_registry()
	SaveManager.load_progress()


# Populates the level registry with all 60 level definitions.
func _build_level_registry() -> void:
	var id := 1
	for i in range(1, EARTH_COUNT + 1):
		var scene := "res://scenes/levels/earth/Level_Earth_%02d.tscn" % i
		var unlocked := (i == 1)
		_levels[id] = LevelData.new(id, "earth", i, scene, unlocked)
		id += 1
	for i in range(1, HEAVEN_COUNT + 1):
		var scene := "res://scenes/levels/heaven/Level_Heaven_%02d.tscn" % i
		_levels[id] = LevelData.new(id, "heaven", i, scene, false)
		id += 1
	for i in range(1, HELL_COUNT + 1):
		var scene := "res://scenes/levels/hell/Level_Hell_%02d.tscn" % i
		_levels[id] = LevelData.new(id, "hell", i, scene, false)
		id += 1


# Loads the given level scene (single-player or multiplayer host only).
func load_level(level_id: int) -> void:
	if not _levels.has(level_id):
		push_error("LevelManager: unknown level id %d" % level_id)
		return
	current_level_id = level_id
	level_loading.emit(level_id)
	get_tree().change_scene_to_file(_levels[level_id].scene_path)


# Marks the level as completed, unlocks the next one, auto-saves and emits the signal.
func complete_level(level_id: int) -> void:
	if not _levels.has(level_id):
		push_error("LevelManager: unknown level id %d" % level_id)
		return
	_levels[level_id].completed = true
	var next_id := level_id + 1
	if _levels.has(next_id) and _levels[next_id].zone == _levels[level_id].zone:
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


# Returns true if the given level id exists in the registry.
func has_level(level_id: int) -> bool:
	return _levels.has(level_id)
