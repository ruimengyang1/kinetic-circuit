# Foundry / Future States — Intent and Consequence

Four short factory levels about manipulating the same dangerous charging
machine: **How → Consequence → Anticipation → Planning**. Your position chooses
its intent; its force, final position and time spent on machinery change the
next decision. The same Can routine and Player abilities apply throughout.

Open in **Godot 4.7** and press Run. Default scene:
`scenes/final_demo.tscn`, 640×360, displayed at 1280×720.

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | A/D or arrows | Left stick / D-pad |
| Jump / automatic descending rebound | Space | A / Cross |
| Airborne stomp | J / X | X / Square |
| Retry current level | R | Y / Triangle |
| Fresh demo / replay after victory | Shift+R / R after victory | Y after victory |
| Pause | Escape | Start |
| Recall controls | H | — |

Can previews for 0.20 seconds, locks for 0.35 seconds, then commits at 230 px/s.
The first 0.10 seconds accelerates to that same maximum.
It sees the worker inside a 52-pixel vertical lane. Movement after lock cannot
redirect it. Rebounding during a charge preserves its motion; an ordinary
stomp staggers it for 0.28 seconds; impact recovery is 0.20 seconds with no extra
cooldown. Player movement has quicker ground acceleration/braking, 0.11-second
coyote time, 0.12-second buffering and strong air control throughout. Buffered
landings launch on contact; jump/stomp presses survive major impact pauses.
Descending top rebounds use forgiving swept contact and a fixed launch height.

Boulder rolls under signed force, blocks airflow and beams, and can become a
traversal step. Fan already runs; solids across its nozzle obstruct the jet.
There are no pressure-to-Fan circuits in the demo. L1 requires two Can
predictions and retains a service-lift alternative; choosing the opening also
chooses Can's next position. L2 starts from the right: moving Boulder left opens
airflow while spending its protection against a visible stationary Laser.
Prepare on the broad shelf before that change. Solid beams are active; faint
dashed continuations show space currently protected by a heavy blocker.

A weight-held rotator turns continuously; leaving freezes its actual angle.
L3 rotates at 18°/s and L4 at 16°/s inside visible mechanical limits. Broad heat
collectors wind platforms through beam contact, coasting for 0.28 seconds through
brief interruptions. Actual optical windows are about 1.74 s / 1.69 s. Begin
repositioning before the desired beam state; the stopping preview follows Can's
remaining windup and clearance distance, without snapping or auto-aiming.
L3 also needs the useful Boulder landing left by its placement charge.

L4 uses only those known systems. Clearing Boulder first works, but spends
cover and leaves Can needing a return trip. A prepared order keeps Boulder
until Laser is aimed away from the low lane, then combines withdrawal, Boulder
force and nozzle clearance in one charge. The automatic Can lift is removed;
Player decides when to spend rotor occupancy. High observation and low bait
shelves make that choice readable. Entering airflow still ramps lift over 0.18 s.

Walk into each visible high exit after landing. Death rebuilds only the current
level in about 0.25 seconds; success changes levels after 0.65 seconds. R quickly
recovers an inconvenient configuration. Earlier completions remain intact.

[STRATEGIC_DEPTH_REDESIGN_PLAN.md](STRATEGIC_DEPTH_REDESIGN_PLAN.md) contains the
preimplementation audit of every level.
[STRATEGIC_DEPTH_REPORT.md](STRATEGIC_DEPTH_REPORT.md) records the redesign,
three reusable heuristics, strategic choices, measured evidence and acceptance
gaps. The 4–5 minute first-time target is **unmeasured**. Blind first/second-run
learning and subjective fun remain pending; desktop capture/input permissions
were unavailable. Rehearsed routes establish consequences and completion.

[REBALANCE_PLAN.md](REBALANCE_PLAN.md) and
[REBALANCE_REPORT.md](REBALANCE_REPORT.md) preserve the preceding version's
audit and evidence; its duct and automatic lift are historical.

[POLISH_PLAN.md](POLISH_PLAN.md) records the feel audit before polish edits.
[POLISH_REPORT.md](POLISH_REPORT.md) gives final before/after tuning, preserved
baseline failures, flow evidence and outstanding human checks. The full-room
camera keeps its framing; impacts use small impulses and bounded effects/audio.
`scenes/polish_sandbox.tscn` is an objective-free Player + Can practice fixture
outside the four-level progression. Run it directly to judge the 30-second loop.

## Verification

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/polish_feel.gd
godot --headless --path . --fixed-fps 60 --script res://tests/strategic_systems.gd
godot --headless --path . --fixed-fps 60 --script res://tests/strategic_audit.gd
godot --headless --path . --fixed-fps 60 --script res://tests/strategic_route.gd
godot --headless --path . --fixed-fps 60 --script res://tests/strategic_route.gd -- --expert
godot --headless --path . --fixed-fps 60 --script res://tests/strategic_route.gd -- --level=1 --upper
godot --headless --path . --fixed-fps 60 --script res://tests/strategic_route.gd -- --level=4 --expert --lead=20
```

Each `--level=1`, `2`, `3`, `4` also starts fresh in that level. Completion
recordings only apply player inputs after spawn; controlled system/recovery
fixtures are explicitly separate. Current evidence is under
`artifacts/strategic_depth/`, including session baseline source/layouts and
`comparison.json`. `--lead=8`, `14`, `20`, `24` exercise distinct early L4 starts;
explicit margin runs write separate evidence folders. With graphics, add
`--capture` to route runs or run `tests/strategic_inspect.gd` for layouts.

Old demo/rebalance/polish route and layout harnesses preserve historical
expectations, including removed duct/button/lift arrangements. Use the strategic
suite for current design; `polish_feel.gd` remains a current regression check.
Historical evidence stays under `artifacts/final_demo/`, `artifacts/rebalance/`
and `artifacts/polish/`, with its corresponding reports.

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
