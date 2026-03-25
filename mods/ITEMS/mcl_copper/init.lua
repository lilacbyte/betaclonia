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

minetest.register_craftitem("mcl_copper:copper_nugget", {
	description = S("Copper Nugget"),
	_doc_items_longdesc = S("A small piece of copper used for compact crafting recipes."),
	inventory_image = "mcl_copper_nugget.png",
	groups = {craftitem = 1},
})

minetest.register_node("mcl_copper:stone_with_copper", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Stone containing copper ore."),
	tiles = {"mcl_copper_ore.png"},
	groups = {pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable = 1},
	drop = "mcl_copper:raw_copper",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
	_mcl_cooking_output = "mcl_copper:copper_ingot",
})

minetest.register_node("mcl_copper:block_raw", {
	description = S("Block of Raw Copper"),
	_doc_items_longdesc = S("A storage block made from raw copper."),
	tiles = {"mcl_copper_block_raw.png"},
	groups = {pickaxey = 3, building_block = 1, material_stone = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_copper:block", {
	description = S("Block of Copper"),
	_doc_items_longdesc = S("A storage block made from copper ingots."),
	tiles = {"mcl_copper_block.png"},
	groups = {pickaxey = 2, building_block = 1, material_stone = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_craft({
	output = "mcl_copper:block",
	recipe = {
		{"mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot"},
		{"mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot"},
		{"mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot"},
	}
})

minetest.register_craft({
	output = "mcl_copper:copper_ingot 9",
	recipe = {{"mcl_copper:block"}}
})

minetest.register_craft({
	output = "mcl_copper:copper_ingot",
	recipe = {
		{"mcl_copper:copper_nugget", "mcl_copper:copper_nugget", "mcl_copper:copper_nugget"},
		{"mcl_copper:copper_nugget", "mcl_copper:copper_nugget", "mcl_copper:copper_nugget"},
		{"mcl_copper:copper_nugget", "mcl_copper:copper_nugget", "mcl_copper:copper_nugget"},
	}
})

minetest.register_craft({
	output = "mcl_copper:copper_nugget 9",
	recipe = {{"mcl_copper:copper_ingot"}}
})

minetest.register_craft({
	output = "mcl_copper:block_raw",
	recipe = {
		{"mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper"},
		{"mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper"},
		{"mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper"},
	}
})

minetest.register_craft({
	output = "mcl_copper:raw_copper 9",
	recipe = {{"mcl_copper:block_raw"}}
})

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
		level = 3,
		speed = 5,
		max_drop_level = 3,
		groups = { dig_class_speed = 3, enchantability = 10 }
	}, {
		["pick"] = {
			description = S("Copper Pickaxe"),
			inventory_image = "mcl_copper_tool_pick.png",
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
				effect_desc = S("Effect: Small chance to ignite mobs on hit."),
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

local y_min = mcl_vars.mg_overworld_min
local y_max = math.min(mcl_vars.mg_overworld_max, 64)

minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_copper:stone_with_copper",
	wherein = "mcl_core:stone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 6,
	clust_size = 4,
	y_min = y_min,
	y_max = y_max,
})
