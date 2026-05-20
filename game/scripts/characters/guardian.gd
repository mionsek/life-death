extends Player
class_name Guardian

# Guardian of Life — Player 2 character.
# Inherits all movement from Player; unique abilities added in branch 005-character-abilities.

func _ready() -> void:
	# Guardian is controlled only via touch — keyboard belongs to Player 1.
	use_keyboard = false
