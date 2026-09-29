# Final gameplay rescue — pre-implementation audit

2026-09-29. This audit concerns the **current executable**, including the
precision revision, not an earlier design proposal. No gameplay code for this
rescue was changed before this audit was completed.

## Inspection actually performed

Ran the native OpenGL game visibly through all four rooms twice, using normal
player inputs: a stop/inspect/reposition rehearsal and a predictive rehearsal.
Inspected rendered starting, locked, parked, boarding and exit frames. Read the
actors and live world-state traces to explain what was visible. Also reran the
current shallow-input/bounce/exit audit before edits.

These are rehearsals, **not first-time human play**. I cannot personally judge
keyboard feel through these scripts or override the player's report that the
game is unsatisfying. Passing a route is not evidence of strategic depth.

Current rehearsals: L1 2/2 charges; L2 3/3; L3 4/2; L4 4/2. The equal L2
counts expose a real missing lesson: looking ahead does not save an interaction.
The current timing preview also uses Can's old facing while it is waiting for
a new lure. That is misleading precisely when choosing the next direction.

## Per-room audit

### L1 — Direction

- Understand: position chooses Can intent; preparation can track until the
  white lock; a left and a right force impact do different useful things.
- Execute: lure right, leave the charge lane, lure left, ride the broad service
  platform and use ordinary jumps. Two manipulations, no timing puzzle.
- Inheritance: none. This supplies the force and commitment rule used later.
- Randomness: fixed travel and collision stops are repeatable; no actual
  random actor force was observed. Recoil is visual, search stays still.
- Awkwardness: upper observation geometry gives safety but partly hides the
  importance of *remaining* Can position. That belongs in L2, not another L1 task.
- Accidents: ground rebound cannot reach the exit; door and height are real
  geometry. Tested holding right, repeated/random jumps, ignored Can, one lure
  then right, and exit-side rebound did not finish. This is bounded evidence,
  not proof over all input sequences.
- Boulder: absent. Adding one would remove no meaningful decision if deleted.
- Understanding-free wins: not observed; the two opposite effects remain
  necessary to get the route's height. Keep ordinary bounce from bypassing it.
- Difficulty source: simple reading and safe repositioning. Preserve this room
  because its *visible interaction* is a suitable starting point, not its tests.

### L2 — End position

- Understand: x24 weight lowers boarding; moving Can away raises that lift;
  the next parked position supplies a crossing. The player must already board.
- Execute: the current layout always opens the door first, parks left, then
  calls right while boarded. Novice and expert both use three charges.
- Inheritance: L1 direction, white lock, force-operated door and opposite lure.
- Randomness: actual x220 force stop and x24/x272 free endpoints are stable;
  fixed platform travel is trustworthy. Endpoint dependence is real.
- Awkwardness: the crossing footprint begins at x252, excluding the useful
  x220 door-impact endpoint. This makes door-first order effectively mandatory
  rather than offering a worthwhile endpoint plan.
- Accidents: later crossing alone supplies no boarding height. Calling Can
  before boarding raises the empty lift. Random input probes did not finish.
- Boulder: absent; retained actor is not needed for this decision.
- Understanding-free wins: ordinary right traversal is blocked by height, but
  once the one order is found there is little room to improve understanding.
- Difficulty source: mainly following a sequence; endpoint prediction does
  not yet reward foresight with a whole saved future charge. **Must change.**

### L3 — Timing

- Understand: first beam supplies boarding; leave it while boarded; freeze
  second beam before it passes. Starting the lure at alignment is too late.
- Execute: Can x90→x338, then either freeze/return for first boarding or board
  its passing state, then withdraw left early for the final beam.
- Inheritance: direction and committed departure; L2 boarding before spending
  a continuous machine state. This transfer is physical, not a completion flag.
- Randomness: reflected 14°/s phase and actual ray agree; sensors absorb the
  ray before upper traversal; stable final illumination matters, not heat coast.
- Awkwardness: waiting-state lead marker forecasts the *previous* facing,
  although the player may be about to choose the other side. The direction of
  the projected stop is unlabeled. This obscures the delay lesson.
- Accidents: one passing final beam cannot lift the crossing high enough;
  final beam without first boarding cannot provide height. Ground bounce fails.
- Boulder: absent, correctly. No cover decision is needed in this timing lesson.
- Understanding-free wins: a deliberately timed first-pass boarding is valid
  expertise, not an accident to ban with a charge counter. Random jumps did
  not establish both necessary states in the tested probes.
- Difficulty source: anticipation plus boarding setup, with wide surfaces.
  Retain margins; improve visible information and demonstrate a recoverable
  late start using actual inputs. Do not add a third optical objective.

### L4 — Planning / chaining

- Understand: first boarding and final beam plus force door plus sustained
  exit weight. Early door clearance returns Can to x170; reserving it returns
  to x272. The next departure distance differs by about 102 pixels.
- Execute: either secure freeze/return plan works; predicting first-pass
  boarding removes that return cycle. Final right endpoint must preserve weight.
- Inheritance: all prior rules. No new actor or player ability appears.
- Randomness: same Can tuning, physical endpoints and reflected sweep. The
  platform cannot latch a lucky passing beam into a permanent solution.
- Awkwardness: early door clearance gives visible immediate progress but the
  old directional preview fails to explain the later long withdrawal. A
  one-way unlabeled forecast is especially harmful at the x170 return point.
- Accidents: correct beam + open door + wrong final weight cannot reach the
  exit. Height, door and weight each have a physical purpose. Tested shallow
  routes did not finish; no invisible objective prerequisite is added.
- Boulder: absent. Returning it would add cover management without helping
  the existing endpoint/timing plan. Keep it removed.
- Understanding-free wins: final setup requires several retained states, but
  a script knowing the answer cannot show whether the player sees those choices.
- Difficulty source: state planning and different departure delays, not faster
  Can or smaller jumps. Keep both credible plans and show their native runs.

## Bounded implementation decisions

1. Keep the checked stationary search, 0.50 s telegraph, explicit 0.12 s lock,
   248 px charge budget, 0.32 s recovery, fixed vertical rebound, buffered and
   coyote jumps. Audit deterministic/lock/reset behavior again on final code.
   Do not retune working physics to make the rooms look harder.
2. L2: extend the *visible* final crossing weight footprint to include the door
   impact position. Door-first remains valid (160→220→24→272, three charges).
   Boarding-first becomes valid (160→24→220, two): the second charge opens
   the door **and** stays on useful next weight while raising the boarded
   player. Same starting state/information; preparation saves an entire charge.
   No ability, latch, hidden prerequisite or new puzzle object.
3. Make prospective endpoints and withdrawal angles direction-aware, using
   the same actual collision/travel calculation. While choosing, show both
   possible sides; after preparation begins, show the selected forecast;
   after LOCK, show only the committed one. A preview must never mutate facing
   or steer/stop/snap the real laser. Explain the visual legend briefly in H help.
4. Show whether the beam is turning, held on a useful receiver, or held between
   receivers. A miss should invite a normal Can return, not pretend the room
   failed because of physics. Keep real ray and continuous power authoritative.
5. L4: preserve early-door and reserve-door orders. The novice rehearsal uses
   the valid early-door plan; the expert uses advance boarding and reserves
   force for the final right withdrawal. Show both from identical fresh starts.
   Also compare styles with equal inspection delay, so faster button handling
   cannot be the explanation for saved charges.

## Verification and delivery

### Additional observed weakness during targeted play (before its fix)

An input-only attempt started walking left only when the first L3 beam was
already centered. It incidentally boarded the lowering lift, stopped the
laser at 30.27° on the second receiver's edge and then **completed**. The
record is `artifacts/final_rescue/baseline/late_reaction_bypass.json`. This was
not found by the earlier random probes. Adjust the second collector's visible
position enough to separate this reactive overshoot from a useful final beam;
keep its actual window broad and test early/late starts again. Do not prevent
deliberately prepared first-pass boarding with an invisible prerequisite.

- Record fresh final videos under `artifacts/final_rescue/`, preserving prior
  evidence. One full correct run, reactive novice run and predictive expert run
  may share the correct-run file; two styles must each cover all four rooms.
- Input-only routes: both L2 orders, both L4 orders, late-start L3 correction,
  small early/late timing variants. Label arbitrary-state fixtures separately.
- Rerun collision/lock/movement checks, dependency/bypass probes and a full
  open-loop input replay. Measure charges, return/correction cycles, movement,
  waiting, time and real chained effects; never feed these metrics into winning.
- Update Unreleased changelog in the same change and write
  `FINAL_RESCUE_REPORT.md` with concrete level transfers and limits.
- Human acceptance remains open until actual play confirms smoothness,
  readability, gradual subjective difficulty and enjoyment. Do not pronounce
  those qualities proven by automation, or preserve a weakness on that basis.
