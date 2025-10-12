extends State
class_name JumpState

func enter():
	character.velocity.y = character.character_data.jump_force

func process_physics(delta: float):
	# Apply gravity
	character.velocity.y += 980 * delta # Assuming default gravity
	
	if character.velocity.y > 0:
		state_machine.transition_to("Fall")
		return

	var intent = InputManager.get_intent()
	character.velocity.x = intent.move * character.character_data.move_speed
	
	character.move_and_slide()
