extends Area2D

# Kills Guardian (Strażniczka) on contact. Kostucha (Player) is immune.
# collision_mask=2 ensures only Guardian bodies trigger body_entered.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Guardian enters the fire zone — triggers death sequence.
func _on_body_entered(body: Node) -> void:
	if body.has_method("die"):
		body.die()
