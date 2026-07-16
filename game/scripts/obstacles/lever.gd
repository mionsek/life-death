extends "res://scripts/obstacles/door_trigger.gd"
class_name Lever

# A toggle lever: each touch flips the handle left<->right and opens or closes
# the paired door to match. The handle is a separate sprite that rotates around
# its joint (HandlePivot), so the sweep is smooth instead of stepping frames.
# Only the peer that owns the touching character originates the flip, which
# then syncs to everyone, so the state stays consistent in multiplayer.

# Handle angle when thrown "on" (rest = 0, pointing left as drawn).
const ON_ANGLE := 1.65   # radians (~95 degrees)
const SWEEP_TIME := 0.3

var _on: bool = false
var _tween: Tween


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# subtle pairing tint so the lever and its door read as a set
	var tint := Door.id_color(target_door_id).lerp(Color.WHITE, 0.7)
	for part in ["LeverBase", "HandlePivot/LeverHandle"]:
		if has_node(part):
			get_node(part).self_modulate = tint


# Flips on contact. In multiplayer only the character's owning peer originates
# the toggle (fires exactly once), then broadcasts it to everyone.
func _on_body_entered(body: Node) -> void:
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		var owner_id: int = body.get_multiplayer_authority() if body else 1
		if multiplayer.get_unique_id() != owner_id:
			return
		_apply_toggle.rpc()
	else:
		_apply_toggle()


# Flips the state on every peer: sweeps the handle and drives the paired door.
@rpc("any_peer", "call_local", "reliable")
func _apply_toggle() -> void:
	_on = not _on
	AudioFx.play("switch")
	_animate_to(_on)
	var door := _find_door()
	if door:
		door.set_open_state(_on)


# Returns whether the lever is thrown (door open). Kept for the trigger tests.
func is_activated() -> bool:
	return _on


# Rotates the handle to the end matching the state.
func _animate_to(on: bool) -> void:
	if not has_node("HandlePivot"):
		return
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property($HandlePivot, "rotation", ON_ANGLE if on else 0.0, SWEEP_TIME)
