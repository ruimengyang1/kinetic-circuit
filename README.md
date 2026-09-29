# Foundry — Final Gameplay Rescue

Four rooms build **Direction → End Position → Timing → Planning** using the
same Can, pressure, optical and platform rules. This rescue fixes the actual
L2 missing endpoint reward, misleading direction forecasts and a reproduced
L3 late-reaction solution, while preserving deliberate first-pass boarding.
No new player ability or major mechanic was added.

Open `project.godot` in Godot 4.7.2 and Run. The default scene is
`scenes/final_demo.tscn`, 640×360 displayed at 1280×720.

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | A/D or arrows | Left stick / D-pad |
| Jump | Space | A / Cross |
| Optional airborne stomp | J / X | X / Square |
| Retry room | R | Y / Triangle |
| Fresh campaign | Shift+R / R at victory | Y at victory |
| Pause | Escape | Start |
| Recall controls | H | — |

Can: stationary search → 0.50 s tracking telegraph → 0.12 s fixed white lock
→ 300 px/s charge with a 248 px distance budget → impact → 0.32 s recovery.
Real contact stops it early; its endpoint marker predicts collision, and visual
recoil does not alter position. It can reliably depart either end bumper.
All rooms share actor tuning, 0.11 s coyote time and 0.12 s jump buffering.
Normal jumps suffice; bounce stays optional and thin platforms accept jumps
from below. Death restores control in about 0.27 s; R keeps prior completions.

- **L1:** two opposite deliberate lures; learn direction and commitment.
- **L2:** door-first works in three charges. Boarding-first works in two: the
  next impact opens the door and leaves useful crossing weight while your
  occupied lift rises. Looking ahead saves a complete future charge.
- **L3:** two separate optical setups. Secure play freezes boarding, boards,
  returns Can and freezes the crossing. Flow play boards the first passing
  beam and prepares the final withdrawal without an extra return cycle.
  Reacting only at the first target no longer happens to freeze the second.
  Directional stop forecasts show both choices before acquisition, then the
  selected/committed one; amber points left and mint points right.
- **L4:** apply those setups while planning early or final shutter clearance.
  Different return origins change withdrawal timing. Final Can weight must
  also supply the exit lift; alignment and an open shutter alone are insufficient.

The later challenge is phase prediction and preserving useful state, with
broad surfaces and unchanged charge/jump tuning. Exits remain physical floors
and doorways without mechanism-completion flags. Boulders/Fans are absent
from the current curriculum; historical scenes and actor implementations remain.

[Pre-edit audit and plan](FINAL_RESCUE_PLAN.md) records native inspection and
critical findings. [Final rescue report](FINAL_RESCUE_REPORT.md) explains the
physical learning transfers, alternative orders and evidence limits.

Native full recordings with sound and victory:
[correct intended run](artifacts/final_rescue/full_intended_playthrough.mp4),
[reactive novice style](artifacts/final_rescue/full_novice_playthrough.mp4),
[predictive expert style](artifacts/final_rescue/full_expert_playthrough.mp4).
These are normal-input rehearsals, not first-time human trials. Fresh human
judgment of fun, smoothness and perceived difficulty remains open.

## Current verification

Replace `godot` with the executable path if needed.

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/final_rescue_systems.gd
godot --headless --path . --fixed-fps 60 --script res://tests/precision_audit.gd -- --output=res://artifacts/final_rescue
godot --headless --path . --fixed-fps 60 --script res://tests/precision_dependencies.gd -- --output=res://artifacts/final_rescue
godot --headless --path . --fixed-fps 60 --script res://tests/final_rescue_route.gd
godot --headless --path . --fixed-fps 60 --script res://tests/final_rescue_route.gd -- --expert --flow
godot --headless --path . --fixed-fps 60 --script res://tests/final_rescue_route.gd -- --expert --flow --equal-inspection
godot --headless --path . --fixed-fps 60 --script res://tests/final_rescue_route.gd -- --expert --level=4 --early-gate
godot --headless --path . --fixed-fps 60 --script res://tests/final_rescue_learning.gd
godot --headless --path . --fixed-fps 60 --script res://tests/final_rescue_recovery.gd
godot --headless --path . --fixed-fps 60 --script res://tests/precision_replay.gd -- --output=res://artifacts/final_rescue
python3 tests/final_rescue_compare.py
```

`--level=1` through `4` starts fresh in that room; `--capture` saves native
views. `--offset=-4` / `4` shifts departure decisions four degrees. Secure and
flow L3 plans and secure, early-gate and flow L4 plans were checked at both
margins. Completion/recovery routes use only player inputs after spawn.
Fixtures explicitly label assigned world states. Replay applies saved inputs
without adapting. Passing checks establish behavior, not enjoyment.

Current evidence is under `artifacts/final_rescue/`, including both failed
and corrected L3 observations. Its `baseline/` preserves the pre-rescue source
and the reproduced accidental timing solution. Previous precision evidence
remains under `artifacts/precision_progression/`; its reports describe that
historical layout. `scenes/polish_sandbox.tscn` uses the same actors for feel
practice. No active campaign room contains an unnecessary Boulder or Fan.

Earlier passes remain documented in
[PRECISION_PROGRESSION_REPORT.md](PRECISION_PROGRESSION_REPORT.md),
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
