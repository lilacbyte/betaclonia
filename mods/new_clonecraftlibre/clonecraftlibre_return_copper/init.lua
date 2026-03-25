
local copperscarcity = minetest.settings:get("betaclonia.copper_clust_scarcity") or 11
local coppersmin = minetest.settings:get("betaclonia.copper_min") or -256
local coppersmax = minetest.settings:get("betaclonia.copper_max") or -16

if minetest.settings:get_bool("betaclonia.allow_copper_generation") == true then
	minetest.register_ore({
		ore_type = "scatter",
		ore = "mcl_copper:stone_with_copper",
		wherein = "mcl_core:stone",
		clust_scarcity = copperscarcity * copperscarcity * copperscarcity,
		clust_num_ores = 3,
		clust_size = 2,
		y_min = coppersmin,
		y_max = coppersmax,
	})
end
