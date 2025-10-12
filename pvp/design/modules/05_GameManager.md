# Module 5: GameManager

This document details the `GameManager`, a scene-specific node responsible for managing the lifecycle and rules of a single game match.

---

### **1. Core Philosophy: The Match Director**

- **Principle:** The `GameManager` is the authoritative controller for a single game session, from the moment players load into the map until a winner is decided. It exists only within the game scene itself, not as a global singleton.
- **Scope:** Its responsibilities are strictly related to the "in-game" loop. It does not handle networking connections or pre-game lobbies.

---

### **2. `GameManager` (Scene Node)**

- **File Location:** `scripts/systems/game_manager.gd`
- **Location in Scene:** A top-level node in every playable map scene (e.g., `level_one.tscn`).

#### **2.1 Responsibilities**

- **Match Initialization:**
  - Receives the final player data from `LobbyManager` when the scene is loaded.
  - Based on the provided `MapData`, it identifies the correct player spawn points.
  - For each player in the data, it instantiates and spawns their chosen `CharacterBody` scene at a designated spawn point. The `MultiplayerSpawner` node is used for this to ensure correct network replication.

- **Game State Management:**
  - Starts the match (e.g., begins a countdown).
  - Tracks game-critical state like score, remaining time, and player respawns.
  - Enforces the rules of the current game mode (e.g., Team Deathmatch, Free-for-All).

- **Victory/Defeat Conditions:**
  - Continuously checks if the conditions for ending the match have been met (e.g., a player reaches the target score, or the timer runs out).
  - Once the match is over, it orchestrates the end-of-game sequence (e.g., displaying a "Victory" screen, showing the scoreboard).

- **System Coordination:**
  - Acts as a central hub for other in-game systems. For example, when the `CombatSystem` reports a player has been eliminated, the `GameManager` is responsible for initiating that player's respawn timer and logic.

#### **2.2 High-Level Workflow**

1.  **`_ready()`:**
    - The `GameManager` is initialized. It immediately retrieves the player and map configuration that was passed from the `LobbyManager` during the scene transition.
    - It iterates through the list of players. For each player:
      - It retrieves the correct `CharacterData` using `DataRegistry.get_character_data()`.
      - It finds an available spawn point from the `MapData`.
      - It calls an RPC, `server_spawn_player`, to the host.

2.  **`server_spawn_player(player_id, character_id, spawn_position)` (Host Only RPC):**
    - The host instantiates the character scene corresponding to `character_id`.
    - It sets the character's initial properties (e.g., position, owner ID).
    - It adds the character to the scene tree using the `MultiplayerSpawner`. The spawner automatically handles replicating the character instance across all clients.

3.  **`_process(delta)`:**
    - The host's `GameManager` updates the match timer.
    - It checks for win conditions.
    - If a win condition is met, it calls a client RPC `client_end_game(winner_info)` to notify all players and trigger the display of the results screen via the `UIManager`.

#### **2.3 Interaction with Other Systems**

- **`LobbyManager`:** Receives the initial setup data from it. This is a one-way handoff.
- **`DataRegistry`:** Uses it to get `CharacterData` and `MapData` resources.
- **`CharacterBody`:** Spawns and destroys these instances.
- **`CombatSystem`:** Listens for signals like `player_eliminated(victim_id, killer_id)` to update the score and manage respawns.
- **`UIManager`:** Instructs it to display and update the in-game HUD (score, timer) and to show the final scoreboard.
