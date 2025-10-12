extends Node

signal player_eliminated(id)

@rpc("authority", "call_local")
func request_skill_use(skill_id: String, _direction: Vector2):
	# This function is called by a client and executed on the server.
	var player_id = multiplayer.get_remote_sender_id()
	var skill_data = DataRegistry.get_skill_data(skill_id)

	if not skill_data:
		return

	# In a real game, you'd check cooldowns, range, etc.
	# For now, we'll just apply damage in an area.
	
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.name != str(player_id): # Don't hit yourself
			# Simple distance check for hit detection
			var player_node = get_node("/root/Game/" + str(player_id))
			if player_node.global_position.distance_to(player.global_position) < 100:
				player.take_damage.rpc(skill_data.damage)

func _ready():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		player.health_changed.connect(Callable(self, "_on_player_health_changed"))

func _on_player_health_changed(new_health, player_id):
	if new_health <= 0:
		emit_signal("player_eliminated", player_id)
		# You might want to respawn the player or end the game here.
		var player_node = get_node("/root/Game/" + str(player_id))
		if player_node:
			player_node.queue_free()
