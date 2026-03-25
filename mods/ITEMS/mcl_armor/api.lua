function mcl_armor.play_equip_sound(stack, obj, pos, unequip)
	local def = stack:get_definition()
	local estr = "equip"
	if unequip then
		estr = "unequip"
	end
	local snd = def.sounds and def.sounds["_mcl_armor_" .. estr]
	if not snd then
		-- Fallback sound
		snd = { name = "mcl_armor_" .. estr .. "_generic" }
	end
	if snd then
		local dist = 8
		if pos then
			dist = 16
		end
		minetest.sound_play(snd, {object = obj, pos = pos, gain = 0.5, max_hear_distance = dist}, true)
	end
end

function mcl_armor.on_equip(itemstack, obj)
	local def = itemstack:get_definition()
	mcl_armor.play_equip_sound(itemstack, obj)
	if def._on_equip then
		def._on_equip(obj, itemstack)
	end
	mcl_armor.update(obj)
end

function mcl_armor.on_unequip(itemstack, obj)
	local def = itemstack:get_definition()
	mcl_armor.play_equip_sound(itemstack, obj, nil, true)
	if def._on_unequip then
		def._on_unequip(obj, itemstack)
	end
	mcl_armor.update(obj)
end

function mcl_armor.equip(itemstack, obj, swap)
	local def = itemstack:get_definition()

	if not def then
		return itemstack
	end

	local inv = mcl_util.get_inventory(obj, true)

	if not inv or inv:get_size("armor") == 0 then
		return itemstack
	end

	local element = mcl_armor.elements[def._mcl_armor_element or ""]

	if element then
		local old_stack = inv:get_stack("armor", element.index)

		if swap or old_stack:is_empty() then
			local new_stack

			if swap then
				new_stack = itemstack
				itemstack = old_stack
				mcl_armor.on_unequip(old_stack, obj)
			else
				new_stack = itemstack:take_item()
			end

			inv:set_stack("armor", element.index, new_stack)
			mcl_armor.on_equip(new_stack, obj)
		end
	end

	return itemstack
end

function mcl_armor.equip_on_use(itemstack, player, pointed_thing)
	if not player or not player:is_player() then
		return itemstack
	end

	local new_stack = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
	if new_stack then
		return new_stack
	end

	return mcl_armor.equip(itemstack, player, true)
end

local function get_armor_texture(textures, name, modname, itemname, itemstring)
	local core_texture = textures[name] or modname .. "_" .. itemname .. ".png"
	if type(core_texture) == "function" then
		return core_texture
	end
	return function(_, itemstack)
		if not itemstack or itemstack:is_empty() then
			return core_texture
		end
		local color = itemstack:get_meta():get_string("mcl_armor:color")
		if color ~= "" and core_texture:find("_leather%.png$") then
			return core_texture:gsub("_leather%.png$", "_leather_desat.png") .. "^[multiply:" .. color
		end
		return core_texture
	end
end

function mcl_armor.register_set(def)
	local modname = minetest.get_current_modname()
	local groups = def.groups or {}
	local on_equip_callbacks = def.on_equip_callbacks or {}
	local on_unequip_callbacks = def.on_unequip_callbacks or {}
	local on_break_callbacks = def.on_break_callbacks or {}
	local textures = def.textures or {}
	local durabilities = def.durabilities or {}
	local element_groups = def.element_groups or {}
	local longdesc = mcl_armor.longdesc
	if def.effect_desc and def.effect_desc ~= "" then
		longdesc = longdesc .. "\n\n" .. def.effect_desc
	end

	-- backwards compatibility
	local descriptions = def.descriptions or {}
	if def.description then
		minetest.log("warning", "[mcl_armor] using the description field of armor set definitions is deprecated, please provide the localized strings in def.descriptions instead. Currently processing " .. def.name)
		local S = minetest.get_translator(modname)
		for name, element in pairs(mcl_armor.elements) do
			descriptions[name] = S(def.description .. " " .. (descriptions[name] or element.description))
		end
	end

	for name, element in pairs(mcl_armor.elements) do
		local itemname = element.name .. "_" .. def.name
		local itemstring = modname .. ":" .. itemname

		local groups = table.copy(groups)
		groups["armor_" .. name] = 1
		groups["combat_armor_" .. name] = 1
		groups["armor_" .. def.name] = 1
		groups.armor = 1
		groups.combat_armor = 1
		groups.mcl_armor_points = def.points[name]
		groups.mcl_armor_toughness = def.toughness
		groups.mcl_armor_uses = (durabilities[name] or math.floor(def.durability * element.durability)) + 1

		for k, v in pairs(element_groups) do
			groups[k] = v
		end
		local upgrade_item = nil
		if def._mcl_upgradable and def._mcl_upgrade_item_material then
			upgrade_item = itemstring:gsub("_[%l%d]*$",def._mcl_upgrade_item_material)
		end

		local on_place = mcl_armor.equip_on_use
		if def.on_place then
			on_place = function(itemstack, placer, pointed_thing)
				if def.on_place then
					local op = def.on_place(itemstack, placer, pointed_thing)
					if op then return op end
				end
				return mcl_armor.equip_on_use(itemstack, placer, pointed_thing)
			end
		end

		minetest.register_tool(itemstring, {
			description = descriptions[name],
			_doc_items_longdesc = longdesc,
			_doc_items_usagehelp = mcl_armor.usage,
			_tt_help = def.effect_desc,
			_mcl_effect_desc = def.effect_desc,
			inventory_image = modname .. "_inv_" .. itemname .. ".png",
			_repair_material = def.repair_material or def.craft_material,
			groups = groups,
			sounds = {
				_mcl_armor_equip = def.sound_equip or modname .. "_equip_" .. def.name,
				_mcl_armor_unequip = def.sound_unequip or modname .. "_unequip_" .. def.name,
			},
			on_place =  on_place,
			on_secondary_use = mcl_armor.equip_on_use,
			_on_equip = on_equip_callbacks[name] or def.on_equip,
			_on_unequip = on_unequip_callbacks[name] or def.on_unequip,
			_on_break = on_break_callbacks[name] or def.on_break,
			_mcl_armor_element = name,
			_mcl_armor_texture = get_armor_texture(textures, name, modname, itemname, itemstring),
			_mcl_upgradable = def._mcl_upgradable,
			_mcl_upgrade_item = upgrade_item,
			_mcl_cooking_output = def.cook_material
		})

		if def.craft_material then
			minetest.register_craft({
				output = itemstring,
				recipe = element.craft(def.craft_material),
			})
		end
	end
end

function mcl_armor.get_piece_condition(itemstack, itemname)
	if not itemstack or itemstack:is_empty() then
		return 0
	end
	local name = itemname or itemstack:get_name()
	local uses = minetest.get_item_group(name, "mcl_armor_uses")
	if uses <= 0 then
		return 1
	end
	local wear = itemstack:get_wear()
	if wear <= 0 then
		return 1
	end
	return math.max(0, 1 - (wear / 65535))
end

function mcl_armor.update(obj)
	local info = {
		points = 0,
		view_range_factors = {},
		leather_power = 0,
		gold_power = 0,
		copper_power = 0,
	}

	local inv = mcl_util.get_inventory(obj)

	if inv then
		for i = 2, 5 do
			local itemstack = inv:get_stack("armor", i)

			local itemname = itemstack:get_name()
			if minetest.registered_aliases[itemname] then
				itemname = minetest.registered_aliases[itemname]
			end

			if not itemstack:is_empty() then
				local def = itemstack:get_definition()

				local texture = def._mcl_armor_texture

				if texture then
					if type(texture) == "function" then
						texture = texture(obj, itemstack)
					end
					if texture then
						info.texture = "(" .. texture .. ")" .. (info.texture and "^" .. info.texture or "")
					end
				end

					local condition = mcl_armor.get_piece_condition(itemstack, itemname)
					-- HUD armor meter is durability-based per equipped combat armor piece.
					if minetest.get_item_group(itemname, "non_combat_armor") == 0 then
						info.points = info.points + (5 * condition)
					end

				if minetest.get_item_group(itemname, "armor_leather") > 0 then
					info.leather_power = info.leather_power + condition
				elseif minetest.get_item_group(itemname, "armor_gold") > 0 then
					info.gold_power = info.gold_power + condition
				elseif minetest.get_item_group(itemname, "armor_copper") > 0 then
					info.copper_power = info.copper_power + condition
				end

				local mob_range_mob = def._mcl_armor_mob_range_mob

				if mob_range_mob then
					local factor = info.view_range_factors[mob_range_mob]

					if factor then
						if factor > 0 then
							info.view_range_factors[mob_range_mob] = factor * def._mcl_armor_mob_range_factor
						end
					else
						info.view_range_factors[mob_range_mob] = def._mcl_armor_mob_range_factor
					end
				end
			end
		end
	end

	info.points = math.max(0, math.floor(info.points + 0.5))
	-- Material passives are durability-weighted by condition.
	info.leather_speed = 1 + math.min(0.5, info.leather_power * 0.125)
	info.gold_fall_reduction = math.min(0.75, info.gold_power * 0.20)
	-- Full copper set target:
	-- - 50% fire/lava damage reduction
	-- - 25% reduced burn duration
	info.copper_fire_reduction = math.min(0.5, info.copper_power * 0.125)
	info.copper_burn_time_reduction = math.min(0.25, info.copper_power * 0.0625)
	info.texture = info.texture or "blank.png"

	if obj:is_player() then
		mcl_armor.update_player(obj, info)
	else
		local luaentity = obj:get_luaentity()

		if luaentity.update_armor then
			luaentity:update_armor(info)
		end
	end
end
