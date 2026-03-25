mcl_death_drop = {}

mcl_death_drop.registered_dropped_lists = {}

function mcl_death_drop.register_dropped_list(inv, listname, drop)
	table.insert(mcl_death_drop.registered_dropped_lists, {inv = inv, listname = listname, drop = drop})
end

mcl_death_drop.register_dropped_list("PLAYER", "main", true)
mcl_death_drop.register_dropped_list("PLAYER", "craft", true)
mcl_death_drop.register_dropped_list("PLAYER", "armor", true)

minetest.register_on_dieplayer(function(player)
	local keep = minetest.settings:get_bool("mcl_keepInventory", false)
	if keep == false then
		-- Drop inventory, crafting grid and armor
		local playerinv = player:get_inventory()
		local pos = player:get_pos()
		-- No item drop if in deep void
		local _, void_deadly = mcl_worlds.is_in_void(pos)

		for l=1,#mcl_death_drop.registered_dropped_lists do
			local inv = mcl_death_drop.registered_dropped_lists[l].inv
			if inv == "PLAYER" then
				inv = playerinv
			elseif type(inv) == "function" then
				inv = inv(player)
			end
			local listname = mcl_death_drop.registered_dropped_lists[l].listname
			local drop = mcl_death_drop.registered_dropped_lists[l].drop
			local dropspots = minetest.find_nodes_in_area(vector.offset(pos,-3,0,-3),vector.offset(pos,3,0,3),{"air"})
			if #dropspots == 0 then
				table.insert(dropspots,pos)
			end
				if inv then
					local list = inv:get_list(listname) or {}
					for i = 1, #list do
						local stack = list[i]
							if stack and not stack:is_empty() then
								local p = vector.offset(dropspots[math.random(#dropspots)], math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
								if not void_deadly and drop then
									minetest.add_item(p, ItemStack(stack))
								end
								inv:set_stack(listname, i, ItemStack(""))
							end
					end
				end
			end
			mcl_armor.update(player)
	end
end)
