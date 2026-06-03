extends Node

const SAVE_PATH: String = "user://save_data.json"

# Persists level progress and pair identity across sessions.


# Saves the current LevelManager state to disk as JSON.
func save_progress() -> void:
	var data := _build_save_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open save file for writing: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


# Loads saved progress from disk and restores LevelManager state.
# Silently initialises a fresh save if no file exists yet.
func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: cannot open save file for reading: %s" % SAVE_PATH)
		return
	var raw := file.get_as_text()
	file.close()
	var parsed := JSON.parse_string(raw)
	if parsed == null or not parsed is Dictionary:
		push_error("SaveManager: save file is corrupt, ignoring")
		return
	_apply_save_data(parsed)


# Deletes the save file and resets LevelManager to its default state.
func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	LevelManager._build_level_registry()


# Returns the stored Pair ID, generating and persisting a new one if absent.
func get_or_create_pair_id() -> String:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var raw := file.get_as_text()
			file.close()
			var parsed := JSON.parse_string(raw)
			if parsed is Dictionary and parsed.has("pair_id"):
				return parsed["pair_id"]
	var new_id := _generate_uuid()
	var data := _build_save_data()
	data["pair_id"] = new_id
	var wfile := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if wfile != null:
		wfile.store_string(JSON.stringify(data, "\t"))
		wfile.close()
	return new_id


# Serialises the current LevelManager registry into a Dictionary.
func _build_save_data() -> Dictionary:
	var levels_data: Dictionary = {}
	for id in range(1, 61):
		if LevelManager.has_level(id):
			var status := LevelManager.get_level_status(id)
			levels_data[str(id)] = {
				"unlocked": status != "locked",
				"completed": status == "completed"
			}
	var pair_id := ""
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var raw := file.get_as_text()
			file.close()
			var parsed := JSON.parse_string(raw)
			if parsed is Dictionary and parsed.has("pair_id"):
				pair_id = parsed["pair_id"]
	if pair_id.is_empty():
		pair_id = _generate_uuid()
	return {"pair_id": pair_id, "levels": levels_data}


# Applies a save Dictionary to the LevelManager registry.
func _apply_save_data(data: Dictionary) -> void:
	if not data.has("levels"):
		return
	var levels: Dictionary = data["levels"]
	for key in levels.keys():
		var id := int(key)
		if not LevelManager.has_level(id):
			continue
		var entry: Dictionary = levels[key]
		if entry.get("unlocked", false):
			LevelManager._levels[id].unlocked = true
		if entry.get("completed", false):
			LevelManager._levels[id].completed = true


# Generates a random UUID v4.
func _generate_uuid() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var b: Array[int] = []
	for i in range(16):
		b.append(rng.randi() % 256)
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
		b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15]
	]
