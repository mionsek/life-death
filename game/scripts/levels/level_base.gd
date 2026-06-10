extends Node2D

# Tracks which players have reached the exit portal.
var _players_at_exit: Array[String] = []


func _ready() -> void:
	$TouchControls.set_player($Player)
	$TouchControlsP2.set_player($Guardian)
	_setup_multiplayer_authority()
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		NetworkManager.peer_disconnected_in_game.connect(_on_peer_disconnected)


# Called by the exit portal when a character body enters it.
func on_exit_entered(body: Node) -> void:
	var body_name := body.name
	if body_name in _players_at_exit:
		return
	_players_at_exit.append(body_name)
	if _players_at_exit.size() >= 2:
		_complete_level()


# Called by the exit portal when a character body leaves it.
func on_exit_exited(body: Node) -> void:
	_players_at_exit.erase(body.name)


# Wrapper for hazard Area2D body_entered signal — discards the body argument.
func _on_hazard_entered(_body: Node) -> void:
	DeathManager.trigger_death()


# Marks the current level complete and returns to level select.
func _complete_level() -> void:
	LevelManager.complete_level(LevelManager.current_level_id)
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")


# Assigns physics authority so each device controls its own character.
func _setup_multiplayer_authority() -> void:
	if NetworkManager.state != NetworkManager.State.CONNECTED:
		return
	$Player.set_multiplayer_authority(1)
	var guardian_authority: int
	if multiplayer.is_server():
		guardian_authority = NetworkManager.client_peer_id
	else:
		guardian_authority = multiplayer.get_unique_id()
	$Guardian.set_multiplayer_authority(guardian_authority)


# Returns to main menu when the remote peer disconnects mid-game.
func _on_peer_disconnected() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
