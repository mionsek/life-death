extends Node2D
class_name Seesaw

# Maximum tilt angle in degrees.
const MAX_ANGLE_DEG := 25.0
# How fast the seesaw rotates toward the target angle (radians per second).
const ROTATION_SPEED := 1.8

var _left_count: int = 0
var _right_count: int = 0


func _process(delta: float) -> void:
	# In multiplayer: only the server drives physics; clients receive synced rotation.
	if NetworkManager.state == NetworkManager.State.CONNECTED and not multiplayer.is_server():
		return
	_update_rotation(delta)


# Calculates target angle and lerps the plank toward it.
func _update_rotation(delta: float) -> void:
	var target_angle := 0.0
	if _left_count > _right_count:
		target_angle = -deg_to_rad(MAX_ANGLE_DEG)
	elif _right_count > _left_count:
		target_angle = deg_to_rad(MAX_ANGLE_DEG)
	$Plank.rotation = lerp_angle($Plank.rotation, target_angle, ROTATION_SPEED * delta)
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		_rpc_sync_rotation.rpc($Plank.rotation)


func _on_left_entered(_body: Node) -> void:
	_left_count += 1


func _on_left_exited(_body: Node) -> void:
	_left_count = max(0, _left_count - 1)


func _on_right_entered(_body: Node) -> void:
	_right_count += 1


func _on_right_exited(_body: Node) -> void:
	_right_count = max(0, _right_count - 1)


# Returns current tilt: negative = left down, positive = right down, 0 = balanced.
func get_tilt() -> float:
	return $Plank.rotation


# Syncs plank rotation to the client in multiplayer.
@rpc("authority", "call_remote", "unreliable")
func _rpc_sync_rotation(rot: float) -> void:
	$Plank.rotation = rot
