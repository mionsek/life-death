extends Control

# Handles main menu button interactions.

func _ready() -> void:
	$VBox/BtnStart.pressed.connect(_on_start_pressed)
	$VBox/BtnSettings.pressed.connect(_on_settings_pressed)
	$VBox/BtnQuit.pressed.connect(_on_quit_pressed)


# Navigates to the level selection screen.
func _on_start_pressed() -> void:
	pass  # TODO: get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")


# Opens the settings screen.
func _on_settings_pressed() -> void:
	pass  # TODO: get_tree().change_scene_to_file("res://scenes/ui/Settings.tscn")


# Exits the application.
func _on_quit_pressed() -> void:
	get_tree().quit()
