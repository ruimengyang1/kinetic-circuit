# Strategic depth redesign — audit and implementation plan

Written on 2026-09-29 **before gameplay edits**. This changes the current
`scenes/final_demo.tscn` demo, not its preserved prototypes or core Can mechanic.
The checkout already contains rebalance and polish changes; preserve them and
all historical evidence. Baseline source, layouts and input-only completion
trace are saved in `artifacts/strategic_depth/baseline/`.

## Audit coverage and evidence

Read `project.godot`, the launch scene and its four procedural level builders;
`demo_player.gd` and its `yard_player` → `action_player` → `player` inheritance;
`demo_can.gd`, `demo_boulder.gd`, `demo_machine.gd`, `demo_platform.gd`, effects,
sound, input setup, camera, exit, pause, death, retry and transition code.
Laser rays, heavy occupancy, airflow clipping, support carrying and moving
platform hazards are in those current scripts. Legacy crushers/enemies are
outside the launch scene and will not be added to it.

Read current README, final-demo design, rebalance plan/report, polish
plan/report, changelog and repository instructions. Inspected current route,
learning, systems, recovery, bounded-attempt, feel, sandbox and capture tests;
the earlier demo tests document obsolete button/layout assumptions.

Played the baseline through **rehearsed normal player inputs**, not actor
teleports: L1 5.78 s, L2 7.58 s, L3 8.27 s, L4 12.02 s. All rooms complete;
sequential L4 takes two hits. All 29 current polish feel fixtures pass.
Inspected fresh rendered layouts for all four rooms. The camera shows the
whole 640×360 room, so composition and state feedback matter more than zoom.

No valid blind GUI playtest is available: CoreGraphics reports both screen
capture and keyboard event posting unauthorized. Engine screenshots and
scripted input work, but neither establishes novice discovery, enjoyment or
human completion time. Do not call known-solution routes blind playtests.

## Current level audit: all eight questions

| Question | L1 — Redirect |
|---|---|
| 1. Mechanic learned | Position selects preview/locked charge; signed force moves shutter/freight/service support; descending Can contact rebounds. |
| 2. Natural heuristic | H1: stand on the side where force is needed, then leave the committed lane. |
| 3. Dominant challenge | Understanding at first, then modest dodge/bounce dexterity. |
| 4. Previous knowledge needed | None; this is the foundation. |
| 5. Earlier heuristic refined | Weak seed: right opening parks Can near freight; left service carries it upward but needs another setup. This is easy to overlook. |
| 6. Does more thought help? | Some: choose an opening and keep the parked Can for height. The force targets otherwise look sequentially positive. |
| 7. Too trivial? | For a known route, yes; two impacts exist, but the short shutter is jumpable and the position choice is poorly expressed. |
| 8. Too execution-heavy? | Generally no. The parked-Can rebound is the main dexterity demand; preserve its generous contact and landings. |

| Question | L2 — Momentum |
|---|---|
| 1. Mechanic learned | Leftward Can force rolls Boulder into a sliding duct; the resulting Boulder position obstructs a running Fan. A second force clears it. |
| 2. Natural heuristic | Move the obstruction to open access, then move it again when airflow fails. |
| 3. Dominant challenge | Understanding the force/duct/nozzle chain, followed by positioning. |
| 4. Previous knowledge needed | H1 directly: aim the same Can left, preserve intent while dodging. |
| 5. Earlier heuristic refined | Opening a panel is not enough if the moving Boulder becomes the next obstruction. |
| 6. Does more thought help? | Yes, but only within a largely forced two-hit sequence. There is no useful state to preserve before the first hit. |
| 7. Too trivial? | After identifying the clogged nozzle, yes: two hits have one obvious useful result. |
| 8. Too execution-heavy? | No; Fan entry and broad upper landings are forgiving. The weakness is decision quality, not jump precision. |

| Question | L3 — Timing |
|---|---|
| 1. Mechanic learned | Heavy occupancy turns Laser continuously; leaving freezes the actual angle. Beam contact moves a crossing. Boulder is a prepared step. |
| 2. Natural heuristic | Wait for alignment, then leave; after correction, start the Can withdrawal before alignment. |
| 3. Dominant challenge | Anticipation/understanding with residual timing. |
| 4. Previous knowledge needed | H1 for Can placement/withdrawal; H2 for the Boulder landing state. |
| 5. Earlier heuristic refined | Correct direction alone is insufficient: windup and pedal clearance delay the result. |
| 6. Does more thought help? | Yes: early bait avoids overshoot; preparing the Boulder avoids a later traversal correction. |
| 7. Too trivial? | Not initially; after understanding it becomes one setup/withdrawal. That is appropriate if the follow-up step remains relevant. |
| 8. Too execution-heavy? | Some residual risk: measured optical traversal is about 1.43 s. A novice already managing placement should have more margin, without removing anticipation. |

| Question | L4 — Combine |
|---|---|
| 1. Mechanic learned | Boulder blocks beam and nozzle; opening airflow exposes danger. Alignment also lifts Can into a new lane, automatically removing rotator weight. |
| 2. Natural heuristic | Clear Boulder first, then solve Laser, then traverse; prepare above danger to reduce damage. |
| 3. Dominant challenge | Understanding simultaneous consequences, plus execution during exposed traversal. |
| 4. Previous knowledge needed | H1 and H2 strongly; H3 is weakened by automatic lift withdrawal. |
| 5. Earlier heuristic refined | Moving cover has a cost, but this arrives too late; the sensor/lift linkage is also a new surprise in the mastery room. |
| 6. Does more thought help? | Yes: prepared route avoids the two sequential-route hits, but still mostly performs the same order. |
| 7. Too trivial? | No on first encounter; order choice and Can availability are nevertheless underused. |
| 8. Too execution-heavy? | Relative to its intended role, yes: a roughly one-second optical window and a newly lifted threat compete with route interpretation. |

## Design commitment: three heuristics, four situations

- **H1 — read intent:** my position controls where Can force appears.
- **H2 — resulting state:** check what the current position provides and what
  the final position will provide before spending it.
- **H3 — plan before the desired state:** windup and travel require an early
  setup; the ideal beam angle is a result, not the cue to start acting.

Keep SEE → TELEGRAPH → LOCK → CHARGE → IMPACT → RECOVER constants and Player
abilities identical in every room. Keep deterministic signed Boulder force,
physical beam blockers, running Fan, continuous occupancy, direct platforms,
full-room camera and cheap current-level retries. Do not add switches, attack
powers, enemies, hazards, precision chains or level-specific Can AI.

### L1: how, with a small position seed

Keep the two existing opening directions and freight follow-up. Make the
shutter tall enough that simply hopping the short obstruction does not read as
the intended first lesson. Retain the service route and broad rebound route.
Rightward opening is simpler and leaves Can near the next force target;
leftward service changes its height/availability and requires a different
setup. The second force receiver uses the same visible bumpers without another
tutorial box. Audit both approaches and one-bait/forward attempts.

### L2: useful obstruction / useful cover

Replace the forced duct-panel two-hit chain in this room with the **existing
laser-blocking relationship**, introduced here rather than late in L4.
Boulder physically covers a stationary low beam and obstructs the running Fan
nozzle. Moving it opens the updraft but spends safe lower-lane cover. A broad
raised staging shelf permits baiting before exposure; both emitter and clipped
beam are visible before movement. No invisible trap and no forced damage.

Reuse Laser ray logic with a stationary emitter presentation (no weight pedal
or fake disabled rotator). This is the same beam/blocking rule already present
in the demo. Preserve the brief cover-removal warning. A reactive first attempt
can be hurt and recover; a prepared second attempt leaves the lower beam lane
before impact and parks Can away from the airflow ascent. Boulder remains
movable, solid traversal geometry, optical cover and airflow obstruction.

### L3: anticipation plus a prepared follow-up

Keep the current Boulder step and occupancy-driven rotor/crossing arrangement.
Keep a slow bounded sweep and broaden the actual optical collector enough to
support a range of early starts. Do not snap alignment or latch completion.
Test that waiting for the center before starting produces a worse stopped
state, while many earlier starts retain the crossing. Final Can position stays
relevant because only one heavy actor is available; the prepared Boulder is
the one secondary consequence. The full-room view contains all three states.

### L4: order, cover, Can availability

Keep the existing Fan/Boulder/rotator/crossing composition. Remove the automatic
sensor-driven Can lift: mastery should use H3, not introduce a new linkage that
solves withdrawal itself. Restore continuous ground beneath its old support.
Use the same broad collection tolerance as L3, a readable slow sweep and roomy
high observation / lower bait shelves.

Two legitimate plans must work through normal inputs:

1. **Reactive/sequential:** move Boulder, inspect the exposed beam, return Can
   to rotor, align/freeze, use airflow/crossing. Useful but spends cover early
   and Can must travel back before controlling Laser.
2. **Prepared/combined:** retain cover, use the initial left charge to park Can
   near the left boundary, direct its next charge to end on rotor before it
   reaches Boulder, observe from outside its sight lane, then bait right early.
   That withdrawal freezes the beam, hits Boulder, clears the nozzle and leaves
   Can beyond the traversal setup in **one continuing commitment**.

The second plan must differ in **order, preserved state and combined effects**,
not require a precision rebound. A novice can inspect/correct after every
interaction; an expert saves return travel and unnecessary charges. If measured
geometry prevents this, revise geometry rather than adding a special Can rule.

## Pacing and acceptance

First-encounter targets: L1 45–60 s, L2 60–75 s, L3 70–90 s, L4 90–120 s.
Those ranges total **265–345 s**; aim toward their lower-middle for roughly
4–5 minutes. They are hypotheses to test, not measured facts. Do not enforce
them with locks, corridors, repeated chores or waiting. Route feasibility times
will remain much shorter than novice discovery times.

Before accepting implementation: input-only complete all four rooms, both L1
approaches and both L4 orders; record charges, signed impacts, actor endpoints,
cover/exposure, actual rotor stop, hits and retries. Use controlled fixtures for
beam-cover safety, late/early withdrawal margins, determinism and support.
Audit shallow forward/jump/one-bait routes, pause/restart, unchanged Can/Player
feel, and inspect rendered consequential states. Preserve baseline/historical
evidence and clearly label scripts as rehearsed or controlled.

Produce `STRATEGIC_DEPTH_REPORT.md` with per-level knowledge/refinement/choices,
characteristics, system relationships, concrete novice/expert differences,
measured evidence and all twelve acceptance gates. Gate 9 (human second run),
gate 11 (first-run duration), and subjective fun remain pending without a valid
blind tester. Do not declare the whole redesign accepted on automation alone.
