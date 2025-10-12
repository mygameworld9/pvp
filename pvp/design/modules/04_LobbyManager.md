# Module 4: LobbyManager

This document describes the `LobbyManager`, a global singleton that manages all game logic *before* a match begins. It is the central hub for players to coordinate before transitioning to the game scene.

---

### **1. Core Responsibilities**

The `LobbyManager` is responsible for the "pre-game" state. Its authority is the server/host.

- **Player State Management:** Tracks all connected players, their chosen names, selected characters, and ready status.
- **Choice Synchronization:** Ensures that when one player makes a choice (e.g., selects a character), that choice is broadcast and visible to all other players in the lobby.
- **Game Start Coordination:** Determines when the game can start (e.g., all players are "Ready") and orchestrates the transition to the game scene for all connected peers.
- **Data Forwarding:** Gathers all the necessary lobby data (who is playing, what character they chose, what map was selected) and provides it to the `GameManager` upon starting the match.

---

### **2. `LobbyManager` (Global Singleton)**

- **File Location:** `scripts/globals/lobby_manager.gd`
- **Registered as:** Autoload singleton named `LobbyManager`.

#### **2.1 Data Structures**

The `LobbyManager` will maintain a dictionary to track the state of all players.

```gdscript
# Player ID (int) -> Player Info (Dictionary)
var players = {
    1: { "name": "HostPlayer", "character_id": "warrior", "is_ready": false },
    24821: { "name": "ClientPlayer", "character_id": "mage", "is_ready": true }
}
```

#### **2.2 Key Functions & RPCs**

- `func reset_and_activate()`: Called when the player enters the lobby screen. Clears any old data and starts listening to signals from the `NetworkManager`.

- `func set_player_name(name: String)`: A locally called function that sends the player's chosen name to the server.
  - `@rpc("call_remote") func server_set_player_name(name: String)`: The server receives the name, updates its `players` dictionary, and then broadcasts the change to all clients.
  - `@rpc("call_local") func client_update_player_list(new_players_data)`: All clients (including the host) receive the updated player list and refresh their UI.

- `func select_character(character_id: String)`: Similar flow to setting the name.
  - `@rpc func server_select_character(character_id: String)`
  - `@rpc func client_update_player_list(new_players_data)`

- `func set_ready_status(is_ready: bool)`: Similar flow.
  - `@rpc func server_set_ready_status(is_ready: bool)`
  - `@rpc func client_update_player_list(new_players_data)`

- `func start_game()`: **(Host Only)** Checks if all players are ready. If so, it calls an RPC on all clients to load the selected map scene.
  - `@rpc func client_load_game_scene(map_id: String)`: All clients are instructed to load the game. The `LobbyManager` also passes its `players` data to the `GameManager` at this point.

#### **2.3 Interaction with Other Systems**

- **`NetworkManager`:** `LobbyManager` listens to `player_connected` and `player_disconnected` signals to add/remove players from its internal `players` dictionary. This is the entry point for managing player states.
- **`UIManager`:** The UI calls functions on `LobbyManager` (e.g., `select_character`) when the player clicks buttons. It also listens to signals from `LobbyManager` (e.g., `player_list_changed`) to know when to redraw the lobby screen.
- **`GameManager`:** When the game starts, `LobbyManager` passes the final, confirmed player and map data to the `GameManager` so it knows what to spawn.
