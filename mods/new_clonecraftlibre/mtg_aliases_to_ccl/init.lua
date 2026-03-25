cclmtgsettingiscompat1enabled = minetest.settings:get_bool("betacloniawithminetestgamecompatibility1") or true

local path = minetest.get_modpath(minetest.get_current_modname())
if cclmtgsettingiscompat1enabled and not minetest.get_modpath("minetest_compatibility_layer_and_port") and not minetest.get_modpath("default") then
	dofile(path .. "/mtgtoccl.lua")
end

dofile(path .. "/otherstuff.lua")
--[[if minetest.get_modpath("default") and not minetest.get_modpath("minetest_compatibility_layer_and_port") then
dofile(mtgtoccl.lua)
end]]
