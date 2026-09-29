# Level progression redesign report

2026-09-29, revision 2. **L2 and L4 have been rebuilt after human play rejected
the previous revision's perceptibility.** Their old authored tradeoff tests
were insufficient grounds for retaining those layouts. The saved rejected
[layout and report](artifacts/level_progression/revision2/baseline/) remain
available; the preimplementation audit is in
[LEVEL_PROGRESSION_REDESIGN_PLAN.md](LEVEL_PROGRESSION_REDESIGN_PLAN.md).

The implementation is ready for another playthrough. Full design acceptance
remains open: a fresh human run must establish whether the choices and learning
curve are perceptible, and whether first-time completion stays near 4–5 minutes.
The checks below establish physical consequences, recovery and feasibility.
They do not establish those human outcomes.

## What changed in the actual rooms

L2 now has two spatially distinct routes, simultaneously visible from a safe
starting shelf. Rightward Can force raises the familiar L1 shutter: the ground
route opens while Boulder remains cover. Leftward force moves Boulder behind
the Laser: the upper Fan route opens while the lower approach becomes exposed.
The choice leaves a different route, Boulder position, Can endpoint and beam
state. It is no longer two staging variants of the same ascent.

L4 now starts with one ordinary charge parking Can on a broad visible pedal,
before Boulder. The player can open air immediately and reach a right-hand
observation ledge facing an unavailable crossing, or preserve rotation and
prepare that crossing before withdrawing Can. The prepared withdrawal also
moves Boulder and opens air. An early withdrawal can be recovered by bringing
Can back to the pedal. The long air shaft and stair stack have been replaced
with a short, wide boost and broad landing; the ready crossing is below that
landing, so good planning does not demand an extra upward precision jump.

Rotator artwork now shows its actual weight footprint. Fan artwork follows
its physical plume width, including a dim outline of blocked airflow. L2's blocked
beam shows its protected ground span; the span disappears when the actual ray
loses cover. These cues show states without explaining the heuristics in text.
No Player or Can AI tuning, Boulder physics, optical rules, Fan force, controls,
enemies, hazard count or transition rules were changed. L3's earlier Boulder
removal and optional endpoint choice remain.

## Level 1 — How

| Required dimension | Current design |
|---|---|
| Previous version | Two signed-force interactions: opening, then freight. Optional service lift; no Boulder. This was already a simple introductory room. |
| New purpose | Keep the foundation: manipulate Can deliberately, then apply the same rule at a second receiver without another tutorial explanation. |
| Required prior knowledge | None. |
| New heuristic | H1: my position controls Can intent. A first hint that Can's endpoint helps the next interaction. |
| Strategic decision | Open the right shutter, keeping Can near freight, or use the left service lift and approach from above. This is a light tutorial alternative. |
| Immediate benefit | Either opening supplies access. |
| Future cost | The service route changes Can's height and next setup; the right route leaves a convenient ground force/rebound position. No heavy novice penalty. |
| Boulder role / removed? | Absent. None added. |
| Novice behavior, expected | Bait, observe commitment, then deliberately apply the rule again at freight. |
| Experienced behavior, authored | Choose an opening that leaves Can useful for the freight interaction. |

The direct route still requires two charges/two force impacts. Both the direct
opening and the service alternative complete. L1 is intentionally a tutorial;
it does not carry the main strategic-depth claim.

## Level 2 — Consequence

| Required dimension | Current design |
|---|---|
| Previous version | Boulder covered a Laser and blocked a Fan, but both tested choices converged on the same ascent. Normal successful play quickly abandoned the exposed floor. Human play did not perceive the intended tradeoff. |
| New purpose | Make preserving versus spending the obstruction create visibly different routes and future states. |
| Required prior knowledge | L1's position-selected direction, commitment and familiar force shutter. The first action asks for that knowledge immediately; Can aiming is not retaught. |
| New heuristic | H2: a useful state may be worth preserving. H3: immediate access can remove a useful fallback. |
| Strategic decision | Send Can right to open the ground shutter and preserve Boulder, or left to open the upper route and leave Can behind the emitter. |
| Immediate benefit | Moving Boulder immediately opens airflow and the upper route over the closed shutter. |
| Future cost | The previously protected ground approach becomes a live beam lane. The familiar ground route remains closed, and low observation/return is no longer safe. Keeping Boulder instead leaves upper air unavailable and Can nearby in the ground approach. |
| Boulder role / removed? | Kept, repositioned: actual Laser cover AND blockage of the nozzle/upper traversal. Its unmoved state already has value. |
| Novice behavior, expected | Move the apparent obstruction to reveal the upper route, then see that the lower safe area was also spent. The reversal is visible and logical, with the existing warning. |
| Experienced behavior, authored | Choose the route and Can endpoint together: preserve cover for a ground approach, or deliberately spend it to take the upper route while leaving Can remote. |

Both routes complete from the same spawn with one charge and no hits. Upper
clearance leaves Boulder near x=181 and Can near x=209; the shutter stays shut.
The ground choice leaves Boulder at x=300 and parks Can near x=468 after raising
the shutter. The upper route removes nearby Can exposure but spends lower-lane
cover. The covered route is shorter in the authored run, but keeps a live Can
near traversal. These are different states, not an assertion of equal efficiency.

The stationary emitter is already visible, with a dashed continuation behind
Boulder. Moving the rock does not introduce or randomly activate a new hazard.
The existing cover-loss warning remains. The upper route cannot be reached by
an ordinary jump from the starting observation shelf; the lower route requires
force on the shutter.

Rendered outcomes:
[covered ground route](artifacts/level_progression/revision2/screenshots/expert_L2_preserved_ground.png),
[cover spent / upper air open](artifacts/level_progression/revision2/screenshots/L2_cover_spent_air_open.png).

## Level 3 — Order / timing

| Required dimension | Current design |
|---|---|
| Previous version | A prescribed Boulder push made a landing step while parking Can. The initial Boulder state had little value to preserve; it was scaffolding. |
| New purpose | Remove that Boulder and make withdrawal choose both the stored Laser angle and Can's future availability. |
| Required prior knowledge | H1 to park and withdraw Can; L2's state-preservation lesson to recognize that moving again can spend a useful configuration. |
| New heuristic | Act before the state you want. Begin H4: arrange the next interaction while solving this one. |
| Strategic decision | Withdraw left for a quiet stepped approach, or right to leave Can beside the crossing for an optional rebound; choose the departure time in either case. |
| Immediate benefit | Both directions can freeze a useful angle and sustain the crossing. Right also makes Can available for traversal. |
| Future cost | Left gives up nearby rebound/control availability. Right leaves a live Can in the approach; returning low can accidentally charge it back over the pedal and spend alignment. |
| Boulder role / removed? | Removed. Its compulsory landing function was replaced by a fixed 36-pixel service step. |
| Novice behavior, expected | React at apparent alignment, discover the withdrawal delay, and recreate occupancy; choose the quieter approach if desired. |
| Experienced behavior, authored | Start early and choose the endpoint for the next traversal, preserving the useful angle by staying above acquisition height. |

Both withdrawals complete with two charges and no damage; the right route uses
an endpoint rebound and the left route does not. The rebound is optional.
Rotation remains 18 degrees/second, with a ray-tested useful window of 31.25
degrees, approximately 1.74 seconds. The camera shows Can, emitter, collector
and crossing together. A wrong-angle attempt can restore occupancy; death
restores current-level control in approximately 0.25 seconds.

## Level 4 — Planning / tradeoff

| Required dimension | Current design |
|---|---|
| Previous version | The clearance/preservation orders existed in scripts, but the initial setup was opaque and their strategic difference was not perceptible in human play. A long air shaft and stair stack obscured the resulting states. |
| New purpose | Start at an intelligible common control state, then make early access versus a prepared crossing produce different visible outcomes. |
| Required prior knowledge | L1 direction and endpoint control; L2 the blocked nozzle/access consequence and useful-state preservation; L3 occupancy, anticipated withdrawal and persistent angle. |
| New heuristic | H4: set up the next interaction while solving the current one. Choose the future state before spending Can's position. |
| Strategic decision | From Can parked on the pedal, open air now and inspect from the right ledge, or keep rotation until an early departure can prepare the crossing and open air together. |
| Immediate benefit | Early withdrawal opens air and reaches a new high observation position immediately. |
| Future cost | It freezes a low, unhelpful beam; the crossing stays parked away from the exit gap, and Can ends away from control. Completing requires returning Can and withdrawing again. Preserving control delays access and requires anticipating the coupled outcome. |
| Boulder role / removed? | Kept, in a rebuilt room: initial beam cover AND nozzle/traversal blockage. Its displacement opens air and determines the right-hand Can endpoint. |
| Novice behavior, expected | Open visible air, reach the ledge, observe the empty gap, then restore control and solve alignment separately. This order can finish. |
| Experienced behavior, authored | Leave Can on the pedal, anticipate departure, and use one withdrawal to freeze useful alignment, displace Boulder and open the next traversal. |

The first right charge ends near x=284 on a wide pedal before hitting Boulder.
Both plans reach that exact same common state using identical inputs. Early
withdrawal freezes about 23.73 degrees; the right ledge faces an empty crossing
gap. A left corrective charge ends near x=173 on the pedal, restoring control
without a precise parking input. Prepared withdrawal freezes about 4.27 degrees
and leaves Can near x=433, opening air while the crossing moves into place.

The early order completes in four charges, with one corrective return and a
subsequent withdrawal; the prepared order takes two. The authored early run
takes two hits and no death; the prepared run takes none. Those hits are a
cost of this demonstrated route, not evidence that damage is mandatory or a
substitute for the actual correction cost. Both orders are recoverable. The
prepared order is more efficient; the early order buys immediate access and
separate observable steps. Equal efficiency or spontaneous novice discovery
has not been claimed.

**Cover is not preserved throughout aiming.** The rotating ray leaves Boulder
cover before the rock moves. In the shared choice, the state being preserved
is Can's occupancy and continuing rotation. Initial rock cover and nozzle
blockage are distinct physical roles; the efficient plan's advantage comes
from retaining control, then chaining clearance, rather than a fictitious
continuous cover state.

L4 introduces no new mechanic and requires no rebound. Rotation remains 16
degrees/second. The actual useful window is 26.75 degrees, approximately 1.67
seconds, essentially the previous 1.69 seconds. Prepared input routes work at
20-, 24-, 28- and 32-degree early departure leads. No faster Can or narrower
execution requirement supplies the new difficulty.

Rendered states:
[shared choice](artifacts/level_progression/revision2/screenshots/L4_shared_choice.png),
[early air / empty gap](artifacts/level_progression/revision2/screenshots/L4_early_air_gap.png),
[prepared crossing](artifacts/level_progression/revision2/screenshots/expert_L4_ready_crossing.png).

## Explicit progression

| Level | Reuses | Learns / adds / combines |
|---|---|---|
| 1 — How | No prior knowledge | Position selects Can intent; apply it twice; notice the endpoint. |
| 2 — Consequence | L1 direction, commitment, familiar force receiver | Preserve or sacrifice a valuable state; choose between different routes and Can endpoints. |
| 3 — Order / timing | L1 placement; L2 persistence and preservation | Anticipate withdrawal delay; preserve a useful beam state while choosing future Can availability. |
| 4 — Planning / tradeoff | All three lessons and familiar Fan, Laser, collector and crossing | Choose action order; combine timed withdrawal with clearance, or recover after early access. |

### Why does Level 4 only make sense after Levels 1–3?

L1 makes the first parking charge an intentional placement rather than an
accidental attack. L2 makes the blocked nozzle a state to evaluate rather than
a puzzle key to clear automatically: opening access changes what remains
useful. L3 explains why Can should remain on the pedal, why leaving freezes a
persistent angle, and why departure must begin before apparent alignment.

Together these lessons explain the final-room decision: keep a useful Can
position long enough to prepare the crossing, then spend that position in a
charge that also opens air. Without H1 the endpoint is accidental; without L2
immediate clearance seems automatically good; without L3 the player lacks the
model for the angle and delay. These are learning dependencies, not hidden
prerequisite flags. A player who already understands all mechanics still must
choose whether to take access early or prepare its next state.

## Reduction pass

| Object/group | What disappears if removed? |
|---|---|
| L1 force opening and freight | The first and second deliberate applications. The optional service opening changes endpoint/height without another mechanic. |
| L2 Boulder | Initial cover and nozzle obstruction; the route-state sacrifice disappears. |
| L2 Laser | Moving Boulder no longer spends ground safety. |
| L2 familiar shutter | The distinct covered ground order disappears; both choices again converge on air. |
| L2 Fan and upper landings | The cover-spending alternative disappears. |
| L2 observation/bait shelves | Deliberate direction selection and safe inspection before commitment. |
| L3 Boulder | Removed: only prescribed scaffolding was lost. Fixed geometry supplies ordinary traversal. |
| L3 rotor, collector and crossing | Anticipation, persistent optical state and its traversal consequence. |
| L3 step/ledges | The quiet alternative to using Can's right endpoint and broad continuation. |
| L4 Boulder and short Fan | The blocked/open traversal state coupled to Can withdrawal; initial beam cover. |
| L4 wide pedal, collector and crossing | The preserved-control order, corrective return and visible prepared/unprepared gap. |
| L4 high/low observation and bait ledges | Observe without consuming Can occupancy; deliberately select departure and broad landing. |
| L4 long shaft and stair stack | Removed. No strategic decision depended on their traversal length. |

Only L2/L4 retain Boulder. No extra switch, collectible, enemy, beam or major
system was added. L2's shutter reuses L1's force receiver. L4 uses Can, Boulder,
Laser/Rotator and the Fan already encountered in L2, with its existing optical
crossing. Ordinary supports were kept for observation, direction choice and
forgiving traversal.

## Same-state comparisons and strategic metrics

L2's alternatives begin at the same spawn. L4's alternatives additionally
share the exact first charge and parked-Can decision state. Expected novice
choices pursue visible access; an informed player can instead preserve a
useful future state. The distinction is action choice and resulting state,
not merely executing the same inputs faster. These are authored comparisons,
not measurements of novice/expert people.

[comparison.json](artifacts/level_progression/revision2/comparison.json) records
times, endpoints, cover loss, state recreation, chains and explicitly annotated
corrections/order branches. Runtime logs include charge IDs and actual air
opening. A useful chain requires one charge to withdraw from aligned control,
transfer force and open previously blocked air; redundant re-hits do not count.

| L4 authored plan | Charges | Corrective returns | Avoidable charges versus prepared order | Whole unnecessary charges | State recreations | Useful chains | Tested order decisions | Time |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Early air, then restore control | 4 | 1 | 2 | 0 | 1 | 0 | 1 | 11.37 s |
| Preserve rotation, then chain | 2 | 0 | 0 | 0 | 0 | 1 | 1 | 8.55 s |

Early charge 4 re-hits an already-cleared Boulder, but its withdrawal is needed
in that resulting state. Calling the whole charge unnecessary would confuse
a correction cost with a useless input. Charges 3/4 are avoidable relative to
the better initial order. Both plans record one cover loss during rotation;
this is neither automatically a mistake nor proof of a cover-preservation plan.
No previous cover state is recreated in these demonstrations.

## Implementation checks and limits

Evidence is under [revision2](artifacts/level_progression/revision2/).
Old evidence remains historical. Native rendered runs inspect the actual
shared choices and outcomes; input-only routes verify that both alternatives
can complete. System fixtures are separate from player routes.

Shared actor/optical checks, state checks, bounded bypass/transition checks,
movement/feedback checks and recovery/exit checks pass. Both full routes,
both L3 endpoints, the L1 service alternative and the broad L4 early-departure
samples complete. Bounded bypass probes are not an exhaustive proof of every
possible shortcut. L2's forward ground completion is valid when its charge
actually opens the familiar shutter; it is not rejected merely to require
more actions.

Known-solution totals are 30.26 seconds for separate-step play and 25.88 for
prepared play, excluding transitions, versus the rejected revision's 35.25 /
31.63 seconds. The redesign does not lengthen those authored routes. They do
not measure first-time discovery. The target remains 240–300 seconds across
all four rooms including observations/retries; no corridors or waiting gates
were added to manufacture that duration.

## Hard acceptance status

| Requested gate | Evidence / status |
|---|---|
| L2 requires L1 | Directed force and the known shutter begin the new route choice. Functional dependency implemented. |
| L3 requires L1 + L2 | Intentional placement plus preservation/recreation of persistent state. Human transfer still needs observation. |
| L4 requires L1 + L2 + L3 | Placement, access consequence and anticipated withdrawal combine in the prepared order. Human recognition still needs observation. |
| Boulder only strategically necessary; each has two roles | Only L2/L4; actual cover plus nozzle/traversal blockage. Their human value must be judged in play, not inferred from ray fixtures alone. |
| Two important states offer multiple plausible actions | Distinct L2 route states and L4 shared parked-Can orders implemented and rendered. Plausibility to a fresh player remains unconfirmed. |
| Immediate benefit plus future cost | L2 upper access spends lower safety; L4 early access spends control and leaves the crossing unavailable. |
| Can final position matters | Different L2 routes, L3 availability, L4 occupied versus remote control endpoints. |
| Later difficulty is not mainly dexterity | Stable tuning, broad traversal, slow rotation and multiple successful departure leads. Human experience remains the deciding check. |
| L4 introduces no major mechanic | Implemented using familiar systems only. |
| Expert differs through decision quality | Authored prepared order removes a corrective return/recreation and adds a useful chain. Independent novice/replay observation pending. |
| Whole demo approximately 4–5 minutes | Unverified; requires a first-time human run. |

The previous human rejection is not erased by passing checks. This revision
changes the physical choices and visible results that prompted it. Full
redesign acceptance stays open until fresh play confirms the learning curve,
meaningful choices and pacing.
