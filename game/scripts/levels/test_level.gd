extends Node2D

# Connects both touch control sets to their respective players after scene is ready.
func _ready() -> void:
	$TouchControls.set_player($Player)
	$TouchControlsP2.set_player($Guardian)
	_setup_multiplayer_authority()
	if multiplayer.has_multiplayer_peer():
		NetworkManager.peer_disconnected_in_game.connect(_on_peer_disconnected)


# Assigns physics authority so each device only simulates its own character.
func _setup_multiplayer_authority() -> void:
	if not multiplayer.has_multiplayer_peer():
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
