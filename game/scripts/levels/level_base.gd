extends Node2D

const MINIMAP_SCENE := preload("res://scenes/ui/Minimap.tscn")
const COIN_HUD_SCENE := preload("res://scenes/ui/CoinHud.tscn")

const WORLD_BG := preload("res://assets/background/bg1.png")
# LEVEL_GRAPH positions live on this world-map canvas (see level_select.gd).
const MAP_CANVAS_SIZE := Vector2(1280, 720)
# Fraction of bg1's height covered by a level's backdrop crop — smaller means
# a tighter zoom on the level's spot on the world map.
const BG_CROP_FRACTION := 0.42

# World-space size of this level; override in bigger scenes so the camera
# limits and the minimap cover the full playfield.
@export var level_size: Vector2 = Vector2(640, 360)

# Tracks which players have reached the exit portal.
var _players_at_exit: Array[String] = []

# Pickup progress per character — collecting the full set unlocks that
# character's exit portal; the level completes only with both sets full.
var _skull_total: int = 0
var _skull_got: int = 0
var _halo_total: int = 0
var _halo_got: int = 0
var _coin_hud: CanvasLayer = null


func _ready() -> void:
	$TouchControls.set_player($Player)
	$TouchControlsP2.set_player($Guardian)
	_setup_background()
	_setup_camera()
	_setup_minimap()
	_setup_multiplayer_authority()
	_connect_exit_portals.call_deferred()
	_setup_collectibles.call_deferred()
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		NetworkManager.peer_disconnected_in_game.connect(_on_peer_disconnected)


# Swaps the scene's flat backdrop for a zoomed-in crop of the hand-drawn world
# map (bg1.png), centered on this level's position on the map — each level is
# visually anchored to the spot the player picked on the world map. Levels
# without a backdrop node or a graph entry keep their original background.
func _setup_background() -> void:
	var bg: TextureRect = get_node_or_null("WorldEnv")
	if bg == null:
		bg = get_node_or_null("Bg")
	if bg == null:
		return
	var data = LevelManager.get_level(LevelManager.current_level_id)
	if data == null or data.scene_path != scene_file_path:
		data = _find_level_by_scene()
	if data == null:
		return
	var img_size := Vector2(WORLD_BG.get_size())
	# map_pos is in world-map canvas pixels; bg1 is drawn stretched over that
	# canvas, so rescale the focus point to the image's own pixels.
	var focus: Vector2 = data.map_pos * img_size / MAP_CANVAS_SIZE
	var crop_h: float = img_size.y * BG_CROP_FRACTION
	var crop := Vector2(crop_h * bg.size.x / bg.size.y, crop_h)
	if crop.x > img_size.x:
		crop *= img_size.x / crop.x
	var atlas := AtlasTexture.new()
	atlas.atlas = WORLD_BG
	atlas.region = Rect2((focus - crop / 2.0).clamp(Vector2.ZERO, img_size - crop), crop)
	bg.texture = atlas
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE


# Finds this scene's graph entry by scene path, so the backdrop also works
# when the scene is launched directly from the editor (F6).
func _find_level_by_scene():
	for data in LevelManager.get_all_levels():
		if data.scene_path == scene_file_path:
			return data
	return null


# Clamps the follow camera to the level bounds. When the zoomed-out view is
# larger than the level on an axis, the limits are widened symmetrically so the
# level stays centered instead of pinning to the top-left corner.
func _setup_camera() -> void:
	if not $Player.has_node("Camera2D"):
		return
	var cam: Camera2D = $Player.get_node("Camera2D")
	var view: Vector2 = get_viewport().get_visible_rect().size / cam.zoom
	var overflow: Vector2 = ((view - level_size) / 2.0).max(Vector2.ZERO)
	cam.limit_left = int(-overflow.x)
	cam.limit_top = int(-overflow.y)
	cam.limit_right = int(level_size.x + overflow.x)
	cam.limit_bottom = int(level_size.y + overflow.y)


# Adds the live minimap (top-right corner, click to expand to a full map).
func _setup_minimap() -> void:
	var minimap := MINIMAP_SCENE.instantiate()
	add_child(minimap)
	minimap.setup(Rect2(Vector2.ZERO, level_size), [$Player, $Guardian])


# Auto-connects all ExitPortal child nodes so the designer only needs to add the scene.
# Called deferred so all children are ready before scanning.
func _connect_exit_portals() -> void:
	for child in get_children():
		if child.get_script() == null:
			continue
		var path: String = child.get_script().resource_path
		if "exit_portal" not in path:
			continue
		if not child.character_entered.is_connected(on_exit_entered):
			child.character_entered.connect(on_exit_entered)
		if not child.character_exited_portal.is_connected(on_exit_exited):
			child.character_exited_portal.connect(on_exit_exited)


# Scans the level for collectibles (skulls/halos), wires their signals and
# shows the counter HUD when the level has any. Deferred so children are ready.
func _setup_collectibles() -> void:
	for node in get_tree().get_nodes_in_group("collectible"):
		if not is_ancestor_of(node):
			continue
		if node.target_character == "Guardian":
			_halo_total += 1
		else:
			_skull_total += 1
		if not node.collected.is_connected(_on_coin_collected):
			node.collected.connect(_on_coin_collected)
	if _skull_total + _halo_total > 0:
		_coin_hud = COIN_HUD_SCENE.instantiate()
		add_child(_coin_hud)
	_refresh_coin_state()


# Bumps the matching counter and re-evaluates HUD, portal locks and completion.
func _on_coin_collected(target_character: String) -> void:
	if target_character == "Guardian":
		_halo_got += 1
	else:
		_skull_got += 1
	_refresh_coin_state()
	_try_complete()


# Returns true when the character has collected their whole set (or has none).
func _coins_done(character: String) -> bool:
	if character == "Guardian":
		return _halo_got >= _halo_total
	return _skull_got >= _skull_total


# Updates the HUD counters and dims/undims exit portals with progress text.
func _refresh_coin_state() -> void:
	if _coin_hud:
		_coin_hud.update_counts(_skull_got, _skull_total, _halo_got, _halo_total)
	for child in get_children():
		if child.get_script() == null or not child.has_method("set_locked"):
			continue
		if "exit_portal" not in String(child.get_script().resource_path):
			continue
		var target: String = child.target_character
		if target == "":
			var both_done := _coins_done("Player") and _coins_done("Guardian")
			child.set_locked(not both_done)
		elif target == "Guardian":
			child.set_locked(not _coins_done("Guardian"), "%d/%d" % [_halo_got, _halo_total])
		else:
			child.set_locked(not _coins_done("Player"), "%d/%d" % [_skull_got, _skull_total])


# Called by the exit portal when a character body enters it.
func on_exit_entered(body: Node) -> void:
	var body_name := body.name
	if body_name in _players_at_exit:
		return
	_players_at_exit.append(body_name)
	_try_complete()


# Called by the exit portal when a character body leaves it.
func on_exit_exited(body: Node) -> void:
	_players_at_exit.erase(body.name)


# Completes the level only when both characters stand at their exits AND both
# have collected their full pickup sets.
func _try_complete() -> void:
	if _players_at_exit.size() < 2:
		return
	if not _coins_done("Player") or not _coins_done("Guardian"):
		return
	_complete_level()


# Wrapper for hazard Area2D body_entered signal — discards the body argument.
func _on_hazard_entered(_body: Node) -> void:
	DeathManager.trigger_death()


# Marks the current level complete and returns to level select.
func _complete_level() -> void:
	LevelManager.complete_level(LevelManager.current_level_id)
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")


# Assigns physics authority so each device controls its own character.
func _setup_multiplayer_authority() -> void:
	if NetworkManager.state != NetworkManager.State.CONNECTED:
		return
	$Player.set_multiplayer_authority(1)
	var guardian_authority: int
	if multiplayer.is_server():
		guardian_authority = NetworkManager.client_peer_id
	else:
		guardian_authority = multiplayer.get_unique_id()
	$Guardian.set_multiplayer_authority(guardian_authority)


# Returns to main menu when the remote peer disconnects mid-game.
func _on_peer_disconnected() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
