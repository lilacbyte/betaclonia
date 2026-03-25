-- Temporary helper recipes.
-- These recipes are NOT part of The OG Game. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "mcl_chests:trapped_chest",
	recipe = {"mcl_core:iron_ingot", "mcl_core:stick", "group:wood", "mcl_chests:chest"},
})
