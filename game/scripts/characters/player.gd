extends CharacterBody2D
class_name Player

# Movement speed in pixels per second.
@export var speed: float = 200.0
# Upward velocity applied when a jump is triggered.
@export var jump_velocity: float = -550.0
# Gravity acceleration in pixels per second squared.
@export var gravity: float = 980.0
# Whether this player responds to keyboard input.
@export var use_keyboard: bool = true

# Life and Death repel each other: touching the other character knocks both
# away. While the knockback lasts, steering is disabled — timing your paths
# around your partner is part of the challenge.
const BOUNCE_SPEED := 260.0
const BOUNCE_UP := -160.0
const BOUNCE_TIME := 0.28

# Horizontal direction set by touch controls; persists while button is held.
var _touch_direction: float = 0.0
# Whether a jump was requested via touch this frame.
var _jump_requested: bool = false
# Seconds of remaining knockback; steering is suppressed while positive.
var _bounce_timer: float = 0.0


# Runs every frame (also for remote peers — velocity is synced over the network).
func _process(_delta: float) -> void:
	_update_animation()


# Picks idle/walk/jump animation from the current physics state and flips the
# sprite to face the movement direction. Safe without the Anim node (unit tests).
func _update_animation() -> void:
	if not has_node("Anim"):
		return
	var anim: AnimatedSprite2D = $Anim
	if absf(velocity.x) > 1.0:
		anim.flip_h = velocity.x < 0.0
	if not is_on_floor():
		anim.play("jump")
	elif absf(velocity.x) > 5.0:
		anim.play("walk")
	else:
		anim.play("idle")


func _physics_process(delta: float) -> void:
	if NetworkManager.state == NetworkManager.State.CONNECTED and not is_multiplayer_authority():
		return
	_tick_bounce(delta)
	_apply_gravity(delta)
	_apply_horizontal_movement()
	_apply_jump()
	move_and_slide()
	_check_character_bounce()
	_jump_requested = false
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		_rpc_sync_state.rpc(position, velocity)


# Increases downward velocity when the character is not on the floor.
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


# Sets horizontal velocity; keyboard input overrides touch only when use_keyboard is true.
# During a bounce the knockback velocity is kept and steering is ignored.
func _apply_horizontal_movement() -> void:
	if _bounce_timer > 0.0:
		return
	var direction := 0.0
	if use_keyboard:
		direction = Input.get_axis("ui_left", "ui_right")
	if direction == 0.0:
		direction = _touch_direction
	velocity.x = direction * speed


# Opposites repel: when the slide collides with the other character, both are
# knocked apart. Each device also detects the contact for its own character in
# multiplayer, so applying it to the remote instance is only a local prediction
# that the position sync will confirm.
func _check_character_bounce() -> void:
	if _bounce_timer > 0.0:
		return
	for i in get_slide_collision_count():
		var other: Object = get_slide_collision(i).get_collider()
		if other is Player and other != self:
			var dir := signf(global_position.x - other.global_position.x)
			if dir == 0.0:
				dir = 1.0
			apply_bounce(Vector2(dir * BOUNCE_SPEED, BOUNCE_UP))
			if other._bounce_timer <= 0.0:
				other.apply_bounce(Vector2(-dir * BOUNCE_SPEED, BOUNCE_UP))
			return


# Counts the bounce window down each physics step.
func _tick_bounce(delta: float) -> void:
	_bounce_timer = maxf(_bounce_timer - delta, 0.0)


# Applies a knockback impulse and suppresses steering for BOUNCE_TIME seconds.
func apply_bounce(impulse: Vector2) -> void:
	_bounce_timer = BOUNCE_TIME
	velocity = impulse


# Returns whether this character is currently being knocked back.
func is_bouncing() -> bool:
	return _bounce_timer > 0.0


# Applies upward velocity if on the floor and a jump was requested.
func _apply_jump() -> void:
	var jump := (use_keyboard and Input.is_action_just_pressed("ui_accept")) or _jump_requested
	if jump and is_on_floor():
		velocity.y = jump_velocity


# Sets horizontal movement direction from touch controls (-1 = left, 0 = stop, 1 = right).
func set_touch_direction(direction: float) -> void:
	_touch_direction = direction


# Requests a jump to be applied on the next physics frame.
func request_jump() -> void:
	_jump_requested = true


# Triggers the death sequence via DeathManager.
func die() -> void:
	DeathManager.trigger_death()


# Syncs position and velocity from the authoritative peer to all others.
@rpc("any_peer", "unreliable_ordered")
func _rpc_sync_state(pos: Vector2, vel: Vector2) -> void:
	if not is_multiplayer_authority():
		position = pos
		velocity = vel
