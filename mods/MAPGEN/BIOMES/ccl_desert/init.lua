table.insert(ccl_overworld_biomes, "Desert")

if not mcl_vars.superflat then
	-- Desert
	minetest.register_biome({
		name = "Desert",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		node_stone = "mcl_core:sandstone",
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 26,
		heat_point = 94,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 17,
		_mcl_skycolor = "#6EB1FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	minetest.register_biome({
		name = "Desert_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 26,
		heat_point = 94,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 17,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})
end
