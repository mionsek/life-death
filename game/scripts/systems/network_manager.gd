extends Node

enum State { OFFLINE, HOSTING, SEARCHING, CONNECTED }

# Emitted whenever the connection state changes.
signal state_changed(new_state: State)
# Emitted on the client when a host is found via UDP discovery.
signal host_found(host_ip: String)
# Emitted on both peers when the ENet connection is established.
signal connection_established
# Emitted when the ENet connection attempt fails.
signal connection_failed
# Emitted when the remote peer disconnects during an active game.
signal peer_disconnected_in_game

const GAME_PORT: int = 7777
const DISCOVERY_PORT: int = 7778
const BROADCAST_MSG: String = "LIFE_DEATH_HOST"
const BROADCAST_INTERVAL: float = 1.0

# Current connection state; read-only from outside.
var state: State = State.OFFLINE
# Peer ID of the connected client (set on host side only).
var client_peer_id: int = 0

var _udp_sender: PacketPeerUDP = PacketPeerUDP.new()
var _udp_listener: PacketPeerUDP = PacketPeerUDP.new()
var _broadcast_timer: float = 0.0


# Creates an ENet server and starts broadcasting presence via UDP.
func start_host() -> void:
	var peer := ENetMultiplayerPeer.new()
	if peer.create_server(GAME_PORT, 1) != OK:
		push_error("NetworkManager: failed to create ENet server on port %d" % GAME_PORT)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if _udp_sender.bind(0) != OK:
		push_error("NetworkManager: failed to bind UDP sender")
		return
	_udp_sender.set_broadcast_enabled(true)
	_udp_sender.connect_to_host("255.255.255.255", DISCOVERY_PORT)
	_broadcast_timer = 0.0
	_set_state(State.HOSTING)


# Starts listening for UDP broadcasts from a host.
func start_join() -> void:
	if _udp_listener.bind(DISCOVERY_PORT) != OK:
		push_error("NetworkManager: failed to bind UDP listener on port %d" % DISCOVERY_PORT)
		return
	_set_state(State.SEARCHING)


# Tears down any active connection and resets to OFFLINE.
func stop() -> void:
	if multiplayer.has_multiplayer_peer():
		if multiplayer.peer_connected.is_connected(_on_peer_connected):
			multiplayer.peer_connected.disconnect(_on_peer_connected)
		if multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
			multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
		if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
			multiplayer.connected_to_server.disconnect(_on_connected_to_server)
		if multiplayer.connection_failed.is_connected(_on_connection_failed):
			multiplayer.connection_failed.disconnect(_on_connection_failed)
		multiplayer.multiplayer_peer = null
	_udp_sender.close()
	_udp_listener.close()
	client_peer_id = 0
	_broadcast_timer = 0.0
	_set_state(State.OFFLINE)


# Polls UDP while hosting (broadcast) or searching (listen for host).
func _process(delta: float) -> void:
	match state:
		State.HOSTING:
			_broadcast_timer -= delta
			if _broadcast_timer <= 0.0:
				_broadcast_timer = BROADCAST_INTERVAL
				_udp_sender.put_packet(BROADCAST_MSG.to_utf8_buffer())
		State.SEARCHING:
			if _udp_listener.get_available_packet_count() > 0:
				var data := _udp_listener.get_packet().get_string_from_utf8()
				var ip := _udp_listener.get_packet_ip()
				if data == BROADCAST_MSG:
					_udp_listener.close()
					_connect_to_host(ip)


# Creates an ENet client and attempts to connect to the discovered host.
func _connect_to_host(ip: String) -> void:
	host_found.emit(ip)
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(ip, GAME_PORT) != OK:
		push_error("NetworkManager: failed to create ENet client to %s:%d" % [ip, GAME_PORT])
		_set_state(State.OFFLINE)
		connection_failed.emit()
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)


# Fires on the host when a client connects.
func _on_peer_connected(id: int) -> void:
	client_peer_id = id
	_udp_sender.close()
	_set_state(State.CONNECTED)
	connection_established.emit()


# Fires on the host when the connected client disconnects mid-game.
func _on_peer_disconnected(_id: int) -> void:
	if state == State.CONNECTED:
		stop()
		peer_disconnected_in_game.emit()


# Fires on the client when it successfully connects to the host.
func _on_connected_to_server() -> void:
	_set_state(State.CONNECTED)
	connection_established.emit()


# Fires on the client when the connection attempt fails.
func _on_connection_failed() -> void:
	stop()
	connection_failed.emit()
