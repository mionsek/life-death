extends Control

# Currently displayed zone ("earth", "heaven", "hell").
var _current_zone: String = "earth"

# Preloaded button scene — instantiated per level slot.
const SLOT_COUNT: int = 20


func _ready() -> void:
	$VBox/HZone/BtnEarth.pressed.connect(func(): _show_zone("earth"))
	$VBox/HZone/BtnHeaven.pressed.connect(func(): _show_zone("heaven"))
	$VBox/HZone/BtnHell.pressed.connect(func(): _show_zone("hell"))
	$VBox/BtnBack.pressed.connect(_on_back_pressed)
	_show_zone("earth")


# Rebuilds the level grid for the selected zone.
func _show_zone(zone: String) -> void:
	_current_zone = zone
	$VBox/LblZone.text = zone.capitalize()

	# Highlight the active zone tab.
	$VBox/HZone/BtnEarth.disabled = (zone == "earth")
	$VBox/HZone/BtnHeaven.disabled = (zone == "heaven")
	$VBox/HZone/BtnHell.disabled = (zone == "hell")

	var grid := $VBox/Grid
	for child in grid.get_children():
		child.queue_free()

	var levels := LevelManager.get_zone_levels(zone)
	for data in levels:
		var btn := Button.new()
		var status := LevelManager.get_level_status(data.id)
		btn.text = "%d" % data.index
		btn.custom_minimum_size = Vector2(40, 40)
		match status:
			"completed":
				btn.text = "✓%d" % data.index
				btn.disabled = false
			"unlocked":
				btn.disabled = false
			"locked":
				btn.disabled = true
		if not btn.disabled:
			var level_id := data.id
			btn.pressed.connect(func(): _on_level_selected(level_id))
		grid.add_child(btn)


# Starts loading the selected level.
func _on_level_selected(level_id: int) -> void:
	LevelManager.load_level(level_id)


# Returns to the main menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
