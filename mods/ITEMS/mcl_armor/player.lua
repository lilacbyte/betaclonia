mcl_player.player_register_model("mcl_armor_character.b3d", {
	animation_speed = 30,
	textures = {
		"character.png",
		"blank.png",
		"blank.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
		sneak_stand = {x=222, y=302},
		sneak_mine = {x=346, y=365},
		sneak_walk = {x=304, y=323},
		sneak_walk_mine = {x=325, y=344},
		swim_walk = {x=368, y=387},
		swim_walk_mine = {x=389, y=408},
		swim_stand = {x=434, y=434},
		swim_mine = {x=411, y=430},
		run_walk	= {x=440, y=459},
		run_walk_mine	= {x=461, y=480},
		sit_mount	= {x=484, y=484},
		die	= {x=498, y=498},
		fly = {x=502, y=581},
		bow_walk = {x=650, y=670},
		bow_sneak = {x=675, y=695},
	},
})

mcl_player.player_register_model("mcl_armor_character_female.b3d", {
	animation_speed = 30,
	textures = {
		"character.png",
		"blank.png",
		"blank.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
		sneak_stand = {x=222, y=302},
		sneak_mine = {x=346, y=365},
		sneak_walk = {x=304, y=323},
		sneak_walk_mine = {x=325, y=344},
		swim_walk = {x=368, y=387},
		swim_walk_mine = {x=389, y=408},
		swim_stand = {x=434, y=434},
		swim_mine = {x=411, y=430},
		run_walk	= {x=440, y=459},
		run_walk_mine	= {x=461, y=480},
		sit_mount	= {x=484, y=484},
		die	= {x=498, y=498},
		fly = {x=502, y=581},
		bow_walk = {x=650, y=670},
		bow_sneak = {x=675, y=695},
	},
})

local leather_tradeoff_timers = {}
local LEATHER_TRADEOFF_INTERVAL = 10

local function apply_leather_tradeoff_wear(player)
	if not player or not player.is_player or not player:is_player() then
		return false
	end
	if minetest.is_creative_enabled(player:get_player_name()) then
		return false
	end
	local inv = player:get_inventory()
	if not inv then
		return false
	end

	local changed = false
	local wear_chance = 0.20

	for _, element in pairs(mcl_armor.elements) do
		local stack = inv:get_stack("armor", element.index)
		if not stack:is_empty() then
			local itemname = stack:get_name()
			if minetest.get_item_group(itemname, "armor_leather") > 0 and minetest.get_item_group(itemname, "non_combat_armor") == 0 then
				if math.random() < wear_chance then
					local def = stack:get_definition()
					mcl_util.use_item_durability(stack, 1)
					if stack:is_empty() and def and def._on_break then
						stack = def._on_break(player) or stack
					end
					inv:set_stack("armor", element.index, stack)
					changed = true
				end
			end
		end
	end

	return changed
end

function mcl_armor.update_player(player, info)
	mcl_player.player_set_armor(player, info.texture)

	local meta = player:get_meta()
	meta:set_int("mcl_armor:armor_points", info.points)
	meta:set_float("mcl_armor:gold_fall_reduction", info.gold_fall_reduction or 0)
	meta:set_float("mcl_armor:copper_fire_reduction", info.copper_fire_reduction or 0)
	meta:set_float("mcl_armor:copper_burn_time_reduction", info.copper_burn_time_reduction or 0)

	if playerphysics and playerphysics.add_physics_factor and playerphysics.remove_physics_factor then
		local speed_factor = tonumber(info.leather_speed) or 1
		if speed_factor > 1.0 then
			playerphysics.add_physics_factor(player, "speed", "mcl_armor:leather_speed", speed_factor)
		else
			playerphysics.remove_physics_factor(player, "speed", "mcl_armor:leather_speed")
		end
	end

	mcl_armor.player_view_range_factors[player] = info.view_range_factors
end

local function is_armor_action(inventory_info)
	return inventory_info.from_list == "armor" or inventory_info.to_list == "armor" or inventory_info.listname == "armor"
end

local function limit_put(_, inventory, index, stack, count)
	local def = stack:get_definition()

	if not def then
		return 0
	end

	local element = def._mcl_armor_element

	if not element then
		return 0
	end

	local element_index = mcl_armor.elements[element].index

	if index ~= 1 and index ~= element_index then
		return 0
	end

	local old_stack = inventory:get_stack("armor", element_index)

	if old_stack:is_empty() or index ~= 1 and old_stack:get_name() ~= stack:get_name() and count <= 1 then
		return count
	else
		return 0
	end
end

local function limit_take(player, _, _, stack, count)
	return count
end

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if not is_armor_action(inventory_info) then
		return
	end

	if action == "put" then
		return limit_put(player, inventory, inventory_info.index, inventory_info.stack, inventory_info.stack:get_count())
	elseif action == "take" then
		return limit_take(player, inventory, inventory_info.index, inventory_info.stack, inventory_info.stack:get_count())
	else
		if inventory_info.from_list ~= "armor" then
			return limit_put(player, inventory, inventory_info.to_index, inventory:get_stack(inventory_info.from_list, inventory_info.from_index), inventory_info.count)
		elseif inventory_info.to_list ~= "armor" then
			return limit_take(player, inventory, inventory_info.from_index, inventory:get_stack(inventory_info.from_list, inventory_info.from_index), inventory_info.count)
		else
			return 0
		end
	end
end)

local function on_put(player, inventory, index, stack)
	if index == 1 then
		mcl_armor.equip(stack, player)
		inventory:set_stack("armor", 1, nil)
	else
		mcl_armor.on_equip(stack, player)
	end
end

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if is_armor_action(inventory_info) then
		if action == "put" then
			on_put(player, inventory, inventory_info.index, inventory_info.stack)
		elseif action == "take" then
			mcl_armor.on_unequip(inventory_info.stack, player)
		else
			local stack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
			if inventory_info.to_list == "armor" then
				on_put(player, inventory, inventory_info.to_index, stack)
			elseif inventory_info.from_list == "armor" then
				mcl_armor.on_unequip(stack, player)
			end
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	player:get_inventory():set_size("armor", 5)
	if not minetest.global_exists("mcl_skins") then
		mcl_player.player_set_model(player, "mcl_armor_character.b3d")
	end

	minetest.after(1, function()
		if player:is_player() then
			mcl_armor.update(player)
		end
	end)
end)

minetest.register_on_leaveplayer(function(player)
	if playerphysics and playerphysics.remove_physics_factor then
		playerphysics.remove_physics_factor(player, "speed", "mcl_armor:leather_speed")
	end
	leather_tradeoff_timers[player] = nil
	mcl_armor.player_view_range_factors[player] = nil
end)

minetest.register_globalstep(function(dtime)
	for player in mcl_util.connected_players() do
			local timer = (leather_tradeoff_timers[player] or 0) + dtime
		if timer >= LEATHER_TRADEOFF_INTERVAL then
			timer = timer - LEATHER_TRADEOFF_INTERVAL
			local vel = player:get_velocity() or {x = 0, y = 0, z = 0}
			local is_moving = math.abs(vel.x) + math.abs(vel.z) > 0.1
			if is_moving and apply_leather_tradeoff_wear(player) then
				mcl_armor.update(player)
			end
		end
		leather_tradeoff_timers[player] = timer
	end
end)
