extends GutTest

var _lever: Area2D
var _door: StaticBody2D


func before_each() -> void:
	_door = preload("res://scripts/obstacles/door.gd").new()
	_door.door_id = "test_door"
	var shape := CollisionShape2D.new()
	shape.name = "Shape"
	_door.add_child(shape)
	var vis := ColorRect.new()
	vis.name = "Vis"
	_door.add_child(vis)
	add_child_autofree(_door)

	_lever = preload("res://scripts/obstacles/lever.gd").new()
	_lever.target_door_id = "test_door"
	var vis_idle := ColorRect.new()
	vis_idle.name = "VisIdle"
	_lever.add_child(vis_idle)
	var vis_act := ColorRect.new()
	vis_act.name = "VisActivated"
	vis_act.visible = false
	_lever.add_child(vis_act)
	add_child_autofree(_lever)


# Lever starts not activated.
func test_lever_starts_not_activated() -> void:
	assert_false(_lever.is_activated())


# Lever becomes activated after body enters.
func test_lever_activates_on_body_entered() -> void:
	var body := Node.new()
	_lever._on_body_entered(body)
	assert_true(_lever.is_activated())
	body.free()


# Lever opens the linked door when activated.
func test_lever_opens_door() -> void:
	var body := Node.new()
	_lever._on_body_entered(body)
	assert_true(_door.is_open())
	body.free()


# Second activation attempt is ignored.
func test_lever_double_activation_is_safe() -> void:
	var body := Node.new()
	_lever._on_body_entered(body)
	_lever._on_body_entered(body)
	assert_true(_lever.is_activated())
	body.free()
