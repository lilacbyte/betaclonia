local modpath = minetest.get_modpath(minetest.get_current_modname())

local raw_register_alias = minetest.register_alias
minetest.register_alias = function(old_name, new_name)
	-- Avoid startup spam: if a node/item with the old alias name already exists,
	-- registering an alias will always fail with a warning.
	if old_name == new_name then
		return
	end
	if minetest.registered_items[old_name] then
		return
	end
	raw_register_alias(old_name, new_name)
end

dofile(modpath.."/mcl_trees.lua")
dofile(modpath.."/mcl_doors.lua")
dofile(modpath.."/mcl_tools.lua")
dofile(modpath.."/mcl_dyes.lua")
--dofile(modpath.."/mcl_copper.lua")--removed
dofile(modpath.."/mcl_stairs.lua")
--dofile(modpath.."/mcl_crimson.lua")--removed
dofile(modpath.."/mcl_armor.lua")
--dofile(modpath.."/mcl_bamboo.lua")--removed
dofile(modpath.."/mesecons.lua")

minetest.register_alias = raw_register_alias
