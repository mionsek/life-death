extends GutTest

# Integration: the reworked Earth level scenes load cleanly, expose both renamed exit
# portals, and level_base auto-connects them for exit tracking (no explicit .tscn wiring).

var _scene_paths := {
	"01": "res://scenes/levels/earth/Level_Earth_01.tscn",
	"02": "res://scenes/levels/earth/Level_Earth_02.tscn",
}


# Both Earth levels instantiate and have their exit portals auto-connected to on_exit_entered.
func test_earth_levels_load_and_wire_exits() -> void:
	for key in _scene_paths:
		var scene: PackedScene = load(_scene_paths[key])
		assert_not_null(scene, "Level %s should load as a PackedScene" % key)
		var level := scene.instantiate()
		add_child_autofree(level)
		# _connect_exit_portals() is call_deferred in _ready(); let it run.
		await get_tree().process_frame
		await get_tree().process_frame

		var guardian_exit := level.get_node_or_null("ExitPortalGuardian")
		var player_exit := level.get_node_or_null("ExitPortalPlayer")
		assert_not_null(guardian_exit, "Level %s should have ExitPortalGuardian" % key)
		assert_not_null(player_exit, "Level %s should have ExitPortalPlayer" % key)

		if guardian_exit and player_exit:
			assert_true(
				guardian_exit.character_entered.is_connected(level.on_exit_entered),
				"Level %s: guardian exit should be auto-connected" % key)
			assert_true(
				player_exit.character_entered.is_connected(level.on_exit_entered),
				"Level %s: player exit should be auto-connected" % key)
