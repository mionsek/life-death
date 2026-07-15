extends CanvasLayer

# Modal lesson card shown by TutorialManager while the tree is paused. The
# overlay shader darkens the screen except a pulsing spotlight around the
# explained obstacle; the text card moves to the opposite half so it never
# covers the highlight. Dismissing unpauses the game and frees the popup.

# Spotlight size around the obstacle's origin (canvas px).
const HOLE_RADIUS: float = 46.0

var _target: Node2D = null


func _ready() -> void:
	$HUD/Panel/BtnOk.pressed.connect(_on_ok)


# Fills the card from the tutorial type's translation keys and aims the
# spotlight at the obstacle (target may be null — plain dark overlay then).
func setup(type: String, target: Node2D = null) -> void:
	var key := type.to_upper()
	$HUD/Panel/Title.text = tr("TUT_%s_TITLE" % key)
	$HUD/Panel/Body.text = tr("TUT_%s_BODY" % key)
	_target = target
	_update_spotlight()


# Tracks the target every frame (window resize, safety on freed nodes).
func _process(_delta: float) -> void:
	_update_spotlight()


func _update_spotlight() -> void:
	var mat: ShaderMaterial = $HUD/Overlay.material
	var canvas_size: Vector2 = $HUD/Overlay.size
	mat.set_shader_parameter("canvas_size", canvas_size)
	if _target == null or not is_instance_valid(_target):
		mat.set_shader_parameter("hole_center", Vector2(-1000, -1000))
		return
	# The obstacle's position in canvas coordinates (camera included).
	var center: Vector2 = _target.get_global_transform_with_canvas().origin
	mat.set_shader_parameter("hole_center", center)
	mat.set_shader_parameter("hole_radius", HOLE_RADIUS)
	# Keep the card on the opposite half of the screen than the spotlight.
	var frac := 0.68 if center.y < canvas_size.y / 2.0 else 0.32
	$HUD/Panel.anchor_top = frac
	$HUD/Panel.anchor_bottom = frac


func _on_ok() -> void:
	get_tree().paused = false
	queue_free()
