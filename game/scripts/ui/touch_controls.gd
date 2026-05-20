extends CanvasLayer

# Controlled player node; assigned via set_player() after scene is ready.
var _player: Player = null


# Registers the player node that will receive touch input commands.
func set_player(player: Player) -> void:
	_player = player


func _ready() -> void:
	$HUD/BtnLeft.button_down.connect(_on_left_down)
	$HUD/BtnLeft.button_up.connect(_on_left_up)
	$HUD/BtnRight.button_down.connect(_on_right_down)
	$HUD/BtnRight.button_up.connect(_on_right_up)
	$HUD/BtnJump.button_down.connect(_on_jump_pressed)


# Sends left direction to the player while button is held.
func _on_left_down() -> void:
	if _player:
		_player.set_touch_direction(-1.0)


# Clears direction when the left button is released.
func _on_left_up() -> void:
	if _player:
		_player.set_touch_direction(0.0)


# Sends right direction to the player while button is held.
func _on_right_down() -> void:
	if _player:
		_player.set_touch_direction(1.0)


# Clears direction when the right button is released.
func _on_right_up() -> void:
	if _player:
		_player.set_touch_direction(0.0)


# Requests a jump from the player when the jump button is pressed.
func _on_jump_pressed() -> void:
	if _player:
		_player.request_jump()
