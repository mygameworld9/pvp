extends Resource
class_name SkillData

@export var skill_name: String          # Name of the skill
@export var damage: float               # Damage value (if applicable)
@export var cooldown: float             # Time in seconds before it can be used again
@export var animation_name: StringName  # The animation to play in the AnimationPlayer node
