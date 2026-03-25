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

-- Trapdoors removed for beta gameplay rules.
