extends GutTest

# Integration: level completion is gated by pickups — both characters must
# stand at their exits AND both full sets (skulls + hearts) must be collected.
# Uses a TestableLevel kept out of the tree (same pattern as
# test_level_completion.gd) with pickup counters driven directly.

class TestableLevel extends "res://scripts/levels/level_base.gd":
	var completed: bool = false
	# Records completion instead of changing scene.
	func _complete_level() -> void:
		completed = true
	# Skips HUD/portal refresh — no scene children exist in this harness.
	func _refresh_coin_state() -> void:
		pass


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


func _both_at_exit() -> void:
	var p := _named("Player")
	var g := _named("Guardian")
	_level.on_exit_entered(p)
	_level.on_exit_entered(g)
	p.free()
	g.free()


# With no pickups in the level, both at exits completes immediately (old behaviour).
func test_no_pickups_completes_normally() -> void:
	_both_at_exit()
	assert_true(_level.completed)


# Missing skulls block completion even with both characters at their exits.
func test_missing_skulls_block_completion() -> void:
	_level._skull_total = 2
	_level._skull_got = 1
	_both_at_exit()
	assert_false(_level.completed, "1/2 skulls must not complete the level")


# Missing hearts block completion too.
func test_missing_hearts_block_completion() -> void:
	_level._heart_total = 3
	_level._heart_got = 0
	_both_at_exit()
	assert_false(_level.completed, "0/3 hearts must not complete the level")


# Full sets on both sides complete the level.
func test_full_sets_complete() -> void:
	_level._skull_total = 2
	_level._skull_got = 2
	_level._heart_total = 3
	_level._heart_got = 3
	_both_at_exit()
	assert_true(_level.completed)


# Collecting the last pickup while both already wait at exits completes the level.
func test_last_coin_completes_while_waiting_at_exit() -> void:
	_level._skull_total = 1
	_level._skull_got = 0
	_both_at_exit()
	assert_false(_level.completed)
	_level._on_coin_collected("Player")
	assert_true(_level.completed, "last skull collected at the exit should finish the level")


# _coins_done maps characters to their own currency.
func test_coins_done_per_character() -> void:
	_level._skull_total = 1
	_level._heart_total = 0
	assert_false(_level._coins_done("Player"))
	assert_true(_level._coins_done("Guardian"))
	_level._skull_got = 1
	assert_true(_level._coins_done("Player"))
