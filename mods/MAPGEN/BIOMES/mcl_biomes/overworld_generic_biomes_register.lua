-- All mapgens except flat and singlenode
local function register_beta_biome(def)
	if not def or not def.name then return end
	local n = def.name
	if n == "IcePlains" or n == "IcePlains_ocean" or
			n == "Plains" or n == "Plains_beach" or n == "Plains_ocean" or
			n == "Taiga" or n == "Taiga_beach" or n == "Taiga_ocean" or
			n == "Forest" or n == "Forest_beach" or n == "Forest_ocean" or
			n == "Savanna" or n == "Savanna_beach" or n == "Savanna_ocean" or
			n == "Jungle" or n == "Jungle_shore" or n == "Jungle_ocean" or
			n == "Swampland" or n == "Swampland_shore" or n == "Swampland_ocean" then
		minetest.register_biome(def)
	end
end

	-- Cold Taiga
	register_beta_biome({
		name = "ColdTaiga",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:dirt_with_grass_snow",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 58,
		heat_point = 8,
		_mcl_biome_type = "snowy",
		_mcl_palette_index = 3,
		_mcl_skycolor = "#839EFF",
		_mcl_fogcolor = overworld_fogcolor
	})

	-- A cold beach-like biome, implemented as low part of Cold Taiga
	register_beta_biome({
		name = "ColdTaiga_beach",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_water_top = "mcl_core:ice",
		depth_water_top = 1,
		node_filler = "mcl_core:sandstone",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 2,
		humidity_point = 58,
		heat_point = 8,
		_mcl_biome_type = "snowy",
		_mcl_palette_index = 3,
		_mcl_skycolor = "#7FA1FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	-- Water part of the beach. Added to prevent snow being on the ice.
	register_beta_biome({
		name = "ColdTaiga_beach_water",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_water_top = "mcl_core:ice",
		depth_water_top = 1,
		node_filler = "mcl_core:sandstone",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -4,
		y_max = 0,
		humidity_point = 58,
		heat_point = 8,
		_mcl_biome_type = "snowy",
		_mcl_palette_index = 3,
		_mcl_skycolor = "#7FA1FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "ColdTaiga_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -5,
		humidity_point = 58,
		heat_point = 8,
		vertical_blend = 1,
		_mcl_biome_type = "snowy",
		_mcl_palette_index = 3,
		_mcl_skycolor = "#7FA1FF",
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Mega Pine Taiga
	register_beta_biome({
		name = "MegaTaiga",
		node_top = "mcl_core:podzol",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 76,
		heat_point = 10,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 4,
		_mcl_skycolor = "#7CA3FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "MegaTaiga_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 76,
		heat_point = 10,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 4,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Mega Spruce Taiga
	register_beta_biome({
		name = "MegaSpruceTaiga",
		node_top = "mcl_core:podzol",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 100,
		heat_point = 8,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 5,
		_mcl_skycolor = "#7DA3FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "MegaSpruceTaiga_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 100,
		heat_point = 8,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 5,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})


	-- Stone beach
	-- Just stone.
	-- Not neccessarily a beach at all, only named so according to MC
	register_beta_biome({
		name = "StoneBeach",
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 1,
		y_min = -7,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 0,
		heat_point = 8,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 9,
		_mcl_skycolor = "#7DA2FF",
		_mcl_fogcolor = overworld_fogcolor
	})

	register_beta_biome({
		name = "StoneBeach_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 1,
		y_min = OCEAN_MIN,
		y_max = -8,
		vertical_blend = 2,
		humidity_point = 0,
		heat_point = 8,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 9,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Ice Plains
	register_beta_biome({
		name = "IcePlains",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:dirt_with_grass_snow",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_water_top = "mcl_core:ice",
		depth_water_top = 2,
		node_river_water = "mcl_core:ice",
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 24,
		heat_point = 8,
		_mcl_biome_type = "snowy",
		_mcl_palette_index = 10,
		_mcl_skycolor = "#7FA1FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "IcePlains_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 24,
		heat_point = 8,
		_mcl_biome_type = "snowy",
		_mcl_palette_index = 10,
		_mcl_skycolor = "#7FA1FF",
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Plains
	register_beta_biome({
		name = "Plains",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 39,
		heat_point = 58,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Plains_beach",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_filler = "mcl_core:sandstone",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 0,
		y_max = 2,
		humidity_point = 39,
		heat_point = 58,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
		_mcl_skycolor = beach_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Plains_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -1,
		humidity_point = 39,
		heat_point = 58,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Sunflower Plains
	register_beta_biome({
		name = "SunflowerPlains",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 28,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 11,
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "SunflowerPlains_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:dirt",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 28,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 11,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Taiga
	register_beta_biome({
		name = "Taiga",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 58,
		heat_point = 22,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 12,
		_mcl_skycolor = "#7DA3FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Taiga_beach",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_filler = "mcl_core:sandstone",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 3,
		humidity_point = 58,
		heat_point = 22,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 12,
		_mcl_skycolor = beach_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Taiga_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 58,
		heat_point = 22,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 12,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Forest
	register_beta_biome({
		name = "Forest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 61,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 13,
		_mcl_skycolor = "#79A6FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Forest_beach",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_filler = "mcl_core:sandstone",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -1,
		y_max = 0,
		humidity_point = 61,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 13,
		_mcl_skycolor = beach_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Forest_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -2,
		humidity_point = 61,
		heat_point = 45,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 13,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Flower Forest
	register_beta_biome({
		name = "FlowerForest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 44,
		heat_point = 32,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 14,
		_mcl_skycolor = "#79A6FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "FlowerForest_beach",
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_filler = "mcl_core:sandstone",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -2,
		y_max = 2,
		humidity_point = 44,
		heat_point = 32,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 14,
		_mcl_skycolor = beach_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "FlowerForest_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -3,
		humidity_point = 44,
		heat_point = 32,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 14,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Birch Forest
	register_beta_biome({
		name = "BirchForest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 78,
		heat_point = 31,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 15,
		_mcl_skycolor = "#7AA5FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "BirchForest_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 78,
		heat_point = 31,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 15,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Birch Forest M
	register_beta_biome({
		name = "BirchForestM",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 77,
		heat_point = 27,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 16,
		_mcl_skycolor = "#7AA5FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "BirchForestM_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 77,
		heat_point = 27,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 16,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Roofed Forest
	register_beta_biome({
		name = "RoofedForest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 94,
		heat_point = 27,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 18,
		_mcl_skycolor = "#79A6FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "RoofedForest_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 94,
		heat_point = 27,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 18,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Savanna
	register_beta_biome({
		name = "Savanna",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 36,
		heat_point = 79,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 1,
		_mcl_skycolor = "#6EB1FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Savanna_beach",
		node_top = "mcl_core:sand",
		depth_top = 3,
		node_filler = "mcl_core:sandstone",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -1,
		y_max = 0,
		humidity_point = 36,
		heat_point = 79,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 1,
		_mcl_skycolor = beach_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Savanna_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -2,
		humidity_point = 36,
		heat_point = 79,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 1,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Savanna M
	-- Changes to Savanna: Coarse Dirt. No sand beach. No oaks.
	-- Otherwise identical to Savanna
	register_beta_biome({
		name = "SavannaM",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:coarse_dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 48,
		heat_point = 100,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 23,
		_mcl_skycolor = "#6EB1FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "SavannaM_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 48,
		heat_point = 100,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 23,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Jungle
	register_beta_biome({
		name = "Jungle",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 88,
		heat_point = 81,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 24,
		_mcl_skycolor = "#77A8FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Jungle_shore",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -2,
		y_max = 0,
		humidity_point = 88,
		heat_point = 81,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 24,
		_mcl_skycolor = "#77A8FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Jungle_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -3,
		vertical_blend = 1,
		humidity_point = 88,
		heat_point = 81,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 24,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Jungle M
	-- Like Jungle but with even more dense vegetation
	register_beta_biome({
		name = "JungleM",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 92,
		heat_point = 81,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 25,
		_mcl_skycolor = "#77A8FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "JungleM_shore",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -2,
		y_max = 0,
		humidity_point = 92,
		heat_point = 81,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 25,
		_mcl_skycolor = "#77A8FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "JungleM_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -3,
		vertical_blend = 1,
		humidity_point = 92,
		heat_point = 81,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 25,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})



	-- Jungle Edge
	register_beta_biome({
		name = "JungleEdge",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 88,
		heat_point = 76,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 26,
		_mcl_skycolor = "#77A8FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "JungleEdge_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 88,
		heat_point = 76,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 26,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Jungle Edge M (very rare).
	-- Almost identical to Jungle Edge. Has deeper dirt. Melons spawn here a lot.
	-- This biome occours directly between Jungle M and Jungle Edge but also has a small border to Jungle.
	-- This biome is very small in general.
	register_beta_biome({
		name = "JungleEdgeM",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 4,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 90,
		heat_point = 79,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 26,
		_mcl_skycolor = "#77A8FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "JungleEdgeM_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 4,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = 0,
		humidity_point = 90,
		heat_point = 79,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 26,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Swampland
	register_beta_biome({
		name = "Swampland",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		-- Note: Limited in height!
		y_max = 23,
		humidity_point = 90,
		heat_point = 50,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 28,
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Swampland_shore",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -5,
		y_max = 0,
		humidity_point = 90,
		heat_point = 50,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 28,
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = overworld_fogcolor
	})
	register_beta_biome({
		name = "Swampland_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = OCEAN_MIN,
		y_max = -6,
		vertical_blend = 1,
		humidity_point = 90,
		heat_point = 50,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 28,
		_mcl_skycolor = ocean_skycolor,
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Cherry Grove (rare)
	register_beta_biome({
		name = "CherryGrove",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 52,
		heat_point = 36,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 30,
		_mcl_skycolor = "#79A6FF",
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Mangrove Swamp (rare)
	register_beta_biome({
		name = "MangroveSwamp",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 20,
		humidity_point = 97,
		heat_point = 75,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 31,
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = overworld_fogcolor
	})

	-- Pale Garden (rare)
	register_beta_biome({
		name = "PaleGarden",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 67,
		heat_point = 34,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 32,
		_mcl_skycolor = "#7AA5FF",
		_mcl_fogcolor = overworld_fogcolor
	})
