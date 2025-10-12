extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.character = get_parent()
			child.state_machine = self
	
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _physics_process(delta: float):
	if current_state:
		current_state.process_physics(delta)

func transition_to(state_name: String, msg: Dictionary = {}):
	if not states.has(state_name.to_lower()):
		return

	if current_state:
		current_state.exit()
	
	current_state = states[state_name.to_lower()]
	current_state.enter()
