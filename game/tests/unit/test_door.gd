extends GutTest

var _door: StaticBody2D


func before_each() -> void:
	_door = preload("res://scripts/obstacles/door.gd").new()
	add_child_autofree(_door)
	# Add required child nodes expected by door.gd
	var shape := CollisionShape2D.new()
	shape.name = "Shape"
	_door.add_child(shape)
	var vis := Sprite2D.new()
	vis.name = "Vis"
	_door.add_child(vis)


# Door starts closed.
func test_door_starts_closed() -> void:
	assert_false(_door.is_open())


# Door is open after calling open().
func test_open_marks_door_as_open() -> void:
	_door.open()
	assert_true(_door.is_open())


# Calling open() twice does not cause errors and stays open.
func test_double_open_is_safe() -> void:
	_door.open()
	_door.open()
	assert_true(_door.is_open())
