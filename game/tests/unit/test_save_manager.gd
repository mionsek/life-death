extends GutTest

const SAVE_PATH: String = "user://save_data.json"


# Removes any leftover save file before each test for a clean slate.
func before_each() -> void:
	SaveManager.clear_save()


# Removes the save file after tests to avoid polluting other test runs.
func after_each() -> void:
	SaveManager.clear_save()


# Loading when no file exists must not crash and level 1 stays unlocked.
func test_load_with_no_file_does_not_crash() -> void:
	LevelManager._build_level_registry()
	SaveManager.load_progress()
	assert_eq(LevelManager.get_level_status(1), "unlocked")


# Saving and reloading restores completed levels correctly.
func test_save_and_load_restores_completed_levels() -> void:
	LevelManager._build_level_registry()
	LevelManager._levels[1].completed = true
	LevelManager._levels[1].unlocked = true
	LevelManager._levels[2].unlocked = true
	SaveManager.save_progress()
	LevelManager._build_level_registry()
	SaveManager.load_progress()
	assert_eq(LevelManager.get_level_status(1), "completed")
	assert_eq(LevelManager.get_level_status(2), "unlocked")
	assert_eq(LevelManager.get_level_status(3), "locked")


# clear_save resets levels to default (only level 1 unlocked, none completed).
func test_clear_save_resets_to_default() -> void:
	LevelManager._build_level_registry()
	LevelManager._levels[1].completed = true
	LevelManager._levels[2].unlocked = true
	SaveManager.save_progress()
	SaveManager.clear_save()
	assert_eq(LevelManager.get_level_status(1), "unlocked")
	assert_eq(LevelManager.get_level_status(2), "locked")
	assert_false(FileAccess.file_exists(SAVE_PATH))


# get_or_create_pair_id returns the same ID on repeated calls.
func test_pair_id_is_stable_across_calls() -> void:
	var id1 := SaveManager.get_or_create_pair_id()
	var id2 := SaveManager.get_or_create_pair_id()
	assert_eq(id1, id2)
	assert_false(id1.is_empty())


# get_or_create_pair_id produces a non-empty string even when no file exists.
func test_pair_id_is_generated_when_no_file() -> void:
	var id := SaveManager.get_or_create_pair_id()
	assert_false(id.is_empty())
	assert_eq(id.length(), 36)
