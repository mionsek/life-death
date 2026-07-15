extends GutTest

# Lever is a toggle: each contact flips it and opens/closes the paired door.

var _lever: Area2D
var _door: StaticBody2D


func before_each() -> void:
	_door = preload("res://scripts/obstacles/door.gd").new()
	_door.door_id = "test_door"
	var shape := CollisionShape2D.new()
	shape.name = "Shape"
	_door.add_child(shape)
	var door_vis := Sprite2D.new()
	door_vis.name = "Vis"
	_door.add_child(door_vis)
	add_child_autofree(_door)

	_lever = preload("res://scripts/obstacles/lever.gd").new()
	_lever.target_door_id = "test_door"
	var lever_vis := Sprite2D.new()
	lever_vis.name = "Vis"
	_lever.add_child(lever_vis)
	add_child_autofree(_lever)


# Lever starts off.
func test_lever_starts_off() -> void:
	assert_false(_lever.is_activated())


# First contact throws the lever and opens the door.
func test_first_touch_opens_door() -> void:
	_lever._on_body_entered(autofree(Node.new()))
	assert_true(_lever.is_activated())
	assert_true(_door.is_open())


# Second contact flips it back and closes the door.
func test_second_touch_closes_door() -> void:
	_lever._on_body_entered(autofree(Node.new()))
	_lever._on_body_entered(autofree(Node.new()))
	assert_false(_lever.is_activated())
	assert_false(_door.is_open())
