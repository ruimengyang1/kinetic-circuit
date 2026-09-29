# Precision, flow and progression — preimplementation plan

Written after inspecting the default scene and all shared actors, running the
current four-room route visibly in Godot, viewing all four starting rooms and
running the existing bounded bypass audit. No gameplay source was changed
before this plan. Baseline source, rendered starts and the new visible route
are preserved in `artifacts/precision_progression/baseline/`.

These are critical code/visual/rehearsed-play observations, not a blind human
playtest. The user's actual play feedback takes precedence over historical
reports or a route script completing. Passing a route proves reachability;
it does not establish fun or learning.

## Current shared problems

- Search walks Can at 84 px/s, including during initial cooldown. Hesitation
  changes its origin, so the apparent same lure has a different endpoint.
- Only 0.20 s of the 0.55 s windup follows the worker; the remaining 0.35 s
  is already locked. The distinction is small and the preview does not account
  for receivers that end the charge. Thus its drawn endpoint can be false.
- Charge expires by time. Sweep tolerance can trigger a force impact before
  actual surface contact, then recover wherever that frame happened to start.
  Search can move the machine again before the player reads that endpoint.
- Rotor occupancy uses partial overlap. Its dial prediction is not exact at a
  negative sweep reflection; coasting and passing platforms affect beam state.
- Player movement already has useful 0.11 s coyote / 0.12 s buffering, strong
  air control, buffered landings and input capture through hit-stop. Preserve
  those. Add floor recovery only where needed; do not increase jump height.
- Automatic top bounce is a fixed impulse and generally useful, but a stomp
  resets preparation on any non-charging Can. Repeated incidental top contact
  can repeatedly restart it. Do not make any required route depend on bounce.
- Boulder is a controlled CharacterBody, not a RigidBody. Its rolling response
  is already signed, but force rejection can reverse it and side/corner contact
  changes the stopping distance. Current rooms use it to remove cover/nozzle
  blockage rather than establish the Can placement lesson requested here.
- The full-room camera is useful: retain it, with bounded impact shake.
- Death restores control in ~0.25 s and R is immediate. Keep retries under
  one second, preserve earlier completions, clear momentum/input state.

## Per-level audit of the current build

| Audit dimension | L1 — How | L2 — Consequence | L3 — Anticipate | L4 — Plan |
|---|---|---|---|---|
| Supposed lesson | Position selects direction, twice; optional service route | Preserve cover versus spend it for air | Hold a rotor, predict withdrawal, freeze useful angle | Preserve rotor position and combine withdrawal with clearing air |
| Actual required actions | Right shutter hit, freight hit, compulsory rebound on the authored direct route, climb | One left Boulder hit plus Fan ascent, or one right shutter hit and short exit approach | Charge onto rotor, withdraw, climb fixed steps and optical crossing | Park, clear/return or time clearance, enter Fan, cross |
| Earlier knowledge actually reused | None | Direction can be used, but one incidental hit is enough | Direction and occupancy; L2 endpoint lesson was optional | Direction, occupancy and optical timing, with an unrelated Fan/Boulder burden |
| Accident / no-understanding win | Service route obscures which first action mattered; one-direction progress opens both direct receivers | Existing audit permits forward, forward+jump and one-bait-forward wins once real force happens; force is not proof of intent | Temporary optical power can move a short crossing before withdrawal; temporary alignment can substitute for understanding persistence | Early Fan opening buys substantial height; bounds must be checked for bounce/temporary-platform shortcuts |
| Inconsistency | Search creep; receiver swept contact versus drawn stopping position; bounce changes preparation | Different Can origin and Boulder stopping corner; cover warning depends on first contact | Pedal partial overlap; asymmetric prediction; retriggering from low observation shelf | Same timing issues plus returning through live Can/air lane; visible baseline route suffered two hits |
| Too-strict timing | Required bounce is execution stress in the introductory room | Leaving covered floor after clearing obstruction adds avoidable hazard pressure | Low perch is still in acquisition lane except when almost directly above Can | Telegraphed return/airflow approach creates avoidable damage during corrective play |
| Meaningless timing / dead time | Waiting after force impacts and compulsory setup for height | One hit followed by unrelated ascent teaches little about endpoint | Brief collector pass may already power the short crossing fully; waiting for a pass can suffice | Waiting/returning is mostly a penalty for the earlier order, not a smooth inherited placement task |
| Independence from earlier rooms | Compulsory bounce competing with direction | Fan and cover grammar replaces the direction/endpoint curriculum | Introduces a weight footprint without L2 having required one | Tradeoff explanation is more elaborate than the actual inherited lessons |

Visible baseline route: L1 5.93 s / 2 charges / 1 compulsory rebound;
L2 4.68 s / 1 charge; L3 8.28 s / 2 charges; L4 11.37 s /
4 charges / 2 hits. These known-solution times are not discovery or enjoyment.
The existing audit explicitly accepts shallow L2 completion. The new baseline
probe saves its actual observations separately, rather than redefining success
as strategic after seeing it happen.

## Scope and decisions

Use the established force-operated shutter/lift, weight pedal, optical
collector, moving platform and Can lure rules. Add no player ability, puzzle
key, hidden completion flag, enemy, random hazard or level-specific Can tuning.
Remove the service alternative/compulsory bounce from L1's required grammar.
Remove Boulder, stationary Laser and Fan from L2; remove Boulder/Fan from L4.
Their obstruction tradeoffs distract from this curriculum. Their source and
historical levels remain; improve controlled Boulder rejection without changing
its force model. No Boulder is needed in the four-room endpoint curriculum.

### Shared precision pass

- Stationary search, no creep. Acquisition requires grounded Can and a readable
  nearby horizontal lane. Safe observation ledges sit above that lane.
- 0.50 s tracking telegraph → unmistakable 0.12 s fixed lock → fast ~300 px/s
  committed charge → impact → 0.32 s recovery. Same values in every room.
- Charge spends a fixed 248 px travel budget; stop at actual walls/receivers.
  Predict the same collision surface for the preview. No physical recoil,
  rebound, sliding or follow after lock. Draw the endpoint, not only an arrow.
- Visible room-end bumpers match collision; no arbitrary level-only Can rails.
- Keep ground acceleration/braking, air control, jump buffering/coyote time and
  fixed vertical bounce. Clear rebound buffers; do not restart a preparation
  repeatedly from harmless descending contact. Required routes use ordinary
  jumps and broad landings.
- Rotor movement uses an exact reflected phase; preview accounts for windup,
  acceleration and actual weight clearance. Fix reflected negative prediction.
  Occupancy must be grounded, stable and match the visible footprint.
- Keep impact hit-stop (~50 ms), particles, sound and light bounded shake.
  Preview and lock cues remain readable during the pause. Restart quickly.

### L1 — Direction (easy)

One clean room, two deliberate opposite lures: right into a tall shutter,
then left into a service lift (either order remains mechanically possible).
The lift makes a broad step onto a high catwalk; the shutter blocks that
catwalk until the right impact. Both are visible physical requirements.
The catwalk/closed shutter exceed jump and ground-Can bounce reach. No Boulder,
Laser, Fan or compulsory bounce. Fixed step beside the lift permits recovery
if the player does not ride its initial rise. Show only the first direction /
lock explanation; the second uses the same cue from another position.

### L2 — Position (easy → medium)

Reuse the right shutter immediately. Its collision creates a known Can origin.
Then lure left so Can ends on a wide, visible weight pedal. The pedal continuously
holds a broad ascent platform at a useful position. Sending Can right again
opens no final route; the projected endpoint visibly misses the pedal.
The route cannot reach its high exit without that platform. Safe perches allow
reading, committing and leaving Can parked without pixel-perfect alignment.
The last interaction explicitly uses a stable Can endpoint on a weight footprint.

### L3 — Timing (medium)

Begin with the same placement problem: a right charge parks Can on the rotor's
weight footprint. A safe perch permits inspection without redirecting Can.
A slow continuous beam and a broad collector show the valid angle. Leaving
freezes the actual angle. Begin the lure before the useful angle arrives,
accounting for telegraph, lock and distance to clear the pedal.
Use an ~1.2–1.4 s physical angle window. The optical crossing's travel and
room geometry prevent its short passing pulse from reaching a viable exit
launch point. Correct frozen alignment sustains it while the player approaches;
traversal during travel prevents a long idle wait. No compulsory bounce.

### L4 — Combination (medium execution, strongest planning)

Reuse the L3 rotor/crossing. A first charge parks Can on a broad pedal.
The useful withdrawal is now rightward: it must both freeze the correct angle
and strike the familiar tall shutter, stopping at its visible bumper. That
endpoint permits a predictable left return onto the pedal if timing was wrong.
A novice may open the shutter first, return Can, inspect and withdraw again.
An experienced player anticipates withdrawal and prepositions into the next
broad step while the same charge opens the shutter. Direction, endpoint and
timing all matter, without introducing an unfamiliar system or tighter jumps.

## Transfers that must remain physical requirements

- **L1 → L2:** position chooses a fixed charge; a force impact supplies a known
  origin. Use the opposite lure again, now landing on a visible weight footprint.
- **L2 → L3:** a useful parked endpoint continuously controls machinery. Park
  on the rotor and choose when to spend that occupancy, rather than treating
  an impact as the entire action.
- **L3 → L4:** start before alignment, because preparation plus clearance takes
  time; freeze actual continuous state. Choose the withdrawal that also hits
  the familiar shutter and leaves a recoverable return endpoint.

## Validation and acceptance

1. Inspect rendered starts, windup/lock, endpoint, useful angle and exit states.
2. Rehearse input-only novice-style (inspect each result; reposition afterward)
   and expert-style (preposition, anticipate, chain) full runs. Capture a full
   native rendered movie; record charges, corrections, waiting, hits and times.
3. Probe holding right, periodic jumps, wandering jump/stomp, isolated Can,
   incidental bounce, one initial bait then forward, and temporary beam power.
   No probe is allowed to win merely because an incidental charge took place.
4. Replay identical inputs and compare actual endpoint/rotor/platform states;
   vary reasonable departure timing and landing positions. Deliberate routes
   must be reliable with hit-stop and real collision enabled.
5. Measure acceleration/stopping, buffered/coyote jumps, bounce impulses, rotor
   prediction, reset time and progression retention. Keep tests separate from
   claims about readability and fun; preserve old evidence as historical.
6. Update Unreleased changelog and README; write the final per-level report
   with measured evidence and any remaining human-validation limits.

No universal mathematical proof against every possible input sequence and no
independent human experience can be claimed from these tools. The acceptance
report must distinguish implemented behavior, observed rehearsal and fresh
human judgment. Changes discovered necessary during implementation must serve
this plan's geometry/precision goals, not introduce another puzzle grammar.

## Revision after actual player rejection — 2026-09-29

The player reports no increasing strategic depth, no increasing difficulty,
and insufficient fun. This overrides the preceding implementation's optimistic
curriculum description. Re-ran the current build visibly before revising it:
every room still needed exactly two charges. L4 merely bundled one extra
effect into the same final withdrawal. Faster rehearsals were evidence of
familiarity with a fixed script, not evidence of more interesting decisions.

### Critical audit of the rejected pass

| Room | Actual decision / remaining defect | Planned correction |
|---|---|---|
| L1 | Two opposite lures. Clear foundation; retain it. | Preserve actor tuning and the easy two-action lesson. |
| L2 | Park left once, then abandon Can permanently. The endpoint's value never has to be spent. | First park lowers a boarding lift. Board before moving Can away; departure raises the occupied lift, while the next endpoint supplies the crossing. Calling early strands the player below: an understandable, recoverable planning error. |
| L3 | One angle, one freeze. No subsequent state depends on that setup. | Two physically separate collectors: first lowers the boarding lift, second supplies the upper crossing. Return Can while aboard; relinquish the first beam to rise, then anticipate a second withdrawal. Freezing only the exit beam cannot supply boarding height. |
| L4 | Same one-angle solution as L3, plus a force hit. | Reuse the entire two-phase route with the familiar force shutter. Either open it during the first withdrawal and return to a different rotor origin, or save that impact for the final withdrawal. Return endpoints change departure distance, useful neutral position and timing. Both plans must be viable. |

### Concrete constraints before implementation

- Keep stationary search, 0.50 s telegraph, 0.12 s lock, 248 px travel,
  0.32 s recovery, movement/jump tuning, bounce and fast retry unchanged.
- No additional abilities, hazard type, completion flag or keyed objective.
  Use existing continuous pressure/optical control and force shutters.
- A lift may have its home high and its powered destination low: this is the
  existing platform's two physical positions, not a new activation rule.
- Upper routes must be above ordinary jump and ground-Can rebound reach.
  The player must acquire boarding height from the first useful state.
- L2 should require three causal charges; L3/L4 four, but charge counts alone
  are not depth. The added demand is preserving player position when spending
  a machine state, then planning the next Can origin and phase.
- Two collectors must have disjoint angular windows. Incidental illumination
  of the second cannot give access to the upper route. Keep a generous final
  timing window and broad lift, shelf and crossing surfaces.
- L4 must have two genuinely different valid plans, rather than a hidden
  mandatory script. Verify both with normal input and actual geometry.
- Shorten empty walks; spend platform travel on boarding, positioning and
  reading the next phase. Do not increase charge speed or shrink jumps.
- Revise the report to explicitly supersede the rejected assessment; retain
  its evidence in `artifacts/precision_progression/feedback_baseline/`.

Fresh player judgment remains the acceptance criterion. Tests will check the
state dependencies, both plans, reasonable timing margins, reliable movement
and shallow bypasses; they cannot establish that this revision is enjoyable.

### Refinement during dependency/flow inspection

The secure L3/L4 plan uses four charges, but requiring that count would prohibit
the requested expertise. A deliberate first-pass boarding may save the two
freeze/return charges. It still requires the actual first collector, an active
boarding move before that state changes, and anticipatory final withdrawal.
Preserve that knowledge-based faster plan; do not introduce a charge counter.

L4's final endpoint must hold the visible exit-lift weight as well as stop the
beam and open the shutter. Thus early clearance returns to x170 and demands a
longer final right withdrawal; reserved clearance returns to x272 and uses a
shorter one. A final left withdrawal with a correct beam leaves the lift low.
This is L2's endpoint consequence applied to L3's ongoing timing, using the
existing pressure/platform rule. Separate boarding bays serve the two return
origins. Collectors absorb the beam before the upper jump route, and the final
crossing rests too low to provide boarding height or a useful temporary exit.
