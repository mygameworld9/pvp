extends Node

var players = {} # { id: { name: "PlayerName", character: "warrior", ready: false } }

signal player_list_changed

func _ready():
	NetworkManager.player_connected.connect(Callable(self, "_on_player_connected"))
	NetworkManager.player_disconnected.connect(Callable(self, "_on_player_disconnected"))

func _on_player_connected(id: int):
	if not multiplayer.is_server():
		return
	players[id] = { "name": "Player " + str(id), "character": "warrior", "ready": false }
	update_player_list.rpc(players)

func _on_player_disconnected(id: int):
	if not multiplayer.is_server():
		return
	if players.has(id):
		players.erase(id)
		update_player_list.rpc(players)

@rpc("authority")
func request_toggle_ready_status():
	var id = multiplayer.get_remote_sender_id()
	if players.has(id):
		players[id].ready = not players[id].ready
		update_player_list.rpc(players)
		# The server won't get the RPC call, so we call it manually
		update_player_list(players)

func host_toggle_ready_status():
	var id = 1 # Host is always 1
	if players.has(id):
		players[id].ready = not players[id].ready
		update_player_list.rpc(players)
		update_player_list(players)

@rpc("any_peer")
func update_player_list(new_players: Dictionary):
	players = new_players
	emit_signal("player_list_changed")

func get_players():
	return players

func are_all_players_ready() -> bool:
	if players.is_empty():
		return false
	for id in players:
		if not players[id].ready:
			return false
	return true
