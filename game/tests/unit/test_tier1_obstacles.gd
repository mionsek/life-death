extends GutTest

# Tier 1 obstacle set: moving platform, crumbling platform, pressure plate
# (with the door's new open/close support) and the lever↔door colour pairing.


# Builds a scripted door with the children door.gd expects (test_lever pattern).
func _make_door(id: String) -> StaticBody2D:
	var door: StaticBody2D = preload("res://scripts/obstacles/door.gd").new()
	door.door_id = id
	var shape := CollisionShape2D.new()
	shape.name = "Shape"
	door.add_child(shape)
	var vis := ColorRect.new()
	vis.name = "Vis"
	door.add_child(vis)
	add_child_autofree(door)
	return door


# --- moving platform ---------------------------------------------------------

# The patrol progress runs 0 → 1 → 0 over one period (cosine-eased).
# (Position itself is engine-managed via sync_to_physics, so the math is
# what we can assert deterministically here.)
func test_moving_platform_patrols_and_returns() -> void:
	var platform: MovingPlatform = autofree(preload("res://scripts/obstacles/moving_platform.gd").new())
	platform.period = 2.0
	platform._clock = 0.0
	assert_almost_eq(platform._progress(), 0.0, 0.001, "at origin when the cycle starts")
	platform._clock = 1.0
	assert_almost_eq(platform._progress(), 1.0, 0.001, "far end after half a cycle")
	platform._clock = 2.0
	assert_almost_eq(platform._progress(), 0.0, 0.001, "back at origin after a full cycle")


# Deterministic clock: identical settings and clocks give identical progress
# (this is what keeps multiplayer peers in lockstep without RPCs).
func test_moving_platforms_stay_in_sync() -> void:
	var a: MovingPlatform = autofree(preload("res://scripts/obstacles/moving_platform.gd").new())
	var b: MovingPlatform = autofree(preload("res://scripts/obstacles/moving_platform.gd").new())
	a.period = 3.7
	b.period = 3.7
	a._clock = 1.234
	b._clock = 1.234
	assert_eq(a._progress(), b._progress())


# --- crumbling platform ------------------------------------------------------

# Touch → shake → gone → back after the respawn time.
func test_crumbling_platform_cycle() -> void:
	var platform: CrumblingPlatform = preload("res://scenes/obstacles/CrumblingPlatform.tscn").instantiate()
	add_child_autofree(platform)
	var body: Node2D = autofree(Node2D.new())
	assert_true(platform.is_solid())

	platform._on_body_entered(body)
	platform._physics_process(0.3)
	assert_true(platform.is_solid(), "still solid while shaking")

	platform._physics_process(0.3)
	assert_false(platform.is_solid(), "gone after the shake time")
	assert_false(platform.visible)

	platform._physics_process(3.1)
	assert_true(platform.is_solid(), "respawned after the respawn time")
	assert_true(platform.visible)


# --- pressure plate + door open/close ---------------------------------------

# The door opens while a body stands on the plate and shuts when it leaves.
func test_pressure_plate_holds_door_open() -> void:
	var door := _make_door("test_plate_gate")
	var plate: PressurePlate = preload("res://scenes/obstacles/PressurePlate.tscn").instantiate()
	plate.target_door_id = "test_plate_gate"
	add_child_autofree(plate)
	var body: Node = autofree(Node.new())

	plate._on_body_entered(body)
	assert_true(plate.is_pressed())
	assert_true(door.is_open())

	plate._on_body_exited(body)
	assert_false(plate.is_pressed())
	assert_false(door.is_open())


# With two bodies on the plate, the door stays open until the last one leaves.
func test_pressure_plate_counts_bodies() -> void:
	var door := _make_door("test_plate_gate2")
	var plate: PressurePlate = preload("res://scenes/obstacles/PressurePlate.tscn").instantiate()
	plate.target_door_id = "test_plate_gate2"
	add_child_autofree(plate)
	var a: Node = autofree(Node.new())
	var b: Node = autofree(Node.new())

	plate._on_body_entered(a)
	plate._on_body_entered(b)
	plate._on_body_exited(a)
	assert_true(door.is_open(), "one body still holds the plate")
	plate._on_body_exited(b)
	assert_false(door.is_open())


# Closing the door re-enables its collision immediately.
func test_door_close_restores_collision() -> void:
	var door := _make_door("test_toggle")
	door.set_open_state(true)
	assert_true(door.is_open())
	door.set_open_state(false)
	assert_false(door.is_open())
	await get_tree().process_frame   # set_deferred lands
	assert_false(door.get_node("Shape").disabled)


# --- colour pairing ----------------------------------------------------------

# The pairing colour is deterministic per id and differs between ids.
func test_id_color_is_deterministic() -> void:
	assert_eq(Door.id_color("gate_01"), Door.id_color("gate_01"))
	assert_ne(Door.id_color("gate_01"), Door.id_color("plate_gate"))


# A lever tints its visuals with its target door's colour.
func test_lever_carries_door_color() -> void:
	var lever = preload("res://scenes/obstacles/Lever.tscn").instantiate()
	lever.target_door_id = "gate_77"
	add_child_autofree(lever)
	var expected := Door.id_color("gate_77").lerp(Color.WHITE, 0.35)
	assert_eq(lever.get_node("VisIdle").self_modulate, expected)
