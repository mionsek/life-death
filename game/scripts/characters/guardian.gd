extends Player
class_name Guardian

# Guardian of Life — Player 2 character.
# Inherits all movement from Player; unique abilities added in branch 005-character-abilities.

func _ready() -> void:
	# Guardian is controlled only via touch — keyboard belongs to Player 1.
	# WASD (physical keys) used as fallback for single-device PC testing only.
	use_keyboard = false


# Overrides horizontal movement to add WASD support for single-device PC testing.
func _apply_horizontal_movement() -> void:
	var direction := 0.0
	if not multiplayer.has_multiplayer_peer():
		if Input.is_physical_key_pressed(KEY_A):
			direction = -1.0
		elif Input.is_physical_key_pressed(KEY_D):
			direction = 1.0
	if direction == 0.0:
		direction = _touch_direction
	velocity.x = direction * speed


# Requests a jump via W key for single-device PC testing.
func _apply_jump() -> void:
	var jump := _jump_requested
	if not multiplayer.has_multiplayer_peer():
		jump = jump or Input.is_physical_key_pressed(KEY_W)
	if jump and is_on_floor():
		velocity.y = jump_velocity
