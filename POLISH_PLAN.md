# Focused polish plan — 2026-09-29

Written before gameplay implementation. Scope: the current `final_demo.tscn`,
its four existing rooms and existing interactions. No new mechanics, enemies,
objectives, art direction or room restructuring. Preserve the pending rebalance
work already in this checkout and all changelog history.

## Current build audit

Read the full Player inheritance chain, Can, Boulder, machine, platform,
camera/flow, effects and sound scripts. Ran the current input-only four-room
route both headless and with the OpenGL renderer, inspected its captured states,
and ran the 33 rebalance system checks. All passed before editing. Saved route,
trace and rendered evidence under `artifacts/polish/baseline/rebalance/`.

This is scripted playthrough and visual inspection, **not a human playtest**.
Subjective fun, sound quality and novice comprehension require an actual person.
The report will keep those verdicts pending rather than inventing observations.

Baseline sequential headless times: L1 5.95 s, L2 7.43 s, L3 8.65 s,
L4 12.50 s. These are rehearsed feasibility times, not novice learning times.
L4 incurs two hits. Its cover change, airflow and lifted threat need especially
careful feedback. L3 includes 1.55 s total idle time and 2.87 s rotor occupancy.
Optical windows measured from real collision rays: L3 25.75° / 1.43 s;
L4 15.25° / 0.95 s. Most existing timings are already reasonably short.

## System decisions and proposed parameters

Each row records the problem, its feel consequence, the proposed change, values
and difficulty/noise risk. Values may be revised after measured route failures;
record final deviations in the report.

| System | Current problem and why it hurts flow | Proposed change and before → after | Risk / guardrail |
|---|---|---|---|
| Ground movement | 0.148 s to reach speed, 0.295 s to reverse; slower response than the existing strong air control | Acceleration 1050 → 1800 px/s²; friction 1100 → 1900. Speed 155 → 155; air acceleration 1700 → 1700; air friction 420 → 650 | Faster reversals can alter bait position; validate all routes and stopping distance. Demo-only tuning |
| Jump / gravity / landing | Good readable arc already, but buffered jump executes a frame after landing; release during hit-stop can disappear | Preserve gravity 650, jump -235, variable cut 0.55, coyote 0.11 s, buffer 0.12 s. Execute a valid buffer on the landing frame, capture press/release during impact pause. Landing control delay remains zero | Preserve traversal height and one-shot input consumption; test late ledge and prelanding presses |
| Bounce / stomp | Two inherited rebound paths plus moving-Can fallback have different overlap rules. Stationary descending contact requires >20 px/s; fast lateral crossings can miss. Bounce freezes controls for 33 ms | One demo contact resolver using relative swept top crossings, half-width 22 → 24 px, top forgiveness 3 px; fixed rebound -305 unchanged. Remove bounce hit-stop 2 → 0 frames; clear stale jump/attack buffer; 0.10 s visual compression/stretch and upward burst | No side/underside rebounds; retain charging Can momentum. Sweep and moving lift fixtures, frame-rate consistency |
| Can search / telegraph / lock | Opening cooldown and tiny postrecovery cooldown add idle time; anticipation is already readable | Opening cooldown 0.45 → 0.25 s; anticipation 0.55 unchanged (0.20 tracking + 0.35 locked). Recovery 0.20 s unchanged; extra cooldown 0.08 → 0; stomp stagger 0.38 → 0.28 s. Add a short lock flash | Faster repetition could overwhelm new players; preserve full warning and maximum speed; route damage checks |
| Can charge / impact | Release is sound but wall hit uses generic hurt cue; every feedback event creates the same 4 px camera shake | Preserve 230 px/s, 0.10 s acceleration, 1.15 s committed charge. Major impact pause 3 frames / 50 ms, bounce none; distinct wall/mechanism sound, contact flash, strength-scaled 0–2 px camera impulse decaying over ~0.14 s | Never home; avoid stronger damage timing. Cap feedback and handle input during hit-stop |
| Boulder | 0.86 s nominal stopping time and ~119 px travel already produce required positions; sound is a single impact chirp, no rolling bed | Keep friction 325, force multiplier 1.22, speed cap 300. Add quiet velocity-scaled rolling loop, contact dust, short impact flash and stronger transfer cue | Do not change final positions or force puzzle. No random physics; stop loop when stationary/paused |
| Laser rotation / stop | Mechanism stops immediately already. Fixed 0.80 s lead mark ignores windup progress, direction and unoccupied state | Preserve L3 18°/s and L4 -16°/s. Predict withdrawal from remaining Can anticipation plus physical distance to pedal edge; hide lead when stopped; reflect at sweep limits. Add engage/disengage cues | Prediction is a cue, not angle assist. Verify actual stop and inspect near sweep reversal |
| Laser window / readability | L4 has less than one second of full target traversal; near-alignment cue exists only on small origin dial | L3 radius 30 unchanged; L4 36 → 40 px. Gradual prealignment receiver glow; beam/contact brighten on useful contact; quiet alignment cue on state change | Slightly easier timing only; retain occlusion and real ray contact; no snapping or timing meter |
| Fan / airflow | Machine spools for 0.167 s visually, but worker receives full force immediately and looping audio can be silent because power was set before voice creation | Worker entry ramp 0 → 0.18 s, strength 1700 and upward cap 220 unchanged; exit clears ramp immediately. Use actual visible flow/spool in force; fix loop startup and blocked/unblocked gain | Too soft a ramp can compromise access; test broad entry, landing and all Fan routes; no teleport or extra horizontal drift |
| Moving platforms / L4 ordering | No periodic loops; most trips 0.35–0.69 s. L4 0.75 s warning stacks with ~0.49 s travel | Keep direct paths and speeds 140–240. L4 lift warning 0.75 → 0.55 s; crossing still reacts immediately. Preserve visible warning so lift follows optical/crossing payoff | Shorter threat warning must remain safe; test supported rising Can and L4 completion |
| Camera / visibility | Static 640×360 view already shows worker, Can, receiver and consequences; generic shake obscures fine beam tuning | Preserve centered full-room framing, zoom 1, no follow lag. Strength-scaled impulses instead of every-event 4 px shake; no shake for settle or rotor ticking | Avoid unnecessary camera movement or room layout changes; verify L3/L4 captures |
| Death / retry / transition | Current retry 0.25 s and transition 0.65 s are already faster than requested; impact offset can remain frozen during transition | Preserve delays and current-level progression. Continue camera decay during short clear/death feedback; flush stale buffered actions and pause state on rebuild | Do not replay tutorials or reset completed levels; test held movement and quick R |
| Audio / particles / performance | Per-event audio node creation, radial bounce spray and repeated same-strength feedback blur state identities | Reusable capped one-shot voice pool; existing synthesis plus distinct engage/stop/alignment/transfer/roll sounds. Directional upward bounce burst, short flashes; cap demo particles at 128 | Keep loop gains quiet, one-shot cooldowns short, and legacy sound defaults compatible. Measure node/particle bounds |

## Level flow focus

- L1: early readable bait and lock, immediate dodge, strong shutter/freight
  reaction, repeated Can rebound; first payoff within 15–20 s.
- L2: keep the intentional two-force duct chain; maintain deterministic Boulder
  endpoints while making rolling/transfer and airflow entry perceptible.
- L3: retain the existing strategic withdrawal; make current and predicted
  beam direction agree with what the Can will physically do.
- L4: impact → rolling cover change → airflow; optical contact → crossing
  motion → warned Can lift. Use existing physical offsets, no artificial force
  delay. Slightly broaden the receiver and shorten only excess lift waiting.

## Validation before final verdict

Run every existing test script, distinguish historical expectations from current
regressions, and keep baseline results. Run current system/audit suites, four-room
and fresh-room routes, upper L1 route and expert route. Add only focused fixtures
for jump/coyote/pause buffering, swept/moving rebounds, Can rhythm, airflow entry,
laser stop/window and fast local rebuild. Inspect rendered postchange states.

Create an objective-free Player + Can + ground/walls sandbox using the same
scripts and feedback; exercise normal input for 30 simulated seconds and capture
its repeat rhythm. Mark every >=2 s no-action interval from route traces and
separate deliberate alignment/setup from avoidable waiting. Bounds checks on
particles/audio voices must accompany repeated feedback.

The final report must explain before/after/why, failures and final tuning, and
list unresolved awkward moments. The 13 subjective pass/fail gates remain
**pending human verification** where automated evidence cannot establish feel.
