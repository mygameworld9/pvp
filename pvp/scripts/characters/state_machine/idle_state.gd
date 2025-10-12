extends State
class_name IdleState

func process_physics(_delta: float):
	if not character.is_on_floor():
		state_machine.transition_to("Fall")
		return

	if Input.is_action_just_pressed("attack"):
		get_node("/root/Game/CombatSystem").request_skill_use.rpc("slash", Vector2.ZERO)

	var intent = InputManager.get_intent()
	if intent.jump:
		state_machine.transition_to("Jump")
		return
	if intent.move != 0.0:
		state_machine.transition_to("Move")
		return

	character.velocity.x = 0
	character.move_and_slide()
