extends Area2D
class_name Lever

# ID of the door this lever controls.
@export var target_door_id: String = "door_01"

var _activated: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Activates the lever on first contact and opens the linked door.
func _on_body_entered(_body: Node) -> void:
	if _activated:
		return
	_activated = true
	$VisIdle.visible = false
	$VisActivated.visible = true
	var door := _find_door()
	if door:
		door.open()


# Finds the door with matching door_id using Godot groups.
func _find_door() -> Node:
	var doors := get_tree().get_nodes_in_group("door_" + target_door_id)
	if doors.is_empty():
		return null
	return doors[0]


# Returns whether this lever has been activated.
func is_activated() -> bool:
	return _activated
