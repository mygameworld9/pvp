extends Resource
class_name MapData

@export var map_name: String              # Name of the map for UI selection
@export var map_scene: PackedScene        # A direct link to the map's .tscn file
@export var player_spawn_points: Array[Vector2] # An array of possible spawn locations
