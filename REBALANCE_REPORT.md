# Focused difficulty, fun and level-design rebalance

Implemented in the existing `scenes/final_demo.tscn` and shared demo scripts.
The four-room structure, movement abilities, maximum Can speed, health and fast
current-level retry remain. The audit and preimplementation decisions are in
[REBALANCE_PLAN.md](REBALANCE_PLAN.md). Earlier scenes, reports, changelog history
and baseline captures are preserved.

The technical checks below pass. **Human fun, perceived difficulty and the
4–5 minute first-run duration have not been validated after these changes.**
The implementation is ready for that playtest; those subjective pass criteria
are not declared satisfied by automation.

## Level 1 — Redirect: easy but active

- **Old problem:** shutter then freight repeated one positive force interaction.
  Existing steps made the post-impact Can position largely irrelevant.
- **Change:** two useful opening receivers. Left force slides the service deck
  under Can, then carries it into an upper approach. Right force clears the
  ground shutter. Freight shifts right to close the final traversal gap. The
  ground route uses the parked Can to rebound onto a broad intermediate landing.
- **Why more interesting:** the first impact determines both access and the
  height of the continuing threat/force source. The upper approach preserves a
  charging companion on the catwalk; the lower approach leaves a useful rebound
  beside the next landing. Both were completed using player inputs.
- **Decision:** which target should receive the first force, and where should
  I be when Can recovers? Solves now: creates a route. Leaves behind: Can in a
  different lane, which changes the next bait and height-gain opportunity.
- **Old knowledge reused:** movement and descending rebound; position selects
  a locked charge. **New knowledge:** no ability or object rule; discover that
  the same force can create different useful configurations.
- **Expected novice:** choose the ground shutter, dodge, observe the freight
  gap and use Can again for height. A lift-first experiment is also recoverable
  by interacting in its new lane or retrying immediately.
- **Expected experienced player:** choose the desired approach before the
  first lock, anticipate the next bait, and combine rebound with continuing
  force. The upper route has more physical interactions; the recorded lower
  route is faster. Neither is a fake target.
- **First-run design estimate:** 50–55 seconds, unmeasured.
- **Payoff:** stronger anticipation tone, body compression, visible lock,
  short acceleration, impact recoil/dust and an upward moving Can rebound.

[Fresh room](artifacts/rebalance/screenshots/layout_1.png).

## Level 2 — Momentum: medium

- **Old problem:** Boulder was a weight key for Button→Fan, followed by waiting
  for a linked hanging sweep. Its motion and direction did little design work.
- **Change:** the room starts from the right. Leftward force rolls Boulder into
  a sliding solid duct panel. Fan runs from spawn but the panel seals its nozzle.
  The panel withdraws; its motion and Boulder momentum leave Boulder over the
  exposed nozzle. Another deliberate commitment clears the obstruction.
- **Why more interesting:** opening the panel does not finish the chain. A
  physical consequence replaces the extra hazard and waiting. The same Boulder
  transfers force, changes geometry, and obstructs a continuous world effect.
- **Decision:** force must go left here, unlike the straightforward L1 opening;
  where should the next bait leave Boulder and Can relative to the nozzle?
  Solves now: withdraws the panel. Leaves behind: an obstructed jet and Can
  near the next force opportunity. The useful second configuration has Boulder
  beside the jet, rather than sitting on a designated key location.
- **Old knowledge reused:** locked direction and preparing the next player
  position. **New knowledge:** signed force transfers through a heavy rolling
  body; its resulting position continues to obstruct the world.
- **Expected novice:** see the panel move, approach the still-sputtering nozzle,
  realize the rolling object now blocks it, then arrange the next charge.
- **Expected experienced player:** start preparing the second bait while the
  first roll completes, then enter the jet above the remaining Can threat.
- **First-run design estimate:** 60–70 seconds, unmeasured.
- **Payoff:** Can→Boulder→moving panel, spinning/rolling dust and a second clunk,
  followed by the exposed upward jet.

[Fresh room](artifacts/rebalance/screenshots/layout_2.png),
[settled nozzle obstruction](artifacts/rebalance/screenshots/L2_nozzle_obstructed.png).

The original plan proposed a reverse-hit alternative after the first roll.
The current ground layout biases Can to the right of Boulder; two useful
leftward commitments are the verified route. The room was mirrored to make
direction an explicit knowledge-transfer decision. A symmetrical reverse route
is not claimed. No new Can jump/teleport behavior was added to manufacture one.

## Level 3 — Timing: medium+

- **Old problem:** an isolated rotator withdrawal task, with little reuse of
  Boulder position and a tiny target at 28°/s.
- **Change:** the approach now contains Boulder. Right force parks it around
  x=429 as a step for the later crossing and leaves Can at the rotator. The old
  redundant step is replaced by a landing that benefits from that prepared
  Boulder. The beam rotates at 18°/s with a broad real optical collector and
  reverses at mechanical limits instead of requiring a full-circle retry.
- **Why more interesting:** the first force prepares both a timing actuator
  and a future traversal object. Alignment alone does not prepare the landing.
- **Decision:** where will Boulder settle, and where should I withdraw before
  Can's locked charge clears the pedal? Solves now: starts controlled rotation.
  Leaves behind: a stepping stone, a moving crossing and a displaced Can.
- **Old knowledge reused:** L1 direction/lock, L2 force and resulting position.
  **New knowledge:** duration of physical occupancy controls a continuous state;
  removing the weight freezes its actual angle.
- **Expected novice:** observe the sweep, leave too late once, correct the
  withdrawal start, then use the prepared Boulder. The collector and lead mark
  show a generous window rather than an exact angle.
- **Expected experienced player:** begin withdrawal earlier and head toward
  the Boulder landing before the crossing finishes moving.
- **First-run design estimate:** 70–75 seconds, unmeasured.
- **Payoff:** freezing a moving red beam, the collector winding its cable,
  then traversing the configuration prepared by the earlier force.

[Fresh room](artifacts/rebalance/screenshots/layout_3.png),
[stopping preview](artifacts/rebalance/screenshots/L3_stopping_preview.png).

## Level 4 — Combine: medium+, mastery

- **Old problem:** about 0.33 seconds of optical contact at 28°/s, a small target,
  immediate simultaneous platform/lift movement, and Can carried into the
  worker's next jump lane. Boulder cover existed mainly in a midair test fixture.
- **Change:** the low emitter's real beam meets the ground Boulder. That same
  Boulder obstructs the running Fan. Moving it opens airflow and extends the
  exposed dangerous beam lane. The control and recovery ledges leave the useful
  ray path clear. Rotation is 16°/s, the collector is broad, and the Can lift
  warns for 0.75 seconds before carrying its actual support upward.
- **Why more interesting:** safety, airflow, angle, physical transport and Can's
  next reachable lane interfere. Boulder is neither an isolated key nor a
  decorative blocker. Can must supply force and later supply occupancy.
- **Decision:** move out of the old beam lane before opening it; arrange the
  returning Can on the pedal; prepare above the beam and away from Can's carried
  lane before alignment. Solves now: opens airflow and the crossing. Leaves
  behind: an exposed beam, displaced Boulder and a transported threat.
- **Old knowledge reused:** all three earlier levels, including platform
  carrying seen in the L1 alternative. **New knowledge:** no major mechanic;
  the existing relationships overlap.
- **Expected novice:** inspect the initial cover, cause a recoverable beam or
  Can hit while returning through the low lane, and prepare the safe perch on
  the next attempt. Incorrect angles and inconvenient states reset locally.
- **Expected experienced player:** withdraw through the safe side, move above
  the lower beam before the lift starts, and take the shorter upper crossing.
  The prepared input-only route completes with zero hits.
- **First-run design estimate:** 90–100 seconds, unmeasured.
- **Payoff:** Boulder roll→airflow and exposed beam→continuous angle→heat winch
  and physical Can transport→final crossing. The same action has benefit and
  consequence. The old danger is already visible before it extends.

[Fresh room](artifacts/rebalance/screenshots/layout_4.png),
[exposed-beam warning](artifacts/rebalance/screenshots/L4_exposed_warning.png),
[carried Can](artifacts/rebalance/screenshots/expert_L4_carried_can.png).

## Laser execution and readability changes

| Property | Old final room | Current L3 | Current L4 |
|---|---:|---:|---:|
| Rotation speed | 28°/s | 18°/s | 16°/s |
| Actual unoccluded angular window | approximately 9° | 25.75° | 15.25° |
| Time within window | approximately 0.33 s | 1.43 s | 0.95 s |
| Can lift warning | immediate | no Can lift | 0.75 s |

Current windows are sampled at 0.25° in controlled real-ray fixtures, including
actual geometry occlusion. The receiver is not snapped into place. The dial
draws its acceptable sector and a predicted withdrawal lead; the collector
glows/spins at contact. Laser, collector, Can and the next bait/perch all remain
inside the original whole-room camera composition.

Five L3 withdrawal leads, 10/14/18/22/26°, sustain the actual beam state. That
covers about 0.89 seconds of different start times. A deliberately late -2°
lead overshoots and loses power after cooling. L4's automatic physical lift
withdrawal provides an alternative to manual timing, while its warning gives
time to commit to a safe next position.

L4's prepared retreat also succeeds with zero hits at bait positions x=215,
225 and 235: a 20-pixel span, with rehearsed completion times of 11.77–11.90
seconds. The [left-margin run](artifacts/rebalance/route_expert_L4_bait215.json)
and [right-margin run](artifacts/rebalance/route_expert_L4_bait235.json) check
spatial tolerance rather than only a single successful coordinate.

The final lift destination was lowered to a deck top of 244 rather than 224,
keeping its new threat near the control area instead of the exit jumps. A broad
intermediate landing replaces the long post-solve leap. A heat winch coasts for
0.28 seconds through a short passing-body interruption, then cools if the beam
is genuinely lost. This prevents its own moving support from chattering.

## Replaced generic logic and shared properties

Removed from the current rooms: Boulder→Button→Fan and Button→hanging sweep,
including both pressure-to-Fan circuits. Pressure-switch code is retained for
history but no demo room instantiates a button. No colored object/switch match
or hidden “puzzle completed” prerequisite determines exit success.

Replacements: signed momentum through the existing force-receiver contract;
a sliding solid panel exposing a physical nozzle; heavy solids obstructing
airflow; grounded Boulder intercepting a real beam; physical occupancy turning
a bounded rotator; a beam-driven heat collector winding a visible cable; and
real platform support carrying Can. The optical connection is retained, but
presented and tuned as a continuous heat winch rather than an instantaneous
colored key. Bodies and geometry continue to matter after activation.

The Can's 230 px/s maximum, 0.55 s preview/lock routine, 0.20 s recovery and
0.38 s normal stagger remain. Its first 0.10 s now accelerates; the visible lane
uses remaining travel. Top rebounds account for a rising Can's relative motion,
and ordinary jumps no longer inherit accidental vertical lift launch speed.
No new attack, enemy, ability unlock, physics object class or player input was
introduced. Airflow influences Player; lifting all object types was deliberately
left outside this focused scope.

## Verification and recorded behavior

Godot 4.7.2 checks and evidence are under [artifacts/rebalance](artifacts/rebalance).
Use the current commands in [README.md](README.md).

- [systems.json](artifacts/rebalance/systems.json): 33 controlled checks,
  including direction lock, signed rolling, the actual duct chain and first
  obstruction, air force/solid clipping, occupancy/freeze, measured angle
  windows, withdrawal margins, cover-removal warning/failure, prepared safety,
  lift confirmation/carrying and loss of heat contact.
- [audit.json](artifacts/rebalance/audit.json): 11 bounded shallow input attempts
  fail to complete L1–L3, including both directions in mirrored L2. Controlled
  checks verify real-floor exits, airborne doorway rejection, current-level R,
  fast death recovery and victory/replay. This is not exhaustive skip search.
- [route_sequential.json](artifacts/rebalance/route_sequential.json) and
  [route_expert.json](artifacts/rebalance/route_expert.json): full input-only
  completion with no death/retry. The prepared route has zero hits; the
  deliberately less-prepared final approach takes two recoverable hits.
- Fresh independent runs of all four rooms pass. The
  [upper opening](artifacts/rebalance/route_sequential_L1_upper.json) also passes
  with zero hits, carrying Can and producing three rebounds.
- Rendered sequential and prepared routes pass; all four fresh layouts and
  consequential screenshots were inspected. Graphics timing differs slightly
  from accelerated headless steps. These are engine-rendered rehearsals, not
  a person playing or listening to the audio.

| Level | Baseline known route | New sequential | New prepared | New sequential / prepared hits |
|---|---:|---:|---:|---:|
| L1 | 4.95 s | 5.95 s | 5.95 s | 0 / 0 |
| L2 | 7.03 s | 7.43 s | 7.42 s | 0 / 0 |
| L3 | 9.53 s | 8.65 s | 8.22 s | 0 / 0 |
| L4 | 10.47 s | 12.50 s | 11.80 s | 2 / 0 |

These timing measurements use the documented fixed-60-FPS harness. An uncapped
headless prepared run also completed, with one recoverable hit as input/frame
scheduling shifted; zero-hit behavior is not asserted for every schedule.

Active known-solution totals are 34.53 and 33.38 seconds, excluding clear
transitions. Earlier withdrawal makes L3 faster; spatial preparation and the
shorter upper crossing make L4 more elegant and faster. L2's recorded speed
gain is negligible and is not evidence of substantial mastery by itself.
L1's upper alternative takes 7.97 seconds in its recording; efficiency comes
from choosing the approach appropriate to the follow-up, not an imposed rank.

Current-level death retry remains about 0.25 seconds and R rebuilds without
replaying previous levels. Alignment mistakes are reversible through another
short bounded sweep or a local retry. There is no added waiting cycle or large
map expansion to manufacture the duration target. Headless runs emit macOS
certificate diagnostics; graphical capture processes also report a small
ObjectDB cleanup warning on exit. No gameplay script errors were present in
the passing final runs.

## Remaining concerns and acceptance status

The first-encounter estimates total **270–300 seconds (4.5–5 minutes)**. They
remain design targets, not measured results. The previous estimates were too
optimistic about how much discovery adds time; the supplied human feedback
takes precedence. Do not use the fast scripted routes to declare duration,
fun or the smoothness of the human difficulty curve proven.

The final technical evidence establishes real choices/configurations, Can-led
chains, multi-purpose Boulder, actual optical cover, clear tolerances, fast
retry and both prepared and recoverable-error completion. It does not certify
that L1–L3 feel sufficiently substantial or that every player finds the chain
surprising. The optically powered crossing still has an activation relationship;
its continuous heat/cable presentation should be judged by a person.

A human pass should record time per room, first chosen L1 target, whether the
L2 clogged nozzle is understood, when the L3 withdrawal plan is formed, and
whether L4 mistakes are about resulting state rather than control execution.
Repeat immediately to compare earlier preparation and cleaner routes. If the
demo still finishes too quickly, increase consequence decisions within the
existing relationships; do not add waiting, precision jumps or new hazards.
If a player who knows the plan repeatedly misses L4's execution, broaden the
spatial/timing margins again. **Fun, perceived depth and first-run pacing remain
the human acceptance gate; automation is not a substitute.**
