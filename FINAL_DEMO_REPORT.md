# Final demo report — Learn the Can

Reviewed and verified on 2026-09-29 with Godot 4.7.2.

The default scene is `scenes/final_demo.tscn`: four compact levels, one stable
Can routine, and the same player abilities throughout. Both recorded approaches
complete all four levels using only player inputs after spawn. The sequential
approach takes one hit in Combine; the expert approach takes no hits and uses
two rebounds that preserve a committed charge. The first-time 4–5 minute goal,
learning clarity, and enjoyment still require human playtesting.

The preimplementation commitments and later layout adjustments are in
[FINAL_DEMO_DESIGN.md](FINAL_DEMO_DESIGN.md). Existing prototype scenes,
scripts, reports, and evidence remain in the repository. The main demo replaces
their launch role with Redirect → Weight → Timing → Combine.

## Shared rules and feedback

Can previews direction for 0.20 seconds, locks it for the remaining 0.35 seconds,
then charges straight at 230 px/s for at most 1.15 seconds. Lock has a distinct
arrow, overhead mark, lane cue, and sound. Moving to the other side after lock
cannot redirect that charge. Search and attack acquisition require the worker
to be within 52 pixels vertically; perching above that lane preserves useful
Can placement. Recovery lasts 0.20 seconds. Ordinary stomps stagger for
0.38 seconds; descending contact during a charge rebounds the worker without
stopping Can. Moving solid platforms can carry Can using ordinary floor support.

The worker retains 155 px/s movement, coyote time, jump buffering, variable
ordinary jump height, and strong air control. A Can rebound is anchored to its
top surface and launches at 305 px/s. Neither level progression nor success
unlocks another ability.

Boulder accepts signed charge force, rolls with deterministic friction, supplies
mass while supported, and blocks laser rays as a solid body. Broad buttons
continuously inspect overlapping weight. Weight leaving removes power; the
circuits do not latch a solved state. Fan airflow acts immediately while powered,
with animated blades, wind strokes, upward arrows, and a hum.

The rotator turns at 28°/s while supported weight overlaps its pedal. Removing
weight freezes its actual angle. The dial includes a lead mark to expose the
delay between baiting Can and clearing the pedal. The beam clips at physical
geometry, Boulder, the worker, or the sensor. Actual sensor contact powers its
linked platforms; losing contact returns them. Platforms share the same powered
path component, draw their destinations, and announce startup and arrival.

Impact dust, rolling dust, brief hit pause, camera shake, rebound feedback,
button clunks, and a sensor pulse distinguish the changes. The 640×360 view
keeps each whole level visible; the HUD shows level name and health. Controls
appear briefly and can be recalled with H.

## Maps and knowledge transfer

| Level | Physical arrangement and route | Knowledge carried forward |
|---|---|---|
| Redirect | A worker-sized gap permits baiting from beyond a shutter that blocks Can. Its charge retracts the shutter. A second charge raises the freight platform toward the high exit. | Position chooses intent; the committed force changes access. |
| Weight | Boulder sits ahead of Can. A rightward impact rolls it onto a broad button. That weight sustains the Fan needed to reach the upper landing and exit. The same circuit moves a hanging sweep across the airflow. | The force rule transfers from a shutter to a rolling object; its ending position determines sustained power. |
| Timing | Bait Can onto the rotator and park above its sight lane. Sustained occupancy sweeps the beam toward a sensor. Withdraw toward the left early enough that Can clears the pedal at alignment. The powered crossing reaches the exit side. | Intentional placement transfers from Boulder to Can; duration now matters as well as position. |
| Combine | One Boulder push powers the Fan and leaves Can overlapping the rotator. Alignment positions the upper crossing and raises Can's supporting platform. Use the Fan and the crossing to reach the final alcove while accounting for the carried Can. | Force, ending position, timing, transport, and player movement can be planned together. |

Fresh layouts: [Redirect](artifacts/final_demo/screenshots/layout_1.png),
[Weight](artifacts/final_demo/screenshots/layout_2.png),
[Timing](artifacts/final_demo/screenshots/layout_3.png),
[Combine](artifacts/final_demo/screenshots/layout_4.png).

Exits require a landing on the real alcove floor and movement into the doorway.
There are no machine-completion prerequisites in the exit check. The geometry
is intended to make machinery useful: elevated exits, limited jump height, and
crossings that move into reachable positions. The recovery audit attempts
forward movement and repeated ordinary jumps for 400 frames per level with Can
suspended. Those bounded attempts cannot bypass the machinery. This is not an
exhaustive search for every possible skip with active Can.

## Two causal reversals

**Weight: powering the desired lift also moves a threat into it.** The button's
visible wiring reaches both Fan and hanging sweep. Activation gives the sweep a
0.22-second warning, then moves it across the airflow once and parks it to the
left. Entering after that sweep avoids contact. A deliberately rushed input-only
run completes with one hit; the cautious route completes with none. The faster
expert route also avoids contact through its chosen arrival timing, so waiting
is a useful strategy rather than a mandatory timer gate.

Evidence: [linked sweep](artifacts/final_demo/screenshots/L2_linked_sweep.png),
[cautious route](artifacts/final_demo/route_sequential_L2.json), and
[rushed route](artifacts/final_demo/route_sequential_rush_L2.json).

**Combine: the familiar sensor also carries Can into a new charging lane.**
The sensor's wiring and platform outline disclose both destinations. Its lift
physically carries Can off the pedal, stopping rotation near alignment, while
the crossing moves toward the exit. The sequential route keeps Can on that
surface until activation, then encounters its upper charge and takes one hit
while still completing. The expert route baits Can left before alignment and
rebounds from its continuing charge as the lift rises, clearing the threat and
gaining height. Both follow the shared transport and charge rules.

Evidence: [carried Can](artifacts/final_demo/screenshots/L4_can_lift_consequence.png),
[expert rebound](artifacts/final_demo/screenshots/expert_L4_continued_charge_rebound.png),
and [expert graphics recording](artifacts/final_demo/route_expert_L4_graphics.json).

Timing's overshoot is the ordinary duration lesson. In controlled fixtures,
starting withdrawal when the sensor first lights stops the beam at 23.13°,
beyond the 4.12° sensor direction. Starting about 26° before that direction
stops it at 4.00° and sustains contact. These fixtures establish the causal
delay; they do not measure how quickly a new player learns it.

## Recorded approaches and results

Completion scripts observe world state and apply movement, jump, and attack
inputs. They do not teleport actors, assign mechanism state, or invoke success
after spawn. The sequential script already knows the solution and is therefore
not a novice playtest. The expert script likewise represents a rehearsed plan.

| Level | Sequential active time | Sequential hits | Expert active time | Expert hits |
|---|---:|---:|---:|---:|
| Redirect | 4.95 s | 0 | 4.95 s | 0 |
| Weight | 7.03 s | 0 | 5.53 s | 0 |
| Timing | 9.53 s | 0 | 9.53 s | 0 |
| Combine | 10.47 s | 1 | 10.78 s | 0 |
| Total | 31.98 s | 1 | 30.79 s | 0 |

These are controller active times, excluding clear transitions. The complete
test recordings span 2,076 and 2,005 frames respectively. Neither route has a
death or reset. Expert Combine has two charging rebounds: the first launches
the worker while Can continues to push Boulder, and the second uses the charge
near the rising lift. It demonstrates a different configuration and avoids
damage; its Combine time is slightly longer than the sequential route.

Latest headless evidence:
[sequential](artifacts/final_demo/route_sequential.json),
[expert](artifacts/final_demo/route_expert.json).
Earlier rendered evidence:
[full sequential](artifacts/final_demo/route_sequential_graphics.json),
[expert Combine](artifacts/final_demo/route_expert_L4_graphics.json).
Rendered and headless timing differs slightly, so the table uses only the
latest headless recordings.

## Verification and recovery

All ten verification runs exited successfully on 2026-09-29:

- `tests/demo_systems.gd`: 23 checks covering preview/lock, force, rebound,
  rolling, continuous weight and airflow, rotation, optical contact, reversible
  platform power, carried Can, and Boulder beam blocking.
- `tests/demo_learning.gd`: late versus anticipatory withdrawal outcomes.
- `tests/demo_recovery.gd`: 14 checks covering bounded jump skips, airborne
  doorway contact, real-floor exit completion, R retry, and death recovery.
- `tests/demo_route.gd`: full sequential and expert runs, the rushed Weight
  run, and fresh independent starts for each of the four levels.

Run the commands listed in [README.md](README.md). Check outputs are also saved
as [systems.json](artifacts/final_demo/systems.json),
[learning.json](artifacts/final_demo/learning.json), and
[recovery.json](artifacts/final_demo/recovery.json).

System and recovery tests use declared actor/state fixtures to isolate rules;
they are separate from the input-only routes. The
[Boulder-cover capture](artifacts/final_demo/screenshots/L4_boulder_cover_fixture.png)
also uses explicitly positioned actors and beam aim. It demonstrates the
secondary optical property, not a demonstrated input-only alternate solution.

R rebuilds the current level and records its failed attempt while keeping prior
completions. Death rebuilds the current level after about 0.25 seconds. Success
advances after 0.65 seconds. Shift+R starts from Redirect, and R after victory
replays the demo. The recovery tests confirm that retry and death in Timing
retain the first two completions.

The sandboxed runs emitted macOS user-log and certificate-access diagnostics,
but every test completed with exit code 0 and empty failure arrays. Saved
screenshots were inspected during this continuation; no new graphical or audio
playthrough was performed.

## Evaluation limits

The design estimates 245–300 seconds for a first encounter. Rehearsed routes
are much shorter and cannot validate that estimate, discovery time, player
planning, enjoyment, or the readability of the two reversals. No delay or long
walking section was added to manufacture the target duration.

The earlier blind-playtest setup was blocked by macOS capture/input access and
contains no gameplay results; see
[SETUP_BLOCKER.md](artifacts/blind_playtest/SETUP_BLOCKER.md). A fresh human
playtest should measure time per level, deaths and retries, when each heuristic
is learned, and whether players predict the linked consequences. The current
evidence establishes runnable mechanics, multiple rehearsed approaches, and
quick recovery. The human experience remains unevaluated.
