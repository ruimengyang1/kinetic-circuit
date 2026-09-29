# Foundry — Precision / Progression

Four rooms use one continuous curriculum: **Direction → Position → Timing →
Combination**. Move to choose Can's intent, read its white commitment cue,
predict its stopping point, then decide when to spend a useful parked position.
No new player ability or major mechanic was added in this pass.

Open `project.godot` in **Godot 4.7.2** and Run. The default scene is
`scenes/final_demo.tscn`, 640×360 displayed at 1280×720.

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | A/D or arrows | Left stick / D-pad |
| Jump | Space | A / Cross |
| Optional airborne stomp | J / X | X / Square |
| Retry current room | R | Y / Triangle |
| Fresh campaign / replay victory | Shift+R / R after victory | Y after victory |
| Pause | Escape | Start |
| Recall controls | H | — |

Descending onto Can still gives a consistent automatic vertical rebound.
Every required route can use ordinary jumps. Thin non-force platforms accept
jumps from below; leaving moving support preserves the ordinary jump impulse.
Movement retains 0.11 s coyote time, 0.12 s buffering, strong air control and
same-frame buffered landings. Jump/stomp presses survive impact pauses.

Can searches while stationary. A 0.50 s tracking telegraph becomes a distinct
0.12 s fixed lock, then a fast 300 px/s charge spends a fixed 248 px travel
budget. Actual bumpers can stop it earlier. The endpoint outline uses collision
contact; visual recoil never changes the collision position. Impact is followed
by 0.32 s recovery. All four rooms share these values. White means committed:
movement after that cue cannot redirect the charge.

- **L1 — Direction:** use opposite lures at the familiar shutter and service
  lift. Both are needed for the high catwalk; no compulsory bounce or alternate
  service puzzle is required.
- **L2 — Position:** reuse the shutter, then park Can on the wide weight pedal.
  Its continued occupancy holds the ascent. Repeating the first direction
  leaves an unhelpful endpoint and requires a deliberate correction.
- **L3 — Timing:** park on the same kind of footprint, now a continuous rotor.
  Leaving freezes the actual beam angle. Begin the withdrawal before alignment;
  a passing beam cannot move the crossing far enough to reach the exit.
- **L4 — Combination:** park, anticipate the useful angle, then withdraw toward
  the familiar shutter. The same charge must freeze alignment and open the
  route. The shutter retracts into the floor, avoiding beam interference.

The 14°/s sweeps have physical valid-angle windows of about 1.26 s / 1.21 s.
Broad safe observation shelves sit above Can's acquisition lane. A full-room
camera shows Player, Can, target and exit together. Boulders and Fans were
removed from these four rooms because their cover/nozzle tradeoffs displaced
the requested placement curriculum. Their implementations and historical
scenes remain. The retained Boulder uses controlled signed rolling and exact
force contact, with no elastic rejection.

Death restores current-room control in approximately 0.27 s. R retries promptly
and preserves earlier completions. Exits require landing on their physical
floor and walking into the visible doorway; there are no mechanism-completion
flags. Nothing activates merely because the player waits at spawn.

[PRECISION_PROGRESSION_PLAN.md](PRECISION_PROGRESSION_PLAN.md) records the audit
written before gameplay changes. [PRECISION_PROGRESSION_REPORT.md](PRECISION_PROGRESSION_REPORT.md)
records transfers, physical fixes, measurements and acceptance limits.

Full native Godot recordings, including sound, transitions and victory:
[expert style](artifacts/precision_progression/full_expert_playthrough.mp4) /
[inspect-and-correct style](artifacts/precision_progression/full_novice_playthrough.mp4).
These are rehearsed input-only demonstrations, not measurements of human
learning or enjoyment. Fresh human feel/progression acceptance remains open.

## Current verification

Replace `godot` with your Godot executable if it is not on PATH.

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/precision_systems.gd
godot --headless --path . --fixed-fps 60 --script res://tests/precision_audit.gd
godot --headless --path . --fixed-fps 60 --script res://tests/precision_route.gd -- --expert
godot --headless --path . --fixed-fps 60 --script res://tests/precision_route.gd
godot --headless --path . --fixed-fps 60 --script res://tests/precision_replay.gd
godot --headless --path . --fixed-fps 60 --script res://tests/precision_recovery.gd
godot --headless --path . --fixed-fps 60 --script res://tests/precision_route.gd -- --expert --level=3 --offset=-4
godot --headless --path . --fixed-fps 60 --script res://tests/precision_route.gd -- --expert --level=3 --offset=4
godot --headless --path . --fixed-fps 60 --script res://tests/precision_route.gd -- --expert --level=4 --offset=-4
godot --headless --path . --fixed-fps 60 --script res://tests/precision_route.gd -- --expert --level=4 --offset=4
python3 tests/precision_compare.py
```

`--level=1` through `4` start fresh in that room. `--capture` records native
rendered states. Every completion route uses only player inputs after spawn.
System/geometry fixtures explicitly label assigned states. The replay instead
applies a saved input stream without adapting to the world.

`scenes/polish_sandbox.tscn` uses the same Player/Can for objective-free feel
practice. Earlier reports and route harnesses preserve the preceding layouts;
their coordinates and tuning expectations are historical. Current evidence is
under `artifacts/precision_progression/`, with baseline source and starting
views, bounded bypass cases, exact replay, timing margins and route comparison.

Earlier passes remain documented in
[LEVEL_PROGRESSION_REDESIGN_REPORT.md](LEVEL_PROGRESSION_REDESIGN_REPORT.md),
[STRATEGIC_DEPTH_REPORT.md](STRATEGIC_DEPTH_REPORT.md),
[POLISH_REPORT.md](POLISH_REPORT.md), and [REBALANCE_REPORT.md](REBALANCE_REPORT.md).

## Preserved prototypes

- `scenes/foundry.tscn`: third persistent yard, committed checkpoint `0192653`.
- `scenes/yard_sandbox.tscn`: objective-free third yard.
- `scenes/foundry_second.tscn`: second four-arena version, checkpoint `2e1ea7d`.
- `scenes/impact_lab.tscn`: second version's isolated core playground.
- `scenes/foundry_legacy.tscn`: first escort redesign, checkpoint `340aed6`.
- `scenes/kinetic_prototype.tscn`: System Link.
- `scenes/game.tscn`: original Foundry and Relay Shaft.

Their scripts, reports, captures and tests remain available. Nothing was pushed
to a remote repository.
