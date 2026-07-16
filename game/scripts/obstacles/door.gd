extends StaticBody2D
class_name Door

# Unique ID used by levers, panels and pressure plates to target this door.
@export var door_id: String = "door_01"

# The door is built from stacked layers (see Door.tscn) so it animates smoothly
# and the character passes through the doorway — in front of the left jamb
# (DoorBack, z below the character) and behind the right jamb + lintel
# (DoorFront, z above). The red curtain (DoorGate) slides up via a shader;
# DoorLight is a greyscale indicator tinted red (shut) / green (open).
const OPEN_TIME := 0.5
const CLOSE_TIME := 0.35
const LIGHT_SHUT := Color(0.9, 0.15, 0.15)
const LIGHT_OPEN := Color(0.3, 0.95, 0.4)

var _is_open: bool = false
var _open_amount: float = 0.0
var _tween: Tween
var _gate_mat: ShaderMaterial


func _ready() -> void:
	add_to_group("door_" + door_id)
	if has_node("DoorGate"):
		# unique material per instance so doors animate independently
		_gate_mat = ($DoorGate.material as ShaderMaterial).duplicate()
		$DoorGate.material = _gate_mat
		_set_open_amount(0.0)
	if has_node("DoorLight"):
		$DoorLight.modulate = LIGHT_SHUT
	# subtle pairing tint on the stone so the door and its trigger read as a set
	var tint := id_color(door_id).lerp(Color.WHITE, 0.7)
	for jamb in ["DoorBack", "DoorFront"]:
		if has_node(jamb):
			get_node(jamb).self_modulate = tint


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


# Smoothly opens or shuts the door on this peer. Hold-style triggers (pressure
# plates) call this both ways; the collision comes back the moment the door
# starts closing so nobody clips through.
func set_open_state(open: bool) -> void:
	if _is_open == open:
		return
	_is_open = open
	if open:
		AudioFx.play("gate")
	else:
		# collision returns immediately when shutting
		if has_node("Shape"):
			$Shape.set_deferred("disabled", false)
	if _tween:
		_tween.kill()
	var dur := OPEN_TIME if open else CLOSE_TIME
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_parallel(true)
	_tween.tween_method(_set_open_amount, _open_amount, 1.0 if open else 0.0, dur)
	if has_node("DoorLight"):
		_tween.tween_property($DoorLight, "modulate",
			LIGHT_OPEN if open else LIGHT_SHUT, dur)
	_tween.set_parallel(false)
	if open:
		_tween.tween_callback(_disable_collision)


# Drives the gate curtain's retract shader (0 = shut, 1 = fully open).
func _set_open_amount(v: float) -> void:
	_open_amount = v
	if _gate_mat:
		_gate_mat.set_shader_parameter("open_amount", v)


# Disables the collision shape after the open animation finishes.
func _disable_collision() -> void:
	if _is_open and has_node("Shape"):
		$Shape.disabled = true


# Returns whether the door is currently open.
func is_open() -> bool:
	return _is_open
