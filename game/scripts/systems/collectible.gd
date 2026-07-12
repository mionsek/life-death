extends Area2D
class_name Collectible

# A per-character pickup (skull for the Reaper, halo for the Guardian).
# Collecting every pickup of a character unlocks that character's exit portal —
# levels cannot be completed until both characters have a full set.
# Collection applies locally on every peer (positions are synced each frame,
# same pattern as FireZone/KillZone), so both devices stay consistent.

# Which character can pick this up: "Player" (skull) or "Guardian" (halo).
@export var target_character: String = "Player"

# Emitted once, when the matching character touches the pickup.
signal collected(target_character: String)

var _collected: bool = false


func _ready() -> void:
	add_to_group("collectible")
	body_entered.connect(_on_body_entered)
	_start_bob()


# Only the matching character collects; first touch wins.
func _on_body_entered(body: Node) -> void:
	if _collected or body.name != target_character:
		return
	_collected = true
	collected.emit(target_character)
	# keep the node alive for counters; just hide and stop colliding
	visible = false
	set_deferred("monitoring", false)


# Returns whether this pickup has already been collected.
func is_collected() -> bool:
	return _collected


# Gentle floating animation so pickups read as interactive.
func _start_bob() -> void:
	if not has_node("Vis"):
		return
	var tween := create_tween().set_loops()
	tween.tween_property($Vis, "position:y", -3.0, 0.7)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Vis, "position:y", 3.0, 0.7)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
