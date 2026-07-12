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


# The root has a single successor: Earth 2.
func test_complete_root_unlocks_earth_2() -> void:
	LevelManager.complete_level(1)
	assert_eq(LevelManager.get_level_status(2), "unlocked")


# Earth 2 is the triple gateway: Earth 3, Heaven 1 and Hell 1 all unlock.
func test_earth_2_is_triple_gateway() -> void:
	LevelManager.complete_level(2)
	assert_eq(LevelManager.get_level_status(3), "unlocked")
	assert_eq(LevelManager.get_level_status(21), "unlocked")
	assert_eq(LevelManager.get_level_status(41), "unlocked")


# The playable Heaven chain: H1 → H2 → H3 → H4 (sketch nodes 7-8-9-10).
func test_heaven_playable_chain_unlocks() -> void:
	LevelManager.complete_level(21)
	assert_eq(LevelManager.get_level_status(22), "unlocked")
	LevelManager.complete_level(22)
	assert_eq(LevelManager.get_level_status(23), "unlocked")
	LevelManager.complete_level(23)
	assert_eq(LevelManager.get_level_status(24), "unlocked")


# The playable Hell branches: D1 unlocks D2 and D4; D2 unlocks D3.
func test_hell_playable_branches_unlock() -> void:
	LevelManager.complete_level(41)
	assert_eq(LevelManager.get_level_status(42), "unlocked")
	assert_eq(LevelManager.get_level_status(44), "unlocked")
	LevelManager.complete_level(42)
	assert_eq(LevelManager.get_level_status(43), "unlocked")


# Leaf levels have no successors — completing them unlocks nothing new.
func test_leaves_have_no_successors() -> void:
	var before := 0
	for data in LevelManager.get_all_levels():
		if data.unlocked:
			before += 1
	for leaf_id in [6, 24, 43]:
		LevelManager.complete_level(leaf_id)
	var after := 0
	for data in LevelManager.get_all_levels():
		if data.unlocked:
			after += 1
	assert_eq(after, before, "leaf levels must not unlock anything")


# Zone listings return exactly the levels defined in the world graph (sketch: 42).
func test_get_zone_levels_counts() -> void:
	assert_eq(LevelManager.get_zone_levels("earth").size(), 11)
	assert_eq(LevelManager.get_zone_levels("heaven").size(), 16)
	assert_eq(LevelManager.get_zone_levels("hell").size(), 15)


# has_level matches the graph: defined ids exist, undefined ones do not.
func test_has_level_boundaries() -> void:
	assert_true(LevelManager.has_level(1))
	assert_true(LevelManager.has_level(11))
	assert_true(LevelManager.has_level(21))
	assert_true(LevelManager.has_level(36))
	assert_true(LevelManager.has_level(41))
	assert_true(LevelManager.has_level(55))
	assert_false(LevelManager.has_level(0))
	assert_false(LevelManager.has_level(12))
	assert_false(LevelManager.has_level(37))
	assert_false(LevelManager.has_level(56))
	assert_false(LevelManager.has_level(61))


# Stable id mapping: heaven = 20 + index, hell = 40 + index.
func test_make_level_id_mapping() -> void:
	assert_eq(LevelManager.make_level_id("earth", 3), 3)
	assert_eq(LevelManager.make_level_id("heaven", 1), 21)
	assert_eq(LevelManager.make_level_id("hell", 4), 44)


# Exactly the 14 built levels are playable; sketched-only ones are "planned".
func test_playable_vs_planned_levels() -> void:
	for id in [1, 2, 3, 4, 5, 6, 21, 22, 23, 24, 41, 42, 43, 44]:
		assert_true(LevelManager.is_level_playable(id), "level %d should be playable" % id)
	for id in [7, 10, 25, 36, 45, 55]:
		assert_false(LevelManager.is_level_playable(id), "level %d is planned only" % id)


# Every playable level is reachable from the start through playable levels only
# (players must never need a planned level to reach existing content).
func test_playable_levels_reachable_through_playable_only() -> void:
	var reachable := {1: true}
	var frontier := [1]
	while not frontier.is_empty():
		var id: int = frontier.pop_back()
		for next_id in LevelManager.get_level(id).next_ids:
			if not reachable.has(next_id) and LevelManager.is_level_playable(next_id):
				reachable[next_id] = true
				frontier.append(next_id)
	for data in LevelManager.get_all_levels():
		if LevelManager.is_level_playable(data.id):
			assert_true(reachable.has(data.id),
				"playable level %d (%s %d) must be reachable without planned levels" %
				[data.id, data.zone, data.index])
