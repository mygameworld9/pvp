# Master Implementation Plan

This document provides a comprehensive, step-by-step guide to developing the game, based on the established architectural and module design documents. It serves as the primary roadmap for development, intended to be followed sequentially.

---

### **Phase 1: Project Foundation & Core Data Structures**

* **Goal:** Establish the data-driven backbone of the project. By the end of this phase, the project will have a system for defining and loading all game content from external resource files.

-   [ ] **1.1 Setup Project Structure:**
    -   Create the directory structure as defined in `大纲.md` (`scenes/`, `scripts/`, `data/`, `assets/`).
    -   Initialize a Git repository and create a `.gitignore` file suitable for a Godot project.

-   [ ] **1.2 Implement Core Data Definitions:**
    -   Create the script `scripts/data_definitions/character_data.gd` with the fields defined in `01_Data_Model_and_Registry.md`.
    -   Create the script `scripts/data_definitions/skill_data.gd`.
    -   Create the script `scripts/data_definitions/map_data.gd`.

-   [ ] **1.3 Create Test Data Resources:**
    -   In the `data/characters/` directory, create at least two `.tres` files using the `CharacterData` resource type (e.g., `warrior.tres`, `mage.tres`) and fill in their stats.
    -   In `data/skills/`, create sample `.tres` files for skills.
    -   In `data/maps/`, create a `test_map.tres` file using the `MapData` resource type.

-   [ ] **1.4 Implement the `DataRegistry` Singleton:**
    -   Create the script `scripts/globals/data_registry.gd`.
    -   Implement the logic to scan the `data/` subdirectories and load all `.tres` resources into dictionaries on startup.
    -   Configure the script as an Autoload singleton named `DataRegistry` in the project settings.

---

### **Phase 2: Single-Player Character Prototype**

* **Goal:** Create a fully functional, playable character in a single-player environment. The focus is on game feel, responsiveness, and ensuring the data-driven systems work as intended.

-   [ ] **2.1 Implement the State Machine Foundation:**
    -   Create the base `State` class (`scripts/characters/state_machine/state.gd`) with its virtual methods (`enter`, `exit`, `process_input`, `process_physics`).
    -   Create the `StateMachine` controller class (`scripts/characters/state_machine/state_machine.gd`) with its logic for managing and transitioning between states.

-   [ ] **2.2 Build the `CharacterBody` Scene:**
    -   Create `player.tscn` with a `CharacterBody2D` root.
    -   Add necessary child nodes: `Sprite2D`, `CollisionShape2D`, `AnimationPlayer`, and the `StateMachine` node.
    -   Attach a script, `player_character.gd`, to the root node.

-   [ ] **2.3 Implement Basic States:**
    -   Create scripts for core movement states (`Idle`, `Move`, `Jump`, `Fall`) that inherit from the base `State` class.
    -   Implement the physics logic within each state (e.g., applying gravity in `Fall`, applying force in `Move`).

-   [ ] **2.4 Implement `InputManager`:**
    -   Define the abstract input actions (`move_left`, `jump`, etc.) in the Godot Input Map.
    -   Create the `InputManager.gd` singleton to translate raw input into a structured "intent" dictionary.

-   [ ] **2.5 Connect Data, Input, and State Machine:**
    -   In `player_character.gd`, load a `CharacterData` resource from the `DataRegistry` to set properties like `move_speed`.
    -   In `_physics_process`, get the input intent from `InputManager` and pass it to the `StateMachine` to drive state transitions and actions.

---

### **Phase 3: Multiplayer Connectivity & Lobby**

* **Goal:** Enable players to connect over a local network and coordinate in a pre-game lobby.

-   [ ] **3.1 Implement the `NetworkManager` Singleton:**
    -   Create `NetworkManager.gd` as an Autoload singleton.
    -   Implement the `host_game` and `join_game` functions.
    -   Implement the signal handling to re-emit clean, game-focused signals like `player_connected`.

-   [ ] **3.2 Implement the `LobbyManager` Singleton:**
    -   Create `LobbyManager.gd` as an Autoload singleton.
    -   Implement the logic to track player states (name, character choice, ready status) in a dictionary.
    -   Create the necessary RPC functions (`server_select_character`, etc.) to synchronize player choices, ensuring the server is authoritative.

-   [ ] **3.3 Build the UI Screens (`MainMenu` & `Lobby`):**
    -   Create the `MainMenu.tscn` and `Lobby.tscn` scenes.
    -   Implement the `UIManager.gd` singleton to manage showing/hiding screens.
    -   Connect UI button presses to the correct functions in `NetworkManager` and `LobbyManager`.
    -   Make the lobby UI reactive by having it redraw the player list whenever it receives a signal from the `LobbyManager`.

---

### **Phase 4: Core Multiplayer Gameplay Loop**

* **Goal:** Transition from the lobby into a networked game session where players can see and interact with each other.

-   [ ] **4.1 Implement the `GameManager`:**
    -   Create `GameManager.gd`. This will be a node within your map scenes.
    -   Implement the logic to receive the final player data from the `LobbyManager` upon scene transition.
    -   Set up a `MultiplayerSpawner` node.

-   [ ] **4.2 Networked Player Spawning:**
    -   In `GameManager`, create a server-side RPC to handle spawning. This function will instantiate a `player.tscn`, set its `multiplayer_authority`, and add it to the scene via the `MultiplayerSpawner`.

-   [ ] **4.3 Input Broadcasting and State Synchronization:**
    -   Modify `player_character.gd` to distinguish between local and remote control (`is_multiplayer_authority()`).
    -   The authoritative player will send its input *requests* (e.g., "I pressed jump") to the server via RPC.
    -   The server-side character will execute the logic and its updated state (position, velocity, current animation) will be broadcast to all clients using a `MultiplayerSynchronizer` node.

-   [ ] **4.4 Implement `CombatSystem`:**
    -   Create `CombatSystem.gd` as a node within the map scene.
    -   Implement the client-to-server RPC flow for requesting skill usage.
    -   On the server, `CombatSystem` will perform authoritative hit detection and damage calculation.
    -   Use RPCs to broadcast cosmetic results (e.g., hit effects) to all clients. Synchronize health changes via the `MultiplayerSynchronizer`.

-   [ ] **4.5 Implement the Game Mode:**
    -   In `GameManager`, add the logic for the chosen game mode (e.g., Team Deathmatch).
    -   Track scores based on signals from the `CombatSystem` (e.g., `player_eliminated`).
    -   Check for victory conditions and end the match, instructing the `UIManager` to display a scoreboard.
