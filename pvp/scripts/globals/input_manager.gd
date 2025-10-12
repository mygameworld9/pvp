extends Node

var intent = {
	"move": 0.0, # -1 for left, 1 for right
	"jump": false
}

func _process(delta):
	intent.move = Input.get_axis("move_left", "move_right")
	intent.jump = Input.is_action_just_pressed("jump")

func get_intent() -> Dictionary:
	return intent
