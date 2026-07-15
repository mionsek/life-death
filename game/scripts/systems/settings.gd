extends Node

# Persists user preferences (sound / music / language) in user://settings.cfg
# and applies them: language via TranslationServer, audio by muting the
# Music / SFX buses (defined in default_bus_layout.tres).

const CONFIG_PATH: String = "user://settings.cfg"
const LOCALES: Array[String] = ["en", "pl"]

var sound_enabled: bool = true
var music_enabled: bool = true
var locale: String = ""


func _ready() -> void:
	_load()
	_apply()


# The device language on first run, en for anything we don't translate.
func _default_locale() -> String:
	var lang := OS.get_locale_language()
	return lang if lang in LOCALES else "en"


func set_sound_enabled(enabled: bool) -> void:
	sound_enabled = enabled
	_apply()
	_save()


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	_apply()
	_save()


func set_locale(new_locale: String) -> void:
	if new_locale not in LOCALES:
		push_warning("Settings: unsupported locale '%s'" % new_locale)
		return
	locale = new_locale
	_apply()
	_save()


func _apply() -> void:
	TranslationServer.set_locale(locale)
	_set_bus_muted("SFX", not sound_enabled)
	_set_bus_muted("Music", not music_enabled)


func _set_bus_muted(bus_name: String, muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_mute(idx, muted)


func _load() -> void:
	locale = _default_locale()
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	sound_enabled = cfg.get_value("audio", "sound_enabled", true)
	music_enabled = cfg.get_value("audio", "music_enabled", true)
	var stored: String = cfg.get_value("general", "locale", locale)
	if stored in LOCALES:
		locale = stored


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sound_enabled", sound_enabled)
	cfg.set_value("audio", "music_enabled", music_enabled)
	cfg.set_value("general", "locale", locale)
	cfg.save(CONFIG_PATH)
