extends State
class_name FallState

func process_physics(_delta: float):
	# Apply gravity
	character.velocity.y += 980 * _delta # Assuming default gravity

	if character.is_on_floor():
		state_machine.transition_to("Idle")
		return

	var intent = InputManager.get_intent()
	character.velocity.x = intent.move * character.character_data.move_speed
	
	character.move_and_slide()
