# Dev helper: instantiates the scenes passed after "--" and reports load errors.
# Run: godot --headless -s res://tools/smoke_load.gd -- res://scenes/levels/heaven/Level_Heaven_01.tscn
extends SceneTree

func _init() -> void:
	# Defer until autoload singletons exist — scripts reference them by name.
	_run.call_deferred()


func _run() -> void:
	var failed := false
	for path in OS.get_cmdline_user_args():
		var packed: PackedScene = load(path)
		if packed == null:
			push_error("LOAD FAIL: " + path)
			failed = true
			continue
		var inst := packed.instantiate()
		if inst == null:
			push_error("INSTANCE FAIL: " + path)
			failed = true
			continue
		root.add_child(inst)
		inst.queue_free()
		print("OK: ", path)
	await process_frame
	quit(1 if failed else 0)
