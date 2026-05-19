extends Node2D

# Connects both touch control sets to their respective players after scene is ready.
func _ready() -> void:
	$TouchControls.set_player($Player)
	$TouchControlsP2.set_player($Guardian)
