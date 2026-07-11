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


# The root splits like a binary tree: upper and lower earth branches unlock.
func test_complete_root_unlocks_both_branches() -> void:
	LevelManager.complete_level(1)
	assert_eq(LevelManager.get_level_status(2), "unlocked")
	assert_eq(LevelManager.get_level_status(3), "unlocked")


# Earth 2 (upper branch) is the gateway to Heaven: unlocks Heaven 1 AND Earth 4.
func test_earth_2_unlocks_heaven_entry() -> void:
	LevelManager.complete_level(2)
	assert_eq(LevelManager.get_level_status(21), "unlocked")
	assert_eq(LevelManager.get_level_status(4), "unlocked")


# Earth 3 (lower branch) is the gateway to Hell: unlocks Earth 5 AND Hell 1.
func test_earth_3_unlocks_hell_entry() -> void:
	LevelManager.complete_level(3)
	assert_eq(LevelManager.get_level_status(5), "unlocked")
	assert_eq(LevelManager.get_level_status(41), "unlocked")


# Heaven 1 splits into two branches; Heaven 3 leads on to the summit diamond.
func test_heaven_tree_unlocks() -> void:
	LevelManager.complete_level(21)
	assert_eq(LevelManager.get_level_status(22), "unlocked")
	assert_eq(LevelManager.get_level_status(23), "unlocked")
	LevelManager.complete_level(23)
	assert_eq(LevelManager.get_level_status(24), "unlocked")


# Leaf levels (diamonds) have no successors — completing them unlocks nothing new.
func test_leaves_have_no_successors() -> void:
	var before := 0
	for data in LevelManager.get_all_levels():
		if data.unlocked:
			before += 1
	for leaf_id in [5, 6, 22, 24, 42, 44]:
		LevelManager.complete_level(leaf_id)
	var after := 0
	for data in LevelManager.get_all_levels():
		if data.unlocked:
			after += 1
	assert_eq(after, before, "leaf levels must not unlock anything")


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
