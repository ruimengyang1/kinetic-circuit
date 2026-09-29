# Precision, flow and progression — implementation report

The current default four-room prototype now follows **Direction → Position →
Timing → Combination**, using its existing lure, force receiver, weight,
rotator, collector and platform rules. No major mechanic, player ability,
completion key or prerequisite flag was added.

The preimplementation audit is in `PRECISION_PROGRESSION_PLAN.md`. The original
build was run visibly before gameplay edits. Its source, starting views,
actual visible route and accidental-win probes are preserved under
`artifacts/precision_progression/baseline/`. The baseline L2 completed with
holding right, repeated rightward jumps and wandering jumps. An incidental
force event was sufficient; the old test's acceptance of that event did not
make the level strategic.

Implementation and correctness verification are finished. Independent human
acceptance of feel, readability, learning transfer and difficulty remains open.
The measurements below establish behavior and feasible routes, not fun.

## Shared precision and feel

| Area | Final behavior and evidence |
|---|---|
| Movement | Preserved quick ground response, air control, 0.11 s coyote and 0.12 s buffering. Full useful speed and reversal within 100 ms; measured braking distance 5.06 px. Retained buffered landings/input capture through hit-stop. |
| Landing/corners | 4 px floor snap and 0.04 safe margin. Continuous opening catwalk removes a narrow falling gap. Thin non-force moving platforms accept jumps from below. Tested jumping through an underside and leaving moving support with the ordinary impulse. |
| Can rhythm | Stationary SEARCH → 0.50 s tracking TELEGRAPH → distinct 0.12 s fixed LOCK → fast CHARGE → IMPACT → 0.32 s RECOVER. Same tuning in every room. No search creep or post-lock tracking. |
| Can travel | Fixed 248 px budget, 300 px/s with short 0.06 s acceleration. Real collision/force surfaces stop it early. Force transfers require actual contact, not a near-hit tolerance. Visual recoil is separate from position. |
| Endpoint feedback | Collision-aware outline and committed arrow. Refined the shape-cast contact bracket: measured force preview x219.985 versus actual x219.925, a ~0.06 px difference. No slide or recoil displacement after impact. |
| Ground support | Can establishes floor contact before acquisition; its bumper spawn has clearance. Actor/platform leave velocity cannot add an unexpected launch. |
| Bounce | Forgiving swept top contact, fixed -305 px/s vertical impulse, no added side launch. Bounce preserves an already-started preparation/charge. No required route uses it. |
| Laser | Exact reflected phase drives both motion and prediction, including negative rotation and an equal-position reflection at a bound. Physical collector windows ~1.26 s in L3 and ~1.21 s in L4, at 14°/s. No angle snapping or auto-aim. |
| Platform state | Continuous weight/optical power remains physical. No hidden solved latch. Brief collector passes cannot move either crossing into exit launch range. |
| Boulder | Removed from all four current rooms, along with redundant Fan/cover branches. Retained actor uses controlled signed velocity, exact nearest force contact, and stops on rejection instead of elastically reversing. Repeated rolls match exactly. |
| Feedback/camera | White lock cue, impact sound/particles, bounded ~50 ms major hit-stop, light shake and short visual recoil. Full-room view keeps all decision elements visible. Collectors sit clear of exit artwork; UI titles update immediately and rails stay behind the header. |
| Retry | Measured death-to-control ~0.27 s. R restores the current room promptly, clears momentum and preserves earlier completions. Victory replay works. Waiting at any initial spawn performs no charge. |

## L1 — Direction

| Requested dimension | Result |
|---|---|
| Previous problem | Two rightward force hits competed with an optional service route and a compulsory rebound for height. This mixed directional understanding with unnecessary execution. |
| New learning goal | My position selects Can's intent; white means it will commit to that direction. Apply the rule twice from different positions. |
| Knowledge inherited | None. This is the foundation. |
| New demand | A right lure opens the shutter; a left lure raises the service lift. Both visible objects are needed for the high catwalk. |
| Execution difficulty | Easy. First bait is on a broad step above Can's body. Ordinary steps/landings, no mandatory rebound. A fixed recovery step reaches the raised lift if its initial rise was missed. |
| Timing difficulty | Low. Read lock and move to safe geometry; no phase judgment. |
| Accidental-win fixes | Spawn sits outside acquisition until movement. The catwalk exceeds a ground Can rebound's reach. The tall closed shutter blocks the catwalk. Holding right can open one object, but cannot supply the opposite lift action. |
| Deterministic fixes | Stationary Can origin; exact shutter/lift contacts; stable endpoints near x220 and x146; no search drift. Continuous catwalk avoids an unintended drop. |
| Expected novice behavior | Bait, inspect the force result, then approach from the other side and use the lift. |
| Expected experienced behavior | Begin the left setup during first impact/recovery, board the lift as it rises and move directly onto the catwalk. |

The previous service alternative and freight/rebound requirement were removed.
The level's two causal actions now remain the directional lesson itself.

## L2 — Position

| Requested dimension | Result |
|---|---|
| Previous problem | One incidental Boulder/shutter hit could finish. Fan and cover consequences replaced the requested endpoint lesson. |
| New learning goal | Aim the charge **and** preserve where Can ends. A parked body can continuously hold a useful machine state. |
| Knowledge inherited | L1's fixed intent, commitment cue, force shutter and opposite lure. The opening shutter is reused without another direction tutorial. |
| New demand | The shutter supplies a known Can origin at x220. Lure left to the wide weight footprint at the room end; its continued occupancy holds the ascent at y250. |
| Execution difficulty | Easy → medium. Broad safe perches and a quiet upper approach; ordinary jumps. No laser, Fan, Boulder or precision bounce. |
| Timing difficulty | Low. The useful state persists as long as Can is parked; no timed window. |
| Accidental-win fixes | Exit height/gap requires the powered ascent. Repeating right ends near x468 without useful weight. Player weight cannot substitute. All shallow forward/jump/wander probes fail. |
| Deterministic fixes | Exact first bumper origin, fixed opposite travel and visible physical end stop. Final Can center ~x24 reliably holds the broad pedal. |
| Expected novice behavior | Repeat the successful direction, see the endpoint miss the pedal, return Can, then park left. Inspect the held lift and leave through the quiet shelves. |
| Expected experienced behavior | Use the first bumper origin immediately, lure left and move toward the ascent while Can finishes parking. Two charges instead of four. |

The final interaction prepares L3 directly: the player leaves Can in a useful
weight footprint while repositioning above its acquisition lane. Moving Can
away releases the supported state; this is continuous occupancy, not a key.

## L3 — Timing

| Requested dimension | Result |
|---|---|
| Previous problem | Low observation was still in acquisition range; partial state reads and a short transient crossing could substitute for preserving alignment. A moving platform could cancel a jump with its underside. |
| New learning goal | Start the next setup **before** the desired angle, because preparation, lock and pedal clearance take time. |
| Knowledge inherited | L1 direction/lock; L2 stable useful weight parking and preservation while moving to a safe shelf. |
| New demand | A right charge parks near x338 on the rotor. Then withdraw left, freezing an actual useful beam angle while leaving Can away from traversal. |
| Execution difficulty | Moderate, forgiving. Wide observation shelves above acquisition; ordinary 32–36 px rises; thin crossing accepts jumps from below. |
| Timing difficulty | Moderate judgment, ~1.26 s optical window at 14°/s. Tested departure starts four degrees earlier and later (~0.29 s each way), both completing without damage. |
| Accidental-win fixes | No-input placement removed. An angle pass can move the crossing's right edge only to x462, leaving a 122 px exit gap, versus a conservative ordinary-jump reach of ~101 px. Can ground bounce cannot reach the exit height. |
| Deterministic fixes | Fixed park/withdraw endpoints near x338/x90, exact reflected rotation/prediction, stable weight contact, no temporary platform head hit or sideways launch. |
| Expected novice behavior | Observe from the safe shelf, begin withdrawal early, inspect the frozen state and approach through the next shelf before boarding. A late attempt is readable and cheap to retry. |
| Expected experienced behavior | Anticipate the delay, rise onto the next setup while Can is charging, board the crossing while it moves and ride into the exit jump. |

The optical crossing's travel prevents an incidental collector pass from
supplying the complete route. Its sustained travel is useful repositioning
time, not a stationary waiting gate.

## L4 — Combination

| Requested dimension | Result |
|---|---|
| Previous problem | Boulder/Fan clearance, cover loss and returning through the live lane obscured the inherited lesson; the baseline rehearsed route took two hits. |
| New learning goal | Predict direction, endpoint and timing together; use one withdrawal to prepare the crossing and open the familiar shutter. |
| Knowledge inherited | L1 signed force/commitment, L2 useful parked weight and return origins, L3 anticipated withdrawal/frozen continuous state. |
| New demand | A first right charge parks near x272. Time the next right withdrawal so it clears the pedal at a useful angle, then hits the shutter and stops near x418. A left return ends near x170 on the same broad pedal. |
| Execution difficulty | Moderate, using known ordinary jumps and broad observation/support areas. No new hazard or tighter jump. |
| Timing difficulty | Moderate, ~1.21 s window, same 14°/s magnitude and Can tuning. Four-degree earlier/later starts both complete without damage. |
| Accidental-win fixes | Direction alone can open the shutter but leaves an unprepared crossing. Freezing by withdrawing left leaves the shutter closed. A passing beam leaves a 126.5 px exit gap. Both physical states are needed. |
| Deterministic fixes | Known entry/impact/return endpoints, reflected timing prediction, stable crossing. The final shutter retracts downward, clearing rather than intercepting valid beam angles. |
| Expected novice behavior | Use learned timing correctly, but inspect each result and approach the ready crossing in separate steps. An early clearance leaves a visible wrong state; a deliberate return restores control, or R promptly retries. |
| Expected experienced behavior | Read the approaching phase, select the useful right endpoint, preposition while Can completes the impact, then board and ride directly into the final jump setup. |

An earlier implementation raised the shutter. A later-but-valid departure
froze at -4.47°, but that raised shutter intercepted the beam and caused a
failure. The failed rehearsal is preserved in
`development/L4_upper_shutter_margin_failure.json`. Retraction into the floor
fixes this physical obstruction and removes the brief crossing reversal; the
successful late margin now remains valid. The window was not redefined to
hide the failure.

## Concrete learning transfers

- **L1 → L2:** the player uses the same right shutter hit to establish a known
  Can origin, then applies the previously learned opposite lure. This time
  its end position must hold the weight footprint; an impact alone is insufficient.
- **L2 → L3:** leave Can parked on useful weight and observe above acquisition.
  The identical occupancy model now turns a beam. Deliberately spending that
  parked position freezes the actual angle instead of releasing only a lift.
- **L3 → L4:** begin before alignment, accounting for preparation and clearance.
  Apply that delay model to the same rotor/collector/crossing, while selecting
  the withdrawal direction whose endpoint also supplies a known force impact.

Without direction, L2's placement is accidental. Without stable weight parking,
L3's rotor control is hard to preserve. Without anticipatory timing, L4 can
open the shutter but cannot supply the crossing. These dependencies exist in
visible geometry and continuous state, not in prerequisite counters.

## Reduction and deviations from the plan

All four rooms have no Boulder or Fan: their earlier cover/nozzle choices were
outside this endpoint curriculum. The retained actor's signed rolling was
polished separately; no unrelated legacy puzzle was rebuilt. L1 uses a nearby
exit to remove an empty walk. Landing rises were reduced slightly, moving
surfaces accept jumps from below, and initial poses prevent automatic first
interactions. These changes serve precision and readability.

The novice-style L4 demonstration uses the timing learned in L3; it does not
manufacture another bad order just to enlarge the expert advantage. A separate
input-only early-order recovery exercise shows x418 → x170, restored rotor
control and immediate retry. The normal novice demonstration includes a
concrete L2 endpoint correction; expertise removes that correction and chains
moving-platform traversal in L3/L4.

## Recorded evidence

Both full runs were rendered visibly in native Godot 4.7.2. These recordings
include sound, all transitions and victory, at 640×360 / 60 FPS:

- [Expert playthrough](artifacts/precision_progression/full_expert_playthrough.mp4)
- [Inspect-and-correct playthrough](artifacts/precision_progression/full_novice_playthrough.mp4)

Both use only normal player inputs after fresh spawn. They are rehearsed
styles; neither is a blind human novice test. Movie lengths include transitions,
short capture pauses and victory display; gameplay times below exclude those.

| Level | Novice-style time / charges | Expert-style time / charges |
|---|---|---|
| 1 | 6.00 s / 2 | 5.33 s / 2 |
| 2 | 11.57 s / 4 | 6.27 s / 2 |
| 3 | 8.03 s / 2 | 6.70 s / 2 |
| 4 | 8.02 s / 2 | 7.13 s / 2 |
| Total | 33.62 s / 10 | 25.43 s / 8 |

Both runs have zero damage, deaths and rebounds. Actual stationary totals are 7.30 s versus 3.17 s; the longest segments are 1.00 s versus 0.83 s. The expert removes two corrective L2 charges and uses two early boarding transitions.

Corrective charges are actual charges above the two-action intended route.
Early boarding uses the same optical crossing while moving, with no route
bypass. Stationary time measures actual position changes, including automatic
platform carriage; local player velocity alone would incorrectly count riding
as waiting. No stationary segment exceeds two seconds in either rehearsal.

Additional evidence under `artifacts/precision_progression/`:

- `systems.json`: movement/input/landing, lock, endpoint, bounce, reflected
  prediction, exact Boulder transfer, consistent rolling and camera checks.
- `audit.json`: 52 bounded behavior cases including isolated-Can fixtures,
  seeded wandering/jumping/stomping, no-input starts, bounce height, temporary
  beam travel, physical exits, death and restart. No tested shallow route wins.
- `replay.json`: open-loop replay of every expert input, comparing gameplay
  actor positions and state at every recorded boundary, with real hit-stop.
- `route_expert_L3_offset-4.json`, `offset4`, and corresponding L4 files:
  earlier/later departure feasibility and actual frozen states.
- `early_order_recovery.json`: input-only wrong order, predictable Can return
  and prompt retry; explicitly not a completion route.
- `screenshots/`: native starting, commitment, endpoint, turning, frozen and
  exit views. These were visually inspected alongside the rendered runs.

## Acceptance status and limits

| Requested gate | Status |
|---|---|
| Responsive movement | Measured and demonstrated: acceleration/braking, buffering, coyote, underside and support-jump checks pass. Subjective silky feel needs fresh play. |
| Deterministic Can/clear lock/predictable endpoint | Implemented and verified by exact replay, repeated setups, native cues and subpixel preview agreement. |
| Predictable Boulder | Retained actor checks pass; no campaign room relies on Boulder. |
| No accidental completion | All tested shallow/bounce/transient routes fail; physical gate/height requirements implemented. Bounded probes cannot prove every possible input sequence or a player's intent. |
| L1 direction | Two opposite deliberate lures, no compulsory bounce; functional requirement implemented. |
| L2 inherits L1 | Familiar force origin and opposite lure must leave useful weight; implemented. |
| L3 inherits L1 + L2 | Directed placement, sustained weight and anticipated withdrawal; implemented. |
| L4 inherits all three | Correct direction must preserve timing and reach the force endpoint; implemented. |
| Gradual difficulty / understanding over tighter execution | Shared tuning, ordinary broad jumps and similar optical windows. Increased state/planning demand implemented; perceived curve needs fresh human play. |
| Expert flow | Recorded earlier boarding/chaining, fewer correction charges, less stationary time and faster completion. Human expertise development remains unmeasured. |
| No new major mechanic / redundant Boulder removed | Verified scope. Existing force, weight and optical rules only. |
| Fast restart / no major dead time | ~0.27 s death recovery; prompt R; longest measured stationary segment below two seconds. Arbitrary wrong configurations can still require a deliberate correction or R. |

The implementation is reviewable and the correctness evidence is complete.
This report does **not** declare the entire human-first acceptance pass complete.
Fresh play must establish that the cues teach the intended rules, that the
control feel is satisfying, and that the difficulty increases naturally. The
recordings and tests provide a concrete build for that judgment, rather than
substituting scripted completion for it.
