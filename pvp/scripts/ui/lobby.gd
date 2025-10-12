extends Control

func _ready():
	LobbyManager.player_list_changed.connect(Callable(self, "redraw_player_list"))
	$ReadyButton.pressed.connect(Callable(self, "_on_ready_pressed"))
	$StartButton.pressed.connect(Callable(self, "_on_start_pressed"))
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
		$StartButton.visible = true
		$StartButton.disabled = not LobbyManager.are_all_players_ready()
	else:
		$StartButton.visible = false

func _on_ready_pressed():
	var local_id = multiplayer.get_unique_id()
	var players = LobbyManager.get_players()
	if players.has(local_id):
		var current_ready_status = players[local_id].ready
		LobbyManager.set_ready.rpc(local_id, not current_ready_status)

func _on_start_pressed():
	if multiplayer.is_server() and LobbyManager.are_all_players_ready():
		UIManager.show_game()
