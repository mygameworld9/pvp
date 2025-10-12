# Module 7: InputManager

This document describes the `InputManager`, a global singleton designed to decouple raw hardware input from the game's character logic.

---

### **1. Core Philosophy: Input as Intent**

- **Principle:** The `InputManager`'s role is not to make the character move, but to report the *player's intent*. Instead of dealing with specific keys like "W" or "Spacebar", the rest of the game code will ask the `InputManager` for abstract actions like "move_forward" or "jump".
- **Benefit:** This makes the code cleaner and more flexible. Remapping controls becomes a simple matter of changing the `InputManager`'s configuration, without touching any of the character or state machine code. It also clarifies the logic for multiplayer, as only the local player's character will ever consult the `InputManager`.

---

### **2. `InputManager` (Global Singleton)**

- **File Location:** `scripts/globals/input_manager.gd`
- **Registered as:** Autoload singleton named `InputManager`.
- **Scope:** **This system is for the local player only.** Networked characters receive their instructions via RPCs and state synchronization, not from this manager.

#### **2.1 Responsibilities**

- To define and manage all player-mappable actions using Godot's built-in Input Map (found in `Project -> Project Settings -> Input Map`).
- To provide simple, clean functions that other systems can call to query the current state of these abstract actions.

#### **2.2 Pre-configured Actions (Input Map)**

The following actions should be defined in the project's Input Map:

- `move_left`: (e.g., bound to `A` key)
- `move_right`: (e.g., bound to `D` key)
- `jump`: (e.g., bound to `Spacebar`)
- `attack_primary`: (e.g., bound to `Mouse Left Click`)
- `attack_secondary`: (e.g., bound to `Mouse Right Click`)

#### **2.3 Public API**

The `InputManager` exposes a simple "getter" function that returns a dictionary or a custom object representing the player's current input state. This function is called every physics frame by the local player's `CharacterBody`.

- `func get_input_intent() -> Dictionary:`
  - **Returns:** A dictionary summarizing the current input state. This prevents other scripts from having to query multiple `Input.is_action_pressed()` functions.
  - **Example Return Value:**
    ```
    {
        "move_direction": -1.0,  // -1 for left, 1 for right, 0 for none
        "is_jump_pressed": true,
        "is_primary_attack_pressed": false
    }
    ```

#### **2.4 Pseudocode Implementation**

```gdscript
# scripts/globals/input_manager.gd
extends Node

# This function is the single public entry point for this manager.
func get_input_intent() -> Dictionary:
    var move_dir = Input.get_axis("move_left", "move_right")
    
    var intent = {
        "move_direction": move_dir,
        "is_jump_pressed": Input.is_action_just_pressed("jump"),
        "is_primary_attack_pressed": Input.is_action_pressed("attack_primary"),
        "is_secondary_attack_pressed": Input.is_action_pressed("attack_secondary")
    }
    
    return intent
```

#### **2.5 Usage Example (in `CharacterBody`)**

```gdscript
# In player_character.gd, inside _physics_process...

# This check ensures only the locally controlled character processes input.
if is_multiplayer_authority():
    var input_intent = InputManager.get_input_intent()
    
    # The intent is then passed to the state machine to be processed.
    state_machine.process_player_input(input_intent)

    # The intent can also be sent over the network.
    # Note: It's often better to send specific actions (like "jump") via RPC
    # rather than streaming the entire input dictionary every frame.
    if input_intent.is_jump_pressed:
        server_rpc_request_jump() # Example RPC
```
