extends Area2D
class_name ExitPortal

# Which character name this exit accepts: "Player", "Guardian", or "" for both.
@export var target_character: String = ""

# Emitted when the correct character enters or exits this portal.
signal character_entered(body: Node)
signal character_exited_portal(body: Node)

# While locked (missing pickups) the portal is dimmed and shows progress;
# level_base still tracks presence but refuses to complete the level.
var _locked: bool = false


func _ready() -> void:
	add_to_group("exit_portal")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_label()


# Locks/unlocks the portal visuals; progress like "1/3" is appended when locked.
func set_locked(locked: bool, progress: String = "") -> void:
	_locked = locked
	_update_label()
	if has_node("Vis"):
		$Vis.self_modulate = Color(0.45, 0.45, 0.45, 0.8) if locked else Color.WHITE
	if locked and progress != "" and has_node("Label"):
		$Label.text += " %s" % progress


# Returns whether this portal is currently locked by missing pickups.
func is_locked() -> bool:
	return _locked


# Filters body_entered — only passes through the targeted character.
func _on_body_entered(body: Node) -> void:
	if target_character == "" or body.name == target_character:
		character_entered.emit(body)


# Filters body_exited — only passes through the targeted character.
func _on_body_exited(body: Node) -> void:
	if target_character == "" or body.name == target_character:
		character_exited_portal.emit(body)


# Updates the visible label to reflect the target character.
func _update_label() -> void:
	if not has_node("Label") or not has_node("Vis"):
		return
	if target_character == "Player":
		$Label.text = "KOSTUCHA"
		$Vis.modulate = Color(0.55, 0.35, 1.0, 0.9)
	elif target_character == "Guardian":
		$Label.text = "GUARDIAN"
		$Vis.modulate = Color(1.0, 0.75, 0.25, 0.9)
	else:
		$Label.text = "EXIT"
		$Vis.modulate = Color(0.5, 1.0, 0.5, 0.9)
