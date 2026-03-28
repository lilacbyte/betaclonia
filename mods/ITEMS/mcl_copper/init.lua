local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("mcl_copper:raw_copper", {
	description = S("Raw Copper"),
	_doc_items_longdesc = S("A raw piece of copper. Smelt it to get a copper ingot."),
	inventory_image = "mcl_copper_raw.png",
	groups = {craftitem = 1, blast_furnace_smeltable = 1},
	_mcl_cooking_output = "mcl_copper:copper_ingot",
})

minetest.register_craftitem("mcl_copper:copper_ingot", {
	description = S("Copper Ingot"),
	_doc_items_longdesc = S("Refined copper used for crafting copper tools and blocks."),
	inventory_image = "mcl_copper_ingot.png",
	groups = {craftitem = 1},
})

minetest.register_node("mcl_copper:stone_with_copper", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Some copper contained in stone, it is prety common and can be found below sea level."),
	tiles = {"default_stone.png^mcl_copper_ore.png"},
	groups = {pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable = 1},
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

	mcl_tools.register_set("copper", {
		craftable = true,
		material = "mcl_copper:copper_ingot",
		uses = 180,
		level = 2,
		speed = 5,
		max_drop_level = 2,
		groups = { dig_class_speed = 3, enchantability = 10 }
	}, {
		["pick"] = {
			description = S("Copper Pickaxe"),
			inventory_image = "mcl_copper_tool_pick.png",
				effect_desc = S("Effect: Explosive. Chance to break nearby blocks."),
			tool_capabilities = {
				full_punch_interval = 0.83333333,
				damage_groups = { fleshy = 3 }
			}
		},
		["shovel"] = {
			description = S("Copper Shovel"),
			inventory_image = "mcl_copper_tool_shovel.png",
			tool_capabilities = {
				full_punch_interval = 1,
				damage_groups = { fleshy = 3 }
			}
		},
			["sword"] = {
				description = S("Copper Sword"),
				inventory_image = "mcl_copper_tool_sword.png",
				effect_desc = S("Effect: A chance to ignite mobs on hit."),
				tool_capabilities = {
					full_punch_interval = 0.625,
					damage_groups = { fleshy = 5 }
				}
		},
		["axe"] = {
			description = S("Copper Axe"),
			inventory_image = "mcl_copper_tool_axe.png",
			tool_capabilities = {
				full_punch_interval = 1.18,
				damage_groups = { fleshy = 8 }
			}
		}
	}, {})
	tools_registered = true
end

register_copper_tools()

minetest.register_on_mods_loaded(function()
	register_copper_tools()
end)

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

local explosive_chance = 0.08
local explosive_max_extra = 2
local explosive_guard = {}

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
	if tool_name ~= "mcl_copper:pick_copper" then
		return
	end
	if math.random() >= explosive_chance then
		return
	end

	local candidates = {}
	for dx = -1, 1 do
		for dy = -1, 1 do
			for dz = -1, 1 do
				if not (dx == 0 and dy == 0 and dz == 0) then
					local npos = vector.offset(pos, dx, dy, dz)
					local node = minetest.get_node_or_nil(npos)
					if node and node.name == oldnode.name then
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
		if broken >= explosive_max_extra then
			break
		end
		local npos = candidates[i]
		local node = minetest.get_node_or_nil(npos)
		if node and node.name == oldnode.name and not minetest.is_protected(npos, player_name) then
			local ndef = minetest.registered_nodes[node.name]
			if ndef and ndef.diggable ~= false then
				minetest.node_dig(npos, node, digger)
				broken = broken + 1
			end
		end
	end
	explosive_guard[player_name] = nil
end)
