extends Node

# Global sound-effect player (autoload). Lives outside the scene tree's
# levels, so a sound keeps playing across a scene change (e.g. the level
# completion jingle). The volume field is the hook for the settings screen's
# future sound on/off toggle.

const SOUNDS := {
	"switch": preload("res://assets/audio/sfx/Door_Switch_01.wav"),
	"gate": preload("res://assets/audio/sfx/Gate_Open_01.wav"),
	"level_complete": preload("res://assets/audio/sfx/Level_Complete_01.wav"),
	"menu_select": preload("res://assets/audio/sfx/Menu_Select_02.wav"),
}

# Master switch for effects; the settings screen (branch 021) will drive this.
var enabled: bool = true


# Plays a named one-shot effect; unknown names are ignored with a warning.
func play(sound_name: String) -> void:
	if not enabled:
		return
	if not SOUNDS.has(sound_name):
		push_warning("AudioFx: unknown sound '%s'" % sound_name)
		return
	var player := AudioStreamPlayer.new()
	player.stream = SOUNDS[sound_name]
	player.bus = "Master"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
