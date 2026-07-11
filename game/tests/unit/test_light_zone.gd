extends GutTest

var _zone: Area2D


# Minimal stand-in for a character: records whether die() was called.
class DummyBody extends Node:
	var died: bool = false
	func die() -> void:
		died = true


func before_each() -> void:
	_zone = preload("res://scripts/systems/light_zone.gd").new()
	add_child_autofree(_zone)


# Kostucha (a body with die()) dies on contact with holy light.
func test_kills_body_with_die() -> void:
	var body := DummyBody.new()
	add_child_autofree(body)
	_zone._on_body_entered(body)
	assert_true(body.died)


# A body without die() is ignored and does not crash the zone.
func test_ignores_body_without_die() -> void:
	var body: Node = autofree(Node.new())
	_zone._on_body_entered(body)
	pass_test("no crash when body has no die() method")
