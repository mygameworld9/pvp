extends Node

@export var player_scene: PackedScene
@export var spawner: MultiplayerSpawner

var scores = {}
const WIN_SCORE = 3

signal game_over(winner_id)

func _ready():
	if multiplayer.is_server():
		var players = LobbyManager.get_players()
		for id in players:
			scores[id] = 0
			spawn_player.rpc(id, players[id])
		
		var combat_system = get_node("/root/Game/CombatSystem")
		combat_system.player_eliminated.connect(Callable(self, "_on_player_eliminated"))


@rpc("any_peer")
func spawn_player(id: int, player_data: Dictionary):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	player.character_id = player_data.character
	spawner.add_child(player)
	
func _on_player_eliminated(id: int):
	# The player who was eliminated is `id`.
	# We need to figure out who eliminated them.
	# This requires a more complex combat system.
	# For now, we'll just give a point to the first player who is not the eliminated player.
	for player_id in scores:
		if player_id != id:
			scores[player_id] += 1
			if scores[player_id] >= WIN_SCORE:
				emit_signal("game_over", player_id)
				print("Player %d wins!" % player_id)
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			break
