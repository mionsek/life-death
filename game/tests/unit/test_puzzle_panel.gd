extends GutTest

var _panel: Area2D
var _door: StaticBody2D


func _make_door() -> StaticBody2D:
	var door: StaticBody2D = preload("res://scripts/obstacles/door.gd").new()
	door.door_id = "puzzle_door"
	var shape := CollisionShape2D.new()
	shape.name = "Shape"
	door.add_child(shape)
	var vis := ColorRect.new()
	vis.name = "Vis"
	door.add_child(vis)
	return door


func _make_panel() -> Area2D:
	var panel: Area2D = preload("res://scripts/obstacles/puzzle_panel.gd").new()
	panel.target_door_id = "puzzle_door"
	panel.question = "2 + 3 = ?"
	panel.answer = "5"
	# Build minimal UI tree expected by puzzle_panel.gd
	var ui := Control.new()
	ui.name = "UI"
	var pc := PanelContainer.new()
	pc.name = "Panel"
	ui.add_child(pc)
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	pc.add_child(vbox)
	var question_lbl := Label.new()
	question_lbl.name = "Question"
	vbox.add_child(question_lbl)
	var input_field := LineEdit.new()
	input_field.name = "Input"
	vbox.add_child(input_field)
	var btn := Button.new()
	btn.name = "SubmitBtn"
	vbox.add_child(btn)
	var feedback := Label.new()
	feedback.name = "Feedback"
	vbox.add_child(feedback)
	panel.add_child(ui)
	return panel


func before_each() -> void:
	_door = _make_door()
	add_child_autofree(_door)
	_panel = _make_panel()
	add_child_autofree(_panel)


# Panel starts unsolved.
func test_panel_starts_unsolved() -> void:
	assert_false(_panel.is_solved())


# Correct answer marks panel as solved.
func test_correct_answer_solves_panel() -> void:
	_panel.get_node("UI/Panel/VBox/Input").text = "5"
	_panel._on_submit_pressed()
	assert_true(_panel.is_solved())


# Correct answer opens the linked door.
func test_correct_answer_opens_door() -> void:
	_panel.get_node("UI/Panel/VBox/Input").text = "5"
	_panel._on_submit_pressed()
	assert_true(_door.is_open())


# Wrong answer leaves panel unsolved.
func test_wrong_answer_does_not_solve_panel() -> void:
	_panel.get_node("UI/Panel/VBox/Input").text = "99"
	_panel._on_submit_pressed()
	assert_false(_panel.is_solved())


# Wrong answer shows feedback text.
func test_wrong_answer_shows_feedback() -> void:
	_panel.get_node("UI/Panel/VBox/Input").text = "99"
	_panel._on_submit_pressed()
	assert_ne(_panel.get_node("UI/Panel/VBox/Feedback").text, "")
