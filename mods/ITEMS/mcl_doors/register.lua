local S = minetest.get_translator(minetest.get_current_modname())

--- Iron Door ---
mcl_doors:register_door("mcl_doors:iron_door", {
	description = S("Iron Door"),
	_doc_items_longdesc = S("Iron doors are 2-block high barriers which can only be opened or closed by a redstone signal, but not by hand."),
	_doc_items_usagehelp = S("To open or close an iron door, supply its lower half with a redstone signal."),
	inventory_image = "doors_item_steel.png",
	groups = {pickaxey=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 5,
	tiles_bottom = {"mcl_doors_door_iron_lower.png^[transformFX", "mcl_doors_door_iron_side_lower.png"},
	tiles_top = {"mcl_doors_door_iron_upper.png^[transformFX", "mcl_doors_door_iron_side_upper.png"},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcl_doors:iron_door 3",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"}
	}
})

-- Oak Trapdoor (re-enabled)
mcl_doors:register_trapdoor("mcl_doors:trapdoor_oak", {
	description = S("Oak Trapdoor"),
	_doc_items_longdesc = S("Oak trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on placement. When open, they can be climbed like a ladder."),
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	wield_image = "doors_trapdoor.png",
	groups = {handy=1, axey=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_burntime = 15,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:trapdoor_oak 2",
	recipe = {
		{"mcl_trees:wood_oak","mcl_trees:wood_oak","mcl_trees:wood_oak"},
		{"mcl_trees:wood_oak","mcl_trees:wood_oak","mcl_trees:wood_oak"},
	}
})
