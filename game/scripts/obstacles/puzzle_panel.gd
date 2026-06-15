extends Area2D
class_name PuzzlePanel

# ID of the door this panel controls when solved.
@export var target_door_id: String = "door_01"
# The question shown to the player.
@export var question: String = "2 + 3 = ?"
# The expected answer (as a string comparison).
@export var answer: String = "5"

var _solved: bool = false
var _bodies_inside: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$UI.visible = false
	$UI/Panel/VBox/Question.text = question
	$UI/Panel/VBox/Feedback.text = ""


# Shows the UI when a character enters the panel zone.
func _on_body_entered(_body: Node) -> void:
	_bodies_inside += 1
	if not _solved:
		$UI.visible = true


# Hides the UI when all characters leave the panel zone.
func _on_body_exited(_body: Node) -> void:
	_bodies_inside = max(0, _bodies_inside - 1)
	if _bodies_inside == 0:
		$UI.visible = false
		$UI/Panel/VBox/Input.text = ""
		$UI/Panel/VBox/Feedback.text = ""


# Checks the submitted answer and opens the door if correct.
func _on_submit_pressed() -> void:
	var input: String = ($UI/Panel/VBox/Input as LineEdit).text.strip_edges()
	if input == answer:
		_solved = true
		$UI.visible = false
		var door := _find_door()
		if door:
			door.open()
	else:
		$UI/Panel/VBox/Feedback.text = "Spróbuj ponownie!"


# Returns whether the puzzle has been solved.
func is_solved() -> bool:
	return _solved


# Finds the door with matching door_id using Godot groups.
func _find_door() -> Node:
	var doors := get_tree().get_nodes_in_group("door_" + target_door_id)
	if doors.is_empty():
		return null
	return doors[0]
