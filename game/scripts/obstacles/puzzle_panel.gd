extends "res://scripts/obstacles/door_trigger.gd"
class_name PuzzlePanel

# A panel showing a multiple-choice question (A/B/C/D) with a countdown.
# Picking the correct option opens the target door (server-authoritative, via the base).
# If the timer runs out the panel locks permanently — the door stays shut until level reset.

# The question shown to the player.
@export var question: String = "2 + 3 = ?"
# The four answer options, in order A, B, C, D.
@export var options: PackedStringArray = PackedStringArray(["4", "5", "6", "7"])
# Index (0-3) of the correct option.
@export var correct_index: int = 1
# Seconds allowed to answer before the panel locks.
@export var time_limit: float = 8.0

var _bodies_inside: int = 0
var _locked: bool = false
var _time_left: float = 0.0
var _timer_active: bool = false

@onready var _ui: Control = $UI
@onready var _question_label: Label = $UI/Panel/VBox/Question
@onready var _timer_label: Label = $UI/Panel/VBox/Timer
@onready var _feedback_label: Label = $UI/Panel/VBox/Feedback
@onready var _option_buttons: Array = [
	$UI/Panel/VBox/Options/OptionA,
	$UI/Panel/VBox/Options/OptionB,
	$UI/Panel/VBox/Options/OptionC,
	$UI/Panel/VBox/Options/OptionD,
]


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var letters := ["A", "B", "C", "D"]
	for i in _option_buttons.size():
		var btn: Button = _option_buttons[i]
		var text := "" if i >= options.size() else options[i]
		btn.text = "%s. %s" % [letters[i], text]
		btn.pressed.connect(_on_option_pressed.bind(i))
	_question_label.text = question
	_feedback_label.text = ""
	_timer_label.text = ""
	_ui.visible = false


# Shows the question and starts the countdown when a character enters (if still answerable).
func _on_body_entered(_body: Node) -> void:
	_bodies_inside += 1
	if _triggered or _locked:
		return
	_ui.visible = true
	_time_left = time_limit
	_timer_active = true
	_feedback_label.text = ""
	_update_timer_label()


# Hides the panel and pauses the countdown when everyone leaves (unless solved/locked).
func _on_body_exited(_body: Node) -> void:
	_bodies_inside = max(0, _bodies_inside - 1)
	if _bodies_inside == 0 and not _triggered and not _locked:
		_ui.visible = false
		_timer_active = false


# Ticks the countdown while active; locks the panel when time runs out.
func _process(delta: float) -> void:
	if not _timer_active:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_time_left = 0.0
		_on_timeout()
	_update_timer_label()


# Handles an answer choice: correct opens the door, wrong shows feedback (retry until timeout).
func _on_option_pressed(index: int) -> void:
	if _triggered or _locked:
		return
	if index == correct_index:
		_timer_active = false
		_request_trigger()
	else:
		_feedback_label.text = "Źle, spróbuj ponownie!"


# Locks the panel permanently when the timer expires.
func _on_timeout() -> void:
	_locked = true
	_timer_active = false
	_feedback_label.text = "Czas minął! Panel zablokowany."
	for btn in _option_buttons:
		(btn as Button).disabled = true


# Updates the countdown label with the remaining whole seconds.
func _update_timer_label() -> void:
	_timer_label.text = "Czas: %d s" % ceili(_time_left)


# Hides the panel when the puzzle is solved (called by the base on activation).
func _on_triggered() -> void:
	_timer_active = false
	_ui.visible = false


# Returns whether the puzzle has been solved.
func is_solved() -> bool:
	return _triggered


# Returns whether the panel has locked out due to a timeout.
func is_locked() -> bool:
	return _locked
