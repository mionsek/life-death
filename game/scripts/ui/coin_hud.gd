extends CanvasLayer

# Top-left counter showing pickup progress per character, e.g. "0/3" skulls
# and "2/2" hearts. Rows with no pickups in the level are hidden. Counters
# turn green when the set is complete (that character's exit unlocks).

const COLOR_PENDING := Color(1, 1, 1, 0.95)
const COLOR_DONE := Color(0.45, 1.0, 0.5, 1.0)

@onready var _skull_row: HBoxContainer = $Panel/Rows/SkullRow
@onready var _heart_row: HBoxContainer = $Panel/Rows/HeartRow
@onready var _skull_label: Label = $Panel/Rows/SkullRow/Count
@onready var _heart_label: Label = $Panel/Rows/HeartRow/Count


# Updates both counters; hides rows whose total is zero.
func update_counts(skulls_got: int, skulls_total: int, hearts_got: int, hearts_total: int) -> void:
	_skull_row.visible = skulls_total > 0
	_heart_row.visible = hearts_total > 0
	_skull_label.text = "%d/%d" % [skulls_got, skulls_total]
	_heart_label.text = "%d/%d" % [hearts_got, hearts_total]
	_skull_label.add_theme_color_override("font_color",
		COLOR_DONE if skulls_got >= skulls_total else COLOR_PENDING)
	_heart_label.add_theme_color_override("font_color",
		COLOR_DONE if hearts_got >= hearts_total else COLOR_PENDING)
