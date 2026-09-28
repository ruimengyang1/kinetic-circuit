# Foundry / Future States — Learn the Can

Four short factory levels about manipulating the same dangerous charging
machine: **Redirect → Weight → Timing → Combine**. No unlocks or new attacks.
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
It sees the worker inside a 52-pixel vertical lane. Movement after lock cannot
redirect it. Rebounding during a charge preserves its motion; an ordinary
stomp staggers it for 0.38 seconds. Player movement has coyote time, buffering
and strong air control throughout.

Boulder rolls under signed force, supplies weight and physically blocks beams.
Pressure continuously powers Fan airflow and linked machinery while weight
remains. A weight-held rotator turns the laser continuously at 28°/s; leaving
freezes the current angle. Actual beam contact powers the sensor's platforms.
Their target positions and circuit connections are drawn in the world.

Walk into each visible high exit after landing. Death rebuilds only the current
level in about 0.25 seconds; success changes levels after 0.65 seconds. R quickly
recovers an inconvenient configuration. Earlier completions remain intact.

[FINAL_DEMO_DESIGN.md](FINAL_DEMO_DESIGN.md) records the preimplementation plan.
[FINAL_DEMO_REPORT.md](FINAL_DEMO_REPORT.md) explains maps, knowledge transfer,
the two causal reversals, recorded approaches, checks, captures and limitations.
The 4–5 minute first-time target is **unmeasured**. Input-only rehearsed routes
are much faster; their passing results establish completion, not human fun.

## Verification

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/demo_systems.gd
godot --headless --path . --fixed-fps 60 --script res://tests/demo_learning.gd
godot --headless --path . --fixed-fps 60 --script res://tests/demo_recovery.gd
godot --headless --path . --fixed-fps 60 --script res://tests/demo_route.gd
godot --headless --path . --fixed-fps 60 --script res://tests/demo_route.gd -- --expert
godot --headless --path . --fixed-fps 60 --script res://tests/demo_route.gd -- --level=2 --rush
```

Each `--level=1`, `2`, `3`, `4` also starts fresh in that level. Completion
recordings only apply player inputs after spawn; controlled system/recovery
fixtures are explicitly separate. Evidence is under `artifacts/final_demo/`.
With graphics, add `--capture` to route runs for live screenshots, or run
`tests/demo_inspect.gd` for layouts and `tests/demo_capture_properties.gd` for
the declared Boulder-cover fixture.

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
