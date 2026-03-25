if minetest.get_modpath("default") and not minetest.get_modpath("minetest_compatibility_layer_and_port") then
for name, def in pairs(minetest.registered_items) do
	if string.match(name,"default:") or string.match(name,"doors:") or string.match(name,"farming:") or string.match(name,"stairs:") or string.match(name,"wool:") or string.match(name,"carts:") or string.match(name,"flowers:") then
		local newgroup = { ["jonne"] = 1 }
		local def_groups = def.groups or {}

		if string.match(name,"hoe_") then
			newgroup = { hoe = 1, tool = 1 }
		elseif string.match(name,"pick_") then
			newgroup = { pickaxe = 1, tool = 1 }
		elseif string.match(name,"axe_") then
			newgroup = { axe = 1, tool = 1 }
		elseif string.match(name,"shovel_") then
			newgroup = { shovel = 1, tool = 1 }
		elseif string.match(name,"sword_") then
			newgroup = { sword = 1, weapon = 1 }
		end
--[[		if def.paramtype == "facedir" then
			newgroup = { deco_block = 1 }
		end]]
		if def_groups.choppy then
			newgroup = { deco_block = 1 }
		end
		if def_groups.oddly_breakable_by_hand then
			newgroup = { deco_block = 1 }
		end
		if def_groups.cracky then
			newgroup = { building_block = 1 }
		end
		if def_groups.dig_immediate then
			newgroup = { deco_block = 1 }
		end
		if def_groups.snappy then
			newgroup = { deco_block = 1 }
		end
		if def.paramtype == "light" then
			newgroup = { deco_block = 1 }
		end
		if def_groups.tree then
			newgroup = { building_block = 1 }
		elseif def_groups.soil then
			newgroup = { building_block = 1 }
		elseif def_groups.wood then
			newgroup = { building_block = 1 }
		end

		if string.match(name,"stairs:") or string.match(name,"wool:") then
			newgroup = { building_block = 1 }
		elseif string.match(name,"carts:") then
			newgroup = { transport = 1 }
		end

--[[		if newgroup["jonne"] then
			newgroup = { craftitem = 1 }
		end]]

		def.groups = table.merge(def_groups, newgroup)
		core.override_item(name, {})--Who knows why this works
	end
end
end
