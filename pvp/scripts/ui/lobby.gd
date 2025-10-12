extends Control

func _ready():
	LobbyManager.player_list_changed.connect(Callable(self, "redraw_player_list"))
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

func _on_start_pressed():
	# For now, this just goes to the game. Later it will be host-only.
	UIManager.show_game()
