# AGENTS.md — Clockwork Tower: Kinetic Circuit Design Constitution

This file is binding for any Codex/AI-assisted change to this project.

Before changing gameplay, level design, UI, balance, presentation, or progression, read this file completely.
If a requested change conflicts with these principles, do not silently implement it. Explain the conflict and propose the smallest alternative that preserves the design thesis.

---

## 1. Core Design Thesis

**Clockwork Tower: Kinetic Circuit is a game about reading and rerouting a system.**

The player is not primarily fighting through a platforming obstacle course.
The player is learning how enemies, hazards, projectiles, machines, and changed states interact, then using that understanding to create a better future state.

The key player question should increasingly become:

> **“What state do I want the room to be in next?”**

A skilled player should improve mainly through **understanding**, not only through faster reactions or more precise execution.

---

## 2. Strategic Depth Is the Main Goal

Every meaningful addition should support strategic depth.

The game should teach reusable heuristics such as:

- **Read intent before acting.**
- **A threat may be a resource.**
- **Think about the resulting state, not only the immediate result.**
- **Preserve options when they may be useful later.**

These are heuristics, not fixed answers.

Do **not** turn them into universal recipes such as:

- “Always bait the Guard into the saw.”
- “Always keep enemies alive.”
- “Always reflect every projectile.”
- “Always activate the nearest socket first.”

A later situation should complicate or qualify what an earlier situation taught.

If experienced play is only “perform the same action faster,” the design is not deep enough.

---

## 3. Systemic Design Principle

The most important systemic rule is:

> **THE RESULT OF ONE INTERACTION SHOULD BE ABLE TO BECOME THE INPUT TO ANOTHER.**

Prefer chains such as:

`enemy intent -> positioning -> machine interaction -> changed actor state -> new traversal/decision`

or:

`projectile -> reflection -> machine state -> changed geometry -> new opportunity`

Avoid dead-end interactions such as:

`enemy hits hazard -> stunned -> nothing else changes`

unless the stun itself is already the meaningful consequence.

When adding or modifying a state, ask:

> **“What other existing system can read or use this state?”**

Prefer connecting existing rules over adding new mechanics.

---

## 4. I Wanna Influence: Break Expectations, Not Trust

The useful influence from *I Wanna Be the Guy* is **expectation reversal**, not arbitrary punishment.

A first-time player may assume:

- enemy = kill or avoid
- projectile = dodge
- saw = avoid
- charge attack = escape from
- stunned enemy = temporarily harmless

The game may reveal that this interpretation is incomplete.

But after revealing the deeper rule, the world must remain consistent.

**Break the expectation once. Keep the underlying rule reliable afterward.**

Do not add surprise deaths, invisible traps, or one-off exceptions that only reward memorization.

Failure should reveal useful information.

---

## 5. Small Number of Rules, Many Combinations

Do not equate “more mechanics” with “more depth.”

Prefer:

> **3–5 strong systems with many meaningful combinations**

over:

> **10 mechanics with one scripted use each**

The current design should remain focused around a small set such as:

- player impact / rebound
- committed Guard behavior
- Shooter + reflectable projectile
- saw / hazard state change
- shared force-receiving sockets
- visible Core / machine state

Do not reintroduce old mechanics merely because their code already exists.

A mechanic must earn its place by changing decisions.

---

## 6. Reuse Code, Not the Old Game

The project should reuse stable implementation wherever possible.

Good things to reuse internally:

- movement physics
- acceleration
- jump buffering
- coyote time
- attack timing
- pogo / rebound calculations
- enemy state-machine infrastructure
- projectile movement
- reflection logic
- stun timers
- hazard collision
- checkpoints and reset logic
- effects helpers
- audio helpers
- test infrastructure

However, **player-facing design should not be preserved just because the code is convenient**.

Do not casually restore:

- old level geometry
- old encounter order
- old long precision-platforming sections
- old powerup progression
- old boss structure
- old HUD
- old tutorial overlay
- old timer / slow-motion presentation
- old ending
- old “fight enemies until the route clears” rhythm

The goal is:

> **HIGH CODE REUSE + LOW PLAYER-FACING DESIGN REUSE**

Someone who played the previous prototype should perceive this as a different game.

---

## 7. Reused Mechanics Must Have New Roles

Reusing an actor is not enough. Its **gameplay role** should support the new design.

Examples:

### Guard
Old role:
combat obstacle.

Desired role:
a readable, committed horizontal force source whose position/state can matter later.

### Shooter
Old role:
ranged enemy to remove.

Desired role:
a renewable projectile source. Removing it may reduce danger but also reduce options.

### Saw
Old role:
pure movement hazard.

Desired role:
a hazard that can also transform another actor's state.

### Socket / receiver
Not just a “button.”

It should make a systemic relationship visible: some source of force/state changes machinery.

### Core
Not a boss health bar.

It is the shared system objective and spatial landmark that reflects accumulated machine state.

Do not change internal class names unless necessary. Player-facing role matters more than filename names.

---

## 8. Level Design: Read, Predict, Act

The level should reward:

> **SEE -> THINK -> ACT**

not:

> **RUN -> REACT -> RETRY**

Avoid making difficulty come primarily from:

- pixel-perfect jumps
- frame-perfect reflects
- enemies that are simply faster
- dense hazard spam
- long execution gauntlets
- memorized trap order

Give the player enough time and visual information to reason.

A player who pauses for two seconds and reads the room should often do better than a player who immediately rushes forward.

---

## 9. Level Structure Must Support Learning

The active game should remain one focused continuous prototype.

The current learning arc should preserve these functions:

### Space 1 — System Language
Teach one safe relationship:
`player impact -> machine changes`

The player learns that the tower is an interactive system.

### Space 2 — Expectation Break
Introduce a threat whose behavior can also be useful.

The player learns:
`threat != only obstacle`

### Space 3 — Future State / Preserve Options
Create a real tradeoff.

For example:
removing a Shooter makes the room safer but removes a renewable projectile source.

The player learns:
`immediate safety may reduce future options`

### Space 4 — Systemic Core
Do not introduce a new major mechanic.

Combine already learned rules so the player must choose:
- what to preserve
- what to trigger
- in what order
- from where
- which resulting state is useful

Prefer multiple viable approaches that emerge from shared rules.

Do not hard-code “Solution A” and “Solution B” when the same rules can naturally produce both.

---

## 10. Avoid Linear “Socket Puzzle” Design

A major failure mode is turning the game into:

`activate socket 1 -> activate socket 2 -> activate socket 3 -> exit`

That is not enough.

Sockets should not merely be locks with different keys.

The important design question is:

> **Does choosing how, when, or with what source to change a machine state affect later possibilities?**

If every room has one obvious source and one matching receiver, redesign it.

---

## 11. Preserve Options Without Creating Softlocks

Strategic mistakes should matter, but they should usually remain understandable and recoverable.

If the player removes or misuses an important source, prefer:

- a slower alternative
- a repeatable source
- a local recovery loop
- a local reset
- a quick understandable retry

Do not create accidental permanent softlocks.

“Preserve options” should be a smart heuristic, not a hidden requirement for avoiding an unwinnable state.

---

## 12. UI Principle: World State First, HUD Second

The UI must support system reading.

Important state should be communicated in the world whenever possible.

Prefer:

- dark -> illuminated conductor
- unpowered -> powered socket
- idle -> committed enemy windup
- hostile -> reflected projectile
- active -> stunned/repositioned actor
- inactive -> synchronized Core
- closed -> visibly moving/open route

Use:

- animation
- motion
- state color
- light
- shape
- sound
- impact feedback

before explanatory text.

The HUD should only show information that cannot be communicated cleanly in-world.

---

## 13. Do Not Restore the Old UI Identity

Do not casually restore the previous game's recognizable interface:

- old three-heart arrangement
- old permanent timer
- old slow-motion meter
- old permanent control line
- old boss health bar
- old powerup messaging
- old victory screen

Underlying variables may remain if needed.

Player-facing presentation should serve the new game.

The interface should feel like restrained mechanical instrumentation, not a traditional action-platformer HUD.

---

## 14. Visual Language Must Communicate Function

Visual changes should not be cosmetic-only.

Use a consistent functional language for states such as:

- neutral machinery
- active hostile intent
- usable/routable energy
- reflected projectile
- powered/resolved machine
- stunned/changed actor
- synchronized Core

Do not add random colors just to make the game look different.

Color, motion, and effects should communicate state.

---

## 15. The Core Is the Objective, Not a Boss Fight

The final encounter should not collapse into:

> “reduce Titan/boss HP to zero.”

The final challenge should be about understanding and configuring the system.

The Core should visibly respond to meaningful machine state.

Completion should feel like:

`systems align -> Core synchronizes -> route resolves -> exit opens`

not:

`boss dies -> generic victory`

---

## 16. Scope Discipline

Do not add, unless absolutely necessary:

- new enemy types
- inventory
- procedural generation
- skill trees
- large dialogue/tutorial systems
- multiple levels
- complex physics simulation
- a new player controller
- many new resources/meters
- large generic frameworks

Before adding a mechanic, ask:

> **“Can the same strategic effect be achieved by connecting two existing systems?”**

If yes, do that instead.

---

## 17. UI, Art, and Level Changes May Be Large; Core-Code Rewrites Should Be Small

It is acceptable to substantially change:

- level geometry
- chamber layout
- camera flow
- object placement
- encounter composition
- HUD layout
- title screen
- visual hierarchy
- state feedback
- objective presentation
- ending presentation

because these define the player's experience.

It is **not** acceptable to rewrite stable movement/combat/state systems merely to make the codebase look new.

---

## 18. Required Change Process for Codex

For any non-trivial gameplay, level, or UI change:

### Before editing
1. Read this file.
2. Inspect the affected code and scene.
3. Check `git status --short`.
4. Identify which existing system can be reused.
5. State the player-facing purpose of the change.
6. Ask:
   - Does this deepen a decision?
   - Does it improve readability?
   - Does it preserve the new game's identity?
   - Can it be done with less new logic?

### During implementation
1. Make the smallest systemic code change.
2. Prefer recomposition over new mechanics.
3. Test after each meaningful change.
4. Preserve unrelated teammate work.
5. Do not reset, revert, delete, or overwrite unrelated changes.

### After implementation
Report:
1. what changed
2. why it supports the design thesis
3. what old code was reused
4. whether it adds a new rule or only connects existing rules
5. how novice and experienced behavior should differ
6. recovery / softlock risks
7. tests run and results
8. remaining human-playtest questions

Do not commit or push unless explicitly requested.

---

## 19. Mandatory Design Check for Every New Encounter

For each encounter, Codex should be able to answer:

**NEW PLAYER**
What will a first-time player probably think or do?

**INFORMATION**
What can the player see/hear that lets them reason?

**HEURISTIC**
What useful rule-of-thumb can they learn?

**EXPERIENCED PLAYER**
What does a player who understands the system do differently?

**COMPLICATION**
Why is the heuristic not an automatic answer?

**RESULTING STATE**
How does this interaction change the next decision?

If these answers are weak, do not compensate by adding more enemies or hazards. Redesign the relationship.

---

## 20. “Different Game” Check

Before finishing any substantial redesign, compare it with the previous prototype.

Ask whether an old player would recognize:

- the same opening
- the same HUD
- the same level silhouette
- the same route
- the same encounter order
- the same enemy purposes
- the same hazard purposes
- the same objective
- the same rhythm
- the same final challenge
- the same ending
- the same mental model

Some code reuse is expected.

But if several **player-facing** answers are still “yes,” change composition, presentation, or role before adding more mechanics.

---

## 21. Repository Safety

- Preserve teammate work.
- Do not delete or revert unrelated changes.
- Do not overwrite an existing scene merely because a redesign is easier from scratch.
- Keep old/reference prototypes isolated when useful.
- Verify the active Godot project and main scene before editing.
- Do not silently switch implementation bases.
- Keep `CHANGELOG.md` current for gameplay, level, control, balance, content, presentation, audio, UI, and player-visible bug-fix changes.
- Preserve existing changelog history; record reversals as new entries instead of rewriting history.

---

## 22. Final Decision Rule

When uncertain between two implementations, prefer the one that:

1. uses fewer new rules,
2. creates more interactions between existing rules,
3. makes cause and effect more readable,
4. gives the player a meaningful future-state decision,
5. keeps failure informative and recoverable,
6. strengthens the new game's identity,
7. requires less fragile code.

The design is successful when the player stops asking:

> **“How do I beat this enemy?”**

and starts asking:

> **“How can I use this situation to change what happens next?”**
