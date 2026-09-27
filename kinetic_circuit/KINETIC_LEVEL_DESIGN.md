# Kinetic Clockwork level design

## Structure gate

All three candidates use the same rules: attacks follow held up, down, left, or
right input. An airborne downward strike transfers the player's horizontal speed
to a ram or, less efficiently, to the carriage and rebounds the player;
horizontal attacks transfer a ram-strength push directly to the carriage. Rams
transfer their current speed on contact; the carriage coasts, carries the
player, and rebounds from its rail stops. Each opening ram has two visible
health pips, so its first strike still demonstrates momentum transfer while a
second strike offers a quick combat solution. Airborne downward strikes also
pogo from floor spikes, turning precise hazard contact into an alternate
recovery or traversal option while ordinary spike contact costs health and
returns the player to their last safe platform even during combat-damage
invulnerability. Solid machinery beneath the animated teeth prevents recovery
frames from turning the spike bed into a fall-through surface. Once collected,
the Dash Core is refreshed by every successful downward pogo, allowing dash
routes to flow through hazards, enemies, and kinetic objects into another dash.

| Candidate | Control density and waiting | Recoverable states and outcomes | Mistakes, surprise, and mastery | Rectangle test |
| --- | --- | --- | --- | --- |
| **Long rail relay** — a horizontal pursuit built around one continuously moving carriage and rams approaching from both directions | High control density; little forced waiting because the player can ride, chase, redirect, or correct moving objects | High. Safe work islands, direct carriage corrections, two rail stops, and either ram can rescue bad momentum. Launch strength, collision order, and player position produce genuinely different continuations | A bad counter-impact sends the entire situation backward instead of clearing it. Skilled players can intercept early, create a later rear boost, or use a faster stop rebound | Strong: motion, spacing, and arrows communicate the whole level |
| **Rising transfer shaft** — stacked horizontal rails whose momentum choices are carried upward by the player | Medium-high control density, but medium waiting while lifts and carriages arrive at transfer floors | Medium. Falling revisits a lower tier, but crossing a tier boundary partially resets the physical problem | Good route invention, but mistakes too often feel like lost height rather than a new machine state | Good, although vertical ownership is harder to read without art |
| **Compact switching yard** — one arena where a carriage and two rams repeatedly exchange roles | Very high control density and low-to-medium waiting | Very high. It permits the most collision orders and local recoveries | Excellent emergence, but the objective becomes opaque and repeated use of one space trends toward a machine puzzle with a known answer | Excellent as a sandbox, weaker as a continuous level |

The long rail relay is the strongest structure. It combines the switching
yard's expressive collisions with a legible journey, and the consequence of
each interaction physically enters the next section.

## Kinetic relay situations

1. **Launch and catch.** The player redirects the launch ram, rebounds, and
   intercepts a carriage that is already moving. A weak launch can be repaired
   by striking the moving carriage; a strong launch creates a faster boarding
   problem. An extended starting runway places the player beyond the ram's
   detection range, giving them a safe approach before the encounter.
2. **Opposing ram.** The same carriage enters a head-on encounter. The player
   can redirect the counter-ram before impact, alter it late, or allow the
   collision and recover the reversed carriage. The safe central floor lets a
   missed landing become a chase instead of a restart.
3. **Use the return.** The carriage returns left either from the far stop or
   because the displaced counter-ram comes back and hits it. The returning
   carriage is the launch point through the gantry and into the Dash Core.
   Extra momentum can create a faster route rather than only an overshoot
   penalty.
4. **Dash relay.** The Dash Core restores the directional target dash from the
   earlier Clockwork Ascent levels. Targets are limited to a 160-pixel range and
   shown with a circle instead of an aim-cone overlay. A right-click close to an
   enemy provides direct mouse selection while preserving the same range and
   line-of-sight restrictions. If no directional target is valid, the same
   keyboard or gamepad input produces a short directional dash. Four shielded
   enemies form the only route over the final spike rail, requiring consecutive
   aimed hits and controlled exit momentum before the tower entrance.
5. **Vertical Works.** A checkpoint converts the dash landing into a vertical
   platforming climb. Nine narrow ledges alternate left and right, partial spike
   strips constrain safe takeoff and landing space, and two horizontally moving
   platforms require timing before the summit transfer. Two bobbing Spring Drones
   and two horizontally sweeping Gearwings introduce optional moving anchors;
   both enemy types accept target dashes and downward pogo strikes. The camera
   remains vertically locked through the preceding horizontal relay and opens
   upward only after the player enters this section. Faster bobbing and sweeping
   cycles keep these anchors active, while coil compression, wing flaps, rotating
   gears, and pulsing cores make their movement phase readable at a glance.
6. **Precision Foundry.** The former summit becomes a transfer into narrow,
   alternating platforms over a continuous spike floor. A moving transfer
   and charging Tower Guards force the player to combine conventional jumps,
   free dashes, target selection, and attack timing instead of repeating the
   Vertical Works rhythm. Guards clearly wind up a fast committed rush and
   become stunned after missing, creating an intentional counterattack window.
7. **Cannon Gallery.** Staggered platforms create exposed firing lanes for three
   Shooter enemies. They patrol their ledges, display a locked firing line, and
   release two-round bursts. Their projectiles collide with terrain and damage
   the player, but an attack reverses a bullet along its incoming trajectory;
   reflected shots can damage any enemy they reach. This turns defense into a
   ranged routing tool rather than adding a separate weapon.
8. **Crown Ascent.** A set of short ledges rises through a reversal jump,
   a moving transfer, charging guards, and another shooter. Several 45-pixel
   rises require an upward or diagonal free dash, making the endgame explicitly
   test the movement kit before the route turns downward.
9. **Descent Foundry.** Eleven ledges alternate across a deep shaft while nine
   Descent Guards quickly acquire the player, telegraph, and commit to horizontal
   charges. Dropping through the formation turns descent speed and landing choice
   into combat resources instead of making downward travel a passive corridor.
10. **Razor Transit.** Six moving platforms weave over continuous spike beds
    while three travelling saws cross the safe routes. Short static islands allow
    recovery, but progress depends on moving-platform timing, pogo control, and
    deliberate dash distance.
11. **Aerial Core.** A winged core grants a double jump that refreshes on landing
    and on every successful pogo. Three moving platforms and elevated Sky Hunters
    immediately teach the ability: their high patrol paths can only be reached by
    combining the new jump with a dash or downward attack.
12. **Titan Regulator.** A large arena mixes high and low ledges, moving
    platforms, travelling saws, and a continuous walkable floor around one
    grounded Titan. Its fifteen health forms one pool damaged by regular and
    pogo strikes or reflected bombs, without tool-specific armor. The Titan is
    not a target-dash anchor and its body is harmless outside its explicit
    attacks. It cycles through a telegraphed rush, a charged two-hit hammer combo
    with continuous swing poses, and bomb throws, enrages at half health, and
    opens the barred exit when defeated.
13. **Summit Ascent.** Seventeen staggered ledges, four moving platforms, three
    travelling saws, and mixed chargers, shooters, and aerial hunters form the
    longest sustained climb. Four intermediate checkpoints keep failures local,
    while two closely spaced approach ledges make the broad top deck reliably
    reachable. The Clockwork Core sits at the platform's center and ends the run
    when collected.

There are no walk-only corridors between these situations. The launch ram can
continue pushing the carriage into the counter encounter, the displaced
counter-ram can cause the final return, and every later transfer introduces a
new hazard, enemy formation, movement test, or powerup application.

## Presentation language

The full route reads as one operating clockwork foundry rather than abstract
rectangles. Dark gear trains counter-rotate behind the playable plane, linked
pistons cycle at offset phases, chain runs traverse the walls, and the platforms
use brass conveyor caps, riveted panels, rollers, and cross-braced steel. These
background mechanisms remain lower contrast than hazards and actors so their
motion adds life without obscuring play. The procedural score follows the same
language with bell-like arpeggios, a warm minor-key mechanism, restrained metal
percussion, and a much quieter alternating tick-tock ambience.

## System-led discovery

The first route probe deliberately allowed the counter-ram to hit the carriage
without intervention. The carriage travelled back into the original launch
ram, which struck it from the left and relaunched it. This was understandable,
repeatable, and useful, but was not part of the initial route plan.

The level was changed to support it: the launch ram's range now extends onto a
wider first recovery island. A failed counter interaction therefore changes
which earlier object is useful instead of forcing a reset. A second discovered
outcome was retained at the finish: the redirected counter-ram can rebound and
create the carriage's useful return before the carriage reaches its own stop.

## Ruthless edit check

- Removing launch and catch loses moving interception and player-to-ram setup.
- Removing the opposing ram loses head-on transfer, reversal recovery, and the
  relaunch discovery.
- Removing use the return loses deliberate over-momentum and the reinterpretation
  of leftward motion as progress.
- Removing the dash relay loses the powerup payoff and its chained directional
  execution test.
- Removing the Vertical Works loses the axis change, alternating precision
  jumps, dual-purpose aerial enemies, and its first moving-platform timing.
- Removing the Precision Foundry loses sustained dash-assisted precision
  platforming and the first enemies that actively charge along the route.
- Removing the Cannon Gallery loses projectile reflection and combat across
  terrain-separated firing lanes.
- Removing the Crown Ascent loses the final mixed-mechanic difficulty peak and
  the transition from the first endgame arc into the deeper route.
- Removing the Descent Foundry loses fast downward combat and the dense charger
  formation built around choosing landing lanes under pressure.
- Removing Razor Transit loses the route's most concentrated moving-platform,
  spike, and travelling-saw timing challenge.
- Removing the Aerial Core loses the second movement powerup, double-jump
  teaching sequence, and enemies positioned around its reach.
- Removing the Titan Regulator loses a focused melee-spacing boss test and the
  arena whose geometry changes how its rush, hammer combo, and bombs are read.
- Removing the Summit Ascent loses the long-form combination of every movement,
  combat, reflection, and hazard skill before the Clockwork Core payoff.

Each section therefore contributes a different interaction. The fourth section
changes the movement kit after the kinetic relay has paid off, and its shielded
targets make the new powerup necessary rather than optional. The fifth changes
the level's axis; the next three establish precision dashing and projectile
reflection; and the final five add descent combat, a hazard gauntlet, double-jump
mastery, a focused melee boss examination, and a culminating ascent.
