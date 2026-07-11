extends GutTest

var _panel: PuzzlePanel
var _door: Door
var _panel_scene := preload("res://scenes/obstacles/PuzzlePanel.tscn")
var _door_scene := preload("res://scenes/obstacles/Door.tscn")


func before_each() -> void:
	_door = _door_scene.instantiate()
	_door.door_id = "quiz_door"
	add_child_autofree(_door)

	_panel = _panel_scene.instantiate()
	_panel.target_door_id = "quiz_door"
	_panel.question = "2 + 2 = ?"
	_panel.options = PackedStringArray(["3", "4", "5", "6"])
	_panel.correct_index = 1
	_panel.time_limit = 5.0
	add_child_autofree(_panel)
	# Deterministic timing: disable the engine tick and drive _process() manually.
	_panel.set_process(false)


# Panel starts unsolved and unlocked.
func test_panel_starts_unsolved_and_unlocked() -> void:
	assert_false(_panel.is_solved())
	assert_false(_panel.is_locked())


# Choosing the correct option solves the panel and opens the door.
func test_correct_option_opens_door() -> void:
	var body: Node = autofree(Node.new())
	_panel._on_body_entered(body)
	_panel._on_option_pressed(1)
	assert_true(_panel.is_solved())
	assert_true(_door.is_open())


# Choosing a wrong option leaves the panel unsolved and the door shut.
func test_wrong_option_keeps_door_closed() -> void:
	var body: Node = autofree(Node.new())
	_panel._on_body_entered(body)
	_panel._on_option_pressed(0)
	assert_false(_panel.is_solved())
	assert_false(_door.is_open())


# The countdown locks the panel when it runs out, and the door stays shut.
func test_timeout_locks_panel() -> void:
	var body: Node = autofree(Node.new())
	_panel._on_body_entered(body)
	_panel._process(_panel.time_limit + 1.0)
	assert_true(_panel.is_locked())
	assert_false(_panel.is_solved())
	assert_false(_door.is_open())


# A correct answer after the panel has locked has no effect.
func test_cannot_solve_after_lock() -> void:
	var body: Node = autofree(Node.new())
	_panel._on_body_entered(body)
	_panel._process(_panel.time_limit + 1.0)
	_panel._on_option_pressed(1)
	assert_false(_panel.is_solved())
	assert_false(_door.is_open())
