extends StaticBody2D
class_name Door

# Unique ID used by levers, panels and pressure plates to target this door.
@export var door_id: String = "door_01"

# Portcullis strip: frame 0 = shut (gate down, red light), last = open (gate
# retracted, green light). Opening animates through the frames in place — the
# stone frame stays put, only the gate rises, so a character walks through.
const OPEN_FRAME := 3
const OPEN_TIME := 0.5
const CLOSE_TIME := 0.3

var _is_open: bool = false
var _tween: Tween


func _ready() -> void:
	add_to_group("door_" + door_id)
	if has_node("Vis"):
		# subtle pairing tint so the door and its trigger read as a set
		$Vis.self_modulate = id_color(door_id).lerp(Color.WHITE, 0.7)
		_set_frame(0)


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


# Animates the gate open or shut on this peer. Hold-style triggers (pressure
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
		_tween.tween_method(_set_frame, float(_current_frame()), float(OPEN_FRAME), OPEN_TIME)
		_tween.tween_callback(_disable_collision)
	else:
		if has_node("Shape"):
			$Shape.set_deferred("disabled", false)
		_tween.tween_method(_set_frame, float(_current_frame()), 0.0, CLOSE_TIME)


# Current gate frame (0..OPEN_FRAME); falls back to the logical state when the
# visual is not an animatable sprite (e.g. in unit tests).
func _current_frame() -> int:
	if has_node("Vis") and $Vis is Sprite2D:
		return $Vis.frame
	return OPEN_FRAME if _is_open else 0


# Sets the gate frame; no-op when the visual is not a sprite strip.
func _set_frame(v: float) -> void:
	if has_node("Vis") and $Vis is Sprite2D:
		$Vis.frame = clampi(int(round(v)), 0, OPEN_FRAME)


# Disables the collision shape after the open animation finishes.
func _disable_collision() -> void:
	if _is_open and has_node("Shape"):
		$Shape.disabled = true


# Returns whether the door is currently open.
func is_open() -> bool:
	return _is_open
