# Foundry / Future States — Kinetic Chain Reaction

Four short factory levels about manipulating the same dangerous charging
machine: **Redirect → Momentum → Timing → Combine**. No unlocks or new attacks.
Your position chooses its intent; its force, final position and time spent on
machinery change the next situation.

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

Boulder rolls under signed force, transfers momentum to a sliding duct panel,
blocks airflow and beams, and can become a traversal step. Fan already runs;
solids across its nozzle obstruct the jet. There are no pressure-to-Fan circuits
in the demo. L2 starts from the right and requires leftward force. L1 offers a
ground approach and a service lift that carries Can into the upper approach.

A weight-held rotator turns continuously; leaving freezes its actual angle.
L3 rotates at 18°/s and L4 at 16°/s inside visible mechanical limits. Broad heat
collectors wind platforms through beam contact, coasting for 0.28 seconds through
brief interruptions. L4's lift warns for 0.55 seconds before moving Can into a
new lane. Moving Boulder opens airflow while exposing more of the old beam.
Destinations, alignment sectors and stopping previews are drawn in the world.
The preview follows Can's remaining windup and distance to clear the pedal;
it hides when Can's committed direction cannot clear the room's rail limit.
The final heat collector is slightly broader, useful beam contact brightens,
and entering airflow ramps the existing lift force over 0.18 seconds.

Walk into each visible high exit after landing. Death rebuilds only the current
level in about 0.25 seconds; success changes levels after 0.65 seconds. R quickly
recovers an inconvenient configuration. Earlier completions remain intact.

[REBALANCE_PLAN.md](REBALANCE_PLAN.md) records the audit and plan written before
gameplay edits. [REBALANCE_REPORT.md](REBALANCE_REPORT.md) explains current
decisions, knowledge transfer, consequences, evidence and remaining concerns.
The 4–5 minute first-time target is **unmeasured**. Input-only rehearsed routes
are much faster; their passing results establish completion, not human fun.

[POLISH_PLAN.md](POLISH_PLAN.md) records the feel audit before polish edits.
[POLISH_REPORT.md](POLISH_REPORT.md) gives final before/after tuning, preserved
baseline failures, flow evidence and outstanding human checks. The full-room
camera keeps its framing; impacts use small impulses and bounded effects/audio.
`scenes/polish_sandbox.tscn` is an objective-free Player + Can practice fixture
outside the four-level progression. Run it directly to judge the 30-second loop.

## Verification

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/polish_feel.gd
godot --headless --path . --fixed-fps 60 --script res://tests/polish_sandbox.gd
godot --headless --path . --fixed-fps 60 --script res://tests/polish_route.gd
godot --headless --path . --fixed-fps 60 --script res://tests/polish_route.gd -- --expert
godot --headless --path . --fixed-fps 60 --script res://tests/rebalance_systems.gd
godot --headless --path . --fixed-fps 60 --script res://tests/rebalance_audit.gd
godot --headless --path . --fixed-fps 60 --script res://tests/rebalance_route.gd
godot --headless --path . --fixed-fps 60 --script res://tests/rebalance_route.gd -- --expert
godot --headless --path . --fixed-fps 60 --script res://tests/rebalance_route.gd -- --level=1 --upper
```

Each `--level=1`, `2`, `3`, `4` also starts fresh in that level. Completion
recordings only apply player inputs after spawn; controlled system/recovery
fixtures are explicitly separate. Polish evidence is under `artifacts/polish/`;
earlier rebalance evidence is under `artifacts/rebalance/`.
With graphics, add `--capture` to route runs for live screenshots, or run
`tests/rebalance_inspect.gd` for layouts. The old `tests/demo_*` harnesses,
`FINAL_DEMO_DESIGN.md`, `FINAL_DEMO_REPORT.md` and `artifacts/final_demo/` are
historical evidence for the version before this rebalance; their expectations
are not the current verification suite.

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
