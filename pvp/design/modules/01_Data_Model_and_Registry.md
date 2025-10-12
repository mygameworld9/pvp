# Module 1: Core Data Model & DataRegistry

This document defines the core data structures that drive the game's content and the global registry responsible for loading and providing access to this data.

---

### **1. Core Philosophy: Configuration-Driven**

- **Principle:** All game-defining data (character stats, skill effects, map layouts) is separated from game logic.
- **Implementation:** Using Godot's `Resource` system (`.tres` files).
- **Advantage:** Allows designers to create and balance content directly in the Godot editor without programmer intervention, enabling parallel development.

---

### **2. Data Structure Definitions**

#### **2.1 `CharacterData` (Resource)**

- **File Location:** `scripts/data_definitions/character_data.gd`
- **Purpose:** Defines the static, unchangeable attributes of a playable character. It is a blueprint for creating a character instance.
- **Key Fields:**
  ```gdscript
  @export var character_name: String      # Name displayed in UI
  @export var max_health: float           # Maximum health points
  @export var move_speed: float           # Base movement speed (pixels/sec)
  @export var jump_force: float           # Initial vertical velocity for a jump
  @export var skills: Array[SkillData]  # An array of skills this character possesses
  ```

#### **2.2 `SkillData` (Resource)**

- **File Location:** `scripts/data_definitions/skill_data.gd`
- **Purpose:** Defines the static properties of a single skill or ability.
- **Key Fields:**
  ```gdscript
  @export var skill_name: String          # Name of the skill
  @export var damage: float               # Damage value (if applicable)
  @export var cooldown: float             # Time in seconds before it can be used again
  @export var animation_name: StringName  # The animation to play in the AnimationPlayer node
  ```

#### **2.3 `MapData` (Resource)**

- **File Location:** `scripts/data_definitions/map_data.gd`
- **Purpose:** Defines the metadata and configuration for a game level.
- **Key Fields:**
  ```gdscript
  @export var map_name: String              # Name of the map for UI selection
  @export var map_scene: PackedScene        # A direct link to the map's .tscn file
  @export var player_spawn_points: Array[Vector2] # An array of possible spawn locations
  ```

---

### **3. `DataRegistry` (Global Singleton)**

- **File Location:** `scripts/globals/data_registry.gd`
- **Registered as:** Autoload singleton named `DataRegistry`.
- **Purpose:** To automatically discover, load, and provide global access to all `.tres` data resources at game startup.

#### **3.1 Responsibilities**

- On `_ready()`, recursively scan the `data/` directory.
- Load all `.tres` files found into memory.
- Store the loaded resources in dictionaries, keyed by their filename (e.g., "warrior" -> `CharacterData` resource).
- Provide public functions to safely retrieve data.

#### **3.2 Pseudocode Implementation**

```gdscript
# scripts/globals/data_registry.gd
extends Node

var characters: Dictionary = {} # Key: "warrior", Value: CharacterData
var skills: Dictionary = {}     # Key: "fireball", Value: SkillData
var maps: Dictionary = {}       # Key: "ancient_ruins", Value: MapData

func _ready():
    _load_resources_from_dir("data/characters", characters)
    _load_resources_from_dir("data/skills", skills)
    _load_resources_from_dir("data/maps", maps)

func _load_resources_from_dir(path: String, target_dictionary: Dictionary):
    # Pseudocode:
    # 1. Use DirAccess to open the specified path.
    # 2. Iterate through all files in the directory.
    # 3. If a file ends with ".tres":
    #    - Load the resource using `load()`.
    #    - Get the filename without the extension.
    #    - Store it in the target_dictionary with the filename as the key.
    pass

func get_character_data(id: String) -> CharacterData:
    return characters.get(id)

func get_map_data(id: String) -> MapData:
    return maps.get(id)

# ... other getters as needed
```
