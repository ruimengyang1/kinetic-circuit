# Game changelog

This file records the history of the game, including discarded prototypes. It is
ordered newest first within each date. Commit links use abbreviated local Git
revisions because the repository may be moved or forked.

## Unreleased

- Replaced the sequential four-shutter ascent with a folded Intake, Pressure,
  Signal, and shared-Core circuit; removed the playable Titan encounter.
- Let a normal Guard charge power Pressure, hit retracting teeth, then remain
  useful for Core; reflected Shooter shots can power Signal and Core, with
  repeatable manual impacts available when either source is lost.
- Saved socket charges and living source states at checkpoints, and made Core
  alignment quiet hostile actors and clear projectiles for the exit climb.
- Added a sectional title, lower-left integrity dial, world conductor states,
  contextual Intake hint, revised actor and projectile silhouettes, and a
  synchronization completion view.
- Rebuilt the playable prototype as Clockwork Tower: Kinetic Circuit, a continuous
  four-chamber zigzag ascent with a new machine objective, service checkpoints,
  conductor-linked shutters, and a clockwork color hierarchy. The old course
  remains available as a separate scene.
- Added one reusable circuit socket: player impacts, reflected shots, and
  charging Guard/Titan actors contribute visible force to the same mechanism.
  Charges open routes while the existing Guard/teeth and Titan/saw interactions
  create safe crossing windows; the Signal Gallery retains a slower manual
  route if its Shooter is removed.
- Added small systemic callbacks to existing Summit encounters: committed Guard
  charges now take damage and enter their normal stun when baited through spike
  strips, the Titan's rush can likewise be interrupted by travelling saws, and
  one Shooter lane now crosses a Sky Hunter so a learned bullet reflection can
  be deliberately turned against it.
- Added four checkpoints throughout Summit Ascent and a closely spaced final
  approach so the top deck is reliably reachable. The summit now holds an
  animated Clockwork Core at the platform center; collecting it ends the run
  with the completed time and wins the game.
- Simplified the Titan Regulator to fifteen universal health points: regular,
  downward, and reflected-projectile strikes all damage the same health pool.
  Removed target dashing and its red vulnerability marker from the Titan, made
  passive body contact harmless, and added continuous hammer motion and trails
  throughout both swings.
- Added a clearly labeled testing warp immediately left of the starting player.
  Entering it grants the Dash and Aerial Cores, moves the active checkpoint to
  the Titan arena, and teleports the player there for faster iteration.
- Replaced Kinetic Clockwork's text-heavy HUD with three top-left health icons,
  a concise top-right timer and slow-motion meter, and a one-time opening prompt
  containing only the WASD movement and J attack controls.
- Rebuilt floor spikes with animated glowing teeth, outlines, inset highlights,
  reinforced machinery, and solid foundations. Spike hazards now continue to
  damage and recover the player through ordinary invulnerability frames without
  allowing the player to fall through the bed.
- Reworked the penultimate arena around a single grounded Titan Regulator,
  removing the flying Warden and replacing the central spike pit with a
  continuous walkable floor.
- Expanded the Titan with a charged two-hit medium-range hammer combo,
  reflectable arcing bomb throws, a longer and much more visible dash windup,
  distinct animations for each attack and recovery, and a larger hitbox that
  matches its body, wheels, and hammer stance.
- Added a large pulsing red marker above the Titan during its dash-vulnerable
  armor phase so the dash window is readable at gameplay scale.
- Changed target dashes into combat enemies to rebound upward at pogo height
  instead of carrying the player through or past them, and added brief
  post-impact invulnerability to prevent immediate contact damage. Relay-chain
  targets still preserve forward momentum.
- Fixed charging Sky Hunters visibly teleporting when they returned to patrol;
  their patrol, charge recovery, and bobbing now use continuous movement.
- Added viewport-aware rendering to Kinetic Clockwork. Procedural gears,
  chains, gridwork, platform detailing, spike teeth, and the arena gate now
  generate draw commands only near the camera instead of across the entire
  11,500-by-1,956-pixel world, and scenery animation refreshes at a stable 30
  Hz while gameplay remains full-rate.
- Added distance-based runtime sleeping for off-screen enemies, moving
  platforms, the rail carriage, and travelling saws. Nearby actors wake well
  before entering dash or combat range, teleports force an immediate refresh,
  and a performance regression suite verifies local activation and render
  bounds.
- Extended Kinetic Clockwork with five fully connected areas after Crown
  Ascent, increasing the world to more than 11,500 pixels wide and 1,700 pixels
  tall. Added the charger-filled Descent Foundry, spike-and-machinery Razor
  Transit, Aerial Core climb, Twin Regulators arena, and long Summit Ascent.
- Added the Aerial Core double-jump powerup. It grants one additional airborne
  jump, refreshes on landing, pogo, hazard recovery, and checkpoint revival,
  has a distinct winged player effect and pickup presentation, and persists
  through late-level checkpoints.
- Added nine fast Descent Guards, high-altitude diving Sky Hunters, and eight
  mixed enemies on the Summit Ascent. New enemies use responsive windup,
  charge, flight, recovery, and enrage animations and can serve as pogo or dash
  targets while navigating the expanded route.
- Added the Titan and Warden Twin Regulator bosses, each with twenty segmented
  health points. Their armor advances through five required weapon strikes,
  five dashes, five downward pogos, and five reflected projectiles; their
  ground rush, aerial swoop, spread-fire, and faster half-health patterns force
  use of the complete movement and combat kit before the summit gate opens.
- Added six Razor Transit moving platforms, three Aerial Core lifts, three
  shifting arena platforms, four Summit Ascent transfers, eight animated
  pogoable saw traps, extensive spike patterns, and five new checkpoints.
  The final climb ends at a deliberately empty summit reserved for future work.
- Added synthesized double-jump, powerup, boss-defeat, and mechanical gate
  sounds, with multi-projectile boss volleys sharing one balanced firing cue.
  Added distinct procedural art for the five regions, including
  color-coded foundry chambers, animated background machinery, winged Aerial
  Core effects, boss armor prompts and health bars, saw gears, and a barred
  arena lock.
- Added an expansion regression suite covering all five areas, moving hazards,
  checkpoints, charger response, Double-Jump Core behavior, high aerial enemy
  placement, both twenty-hit multi-tool boss fights, gate unlocking, and the
  empty future summit. Expanded audio coverage from ten to fourteen cues.
- Documented the current presentation and gameplay changes in the README and
  Kinetic Clockwork design notes, including destructible opening rams, run
  timing, defeat feedback, reduced dash overshoot, the animated foundry theme,
  procedural music, and clock ambience.
- Expanded automated coverage for two-hit ram health and restoration, real-time
  timing during slow motion, completion-time messages, player and enemy defeat
  animations, death-camera cleanup, grounded-enemy dash clearance, and the
  generated music and tick-tock loops.
- Lengthened the defeat hold before revival to 0.72 seconds in the original
  levels and 0.68 seconds in Kinetic Clockwork so the new knockback, breakup,
  zoom, and failure-message sequence can finish visibly.
- Refined run-timer behavior and presentation: deliberate full-run restarts
  reset Kinetic Clockwork's timer, checkpoint recovery retains the accumulated
  run time, both completion messages include tenths, and the original HUD's
  status text was shortened to make room for the labeled timer.
- Fixed the two opening Kinetic Clockwork rams having effectively infinite
  health. Each now shows two health pips, retains its momentum-transfer behavior
  on the first hit, breaks apart on the second, and revives correctly when the
  encounter resets.
- Added a real-time run timer to both the original levels and Kinetic
  Clockwork, shown to tenths of a second during play and on completion. Slow
  motion no longer makes recorded runs appear artificially shorter.
- Added a dramatic player defeat sequence with a forceful knockback, spinning
  breakup animation, camera zoom, and timed system-failure message. Revival
  now explicitly restores the camera, collision, animation, and UI state.
- Added animated enemy defeats: destroyed machines now launch, spin, break into
  glowing mechanical fragments, and fade before being removed.
- Reduced grounded-enemy target-dash overshoot to a short 18-pixel clearance
  past the enemy, preserving safe separation without throwing the player far
  beyond the encounter.
- Rethemed every level background and platform as an operating clockwork
  foundry. Added animated counter-rotating gear trains, spokes, linked pistons,
  chain runs, pipes, conveyor trim, rivets, rollers, panel seams, and steel
  bracing across the original stages, Kinetic Clockwork, moving lifts, and the
  rail carriage.
- Added an original looping mechanical score with chord, bass, arpeggio, melody,
  kick, and metallic percussion layers. Added a separate alternating tick-tock
  ambience mixed well below the music and gameplay effects; both loops follow
  pause and slow-motion playback.
- Made every successful downward pogo refresh the Dash Core, including pogos on
  all enemy types and kinetic objects. Successful target dashes now carry the
  player fully through grounded enemies before ending, preventing post-dash
  overlap damage while retaining exit momentum and solid-terrain collision.
- Added state-driven procedural animation to every enemy family: walkers now
  stride, bob, lean, and swing their arms; drones spin rotors; relays pulse;
  Spring Drones squash and extend; Gearwings flap and rotate; and heavy enemies
  lean, recoil, roll, trail, and stagger with their current action. Increased
  patrol and flight speeds and shortened ram, guard, and shooter response times
  while retaining their anticipation and recovery tells.
- Reworked late-game enemy behavior. Tower Guards now telegraph faster committed
  rushes and become visibly stunned after a missed charge. Shooters now patrol
  their platforms, show a locked aim line, fire two-round reflectable bursts,
  and pause between volleys, with clearer charge, stun, aim, and muzzle effects.
- Fixed regular horizontal attacks failing to damage non-kinetic enemies,
  including late-game Tower Guards and Shooters. Reflected bullets now reverse
  their incoming trajectory back toward their source instead of adopting the
  player's attack angle.
- Changed spike and fall failures to cost one health and return the player to
  the last safe platform they occupied, including moving platforms. The level
  now returns to the latest checkpoint and rebuilds its state only when health
  reaches zero.
- Recentered the camera vertically on the player after the Vertical Works. The
  tower's upward look-ahead now eases out across the summit transfer instead of
  leaving the three later areas framed too high.
- Extended Kinetic Clockwork far beyond the Vertical Works with three major
  endgame regions: the spike-lined Precision Foundry, projectile-focused Cannon
  Gallery, and dash-assisted Crown Ascent. Added twenty short platforms, three
  moving transfers, three area checkpoints, and relocated the final bell to the
  end of the new route.
- Added four charging Tower Guards and four Shooter enemies across the endgame.
  Shooters fire terrain-blocked projectiles that damage the player but can be
  redirected with directional attacks; reflected bullets travel along the
  strike direction and damage enemies. Added distinct firing and reflection
  effects and sounds, plus checkpoint restoration for enemies and bullets.
- Added two enemy types to the Vertical Works: bobbing Spring Drones and
  horizontally sweeping Gearwings. Both serve as target-dash anchors, support
  downward pogo rebounds, damage the player on ordinary contact, and respawn
  with the tower checkpoint.
- Made successful spike pogos refresh a spent dash after the Dash Core has been
  collected, allowing pogo-to-dash route extensions.
- Widened attack collision again to cover more of the visible blade arc:
  vertical strikes now use a 24 by 18 pixel box and horizontal strikes use a
  28 by 24 pixel box.
- Added spike pogoing across the original stages and Kinetic Clockwork: an
  airborne downward strike against floor spikes now gives the full rebound,
  while ordinary spike contact remains lethal.
- Lowered the overall sound-effects mix by another 5 dB, for a total 10 dB
  reduction from the rebuilt sound bank's original playback level.
- Lowered the overall sound-effects mix by 5 dB while preserving the relative
  balance between movement, combat, checkpoint, and victory cues.
- Rebuilt all eight generated sound cues with distinct layered synthesis: airy
  jump and dash movement, a spring-like rebound, weightier impacts, a brighter
  weapon connection, a descending death cue, and multi-note checkpoint and
  victory phrases. Raised synthesis quality to 32 kHz and added subtle pitch
  variation to frequently repeated action sounds.
- Reduced the slow-motion meter from 91 by 7 pixels to a compact 53 by 5 pixel
  display and tightened its label so it occupies less of the playfield.
- Added mouse target dashing: after collecting the Dash Core, right-clicking
  within 14 pixels of a reachable enemy dashes directly to it. Mouse selection
  retains the existing 160-pixel player range and line-of-sight restrictions.
- Changed the player's legs from near-black to warm copper so the idle and run
  silhouettes remain readable against the level's dark blue machinery.
- Added procedural idle and movement animation to the player, including idle
  breathing, blinking, and scarf motion plus a running body bounce, alternating
  stride, arm swing, and stronger scarf movement.
- Kept horizontal attack collision active through the visible blade sweep so
  advancing into an enemy during the latter half of a swing still connects,
  without lengthening the attack's forward lunge.
- Enlarged the directional attack hitboxes slightly so weapon strikes connect
  consistently across the full visible blade swing.
- Smoothed the camera's vertical-limit change at the entrance to the Vertical
  Works so the view rises gradually instead of jolting upward at the boundary.
- Fixed attack feedback so downward rebound strikes use the same dedicated hit
  sound and impact effect as horizontal and upward hits. The player's facing is
  now visually locked through the full swing so reversing direction during the
  follow-through no longer flips or breaks the animation.
- Added a short recovery between player attacks so swings cannot be rapidly
  spammed, and gave connected weapon strikes a louder layered crack and metallic
  ring distinct from the generic damage sound.
- Replaced the player's tiny static attack jab with a complete anticipation,
  sweeping slash, and follow-through animation. Successful attacks now finish
  through the hit with a bright impact arc and directional sparks, while dashes
  use a tucked launch pose, layered afterimages, and directional speed streaks.
- Expanded automated coverage for the complete Kinetic Clockwork route,
  directional attacks, target and fallback dashes, health and reset behavior,
  reduced spike collision, opening spawn safety, section-based camera limits,
  the Dash Core relay and Vertical Works, and slow-motion toggle, drain,
  recharge, depletion, audio speed, and HUD feedback.
- Updated the README, implementation plan, and Kinetic Clockwork design notes
  to document the current controls, momentum interactions, checkpoints, Dash
  Core route, Vertical Works, camera behavior, and rechargeable slow motion.
- Changed Q slow motion from hold-to-use to a toggle backed by a visible
  four-second meter. The meter drains in real time while active, switches slow
  motion off at zero, and recharges during normal gameplay.
- Added hold-to-slow action on Q. While held during play, the full simulation
  and audio run at 35 percent speed with a blue tint and on-screen indicator;
  releasing Q or leaving active play immediately restores normal speed.
- Locked the Level 2 camera vertically throughout the horizontal relay; upward
  camera tracking now activates only inside the Vertical Works.
- Extended the opening platform and moved its spawn farther from the launch
  ram, outside its detection range, so the player is not attacked immediately.
- Changed attacks to follow held left, right, or up input on the ground and all
  four directions in the air. Neutral and grounded-down attacks slash in the
  facing direction, airborne downward hits retain their rebound, and horizontal
  carriage hits retain ram-strength momentum transfer.
- Removed the three-line dash aim guide while retaining the circle around a
  valid target, reduced target acquisition range from 175 to 160 pixels, and
  added a short directional fallback dash when no enemy can be acquired.
- Extended Kinetic Clockwork beyond the dash relay into the Vertical Works, a
  required climb of nine narrow ledges, two moving platforms, four spike strips,
  and repeated direction-changing jumps to a summit bell over 400 pixels above
  the tower entrance. Added a checkpoint at the base of the climb.
- Made the dash target circle appear only when directional input places an
  enemy inside the dash cone; shielded relays now use corner armor marks instead
  of an always visible circle.
- Added a grounded forward attack on the existing attack button. It lunges in
  the player's facing direction and gives the carriage the same strong momentum
  transfer and rebound as a charging ram, providing recovery when no ram is in
  position.
- Changed kinetic ram and relay contact from an instant defeat to one point of
  damage, using the player's three health points, knockback, and brief
  invulnerability; the HUD now displays remaining health.
- Fixed death resets so the rail carriage returns to its spawn transform with
  zero velocity at both the level entrance and the Dash Core checkpoint.
- Inset the kinetic level's spike collision rectangles within their visible
  artwork to make edge and near-tip contacts less punishing.
- Restored the directional, momentum-preserving target dash from the earlier
  Clockwork Ascent levels as a collectible Dash Core near the end of the
  Kinetic Clockwork relay.
- Extended the active level beyond the return gantry with a spike-spanning chain
  of four shielded relay enemies that can only be broken by dashing through them.
- Added a checkpoint at the Dash Core so failures in the new relay section
  restore the powerup and enemies without replaying the full kinetic sequence.
- Expanded the Kinetic Clockwork experiment from one room into a continuous
  three-part rail relay built around the same persistent carriage.
- Added an opposing ram, a scrolling camera, recovery islands, and an exit
  gantry reached by using the carriage's leftward return.
- Extended the launch ram's range so a carriage reversed by the opposing ram
  can return to it and be relaunched instead of forcing a restart.
- Reduced carriage friction for the long rail, keeping objects in motion while
  preserving direct strike corrections and rail-stop rebounds.
- Added a one-room Kinetic Clockwork gray-box prototype as the project's launch
  scene while preserving the original two-level game scene.
- Made downward strikes transfer the player's horizontal momentum into the
  prototype ram and heavy rail carriage. The persistent ram can then transfer
  its current momentum into the carriage on contact.
- Added deterministic carriage friction, damped rail-stop rebounds, direct
  strike corrections, quick room resets, and temporary velocity diagnostics.
- Built a compact test room with a safe starting ledge, spike rail, movable
  carriage, charging ram, and upper-right exit to test undershoot, controlled
  pushes, overshoot, and recovery from imperfect inputs.

## 2026-09-18

### Directional dash targeting (`60af703`)

- Changed the level-two dash from automatic nearest-target selection to
  directional aiming with the keyboard, D-pad, or analog stick.
- Limited valid dash targets to visible enemies within 175 pixels and a
  35-degree cone around the player's aim.
- Added an aim-cone guide and target highlight, and revised the HUD and in-level
  instructions to teach the new controls.

### Relay Shaft and level selection (`23dc870`)

- Expanded *Clockwork Ascent* from one level to two with the Relay Shaft, a
  longer stage built around chains of relay enemies, spike gaps, crushers, and
  three checkpoints.
- Added the target dash. It homes toward a visible relay enemy, defeats it on
  contact, carries some entry momentum through the hit, and refreshes after a
  successful connection so dashes can be chained.
- Added dash-ready HUD feedback, dash effects and sounds, and relay-enemy visual
  states.
- Added a level selector to the title and completion screens. Finishing level
  one unlocks level two and saves that unlock in `user://progress.cfg`.
- Made checkpoints, goals, camera limits, respawning, and completion flow work
  independently for either level.

### Rebound and crusher corrections (`47efc06`)

- Made crushers solid moving bodies with separate lethal spike hitboxes, so
  their movement and contacts are handled by physics instead of an approximate
  distance check.
- Stopped jump-button release from shortening a rebound, downward strike, damage
  knockback, death, or respawn motion by tracking whether a normal jump is still
  eligible for a variable-height cut.
- Added focused integration coverage for rebound height and the corrected
  crusher behavior.

### Clockwork Ascent vertical slice (`9809cea`, integrated by `d6b581b`)

- Replaced the thread-swinging prototype with *Clockwork Ascent*, a side-view
  pixel-art platformer rendered at a 384 x 216 internal resolution.
- Added momentum-based running, variable jump height, coyote time, jump
  buffering, an airborne downward strike, and upward rebounds from enemies and
  gold clockwork devices.
- Built the Clockwork Tower stage with platforms, spikes, moving platforms,
  timed crushers, rebound devices, checkpoints, and a bell goal.
- Added three enemy types: patrolling walkers, hovering drones, and charging
  sentries with a telegraphed windup.
- Added three-point health, damage knockback and invulnerability, fall and hazard
  deaths, checkpoint respawns, pause/retry flow, a timer and HUD, title and win
  overlays, particles, and generated sound effects.
- Added keyboard and gamepad controls plus smoke, route, interaction, and
  screenshot checks.
- Added the game's design and implementation brief in `GAME_PLAN.md`.

### Prototype reset and branch transition (`abc3a7a`, `d6b581b`)

- Removed the Wind Effigy implementation, its generated art and audio, design
  notes, playtest materials, and recovery bundle from the main branch.
- Merged the Clockwork Ascent branch, making that vertical slice the active game.

### Wind Effigy thread playground (`30e8be7`)

- Reworked the earlier 3D experiment into *Wind Effigy*, a 30–60 second
  side-view swinging playground intended to test whether the core interaction
  was enjoyable.
- Added running, buffered/coyote-time jumping, mouse-aimed Wind Thread
  attachment, momentum-preserving release, roof checkpoints, recovery ledges,
  an optional high route, and an airborne two-anchor chain.
- Added three switchable feel profiles, retry and full-restart controls, and a
  HUD showing speed, thread tension, attempts, and elapsed time.
- Added a puppet sprite, generated audio, art studies, a design foundation,
  human playtest instructions, and automated probes for constraint stability,
  landing windows, timing, and anchor chaining.
- Preserved the preceding Momentum Lab prototype in a Git recovery bundle before
  replacing it.

## 2026-09-17 to 2026-09-19

### Momentum Lab greybox (`6a228f7`)

- Created a third-person momentum playground for redirecting speed around rigid
  tether anchors, storing and returning energy with elastic bamboo, and
  transferring motion into a resonant bell.
- Added camera-relative movement, orbit camera controls, jumping with coyote time
  and input buffering, directional dash, hold-to-attach tethering, preserved
  swing velocity on release, and respawning.
- Built multiple anchor chains, alternate routes, a low recovery floor, a goal
  bell, debug feedback, placeholder sound effects, and reference art.
- Added automated probes for the first swing, bamboo behavior, and momentum
  transfer.

> The commit's authored date is 2026-09-19 in UTC+08, which corresponds to
> 2026-09-18 in this repository's later UTC-04 working timezone.

### Project foundation (`ce11fd8`, `7456c70`, `d695b22`)

- Created the repository and an initially empty Godot 4.7 project named *Slop*.
- Added the project icon, editor and Git settings, and local Codex/Godot tooling
  configuration. The follow-up commit corrected that tooling configuration; it
  did not change gameplay.

## Maintenance rule

Every future change that affects gameplay, levels, controls, balance, content,
presentation, audio, player-visible behavior, or game-facing bug fixes must add
an entry under **Unreleased** in the same change. Replace “No game changes yet”
when adding the first entry. Keep entries factual and player-focused, and never
delete historical entries when a feature is removed; record the removal as a new
change instead. Documentation-only, test-only, and internal refactors need an
entry only when they alter or clarify player-visible behavior.
