extends StaticBody2D
class_name Door

# Unique ID used by levers and panels to target this door.
@export var door_id: String = "door_01"

var _is_open: bool = false


func _ready() -> void:
	add_to_group("door_" + door_id)


# Public entry point. In multiplayer the open is routed through the server so both peers stay in sync.
func open() -> void:
	if _is_open:
		return
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		if multiplayer.is_server():
			_rpc_open.rpc()
		else:
			_rpc_request_open.rpc_id(1)
	else:
		open_local()


# Client -> server request to open; only the server acts on it, then broadcasts.
@rpc("any_peer", "call_remote", "reliable")
func _rpc_request_open() -> void:
	if not multiplayer.is_server():
		return
	_rpc_open.rpc()


# Server -> all peers: perform the open on every instance.
@rpc("authority", "call_local", "reliable")
func _rpc_open() -> void:
	open_local()


# Opens the door on this peer only: animates it upward and disables its collision. Idempotent.
func open_local() -> void:
	if _is_open:
		return
	_is_open = true
	$Vis.modulate = Color(0.4, 0.9, 0.5, 0.35)
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 80.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_disable_collision)


# Disables the collision shape after the open animation finishes.
func _disable_collision() -> void:
	$Shape.disabled = true


# Returns whether the door is currently open.
func is_open() -> bool:
	return _is_open
