extends Node

# Emitted when any player calls die(); listened to by DeathScreen.
signal player_died


# Triggers the death sequence: broadcasts via RPC in multiplayer, runs locally in single-player.
# Ignores repeated calls if the game is already paused.
func trigger_death() -> void:
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		_broadcast_death.rpc()
	else:
		_execute_death()


# Executes death on all peers simultaneously in multiplayer.
@rpc("any_peer", "call_local", "reliable")
func _broadcast_death() -> void:
	_execute_death()


# Pauses the tree and emits the death signal.
func _execute_death() -> void:
	if get_tree().paused:
		return
	player_died.emit()
	get_tree().paused = true
