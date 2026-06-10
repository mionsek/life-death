extends CanvasLayer

# Listens for death signal and handles reset/menu actions.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	DeathManager.player_died.connect(_on_player_died)
	$HUD/Panel/BtnTryAgain.pressed.connect(_on_try_again)
	$HUD/Panel/BtnMainMenu.pressed.connect(_on_main_menu)


# Shows the death screen when a player dies.
func _on_player_died() -> void:
	visible = true


# Reloads the current level from the beginning (synced across peers in multiplayer).
func _on_try_again() -> void:
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		_sync_try_again.rpc()
	else:
		get_tree().paused = false
		get_tree().reload_current_scene()


@rpc("any_peer", "call_local", "reliable")
func _sync_try_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


# Returns to the main menu (synced across peers in multiplayer).
func _on_main_menu() -> void:
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		_sync_main_menu.rpc()
	else:
		_do_main_menu()


@rpc("any_peer", "call_local", "reliable")
func _sync_main_menu() -> void:
	_do_main_menu()


func _do_main_menu() -> void:
	NetworkManager.stop()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
