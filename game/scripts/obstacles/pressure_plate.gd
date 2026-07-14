extends Area2D
class_name PressurePlate

# A hold-style trigger: the target door stays open only while at least one
# character stands on the plate — step off and it slams shut. Pairs of plates
# on both sides of a door let the duo cross one at a time. Both peers see the
# same synced character positions, so the state is applied locally on each
# device (same pattern as hazards and pickups).

# ID of the door this plate holds open.
@export var target_door_id: String = "door_01"

var _bodies: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# carry the paired door's hue so the player can see what this plate opens
	var tint := Door.id_color(target_door_id)
	for vis_name in ["VisUp", "VisDown"]:
		if has_node(vis_name):
			get_node(vis_name).self_modulate = tint


func _on_body_entered(_body: Node) -> void:
	_bodies += 1
	if _bodies == 1:
		_set_pressed(true)


func _on_body_exited(_body: Node) -> void:
	_bodies = maxi(_bodies - 1, 0)
	if _bodies == 0:
		_set_pressed(false)


# Applies the plate state: swaps the visual and drives the paired door.
func _set_pressed(pressed: bool) -> void:
	if has_node("VisUp"):
		$VisUp.visible = not pressed
	if has_node("VisDown"):
		$VisDown.visible = pressed
	var doors := get_tree().get_nodes_in_group("door_" + target_door_id)
	if doors.is_empty():
		push_warning("PressurePlate '%s' found no door with id '%s'." % [name, target_door_id])
		return
	doors[0].set_open_state(pressed)


# Returns whether anything is standing on the plate.
func is_pressed() -> bool:
	return _bodies > 0
