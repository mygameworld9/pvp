extends Node

var characters: Dictionary = {} # Key: "warrior", Value: CharacterData
var skills: Dictionary = {}     # Key: "fireball", Value: SkillData
var maps: Dictionary = {}       # Key: "ancient_ruins", Value: MapData

func _ready():
	_load_resources_from_dir("res://data/characters", characters)
	_load_resources_from_dir("res://data/skills", skills)
	_load_resources_from_dir("res://data/maps", maps)

func _load_resources_from_dir(path: String, target_dictionary: Dictionary):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				_load_resources_from_dir(path.path_join(file_name), target_dictionary)
			elif file_name.ends_with(".tres"):
				var resource = load(path.path_join(file_name))
				var key = file_name.get_basename()
				target_dictionary[key] = resource
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func get_character_data(id: String):
	return characters.get(id)

func get_skill_data(id: String):
	return skills.get(id)

func get_map_data(id: String):
	return maps.get(id)

func get_all_character_data() -> Dictionary:
	return characters

func get_all_skill_data() -> Dictionary:
	return skills
	
func get_all_map_data() -> Dictionary:
	return maps
