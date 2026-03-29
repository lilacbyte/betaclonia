local S = minetest.get_translator(minetest.get_current_modname())

local function format_hearts_from_eatable(eatable)
	local whole = math.floor(eatable / 2)
	if eatable % 2 == 0 then
		return tostring(whole)
	end
	if whole == 0 then
		return "0.5"
	end
	return tostring(whole) .. ".5"
end

-- Armor
tt.register_snippet(function(itemstring)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local head = minetest.get_item_group(itemstring, "armor_head")
	local torso = minetest.get_item_group(itemstring, "armor_torso")
	local legs = minetest.get_item_group(itemstring, "armor_legs")
	local feet = minetest.get_item_group(itemstring, "armor_feet")
	if head > 0 then
		s = s .. S("Head armor")
	end
	if torso > 0 then
		s = s .. S("Torso armor")
	end
	if legs > 0 then
		s = s .. S("Legs armor")
	end
	if feet > 0 then
		s = s .. S("Feet armor")
	end
	return s ~= "" and s or nil
end)
tt.register_snippet(function(itemstring, _, itemstack)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local use = minetest.get_item_group(itemstring, "mcl_armor_uses")
	local pts = minetest.get_item_group(itemstring, "mcl_armor_points")
	if pts > 0 then
		s = s .. S("Armor points: @1", pts)
		s = s .. "\n"
	end
	if use > 0 then
		s = s .. S("Armor durability: @1", use)
	end
	return s ~= "" and s or nil
end)
tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	local groups = def.groups or {}
	if groups.eatable and groups.eatable > 0 then
		local hearts = format_hearts_from_eatable(groups.eatable)
		if hearts == "1" then
			return S("Heals: 1 heart")
		end
		return S("Heals: @1 hearts", hearts)
	end
end)

tt.register_snippet(function(itemstring)
	--local def = minetest.registered_items[itemstring]
	if minetest.get_item_group(itemstring, "crush_after_fall") == 1 then
		return S("Deals damage when falling"), mcl_colors.YELLOW
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if def.groups.place_flowerlike == 1 then
		return S("Grows on grass blocks or dirt")
	elseif def.groups.place_flowerlike == 2 then
		return S("Grows on grass blocks, podzol or dirt")
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if def.groups.flammable then
		return S("Flammable")
	end
end)

tt.register_snippet(function(itemstring)
	if itemstring == "mcl_heads:zombie" then
		return S("Zombie view range: -50%")
	elseif itemstring == "mcl_heads:skeleton" then
		return S("Skeleton view range: -50%")
	elseif itemstring == "mcl_heads:creeper" then
		return S("Creeper view range: -50%")
	end
end)

tt.register_snippet(function(itemstring, _, itemstack)
	if itemstring:sub(1, 23) == "mcl_fishing:fishing_rod" or itemstring:sub(1, 12) == "mcl_bows:bow" then
		return S("Durability: @1", S("@1 uses", mcl_util.calculate_durability(itemstack or ItemStack(itemstring))))
	end
end)
