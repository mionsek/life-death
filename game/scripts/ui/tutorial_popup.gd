extends CanvasLayer

# Modal lesson card shown by TutorialManager while the tree is paused.
# Dismissing it unpauses the game and frees the popup.


func _ready() -> void:
	$HUD/Panel/BtnOk.pressed.connect(_on_ok)


# Fills the card from the tutorial type's translation keys.
func setup(type: String) -> void:
	var key := type.to_upper()
	$HUD/Panel/Title.text = tr("TUT_%s_TITLE" % key)
	$HUD/Panel/Body.text = tr("TUT_%s_BODY" % key)


func _on_ok() -> void:
	get_tree().paused = false
	queue_free()
