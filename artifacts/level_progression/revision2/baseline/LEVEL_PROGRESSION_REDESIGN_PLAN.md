# Current-build audit and progression plan

Audit completed before gameplay edits, 2026-09-29. The launch scene is
`scenes/final_demo.tscn`; its four rooms are built in `scripts/final_demo.gd`,
not four separate scene files. Read all nine scene wrappers, current room
builders, Player inheritance through `player.gd`, Can, Boulder, machines
(Laser, Rotator, sensor, Fan), moving supports, transitions, and current
strategic/rebalance/demo/feel/recovery tests. Other scene wrappers launch
historical prototypes or sandboxes and are outside the current four-room demo.

Played the existing input-driven route in native Godot and inspected rendered
consequential states. This is an authored, rehearsed playthrough, not blind
discovery or a human fun test. Baseline route and 45 passing system checks are
saved in `artifacts/level_progression/baseline/`. Baseline known-solution room
times: 5.93 / 6.73 / 8.27 / 14.30 seconds. These do not establish novice pacing.

## Honest audit: nine questions for every current level

| Question | L1 — How | L2 — Consequence | L3 — Anticipate | L4 — Plan |
|---|---|---|---|---|
| 1. Actually learns | Bait signed force twice; use a parked Can for height | Moving a nozzle obstruction also removes beam cover | Occupancy rotates Laser; withdrawal has delay; pushed Boulder becomes a step | Keep Boulder while parking Can, then combine withdrawal and displacement |
| 2. Heuristic formed | Stand on the side you want Can to charge toward | Inspect what an obstruction currently protects | Start leaving before alignment | Arrange the next charge while solving this one |
| 3. Prior knowledge | None | L1 direction, commitment, safe repositioning | L1 placement/withdrawal; weak L2 transfer because Boulder has no valuable initial cover state here | L1 control, L2 cover/nozzle consequence, L3 anticipation |
| 4. Decision | Service lift first or shutter first | Clear now from lower approach or stage on safe shelf first | Withdrawal start time; landing-step push has one useful endpoint | Clear Boulder first or park Can first |
| 5. Multiple plausible actions? | Yes, two opening directions | Yes, immediate access versus preparation | Mostly one authored sequence; timing variants are not much of a strategic branch | Yes, both orders complete |
| 6. Future options changed? | Can height/location affects freight access | Open air, lose cover, park Can away from ascent | Angle persists, but Boulder is simply mandatory scaffolding | Early clearance spends cover and demands a return charge; preservation permits a combined action |
| 7. Main challenge | Tutorial understanding with some rebound dexterity | Understanding consequence and preparing position | Timing/anticipation plus traversal | Planning/order plus timing already learned |
| 8. Boulder purpose | Absent | Laser cover AND nozzle obstruction | Force target that becomes a landing step; two physical properties, but only one meaningful destination | Initial beam cover AND nozzle obstruction; displacement can chain with withdrawal |
| 9. Remove Boulder? | Already absent | Changes both safety and route availability; keep | Breaks a landing unless replaced by ordinary geometry; this is scaffolding, not a preservation decision; remove | Removes the order/cover/air tradeoff; keep |

The current build already partially implements the requested curriculum. Keep
successful relationships instead of replacing them merely to produce a larger
diff. L1 is intentionally a tutorial. L3 is the weakest strategic transfer.
The old report honestly leaves independent discovery and 4–5 minute first-run
pacing unverified; that uncertainty must remain visible.

## Concrete redesign

- L1: retain the two deliberate force targets and optional service approach;
  keep Boulder absent. Useful Can endpoint supplies the next force/rebound.
  No additional tutorial explanation for the second target.
- L2: retain actual cover + nozzle obstruction, visible projected beam,
  broad staging shelf, and recoverable exposure warning. Compare immediate
  clearance to preparation from the exact same spawn. Both can complete;
  immediate progress costs lower-lane safety, not an arbitrary puzzle flag.
- L3: remove Boulder. Replace its compulsory landing role with a broad fixed
  service step. Extend Can's existing rail to the crossing approach. Preserve
  slow rotation and optical window. Test both withdrawal directions: left
  freezes the angle and keeps Can out of traversal, but gives up nearby
  rebound availability; right freezes the angle and parks Can as an optional
  rebound/setup, but introduces a live Can into the approach. Staying above
  acquisition height preserves the chosen state. Wrong withdrawal timing
  requires recreating occupancy, directly transferring L2's persistence lesson.
- L4: retain both viable orders and combined withdrawal. Demonstrate a
  deliberately safe staged clearance order as well as the efficient preserved
  cover order, so the comparison is planning quality rather than just damage
  from a carelessly executed route. No new major system; Fan was learned in L2.

## Measurement and reduction

Record raw charge/lock endpoints, useful-cover loss, angle/occupancy losses and
recreation, completion time, and multiple effects chained in one commitment.
Do not pretend every reversal or every charge is an error. Rehearsed route
comparison annotates corrective/wasted charges and meaningful decisions with
explicit context; mechanics counters alone cannot infer player intent.

Reduction: keep only Boulders in L2/L4. Retain geometry that enables safe
observation, an alternative action order, or necessary broad traversal. Do not
add hazards, enemies, longer waits, input commands, or tighter windows. Can's
tracking → telegraph → lock → charge → impact → recovery stays identical.

## Acceptance evidence

Run both L3 withdrawals, both L4 orders, full input-only routes, shared-system
fixtures, a wrong-angle/recreation fixture, timing margins, bounded bypass
attempts, feel and recovery checks, and inspect native captures. Compare two
same-state choices in L2 and L4; L3 direction is an additional branch.

Target discovery budgets: L1 45–55 s, L2 55–70 s, L3 65–80 s, L4 75–95 s
(total 240–300 s). These are targets, not measurements. Never pad the demo to
make a stopwatch pass. The hard duration gate needs an independent first run;
do not declare full design acceptance without that evidence.
