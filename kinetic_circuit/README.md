# Clockwork Tower: Kinetic Circuit

The project launches one folded tower around a shared Core. Strike the Intake
socket to climb into the two side circuits. A Guard's committed charge can
power Pressure, then hit teeth that briefly stun it. Reflected Shooter bolts
can power Signal and later the Core. Both sources can be removed; slower manual
impacts still finish the circuit. Socket pips, conductors, and moving shutters
show what changed. Core alignment quiets the machinery and opens the exit climb.

Run it with Godot 4.7 from this directory, or with
`godot --path kinetic_circuit` from the parent repository. Move with A/D or the
arrows, jump with Space, and hold S while pressing J or X in the air for a
downward impact and rebound. Hold a horizontal direction while striking to hit
a threat or reflect a bolt. R restarts the whole circuit. A gamepad can move
with the left stick or D-pad, jump with A/Cross, attack with X/Square, aim down
with the stick or D-pad, and restart with Y/Triangle.

The main route and source-loss recovery checks are
`tests/circuit_route.gd` and `tests/circuit_recovery.gd`.

The previous Kinetic Clockwork course remains in
`scenes/kinetic_prototype.tscn` for comparison and regression tests. The new
route reuses its movement, enemy, hazard, reflection, effects, and sound code;
its layout and objective are new. The redesign audit and plan are in the
parent [CLOCKWORK_TOWER_REDESIGN_PLAN.md](../CLOCKWORK_TOWER_REDESIGN_PLAN.md).

## Previous prototype (preserved)

### Clockwork Ascent: Kinetic Prototype

This preserved scene contains a continuous Godot 4.7 gray-box level for
*Kinetic Clockwork*. Run, jump, and downward-strike a charging ram to transfer
your horizontal momentum into it. The same heavy rail carriage carries that
changing momentum through three connected situations: catch it after launch,
deal with a second ram approaching from the opposite direction, and turn its
leftward return into the jump to the Dash Core. The collected core opens a
fourth section where a chain of target dashes crosses the final spike rail,
followed by a vertically scrolling platforming tower. Beyond that tower, eight
additional regions continue through precision platforming, aggressive guards,
reflectable projectile lanes, a charger-filled descent, moving-saw transit,
double-jump aerial combat, a single-guardian mastery arena, and a long summit climb.

The original two-level *Clockwork Ascent* build remains intact in
`scenes/game.tscn`; this prototype is isolated in
`scenes/kinetic_prototype.tscn` so the mechanic can be evaluated before either
full level is redesigned.

The original design brief and implementation plan are in [GAME_PLAN.md](GAME_PLAN.md).
Past and upcoming game changes are recorded in [CHANGELOG.md](CHANGELOG.md).

## Play

Open `scenes/kinetic_prototype.tscn` in Godot 4.7 and run that scene.
For rapid boss testing, enter the `TEST WARP` immediately left of the initial
spawn. It grants both level powerups and makes the Titan arena checkpoint active
before teleporting the player there.

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move | A/D or arrow keys | Left stick or D-pad |
| Jump | Space | A / Cross |
| Double jump, after Aerial Core | Space again while airborne | A / Cross again while airborne |
| Attack | J or X | X / Square |
| Toggle slow motion | Q | — |
| Dash aim, after Dash Core | W/A/S/D or arrow keys | Left stick or D-pad |
| Target dash, after Dash Core | K/C with aim, or right-click near an enemy | B / Circle |
| Reset experiment | R | Y / Triangle |

Hold up, down, left, or right while attacking to strike in that direction.
Press Q to toggle the full simulation and audio to 35 percent speed for precise
dash aiming, directional attacks, and rebound timing. The four-second meter
drains in real time while slow motion is active, switches the effect off when
empty, and recharges during normal gameplay. A blue tint shows when it is active.
Downward attacks are available in the air; neutral and grounded-down attacks
follow the player's facing direction. Downward hits still rebound the player,
including when the blade connects with floor spikes, while horizontal hits
drive the carriage with the same strong momentum transfer as a charging ram.
After collecting the Dash Core, every successful downward pogo refreshes a spent
dash. A near-vertical downward strike damps a ram, a fast strike in its direction
accelerates it, and an opposite-direction strike can slow or reverse it. The
two opening rams display two health pips: the first hit still redirects their
momentum, while a second hit destroys them. The carriage coasts with
deterministic friction and rebounds from its rail stops.
Safe work islands make imperfect momentum recoverable. Ram contact removes one
of three health points and grants brief invulnerability. Touching spikes without
a downward strike or falling off the map also costs one health, but returns the
player to the last safe platform; ordinary damage invulnerability does not make
spikes intangible or harmless. The full checkpoint resets only at zero health.
Enemies use state-driven procedural animation: walkers stride and lean, flying
units flap or spin, relays pulse, and heavier enemies visibly anticipate,
attack, recoil, and recover. Their patrols and attack responses are deliberately
quick, while dangerous actions retain distinct visual tells. Defeated machines
now launch apart into spinning, glowing fragments instead of disappearing.
The compact HUD uses three top-left icons for health, with the real-time timer
immediately left of the slow-motion meter at the top right. A one-time opening
message shows the essential WASD movement and J attack controls. The timer keeps
recording during slow motion and reports the final time at the summit. At zero
health, the player is thrown into a brief breakup animation while the camera
zooms in and a system failure message appears; revival clears every part of that
presentation.

The presentation uses a unified clockwork-foundry theme. Layered gear trains,
pistons, chain runs, pipework, and structural frames animate behind the route,
while static and moving platforms use conveyor trim, rivets, rollers, and steel
bracing. Spike beds use independently animated glowing teeth over solid,
reinforced machinery. An original looping mechanical score combines warm chord beds, bass,
bell-like arpeggios, melody, and restrained industrial percussion. A separate
quiet tick-tock mechanism sits beneath the music and gameplay sound effects.

The Dash Core waits on the return gantry. After collecting it, hold a direction
and press dash to target a visible shielded relay within the 160-pixel aim
range, or right-click within 14 pixels of an enemy to select it directly. The
circle marks the current target. Mouse selection still respects the normal
range and line-of-sight rules. With no valid directional target, keyboard or
gamepad dash instead gives a short burst in the held direction, or forward when
no direction is held.
Each targeted hit refreshes the dash. Relay hits preserve momentum so all four
relays can carry the player across the spike gap. Dashing into a combat enemy
instead produces a safe, pogo-height upward rebound and briefly protects the
player from follow-up contact. Every downward pogo hit refreshes a spent dash
regardless of the surface or enemy struck. The
landing activates a second checkpoint before the Vertical Works, where narrow
zigzag ledges, partial spike strips, and two moving platforms climb more than
400 pixels to the summit transfer. Spring
Drones bob above the lower ledges and Gearwings sweep across upper gaps; either
enemy can be used as a target dash or struck downward for a pogo rebound.

The old summit opens into three initial endgame areas. The Precision Foundry
uses narrow alternating ledges, spike floors, moving lifts, and charging Tower
Guards. Their fast rushes have a clear windup and leave them stunned when they
miss. The Cannon Gallery adds staggered firing lanes and patrolling Shooter
enemies that display their aim before firing two-round bursts; attack an
incoming bullet to reverse it back along its incoming trajectory, allowing it
to damage enemies. The Crown Ascent combines steep dash-assisted jumps, a
moving transfer platform, guards, and shooters before the deep expansion. Each area
has a checkpoint, and failures restore its enemies while clearing active bullets.

Five more major areas follow. The Descent Foundry drops through alternating
ledges while nine fast Descent Guards charge across the shaft. Razor Transit is
a dense platforming gauntlet with six moving platforms, continuous spike beds,
and three animated travelling saws. The Aerial Core grants a reusable double
jump that refreshes on landing and pogo; its elevated Sky Hunters demand that
new jump or a well-aimed dash. The Titan Regulator locks one 15-health ground
guardian into a large multi-level arena with a continuous walkable floor. Its
expanded moveset cycles between a heavily telegraphed rush, a charged two-hit
hammer combo with continuous swing animation, and reflectable arcing bombs.
Regular, pogo, and reflected-projectile strikes all damage the same health pool;
the Titan cannot be target-dashed, and merely touching its body is harmless.
Only its committed attacks hurt the player. The Summit Ascent then climbs through seventeen ledges, four
moving platforms, three more travelling saws, and mixed enemies. Four additional
checkpoints divide the climb, and closely spaced final ledges provide reliable
access to the top deck. An animated Clockwork Core waits in the middle of that
platform; collecting it records the final time and wins the game.

Each expansion area has its own checkpoint and procedurally animated mechanical
scenery. The new enemies have readable windups and attack animations, the Titan
accelerates below half health, and double jumps, powerup collection,
boss defeat, and the arena gate each have distinct synthesized sound cues.
The expanded world uses camera-bounded procedural drawing and automatically
sleeps distant enemies, lifts, carriage machinery, and saws. Actors wake before
they enter combat or dash range, keeping the long route responsive without
changing encounter behavior.
After the Vertical Works summit transfer, the camera smoothly sheds its upward
look-ahead and centers on the player for the remainder of the route.

The candidate comparison, section audit, and system-led discovery are recorded
in [KINETIC_LEVEL_DESIGN.md](KINETIC_LEVEL_DESIGN.md).

## Checks

Run the integration checks from this directory:

```sh
godot --headless --path . --script res://tests/smoke.gd
godot --headless --path . --script res://tests/route.gd
godot --headless --path . --script res://tests/interactions.gd
godot --headless --path . --script res://tests/rebound.gd
godot --headless --path . --script res://tests/dash.gd
godot --headless --path . --script res://tests/kinetic.gd
godot --headless --path . --script res://tests/kinetic_route.gd
godot --headless --path . --script res://tests/kinetic_dash.gd
godot --headless --path . --script res://tests/kinetic_endgame.gd
godot --headless --path . --script res://tests/kinetic_expansion.gd
godot --headless --path . --script res://tests/kinetic_performance.gd
godot --headless --path . --script res://tests/audio.gd
```

The optional capture scripts save screenshots to `/tmp` when run with a
graphics display.
