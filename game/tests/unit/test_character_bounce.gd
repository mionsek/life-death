extends GutTest

# Opposites repel: touching the other character knocks both away and briefly
# disables steering. Uses script instances driven directly (no physics step).

var _player: Player
var _guardian: Guardian


func before_each() -> void:
	_player = preload("res://scenes/characters/Player.tscn").instantiate()
	_guardian = preload("res://scenes/characters/Guardian.tscn").instantiate()
	add_child_autofree(_player)
	add_child_autofree(_guardian)


# apply_bounce sets the knockback velocity and starts the bounce window.
func test_apply_bounce_sets_velocity_and_timer() -> void:
	_player.apply_bounce(Vector2(260, -160))
	assert_eq(_player.velocity, Vector2(260, -160))
	assert_true(_player.is_bouncing())


# While bouncing, the Reaper's steering does not override the knockback.
func test_player_steering_suppressed_during_bounce() -> void:
	_player.apply_bounce(Vector2(-260, -160))
	_player.set_touch_direction(1.0)
	_player._apply_horizontal_movement()
	assert_eq(_player.velocity.x, -260.0, "steering must not cancel the knockback")


# While bouncing, the Guardian's steering does not override the knockback either.
func test_guardian_steering_suppressed_during_bounce() -> void:
	_guardian.apply_bounce(Vector2(260, -160))
	_guardian.set_touch_direction(-1.0)
	_guardian._apply_horizontal_movement()
	assert_eq(_guardian.velocity.x, 260.0, "steering must not cancel the knockback")


# After the bounce window passes, steering works again.
func test_steering_returns_after_bounce() -> void:
	_player.apply_bounce(Vector2(260, -160))
	_player._bounce_timer = 0.0
	_player.set_touch_direction(-1.0)
	_player._apply_horizontal_movement()
	assert_eq(_player.velocity.x, -_player.speed)


# The bounce window expires over time.
func test_bounce_timer_decays() -> void:
	_player.apply_bounce(Vector2(260, -160))
	_player._bounce_timer = 0.01
	_player._tick_bounce(0.02)
	assert_false(_player.is_bouncing())