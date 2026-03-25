
	-- Cacti
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.012,
			scale = 0.024,
			spread = {x = 100, y = 100, z = 100},
			seed = 257,
			octaves = 3,
			persist = 0.6
		},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:cactus",
		biomes = {"Desert",
			"Mesa","Mesa_sandlevel",
			"MesaPlateauF","MesaPlateauF_sandlevel",
			"MesaPlateauFM","MesaPlateauFM_sandlevel"},
		height = 1,
		height_max = 3,
	})
	-- Dead bushes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.003,
			scale = 0.006,
			spread = {x = 160, y = 160, z = 160},
			seed = 1972,
			octaves = 3,
			persist = 0.6
		},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		biomes = {
			"Desert"
		},
		decoration = "mcl_core:deadbush",
		height = 1,
	})
