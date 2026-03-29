local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("mcl_copper:raw_copper", {
	description = S("Raw Copper"),
	_doc_items_longdesc = S("A raw piece of copper. Smelt it to get a copper ingot."),
	inventory_image = "mcl_copper_raw.png",
	groups = { craftitem = 1, blast_furnace_smeltable = 1 },
	_mcl_cooking_output = "mcl_copper:copper_ingot",
})

minetest.register_craftitem("mcl_copper:copper_ingot", {
	description = S("Copper Ingot"),
	_doc_items_longdesc = S("Refined copper used for crafting copper tools and blocks."),
	inventory_image = "mcl_copper_ingot.png",
	groups = { craftitem = 1 },
})

minetest.register_node("mcl_copper:stone_with_copper", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Some copper contained in stone, it is pretty common and can be found below sea level."),
	tiles = { "default_stone.png^mcl_copper_ore.png" },
	groups = { pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable = 1 },
	drop = "mcl_copper:raw_copper",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
	_mcl_cooking_output = "mcl_copper:copper_ingot",
})

minetest.register_alias("mcl_copper:block", "mcl_core:stone")

local tools_registered = false
local function register_copper_tools()
	if tools_registered then
		return
	end
	if not (mcl_tools and mcl_tools.register_set) then
		return
	end

	mcl_tools.register_set(
		"copper",
		{
			craftable = true,
			material = "mcl_copper:copper_ingot",
			uses = 180,
			level = 2,
			speed = 5,
			max_drop_level = 2,
			groups = { dig_class_speed = 3, enchantability = 10 },
		},
		{
			pick = {
				description = S("Copper Pickaxe"),
				inventory_image = "mcl_copper_tool_pick.png",
				effect_desc = S("Effect: Explosive"),
				tool_capabilities = {
					full_punch_interval = 0.83333333,
					damage_groups = { fleshy = 3 },
				},
			},
			shovel = {
				description = S("Copper Shovel"),
				inventory_image = "mcl_copper_tool_shovel.png",
				effect_desc = S("Effect: Smeltery"),
				tool_capabilities = {
					full_punch_interval = 1,
					damage_groups = { fleshy = 3 },
				},
			},
			sword = {
				description = S("Copper Sword"),
				inventory_image = "mcl_copper_tool_sword.png",
				effect_desc = S("Effect: Ignites targets"),
				tool_capabilities = {
					full_punch_interval = 0.625,
					damage_groups = { fleshy = 3.5 },
				},
			},
			axe = {
				description = S("Copper Axe"),
				inventory_image = "mcl_copper_tool_axe.png",
				effect_desc = S("Effect: Chance to smelt wood"),
				tool_capabilities = {
					full_punch_interval = 1.18,
					damage_groups = { fleshy = 8 },
				},
			},
		},
		{}
	)

	tools_registered = true
end

register_copper_tools()

-- Copper spawns a bit higher than iron, while staying underground.
minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_copper:stone_with_copper",
	wherein = "mcl_core:stone",
	clust_scarcity = 700,
	clust_num_ores = 5,
	clust_size = 3,
	y_min = mcl_vars.mg_overworld_min,
	y_max = mcl_worlds.layer_to_y(47),
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_copper:stone_with_copper",
	wherein = "mcl_core:stone",
	clust_scarcity = 1400,
	clust_num_ores = 4,
	clust_size = 2,
	y_min = mcl_worlds.layer_to_y(48),
	y_max = mcl_worlds.layer_to_y(75),
})

local function resolve_alias(name)
	local seen = {}
	while name and minetest.registered_aliases[name] and not seen[name] do
		seen[name] = true
		name = minetest.registered_aliases[name]
	end
	return name
end

local COPPER_PICK_BLOCKED_GOLD_NODES = {
	["mcl_core:stone_with_gold"] = true,
	["default:stone_with_gold"] = true,
	["mcl_deepslate:deepslate_with_gold"] = true,
	["mcl_nether:nether_gold_ore"] = true,
	["mcl_blackstone:nether_gold"] = true,
}

local COPPER_PICK_ALLOWED_IRON_NODES = {
	["mcl_core:stone_with_iron"] = true,
	["default:stone_with_iron"] = true,
	["mcl_deepslate:deepslate_with_iron"] = true,
}

local function copper_pick_harvest_override(nodename, toolname)
	local resolved_tool = resolve_alias(toolname) or toolname
	if resolved_tool ~= "mcl_copper:pick_copper" then
		return nil
	end
	local resolved_node = resolve_alias(nodename) or nodename
	if COPPER_PICK_BLOCKED_GOLD_NODES[resolved_node] then
		return false
	end
	if COPPER_PICK_ALLOWED_IRON_NODES[resolved_node] then
		return true
	end
	return nil
end

minetest.register_on_mods_loaded(function()
	register_copper_tools()
	if mcl_autogroup and type(mcl_autogroup.can_harvest) == "function" and not mcl_autogroup._copper_pick_gold_guard then
		local base_can_harvest = mcl_autogroup.can_harvest
		mcl_autogroup.can_harvest = function(nodename, toolname, player)
			local harvest_override = copper_pick_harvest_override(nodename, toolname)
			if harvest_override ~= nil then
				return harvest_override
			end
			return base_can_harvest(nodename, toolname, player)
		end
		mcl_autogroup._copper_pick_gold_guard = true
	end
end)

local EXPLOSIVE_CHANCE = 0.15
local EXPLOSIVE_MAX_EXTRA = 1
local AXE_CHARCOAL_CHANCE = 0.34

local SMELTERY_OUTPUT = "mcl_core:glass"
local SMELTERY_OUTPUT_ITEM = "mcl_core:glass"
local SMELTERY_RADIUS = 1.75
local SMELTERY_EXTRA_DURABILITY = 1.35

local CHARCOAL_OUTPUT_ITEM = "mcl_core:charcoal_lump"
local CHARCOAL_RADIUS = 1.5

local explosive_guard = {}

local function replace_one_nearby_drop(pos, radius, matcher, replacement_item)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, radius)) do
		local entity = obj:get_luaentity()
		if entity and entity.name == "__builtin:item" and entity.itemstring and entity.itemstring ~= "" then
			local stack = ItemStack(entity.itemstring)
			if matcher(stack) then
				stack:take_item(1)
				if stack:is_empty() then
					obj:remove()
				else
					entity:set_item(stack:to_string())
				end
				minetest.add_item(vector.offset(pos, 0, 0.25, 0), replacement_item)
				return true
			end
		end
	end
	return false
end

local function convert_nearby_log_drop_to_charcoal(pos, log_name)
	return replace_one_nearby_drop(
		pos,
		CHARCOAL_RADIUS,
		function(stack)
			local dropped_name = resolve_alias(stack:get_name()) or stack:get_name()
			return dropped_name == log_name
		end,
		CHARCOAL_OUTPUT_ITEM
	)
end

local function convert_nearby_smeltable_drop_to_glass(pos)
	return replace_one_nearby_drop(
		pos,
		SMELTERY_RADIUS,
		function(stack)
			local dropped_name = resolve_alias(stack:get_name()) or stack:get_name()
			local dropped_def = minetest.registered_items[dropped_name]
			return dropped_def and dropped_def._mcl_cooking_output == SMELTERY_OUTPUT
		end,
		SMELTERY_OUTPUT_ITEM
	)
end

local function is_smeltery_node(node_name, node_def)
	return (node_def and node_def._mcl_cooking_output == SMELTERY_OUTPUT)
		or node_name == "mcl_core:sand"
		or node_name == "mcl_core:redsand"
end

local function handle_copper_shovel_dig(pos, player_name, wield, node_name, node_def)
	if minetest.is_creative_enabled(player_name) then
		return false
	end
	if not is_smeltery_node(node_name, node_def) then
		return false
	end

	-- Try now and once more next tick in case item entities spawn slightly later.
	if not convert_nearby_smeltable_drop_to_glass(pos) then
		minetest.after(0, convert_nearby_smeltable_drop_to_glass, vector.new(pos))
	end

	mcl_util.use_item_durability(wield, SMELTERY_EXTRA_DURABILITY)
	return true
end

local function handle_copper_axe_dig(pos, node_name, node_def)
	if node_def and node_def._mcl_cooking_output == CHARCOAL_OUTPUT_ITEM and math.random() < AXE_CHARCOAL_CHANCE then
		convert_nearby_log_drop_to_charcoal(pos, node_name)
	end
end

minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger or not digger:is_player() or not oldnode then
		return
	end

	local player_name = digger:get_player_name()
	if player_name == "" or explosive_guard[player_name] then
		return
	end

	local wield = digger:get_wielded_item()
	local tool_name = resolve_alias(wield:get_name())
	local oldnode_raw_name = oldnode.name
	local oldnode_name = resolve_alias(oldnode_raw_name) or oldnode_raw_name
	local node_def = minetest.registered_nodes[oldnode_name]

	if tool_name == "mcl_copper:shovel_copper" then
		if handle_copper_shovel_dig(pos, player_name, wield, oldnode_name, node_def) then
			digger:set_wielded_item(wield)
		end
		return
	end

	if tool_name == "mcl_copper:axe_copper" then
		handle_copper_axe_dig(pos, oldnode_name, node_def)
		return
	end

	if tool_name ~= "mcl_copper:pick_copper" then
		return
	end
	if math.random() >= EXPLOSIVE_CHANCE then
		return
	end

	local candidates = {}
	for dx = -1, 1 do
		for dy = -1, 1 do
			for dz = -1, 1 do
				if not (dx == 0 and dy == 0 and dz == 0) then
					local npos = vector.offset(pos, dx, dy, dz)
					local node = minetest.get_node_or_nil(npos)
					if node and node.name == oldnode_raw_name then
						table.insert(candidates, npos)
					end
				end
			end
		end
	end

	if #candidates == 0 then
		return
	end
	table.shuffle(candidates)

	explosive_guard[player_name] = true
	local broken = 0
	for i = 1, #candidates do
		if broken >= EXPLOSIVE_MAX_EXTRA then
			break
		end

		local npos = candidates[i]
		local node = minetest.get_node_or_nil(npos)
		if node and node.name == oldnode_raw_name and not minetest.is_protected(npos, player_name) then
			local ndef = minetest.registered_nodes[node.name]
			if ndef and ndef.diggable ~= false then
				minetest.node_dig(npos, node, digger)
				broken = broken + 1
			end
		end
	end
	explosive_guard[player_name] = nil
end)
