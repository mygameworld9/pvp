# Module 8: UIManager

This document outlines the design of the `UIManager`, a global singleton that manages the game's entire user interface, acting as a bridge between the player's interactions with UI elements and the game's backend systems.

---

### **1. Core Philosophy: A Reactive View Layer**

- **Principle:** The UI should be a "dumb" view layer. It displays information given to it by other systems and reports user interactions (like button clicks) back to those systems. It should contain minimal game logic itself.
- **Implementation:** The `UIManager` will manage a collection of UI "screens" or "scenes" (e.g., Main Menu, Lobby, HUD). It will be responsible for showing, hiding, and updating these screens in response to signals from the game's logic controllers (`LobbyManager`, `GameManager`, etc.).

---

### **2. `UIManager` (Global Singleton)**

- **File Location:** `scripts/globals/ui_manager.gd`
- **Registered as:** Autoload singleton named `UIManager`.

#### **2.1 Responsibilities**

- **Screen Management:** Handles the lifecycle of all major UI screens, ensuring only the relevant screen is visible at any given time (e.g., hiding the Main Menu when the Lobby is shown).
- **Data Display:** Receives data from game systems and passes it to the active UI screen for display. For example, it takes the player list from `LobbyManager` and tells the Lobby UI to update itself.
- **Event Forwarding:** Listens for UI events (e.g., a button's `pressed` signal) and translates them into calls on the appropriate game system. For example, when the "Ready" button is clicked in the lobby, the `UIManager` calls `LobbyManager.set_ready_status(true)`.

---

### **3. UI Screens (Individual Scenes)**

Each major UI component will be its own `.tscn` scene.

- **`MainMenu.tscn`:**
  - **Elements:** "Host Game" button, "Join Game" button, IP address input field, "Quit" button.
  - **Interactions:**
    - "Host Game" click -> `UIManager` calls `NetworkManager.host_game()` and then `LobbyManager.reset_and_activate()`, finally transitions to the Lobby screen.
    - "Join Game" click -> `UIManager` calls `NetworkManager.join_game(ip_address)`.

- **`Lobby.tscn`:**
  - **Elements:** List of connected players, character selection buttons, map selection UI (host only), "Ready" button, "Start Game" button (host only).
  - **Interactions:**
    - `LobbyManager`'s `player_list_changed` signal -> `UIManager` tells `Lobby.tscn` to redraw the player list.
    - "Ready" button click -> `UIManager` calls `LobbyManager.set_ready_status()`.
    - "Start Game" click -> `UIManager` calls `LobbyManager.start_game()`.

- **`GameHUD.tscn`:**
  - **Elements:** Timer display, score display, player health bar, skill cooldown indicators.
  - **Interactions:**
    - `GameManager`'s `score_updated` signal -> `UIManager` tells `GameHUD.tscn` to update the score text.
    - The local player's `health_changed` signal -> `UIManager` updates the health bar.

- **`Scoreboard.tscn`:**
  - **Elements:** Final scores, "Return to Main Menu" button.
  - **Interactions:**
    - Shown by the `UIManager` when it receives the `game_over` signal from `GameManager`.

#### **3.1 High-Level Workflow: Hosting a Game**

1.  Player clicks the "Host Game" button in `MainMenu.tscn`.
2.  The button's `pressed` signal is connected to a function in the `UIManager`.
3.  The `UIManager` function does the following:
    a. Calls `NetworkManager.host_game()`.
    b. Calls `LobbyManager.reset_and_activate()`.
    c. Calls its own internal `_change_screen(LobbyScreen)` method.
4.  The `_change_screen` method hides the `MainMenu` scene and shows the `Lobby` scene.
5.  Now in the lobby, when a new player connects, `NetworkManager` emits `player_connected`. `LobbyManager` catches this, updates its internal player list, and emits `player_list_changed`.
6.  `UIManager` is listening for `player_list_changed` and tells the `Lobby` scene to refresh its display of the player list.
