local S = minetest.get_translator(minetest.get_current_modname())

mcl_stairs.register_stair_and_slab("stone_rough", {
	baseitem = "mcl_core:stone",
	description_stair = S("Stone Stairs"),
	description_slab = S("Stone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone"}},
})

mcl_stairs.register_slab("stone", {
	baseitem = "mcl_core:stone_smooth",
	description = S("Smooth Stone Slab"),
	tiles = {"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone_smooth"}},
})

mcl_stairs.register_stair_and_slab("cobble", {
	baseitem = "mcl_core:cobble",
	description_stair = S("Cobblestone Stairs"),
	description_slab = S("Cobblestone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:cobble"}},
})

mcl_stairs.register_stair_and_slab("brick_block", {
	baseitem = "mcl_core:brick_block",
	description_stair = S("Brick Stairs"),
	description_slab = S("Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:brick_block"}},
})

mcl_stairs.register_stair_and_slab("sandstone", {
	baseitem = "mcl_core:sandstone",
	description_stair = S("Sandstone Stairs"),
	description_slab = S("Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth2", {
	baseitem = "mcl_core:sandstonesmooth2",
	description_stair = S("Smooth Sandstone Stairs"),
	description_slab = S("Smooth Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth", {
	baseitem = "mcl_core:sandstonesmooth",
	description_stair = S("Cut Sandstone Stairs"),
	description_slab = S("Cut Sandstone Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone", "mcl_core:sandstonesmooth2"}},
})
