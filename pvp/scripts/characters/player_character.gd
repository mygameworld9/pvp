extends CharacterBody2D

@export var character_id: String = "warrior"

var character_data: CharacterData
var health: float

signal health_changed(new_health, id)

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	add_to_group("players")

func _ready():
	character_data = DataRegistry.get_character_data(character_id)
	health = character_data.max_health
	if character_data:
		print("Loaded character data for: " + character_data.character_name)
	else:
		print("Failed to load character data for id: " + character_id)

	if not is_multiplayer_authority():
		$StateMachine.set_physics_process(false)

@rpc("any_peer", "call_local")
func take_damage(amount: float):
	health -= amount
	emit_signal("health_changed", health, name.to_int())
	print("Player %s took %d damage, health is now %d" % [name, amount, health])

func _physics_process(delta):
	# The state machine only runs if it's the authority
	pass
