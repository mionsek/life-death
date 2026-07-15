extends "res://scripts/obstacles/door_trigger.gd"
class_name Lever

# A toggle lever: each touch flips it left<->right and opens or closes the
# paired door to match. The 4-frame handle sweeps between the two ends. Only
# the peer that owns the touching character originates the flip, which then
# syncs to everyone, so the state stays consistent in multiplayer.

const FRAMES := 4
const SWEEP_TIME := 0.3

var _on: bool = false
var _tween: Tween


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if has_node("Vis"):
		# subtle pairing tint so the lever and its door read as a set
		$Vis.self_modulate = Door.id_color(target_door_id).lerp(Color.WHITE, 0.7)
		_set_frame(0)


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


# Tweens the handle to the end matching the state.
func _animate_to(on: bool) -> void:
	var target := (FRAMES - 1) if on else 0
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_frame, float(_current_frame()), float(target), SWEEP_TIME)


func _current_frame() -> int:
	if has_node("Vis") and $Vis is Sprite2D:
		return $Vis.frame
	return (FRAMES - 1) if _on else 0


func _set_frame(v: float) -> void:
	if has_node("Vis") and $Vis is Sprite2D:
		$Vis.frame = clampi(int(round(v)), 0, FRAMES - 1)
