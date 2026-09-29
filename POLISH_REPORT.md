# Focused polish report — 2026-09-29

Implementation and functional verification are complete for this pass. **Human
feel acceptance remains pending.** This report contains scripted normal-input
playthroughs, controlled physics/input fixtures and rendered visual inspection.
No human played all four rooms or supplied a 30-second enjoyment verdict in this
session. The final subjective pass/fail gates are not declared passed.

Scope stayed within the existing four-room design. No enemies, mechanics,
objectives or room layout changes. The separate practice scene is a test fixture,
outside progression. Existing pending rebalance work and changelog history were
preserved. `POLISH_PLAN.md` was written after the baseline audit and before edits.

## Player: before → after → why

| Property | Before | After | Practical improvement |
|---|---|---|---|
| Ground acceleration | 1050 px/s² | 1800 px/s² | Nominal full speed in 86 ms instead of 148 ms; reversal in 172 ms instead of 295 ms |
| Ground braking | 1100 px/s² | 1900 px/s² | Measured stopping distance 5.06 px; less drift past a chosen bait/landing point |
| Air braking | 420 px/s² | 650 px/s² | Releasing direction stops the long airborne tail sooner |
| Run / air control | 155 px/s / 1700 px/s² | Preserved | Keeps traversal distances and useful rebound steering |
| Jump / gravity | -235 px/s / 650 px/s² | Preserved | Same readable jump height and arc |
| Variable jump | 0.55 release multiplier | Preserved; remembers release during pause or before buffered landing | Short taps remain short even around impact/landing edges |
| Coyote / buffer | 0.11 / 0.12 s | Preserved | Existing scale already supplies useful forgiveness; expiry tested |
| Buffered landing | Consumed on the following physics frame | Consumed on the contact frame | Landing produces the requested action immediately, with no animation lock |
| Impact pause input | `active = false`, input edges ignored | Separate simulation pause with captured jump, release and stomp edges | A press and release entirely inside hit-stop now works |

The demo's movement loop is isolated in `demo_player.gd`; preserved prototype
movement constants and dash behavior remain unchanged. A regression test caught
the stale floor flag after a buffered launch disabling variable release. The
final code treats an upward launch as airborne on the following frame.

## Bounce

Before: inherited descending checks, strike checks and the rising-Can fallback
had different contact windows. Ordinary falling contact required at least
20 px/s downward speed. A diagonal crossing could miss, and bounce feedback
froze the world/player for two requested frames.

After: automatic contact uses one relative swept top resolver, a 24 px horizontal
half-window instead of 22, a 3 px approach allowance and a bounded 10 px descending
corner grace. Rising supports resolve relative motion before side damage. Launch
remains exactly -305 px/s, anchored to the current shell top; downward momentum
is replaced. Jump release cannot cut a rebound. Attack/stale jump buffers clear
on contact. Side/underside and ascending contacts remain excluded.

Can charge continues through rebound. Player gets useful air control immediately,
with no bounce pause, a 0.10 s compression/stretch pose, upward particles, bounce
sound and a small 0.7 px camera impulse. Visual compression never delays launch.
Fixtures cover slow/fast descents, diagonal contact, rising Can and rejected
side/underside contacts. L1's normal route completes its first rebound without
damage; the upper route also passes.

## Can: rhythm and payoff

| Phase / feedback | Before | Final | Why |
|---|---|---|---|
| Opening cooldown | 0.45 s | 0.45 s | Retained the useful setup window after trial tuning; anticipation starts while the player positions |
| Telegraph | 0.55 s total | 0.55 s total | Existing warning was already readable; 0.20 s tracking followed by 0.35 s locked warning |
| Lock | Sharp sound, frozen arrow | Same plus 0.09 s shell flash | Stronger visible commitment without extra delay |
| Release / charge | 0.10 s ramp, 230 px/s max, 1.15 s commitment | Preserved | Powerful committed motion without harder dodge timing or homing |
| Impact recovery | 0.20 s plus 0.08 s extra cooldown | 0.20 s, no extra cooldown | Measured return to preview 0.233 s; faster next decision |
| Ordinary stomp stagger | 0.38 s | 0.28 s | Can becomes useful sooner |
| Major impact pause | Different small frame counts; immediate midframe freeze | Three complete physics frames, 50 ms at the default 60 Hz, starting at a frame boundary | Consistent payoff; preserves the current force-transfer frame |
| Wall / force feedback | Hurt-like wall sound, radial effects near target center, generic shake | Distinct clunk/roll/low transfer cues, contact-local bursts, shell recoil/flash and scaled impulse | Cause and effect remain spatially connected |

An initial stronger force-transfer pause exposed a real scheduling bug: freezing
midcallback could stop Boulder against a panel that had not finished its motion.
The controller now processes before supports and applies pauses at frame
boundaries. All original force-chain consequences pass with hit-stop enabled.

The proposed 0.25 s opening cooldown was reverted to 0.45 s during route testing.
Shortening it did not provide a useful decision improvement. The final plan
deviation is recorded here; the preimplementation plan remains intact.

## Boulder

Before: force multiplier 1.22, friction 325 px/s², speed cap 300 px/s, visible
rotation and dust already gave a nominal 0.86 s roll / ~119 px travel from one
230 px/s Can hit. These values supplied important predictable room states.

After: all those physics values are preserved. Added a quiet velocity-scaled
rolling loop, 0.10 s contact flash, distinct low transfer impact and contact-local
particles. Loop pauses when stationary, unsupported or gameplay is paused.
Floor dust remains short and sparse. Real force-transfer and settling checks
pass, including the intentionally obstructed L2 nozzle after the first force.

Why: perceived weight improves while final position remains a planning tool.
Small contact-order differences shift L2's settled center by a few pixels;
required obstruction/clearance and the two-force sequence remain verified.

## Laser

Before: L3 18°/s and L4 16°/s, immediate occupancy-driven stopping, a fixed
0.80 s stopping diamond, 30 px L3 and 36 px L4 collectors. The L4 real unoccluded
beam window was 15.25° / 0.953 s. Tiny origin cues carried most of the feedback.

After: rotation speeds and instant stop are preserved. The lead uses remaining
Can anticipation plus physical travel to clear the pedal, and reflects at the
mechanical limits. It hides when unoccupied or when the chosen direction cannot
clear the rail boundary. It is an estimate of the current intent, not a promise
about future player movement, angle snapping or a timing meter.

L3 collector remains 30 px and its real window 25.75° / 1.431 s. L4 collector
increases to 40 px; the measured real window is 16.50° / 1.031 s. Physical blockers
still reduce the usable sector. The collector gains a subtle approach glow;
useful beam/contact becomes mint-bright. Engage, disengage and alignment use
distinct short cues. Wrong-angle cooling remains 0.28 s to suppress circuit
chatter without latching a completion flag.

Why: release timing is more consistent with the visible Can state, final-room
precision has a little more margin, and consequences can be understood spatially.
The controlled late withdrawal still fails and several earlier withdrawals pass.

## Airflow and platforms

Before: Fan visually spooled over ~0.167 s but immediately applied full force to
a worker entering its field. Its loop could be silent because power was set
before the voice existed. L4 lift waited 0.75 s before its ~0.49 s travel.

After: entry ramps force over 0.18 s and uses actual spool; lift strength 1700
and upward cap 220 are preserved. Exit clears the entry ramp immediately, with
no teleport or added drift. Flow lines still match the clipped physical column.
Loop starts reliably and gets quieter under obstruction.

L4 lift warning becomes 0.55 s. Crossing moves on contact immediately, then the
warned Can lift follows. Direct platform speeds and destinations are preserved;
there are no periodic wait cycles. Nominal trips remain ~0.35–0.69 s.

Why: entering airflow has a readable physical onset; L4 has a short staggered
consequence chain without extra artificial delays.

## Camera, audio and effects

Before: centered 640×360 framing already displayed the actor, Can, target and
consequence, but every feedback event requested ~4 px shake lasting ~0.20 s.
Each one-shot sound created/freed an audio node.

After: framing and zoom remain unchanged. Impulses are 0–2 px, roughly 0.14 s
maximum decay; settling and rotor state cues do not shake. Camera offset decays
during short clear/death feedback and clears on rebuild. The worker stays visible
during impact pause. L3/L4 captures retain the target and the relevant mechanisms.

One-shots reuse eight voices. Fan and Boulder each own one quiet loop in their
room; samples are created at build time. Demo particles cap at 128, with no
particle nodes/timers. Short effects, low loop gains and state-edge audio avoid
constant noise. Audio balance and subjective impact strength still require ears.

## Pacing, failure and transitions

| Item | Before | After | Interpretation |
|---|---|---|---|
| Current-level death delay | 0.25 s | Preserved; measured control return 0.267 s | Already cheap experimentation |
| Success transition | 0.65 s | Preserved; measured 0.65 s | Short reward, then the next room; no title-screen wait |
| Current-level R | Next deferred rebuild | Preserved; clears stale hit-stop/input state | Earlier completions remain intact |
| L1 rehearsed route | 5.95 s | 5.78 s | First force and first rebound remain quick and damage-free |
| L2 rehearsed route | 7.43 s | 7.58 s | Small extra impact/ramp time buys physical readability; no new wait cycle |
| L3 rehearsed route | 8.65 s | 8.27 s | Faster reposition and consistent withdrawal |
| L4 rehearsed route | 12.50 s | 12.02 s | Faster lift/repetition; two hits remain on this sequential plan |

These are normal-input **rehearsed simulation times**, not human completion or
learning times. The prepared/expert L4 route takes 11.33 s with zero hits.

`artifacts/polish/pacing.json` compares 15-frame route samples. No >=2 s interval
had both a stationary worker and an unchanged mechanical world. Longest such
postchange sample run was 0.25 s in L2. Stationary player time alone is not dead
time: observing rotating beam angle is part of the existing decision.

This sample audit cannot establish that a human is making a decision. An
unfavorable full sweep still takes 4.67 s in L3 or 3.75 s in L4. Speeding it up
would narrow execution margins, so these bounds were retained and are listed
for human pacing review.

## Validation and evidence

- Read every requested current system; ran and inspected the four-room baseline
  with OpenGL before editing. Baseline saved in `artifacts/polish/baseline/`.
- Ran all **32 existing test scripts**, including graphical capture scripts,
  before and after: 29 pass in both; the same three historical scripts fail.
  `demo_learning.gd` expects a narrower old receiver, `demo_route.gd` expects an
  old L1 landing at 489/190, and `demo_systems.gd` references the removed `button`
  and times out after that script error. Full logs/results are preserved under
  `baseline/tests/` and `after/tests/`; they were not rewritten to fake green.
- Final current checks: 33 rebalance system checks, the bounded rebalance audit,
  14 recovery checks and **29 focused polish checks** pass. Focused evidence
  covers real input buffering/coyote expiry, release/stomp during hit-stop,
  consistent corner/rising rebounds, immediate rotor stop, airflow entry,
  short death, held movement during transition and effect budgets.
- Input-only full sequential and expert routes pass. Each fresh room and the
  alternate upper L1 route pass. Rendered four-room route and state captures
  pass; evidence lives in `artifacts/polish/after/`.
- Objective-free sandbox exercises 30 simulated seconds through normal inputs:
  **12 charges, two rebounds, zero hits, zero deaths, zero resets** in both
  headless and rendered runs. The captured run observes eight reusable audio
  voices, 28 peak scene nodes and 10 peak particles; `sandbox_graphics.json`
  records 30.08 s including capture-boundary ticks. The 60 FPS timed run records
  exactly 30.00 simulated seconds and 30 nodes including two timing probes.
  Its gameplay physics callback interval has p95 0.104 ms and maximum 1.478 ms
  across 1800 samples. Engine physics monitor peaks at 2.642 ms after warmup;
  process monitor still peaks at 22.461 ms, so occasional rendered spikes remain
  unisolated. Startup includes a ~224 ms monitor peak. Evidence: `sandbox.json`,
  `sandbox_graphics.json` and `screenshots/`. This proves bounded repeatability,
  not enjoyment or universally smooth rendering.
- One capture run was invalidated because a background screenshot wait allowed
  235 s of unactuated simulation inside a requested 30-second exercise. Its
  failure is saved in `sandbox_capture_stall.json`. The harness now pauses the
  fixture after its physics tick while waiting for screenshots; the corrected
  rendered run passes. No game mechanics were changed to make that test pass.
- `git diff --check` passes. No deployment, commit or remote push was performed.

## Unresolved awkward or confusing moments

1. The user's feedback, “机制之间没有很深的交互”, remains a design limitation.
   Several chains have one obvious useful outcome and can resemble sequential
   activation. L4 already couples Boulder movement to airflow/laser exposure and
   optical power to Can height, but polish cannot establish deeper combination
   choices. No unrequested redesign was performed.
2. Sequential L4 still loses two health points around exposed beam/Can contact.
   This also occurred before polish. Safe preparation avoids those hits, but a
   novice may struggle to parse the spatial reversal on first encounter.
3. A wrong frozen laser angle can require another bait/reposition and several
   seconds of sweep. The new preview is most reliable after intent locks; early
   direction changes require rereading the visible state.
4. L2 intentionally needs a second force to clear the Boulder left at the nozzle.
   It is a world-state decision, but a novice may first interpret it as slow or
   failed activation. Sound/airflow readability needs human confirmation.
5. Synthesized rolling, airflow and telegraph sounds have distinct functional
   cues but have not received a human listening/mix review. Rendered checks verify
   playback/node bounds, not perceptual quality.
6. No novice completion timing, fatigue judgment or subjective fun result exists.
   Physics callback measurements/node bounds are smoke evidence. The engine's
   startup and occasional process-time peaks need a separate renderer/platform
   profiling session if visible stutter persists; this is not a broad hardware
   benchmark or proof that every frame spike is eliminated.

## Final acceptance gates

| Requested gate | Functional / visual evidence | Human verdict |
|---|---|---|
| 1 Responsive movement | Response/braking and input-edge fixtures pass | Pending |
| 2 Satisfying forgiving bounce | Fixed launch, corner/rising tests, rendered compression/burst | Pending |
| 3 Clear charge rhythm | Fixed warning/commitment and 12 sandbox charges | Pending |
| 4 No boring recovery | 0.233 s recovery-to-preview measured | Pending |
| 5 Powerful impacts | 50 ms pause, contact feedback, small impulse | Pending |
| 6 Heavy predictable Boulder | Preserved physics and force/settling tests pass | Pending |
| 7 Understandable laser timing | Stop/window/withdrawal checks pass; preview/glow inspected | Pending |
| 8 Decision-supporting camera | Full-room L3/L4 captures inspected | Pending |
| 9 No platform cycle waits | Direct paths retained; warning shortened | Pending |
| 10 Fast death/restart | 0.267 s control return and local R pass | Functionally passed |
| 11 Fast transitions | 0.65 s and held movement/stale-jump fixture pass | Functionally passed |
| 12 Better second-to-second play | Four routes, input improvements and pacing samples | Pending |
| 13 Enjoyable 30-second core loop | Input-only sandbox repeated without damage/reset | Pending |

Human review should play the normal four rooms and `polish_sandbox.tscn`, listen
to the mix, and explicitly judge bounce pleasure, warning clarity, L4 parsing and
laser waiting. This report does not substitute automation for that final review.
