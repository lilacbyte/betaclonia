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

## Current Beta Conversion (Implemented)

### Global gameplay rules

- Hunger is disabled (`mcl_hunger.active = false`).
- Food stack size is forced to `1`.
- Golden apple crafting is removed.
- chest boats are disabled (items/crafts/entities).
- End progression is removed.
- Legacy custom beta terrain generators are force-unregistered at startup (to avoid slow generation regressions).

### Removed

-  horses and horse armor 
- ender chests
- slime blocks

### Combat, durability and armor

- armor HUD uses a classic 10-icon / 20-point bar and updates from armor state
- armor points are durability-weighted by remaining condition
- armor effects :
  - leather: movement speed bonus
  - gold: reduced fall damage
  - copper: reduced fire damage
- weapon durability is consumed on:
  - block break flows (existing logic)
  - mob hits
  - player hits

special tool effects:

- copper sword: small chance to ignite target
- golden pickaxe: Silk Touch-like behavior

### drops

- Zombie drops 1 feather
- chicken drops 1 feather
- zombified piglin is active in Nether and drops a feather
- pig drops are set to `0..2` raw meat
- sheep drop wool only
- rabbit drops rabbit hide

### Item naming and food simplification

- beef item :
  - `Raw Meat`
  - `Meat`

Dungeon generation is intentionally rarer for performance and pacing

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

- copper ore, raw copper, ingots/nuggets, storage blocks
- copper tools
- copper armor
- cherry/mangrove/pale wood sets present as curated content
- cherry/mangrove/pale saplings are dungeon-loot oriented (not intended as common worldgen trees)

## Credits and Legal

See:

- `CREDITS.md`
- `LEGAL.md`
- `LICENSE.txt`
- `API.md`

