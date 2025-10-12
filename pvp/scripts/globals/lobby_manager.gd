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
	# The server calling an RPC on itself has a sender ID of 0.
	# We treat 0 as the host's ID, which is always 1.
	if id == 0:
		id = 1
	
	if players.has(id):
		players[id].ready = not players[id].ready
		# Broadcast the updated list to all clients
		update_player_list.rpc(players)
		# Update the server's local list as well
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
