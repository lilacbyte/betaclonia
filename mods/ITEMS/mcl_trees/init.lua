mcl_trees = {}
mcl_trees.woods = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/abms.lua")
dofile(modpath.."/nodes_trees.lua") -- register the trees
