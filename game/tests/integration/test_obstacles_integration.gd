extends GutTest

# Integration: obstacle scenes wired to a door purely via the door_id group mechanism,
# exercising the real .tscn node trees (not hand-built stand-ins).

var _door_scene := preload("res://scenes/obstacles/Door.tscn")
var _lever_scene := preload("res://scenes/obstacles/Lever.tscn")
var _panel_scene := preload("res://scenes/obstacles/PuzzlePanel.tscn")


# Instantiates a Door with the given id and adds it to the tree so it registers its group.
func _add_door(id: String) -> Door:
	var door: Door = _door_scene.instantiate()
	door.door_id = id
	add_child_autofree(door)
	return door


# A lever opens the door that shares its target id, discovered via group lookup.
func test_lever_opens_targeted_door() -> void:
	var door := _add_door("gate_a")
	var lever: Lever = _lever_scene.instantiate()
	lever.target_door_id = "gate_a"
	add_child_autofree(lever)

	var body: Node = autofree(Node.new())
	lever._on_body_entered(body)

	assert_true(lever.is_activated(), "lever should activate on contact")
	assert_true(door.is_open(), "the targeted door should open")


# A puzzle panel opens its targeted door when the correct option is clicked.
func test_puzzle_opens_targeted_door() -> void:
	var door := _add_door("gate_b")
	var panel: PuzzlePanel = _panel_scene.instantiate()
	panel.target_door_id = "gate_b"
	panel.options = PackedStringArray(["1", "2", "3", "4"])
	panel.correct_index = 2
	add_child_autofree(panel)

	var body: Node = autofree(Node.new())
	panel._on_body_entered(body)
	# Emit the real button signal (OptionC == index 2) to validate the _ready() wiring.
	panel.get_node("UI/Panel/VBox/Options/OptionC").pressed.emit()

	assert_true(panel.is_solved(), "panel should be solved by the correct option")
	assert_true(door.is_open(), "the targeted door should open")


# A wrong option neither solves the panel nor opens the door.
func test_puzzle_wrong_answer_keeps_door_closed() -> void:
	var door := _add_door("gate_c")
	var panel: PuzzlePanel = _panel_scene.instantiate()
	panel.target_door_id = "gate_c"
	panel.options = PackedStringArray(["1", "2", "3", "4"])
	panel.correct_index = 2
	add_child_autofree(panel)

	var body: Node = autofree(Node.new())
	panel._on_body_entered(body)
	panel.get_node("UI/Panel/VBox/Options/OptionA").pressed.emit()  # index 0 — wrong

	assert_false(panel.is_solved(), "wrong option must not solve the panel")
	assert_false(door.is_open(), "wrong option must leave the door closed")


# A trigger targeting a non-existent door still activates and does not crash.
func test_trigger_with_missing_door_does_not_crash() -> void:
	var lever: Lever = _lever_scene.instantiate()
	lever.target_door_id = "nonexistent_door"
	add_child_autofree(lever)

	var body: Node = autofree(Node.new())
	lever._on_body_entered(body)

	assert_true(lever.is_activated(), "lever activates even when its door is missing")
