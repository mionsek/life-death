extends GutTest

# AudioFx autoload: effect players spawn on the SFX bus and keep playing while
# the tree is paused (so the level-complete jingle plays over the paused
# banner), then free themselves.


func before_each() -> void:
	# Free synchronously so a leftover player never bleeds into the next test.
	for child in AudioFx.get_children():
		AudioFx.remove_child(child)
		child.free()


func test_play_spawns_sfx_bus_player_that_ignores_pause() -> void:
	AudioFx.play("level_complete")
	var players := AudioFx.get_children()
	assert_eq(players.size(), 1, "one player should be spawned")
	var player: AudioStreamPlayer = players[0]
	assert_eq(player.bus, "SFX")
	assert_eq(player.process_mode, Node.PROCESS_MODE_ALWAYS,
		"effects must keep playing while the game is paused")


func test_unknown_sound_spawns_nothing() -> void:
	AudioFx.play("does_not_exist")
	assert_eq(AudioFx.get_children().size(), 0)
