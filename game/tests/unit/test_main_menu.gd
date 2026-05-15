extends GutTest

# Unit tests for MainMenu script behaviour.

var _scene: Control


func before_each() -> void:
	_scene = preload("res://scenes/ui/MainMenu.tscn").instantiate()
	add_child_autofree(_scene)


# Verifies that all expected buttons exist in the scene.
func test_main_menu_has_start_button() -> void:
	assert_not_null(_scene.get_node("VBox/BtnStart"), "Start button should exist")


func test_main_menu_has_settings_button() -> void:
	assert_not_null(_scene.get_node("VBox/BtnSettings"), "Settings button should exist")


func test_main_menu_has_quit_button() -> void:
	assert_not_null(_scene.get_node("VBox/BtnQuit"), "Quit button should exist")


# Verifies that the title label displays the correct game name.
func test_title_label_text() -> void:
	var label: Label = _scene.get_node("VBox/Title")
	assert_eq(label.text, "LIFE & DEATH", "Title should display game name")
