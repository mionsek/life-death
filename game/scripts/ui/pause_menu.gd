extends CanvasLayer

# In-level pause menu (Escape / Android back): resume, restart level, settings
# overlay and exit to the world map. In multiplayer only the host can restart,
# and the partner must approve — the request/confirm handshake runs over the
# same RPC pattern as the death screen (identical node paths on both peers).

const SETTINGS_SCENE := preload("res://scenes/ui/SettingsMenu.tscn")

var _settings_overlay: Control = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$HUD/Panel/BtnResume.pressed.connect(_resume)
	$HUD/Panel/BtnRestart.pressed.connect(_on_restart_pressed)
	$HUD/Panel/BtnSettings.pressed.connect(_open_settings)
	$HUD/Panel/BtnExitMap.pressed.connect(_on_exit_map_pressed)
	$HUD/ConfirmPanel/Buttons/BtnYes.pressed.connect(_on_confirm_yes)
	$HUD/ConfirmPanel/Buttons/BtnNo.pressed.connect(_on_confirm_no)
	# Restart is host-only in multiplayer.
	if NetworkManager.state == NetworkManager.State.CONNECTED and not multiplayer.is_server():
		$HUD/Panel/BtnRestart.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		_resume()
		get_viewport().set_input_as_handled()
	elif not get_tree().paused:
		# Only pause from live gameplay — never over a death screen or tutorial.
		_open()
		get_viewport().set_input_as_handled()


func _open() -> void:
	visible = true
	get_tree().paused = true
	_show_main_panel()


func _resume() -> void:
	_close_settings()
	visible = false
	get_tree().paused = false


func _show_main_panel() -> void:
	$HUD/Panel.visible = true
	$HUD/ConfirmPanel.visible = false
	$HUD/LblWaiting.visible = false


# ------------------------------------------------------------ restart flow ---

func _on_restart_pressed() -> void:
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		$HUD/Panel.visible = false
		$HUD/LblWaiting.visible = true
		_request_restart.rpc()
	else:
		_do_restart()


# Runs on the partner: opens the pause menu in confirm mode.
@rpc("any_peer", "reliable")
func _request_restart() -> void:
	visible = true
	get_tree().paused = true
	$HUD/Panel.visible = false
	$HUD/LblWaiting.visible = false
	$HUD/ConfirmPanel.visible = true


func _on_confirm_yes() -> void:
	_sync_restart.rpc()


func _on_confirm_no() -> void:
	_decline_restart.rpc()
	_resume()


# Runs on the host when the partner declines: back to the normal menu.
@rpc("any_peer", "reliable")
func _decline_restart() -> void:
	_show_main_panel()


@rpc("any_peer", "call_local", "reliable")
func _sync_restart() -> void:
	_do_restart()


func _do_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


# ---------------------------------------------------------------- settings ---

func _open_settings() -> void:
	if _settings_overlay != null:
		return
	$HUD/Panel.visible = false
	_settings_overlay = SETTINGS_SCENE.instantiate()
	_settings_overlay.closed.connect(_close_settings)
	$HUD.add_child(_settings_overlay)


func _close_settings() -> void:
	if _settings_overlay != null:
		_settings_overlay.queue_free()
		_settings_overlay = null
	if visible:
		_show_main_panel()


# ------------------------------------------------------------- exit to map ---

func _on_exit_map_pressed() -> void:
	if NetworkManager.state == NetworkManager.State.CONNECTED:
		_sync_exit_map.rpc()
	else:
		_do_exit_map()


@rpc("any_peer", "call_local", "reliable")
func _sync_exit_map() -> void:
	_do_exit_map()


func _do_exit_map() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
