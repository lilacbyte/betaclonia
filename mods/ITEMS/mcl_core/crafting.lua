-- mods/default/crafting.lua

--
-- Crafting definition
--

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:mossycobble",
	recipe = { "mcl_core:cobble", "mcl_core:vine" },
})

minetest.register_craft({
	output = "mcl_core:coarse_dirt 4",
	recipe = {
		{"mcl_core:dirt", "mcl_core:gravel"},
		{"mcl_core:gravel", "mcl_core:dirt"},
	}
})
minetest.register_craft({
	output = "mcl_core:coarse_dirt 4",
	recipe = {
		{"mcl_core:gravel", "mcl_core:dirt"},
		{"mcl_core:dirt", "mcl_core:gravel"},
	}
})

minetest.register_craft({
	output = "mcl_core:sandstonesmooth 4",
	recipe = {
		{"mcl_core:sandstone","mcl_core:sandstone"},
		{"mcl_core:sandstone","mcl_core:sandstone"},
	}
})

minetest.register_craft({
	output = "mcl_core:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})



minetest.register_craft({
	output = "mcl_core:sandstone",
	recipe = {
		{"mcl_core:sand", "mcl_core:sand"},
		{"mcl_core:sand", "mcl_core:sand"},
	}
})

minetest.register_craft({
	output = "mcl_core:clay",
	recipe = {
		{"mcl_core:clay_lump", "mcl_core:clay_lump"},
		{"mcl_core:clay_lump", "mcl_core:clay_lump"},
	}
})

minetest.register_craft({
	output = "mcl_core:brick_block",
	recipe = {
		{"mcl_core:brick", "mcl_core:brick"},
		{"mcl_core:brick", "mcl_core:brick"},
	}
})

minetest.register_craft({
	output = "mcl_core:paper 3",
	recipe = {
		{"mcl_core:reeds", "mcl_core:reeds", "mcl_core:reeds"},
	}
})

minetest.register_craft({
	output = "mcl_core:ladder 3",
	recipe = {
		{"mcl_core:stick", "", "mcl_core:stick"},
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"mcl_core:stick", "", "mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_core:sugar",
	recipe = {
		{"mcl_core:reeds"},
	}
})

minetest.register_craft({
	output = "mcl_core:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = "mcl_core:snowblock",
	recipe = {
		{"mcl_throwing:snowball", "mcl_throwing:snowball"},
		{"mcl_throwing:snowball", "mcl_throwing:snowball"},
	}
})

minetest.register_craft({
	output = "mcl_core:snow 6",
	recipe = {
		{"mcl_core:snowblock", "mcl_core:snowblock", "mcl_core:snowblock"},
	}
})

--
-- Crafting (tool repair)
--
minetest.register_craft({
	type = "toolrepair",
	additional_wear = -mcl_core.repair,
})
