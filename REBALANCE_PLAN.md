# Focused rebalance — preimplementation plan

Written after inspecting the current launch scene, all four room builders,
Can, Boulder, machine/switch/laser/airflow, moving platform, inherited player
movement and retry flow. Inspected all four existing rendered layouts and ran
the current input-only four-level route and withdrawal fixtures in Godot 4.7.2.
This is an incremental change to `final_demo.tscn`, not another launch scene or
replacement game. Earlier prototypes and their historical evidence stay intact.

## Findings from the current playable version

The baseline known-solution run takes 4.95 / 7.03 / 9.53 / 10.47 seconds.
These are rehearsed completion times, not novice playtests. They explain why
the existing first-run estimates are weak evidence in light of human feedback.
Player speed, broad jumps, 0.11 s coyote time, 0.12 s buffering, automatic Can
rebound and 0.25 s current-level death retry already work and should be retained.
The camera already shows the whole 640×360 room; zooming farther out would
make small mechanisms harder to read. Improve composition within that view.

### Level 1: easy but active, 50–55 s first encounter

**Why too easy:** the shutter and freight are sequential positive force
receivers. Stand right, dodge, repeat; existing steps make the resulting Can
position unimportant. There is no choice of useful first target.

**Actual decision now:** currently only when to jump out of the charge. The
new decision will be which side to bait first, then where to leave Can for the
next height gain. A leftward force-operated service lift gives an upper approach;
the existing rightward shutter gives a roomy lower approach. Both feed the
existing freight ascent. Both are useful, with different Can follow-up positions.

**Change without new mechanic:** add a second instance of the existing signed
force platform, with reversed operating direction. Keep the shutter/freight.
Adjust broad intermediate landings so the lower route benefits from a parked
Can rebound; the upper approach needs Can brought back toward freight. Avoid
new buttons, abilities, hazards or narrow jumps. Improve the shared Can's
compression/lock/short acceleration ramp/impact recoil and anticipation sound.
Discover direction, apply it to a chosen target, then use the state left behind.

### Level 2: medium, 60–70 s first encounter

**Why too easy / button logic:** one rightward hit parks Boulder on a 76-pixel
button. Fan and hanging hazard both start. Boulder then has no useful role
beyond continuing to hold a key. Waiting for the sweep is the safest answer.

**Force consequence:** keep Boulder and Fan, remove the pressure circuit and
the hanging sweep from this room. Fan already runs. Boulder transfers signed
momentum into an existing sliding solid duct shutter; the panel physically
uncovers the nozzle. The same roll leaves Boulder over the now-open nozzle,
so opening the route also blocks the new airflow. The visible sputtering duct,
solid Boulder and short roll make the consequence inspectable immediately.

**Decision:** hit from which side next? Reversing Boulder clears the nozzle
and leaves Can on the left; a further rightward push also clears it but needs
another setup and leaves the threat nearer traversal. Boulder remains a solid
step and airflow obstruction, not a key. Use one secondary consequence, not
extra hazards. The surprise is “I opened it, then my rolling object covered it.”

### Level 3: medium+, 70–75 s first encounter

**Why too easy / prediction now:** the existing level does require predicting
withdrawal delay, but the rest is a single isolated sensor task. It has no
Boulder and earlier resulting-position knowledge contributes little. The 28°/s
rotation and tiny receiver make its timing lesson less forgiving than intended.

**Change:** retain the rotator and crossing. Add the existing Boulder in the
approach lane: directing force right prepares a useful landing step beyond the
rotator. The step's position matters after alignment; pushing it the other way
loses that approach. Remove the redundant fixed stepping stone that currently
supplies the same access. Alternatives using a deliberately positioned Can
rebound remain legitimate. Only the existing duration rule is introduced here.

**Timing:** use roughly 18°/s rotation, a much broader actual optical receiver,
a short bounded reversing sweep rather than a full-circle retry wait, and a
visible receiver sector plus predicted stopping marker. No angle snapping or
hidden solved flag. Bait left before useful alignment, then move toward the
prepared Boulder step. Novices can correct one overshoot; experts prepare their
withdrawal and follow-up position while the beam moves. The simultaneous
consideration is the resulting Boulder traversal position, not another hazard.

### Level 4: medium+, mastery, 90–100 s first encounter

**Exact spike:** the default beam takes about four seconds to sweep to a small
receiver. Its angular tolerance is around 9° total at a roughly 194-pixel
distance, about 0.33 s at 28°/s. Can's acquisition, 0.55 s telegraph and pedal
clearance can exceed that. The sensor immediately raises both crossing and Can
support, removing weight and carrying a threat into the worker's lane. Static
ledges, cable lines, a pressure-powered Fan and the moving Can all compete for
attention. Boulder blocking is technically supported but absent from the real
ground-level route: the old cover evidence positions it by hand in midair.

The difficulty is conceptual and visual (automatic removal and two linked
motions), with an unnecessary timing/execution burden. Camera cropping is
not the source; the meaningful cover and next safe position need better
composition and markings inside the existing full-room frame.

**Keep strategy, simplify execution:** remove Button→Fan here as well. Put the
laser mast low enough for the actual ground Boulder to block its visible beam.
The running Fan's nozzle is also obstructed by Boulder. Moving it opens air
and exposes the old danger: prepare an elevated safe position before impact.
The existing ledges provide a way into airflow above the dangerous lower lane.
Reuse continuous rotation to aim at the upper receiver. Use about 16°/s, a
generous receiver, a bounded short retry sweep, and strong near-alignment cues.
Keep the crossing and physical Can lift, but delay the lift by about 0.75 s of
readable warning after alignment; avoid simultaneous alignment/jump/dodge.
Can on the lift remains a threat and can also be used for a continuing rebound.
An automatic lift withdrawal is a legitimate planned alternative to manual
withdrawal, not a new control rule. Keep broad landings and quick transport.

**Final reversal:** Boulder visibly blocks the lower beam. The player moves
it, exposing the lane. Remaining on that lane can cause damage. A brief visible
beam reignition warning gives readable consequence; the safe setup is spatial,
not a twitch dodge. All damage is recoverable until health runs out; retry is
still current-level and about 0.25 s. No hidden spikes or new enemy.

## Scope and reusable relationships

- Keep Can maximum speed at 230 px/s and short recovery. A brief acceleration
  ramp preserves commitment, with matching force sweep and lane preview.
- Add force transfer to Boulder using the existing receiver contract and one
  contact per roll. No general-purpose physics simulation.
- Running Fan samples its narrow nozzle against real solids; visible airflow
  is clipped by the obstruction. Player force follows the exposed air column.
- Laser continues to raycast against real solids and Player. Actual receiver
  shape grows; feedback previews tolerance but does not auto-aim the beam.
- Existing platforms keep real support/carrying, visible destinations and
  signed force. Add reusable operating direction and a start-warning margin.
- Keep pressure-switch implementation available for preserved content, but
  remove it from the four-room design grammar. Present the optical receiver as
  a heat-driven winch with a physical cable, not a colored matching button.
- Preserve immediate R retry, death and completed-level history; fix any
  regression found while testing. Update `CHANGELOG.md` with gameplay edits.

First-encounter estimate totals 270–300 s. Do not manufacture that time with
walking or mandatory waiting. It is a human-test target, not an automated fact.

## Verification before completion

1. Run fresh input-only routes through all rooms, both L1 openings and at least
   one efficient compound approach. Record impacts, position, timing, hits and
   retries. Routes must not set world state after spawn.
2. Test forward movement, forward/jump spam and one-bait-then-forward attempts
   in L1–L3. Inspect failure positions, not just exit flags. Deliberate Can
   rebounds/alternative configurations are welcome; accidental skips are not.
3. Test signed Boulder momentum, real duct opening and subsequent occlusion,
   withdrawal margins, beam cover/removal, platform carrying and fast retries
   in explicitly labeled controlled fixtures.
4. Inspect fresh rendered layouts and consequential states; check every
   target, beam, Can and safe bait position in the same camera composition.
5. Record L4 alignment tolerances and successful input margins. If a sound
   route repeatedly fails on execution, reduce the demand instead of hiding it.
6. Write `REBALANCE_REPORT.md` per level, with prior/new knowledge, decisions,
   novice/expert expectations, time estimates, replaced circuits, test evidence
   and remaining human validation. Automated checks establish behavior and
   solvability; they cannot prove fun, novelty, or a 4–5 minute first run.
