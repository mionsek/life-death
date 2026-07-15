extends "res://scripts/obstacles/door_trigger.gd"
class_name Lever

# A lever that opens its target door on first contact. Networking is handled by the base.


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# carry the paired door's hue so the player can see what this lever opens
	var tint := Door.id_color(target_door_id).lerp(Color.WHITE, 0.35)
	for vis_name in ["VisIdle", "VisActivated"]:
		if has_node(vis_name):
			get_node(vis_name).self_modulate = tint
	if has_node("Label"):
		$Label.add_theme_color_override("font_color", Door.id_color(target_door_id))


# Requests activation on first body contact.
func _on_body_entered(_body: Node) -> void:
	_request_trigger()


# Swaps the lever visuals when activated.
func _on_triggered() -> void:
	AudioFx.play("switch")
	$VisIdle.visible = false
	$VisActivated.visible = true


# Returns whether this lever has been activated.
func is_activated() -> bool:
	return _triggered
