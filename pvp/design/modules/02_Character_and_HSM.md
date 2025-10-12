# Module 2: Character & Hierarchical State Machine (HSM)

This document details the structure of the `CharacterBody` node, which represents a player in the game world, and the Hierarchical State Machine (HSM) that drives its behavior.

---

### **1. `CharacterBody` (Scene)**

- **Scene Root:** A `CharacterBody2D` node.
- **Purpose:** To be the physical representation of a player in the game world. It handles physics, collision, and visual representation, but delegates all complex behavior logic to its child `StateMachine`.

#### **1.1 Key Responsibilities**

- **Data Binding:** Holds a reference to its corresponding `CharacterData` resource to know its stats (e.g., `move_speed`).
- **Input Forwarding:** If it is the authority for the local player (`is_multiplayer_authority()` is true), it retrieves the input intent from `InputManager` and passes it to the `StateMachine`.
- **State Delegation:** In `_physics_process`, it calls the active state's `process_physics()` method via the `StateMachine`.
- **Network Synchronization:** Its properties (position, velocity, current state) are updated by incoming network data. It does **not** run its own logic if it's a remote client.

#### **1.2 Example Scene Tree (`player.tscn`)**

```
- 📜 player (CharacterBody2D, script: player_character.gd)
  - Sprite2D (Visual representation)
  - CollisionShape2D
  - AnimationPlayer
  - 📜 StateMachine (Node, script: state_machine.gd)
    - 📜 OnGround (Node, script: on_ground_state.gd)
      - 📜 Idle (Node, script: idle_state.gd)
      - 📜 Move (Node, script: move_state.gd)
    - 📜 InAir (Node, script: in_air_state.gd)
      - 📜 Jump (Node, script: jump_state.gd)
      - 📜 Fall (Node, script: fall_state.gd)
```

---

### **2. Hierarchical State Machine (HSM) Design**

The HSM is the "brain" of the character, responsible for managing all its complex behaviors in a clean, modular, and extensible way.

#### **2.1 `State` (Base Class)**

- **File Location:** `scripts/characters/state_machine/state.gd`
- **Purpose:** An abstract base class that defines the contract for all individual state nodes. It represents a single, atomic behavior.
- **Core Interface (Virtual Methods):**
  - `func enter():` Called once when the state becomes active. Used for setup, like playing an animation or starting a timer.
  - `func exit():` Called once when the state is deactivated. Used for cleanup.
  - `func process_input(event: InputEvent) -> State:` Called when the `CharacterBody` receives an input event. It can process the input and return a new state to transition to, or `null` to remain in the current state.
  - `func process_physics(delta: float) -> State:` Called every physics frame. Contains the core logic of the state (e.g., applying gravity, moving the character). Can also return a new state to transition to (e.g., switching from `JumpState` to `FallState` when velocity.y becomes positive).

#### **2.2 `StateMachine` (Controller Class)**

- **File Location:** `scripts/characters/state_machine/state_machine.gd`
- **Purpose:** The manager node that holds references to all possible states and controls the transitions between them.
- **Core Responsibilities:**
  - **Initialization:** On `_ready()`, it identifies its child state nodes and sets the initial state (e.g., `Idle`).
  - **State Delegation:** In its own `_physics_process` and `_input` functions, it calls the corresponding method on the currently active state.
  - **Transition Logic:** Provides a safe `change_state(new_state: State)` method. This method is responsible for:
    1. Calling `exit()` on the current state (if one exists).
    2. Setting the `new_state` as the `current_state`.
    3. Calling `enter()` on the `new_state`.
    4. Emitting a signal `state_changed(new_state_name)` for network synchronization purposes.
