extends GutTest

var _player_scene: PackedScene = preload("res://scenes/characters/Player.tscn")
var _guardian_scene: PackedScene = preload("res://scenes/characters/Guardian.tscn")
var _player: CharacterBody2D
var _guardian: CharacterBody2D


func before_each() -> void:
	_player = _player_scene.instantiate()
	_guardian = _guardian_scene.instantiate()
	add_child(_player)
	add_child(_guardian)


func after_each() -> void:
	_player.queue_free()
	_guardian.queue_free()


# Player (Kostucha) is on the player physics layer only.
func test_player_collision_layer_is_player_only() -> void:
	assert_eq(_player.collision_layer, 1)


# Player mask = 4 (world only) — excludes cloud layer (8), so she passes through clouds.
func test_player_collision_mask_excludes_cloud() -> void:
	assert_eq(_player.collision_mask, 4)
	assert_eq(_player.collision_mask & 8, 0)


# Guardian mask = 12 (world + cloud) — she can stand on cloud platforms.
func test_guardian_collision_mask_includes_cloud() -> void:
	assert_eq(_guardian.collision_mask, 12)
	assert_eq(_guardian.collision_mask & 8, 8)
