extends GutTest

# Resets tree state after each test to prevent pause pollution.
func after_each() -> void:
	get_tree().paused = false


# Verifies that trigger_death emits the player_died signal.
func test_trigger_death_emits_player_died_signal() -> void:
	watch_signals(DeathManager)
	DeathManager.trigger_death()
	assert_signal_emitted(DeathManager, "player_died")


# Verifies that a second trigger_death call is ignored when already paused.
func test_trigger_death_does_not_emit_twice_when_already_paused() -> void:
	DeathManager.trigger_death()
	watch_signals(DeathManager)
	DeathManager.trigger_death()
	assert_signal_not_emitted(DeathManager, "player_died")


# Verifies that the tree is paused after trigger_death.
func test_trigger_death_pauses_tree() -> void:
	DeathManager.trigger_death()
	assert_true(get_tree().paused)
