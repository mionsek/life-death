extends StaticBody2D
class_name Door

# Unique ID used by levers and panels to target this door.
@export var door_id: String = "door_01"

var _is_open: bool = false


func _ready() -> void:
	add_to_group("door_" + door_id)


# Opens the door: animates it upward and disables its collision.
func open() -> void:
	if _is_open:
		return
	_is_open = true
	$Vis.color = Color(0.4, 0.6, 0.4, 0.3)
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 80.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_disable_collision)


# Disables the collision shape after the open animation finishes.
func _disable_collision() -> void:
	$Shape.disabled = true


# Returns whether the door is currently open.
func is_open() -> bool:
	return _is_open
