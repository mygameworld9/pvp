extends Node

const DEFAULT_PORT = 7777
const MAX_PLAYERS = 4

var enet_peer = ENetMultiplayerPeer.new()

signal player_connected(id)
signal player_disconnected(id)

func _ready():
	multiplayer.peer_connected.connect(Callable(self, "_on_player_connected"))
	multiplayer.peer_disconnected.connect(Callable(self, "_on_player_disconnected"))

func host_game():
	var error = enet_peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if error != OK:
		print("Failed to host game.")
		return
	multiplayer.set_multiplayer_peer(enet_peer)
	print("Server started on port %d" % DEFAULT_PORT)
	emit_signal("player_connected", 1)

func join_game(address: String):
	var error = enet_peer.create_client(address, DEFAULT_PORT)
	if error != OK:
		print("Failed to join game.")
		return
	multiplayer.set_multiplayer_peer(enet_peer)

func _on_player_connected(id: int):
	print("Player connected: %d" % id)
	emit_signal("player_connected", id)

func _on_player_disconnected(id: int):
	print("Player disconnected: %d" % id)
	emit_signal("player_disconnected", id)
