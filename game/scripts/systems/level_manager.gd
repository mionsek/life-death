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

# The world-map graph — transcribed from the hand-drawn design sketch
# (docs: 42 levels flowing left→right across three horizontal bands:
# Heaven on top, Earth in the middle, Hell at the bottom; wavy borders).
# pos = pixel position on the 1280x720 map canvas. Completing a level unlocks
# its `next` successors. Levels whose scene file does not exist yet are shown
# on the map as "planned" and cannot be played (is_level_playable == false).
#
# Sketch numbering → game ids: Earth spine 1-6 plus the lower pocket
# (25,32,31 → E07-E09) and the upper-right pocket (20,21 → E10-E11);
# Heaven cluster (sketch 7-19,22-24 → H01-H16, ids 21-36); Hell cluster
# (sketch 26-30,33-42 → D01-D15, ids 41-55).
const LEVEL_GRAPH: Array[Dictionary] = [
	# --- Earth (between the wavy borders) ---
	{"zone": "earth", "index": 1, "pos": Vector2(256, 345), "next": [2]},                # start
	{"zone": "earth", "index": 2, "pos": Vector2(495, 333), "next": [3, 21, 41]},        # gateway: Heaven #1 + Hell #1
	{"zone": "earth", "index": 3, "pos": Vector2(640, 358), "next": [4, 7]},             # gateway: lower earth pocket
	{"zone": "earth", "index": 4, "pos": Vector2(838, 333), "next": [5, 29]},            # gateway: Heaven #2
	{"zone": "earth", "index": 5, "pos": Vector2(1026, 374), "next": [6, 10]},           # gateway: upper-right pocket
	{"zone": "earth", "index": 6, "pos": Vector2(1163, 345), "next": []},
	{"zone": "earth", "index": 7, "pos": Vector2(624, 467), "next": [8]},                # sketch 25 (planned)
	{"zone": "earth", "index": 8, "pos": Vector2(805, 474), "next": [9, 46, 49]},        # sketch 32 → Hell mid cluster
	{"zone": "earth", "index": 9, "pos": Vector2(940, 470), "next": [50]},               # sketch 31 → Hell deep cluster
	{"zone": "earth", "index": 10, "pos": Vector2(1015, 264), "next": [11]},             # sketch 20 (planned)
	{"zone": "earth", "index": 11, "pos": Vector2(1155, 230), "next": []},               # sketch 21 (planned)
	# --- Heaven (top band; the further up-right, the harder for the Reaper) ---
	{"zone": "heaven", "index": 1, "pos": Vector2(586, 210), "next": [22, 25]},          # sketch 7  = Heaven_01
	{"zone": "heaven", "index": 2, "pos": Vector2(434, 155), "next": [23]},              # sketch 8  = Heaven_02
	{"zone": "heaven", "index": 3, "pos": Vector2(284, 148), "next": [24]},              # sketch 9  = Heaven_03
	{"zone": "heaven", "index": 4, "pos": Vector2(190, 54), "next": []},                 # sketch 10 = Heaven_04
	{"zone": "heaven", "index": 5, "pos": Vector2(640, 129), "next": [26, 28]},          # sketch 11 (planned)
	{"zone": "heaven", "index": 6, "pos": Vector2(525, 52), "next": [27]},               # sketch 12
	{"zone": "heaven", "index": 7, "pos": Vector2(401, 52), "next": []},                 # sketch 13
	{"zone": "heaven", "index": 8, "pos": Vector2(738, 52), "next": []},                 # sketch 14
	{"zone": "heaven", "index": 9, "pos": Vector2(838, 222), "next": [30, 31]},          # sketch 15
	{"zone": "heaven", "index": 10, "pos": Vector2(738, 168), "next": []},               # sketch 16
	{"zone": "heaven", "index": 11, "pos": Vector2(932, 165), "next": [32, 34]},         # sketch 17
	{"zone": "heaven", "index": 12, "pos": Vector2(896, 93), "next": [33]},              # sketch 18
	{"zone": "heaven", "index": 13, "pos": Vector2(1023, 41), "next": []},               # sketch 19
	{"zone": "heaven", "index": 14, "pos": Vector2(1122, 155), "next": [35, 36]},        # sketch 22
	{"zone": "heaven", "index": 15, "pos": Vector2(998, 103), "next": []},               # sketch 23
	{"zone": "heaven", "index": 16, "pos": Vector2(1213, 77), "next": []},               # sketch 24
	# --- Hell (bottom band; the deeper, the harder for the Guardian) ---
	{"zone": "hell", "index": 1, "pos": Vector2(470, 483), "next": [42, 44]},            # sketch 26 = Hell_01
	{"zone": "hell", "index": 2, "pos": Vector2(305, 576), "next": [43]},                # sketch 27 = Hell_02
	{"zone": "hell", "index": 3, "pos": Vector2(314, 672), "next": []},                  # sketch 28 = Hell_03
	{"zone": "hell", "index": 4, "pos": Vector2(503, 590), "next": [45]},                # sketch 29 = Hell_04
	{"zone": "hell", "index": 5, "pos": Vector2(553, 672), "next": []},                  # sketch 30 (planned)
	{"zone": "hell", "index": 6, "pos": Vector2(701, 556), "next": [47]},                # sketch 33
	{"zone": "hell", "index": 7, "pos": Vector2(586, 634), "next": [48]},                # sketch 34
	{"zone": "hell", "index": 8, "pos": Vector2(710, 693), "next": []},                  # sketch 35
	{"zone": "hell", "index": 9, "pos": Vector2(891, 560), "next": []},                  # sketch 36
	{"zone": "hell", "index": 10, "pos": Vector2(1040, 563), "next": [51, 53]},          # sketch 37
	{"zone": "hell", "index": 11, "pos": Vector2(998, 634), "next": [52, 54]},           # sketch 38
	{"zone": "hell", "index": 12, "pos": Vector2(866, 693), "next": []},                 # sketch 39
	{"zone": "hell", "index": 13, "pos": Vector2(1172, 515), "next": [55]},              # sketch 40
	{"zone": "hell", "index": 14, "pos": Vector2(1089, 672), "next": []},                # sketch 41
	{"zone": "hell", "index": 15, "pos": Vector2(1196, 672), "next": []},                # sketch 42
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
