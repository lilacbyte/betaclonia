local S = minetest.get_translator(minetest.get_current_modname())

local NETHER_Y_MIN = (mcl_vars and mcl_vars.mg_nether_min) or -29000
local NETHER_Y_MAX = (mcl_vars and mcl_vars.mg_nether_max) or -27000

-- Iron stick used as handle for netherite tools.
minetest.register_craftitem("mcl_netherite:iron_stick", {
	description = S("Iron Stick"),
	_doc_items_longdesc = S("An iron handle used to craft netherite tools."),
	inventory_image = "mcl_netherite_iron_stick.png",
	groups = { craftitem = 1 },
})

minetest.register_craft({
	output = "mcl_netherite:iron_stick 4",
	recipe = {
		{ "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot" },
	}
})

minetest.register_node("mcl_netherite:ancient_debris", {
	description = S("Ancient Debris"),
	_doc_items_longdesc = S("A very rare Nether ore used to craft netherite."),
	tiles = {
		"mcl_netherite_ancient_debris_top.png",
		"mcl_netherite_ancient_debris_top.png",
		"mcl_netherite_ancient_debris_side.png",
	},
	groups = { pickaxey = 4, building_block = 1, material_stone = 1, blast_furnace_smeltable = 1 },
	drop = "mcl_netherite:ancient_debris",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 30,
	_mcl_cooking_output = "mcl_netherite:netherite_scrap",
})

minetest.register_craftitem("mcl_netherite:netherite_scrap", {
	description = S("Netherite Scrap"),
	_doc_items_longdesc = S("Smelted from ancient debris and used to craft netherite ingots."),
	inventory_image = "mcl_netherite_scrap.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_netherite:netherite_ingot", {
	description = S("Netherite Ingot"),
	_doc_items_longdesc = S("A powerful ingot used to craft netherite tools."),
	inventory_image = "mcl_netherite_ingot.png",
	groups = { craftitem = 1 },
})

minetest.register_craft({
	output = "mcl_netherite:netherite_ingot",
	type = "shapeless",
	recipe = {
		"mcl_netherite:netherite_scrap",
		"mcl_netherite:netherite_scrap",
		"mcl_netherite:netherite_scrap",
		"mcl_netherite:netherite_scrap",
		"mcl_core:gold_ingot",
		"mcl_core:gold_ingot",
		"mcl_core:gold_ingot",
		"mcl_core:gold_ingot",
	},
})

minetest.register_alias("mcl_netherite:netherite_block", "mcl_core:stone")

-- Backward compatibility for old MineClone-style names.
minetest.register_alias("mcl_nether:ancient_debris", "mcl_netherite:ancient_debris")
minetest.register_alias("mcl_nether:netherite_scrap", "mcl_netherite:netherite_scrap")
minetest.register_alias("mcl_nether:netherite_ingot", "mcl_netherite:netherite_ingot")
minetest.register_alias("mcl_nether:netheriteblock", "mcl_core:stone")
minetest.register_alias("mcl_nether:netherite_block", "mcl_core:stone")

if minetest.settings:get_bool("mcl_generate_ores", true) then
	-- Ancient debris: two pass generation similar to MC density profile.
	minetest.register_ore({
		ore_type = "scatter",
		ore = "mcl_netherite:ancient_debris",
		wherein = { "mcl_nether:netherrack" },
		clust_scarcity = 17 * 17 * 17,
		clust_num_ores = 3,
		clust_size = 2,
		y_min = NETHER_Y_MIN,
		y_max = NETHER_Y_MAX,
	})

	minetest.register_ore({
		ore_type = "scatter",
		ore = "mcl_netherite:ancient_debris",
		wherein = { "mcl_nether:netherrack" },
		clust_scarcity = 13 * 13 * 13,
		clust_num_ores = 1,
		clust_size = 1,
		y_min = NETHER_Y_MIN,
		y_max = NETHER_Y_MAX,
	})
end

-- Register netherite tools under this mod; crafting is custom (iron stick).
mcl_tools.register_set("netherite", {
	craftable = false,
	material = "mcl_netherite:netherite_ingot",
	uses = 2031,
	level = 6,
	speed = 9.5,
	max_drop_level = 5,
	groups = { dig_class_speed = 6, enchantability = 10, fire_immune = 1 },
}, {
	pick = {
		description = S("Netherite Pickaxe"),
		inventory_image = "mcl_netherite_tool_pickaxe.png",
		tool_capabilities = {
			full_punch_interval = 0.83333333,
			damage_groups = { fleshy = 6 },
		},
	},
	shovel = {
		description = S("Netherite Shovel"),
		inventory_image = "mcl_netherite_tool_shovel.png",
		tool_capabilities = {
			full_punch_interval = 1,
			damage_groups = { fleshy = 6 },
		},
	},
	sword = {
		description = S("Netherite Sword"),
		inventory_image = "mcl_netherite_tool_sword.png",
		tool_capabilities = {
			full_punch_interval = 0.625,
			damage_groups = { fleshy = 9 },
		},
	},
	axe = {
		description = S("Netherite Axe"),
		inventory_image = "mcl_netherite_tool_axe.png",
		tool_capabilities = {
			full_punch_interval = 1,
			damage_groups = { fleshy = 10 },
		},
	},
})

local function register_tool_craft(output, recipe)
	minetest.register_craft({
		output = output,
		recipe = recipe,
	})
end

register_tool_craft("mcl_netherite:pick_netherite", {
	{ "mcl_netherite:netherite_ingot", "mcl_netherite:netherite_ingot", "mcl_netherite:netherite_ingot" },
	{ "", "mcl_netherite:iron_stick", "" },
	{ "", "mcl_netherite:iron_stick", "" },
})

register_tool_craft("mcl_netherite:shovel_netherite", {
	{ "mcl_netherite:netherite_ingot" },
	{ "mcl_netherite:iron_stick" },
	{ "mcl_netherite:iron_stick" },
})

register_tool_craft("mcl_netherite:sword_netherite", {
	{ "mcl_netherite:netherite_ingot" },
	{ "mcl_netherite:netherite_ingot" },
	{ "mcl_netherite:iron_stick" },
})

register_tool_craft("mcl_netherite:axe_netherite", {
	{ "mcl_netherite:netherite_ingot", "mcl_netherite:netherite_ingot" },
	{ "mcl_netherite:netherite_ingot", "mcl_netherite:iron_stick" },
	{ "", "mcl_netherite:iron_stick" },
})
register_tool_craft("mcl_netherite:axe_netherite", {
	{ "mcl_netherite:netherite_ingot", "mcl_netherite:netherite_ingot" },
	{ "mcl_netherite:iron_stick", "mcl_netherite:netherite_ingot" },
	{ "mcl_netherite:iron_stick", "" },
})

-- Netherite hoe lives in mcl_netherite too, no smithing upgrade path.
local diamond_hoe = minetest.registered_items["mcl_farming:hoe_diamond"]
local hoe_on_place = diamond_hoe and diamond_hoe.on_place

minetest.register_tool("mcl_netherite:hoe_netherite", {
	description = S("Netherite Hoe"),
	_tt_help = S("Turns block into farmland") .. "\n" .. S("Uses: @1", 2031),
	_doc_items_longdesc = S("Hoes are used to create farmland for crops."),
	_doc_items_usagehelp = S("Use on cultivatable blocks to till farmland."),
	inventory_image = "mcl_netherite_tool_hoe.png",
	wield_scale = (mcl_vars and mcl_vars.tool_wield_scale) or { x = 1, y = 1, z = 1 },
	on_place = hoe_on_place,
	groups = { tool = 1, hoe = 1, enchantability = 10, fire_immune = 1, offhand_item = 1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1 },
		punch_attack_uses = 2031,
	},
	_repair_material = "mcl_netherite:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		hoey = { speed = 9.5, level = 6, uses = 2031 },
	},
})

register_tool_craft("mcl_netherite:hoe_netherite", {
	{ "mcl_netherite:netherite_ingot", "mcl_netherite:netherite_ingot" },
	{ "", "mcl_netherite:iron_stick" },
	{ "", "mcl_netherite:iron_stick" },
})
register_tool_craft("mcl_netherite:hoe_netherite", {
	{ "mcl_netherite:netherite_ingot", "mcl_netherite:netherite_ingot" },
	{ "mcl_netherite:iron_stick", "" },
	{ "mcl_netherite:iron_stick", "" },
})

-- Old IDs compatibility aliases if something still references mcl_tools/mcl_farming netherite tools.
minetest.register_alias("mcl_tools:pick_netherite", "mcl_netherite:pick_netherite")
minetest.register_alias("mcl_tools:shovel_netherite", "mcl_netherite:shovel_netherite")
minetest.register_alias("mcl_tools:sword_netherite", "mcl_netherite:sword_netherite")
minetest.register_alias("mcl_tools:axe_netherite", "mcl_netherite:axe_netherite")
minetest.register_alias("mcl_farming:hoe_netherite", "mcl_netherite:hoe_netherite")
