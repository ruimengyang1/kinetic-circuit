# Level progression redesign report

2026-09-29. The current four-room prototype is implemented and functionally
verified. **Full design acceptance remains pending the hard 4–5 minute
first-time pacing gate and an independent learning/replay observation.** Do
not label the whole redesign finished on the strength of authored routes.

The audit and plan were written before gameplay edits in
[LEVEL_PROGRESSION_REDESIGN_PLAN.md](LEVEL_PROGRESSION_REDESIGN_PLAN.md).
The current build already had useful L2/L4 relationships; those were retained.
The material layout change is L3's Boulder removal and two-sided Can placement.
No Player, Can, Boulder, Fan, Laser, sensor or moving-platform actor behavior
was changed. No new mechanic, enemy, hazard, control, timing restriction,
mandatory interaction or room was added. Can's L3 rail endpoint changed from
355 to 429; charge speed and duration did not change. Changelog history remains.

## Level 1 — How

| Requested dimension | Result |
|---|---|
| Previous version | Two signed force targets, optional left service lift, and a useful Can rebound after freight moves. Already a valid introductory room. |
| New purpose | Retain this simple tutorial as the foundation: predict a direction, observe commitment, apply it again to another receiver. |
| Required prior knowledge | None. |
| New heuristic | H1: my position controls Can intent. Seed: where Can finishes affects my next interaction. |
| Strategic decision | Open the right shutter, keeping Can near freight, or use the left service lift and approach from above. |
| Immediate benefit | Either opening creates a route. |
| Future cost | Left opening changes Can's height and needs a different freight setup; right opening supplies a convenient ground force/rebound position. Neither severely punishes a beginner. |
| Boulder role / removed? | Absent before and after. |
| Novice behavior, expected | Try a bait, observe lock and impact, then apply the same rule at freight without a second explanation. |
| Experienced behavior, demonstrated | Select the right opening to leave Can near the next receiver; preserve that nearby shell for a rebound. |

Input-only right route: two charges/two impacts, one rebound, 5.93 s, no damage.
Service alternative: four charges/three impacts, 8.78 s, no damage. These are
rehearsed feasibility times. This room is intentionally a tutorial, not the
main strategic test.

## Level 2 — Consequence

| Requested dimension | Result |
|---|---|
| Previous version | Boulder already blocked a stationary Laser and the running Fan nozzle; a broad staging shelf let the player prepare safely. |
| New purpose | Retain and verify the fair reversal: the obstruction is also cover. Establish the shared cover/nozzle relationship used again in L4. |
| Required prior knowledge | L1's position-selected direction, lock, and movement after commitment. The opening asks for leftward Can force immediately, without reteaching aiming. |
| New heuristic | H2: a useful state may be worth preserving. H3: immediate progress can leave a worse future state. |
| Strategic decision | Spend Boulder cover now and continue into opened air, or keep cover while staging above the exposed lane. |
| Immediate benefit | Immediate clearance makes the ascent available sooner. |
| Future cost | The low approach becomes an active beam lane. It is no longer a safe place to stop and inspect. Staging preserves safety until the player is prepared, at the cost of delayed access. |
| Boulder role / removed? | Kept: actual beam obstruction AND nozzle/traversal obstruction. Its starting position protects the approach; it is never a button weight. |
| Novice behavior, expected | Treat the obstruction as progress; move it and discover that waiting on the old safe floor now hurts. A retry changes the player's model, not a rule. |
| Experienced behavior, demonstrated | Either prepare on the shelf first, or deliberately choose immediate clearance with a plan to use the opened jet promptly. |

Same spawn, normal inputs: immediate clearance followed by observation takes
one hit (6.73 s); staged clearance takes none (6.18 s); immediate clearance
followed by ascent also takes none (5.30 s). Immediate use is therefore viable,
not an intentionally losing choice. It removes a safe observation state; the
staged plan preserves time to inspect. The existing 0.70 s cover-loss warning
makes the reversal recoverable. No shorter warning was introduced.

## Level 3 — Order / timing

| Requested dimension | Result |
|---|---|
| Previous version | The placement charge pushed Boulder to a compulsory landing step while parking Can on Rotator. Boulder had one useful endpoint, with little reason to preserve its initial state. |
| New purpose | Remove that scaffolding Boulder. A fixed 36 px service step keeps ordinary traversal available. Can's withdrawal direction now chooses its future availability as well as stopping Laser. |
| Required prior knowledge | H1 to park/withdraw Can; L2's H2 to preserve a useful configuration instead of treating every successful interaction as permanent progress. Occupancy and beam angle remain live states. |
| New heuristic | Act before the state you want. Refine H2 into preserving Can's position and Laser angle together. H4 begins: solve alignment while arranging the next traversal. |
| Strategic decision | Withdraw left to clear Can from the approach, or right to park it at x=429 beside the crossing for a rebound. Also choose when to begin withdrawal. |
| Immediate benefit | Both directions stop a useful Laser angle and sustain the crossing. Right also puts Can near traversal. |
| Future cost | Left sacrifices nearby rebound/control availability and uses an extra landing step. Right leaves a live Can near the approach; carelessly returning low can charge it back over Rotator and spend the stored angle. |
| Boulder role / removed? | Removed. A mandatory pushed landing step was insufficient strategic purpose. |
| Novice behavior, expected | React when the beam looks aligned, overshoot because approach/telegraph/clearance take time, then recreate occupancy. May choose the quiet left approach. |
| Experienced behavior, demonstrated | Begin early and select the endpoint for the next action. Right leaves an available shell, then an intentional ascent/rebound preserves the optical state. Left remains a valid safety preference. |

Same-spawn routes: left takes 8.28 s, two charges, no rebound; right takes
7.65 s, two charges, one endpoint rebound. Both sustain alignment with no hits.
The rebound is optional, not a new execution requirement. Controlled fixtures
also verify both directions from the same optical state, stable frozen angle
while the player stays high, and loss/recreation after a low return.

Rotation remains 18°/s. Actual ray-tested useful window remains 31.25°
(1.74 s). Left withdrawal fixtures succeed at early leads 8°, 12°, 18°, 24°,
28°; center or late starts miss. All relevant objects fit in the existing
640×360 camera. Death restores current-level control in about 0.25 s.

## Level 4 — Planning / tradeoff

| Requested dimension | Result |
|---|---|
| Previous version | Existing cover/nozzle Boulder, Can-operated Rotator, optical crossing and Fan. Two orders were already supported. |
| New purpose | Retain the compact capstone; verify that order and intentional endpoints produce different costs, and record those costs explicitly. |
| Required prior knowledge | L1 direction/lock/endpoint; L2 cover/nozzle sacrifice; L3 occupancy, delayed withdrawal, and preserving a frozen optical state. Fan was introduced in L2. |
| New heuristic | H4: set up the next interaction while solving the current one. Choose the future state before spending force. |
| Strategic decision | Clear Boulder first and solve live states in stages, or preserve Boulder while parking Can on Rotator and spend it with the timed withdrawal. |
| Immediate benefit | Clearance-first gives visible airflow access before beam control is solved. |
| Future cost | It loses cover, leaves the same Can away from the needed control state, and needs a return/setup. Preserving first delays airflow and asks the player to plan beam withdrawal plus force together. |
| Boulder role / removed? | Kept: initial beam cover AND nozzle obstruction. Its later displacement opens ascent, and the chosen order determines whether that displacement also solves withdrawal. |
| Novice behavior, expected | Clear the visible obstruction, inspect the result, then bring Can back and solve the optical crossing separately. This order can finish. |
| Experienced behavior, demonstrated | First choose a known left endpoint, then a right charge that parks on Rotator without hitting Boulder. Withdraw right before alignment; that same charge freezes the useful angle and opens the nozzle. |

Clearance-first completes in 14.30 s with four charges, two Boulder impacts,
one corrective Can return, one rotor-state recreation, and one hit. Preserved
cover first completes in 11.23 s with three charges, one Boulder impact, no
correction/recreation, one useful chained interaction and no hits. The first
left charge in the prepared order is intentional setup, not waste.

Both orders work; the prepared order is a better optimized plan. The tradeoff
is earlier visible access and separate observable steps versus delayed access
and coordinating consequences. No claim is made that the orders are equally
efficient or that a novice spontaneously discovers the better one. A staged
return experiment did not reliably remove the beam cost and is retained as
failed experimental evidence, not a recommended route.

The actual window remains 27° (1.69 s) at 16°/s. The capstone introduces no
major mechanic and requires no rebound. Expert improvement here comes from
action order and removing a correction, not executing jumps faster.

## Explicit learning curve

| Level | Learns / reuses | Adds / combines |
|---|---|---|
| 1 — How | Position → intent → locked charge | Two applications; initial endpoint awareness |
| 2 — Consequence | L1's directed force and commitment | Existing obstruction has value; access sacrifices cover |
| 3 — Order / timing | L1's placement; L2's persistent-state preservation | Anticipate delay; choose a Can endpoint while freezing a live optical state |
| 4 — Planning / tradeoff | All three: direction, cover/access consequence, early withdrawal and endpoint preservation | Choose order; combine one withdrawal with the next required force |

Why does Level 4 only make sense after Levels 1–3? Knowing that Can hits things
does not explain why its first charge should go away from visible progress.
L1 supplies intentional endpoint control; L2 explains why the blocked nozzle
should sometimes stay blocked; L3 explains why the withdrawal must begin before
the desired angle and why subsequent low movement can destroy alignment.
Together they justify parking Can without moving Boulder, then using a single
early withdrawal to produce both the desired beam state and airflow. Removing
any of those lessons leaves an unexplained step in the efficient order.
This is a learning dependency, not a hidden prerequisite flag; an already
knowledgeable player can still solve a fresh room.

## Reduction pass

| Objects retained or removed | Decision/function that would disappear |
|---|---|
| L1 Can, shutter, service lift, freight | Two deliberate forces and alternative opening endpoint/height. No Boulder added. |
| L2 Boulder, Laser, Fan | Preserve safe cover versus create ascent; all three are needed for the consequence. |
| L2 staging shelf and upper landing | Prepare before cover loss; exit after airflow. |
| L3 Boulder | Removed: only the prescribed landing preparation disappeared. |
| L3 Can, Rotator, sensor, crossing | Choose delayed withdrawal, preserve angle, and choose nearby versus remote Can availability. Unpowered crossing cannot span the exit gap. |
| L3 perch, service step, upper ledge | Stable bait/observation; optional ordinary path versus using Can; broad continuation after the chosen state. |
| L4 Boulder, Rotator/sensor/crossing, Fan | Both action orders, deferred cover sacrifice, and combined force/withdrawal. |
| L4 high observation and low bait shelves | Observe without spending Can's position; choose when/where to commit its next charge. Remaining ledges support normal traversal after that choice. |

Only two Boulders remain, each with two relevant physical roles. There are no
extra collectible keys, switches, enemies or force receivers to disguise a
single prescribed sequence. Necessary traversal geometry supports access and
state preservation; decorative background drawing is unchanged.

## Same-state novice / expert test and metrics

The L2 and L4 comparisons start at identical fresh spawns. Expected novice
choices favor visible clearance; prepared choices inspect or preserve the
future state. L3 supplies a third tested branch: both angle-preserving actions
have different Can endpoints. These are authored strategies, not measured
novice/expert people. Equal mechanic knowledge still leaves a choice about
safety, inspection time, delayed access, order, and future availability.

Runtime records charge IDs/endpoints, cover loss, rotor reoccupation and
useful aligned force/withdrawal chains. `tests/progression_compare.py` adds
explicit route-specific annotations for unnecessary charges, corrective
repositioning and meaningful order decisions. It does not infer intent from
every reversal or call every sacrificed cover state an error.

| L4 strategy | Charges | Unnecessary charge annotations | Corrective returns | Cover losses | State recreations | Useful chains | Order branch | Time |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Clearance first | 4 | 1 | 1 | 1 | 1 | 0 | 1 | 14.30 s |
| Preserve first | 3 | 0 | 0 | 1, deliberately later | 0 | 1 | 1 | 11.23 s |

Both L2 strategies currently trigger a second charge after clearance with no
required mechanism change. That waste remains visible in the metrics; the
improved plan is not falsely credited with eliminating every unnecessary
charge. Better cover use in L2 changes exposure and inspection options, not
necessarily charge count.

## Verification and evidence

[artifacts/level_progression/comparison.json](artifacts/level_progression/comparison.json)
contains all requested strategic metrics and their annotation definitions.
Input traces and snapshots are in the same directory; controlled fixtures and
check summaries are separate. Earlier historical artifacts were restored after
baseline verification rather than being replaced by this revision.

- 16 new state/resource checks pass.
- 45 shared Can, Boulder, optics and timing checks pass.
- 26 bounded bypass/transition/replay checks pass.
- 29 movement/input/feedback checks pass.
- 14 recovery and actual-floor exit checks pass.
- Full sequential and prepared routes pass; both L3 withdrawals, immediate L2
  ascent, and the alternate L1 opening pass from fresh spawns.
- Native rendered full routes agree with headless routes. Inspected L3 right
  endpoint/rebound, L2 cover exposure, L4 retained cover and combined withdrawal.

Total: **130 assertions plus successful route checks**. Bypass attempts are
bounded, not an exhaustive proof against every imaginable skip. An initial
state fixture incorrectly expected Can still to occupy Rotator after a long
charge; it now checks the actual visitation and angle change instead. That
correction does not change gameplay.

## Hard pass / fail

| Requested gate | Status |
|---|---|
| L2 requires L1 | Functionally supported: directed force starts the room; shallow bypasses fail. |
| L3 requires L1 + L2 | Functionally supported: intentional placement plus preservation/recreation of useful live state. |
| L4 requires L1 + L2 + L3 | Functionally supported by both orders and the combined early withdrawal. |
| Boulder only strategically necessary | Passed: L1/L3 none; L2/L4 cover and nozzle tradeoff. |
| Every remaining Boulder has two roles | Passed by actual ray/nozzle fixtures. |
| Two states offer plausible actions | Passed functionally: L2/L4 same-spawn choices; L3 adds two withdrawal directions. |
| Immediate benefit plus future cost | Passed: clearance grants airflow but loses safe observation; L4 also costs a return/setup. |
| Can final position matters | Passed: L1 next force; L3 quiet approach versus endpoint rebound; L4 rotor setup versus return. |
| Later difficulty mainly planning | Supported: unchanged actor tuning, broad windows and L4 routes without rebounds. Player perception remains unmeasured. |
| L4 no major new mechanic | Passed: all systems already present in L1–L3. |
| Expert differs through decision quality | Different authored plans demonstrate fewer corrections and a useful chain; independent novice/replay observation pending. |
| Whole demo approximately 4–5 minutes | **Unverified.** Independent first encounter needed. |

Known-solution sequential total is 35.25 s versus baseline 35.23 s, excluding
transitions. Prepared total is 31.63 s; the alternative L3 setup is shorter.
The redesign therefore did not lengthen the known route. Discovery target
remains 240–300 s across all rooms, including observations/retries; no waiting
gates or dead corridors were added to manufacture that number. Authored route
duration cannot establish first-time pacing, fun, or spontaneous learning.
Those acceptance claims remain open.
