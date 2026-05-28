extends Control

# Handles lobby UI: hosting, joining, and navigation to the game.
func _ready() -> void:
	NetworkManager.state_changed.connect(_on_state_changed)
	NetworkManager.host_found.connect(_on_host_found)
	NetworkManager.connection_established.connect(_on_connection_established)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	$VBox/BtnHost.pressed.connect(_on_host_pressed)
	$VBox/BtnJoin.pressed.connect(_on_join_pressed)
	$VBox/BtnBack.pressed.connect(_on_back_pressed)
	_update_ui(NetworkManager.State.OFFLINE)


# Starts hosting and waits for a second player.
func _on_host_pressed() -> void:
	NetworkManager.start_host()


# Starts scanning for a host on the local network.
func _on_join_pressed() -> void:
	NetworkManager.start_join()


# Stops any active connection and returns to the main menu.
func _on_back_pressed() -> void:
	NetworkManager.stop()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


# Updates status label when a host is discovered.
func _on_host_found(ip: String) -> void:
	$VBox/LblStatus.text = "Connecting to %s..." % ip


# Both peers navigate to the game level once connected.
func _on_connection_established() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/TestLevel.tscn")


# Shows error and re-enables buttons on connection failure.
func _on_connection_failed() -> void:
	$VBox/LblStatus.text = "Connection failed. Try again."
	$VBox/BtnHost.disabled = false
	$VBox/BtnJoin.disabled = false


# Syncs button states and status text to the current network state.
func _on_state_changed(new_state: NetworkManager.State) -> void:
	_update_ui(new_state)


func _update_ui(s: NetworkManager.State) -> void:
	var busy := s != NetworkManager.State.OFFLINE
	$VBox/BtnHost.disabled = busy
	$VBox/BtnJoin.disabled = busy
	match s:
		NetworkManager.State.OFFLINE:
			$VBox/LblStatus.text = "Connect both devices to the same WiFi"
		NetworkManager.State.HOSTING:
			$VBox/LblStatus.text = "Waiting for second player..."
		NetworkManager.State.SEARCHING:
			$VBox/LblStatus.text = "Searching for host..."
		NetworkManager.State.CONNECTED:
			$VBox/LblStatus.text = "Connected! Starting game..."
