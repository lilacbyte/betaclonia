# Betaclonia (fork of 'clonecraftlibre')

(Yes, this is a fork on top of a fork on top of 2 to 3 other forks... Lots of forks....)

Betaclonia is a heavily customized Mineclonia fork focused on Minecraft b1.7.3 style. This project intentionally removes or rewires large chunks of post-Beta gameplay and content.

Fork base: Mineclonia `0.109.3`

## Project Direction

This fork is **not** trying to track modern Minecraft parity.
It is being shaped into a Beta-flavored experience with:

- simpler progression
- aggressive content pruning
- flatter / less extreme terrain profile
- dungeon-first loot progression for selected items
- fewer high-overhead generation systems
- food stack size is forced to `1`
- golden apple crafting is removed

### Combat, durability and armor

- you can enable sprinting and it has a stamina bar ([texture credit](https://content.luanti.org/packages/drkwv/minetest_wadsprint/))
- armor HUD uses a classic 10-icon / 20-point bar and updates from armor state
- armor points are durability-weighted by remaining condition
- armor effects :
  - leather: movement speed bonus
  - gold: reduced fall damage
  - copper: reduced fire damage
  - chainmail: extra protection
- weapon durability is consumed on:
  - block break flows (existing logic)
  - mob hits
  - player hits

special tool effects:

- copper sword: ignites target
- golden pickaxe: silk touch
- copper shovel: smeltery

### drops

- zombie drops 1 feather
- chicken drops 1 feather
- zombified piglin is active in Nether and drops a feather
- pig drops are set to `0..2` raw meat
- sheep drop wool only
- rabbit drops rabbit hide

Overworld dungeons include curated Beta-style loot additions such as:

- apples
- very rare golden apples
- melon/pumpkin seeds
- potato items
- music discs

Nether dungeon path:

- nether-brick themed dungeon internals
- wither skeleton spawners
- nether wart loot
- rare nether music discs including pigstep

### Reintroduced curated content

re-adds selected non-Beta content intentionally where it improves progression variety:

- infdev pyramids
- beta 1.8.1 empty villages
- netherite tools
- copper ore, raw copper, ingots
- copper tools
- copper armor
- cherry/pale wood sets present as curated content

## Credits and Legal

See:

- `CREDITS.md`
- `LEGAL.md`
- `LICENSE.txt`
- `API.md`

