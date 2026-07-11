extends GutTest

# Integration: level_base tracks which characters are at their exits and completes the
# level only when both are present simultaneously. A tiny subclass overrides _complete_level
# so the test observes completion without triggering a real scene change, and instances are
# kept out of the tree to avoid _ready()'s child/autoload requirements.

class TestableLevel extends "res://scripts/levels/level_base.gd":
	var completed: bool = false
	# Records completion instead of changing scene.
	func _complete_level() -> void:
		completed = true


var _level: TestableLevel


func before_each() -> void:
	_level = TestableLevel.new()


func after_each() -> void:
	_level.free()


# Builds a named stand-in body (name is what level_base tracks).
func _named(character_name: String) -> Node:
	var node := Node.new()
	node.name = character_name
	return node


# One character at its exit does not complete the level.
func test_one_character_does_not_complete() -> void:
	var p := _named("Player")
	_level.on_exit_entered(p)
	assert_false(_level.completed)
	p.free()


# The same character entering twice is not double-counted.
func test_same_character_not_double_counted() -> void:
	var p := _named("Player")
	_level.on_exit_entered(p)
	_level.on_exit_entered(p)
	assert_false(_level.completed, "one character counted twice must not complete the level")
	p.free()


# Both characters at their exits completes the level.
func test_both_characters_complete() -> void:
	var p := _named("Player")
	var g := _named("Guardian")
	_level.on_exit_entered(p)
	_level.on_exit_entered(g)
	assert_true(_level.completed)
	p.free()
	g.free()


# A character leaving its exit is removed, so the level no longer completes.
func test_exit_removes_character() -> void:
	var p := _named("Player")
	var g := _named("Guardian")
	_level.on_exit_entered(p)
	_level.on_exit_exited(p)
	_level.on_exit_entered(g)
	assert_false(_level.completed, "only one character present after the other left")
	p.free()
	g.free()
