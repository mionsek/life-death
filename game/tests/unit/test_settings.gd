extends GutTest

# Settings autoload: locale switching, audio-bus muting and persistence.

var _saved_locale: String
var _saved_sound: bool
var _saved_music: bool


func before_each() -> void:
	_saved_locale = Settings.locale
	_saved_sound = Settings.sound_enabled
	_saved_music = Settings.music_enabled


func after_each() -> void:
	Settings.set_sound_enabled(_saved_sound)
	Settings.set_music_enabled(_saved_music)
	Settings.set_locale(_saved_locale)


func test_locale_switch_changes_translations() -> void:
	Settings.set_locale("pl")
	assert_eq(TranslationServer.get_locale().substr(0, 2), "pl")
	assert_eq(tr("MENU_START"), "Rozpocznij grę")
	Settings.set_locale("en")
	assert_eq(tr("MENU_START"), "Start Game")


func test_unsupported_locale_is_rejected() -> void:
	Settings.set_locale("en")
	Settings.set_locale("de")
	assert_eq(Settings.locale, "en")


func test_sound_toggle_mutes_sfx_bus() -> void:
	var idx := AudioServer.get_bus_index("SFX")
	assert_gt(idx, 0, "SFX bus should exist in default_bus_layout.tres")
	Settings.set_sound_enabled(false)
	assert_true(AudioServer.is_bus_mute(idx))
	Settings.set_sound_enabled(true)
	assert_false(AudioServer.is_bus_mute(idx))


func test_music_toggle_mutes_music_bus() -> void:
	var idx := AudioServer.get_bus_index("Music")
	assert_gt(idx, 0, "Music bus should exist in default_bus_layout.tres")
	Settings.set_music_enabled(false)
	assert_true(AudioServer.is_bus_mute(idx))
	Settings.set_music_enabled(true)
	assert_false(AudioServer.is_bus_mute(idx))


func test_settings_persist_to_config_file() -> void:
	Settings.set_locale("pl")
	var cfg := ConfigFile.new()
	assert_eq(cfg.load(Settings.CONFIG_PATH), OK)
	assert_eq(cfg.get_value("general", "locale", ""), "pl")


func test_every_tutorial_type_has_both_translations() -> void:
	var types := ["lava", "holy_light", "cloud", "moving_platform",
		"crumbling_platform", "pressure_plate", "one_way", "lever", "door",
		"seesaw", "portal", "skull", "heart"]
	for locale in ["en", "pl"]:
		Settings.set_locale(locale)
		for type in types:
			for suffix in ["TITLE", "BODY"]:
				var key := "TUT_%s_%s" % [type.to_upper(), suffix]
				assert_ne(tr(key), key,
					"missing %s translation for %s" % [locale, key])
