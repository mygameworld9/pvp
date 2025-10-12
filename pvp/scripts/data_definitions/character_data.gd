extends Resource
class_name CharacterData

@export var character_name: String      # Name displayed in UI
@export var max_health: float           # Maximum health points
@export var move_speed: float           # Base movement speed (pixels/sec)
@export var jump_force: float           # Initial vertical velocity for a jump
@export var skills: Array[SkillData]  # An array of skills this character possesses
