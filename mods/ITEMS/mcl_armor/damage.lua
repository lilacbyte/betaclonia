local function use_durability(obj, inv, index, stack, uses)
	local def = stack:get_definition()
	mcl_util.use_item_durability(stack, uses)
	if stack:is_empty() and def and def._on_break then
		stack = def._on_break(obj) or stack
	end
	inv:set_stack("armor", index, stack)
end

local function wear_combat_armor(obj, inv, uses)
	if not inv then
		return false
	end
	local worn = false
	for _, element in pairs(mcl_armor.elements) do
		local itemstack = inv:get_stack("armor", element.index)
		if not itemstack:is_empty() then
			local itemname = itemstack:get_name()
			if minetest.get_item_group(itemname, "non_combat_armor") == 0 then
				use_durability(obj, inv, element.index, itemstack, uses)
				worn = true
			end
		end
	end
	return worn
end

local function is_mob_attack(reason)
	if not reason then
		return false
	end
	if reason.type == "mob" then
		return true
	end
	local source = reason.source or reason.direct
	if source and source.get_luaentity and not (source.is_player and source:is_player()) then
		local luaentity = source:get_luaentity()
		if luaentity and luaentity.is_mob then
			return true
		end
	end
	return false
end

mcl_damage.register_modifier(function(obj, damage, reason)
	local flags = reason.flags or {}

	if flags.bypasses_armor and flags.bypasses_magic then
		return damage
	end

	local uses = math.max(1, math.floor(damage / 4))
	if is_mob_attack(reason) then
		uses = math.max(1, math.ceil(uses * 2))
	end

	local points = 0
	local toughness = 0

	local inv = mcl_util.get_inventory(obj)

	if inv then
		for _, element in pairs(mcl_armor.elements) do
			local itemstack = inv:get_stack("armor", element.index)
			if not itemstack:is_empty() then
				local itemname = itemstack:get_name()

				if not flags.bypasses_armor and minetest.get_item_group(itemname, "non_combat_armor") == 0 then
					local condition = mcl_armor.get_piece_condition(itemstack, itemname)
					points = points + minetest.get_item_group(itemname, "mcl_armor_points") * condition
					toughness = toughness + minetest.get_item_group(itemname, "mcl_armor_toughness") * condition

					use_durability(obj, inv, element.index, itemstack, uses)
				end
			end
		end
	end

	-- https The OG Game gamepedia.com/Armor#Damage_protection
	damage = damage * (1 - math.min(20, math.max((points / 5), points - damage / (2 + (toughness / 4)))) / 25)

	mcl_armor.update(obj)
	return damage
end, 0)

-- Material passives: gold mitigates fall damage, copper mitigates fire damage.
mcl_damage.register_modifier(function(obj, damage, reason)
	if damage <= 0 or not obj or not obj.is_player or not obj:is_player() then
		return damage
	end

	local meta = obj:get_meta()
	if not meta then
		return damage
	end

	if reason and reason.type == "fall" then
		local fall_reduction = math.max(0, math.min(0.8, meta:get_float("mcl_armor:gold_fall_reduction") or 0))
		if fall_reduction > 0 then
			-- Preserve pre-mitigation fall damage so durability wear can scale
			-- with fall severity in a later modifier.
			reason._gold_fall_pre_damage = damage
			reason._gold_fall_reduction = fall_reduction
			damage = damage * (1 - fall_reduction)
		end
	end

	local fire_type = reason and (reason.type == "in_fire" or reason.type == "on_fire" or reason.type == "lava" or reason.type == "hot_floor")
	local fire_flag = reason and reason.flags and reason.flags.is_fire
	if fire_type or fire_flag then
		local fire_reduction = math.max(0, math.min(0.8, meta:get_float("mcl_armor:copper_fire_reduction") or 0))
		if fire_reduction > 0 then
			-- Preserve pre-mitigation fire damage so durability wear can scale
			-- with fire severity in a later modifier.
			reason._copper_fire_pre_damage = damage
			reason._copper_fire_reduction = fire_reduction
			damage = damage * (1 - fire_reduction)
		end
	end

	return damage
end, 10)

-- Also wear armor durability on bypass-armor damage (e.g. fall/on_fire),
-- except for reasons that bypass both armor and magic.
mcl_damage.register_modifier(function(obj, damage, reason)
	if damage <= 0 then
		return damage
	end
	local flags = (reason and reason.flags) or {}
	local is_fire = flags.is_fire == true
		or (reason and (reason.type == "in_fire" or reason.type == "on_fire" or reason.type == "lava" or reason.type == "hot_floor"))
	if flags.bypasses_magic then
		return damage
	end
	if not flags.bypasses_armor and not is_fire then
		return damage
	end

	local inv = mcl_util.get_inventory(obj)
	local uses = math.max(1, math.floor(damage / 4))
	if reason and reason.type == "fall" then
		local pre_damage = tonumber(reason._gold_fall_pre_damage) or damage
		local gold_reduction = math.max(0, math.min(0.8, tonumber(reason._gold_fall_reduction) or 0))
		if gold_reduction > 0 then
			-- Gold armor trade-off: larger falls consume much more durability.
			-- Base wear follows fall size before mitigation, then scales further
			-- with how much fall protection gold is currently providing.
			local severity = math.max(0, pre_damage - 20)
			uses = math.max(uses, math.floor(pre_damage / 3))
			uses = uses + math.floor(severity * gold_reduction * 0.35)
			uses = math.max(1, math.ceil(uses * 3.5))
		end
	end
	if is_fire then
		local pre_damage = tonumber(reason and reason._copper_fire_pre_damage) or damage
		local copper_reduction = math.max(0, math.min(0.8, tonumber(reason and reason._copper_fire_reduction) or 0))
		if copper_reduction > 0 then
			-- Copper armor trade-off: fire protection costs extra durability.
			-- Extra wear grows with incoming fire damage and protection amount.
			local extra = math.max(1, math.floor(pre_damage * (0.2 + copper_reduction * 0.3)))
			local hotspot = math.max(0, pre_damage - 4)
			extra = extra + math.floor(hotspot * copper_reduction * 0.2)
			uses = uses + extra
		end
	end
	if wear_combat_armor(obj, inv, uses) then
		mcl_armor.update(obj)
	end
	return damage
end, 20)
