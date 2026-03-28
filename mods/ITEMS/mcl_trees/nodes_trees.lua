--local modname = minetest.get_current_modname()
local core_modpath = minetest.get_modpath("mcl_core")
local core_schem_path = core_modpath.."/schematics"

local function remap_tree_area(pos, replacements)
	local p1 = vector.offset(pos, -8, -2, -8)
	local p2 = vector.offset(pos, 8, 24, 8)
	for from_name, to_name in pairs(replacements) do
		local nodes = minetest.find_nodes_in_area(p1, p2, {from_name})
		for i = 1, #nodes do
			minetest.swap_node(nodes[i], {name = to_name})
		end
	end
end

local function make_after_grow_replacer(replacements)
	return function(pos)
		remap_tree_area(pos, replacements)
	end
end

-- All required translation strings are currently generated in mcl_trees
-- local S = minetest.get_translator(minetest.get_current_modname())

mcl_trees.register_wood("oak",{
	readable_name = "Oak",
	sign_color="#917056",
	tree_schems= {
		{ file = core_schem_path.."/mcl_core_oak_balloon.mts"},
		{ file = core_schem_path.."/mcl_core_oak_large_1.mts"},
		{ file = core_schem_path.."/mcl_core_oak_large_2.mts"},
		{ file = core_schem_path.."/mcl_core_oak_large_3.mts"},
		{ file = core_schem_path.."/mcl_core_oak_large_4.mts"},
		{ file = core_schem_path.."/mcl_core_oak_swamp.mts"},
		{ file = core_schem_path.."/mcl_core_oak_v6.mts"},
		{ file = core_schem_path.."/mcl_core_oak_classic.mts"},
	},
	tree = { tiles = {"default_tree_top.png", "default_tree_top.png","default_tree.png"} },
	leaves = {
		tiles = { "default_leaves.png" },
		color = "#77ab2f",
	},
	drop_apples = true,
	wood = { tiles = {"default_wood.png"}},
	sapling = {
		tiles = {"default_sapling.png"},
		inventory_image = "default_sapling.png",
		wield_image = "default_sapling.png",
--		_after_grow=mcl_trees.sapling_add_bee_nest,--removed
	},
	door = {
		inventory_image = "doors_item_wood.png",
		tiles_bottom = {"mcl_doors_door_wood_lower.png", "mcl_doors_door_wood_side_lower.png"},
		tiles_top = {"mcl_doors_door_wood_upper.png", "mcl_doors_door_wood_side_upper.png"}
	},
	trapdoor = {
		tile_front = "doors_trapdoor.png",
		tile_side = "doors_trapdoor_side.png",
		wield_image = "doors_trapdoor.png",
	},
	potted_sapling = {
		image = "default_sapling.png",
	},
})

mcl_trees.register_wood("spruce",{
	readable_name = "Spruce",
	sign_color="#604335",
	tree_schems = {
		{ file = core_schem_path.."/mcl_core_spruce_1.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_2.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_3.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_4.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_5.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_lollipop.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_matchstick.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_tall.mts"},
	},
	tree_schems_2x2 = {
		{ file = core_schem_path.."/mcl_core_spruce_huge_1.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_huge_2.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_huge_3.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_huge_4.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_huge_up_1.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_huge_up_2.mts"},
		{ file = core_schem_path.."/mcl_core_spruce_huge_up_3.mts"},
	},
	tree = { tiles = {"mcl_core_log_spruce_top.png", "mcl_core_log_spruce_top.png", "mcl_core_log_spruce.png"} },
	wood = { tiles = {"mcl_core_planks_spruce.png"}},
	leaves = {
		tiles = { "mcl_core_leaves_spruce.png" },
		color = "#2bbb0f",
	},
	sapling = {
		tiles = {"mcl_core_sapling_spruce.png"},
		inventory_image = "mcl_core_sapling_spruce.png",
		wield_image = "mcl_core_sapling_spruce.png",
	},
	potted_sapling = {
		image = "mcl_core_sapling_spruce.png",
	},
})

mcl_trees.register_wood("birch",{
	readable_name = "Birch",
	sign_color="#AA907A",
	tree = { tiles = {"mcl_core_log_birch_top.png", "mcl_core_log_birch_top.png", "mcl_core_log_birch.png"} },
	tree_schems = {
		{ file = core_schem_path.."/mcl_core_birch.mts"},
	},
	wood = { tiles = {"mcl_core_planks_birch.png"}},
	leaves = {
		tiles = { "mcl_core_leaves_birch.png" },
		color = "#68a55f",
	},
	sapling = {
		tiles = {"mcl_core_sapling_birch.png"},
		inventory_image = "mcl_core_sapling_birch.png",
		wield_image = "mcl_core_sapling_birch.png",
		--_after_grow=mcl_trees.sapling_add_bee_nest,--removed
	},
	potted_sapling = {
		image = "mcl_core_sapling_birch.png",
	},
})

mcl_trees.register_wood("cherry_blossom",{
	readable_name = "Cherry",
	sign_color = "#F29889",
	chest_boat = false,
	tree_schems = {
		{ file = core_schem_path.."/mcl_core_cherry.mts"},
	},
	tree = { tiles = {
		"mcl_cherry_blossom_log_top.png",
		"mcl_cherry_blossom_log_top.png",
		"mcl_cherry_blossom_log.png",
	} },
	wood = { tiles = {"mcl_cherry_blossom_planks.png"}},
	leaves = {
		tiles = { "mcl_cherry_blossom_leaves.png" },
		paramtype2 = "none",
		palette = "",
	},
	fence = {
		tiles = { "mcl_cherry_blossom_planks.png" },
	},
	door = {
		inventory_image = "mcl_cherry_blossom_door_inv.png",
		tiles_bottom = {"mcl_cherry_blossom_door_bottom.png", "mcl_cherry_blossom_door_bottom_side.png"},
		tiles_top = {"mcl_cherry_blossom_door_top.png", "mcl_cherry_blossom_door_top_side.png"},
	},
	boat = {
		item = {
			inventory_image = "mcl_boats_cherry_blossom_boat.png",
			texture = "mcl_boats_texture_cherry_blossom_boat.png",
		},
	},
	sapling = {
		tiles = {"mcl_cherry_blossom_sapling.png"},
		inventory_image = "mcl_cherry_blossom_sapling.png",
		wield_image = "mcl_cherry_blossom_sapling.png",
	},
	potted_sapling = {
		image = "mcl_cherry_blossom_sapling.png",
	},
})

mcl_trees.register_wood("pale_oak",{
	readable_name = "Pale Oak",
	sign_color = "#CFCFD2",
	chest_boat = false,
	tree_schems = {
		{ file = core_schem_path.."/mcl_pale_oak_1.mts"},
		{ file = core_schem_path.."/mcl_pale_oak_2.mts"},
		{ file = core_schem_path.."/mcl_pale_oak_3.mts"},
	},
	tree = { tiles = {
		"mcl_pale_oak_log_top.png",
		"mcl_pale_oak_log_top.png",
		"mcl_pale_oak_log.png",
	} },
	wood = { tiles = {"mcl_pale_oak_planks.png"}},
	leaves = {
		tiles = { "mcl_pale_oak_leaves.png" },
		paramtype2 = "none",
		palette = "",
	},
	fence = {
		tiles = { "mcl_pale_oak_planks.png" },
	},
	door = {
		inventory_image = "mcl_pale_oak_door_item.png",
		tiles_bottom = {"mcl_pale_oak_door_bottom.png", "mcl_pale_oak_door_bottom.png"},
		tiles_top = {"mcl_pale_oak_door_top.png", "mcl_pale_oak_door_top.png"},
	},
	boat = {
		item = {
			inventory_image = "mcl_boats_pale_oak_boat.png",
			texture = "mcl_boats_texture_pale_oak_boat.png",
		},
	},
	sapling = {
		tiles = {"mcl_pale_oak_sapling_pale_oak.png"},
		inventory_image = "mcl_pale_oak_sapling_pale_oak.png",
		wield_image = "mcl_pale_oak_sapling_pale_oak.png",
	},
	potted_sapling = {
		image = "mcl_pale_oak_sapling_pale_oak.png",
	},
})
