extends GutTest

var _seesaw: Node2D


func before_each() -> void:
	_seesaw = preload("res://scripts/obstacles/seesaw.gd").new()
	# Use plain Node2D — AnimatableBody2D resets rotation via physics in test env.
	var plank := Node2D.new()
	plank.name = "Plank"
	_seesaw.add_child(plank)
	add_child_autofree(_seesaw)


# Seesaw starts with zero tilt.
func test_starts_balanced() -> void:
	assert_almost_eq(_seesaw.get_tilt(), 0.0, 0.01)


# More weight on the left tilts the seesaw left (negative angle).
func test_left_heavy_tilts_left() -> void:
	_seesaw._on_left_entered(Node.new())
	_seesaw._update_rotation(1.0)
	assert_lt(_seesaw.get_tilt(), 0.0)


# More weight on the right tilts the seesaw right (positive angle).
func test_right_heavy_tilts_right() -> void:
	_seesaw._on_right_entered(Node.new())
	_seesaw._update_rotation(1.0)
	assert_gt(_seesaw.get_tilt(), 0.0)


# Equal weight on both sides stays balanced.
func test_balanced_stays_near_zero() -> void:
	_seesaw._on_left_entered(Node.new())
	_seesaw._on_right_entered(Node.new())
	_seesaw._update_rotation(1.0)
	assert_almost_eq(_seesaw.get_tilt(), 0.0, 0.01)


# Body count does not go below zero on excess exits.
func test_count_cannot_go_below_zero() -> void:
	_seesaw._on_left_exited(Node.new())
	_seesaw._on_left_exited(Node.new())
	_seesaw._update_rotation(1.0)
	# Should not crash and tilt should be near zero
	assert_almost_eq(_seesaw.get_tilt(), 0.0, 0.01)
