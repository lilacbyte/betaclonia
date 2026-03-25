local S = minetest.get_translator(minetest.get_current_modname())

	-- Register bed
	mcl_beds.register_bed("mcl_beds:bed_red", {
		description = S("Bed"),
		_doc_items_create_entry = false,
		inventory_image = "mcl_beds_bed_red_inv.png",
		wield_image = "mcl_beds_bed_red_inv.png",
		tiles = {"mcl_beds_bed_red.png"},
		recipe = {
			{"group:wool", "group:wool", "group:wool"},
			{"group:wood", "group:wood", "group:wood"}
		},
	})

minetest.register_alias("beds:bed_bottom", "mcl_beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "mcl_beds:bed_red_top")
