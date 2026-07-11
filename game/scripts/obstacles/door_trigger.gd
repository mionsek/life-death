extends Area2D

# Shared base for one-shot obstacles that open a door (levers, puzzle panels).
# Activation is server-authoritative: a request is routed through the server, which
# broadcasts it to every peer so the trigger state, its visuals and the target door
# all stay in sync in multiplayer. Offline it simply applies locally.

# ID of the door this trigger opens when activated.
@export var target_door_id: String = "door_01"

var _triggered: bool = false


# Requests activation; routes through the server in multiplayer, applies directly when offline.
func _request_trigger() -> void:
	if _triggered:
		return
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		if multiplayer.is_server():
			_rpc_trigger.rpc()
		else:
			_rpc_request_trigger.rpc_id(1)
	else:
		_apply_trigger()


# Client -> server request; only the server acts on it, then broadcasts.
@rpc("any_peer", "call_remote", "reliable")
func _rpc_request_trigger() -> void:
	if not multiplayer.is_server():
		return
	_rpc_trigger.rpc()


# Server -> all peers: apply the activation on every instance.
@rpc("authority", "call_local", "reliable")
func _rpc_trigger() -> void:
	_apply_trigger()


# Applies activation on this peer: marks triggered, runs the subclass effect, opens the door. Idempotent.
func _apply_trigger() -> void:
	if _triggered:
		return
	_triggered = true
	_on_triggered()
	_open_target_door()


# Hook for subclasses to update their own visuals/state when activated.
func _on_triggered() -> void:
	pass


# Finds the linked door by group, or null (with a warning) if misconfigured.
func _find_door() -> Door:
	var doors := get_tree().get_nodes_in_group("door_" + target_door_id)
	if doors.is_empty():
		push_warning("DoorTrigger '%s' found no door with id '%s'." % [name, target_door_id])
		return null
	return doors[0] as Door


# Opens the linked door on this peer (the trigger broadcast already synced the event).
func _open_target_door() -> void:
	var door := _find_door()
	if door:
		door.open_local()
