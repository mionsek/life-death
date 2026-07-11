extends Node2D

# Tracks which players have reached the exit portal.
var _players_at_exit: Array[String] = []


func _ready() -> void:
	$TouchControls.set_player($Player)
	$TouchControlsP2.set_player($Guardian)
	_setup_multiplayer_authority()
	_connect_exit_portals.call_deferred()
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		NetworkManager.peer_disconnected_in_game.connect(_on_peer_disconnected)


# Auto-connects all ExitPortal child nodes so the designer only needs to add the scene.
# Called deferred so all children are ready before scanning.
func _connect_exit_portals() -> void:
	for child in get_children():
		if child.get_script() == null:
			continue
		var path: String = child.get_script().resource_path
		if "exit_portal" not in path:
			continue
		if not child.character_entered.is_connected(on_exit_entered):
			child.character_entered.connect(on_exit_entered)
		if not child.character_exited_portal.is_connected(on_exit_exited):
			child.character_exited_portal.connect(on_exit_exited)


# Called by the exit portal when a character body enters it.
# Level completes only when both characters are inside their exits simultaneously.
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
