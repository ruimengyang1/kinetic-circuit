# Final demo: learn the Can

## Audit and preservation

Current yard gameplay, reports and evidence are committed at `0192653`; no
backup commit or remote push is necessary. Keep `foundry.tscn` as the third
checkpoint and all older scenes/scripts runnable. Default launch becomes a new
`final_demo.tscn`. Existing untracked playtest/import/UID files stay untouched.

Verified reusable systems: 155 px/s movement, 0.11 s coyote, 0.12 s jump buffer,
strong air control, automatic descending Can rebound anchored to its top,
0.55 s anticipation, 230 px/s straight charge, brief stagger/recovery, shared
force receivers, physical mass overlap, moving solid platforms, generated
sound, particles, hit pause, camera feedback and cheap reset.

Remove from main demo: Cart/docks, Crusher, old yard, legacy gates/levers,
fracture shortcuts, escort, stage checklists, optional sandboxes and previous
HUD. Preserve their code. Do not add abilities, enemies or inventory.

## Stable rules

One Can routine in every level: search, preview/lock, straight committed charge,
impact, short recovery. A descending rebound preserves committed motion.
Character-body support lets existing platform motion carry Can; this is
transport, not a new attack. Can's physical floor weight can press mechanisms.

Force acts on the same receiver contract. A Boulder rolls with deterministic
impulse/friction, collides with solids, has mass and blocks laser rays. Pressure
buttons continuously inspect mass; no latches, identity checks or hidden grace.
Fan airflow accelerates the worker upward immediately, with blades/audio/wind.

A weight-held rotator turns its laser at a constant clockwise rate. Leaving
freezes the angle. Beam contact powers a sensor continuously; losing contact
returns its linked platforms. Laser clips at actual geometry and Boulder.
All moving platforms use one deterministic powered-path component, including
the two visible reversal consequences. Exit is a visible physical alcove;
geometry, not an invisible progress flag, prevents jumping directly to it.

## Exact progression and transfer

| Level | First-time estimate | Required prior knowledge | New variable / payoff | Heuristic |
|---|---|---|---|---|
| 1 — Redirect | 45–55 s | move / jump | lure a charge through a service shutter; repeat on a freight lift and reach the high exit | my position chooses Can intent |
| 2 — Weight | 55–65 s | direction lock and force | roll Boulder onto broad button; Fan lifts to upper exit; linked hanging shuttle crosses airflow once per activation | object ending position sustains world state |
| 3 — Timing | 65–80 s | intentional Can placement; persistent state | place Can on rotator, park above it, bait left before alignment; sensor positions a horizontal crossing | position plus duration determines result |
| 4 — Combine | 80–100 s | all earlier rules | Boulder sustains Fan; its first push already leaves Can on the rotator; align sensor for exit crossing and predict the Can lift | plan the next configuration, not just this action |

Target total: 245–300 s. User per-level ranges sum to 270–345 s; use the lower
part of those ranges to respect the higher-priority under-five-minute goal.
These are human estimates to validate, never waits or walking added as padding.

L1 target opening clears Can's path to the second force target. L2 requires the
same positioning immediately. L3 begins with the same placement problem, then
tests persistent occupancy rather than one impact. L4 reuses both chains with
the identical actor settings. No explanatory mechanic paragraphs or unlocks.

## Layout commitments

Four distinct compact factory scenes built by one level controller; each has
visible beginning, machinery and exit. Broad landing surfaces and no long
backtracking. L1 uses a worker-sized service gap beneath the shutter so the
player can stand behind it; Can is too tall and must retract it with force.
L2 exit is above rebound height and requires the updraft. L3's unpowered
crossing leaves a jump too wide; the sensor shifts it into range. L4's upper
crossing likewise needs sensor positioning and a purposeful final landing.

L4's rotator is near Can's post-Boulder position. One charge can launch the
worker and move Boulder while preserving Can motion. The Fan supplies upper access; the post-impact Can position sets duration. Boulder can also absorb a
beam or obstruct movement through its ordinary solid shape. Preserve useful
nontrivial alternatives, but test normal-jump and simple forward-spam skips.

## Exactly two major causal reversals

1. **L2: active Fan is immediately safe.** Reasonable because it supplies the
   desired lift. The same button starts a visible hanging shuttle across the
   airflow, with warning before motion. Immediate entry can knock the worker
   back; watching the sweep finish allows safe entry. No spawned hazard.
2. **L4: sensor activation is only progress.** Reasonable after L3's crossing.
   The sensor also lifts the surface supporting Can into an upper charging
   lane. A visible cable, lift outline and carried robot explain the threat.
   Prepare Can off the lift before alignment, or deliberately evade/rebound
   from the arriving charge. Sequential novice play remains viable.

L3 overshooting is the ordinary timing lesson, not a third surprise trap:
Can takes time to telegraph and clear the knob, so waiting for perfect alignment
before baiting is late. A lead marker on the dial makes delay inspectable.

## Behavior and polish bar

Novice: react, move Boulder then inspect, overshoot then retry earlier, combine
systems one at a time. Expert: select lock side, predict roll endpoint, bait
before alignment, combine rebound/force/position and clear Can's lift in advance.

Tune and inspect actual level play before encoding routes. Lock snap and sound,
strong bounce, force dust, button clunk, Fan acceleration/airflow/hum, bright
beam/contact sparks, sensor pulse, platform startup and target outlines matter.
All deaths/restarts reset only the current level in under one second; completed
levels stay completed. Success feedback lasts about 0.65 s. Anti-skip tests must
inspect geometry and input attempts, not prerequisite flags. Automated tests
verify systems and routes; visual motion review cannot establish human fun or
first-time duration. Report those limits honestly.

## Implementation review adjustments

Motion review moved the laser mast above the control steps so actual solids
do not occlude the primary sensor line. L4 airflow sits beyond the aligned
beam's endpoint, avoiding mandatory damage while ascending. The L2 hanging
sweep crosses from the right and parks to the left; it acts once per pressure
activation, not as a waiting cycle. Can searches/attacks inside the same
52-pixel vertical sight lane in every level and remains where a charge ends
when the player is above that lane. This makes intentional persistent
placement legible. The final sensor physically lifts Can off its pedal and
stops rotation; a skilled withdrawal can turn that arriving Can into a second
continuing-charge rebound. This consequence is permitted by the shared rules.
