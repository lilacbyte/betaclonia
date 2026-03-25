mcl_redstone = {}

mcl_redstone._action_tab = {}

function mcl_redstone.register_action(func, node_names)
	for _, name in pairs(node_names) do
		mcl_redstone._action_tab[name] = mcl_redstone._action_tab[name] or {}
		table.insert(mcl_redstone._action_tab[name], func)
	end
end

-- Nodes by name that are opaque. Redstone block is a special opaque node that
-- is treated as always being powered, its entry has the value 15 and all
-- others have the value 0.
mcl_redstone._solid_opaque_tab = {}

--- Wireflags are numbers with binary representation YYYYXXXX where XXXX
--- determines if there is a visible connection in each of the four cardinal
--- directions and YYYY if the respective connection also goes up over the
--- neighbouring node. Order of the bits (right to left) are -z, +x, +z, -x.
--
-- This table contains wireflags by node name.
mcl_redstone._wireflag_tab = {}

minetest.register_on_mods_loaded(function()
	for name, ndef in pairs(minetest.registered_nodes) do
		local opaquely_powered = minetest.get_item_group(name, "opaquely_powered")
		if opaquely_powered > 0 then
			mcl_redstone._solid_opaque_tab[name] = opaquely_powered
		elseif minetest.get_item_group(name, "opaque") ~= 0 and minetest.get_item_group(name, "solid") ~= 0 then
			mcl_redstone._solid_opaque_tab[name] = 0
		end
	end
end)

local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/logic.lua")
dofile(modpath.."/eventqueue.lua")
dofile(modpath.."/wire.lua")
