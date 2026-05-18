extends Node2D

# Connects touch controls to the player after both nodes are ready.
func _ready() -> void:
	$TouchControls.set_player($Player)
