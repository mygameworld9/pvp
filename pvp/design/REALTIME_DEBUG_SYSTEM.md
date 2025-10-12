## Real-time Control and Logging System: Implementation Roadmap

This document outlines the step-by-step plan for creating a robust, interactive, real-time debugging and logging system for the project. This system is inspired by professional game development tools and is essential for efficient development and debugging in a networked environment.

---

### **1. Overview & Design Philosophy**

The goal is to build a centralized logging system that can be controlled in real-time from an in-game console.

-   **Centralized:** All log messages from any module are routed through a single `Logger` singleton. This ensures consistency in formatting and control.
-   **Informative:** Log messages will be structured to include a timestamp, severity level, and source module, allowing for easy tracing of the application's execution flow.
-   **Interactive:** Developers can change the verbosity of logs, filter by specific game systems, and execute debug commands in real-time via an in-game console.
-   **Performant:** The logging system will be designed so that logging calls can be compiled out or disabled in release/production builds to avoid any performance impact.

---

### **2. Core Components**

1.  **`Logger` Singleton (`Logger.gd`):** A global (Autoload) script that serves as the central API for all logging. It will manage log levels, format messages, and route them to various outputs (e.g., console, file, in-game UI).
2.  **`DebugConsole` UI (`DebugConsole.tscn`):** A Quake-style dropdown console that can be toggled with a hotkey. It will display real-time logs and provide a command-line interface for interacting with the debug system.
3.  **Command System:** A simple, extensible system within the `DebugConsole` for registering and executing text-based commands (e.g., changing log levels).

---

### **3. Step-by-Step Implementation Plan**

This plan is broken down into four distinct phases, starting with the foundation and progressively adding features and integration.

#### **Phase 1: Foundational `Logger` Singleton**

*The goal of this phase is to create the core logging backend.*

-   [ ] **Task 1.1:** Create a new script `Logger.gd` and configure it as a global Autoload singleton named `Logger`.
-   [ ] **Task 1.2:** Implement the core logging methods: `info(source, message)`, `debug(source, message)`, `warn(source, message)`, and `error(source, message)`. The `source` parameter will be a `String` identifying the module (e.g., "CombatSystem").
-   [ ] **Task 1.3:** Implement log level filtering. The `Logger` will have a `current_log_level` variable (e.g., `DEBUG`, `INFO`, `WARNING`, `ERROR`), and it will only process logs at or above that severity.
-   [ ] **Task 1.4:** Implement standard message formatting. All logs printed to the Godot console should follow the format: `[LEVEL] [Source]: Message`.
-   [ ] **Task 1.5:** Define a signal `new_log_message(formatted_string)` in the `Logger`. This signal will be emitted for every log message that passes the level filter, allowing other systems (like the UI) to subscribe to it.

#### **Phase 2: In-Game Debug Console UI**

*The goal of this phase is to create the user-facing interface for viewing logs.*

-   [ ] **Task 2.1:** Create a new UI scene `DebugConsole.tscn`. It should contain a `RichTextLabel` for displaying log output and a `LineEdit` for user input. The scene should be hidden by default.
-   [ ] **Task 2.2:** Add logic to a global script to toggle the visibility of the `DebugConsole` when a hotkey (e.g., the backtick `~` key) is pressed.
-   [ ] **Task 2.3:** In the `DebugConsole.gd` script, connect to the `Logger.new_log_message` signal. When the signal is received, append the formatted message to the `RichTextLabel`.
-   [ ] **Task 2.4:** Implement auto-scrolling in the `RichTextLabel` to ensure the most recent log message is always visible.

#### **Phase 3: Real-time Control via Console Commands**

*The goal of this phase is to make the debug system interactive.*

-   [ ] **Task 3.1:** Implement a basic command registry (e.g., a `Dictionary` mapping command strings to `Callable` functions) in the `DebugConsole.gd` script.
-   [ ] **Task 3.2:** Create the command `set_log_level <level>`. This command will call a public function on the `Logger` singleton to change its `current_log_level` in real-time.
-   [ ] **Task 3.3:** Create the command `set_log_filter <source_string>`. This will set a filter property in the `Logger` to only process logs where the `source` parameter matches the provided string. An empty string will disable the filter.
-   [ ] **Task 3.4:** Create a `help` command that prints a list of all available commands and their descriptions to the console.

#### **Phase 4: System-Wide Integration**

*The goal of this phase is to embed logging throughout the entire codebase.*

-   [ ] **Task 4.1:** Integrate logging into `NetworkManager`. Log host/join events and player connect/disconnect signals using `Logger.info("NetworkManager", "...")`.
-   [ ] **Task 4.2:** Integrate logging into `LobbyManager`. Log important RPC calls (character selection, ready status) and player state changes using `Logger.debug(...)`.
-   [ ] **Task 4.3:** Integrate logging into `GameManager`. Log critical match state transitions (e.g., "Initializing Match", "Spawning Players", "Match Over") and the outcomes of win condition checks.
-   [ ] **Task 4.4:** Integrate logging into `CombatSystem`. This is a high-priority integration. Log skill use requests, validation results (e.g., "Skill on cooldown"), hit detection results, and final damage calculations.
-   [ ] **Task 4.5:** Integrate logging into the `StateMachine` base class. The `change_state()` method should automatically log every state transition, providing a clear trace of character behavior (e.g., `Logger.debug("StateMachine:{owner_name}", "State -> {new_state}")`).
