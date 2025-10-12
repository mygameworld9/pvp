# Module 3: NetworkManager

This document outlines the design of the `NetworkManager`, a global singleton responsible exclusively for low-level network session management.

---

### **1. Core Philosophy: Decoupled Network Layer**

- **Principle:** The `NetworkManager` should not have any knowledge of game-specific logic like players, characters, or scores. Its sole responsibility is to establish, maintain, and terminate network connections.
- **Communication:** It communicates with higher-level systems (`LobbyManager`, `GameManager`) via signals. This keeps the game logic separate from the networking backend, making the code easier to maintain and allowing for future changes (like a dedicated server) with minimal refactoring.

---

### **2. `NetworkManager` (Global Singleton)**

- **File Location:** `scripts/globals/network_manager.gd`
- **Registered as:** Autoload singleton named `NetworkManager`.

#### **2.1 Responsibilities**

- Creating a network session (acting as a listen server/host).
- Joining an existing network session (acting as a client).
- Disconnecting from a session.
- Broadcasting signals about network events so other systems can react.

#### **2.2 Public API**

- `func host_game(port: int = DEFAULT_PORT):`
  - Creates an `ENetMultiplayerPeer`.
  - Calls `create_server()` on the peer.
  - Assigns the peer to `multiplayer.multiplayer_peer`.
  - Connects to the `multiplayer` object's built-in signals (`peer_connected`, `peer_disconnected`).

- `func join_game(ip_address: String, port: int = DEFAULT_PORT):`
  - Creates an `ENetMultiplayerPeer`.
  - Calls `create_client()` on the peer with the provided address and port.
  - Assigns the peer to `multiplayer.multiplayer_peer`.

- `func disconnect_from_game():`
  - Sets `multiplayer.multiplayer_peer` to `null`, gracefully closing the connection.

#### **2.3 Signals**

The `NetworkManager` will listen to Godot's built-in multiplayer signals and re-emit them with relevant information for other game systems.

- `signal server_created`: Emitted when `host_game()` is successfully called.
- `signal connected_to_server`: Emitted when `join_game()` successfully connects to a host.
- `signal connection_failed`: Emitted if the client fails to connect.
- `signal player_connected(player_id: int)`: Emitted on both server and clients when a new player joins the session. `player_id` is the unique network ID assigned by Godot.
- `signal player_disconnected(player_id: int)`: Emitted on both server and clients when a player leaves the session.
- `signal disconnected_from_server`: Emitted on the client when its connection to the server is lost.

#### **2.4 Pseudocode Implementation**

```gdscript
# scripts/globals/network_manager.gd
extends Node

const DEFAULT_PORT = 7777

signal server_created
signal connected_to_server
signal connection_failed
signal player_connected(player_id)
signal player_disconnected(player_id)
signal disconnected_from_server

func _ready():
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_disconnected_from_server)

func host_game():
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(DEFAULT_PORT)
    if error != OK:
        print("Failed to create server!")
        return
    multiplayer.multiplayer_peer = peer
    server_created.emit()
    # The host is also a "player", so we emit for player_id = 1
    player_connected.emit(1)

func join_game(ip_address: String):
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(ip_address, DEFAULT_PORT)
    multiplayer.multiplayer_peer = peer

# --- Signal Handlers ---

func _on_player_connected(id):
    player_connected.emit(id)

func _on_player_disconnected(id):
    player_disconnected.emit(id)

func _on_connected_to_server():
    connected_to_server.emit()

func _on_connection_failed():
    connection_failed.emit()

func _on_disconnected_from_server():
    disconnected_from_server.emit()
```
