extends CanvasLayer

# "Level Complete" banner shown by level_base for a few seconds before the
# world map loads. Pops in with a fade + slight scale; purely visual, the
# timing and scene change stay in level_base.


func _ready() -> void:
	var hud: Control = $HUD
	hud.modulate.a = 0.0
	var panel: Control = $HUD/Panel
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.7, 0.7)
	var tw := create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tw.tween_property(hud, "modulate:a", 1.0, 0.3)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK)
