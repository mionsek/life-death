extends GutTest

# Integration: every level defined in the world graph (earth, heaven and hell)
# instantiates cleanly, has both exit portals auto-connected by level_base and
# spawns the minimap. This is the guard against registering levels whose scene
# files do not exist (the old registry crash).

# All playable levels load, wire their exits and create a minimap.
# Planned (sketched-only) levels are skipped — they have no scene yet.
func test_all_world_levels_load_and_wire() -> void:
	for data in LevelManager.get_all_levels():
		var label := "%s %d (id %d)" % [data.zone, data.index, data.id]
		if not LevelManager.is_level_playable(data.id):
			continue
		var scene: PackedScene = load(data.scene_path)
		assert_not_null(scene, label + ": loads as PackedScene")
		var level := scene.instantiate()
		add_child_autofree(level)
		# _connect_exit_portals() is call_deferred in _ready(); let it run.
		await get_tree().process_frame
		await get_tree().process_frame

		var guardian_exit := level.get_node_or_null("ExitPortalGuardian")
		var player_exit := level.get_node_or_null("ExitPortalPlayer")
		assert_not_null(guardian_exit, label + ": has ExitPortalGuardian")
		assert_not_null(player_exit, label + ": has ExitPortalPlayer")
		if guardian_exit and player_exit:
			assert_true(guardian_exit.character_entered.is_connected(level.on_exit_entered),
				label + ": guardian exit auto-connected")
			assert_true(player_exit.character_entered.is_connected(level.on_exit_entered),
				label + ": player exit auto-connected")

		var found_minimap := false
		for child in level.get_children():
			if child is CanvasLayer and child.has_method("setup"):
				found_minimap = true
		assert_true(found_minimap, label + ": minimap instantiated")
