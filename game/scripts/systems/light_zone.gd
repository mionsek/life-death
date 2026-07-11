extends Area2D

# Holy light beam — kills Kostucha (Player) on contact; the Guardian passes
# through unharmed. Set collision_mask=1 in the scene so only Player bodies
# trigger body_entered. Heaven's counterpart of FireZone.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Kostucha steps into the light — triggers the death sequence.
func _on_body_entered(body: Node) -> void:
	if body.has_method("die"):
		body.die()
