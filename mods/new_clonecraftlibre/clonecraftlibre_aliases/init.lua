-- Minimal compatibility aliases.
-- Intentionally limited to non-removed content only.

local function bridge_wood_ids(src, dst)
	minetest.register_alias("mcl_trees:tree_" .. src, "mcl_trees:tree_" .. dst)
	minetest.register_alias("mcl_trees:wood_" .. src, "mcl_trees:wood_" .. dst)
	minetest.register_alias("mcl_trees:bark_" .. src, "mcl_trees:bark_" .. dst)
	minetest.register_alias("mcl_trees:stripped_" .. src, "mcl_trees:stripped_" .. dst)
	minetest.register_alias("mcl_trees:stripped_bark_" .. src, "mcl_trees:stripped_bark_" .. dst)
	minetest.register_alias("mcl_trees:sapling_" .. src, "mcl_trees:sapling_" .. dst)
	minetest.register_alias("mcl_trees:leaves_" .. src, "mcl_trees:leaves_" .. dst)

	minetest.register_alias("mcl_doors:door_" .. src, "mcl_doors:door_" .. dst)
	minetest.register_alias("mcl_doors:door_" .. src .. "_b_1", "mcl_doors:door_" .. dst .. "_b_1")
	minetest.register_alias("mcl_doors:door_" .. src .. "_t_1", "mcl_doors:door_" .. dst .. "_t_1")
	minetest.register_alias("mcl_doors:door_" .. src .. "_b_2", "mcl_doors:door_" .. dst .. "_b_2")
	minetest.register_alias("mcl_doors:door_" .. src .. "_t_2", "mcl_doors:door_" .. dst .. "_t_2")

	minetest.register_alias("mcl_fences:" .. src .. "_fence", "mcl_fences:" .. dst .. "_fence")
	minetest.register_alias("mcl_fences:" .. src .. "_fence_gate", "mcl_fences:" .. dst .. "_fence")
	minetest.register_alias("mcl_fences:" .. src .. "_fence_gate_open", "mcl_fences:" .. dst .. "_fence")

	minetest.register_alias("mcl_signs:wall_sign_" .. src, "mcl_signs:wall_sign_" .. dst)
	minetest.register_alias("mcl_signs:standing_sign_" .. src, "mcl_signs:standing_sign_" .. dst)
	minetest.register_alias("mcl_pressureplates:pressure_plate_" .. src .. "_off", "mcl_pressureplates:pressure_plate_" .. dst .. "_off")
	minetest.register_alias("mcl_pressureplates:pressure_plate_" .. src .. "_on", "mcl_pressureplates:pressure_plate_" .. dst .. "_on")
	minetest.register_alias("mcl_buttons:button_" .. src .. "_off", "mcl_buttons:button_" .. dst .. "_off")
	minetest.register_alias("mcl_buttons:button_" .. src .. "_on", "mcl_buttons:button_" .. dst .. "_on")

	minetest.register_alias("mcl_stairs:stair_" .. src, "mcl_stairs:stair_" .. dst)
	minetest.register_alias("mcl_stairs:stair_" .. src .. "_inner", "mcl_stairs:stair_" .. dst .. "_inner")
	minetest.register_alias("mcl_stairs:stair_" .. src .. "_outer", "mcl_stairs:stair_" .. dst .. "_outer")
	minetest.register_alias("mcl_stairs:slab_" .. src, "mcl_stairs:slab_" .. dst)
	minetest.register_alias("mcl_stairs:slab_" .. src .. "_top", "mcl_stairs:slab_" .. dst .. "_top")
	minetest.register_alias("mcl_stairs:slab_" .. src .. "_double", "mcl_stairs:slab_" .. dst .. "_double")

	minetest.register_alias("mcl_boats:boat_" .. src, "mcl_boats:boat_" .. dst)
	minetest.register_alias("mcl_boats:boat_" .. src .. "_chest", "mcl_boats:boat_" .. dst)
end

-- Mineclonia naming bridges for reintroduced woods.
bridge_wood_ids("cherry", "cherry_blossom")
bridge_wood_ids("pale", "pale_oak")

-- Legacy cherry IDs from older layouts.
minetest.register_alias("mcl_cherry_blossom:cherrytree", "mcl_trees:tree_cherry_blossom")
minetest.register_alias("mcl_cherry_blossom:cherrywood", "mcl_trees:wood_cherry_blossom")
minetest.register_alias("mcl_cherry_blossom:cherryleaves", "mcl_trees:leaves_cherry_blossom")
minetest.register_alias("mcl_cherry_blossom:cherrysapling", "mcl_trees:sapling_cherry_blossom")


-- Copper tool ID compatibility.
minetest.register_alias("mcl_copper:pickaxe_copper", "mcl_copper:pick_copper")
minetest.register_alias("mcl_tools:pick_copper", "mcl_copper:pick_copper")
minetest.register_alias("mcl_tools:axe_copper", "mcl_copper:axe_copper")
minetest.register_alias("mcl_tools:shovel_copper", "mcl_copper:shovel_copper")
minetest.register_alias("mcl_tools:sword_copper", "mcl_copper:sword_copper")
minetest.register_alias("mcl_tools:hoe_copper", "mcl_copper:hoe_copper")
minetest.register_alias("mcl_tools:pickaxe_copper", "mcl_copper:pick_copper")
minetest.register_alias("mcl_tools:copper_pickaxe", "mcl_copper:pick_copper")
minetest.register_alias("mcl_tools:copper_axe", "mcl_copper:axe_copper")
minetest.register_alias("mcl_tools:copper_shovel", "mcl_copper:shovel_copper")
minetest.register_alias("mcl_tools:copper_sword", "mcl_copper:sword_copper")
