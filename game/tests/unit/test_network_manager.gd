extends GutTest

# Ensures a clean state after each test by stopping any active connection.
func after_each() -> void:
	NetworkManager.stop()


# NetworkManager starts in the OFFLINE state.
func test_initial_state_is_offline() -> void:
	assert_eq(NetworkManager.state, NetworkManager.State.OFFLINE)


# Calling start_host transitions to HOSTING state.
func test_start_host_changes_state_to_hosting() -> void:
	NetworkManager.start_host()
	assert_eq(NetworkManager.state, NetworkManager.State.HOSTING)


# Calling start_join transitions to SEARCHING state.
func test_start_join_changes_state_to_searching() -> void:
	NetworkManager.start_join()
	assert_eq(NetworkManager.state, NetworkManager.State.SEARCHING)


# Calling stop always returns to OFFLINE, regardless of previous state.
func test_stop_resets_state_to_offline() -> void:
	NetworkManager.start_host()
	NetworkManager.stop()
	assert_eq(NetworkManager.state, NetworkManager.State.OFFLINE)


# Stopping a second time when already OFFLINE is a no-op (no crash).
func test_stop_when_already_offline_does_not_crash() -> void:
	NetworkManager.stop()
	assert_eq(NetworkManager.state, NetworkManager.State.OFFLINE)
