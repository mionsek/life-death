extends GutTest

# Unit tests for Guardian — verifies inheritance from Player works correctly.

var _guardian: Guardian


func before_each() -> void:
	_guardian = preload("res://scenes/characters/Guardian.tscn").instantiate()
	add_child_autofree(_guardian)


# Verifies that Guardian starts with zero velocity.
func test_initial_velocity_is_zero() -> void:
	assert_eq(_guardian.velocity, Vector2.ZERO, "Guardian should start with zero velocity")


# Verifies that Guardian inherits the default speed from Player.
func test_inherits_default_speed() -> void:
	assert_eq(_guardian.speed, 200.0, "Guardian should inherit default speed from Player")


# Verifies that touch right input produces positive horizontal velocity.
func test_touch_right_sets_positive_velocity_x() -> void:
	_guardian.set_touch_direction(1.0)
	_guardian._apply_horizontal_movement()
	assert_eq(_guardian.velocity.x, _guardian.speed, "Right direction should give velocity.x = speed")


# Verifies that request_jump sets the internal jump flag.
func test_request_jump_sets_flag() -> void:
	_guardian.request_jump()
	assert_true(_guardian._jump_requested, "request_jump() should set _jump_requested to true")
