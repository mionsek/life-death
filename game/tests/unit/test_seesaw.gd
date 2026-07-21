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


# These direction checks step by a frame-sized delta: the plank now takes an
# impact kick and spins up briskly, so a whole second carries it past half a
# turn and the wrapped angle comes back with the opposite sign.

# More weight on the left tilts the seesaw left (negative angle).
func test_left_heavy_tilts_left() -> void:
	_seesaw._on_left_entered(Node.new())
	_seesaw._update_rotation(0.1)
	assert_lt(_seesaw.get_tilt(), 0.0)


# More weight on the right tilts the seesaw right (positive angle).
func test_right_heavy_tilts_right() -> void:
	_seesaw._on_right_entered(Node.new())
	_seesaw._update_rotation(0.1)
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


# Pushing up under the left arm raises it — rotates like weight on the right (positive).
func test_push_under_left_tilts_right() -> void:
	var body: Node = autofree(Node.new())
	_seesaw._on_left_under_entered(body)
	_seesaw._update_rotation(0.1)
	assert_gt(_seesaw.get_tilt(), 0.0)


# Pushing up under the right arm raises it — rotates like weight on the left (negative).
func test_push_under_right_tilts_left() -> void:
	var body: Node = autofree(Node.new())
	_seesaw._on_right_under_entered(body)
	_seesaw._update_rotation(0.1)
	assert_lt(_seesaw.get_tilt(), 0.0)


# Weight on top of a side and a push under the same side cancel out.
func test_top_and_under_same_side_cancel() -> void:
	var body: Node = autofree(Node.new())
	_seesaw._on_left_entered(body)
	_seesaw._on_left_under_entered(body)
	_seesaw._update_rotation(1.0)
	assert_almost_eq(_seesaw.get_tilt(), 0.0, 0.01)


# Under-counts never drop below zero on excess exits.
func test_under_count_cannot_go_below_zero() -> void:
	var body: Node = autofree(Node.new())
	_seesaw._on_left_under_exited(body)
	_seesaw._on_left_under_exited(body)
	_seesaw._update_rotation(1.0)
	assert_almost_eq(_seesaw.get_tilt(), 0.0, 0.01)


# A weighted seesaw spins up freely (no fixed angle limit) up to the speed cap.
func test_weighted_seesaw_spins_up_to_cap() -> void:
	var body: Node = autofree(Node.new())
	_seesaw._on_right_entered(body)
	for i in range(200):
		_seesaw._update_rotation(0.1)
	assert_almost_eq(_seesaw._angular_velocity, _seesaw.MAX_ANGULAR_VELOCITY, 0.001)


# Angular velocity never exceeds the configured maximum, even under heavy imbalance.
func test_angular_velocity_capped() -> void:
	var body: Node = autofree(Node.new())
	# A large imbalance would blow past the cap in a single step if unclamped.
	for i in range(20):
		_seesaw._on_right_entered(body)
	_seesaw._update_rotation(1.0)
	assert_true(absf(_seesaw._angular_velocity) <= _seesaw.MAX_ANGULAR_VELOCITY + 0.0001)


# When unweighted, the seesaw coasts to a stop but keeps its tilt (does not reset).
func test_coasts_to_stop_keeping_angle() -> void:
	var body: Node = autofree(Node.new())
	_seesaw._on_right_entered(body)
	for i in range(20):
		_seesaw._update_rotation(0.1)
	# Step off and let friction bring it to rest.
	_seesaw._on_right_exited(body)
	for i in range(300):
		_seesaw._update_rotation(0.1)
	assert_almost_eq(_seesaw._angular_velocity, 0.0, 0.001)
	assert_true(absf(_seesaw.get_tilt()) > 0.001, "the plank keeps its angle instead of resetting")
