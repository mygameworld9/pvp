extends State
class_name MoveState

func process_physics(delta: float):
	if not character.is_on_floor():
		state_machine.transition_to("Fall")
		return

	var intent = InputManager.get_intent()
	if intent.jump:
		state_machine.transition_to("Jump")
		return
	
	if intent.move != 0.0:
		character.velocity.x = intent.move * character.character_data.move_speed
	else:
		state_machine.transition_to("Idle")
		return

	character.move_and_slide()
