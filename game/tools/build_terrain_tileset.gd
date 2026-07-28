# Builds the TileSet resource used to paint terrain, from the normalised atlas
# that slice_terrain.gd produces.
#
# The atlas is indexed by the neighbour bitmask, so wiring Godot's autotiling is
# a direct translation: a tile that was cut with a neighbour to the north gets
# the north peering bit, and so on. Painting a terrain then makes the engine
# pick corners and edges by itself.
#
# Every tile also gets a full-square collision on the world physics layer, so a
# painted level is solid without a single hand-placed StaticBody2D.
# Run: godot --headless -s res://tools/build_terrain_tileset.gd
extends SceneTree

const ATLAS := "res://assets/tilesets/earth/earth_terrain.png"
const DST := "res://assets/tilesets/earth/earth_terrain.tres"
const TILE := 32
# Matches the project's world layer (LEVEL_BUILDING.md: "Layer = tylko 3").
const WORLD_LAYER := 4

const N := 1
const E := 2
const S := 4
const W := 8


func _init() -> void:
	var texture: Texture2D = load(ATLAS)
	if texture == null:
		push_error("cannot load " + ATLAS)
		quit(1)
		return

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE, TILE)

	# These adders return void, so the new index is read back from the counts.
	tile_set.add_physics_layer()
	var physics_layer := tile_set.get_physics_layers_count() - 1
	tile_set.set_physics_layer_collision_layer(physics_layer, WORLD_LAYER)
	tile_set.set_physics_layer_collision_mask(physics_layer, 0)

	tile_set.add_terrain_set()
	var terrain_set := tile_set.get_terrain_sets_count() - 1
	tile_set.set_terrain_set_mode(terrain_set, TileSet.TERRAIN_MODE_MATCH_SIDES)
	tile_set.add_terrain(terrain_set)
	tile_set.set_terrain_name(terrain_set, 0, "Ziemia")
	tile_set.set_terrain_color(terrain_set, 0, Color(0.45, 0.8, 0.3))

	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE, TILE)
	tile_set.add_source(source, 0)

	var half := TILE / 2.0
	var square := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half),
	])

	for mask in 16:
		var coords := Vector2i(mask % 4, mask / 4)
		source.create_tile(coords)
		var data := source.get_tile_data(coords, 0)

		data.add_collision_polygon(physics_layer)
		data.set_collision_polygon_points(physics_layer, 0, square)

		data.terrain_set = terrain_set
		data.terrain = 0
		if (mask & N) != 0:
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE, 0)
		if (mask & E) != 0:
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE, 0)
		if (mask & S) != 0:
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, 0)
		if (mask & W) != 0:
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE, 0)

	var err := ResourceSaver.save(tile_set, DST)
	if err != OK:
		push_error("could not save %s (error %d)" % [DST, err])
		quit(1)
		return
	print("  saved ", DST, " — 16 tiles, terrain autotiling, world collision")
	quit()
