extends GutTest

var _portal: Area2D


func before_each() -> void:
	_portal = preload("res://scripts/obstacles/exit_portal.gd").new()
	add_child_autofree(_portal)


# Emits character_entered when body name matches target_character.
func test_emits_for_matching_character() -> void:
	_portal.target_character = "Player"
	watch_signals(_portal)
	var body := Node.new()
	body.name = "Player"
	_portal._on_body_entered(body)
	assert_signal_emitted(_portal, "character_entered")
	body.free()


# Does not emit character_entered when body name does not match target_character.
func test_does_not_emit_for_wrong_character() -> void:
	_portal.target_character = "Player"
	watch_signals(_portal)
	var body := Node.new()
	body.name = "Guardian"
	_portal._on_body_entered(body)
	assert_signal_not_emitted(_portal, "character_entered")
	body.free()


# Emits for any character when target_character is empty.
func test_emits_for_any_character_when_target_empty() -> void:
	_portal.target_character = ""
	watch_signals(_portal)
	var body := Node.new()
	body.name = "Guardian"
	_portal._on_body_entered(body)
	assert_signal_emitted(_portal, "character_entered")
	body.free()


# Emits character_exited_portal for matching character.
func test_emits_exited_for_matching_character() -> void:
	_portal.target_character = "Guardian"
	watch_signals(_portal)
	var body := Node.new()
	body.name = "Guardian"
	_portal._on_body_exited(body)
	assert_signal_emitted(_portal, "character_exited_portal")
	body.free()
