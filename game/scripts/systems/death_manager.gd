extends Node

# Emitted when any player calls die(); listened to by DeathScreen.
signal player_died


# Triggers the death sequence: emits signal and pauses the scene tree.
# Ignores repeated calls if the game is already paused.
func trigger_death() -> void:
	if get_tree().paused:
		return
	player_died.emit()
	get_tree().paused = true
