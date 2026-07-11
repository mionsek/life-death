extends GutTest

# Resets LevelManager state between tests by rebuilding the registry.
func before_each() -> void:
	LevelManager._build_level_registry()
	LevelManager.current_level_id = 0


# Level 1 (Earth hub) is unlocked by default.
func test_level_1_is_unlocked_by_default() -> void:
	assert_eq(LevelManager.get_level_status(1), "unlocked")


# Every other level starts locked (earth tail, heaven entry, hell entry).
func test_other_levels_start_locked() -> void:
	assert_eq(LevelManager.get_level_status(2), "locked")
	assert_eq(LevelManager.get_level_status(21), "locked")
	assert_eq(LevelManager.get_level_status(41), "locked")


# Completing a level marks it as completed.
func test_complete_level_marks_it_completed() -> void:
	LevelManager.complete_level(1)
	assert_eq(LevelManager.get_level_status(1), "completed")


# The hub unlocks both of its graph successors (east and west earth arms).
func test_complete_hub_unlocks_both_arms() -> void:
	LevelManager.complete_level(1)
	assert_eq(LevelManager.get_level_status(2), "unlocked")
	assert_eq(LevelManager.get_level_status(5), "unlocked")


# Earth 3 is the gateway to Heaven: completing it unlocks Earth 4 AND Heaven 1.
func test_earth_3_unlocks_heaven_entry() -> void:
	LevelManager.complete_level(3)
	assert_eq(LevelManager.get_level_status(4), "unlocked")
	assert_eq(LevelManager.get_level_status(21), "unlocked")


# Earth 5 is the gateway to Hell: completing it unlocks Earth 6 AND Hell 1.
func test_earth_5_unlocks_hell_entry() -> void:
	LevelManager.complete_level(5)
	assert_eq(LevelManager.get_level_status(6), "unlocked")
	assert_eq(LevelManager.get_level_status(41), "unlocked")


# Heaven levels chain upward: each unlocks the next until the summit diamond.
func test_heaven_chain_unlocks_in_order() -> void:
	LevelManager.complete_level(21)
	assert_eq(LevelManager.get_level_status(22), "unlocked")
	LevelManager.complete_level(22)
	assert_eq(LevelManager.get_level_status(23), "unlocked")
	LevelManager.complete_level(23)
	assert_eq(LevelManager.get_level_status(24), "unlocked")


# Arm-end levels (diamonds) have no successors — completing them unlocks nothing new.
func test_arm_ends_have_no_successors() -> void:
	var before := 0
	for data in LevelManager.get_all_levels():
		if data.unlocked:
			before += 1
	LevelManager.complete_level(24)
	LevelManager.complete_level(44)
	var after := 0
	for data in LevelManager.get_all_levels():
		if data.unlocked:
			after += 1
	assert_eq(after, before, "diamond levels must not unlock anything")


# Zone listings return exactly the levels defined in the world graph.
func test_get_zone_levels_counts() -> void:
	assert_eq(LevelManager.get_zone_levels("earth").size(), 6)
	assert_eq(LevelManager.get_zone_levels("heaven").size(), 4)
	assert_eq(LevelManager.get_zone_levels("hell").size(), 4)


# has_level matches the graph: defined ids exist, undefined ones do not.
func test_has_level_boundaries() -> void:
	assert_true(LevelManager.has_level(1))
	assert_true(LevelManager.has_level(6))
	assert_true(LevelManager.has_level(21))
	assert_true(LevelManager.has_level(24))
	assert_true(LevelManager.has_level(41))
	assert_true(LevelManager.has_level(44))
	assert_false(LevelManager.has_level(0))
	assert_false(LevelManager.has_level(7))
	assert_false(LevelManager.has_level(25))
	assert_false(LevelManager.has_level(61))


# Stable id mapping: heaven = 20 + index, hell = 40 + index.
func test_make_level_id_mapping() -> void:
	assert_eq(LevelManager.make_level_id("earth", 3), 3)
	assert_eq(LevelManager.make_level_id("heaven", 1), 21)
	assert_eq(LevelManager.make_level_id("hell", 4), 44)


# Every level in the registry has an existing scene file (crash-fix guarantee).
func test_all_registry_levels_are_playable() -> void:
	for data in LevelManager.get_all_levels():
		assert_true(LevelManager.is_level_playable(data.id),
			"level %d (%s %d) should have a scene file" % [data.id, data.zone, data.index])
