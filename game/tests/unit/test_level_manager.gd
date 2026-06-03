extends GutTest

# Resets LevelManager state between tests by rebuilding the registry.
func before_each() -> void:
	LevelManager._build_level_registry()
	LevelManager.current_level_id = 0


# Level 1 (Earth zone, index 1) is unlocked by default.
func test_level_1_is_unlocked_by_default() -> void:
	assert_eq(LevelManager.get_level_status(1), "unlocked")


# All other Earth levels start locked.
func test_levels_above_1_start_locked() -> void:
	assert_eq(LevelManager.get_level_status(2), "locked")
	assert_eq(LevelManager.get_level_status(10), "locked")
	assert_eq(LevelManager.get_level_status(20), "locked")


# Completing a level marks it as completed.
func test_complete_level_marks_it_completed() -> void:
	LevelManager.complete_level(1)
	assert_eq(LevelManager.get_level_status(1), "completed")


# Completing a level unlocks the next one in the same zone.
func test_complete_level_unlocks_next() -> void:
	LevelManager.complete_level(1)
	assert_eq(LevelManager.get_level_status(2), "unlocked")


# Completing the last level in a zone does NOT unlock a level in the next zone.
func test_completing_last_earth_level_does_not_unlock_heaven() -> void:
	# Manually unlock and complete levels 1-19 to reach level 20.
	for i in range(1, 20):
		LevelManager.complete_level(i)
	LevelManager.complete_level(20)
	# Level 21 is heaven zone, should remain locked.
	assert_eq(LevelManager.get_level_status(21), "locked")


# get_zone_levels returns exactly 20 levels for the earth zone.
func test_get_zone_levels_returns_correct_count_for_earth() -> void:
	var levels := LevelManager.get_zone_levels("earth")
	assert_eq(levels.size(), 20)


# has_level returns true for valid ids and false for invalid.
func test_has_level_boundaries() -> void:
	assert_true(LevelManager.has_level(1))
	assert_true(LevelManager.has_level(60))
	assert_false(LevelManager.has_level(0))
	assert_false(LevelManager.has_level(61))
