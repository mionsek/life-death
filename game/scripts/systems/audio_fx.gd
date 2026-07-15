extends Node

# Global sound-effect player (autoload). Lives outside the scene tree's
# levels, so a sound keeps playing across a scene change (e.g. the level
# completion jingle). Plays on the SFX bus, so the settings screen's sound
# toggle (Settings autoload) mutes it globally.

const SOUNDS := {
	"switch": preload("res://assets/audio/sfx/Door_Switch_01.wav"),
	"gate": preload("res://assets/audio/sfx/Gate_Open_01.wav"),
	"level_complete": preload("res://assets/audio/sfx/Level_Complete_01.wav"),
	"menu_select": preload("res://assets/audio/sfx/Menu_Select_02.wav"),
}

# Plays a named one-shot effect; unknown names are ignored with a warning.
func play(sound_name: String) -> void:
	if not SOUNDS.has(sound_name):
		push_warning("AudioFx: unknown sound '%s'" % sound_name)
		return
	var player := AudioStreamPlayer.new()
	player.stream = SOUNDS[sound_name]
	player.bus = "SFX"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
