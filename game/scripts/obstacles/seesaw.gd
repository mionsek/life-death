extends Node2D
class_name Seesaw

# Angular acceleration applied per unit of weight imbalance (rad/s²).
const TORQUE := 6.0
# Instant kick given when a body lands on an arm (or shoves one from below).
# Torque alone only eases the plank over, so jumping onto it barely moved it;
# this makes the impact itself throw the seesaw.
const IMPACT_IMPULSE := 1.8
# Max rotation speed (rad/s) — prevents infinite spin-up while still allowing full 360° turns.
const MAX_ANGULAR_VELOCITY := 5.0
# Constant angular friction (rad/s²) applied when balanced — coasts smoothly to a stop.
const ANGULAR_FRICTION := 2.0

var _angular_velocity: float = 0.0
var _left_count: int = 0
var _right_count: int = 0
# Bodies pushing up from underneath each arm (raises that arm).
var _left_under_count: int = 0
var _right_under_count: int = 0


func _physics_process(delta: float) -> void:
	# In multiplayer: only the server drives physics; clients receive synced rotation.
	if NetworkManager.state == NetworkManager.State.CONNECTED and not multiplayer.is_server():
		return
	_update_rotation(delta)


# Applies torque while weighted; coasts to a gentle stop (keeping its angle) when balanced.
func _update_rotation(delta: float) -> void:
	# Weight on top pushes that side down; a body under an arm pushes it up (like weight on the far side).
	var net_weight := float((_right_count + _left_under_count) - (_left_count + _right_under_count))
	if net_weight != 0.0:
		_angular_velocity += net_weight * TORQUE * delta
		_angular_velocity = clampf(_angular_velocity, -MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY)
	else:
		# Slow down by a fixed amount each second until it halts, keeping the current tilt.
		var drop := ANGULAR_FRICTION * delta
		if absf(_angular_velocity) <= drop:
			_angular_velocity = 0.0
		else:
			_angular_velocity -= signf(_angular_velocity) * drop
	# Rotate freely through a full circle; wrap keeps the stored value bounded.
	$Plank.rotation = wrapf($Plank.rotation + _angular_velocity * delta, -PI, PI)
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		_rpc_sync_rotation.rpc($Plank.rotation)


# Landing on an arm (or shoving one from below) kicks the plank straight away.
# The sign matches the torque convention: positive tips the right arm down.
func _impact(direction: float) -> void:
	_angular_velocity = clampf(_angular_velocity + direction * IMPACT_IMPULSE,
		-MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY)


func _on_left_entered(_body: Node) -> void:
	_left_count += 1
	_impact(-1.0)


func _on_left_exited(_body: Node) -> void:
	_left_count = max(0, _left_count - 1)


func _on_right_entered(_body: Node) -> void:
	_right_count += 1
	_impact(1.0)


func _on_right_exited(_body: Node) -> void:
	_right_count = max(0, _right_count - 1)


func _on_left_under_entered(_body: Node) -> void:
	_left_under_count += 1
	_impact(1.0)


func _on_left_under_exited(_body: Node) -> void:
	_left_under_count = max(0, _left_under_count - 1)


func _on_right_under_entered(_body: Node) -> void:
	_right_under_count += 1
	_impact(-1.0)


func _on_right_under_exited(_body: Node) -> void:
	_right_under_count = max(0, _right_under_count - 1)


# Returns the current plank rotation in radians (wrapped to [-PI, PI]).
func get_tilt() -> float:
	return $Plank.rotation


# Syncs plank rotation to the client in multiplayer.
@rpc("authority", "call_remote", "unreliable")
func _rpc_sync_rotation(rot: float) -> void:
	$Plank.rotation = rot
