extends Area2D
class_name ExitPortal

# Which character name this exit accepts: "Player", "Guardian", or "" for both.
@export var target_character: String = ""

# Emitted when the correct character enters or exits this portal.
signal character_entered(body: Node)
signal character_exited_portal(body: Node)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_label()


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
		$Vis.color = Color(0.4, 0.8, 1.0, 0.8)
	elif target_character == "Guardian":
		$Label.text = "GUARDIAN"
		$Vis.color = Color(1.0, 0.6, 0.2, 0.8)
	else:
		$Label.text = "EXIT"
		$Vis.color = Color(0.5, 1.0, 0.5, 0.8)
