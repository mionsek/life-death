extends AnimatableBody2D
class_name MovingPlatform

# A platform that patrols between its start position and start+travel on a
# fixed clock (smooth cosine ease at both ends). Motion is purely time-driven
# and deterministic, so multiplayer peers stay in sync without any RPCs.

# Displacement from the start position at the far end of the patrol.
@export var travel: Vector2 = Vector2(0, -160)
# Seconds for a full there-and-back cycle.
@export var period: float = 5.0
# Cycle offset (0..1) — lets several platforms run out of step.
@export var phase: float = 0.0

var _origin: Vector2
var _clock: float = 0.0


func _ready() -> void:
	_origin = position


func _physics_process(delta: float) -> void:
	_clock += delta
	position = _origin + travel * _progress()


# Position along the patrol (0 at start, 1 at the far end), eased with cosine.
func _progress() -> float:
	if period <= 0.0:
		return 0.0
	return 0.5 - 0.5 * cos(TAU * fposmod(_clock / period + phase, 1.0))
