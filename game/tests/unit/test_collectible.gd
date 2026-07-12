extends GutTest

# Minimal stand-in body identified by name (that's all Collectible checks).
func _named(character_name: String) -> Node2D:
	var node := Node2D.new()
	node.name = character_name
	return node


var _pickup: Collectible


func before_each() -> void:
	_pickup = preload("res://scripts/systems/collectible.gd").new()
	_pickup.target_character = "Player"
	add_child_autofree(_pickup)


# The matching character collects the pickup and the signal fires once.
func test_matching_character_collects() -> void:
	watch_signals(_pickup)
	var body := _named("Player")
	add_child_autofree(body)
	_pickup._on_body_entered(body)
	assert_true(_pickup.is_collected())
	assert_signal_emitted_with_parameters(_pickup, "collected", ["Player"])


# The other character cannot collect it.
func test_other_character_is_ignored() -> void:
	watch_signals(_pickup)
	var body := _named("Guardian")
	add_child_autofree(body)
	_pickup._on_body_entered(body)
	assert_false(_pickup.is_collected())
	assert_signal_not_emitted(_pickup, "collected")


# A second touch does not emit the signal again.
func test_double_touch_emits_once() -> void:
	watch_signals(_pickup)
	var body := _named("Player")
	add_child_autofree(body)
	_pickup._on_body_entered(body)
	_pickup._on_body_entered(body)
	assert_signal_emit_count(_pickup, "collected", 1)


# Collected pickups disappear from view.
func test_collected_pickup_hides() -> void:
	var body := _named("Player")
	add_child_autofree(body)
	_pickup._on_body_entered(body)
	assert_false(_pickup.visible)
