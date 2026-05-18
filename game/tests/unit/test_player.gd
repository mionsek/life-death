extends GutTest

# Unit tests for Player movement logic.

var _player: Player


func before_each() -> void:
	_player = preload("res://scenes/characters/Player.tscn").instantiate()
	add_child_autofree(_player)


# Verifies that the player starts with zero velocity.
func test_initial_velocity_is_zero() -> void:
	assert_eq(_player.velocity, Vector2.ZERO, "Player should start with zero velocity")


# Verifies set_touch_direction stores the given value.
func test_set_touch_direction_stores_value() -> void:
	_player.set_touch_direction(-1.0)
	assert_eq(_player._touch_direction, -1.0, "Touch direction -1.0 should be stored")


# Verifies moving right produces positive horizontal velocity.
func test_touch_right_sets_positive_velocity_x() -> void:
	_player.set_touch_direction(1.0)
	_player._apply_horizontal_movement()
	assert_eq(_player.velocity.x, _player.speed, "Right direction should give velocity.x = speed")


# Verifies moving left produces negative horizontal velocity.
func test_touch_left_sets_negative_velocity_x() -> void:
	_player.set_touch_direction(-1.0)
	_player._apply_horizontal_movement()
	assert_eq(_player.velocity.x, -_player.speed, "Left direction should give velocity.x = -speed")


# Verifies zero direction stops horizontal movement.
func test_zero_direction_stops_horizontal_movement() -> void:
	_player.velocity.x = 200.0
	_player.set_touch_direction(0.0)
	_player._apply_horizontal_movement()
	assert_eq(_player.velocity.x, 0.0, "Zero direction should result in velocity.x = 0")


# Verifies request_jump sets the internal jump flag.
func test_request_jump_sets_flag() -> void:
	_player.request_jump()
	assert_true(_player._jump_requested, "request_jump() should set _jump_requested to true")
