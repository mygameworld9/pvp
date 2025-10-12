# Module 6: CombatSystem

This document outlines the design for the `CombatSystem`, a dedicated node responsible for the authoritative processing of all combat-related actions, such as skill usage, damage calculation, and hit detection.

---

### **1. Core Philosophy: Server Authority in Combat**

- **Principle:** The server (host) has absolute authority over all combat outcomes. A client can *request* to perform an action (e.g., "I want to use Fireball"), but the server makes the final decision and calculates the result.
- **Reasoning:** This is the most critical component for preventing cheating. Clients cannot decide for themselves if they hit another player or how much damage they deal.

---

### **2. `CombatSystem` (Scene Node)**

- **File Location:** `scripts/systems/combat_system.gd`
- **Location in Scene:** A child node of the `GameManager` in every playable map scene.

#### **2.1 Responsibilities**

- **Action Validation:** Receives action requests from clients and validates them. Can the player perform this action? (e.g., Is the skill off cooldown? Do they have enough mana?).
- **Hit Detection & Calculation:** Performs authoritative hit detection. For an instant attack, this could be a raycast or shape cast. For a projectile, it would involve spawning an authoritative projectile scene.
- **Damage Application:** Once a hit is confirmed, it calculates the damage based on `SkillData` and any other modifiers, and then applies that damage to the target.
- **State Broadcasting:** Emits signals or calls RPCs to inform all clients of the outcome of a combat action (e.g., who was hit, how much damage was taken, who was eliminated).

#### **2.2 High-Level Workflow: Skill Usage**

1.  **Client Request:**
    - The local player's `CharacterBody` receives input to use a skill.
    - It calls an RPC to the server: `@rpc("call_remote") func server_request_skill_use(skill_id: String, aim_direction: Vector2)`.

2.  **Server Validation & Execution:**
    - The `CombatSystem` on the server receives the `server_request_skill_use` RPC.
    - It validates the request (e.g., checks the player's cooldowns).
    - If valid, it performs the action:
      - **For an instant attack (e.g., a sword swing):** It performs a `ShapeCast2D` in the `aim_direction`. If it hits a valid target, it proceeds to damage calculation.
      - **For a projectile (e.g., a fireball):** It instantiates a server-authoritative projectile scene and sets its initial velocity. This projectile will have its own script to handle collision detection on the server.
    - It consumes resources (e.g., starts the skill's cooldown).

3.  **Damage & Effect Application (Server-Side):**
    - When a hit is confirmed, the `CombatSystem` gets the target `CharacterBody`.
    - It calls a function on that character, e.g., `take_damage(amount)`.
    - The `take_damage` function (on the server) reduces the character's health.
    - If health drops to or below zero, the character is marked for elimination. The `CombatSystem` then emits a signal: `player_eliminated(victim_id, attacker_id)`.

4.  **Broadcasting Results:**
    - The server's `CombatSystem` calls a client RPC to create cosmetic effects for all players: `@rpc("call_local") func client_spawn_hit_effect(position)`.
    - The `CharacterBody`'s health variable is synchronized using the `MultiplayerSynchronizer` node, so all clients automatically see the health bar change.

#### **2.3 Interaction with Other Systems**

- **`CharacterBody`:** Receives requests from clients' characters and applies damage to other characters.
- **`GameManager`:** Emits signals like `player_eliminated` to the `GameManager`, which then handles scoring and respawning.
- **`DataRegistry`:** Fetches `SkillData` to determine damage, cooldowns, and other effects.
