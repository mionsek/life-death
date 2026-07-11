extends "res://scripts/obstacles/door_trigger.gd"
class_name Lever

# A lever that opens its target door on first contact. Networking is handled by the base.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Requests activation on first body contact.
func _on_body_entered(_body: Node) -> void:
	_request_trigger()


# Swaps the lever visuals when activated.
func _on_triggered() -> void:
	$VisIdle.visible = false
	$VisActivated.visible = true


# Returns whether this lever has been activated.
func is_activated() -> bool:
	return _triggered
