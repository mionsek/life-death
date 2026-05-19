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


# Reloads the current level from the beginning.
func _on_try_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


# Returns to the main menu.
func _on_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
