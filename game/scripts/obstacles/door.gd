extends StaticBody2D
class_name Door

# Unique ID used by levers, panels and pressure plates to target this door.
@export var door_id: String = "door_01"

# How far up the door slides when opening.
const OPEN_OFFSET := 80.0

var _is_open: bool = false
var _closed_y: float = 0.0
var _tween: Tween


func _ready() -> void:
	add_to_group("door_" + door_id)
	_closed_y = position.y
	# every trigger paired with this door carries the same hue (see id_color)
	if has_node("Vis"):
		$Vis.self_modulate = id_color(door_id).lerp(Color.WHITE, 0.25)


# Deterministic pairing colour for a door id — the door and all of its
# triggers (levers, plates) tint themselves with it so the player can see at
# a glance what opens what.
static func id_color(id: String) -> Color:
	return Color.from_hsv(float(posmod(hash(id), 360)) / 360.0, 0.65, 1.0)


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


# Opens the door on this peer only (one-shot triggers like levers). Idempotent.
func open_local() -> void:
	set_open_state(true)


# Slides the door open or shut on this peer. Hold-style triggers (pressure
# plates) call this both ways; the collision comes back the moment the door
# starts closing so nobody clips through.
func set_open_state(open: bool) -> void:
	if _is_open == open:
		return
	_is_open = open
	if open:
		AudioFx.play("gate")
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if open:
		if has_node("Vis"):
			$Vis.modulate = Color(0.4, 0.9, 0.5, 0.35)
		_tween.tween_property(self, "position:y", _closed_y - OPEN_OFFSET, 0.5)\
			.set_ease(Tween.EASE_IN_OUT)
		_tween.tween_callback(_disable_collision)
	else:
		if has_node("Vis"):
			$Vis.modulate = Color.WHITE
		if has_node("Shape"):
			$Shape.set_deferred("disabled", false)
		_tween.tween_property(self, "position:y", _closed_y, 0.3)\
			.set_ease(Tween.EASE_IN_OUT)


# Disables the collision shape after the open animation finishes.
func _disable_collision() -> void:
	if _is_open and has_node("Shape"):
		$Shape.disabled = true


# Returns whether the door is currently open.
func is_open() -> bool:
	return _is_open
