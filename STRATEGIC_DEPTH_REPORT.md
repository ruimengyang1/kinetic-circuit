# Strategic depth redesign report — 2026-09-29

The current playable demo now progresses through **How → Consequence →
Anticipation → Planning**. Implementation and automated/visual verification
are complete. **Final design acceptance remains pending a blind player, actual
first-run duration, and subjective fun review.** Those are not claimed passed.

The audit in [STRATEGIC_DEPTH_REDESIGN_PLAN.md](STRATEGIC_DEPTH_REDESIGN_PLAN.md)
was completed before gameplay edits. This remains `scenes/final_demo.tscn`;
existing polish, prior pending changes, prototypes and changelog history were
preserved. Can, Player, Boulder and moving-platform actor scripts are byte for
byte identical to the saved session baseline. Only current room composition,
collector margins, stationary-emitter presentation, state recording and beam
projection were changed. No new Player ability, Can power or control was added.

## Level 1 — How

| Required dimension | Result |
|---|---|
| Old version | Short shutter with a worker-sized service gap; either a rightward shutter opening or leftward service lift led to freight. Known route used two impacts, but bypassing the short obstruction obscured the lesson. |
| New version | Shutter reaches the floor and is 78 px tall. Ground route deliberately predicts Can twice: open shutter, then move freight. Left service approach remains valid and physically carries Can to another height. |
| Mechanic used | Position-selected locked force; signed force platforms; existing descending rebound/support carrying. |
| Old knowledge required | None. Observe preview, distinguish tracking from lock, bait and see a physical result. |
| Heuristic used | H1: stand where the force should go, then move after commitment. |
| Heuristic refinement | The chosen impact also determines where Can remains available. Rightward opening keeps it nearer freight; leftward opening supplies an upper approach but requires another setup. This is a seed, not a major optimization puzzle. |
| Strategic choice | Which opening direction supplies the desired next position? After freight moves, keep its nearby Can available for height rather than dragging it away. |
| Execution demand | Two readable baits, a forgiving rebound on the ground route, and broad existing landings. No faster Can, shorter warning or smaller top-contact margin. Second force target repeats bumpers without another tutorial. |
| Novice behavior — expected | Watch an arrow, try a direction, inspect the moving target, then reproduce the prediction with different geometry. May explore the service approach. |
| Experienced behavior — supported | Choose the simpler right opening because its Can endpoint helps the next force/height setup. Alternate service route is still legitimate. |
| Estimated first-time completion | 45–60 s; nominal pacing budget 50 s. Unmeasured. |

Rehearsed ground route: **5.93 s, two charges/two impacts, one rebound, zero
hits**. Alternate service route: **8.78 s, four charges/three impacts, zero
hits**. The two `--expert`/sequential ground runs deliberately share this same
opening; their equal times do not constitute evidence of novice learning.
Bounded forward, jump spam and one-bait-then-forward attempts do not complete.

## Level 2 — Consequence

| Required dimension | Result |
|---|---|
| Old version | Boulder transferred leftward momentum to a duct panel, then clogged the opened nozzle. A second push cleared it; the sequence had one obvious useful endpoint and no preexisting benefit worth preserving. |
| New version | Boulder physically blocks a low stationary Laser and the already-running Fan nozzle. A leftward push opens airflow while removing lower-lane protection. The broad staging shelf permits safe preparation before committing force. |
| Mechanic used | Same H1 Can force; existing signed Boulder rolling, solid optical blocking, airflow obstruction and lift. Stationary Laser shares the existing ray/damage code and has no misleading rotator pedal. |
| Old knowledge required | L1's deliberate direction choice, lock and safe repositioning. No repeated explanation of aiming. |
| Heuristic used | H1 + H2: ask what the obstruction currently provides before moving it. |
| Heuristic refinement | “Move the obstruction to make progress” becomes “prepare a safe position before moving an obstruction that is also cover.” Boulder is solid geometry, cover and nozzle obstruction, not a button key. |
| Strategic choice | Move immediately from the low approach, or first occupy the shelf and spend cover from safety. Leftward movement also places Can away from the ascent. |
| Execution demand | One intentional Boulder displacement and generous airflow traversal. Exposure gives 0.70 s of warning. Safe preparation removes the need to react to the newly exposed beam. |
| Novice behavior — expected | Assume moving Boulder is purely helpful, see airflow open and beam extend, hesitate or take one recoverable hit, then recognize its former cover role. Failure is visible and causal; damage is not compulsory. |
| Experienced behavior — supported | Reach the staging shelf before impact and enter airflow from that prepared position. Same force/action count, better damage outcome. |
| Estimated first-time completion | 60–75 s; nominal budget 65 s. Unmeasured, and this short room particularly needs pacing review. |

Reactive rehearsed route: **6.73 s, one Boulder push, one hit**. Prepared route:
**6.18 s, one Boulder push, zero hits**. Controlled fixtures hold the same
player horizontal position and apply the same Can force: the low player takes
a hit after warning; the raised player stays unharmed. Both open airflow.
Three repeated identical force setups settle Boulder at the same endpoint
within 0.01 px. This is one fair expectation reversal, not an invisible trap.

## Level 3 — Anticipation

| Required dimension | Result |
|---|---|
| Old version | Occupancy rotated Laser at 18°/s; leaving froze it. The initial Can push also prepared a Boulder landing. A 30 px receiver gave a measured 25.75° / 1.43 s optical traversal. |
| New version | Preserve the same approach, prepared Boulder step and continuous crossing. Increase the collector radius to 36 px, retaining real ray contact, bounded sweep and physical stopping preview. |
| Mechanic used | Same Can force/position; previously learned Boulder resulting position; continuously weight-held Laser and heat-driven moving crossing. |
| Old knowledge required | H1 to place/withdraw Can; H2 to prepare the Boulder landing and leave useful states intact. |
| Heuristic used | H1 + H2, refined by H3: begin withdrawal before the ideal beam state. |
| Heuristic refinement | “Wait for alignment, then act” becomes “include repositioning, Can acquisition, windup and pedal clearance in the plan.” The beam's aligned state is the result of earlier action. |
| Strategic choice | Which Boulder endpoint supports the next landing, and when/where should Can leave so both frozen beam and follow-up route remain useful? |
| Execution demand | Actual optical window **31.25° / 1.74 s**. Five tested early leads (8°, 12°, 18°, 24°, 28°) work; starting at center or 2° after it does not sustain alignment. No frame-perfect withdrawal or angle snap. |
| Novice behavior — expected | Prepare/observe one state at a time, begin too late, identify overshoot, then start earlier on correction. |
| Experienced behavior — supported | Arrange the Boulder during the same placement charge; depart before beam contact and move toward the prepared landing as the world settles. |
| Estimated first-time completion | 70–90 s; nominal budget 75 s. Unmeasured. |

Sequential rehearsed route: **8.27 s**. Earlier prepared withdrawal: **7.83 s**.
Both use two charges/one Boulder push and take no damage. Event order differs:
the sequential rehearsal locks withdrawal after collector contact; the earlier
rehearsal locks before contact. Controlled center-start fixtures demonstrate the
overshoot that those already-informed successful rehearsals do not contain.

The prepared Boulder is the **one secondary consequence**. No extra hazard,
airflow device or automatic Can lift was added to this room.

## Level 4 — Planning

| Required dimension | Result |
|---|---|
| Old version | Low Laser, obstructing Boulder and Fan, then sensor-driven crossing plus a warned Can lift. Automatic lift removed weight for the player. First clear-cover order was dominant; the elevated threat/linkage arrived as a new mastery-room surprise. |
| New version | Same Can/Boulder/Fan/rotator/crossing, with raised emitter, broad collector, high left observation shelf, low right bait shelf and traversal below the useful beam. Remove the automatic Can lift and fill its former floor gap. Two action orders genuinely complete. |
| Mechanic used | Only established rules: stable charge endpoint, signed Boulder force, beam cover, airflow obstruction, occupancy rotation, delayed withdrawal, direct optical crossing. |
| Old knowledge required | All three heuristics from L1–L3. The final room adds no device or power. |
| Heuristic used | H1 chooses force location; H2 treats cover/nozzle/Can positions as resources; H3 prepares departure before alignment. |
| Heuristic refinement | “Opening airflow is useful” and “keep Can available on the rotor” compete. Separate useful actions can be combined by planning the final Can commitment. |
| Strategic choice | Clear Boulder first and bring Can back, or retain Boulder, park Can deliberately on rotor, aim away from the low lane, then withdraw right so one charge freezes Laser and clears airflow. |
| Execution demand | Actual optical window **27° / 1.69 s**. Prepared routes using departure leads 8°, 14°, 20° and 24° all complete with zero hits: tested start times span one second. No rebound is needed by either final route. |
| Novice behavior — expected | Push the obvious obstruction, inspect the new danger, return Can to the rotor, align, withdraw, traverse. Corrections can be made one state at a time; a demonstrated reactive route survives one hit without a retry. |
| Experienced behavior — supported | Use an initial leftward charge to establish a known endpoint. Next rightward charge ends on the pedal before Boulder. Observe above the acquisition lane; bait right early so departure, Boulder force and nozzle clearance are one continuing commitment. |
| Estimated first-time completion | 90–120 s; nominal budget 100 s. Unmeasured. |

| Normal-input strategy | Charges | Boulder pushes | Hits | Rebounds required | Time |
|---|---:|---:|---:|---:|---:|
| Clear cover first, solve remaining states | 4 | 2 | 1 | 0 | 14.30 s |
| Preserve Boulder, combine withdrawal/force | 3 | 1 | 0 | 0 | 11.23 s |

The improvement is **different order and fewer state changes**, not just a
faster input sequence. The expert intentionally charges left despite eventual
progress being rightward: the endpoint determines where the next charge stops.
The novice spends Boulder position and leaves Can beyond the rotor, requiring
return travel. The expert keeps Boulder available until the beam has been aimed
away from the low lane, then spends Can occupancy and Boulder cover together.

As Laser rotates upward it ceases to need Boulder as optical cover **before
the Boulder physically moves**. The report does not claim the beam remains
blocked throughout setup. Preserving the Boulder preserves nozzle obstruction,
future low-angle cover and the ability to combine the final interaction.
After the push, Can ends near the shifted Boulder while Player uses the safe
upper route; descending into that lane unnecessarily would create another bait.

## Characteristics

| Characteristic | Final behavior |
|---|---|
| Stochasticity | Low. Shared fixed actor parameters, signed friction-driven rolling, bounded rotation, physical contact. Random particles do not affect mechanics. Identical fixtures have identical endpoints; arbitrary inconsistent inputs need not produce identical states. |
| Observability | Full-room camera shows actors, beam, collector, occupancy and destinations. Can tracks then displays locked intent; falling/rebounding actors remain visible. Solid beam is active, faint dashed continuation shows the space protected by a heavy blocker; warning brightens exposure. Fan visibly sputters under obstruction. Stop diamond includes remaining windup and clearance, but is a preview, not an auto-solver. |
| Time granularity | Real time, normally 60 physics ticks/s. Windup 0.55 s including 0.35 s locked warning; charge 230 px/s with 0.10 s ramp; recovery 0.20 s. Rotation L3 18°/s, L4 16°/s; collector briefly coasts 0.28 s. Broad windows and safe observation provide thinking time. |
| Single / one-and-a-half player | One human-controlled worker plus one autonomous adversarial Can. Can is not a second commandable avatar: its stable reaction converts worker position into intent and force. The player reasons about another actor's future action. |
| Systems | Position, weight, force, beams, airflow and support share real world state. The same Boulder can be cover, obstruction and a landing; the same Can can be danger, force and rotor occupancy. No hidden completed-puzzle flag is required to exit. |
| Dexterity vs strategy | Dodging, movement and bounce still provide tension. Player response, coyote/buffer, air control and rebound margins are unchanged. Final success routes do not require rebound timing; better preparation changes exposure, action count and order. Human judgment of this balance remains pending. |

## Reusable heuristics

**H1 — Read intent:** my position controls where Can force appears. L1 teaches
tracking versus lock and both directions; L2 uses leftward force; L3 uses
placement then withdrawal; L4 uses an initial left setup and a combined right
commitment. Keeping away at all times is refined into choosing deliberate safe
acquisition positions and moving after lock.

**H2 — Think about resulting state:** before moving something, inspect its
current jobs and its endpoint. L1 seeds Can availability. L2 challenges the
“obstacle means progress” assumption with lost cover. L3 requires the prepared
Boulder step. L4 preserves Boulder and rotor occupancy until a useful order
can spend them together. Current usefulness and future usefulness can conflict.

**H3 — Plan before the desired state:** actions have delay, so prepare early.
L3 exposes center-start overshoot and rewards a range of earlier starts. L4
adds approach travel and a force consequence to that same delay; freezing the
beam and clearing the nozzle become the result of one earlier spatial plan.

## System relationships

- **Conditional:** a signed Can hit moves a force receiver; supported heavy
  occupancy rotates Laser; exposed air applies lift. Each uses continuous
  geometry/contact rather than an object's special puzzle ID.
- **Combination:** L2 Can + Boulder + Laser + Fan opens ascent while losing
  cover. L3 the placement charge both prepares Boulder and occupies the rotor.
  L4 the withdrawal charge simultaneously fixes beam state, rolls Boulder and
  opens airflow; neither timing nor displacement alone supplies that result.
- **Feedback:** Player position → Can intent → charge/impact/occupancy → beam,
  cover and airflow → Player's new safe position → next Can intent. Standing
  too low after a useful action can spend an additional charge; staying above
  the acquisition lane preserves an intended configuration.
- **Resource:** Can's location and occupancy, Boulder position and cover, and
  the frozen beam angle are useful states that can be kept or spent. Moving
  Boulder early gains access but loses cover and leaves Can needing a return
  trip. Keeping Can on the pedal gains continuing control but withholds its
  next force until the correct time.

## Verification and evidence

Evidence directory: [artifacts/strategic_depth](artifacts/strategic_depth/).
`comparison.json` contains strategy metrics and unchanged actor-source checks;
`systems.json` contains controlled fixtures, windows, withdrawal leads and
determinism. Route JSON contains normal input traces and events. Screenshots
include fresh layouts, L2 cover loss, L3 preview/alignment and the L4 combined
withdrawal. Baseline source/layout/route is in `baseline/`.

- **45 strategic system checks pass:** consistent Can loop in all rooms,
  repeatable signed endpoints, cover/exposure versus prepared safety, nozzle
  clearance, actual optical windows, center/early withdrawal, continuous
  occupancy and absence of the final automatic lift.
- **26 bounded input/flow checks pass:** forward, jump spam and one-bait
  attempts in all four rooms, two additional leftward L2 attempts, actual
  landing exits, victory/replay, local retry and death progression preservation.
  This is a bounded audit, not an exhaustive proof against every possible skip.
- **29 existing feel checks pass**, with only the Fan fixture updated to use
  its current position and remove the obsolete duct lookup. Input buffering,
  coyote time, release, swept rebounds, support, camera/effect budgets and retry
  behavior remain covered. One initial test invocation stopped at that obsolete
  lookup; the fixture was corrected rather than restoring an unwanted device.
- **14 recovery checks pass.** Death control return remains under 0.3 s;
  current-level R retains prior completions. Success transition remains 0.65 s.
- Full four-room sequential and prepared input-only routes pass. Both rendered
  runs match their headless outcomes. Alternate L1 service route passes. Fresh
  L2/L3 runs, both L4 orders and three additional prepared departure-lead
  variants pass.
- The unchanged objective-free sandbox runs 30 simulated seconds with **12
  charges, two rebounds, zero hits/deaths/resets**. It supports preservation of
  response/behavior; it does not establish enjoyment or sound quality.
- Fresh and consequential screenshots were inspected at the same 640×360
  framing. Photography pauses simulation while awaiting rendering, avoiding
  uncontrolled gameplay between recorded inputs. `git diff --check` passes.

### Geometry corrections during validation

The first low-emitter L4 prototype made rightward bait cross Laser and let a
ledge clip the nominally useful angle range. Raising the mast and collector,
removing the automatic lift and arranging traversal below useful beam states
resolved these issues without modifying Can/Player behavior. The final emitter
is 172 px above its pedal; initial downward beam actually hits ground Boulder;
aligned beam reaches the high collector while worker traverses below it.

The plan allowed geometry revisions if the combined charge failed. It was also
necessary to move the observation shelf left of the mast and keep a distinct
low bait shelf. Waiting on a low shelf after placing Can had automatically
started another charge; the high shelf now supports actual observation outside
the unchanged 52 px vertical acquisition lane. These are spatial planning
affordances, not per-level AI exceptions.

## Blind first run and experienced second run

**No valid blind run occurred.** macOS screen-capture and event-posting
preflight both returned false. Native Godot rendering/input scripts are
available, but GUI observation plus normal desktop control is not. The author
also read the level design during the required audit, so authored routes cannot
be relabeled as blind AI discovery.

| Requested observation | Blind first run | Experienced second run |
|---|---|---|
| First assumption/action | Unobserved | Unobserved by an independent player |
| Hesitation/failure | Unobserved | Unobserved |
| Revised strategy | Unobserved | Unobserved |
| Completion time | Unmeasured | Unmeasured |

The two rehearsed strategies provide **functional evidence that more intentional
play is possible**, especially fewer forces and no damage in L4. They do not
prove that a novice spontaneously learns that plan or looks different on replay.
A blind tester should record those four fields per room, then replay immediately
and explain H1/H2/H3 in their own words. The critical second-run observation is
whether they preserve Boulder and arrange Can's endpoint before withdrawing,
not whether their walking happens faster.

## Duration and final pass/fail gates

Nominal discovery budgets total **290 s (4 min 50 s)**. The requested room
ranges total 265–345 s, so target their lower-middle. No time locks, corridors,
extra enemies or mandatory repetitions enforce that budget. Known-solution
routes total roughly **35 s sequential / 31 s prepared**, excluding transitions.
These short feasibility times cannot validate a 4–5 minute first encounter.
L2 may still be shorter than intended after its consequence is understood;
that concern remains open for the blind pacing test.

| Gate | Verdict and evidence |
|---|---|
| 1. Consistent Can behavior | Passed functionally: unchanged source and same loop tested in every room. |
| 2. No major Player ability | Passed: unchanged Player source/controls. |
| 3. L2 requires L1 understanding | Supported: same deliberate direction/lock; bounded shallow attempts fail. |
| 4. L3 requires L1 + L2 | Supported: Can placement/withdrawal and prepared Boulder endpoint both used by normal routes. |
| 5. L4 has no major new mechanic | Passed: established objects only; removed automatic lift linkage. |
| 6. A heuristic is challenged/refined | Supported: obstacle-as-progress becomes cover-as-resource; center reaction becomes early withdrawal. Human comprehension pending. |
| 7. Action has benefit and future cost | Passed functionally: L2 moves obstruction/open air while exposing beam; L4 early displacement requires Can return before rotation. |
| 8. Later difficulty is conceptual | Supported by unchanged speed/warning, broad optical margins and zero-rebound L4 strategies; perceived balance pending. |
| 9. Replay shows planning, not memorization | Different intentional routes demonstrated; **actual blind first/second comparison pending**. |
| 10. Player explains 2–3 heuristics | Curriculum and transfer implemented; **independent explanation pending**. |
| 11. Approximately five-minute demo | Nominal budget 290 s; **actual novice duration pending**. |
| 12. Fun and responsive | Response regression/sandbox evidence passes; **subjective enjoyment/audio review pending**. |

The redesign is not declared fully accepted until the pending player gates pass.

## Why does thinking more make the player better?

Because the same input can leave very different useful states. In L2, thinking
before the push preserves health without reducing the number of pushes or
reacting faster. In L3, estimating delay changes the frozen angle; moving at
the visually perfect moment is worse than preparing earlier. In L4, the expert
recognizes that Can's first endpoint can reserve its next charge for the rotor,
then recognizes that withdrawing toward Boulder accomplishes two required
interactions together. The demonstrated improvement removes an entire charge,
one unnecessary Boulder displacement and a damage event. It requires no final
precision bounce and works over multiple departure times.

The player gains no strength. They learn to ask **where force will appear,
what state will remain, and whether spending that state now improves the next
two decisions**.
