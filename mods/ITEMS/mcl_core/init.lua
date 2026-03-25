mcl_core = {}

-- Repair percentage for toolrepair
mcl_core.repair = 0.05

mcl_autogroup.register_diggroup("handy")
mcl_autogroup.register_diggroup("pickaxey", {
	levels = { "wood", "gold", "stone", "iron", "diamond" }
})
mcl_autogroup.register_diggroup("axey")
mcl_autogroup.register_diggroup("shovely")
mcl_autogroup.register_diggroup("shearsy")
mcl_autogroup.register_diggroup("shearsy_wool")
mcl_autogroup.register_diggroup("shearsy_cobweb")
mcl_autogroup.register_diggroup("swordy")
mcl_autogroup.register_diggroup("swordy_cobweb")
mcl_autogroup.register_diggroup("hoey")

cclmtgsettingiscompat2enabled = minetest.settings:get_bool("betacloniawithminetestgamecompatibility2") or true

-- Load files
local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/functions.lua")
dofile(modpath.."/nodes_base.lua") -- Simple solid cubic nodes with simple definitions
dofile(modpath.."/nodes_liquid.lua") -- Liquids
--dofile(modpath.."/nodes_trees.lua") -- Trees
dofile(modpath.."/nodes_cactuscane.lua") -- Cactus and sugar canes
dofile(modpath.."/nodes_glass.lua") -- Glass
dofile(modpath.."/nodes_climb.lua") -- Climbable nodes
if minetest.get_modpath("mcl_stairs") then
	dofile(modpath.."/nodes_stairs.lua")
end
dofile(modpath.."/nodes_misc.lua") -- Other and special nodes
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/crafting.lua")
dofile(modpath.."/compat.lua")

if cclmtgsettingiscompat2enabled and minetest.get_modpath("default") and not minetest.get_modpath("minetest_compatibility_layer_and_port") then
	dofile(modpath.."/override_default_tools.lua")--CC;L & MTG
end
