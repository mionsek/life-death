extends GutTest

# TutorialManager: obstacle classification and the seen-once bookkeeping.

var _saved_seen: Dictionary


func before_each() -> void:
	_saved_seen = TutorialManager._seen.duplicate()
	TutorialManager.reset_seen()


func after_each() -> void:
	TutorialManager._seen = _saved_seen
	TutorialManager._save_seen()
	TutorialManager._pending.clear()
	TutorialManager._camera = null


func _scripted(base: Node, script_path: String) -> Node:
	base.set_script(load(script_path))
	add_child_autofree(base)
	return base


func test_classifies_hazard_zones_by_script() -> void:
	var lava := _scripted(Area2D.new(), "res://scripts/systems/fire_zone.gd")
	var light := _scripted(Area2D.new(), "res://scripts/systems/light_zone.gd")
	assert_eq(TutorialManager.classify(lava), "lava")
	assert_eq(TutorialManager.classify(light), "holy_light")


func test_classifies_obstacle_classes() -> void:
	var cases := {
		"res://scripts/obstacles/moving_platform.gd": "moving_platform",
		"res://scripts/obstacles/crumbling_platform.gd": "crumbling_platform",
		"res://scripts/obstacles/lever.gd": "lever",
		"res://scripts/obstacles/seesaw.gd": "seesaw",
	}
	for path in cases:
		var node: Node = (load(path) as GDScript).new()
		add_child_autofree(node)
		assert_eq(TutorialManager.classify(node), cases[path], path)


func test_classifies_collectibles_per_character() -> void:
	var skull: Collectible = preload("res://scripts/systems/collectible.gd").new()
	skull.target_character = "Player"
	add_child_autofree(skull)
	var heart: Collectible = preload("res://scripts/systems/collectible.gd").new()
	heart.target_character = "Guardian"
	add_child_autofree(heart)
	assert_eq(TutorialManager.classify(skull), "skull")
	assert_eq(TutorialManager.classify(heart), "heart")


func test_classifies_cloud_and_one_way_platforms() -> void:
	var cloud := StaticBody2D.new()
	cloud.name = "CloudPlatform1"
	add_child_autofree(cloud)
	assert_eq(TutorialManager.classify(cloud), "cloud")
	var one_way := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	shape.one_way_collision = true
	one_way.add_child(shape)
	add_child_autofree(one_way)
	assert_eq(TutorialManager.classify(one_way), "one_way")


func test_plain_nodes_are_not_obstacles() -> void:
	var node := Node2D.new()
	add_child_autofree(node)
	assert_eq(TutorialManager.classify(node), "")


func test_seen_marking_persists() -> void:
	assert_false(TutorialManager.was_seen("lava"))
	TutorialManager.mark_seen("lava")
	assert_true(TutorialManager.was_seen("lava"))
	TutorialManager._seen = {}
	TutorialManager._load_seen()
	assert_true(TutorialManager.was_seen("lava"),
		"seen flags should survive a reload from disk")


func test_track_level_skips_seen_types() -> void:
	TutorialManager.mark_seen("lava")
	var root := Node2D.new()
	var lava := Area2D.new()
	lava.set_script(load("res://scripts/systems/fire_zone.gd"))
	root.add_child(lava)
	var plate: Node = (load("res://scripts/obstacles/pressure_plate.gd") as GDScript).new()
	root.add_child(plate)
	add_child_autofree(root)
	var camera := Camera2D.new()
	add_child_autofree(camera)
	TutorialManager.track_level(root, camera)
	assert_eq(TutorialManager._pending.size(), 1)
	assert_eq(TutorialManager._pending[0].type, "pressure_plate")
