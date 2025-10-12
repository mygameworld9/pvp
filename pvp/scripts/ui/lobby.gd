extends Control

func _ready():
	LobbyManager.player_list_changed.connect(Callable(self, "redraw_player_list"))
	$StartButton.pressed.connect(Callable(self, "_on_start_pressed"))
	$ReadyButton.toggled.connect(Callable(self, "_on_ready_toggled"))
	
	if not multiplayer.is_server():
		$StartButton.hide()

	redraw_player_list()

func redraw_player_list():
	for child in $PlayerList.get_children():
		child.queue_free()
	
	var players = LobbyManager.get_players()
	for id in players:
		var player_info = players[id]
		var label = Label.new()
		label.text = "Player %d: %s (%s)" % [id, player_info.name, "Ready" if player_info.ready else "Not Ready"]
		$PlayerList.add_child(label)
		
	if multiplayer.is_server():
		$StartButton.disabled = not LobbyManager.get_all_players_ready()

func _on_start_pressed():
	# This should only be callable by the host.
	UIManager.show_game()

func _on_ready_toggled(button_pressed: bool):
	var my_id = multiplayer.get_unique_id()
	LobbyManager.server_set_player_ready.rpc_id(1, my_id, button_pressed)
