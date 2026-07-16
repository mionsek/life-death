# Dev helper: prints the geometry needed to anchor the lever handle on the
# base's black dot — the dot's centroid in lever_base.png and the handle's
# grip-end position in lever_handle.png.
# Run: godot --headless -s res://tools/find_anchor.gd
extends SceneTree


func _init() -> void:
	var base := Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/doors/lever_base.png"))
	var handle := Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/doors/lever_handle.png"))
	print("base size: ", base.get_size(), "  handle size: ", handle.get_size())

	# black dot = near-black, opaque pixels
	var sum := Vector2.ZERO
	var count := 0
	for y in base.get_height():
		for x in base.get_width():
			var c := base.get_pixel(x, y)
			if c.a > 0.9 and maxf(c.r, maxf(c.g, c.b)) < 0.12:
				sum += Vector2(x, y)
				count += 1
	if count > 0:
		print("black dot centroid in base: ", sum / count, " (", count, " px)")

	# handle: bounding box of opaque pixels + red knob centroid (to know which
	# end is the grip)
	var used := handle.get_used_rect()
	print("handle used rect: ", used)
	var red_sum := Vector2.ZERO
	var red_count := 0
	for y in handle.get_height():
		for x in handle.get_width():
			var c := handle.get_pixel(x, y)
			if c.a > 0.5 and c.r > 0.5 and c.g < 0.35 and c.b < 0.35:
				red_sum += Vector2(x, y)
				red_count += 1
	if red_count > 0:
		print("red knob centroid in handle: ", red_sum / red_count, " (", red_count, " px)")
	quit()
