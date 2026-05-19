extends Area2D

# Kills any character that falls into this zone.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Calls die() on any body that has the method (Player or Guardian).
func _on_body_entered(body: Node) -> void:
	if body.has_method("die"):
		body.die()
