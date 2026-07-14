extends StaticBody2D
class_name CrumblingPlatform

# A platform that gives way shortly after someone steps on it: shakes for a
# moment, then falls away, and reappears a few seconds later. Both peers see
# the same synced character positions, so the trigger is applied locally on
# each device (same pattern as hazards and pickups).

# Seconds of warning shake after the first touch.
@export var shake_time: float = 0.5
# Seconds the platform stays gone before it reappears.
@export var respawn_time: float = 3.0

enum State { IDLE, SHAKING, GONE }

var _state: State = State.IDLE
var _timer: float = 0.0
var _vis_origin: Vector2


func _ready() -> void:
	if has_node("Vis"):
		_vis_origin = $Vis.position
	if has_node("TouchArea"):
		$TouchArea.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	match _state:
		State.SHAKING:
			_timer -= delta
			if has_node("Vis"):
				$Vis.position = _vis_origin + Vector2(randf_range(-2, 2), randf_range(-1, 1))
			if _timer <= 0.0:
				_break_apart()
		State.GONE:
			_timer -= delta
			if _timer <= 0.0:
				_restore()


# First touch starts the countdown.
func _on_body_entered(_body: Node) -> void:
	if _state == State.IDLE:
		_state = State.SHAKING
		_timer = shake_time


# Removes the platform from play.
func _break_apart() -> void:
	_state = State.GONE
	_timer = respawn_time
	visible = false
	if has_node("Shape"):
		$Shape.set_deferred("disabled", true)


# Brings the platform back.
func _restore() -> void:
	_state = State.IDLE
	visible = true
	if has_node("Vis"):
		$Vis.position = _vis_origin
	if has_node("Shape"):
		$Shape.set_deferred("disabled", false)


# Returns whether the platform is currently solid.
func is_solid() -> bool:
	return _state != State.GONE
