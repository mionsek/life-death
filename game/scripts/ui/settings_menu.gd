extends Control

# Settings panel: sound / music toggles and language choice. Works both as a
# standalone scene (main menu) and embedded as an overlay (pause menu) — when
# embedded, Back emits `closed` instead of changing the scene.

signal closed

# Must match Settings.LOCALES order; shown as native names on purpose.
const LANGUAGES: Array[Dictionary] = [
	{"locale": "en", "label": "English"},
	{"locale": "pl", "label": "Polski"},
]


func _ready() -> void:
	var lang: OptionButton = $VBox/LangRow/OptLanguage
	for entry in LANGUAGES:
		lang.add_item(entry.label)
	for i in LANGUAGES.size():
		if LANGUAGES[i].locale == Settings.locale:
			lang.select(i)
	$VBox/ChkSound.button_pressed = Settings.sound_enabled
	$VBox/ChkMusic.button_pressed = Settings.music_enabled
	$VBox/ChkSound.toggled.connect(Settings.set_sound_enabled)
	$VBox/ChkMusic.toggled.connect(Settings.set_music_enabled)
	lang.item_selected.connect(_on_language_selected)
	$VBox/BtnBack.pressed.connect(_on_back)


func _on_language_selected(index: int) -> void:
	Settings.set_locale(LANGUAGES[index].locale)


func _on_back() -> void:
	if get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
	else:
		closed.emit()
