extends CharacterBody2D
class_name Player

# Movement speed in pixels per second.
@export var speed: float = 200.0
# Upward velocity applied when a jump is triggered.
@export var jump_velocity: float = -550.0
# Gravity acceleration in pixels per second squared.
@export var gravity: float = 980.0

# Horizontal direction set by touch controls; persists while button is held.
var _touch_direction: float = 0.0
# Whether a jump was requested via touch this frame.
var _jump_requested: bool = false


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_horizontal_movement()
	_apply_jump()
	move_and_slide()
	_jump_requested = false


# Increases downward velocity when the character is not on the floor.
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


# Sets horizontal velocity; keyboard input (arrow keys) overrides touch input.
func _apply_horizontal_movement() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction == 0.0:
		direction = _touch_direction
	velocity.x = direction * speed


# Applies upward velocity if on the floor and a jump was requested.
func _apply_jump() -> void:
	var jump := Input.is_action_just_pressed("ui_accept") or _jump_requested
	if jump and is_on_floor():
		velocity.y = jump_velocity


# Sets horizontal movement direction from touch controls (-1 = left, 0 = stop, 1 = right).
func set_touch_direction(direction: float) -> void:
	_touch_direction = direction


# Requests a jump to be applied on the next physics frame.
func request_jump() -> void:
	_jump_requested = true
