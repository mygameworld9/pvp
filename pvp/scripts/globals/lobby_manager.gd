extends Node

var players = {} # { id: { name: "PlayerName", character: "warrior", ready: false } }

signal player_list_changed

func _ready():
	NetworkManager.player_connected.connect(Callable(self, "_on_player_connected"))
	NetworkManager.player_disconnected.connect(Callable(self, "_on_player_disconnected"))

func _on_player_connected(id: int):
	players[id] = { "name": "Player " + str(id), "character": "warrior", "ready": false }
	emit_signal("player_list_changed")

func _on_player_disconnected(id: int):
	players.erase(id)
	emit_signal("player_list_changed")

@rpc("authority", "call_local")
func server_set_player_ready(player_id: int, is_ready: bool):
	if players.has(player_id):
		players[player_id].ready = is_ready
		client_update_player_ready.rpc(player_id, is_ready)

@rpc("any_peer")
func client_update_player_ready(player_id: int, is_ready: bool):
	if players.has(player_id):
		players[player_id].ready = is_ready
		emit_signal("player_list_changed")

@rpc("any_peer", "call_local")
func set_character(id: int, character_id: String):
	if players.has(id):
		players[id].character = character_id
		emit_signal("player_list_changed")

func get_players():
	return players

func get_all_players_ready() -> bool:
	for id in players:
		if not players[id].ready:
			return false
	return true
