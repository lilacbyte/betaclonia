# Changelog 4 (Session Summary)

Date range: 2026-03-27 to 2026-03-28  
Scope: work merged in commits `cf4c464` through `e002786`

## Commit Timeline

1. `cf4c464` - add pyramids and villages
2. `99bdcda` - fixing
3. `d54a528` - structures, removal of items, fixes, etc
4. `ffc8cde` - junk removed
5. `be665f8` - fixes
6. `40ad97c` - pyramid fix, NEW COPPER ABILITIES
7. `cd9332c` - pushed 1774691187
8. `7e83d98` - pushed 1774691660
9. `d5866cd` - pushed 1774693927
10. `e002786` - fixes

## Structures and Mapgen

- Added/maintained beta structure system (`mcl_beta_structures`) for `brick_pyramid` and `empty_village`.
- Pyramid dimensions are set to Infdev-style values in code:
  - base width `127` (`PYRAMID_HALF = 63`)
  - height `64` (`PYRAMID_HEIGHT = 64`)
- Improved structure placement flow using emerge-before-place to reduce chunk-edge placement failures.
- Registered `desert_well` in `mcl_structures` to place only its schematic (`mcl_structures_desert_well.mts`) without loot/suspicious-sand logic.
- Kept small boulder structure and worldgen decoration (`mcl_structures_boulder_small.mts`) while dropping large boulder schematic usage.
- Updated `/spawnstruct` behavior and structure registration aliases so beta structures are available through the structure API.

## Village Behavior

- Beta village generator was rewritten around weighted pieces and terrain checks.
- Ruined-house behavior includes cobweb placement.
- Optional zombie spawner support exists in ruined houses.
- Village road/well generation logic was refactored for more stable placement.

## Content Removal and Size Cleanup

- Removed large groups of structure schematics/assets (corals, fossils, portals, shipwreck variants, outpost/cabin, etc.) during cleanup passes.
- Removed mangrove-related assets/content references and replaced old IDs through compatibility aliases.
- Removed coarse dirt asset and node content:
  - `mcl_core:coarse_dirt` now aliases to `mcl_core:dirt`
  - `mods/ITEMS/mcl_core/textures/mcl_core_coarse_dirt.png` removed
- Removed copper block and netherite block as gameplay blocks (mapped to fallback nodes/aliases).
- Removed legacy obsidian addon content (`mcl_obsidian`).

## Compatibility and World-Safety Aliases

- Added `mods/new_clonecraftlibre/clonecraftlibre_aliases/removed_content_aliases.lua` with broad alias coverage for removed content.
- Added/kept compatibility aliases for removed IDs including:
  - `mcl_maps:*`
  - `mcl_bells:*`
  - `mcl_panes:*`
  - `mcl_lanterns:*`
- This was done to keep old worlds loadable after removals.

## Copper Tool Mechanics

- Copper shovel "Smeltery":
  - converts smeltable/sand-type drops to glass near dig point
  - applies extra durability cost multiplier `1.35`
- Copper axe:
  - chance to convert log drops to charcoal
  - chance increased to `0.34`
- Copper sword:
  - always ignites hit targets (burn application in player/mob combat paths)
  - lower damage profile than normal baseline for copper sword
- Copper pickaxe:
  - explosive bonus behavior retained
  - explicit harvest override: can break iron ores, blocked from gold ores

## Player, Movement, and UI

- Removed elytra runtime code:
  - deleted `mods/PLAYER/playerphysics/elytra.lua`
  - removed loader from `mods/PLAYER/playerphysics/init.lua`
- Removed swim/elytra/crawl animation handling from `mods/PLAYER/mcl_player/animations.lua`.
- Forced no swim/crawl pose path in animation state and removed old underwater particle spawner behavior.
- Simplified player suffocation check path in `mods/PLAYER/mcl_player/init.lua` (head-node based).
- Added death coordinate output to player on death:
  - chat message with rounded XYZ
  - actionbar title display support

## Drops and Crafting Tweaks

- Leaves drop logic was reduced to sapling-focused drops (apple/stick leaf-drop behavior removed from the leaf drop table path).
- Coarse dirt recipes/content paths removed as part of coarse dirt removal.
- Various small adjustments in flowers/mushrooms/cactuscane/hoes/tools support files to match removals and behavior changes.

## Settings

- Added new setting:
  - `betaclonia.enable_netherite_addon` (default `false`)
- `mcl_netherite` now early-returns when this setting is off, so the addon is opt-in only.

## Primary Files Touched Late in Session

- `mods/MAPGEN/mcl_beta_structures/init.lua`
- `mods/MAPGEN/mcl_structures/init.lua`
- `mods/ITEMS/mcl_copper/init.lua`
- `mods/new_clonecraftlibre/clonecraftlibre_aliases/removed_content_aliases.lua`
- `mods/PLAYER/mcl_player/animations.lua`
- `mods/PLAYER/mcl_player/init.lua`
- `mods/PLAYER/playerphysics/init.lua`
- `mods/HUD/mcl_death_messages/init.lua`
- `mods/ITEMS/mcl_netherite/init.lua`
- `settingtypes.txt`

