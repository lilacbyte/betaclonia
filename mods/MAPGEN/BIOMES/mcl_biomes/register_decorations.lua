local mod_mcl_core = minetest.get_modpath("mcl_core")
local mod_mcl_mushrooms = minetest.get_modpath("mcl_mushrooms")
local mod_mcl_structures = minetest.get_modpath("mcl_structures")
local beta_register_decoration
local stonelike = {"mcl_core:stone"}


-- All mapgens

-- Template to register a grass or fern decoration
function mcl_biomes.register_grass_decoration(grasstype, offset, scale, biomes)
	local place_on, seed, node
	if grasstype == "fern" then
		node = "mcl_flowers:fern"
		place_on = {"group:grass_block_no_snow", "mcl_core:podzol"}
		seed = 333
	elseif grasstype == "tallgrass" then
		node = "mcl_flowers:tallgrass"
		place_on = {"group:grass_block_no_snow"}
		seed = 420
	end
	local noise = {
		offset = offset,
		scale = scale,
		spread = {x = 200, y = 200, z = 200},
		seed = seed,
		octaves = 3,
		persist = 0.6
	}
	for b=1, #biomes do
		local localbiometablething = minetest.registered_biomes[biomes[b]]
		local param2 = 0
		if localbiometablething then
			param2 = localbiometablething._mcl_palette_index or 0
		end
		beta_register_decoration({
			deco_type = "simple",
			place_on = place_on,
			sidelen = 16,
			noise_params = noise,
			biomes = { biomes[b] },
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			decoration = node,
			param2 = param2,
		})
	end
end

local function filter_existing_biomes(biomes)
	if type(biomes) ~= "table" then
		return biomes, true
	end
	local filtered = {}
	for i = 1, #biomes do
		local b = biomes[i]
		local id = minetest.get_biome_id(b)
		if id and id ~= 0 and id ~= -1 then
			filtered[#filtered + 1] = b
		end
	end
	return filtered, #filtered > 0
end

local function is_tree_schematic(path)
	if type(path) ~= "string" then
		return false
	end
	return path:find("mcl_core_oak", 1, true) ~= nil
		or path:find("mcl_core_spruce", 1, true) ~= nil
		or path:find("mcl_core_birch", 1, true) ~= nil
end

local function is_spruce_schematic(path)
	return type(path) == "string" and path:find("mcl_core_spruce", 1, true) ~= nil
end

local function get_tree_type(path)
	if type(path) ~= "string" then
		return nil
	end
	if path:find("mcl_core_spruce", 1, true) then
		return "spruce"
	end
	if path:find("mcl_core_birch", 1, true) then
		return "birch"
	end
	if path:find("mcl_core_oak", 1, true) then
		return "oak"
	end
	return nil
end

local tree_biomes = {
	oak = { Forest=true, Plains=true },
	birch = { Forest=true, Plains=true },
	spruce = { Forest=true, IcePlains=true },
}

local function constrain_tree_biomes(def)
	if not def or def.deco_type ~= "schematic" or not is_tree_schematic(def.schematic) or type(def.biomes) ~= "table" then
		return true
	end
	local t = get_tree_type(def.schematic)
	local allowed = t and tree_biomes[t]
	if not allowed then
		return true
	end
	local filtered = {}
	for i = 1, #def.biomes do
		local b = def.biomes[i]
		if allowed[b] then
			filtered[#filtered + 1] = b
		end
	end
	if #filtered == 0 then
		return false
	end
	def.biomes = filtered
	return true
end

local grass_nodes = {
	["mcl_flowers:tallgrass"] = true,
	["mcl_flowers:fern"] = true,
	["mcl_flowers:double_grass"] = true,
	["mcl_flowers:double_grass_top"] = true,
	["mcl_flowers:double_fern"] = true,
	["mcl_flowers:double_fern_top"] = true,
}

local function is_grass_like_decoration(def)
	if not def then
		return false
	end
	if type(def.decoration) == "string" and grass_nodes[def.decoration] then
		return true
	end
	if type(def.schematic) == "table" and type(def.schematic.data) == "table" then
		for i = 1, #def.schematic.data do
			local n = def.schematic.data[i] and def.schematic.data[i].name
			if type(n) == "string" and grass_nodes[n] then
				return true
			end
		end
	end
	return false
end

local function reduce_tree_density(def)
	if not def or def.deco_type ~= "schematic" or not is_tree_schematic(def.schematic) then
		return
	end
	if def._no_tree_density_reduce then
		return
	end

	-- Moderate reduction so trees still appear reliably.
	if def.fill_ratio then
		def.fill_ratio = def.fill_ratio * 0.35
	end

	local np = def.noise_params
	if np then
		local old_scale = np.scale or 0
		if old_scale ~= 0 then
			np.scale = old_scale * 0.55
		end
		local old_offset = np.offset or 0
		local bias = math.abs(old_scale) * 0.28
		np.offset = old_offset - bias
	end

	local tree_type = get_tree_type(def.schematic)

	-- Spruce should exist, but be very rare.
	if tree_type == "spruce" then
		if def.fill_ratio then
			def.fill_ratio = def.fill_ratio * 0.4
		end
		if np then
			local scale = np.scale or 0
			if scale ~= 0 then
				np.scale = scale * 0.5
			end
			np.offset = (np.offset or 0) - (math.abs(scale) * 0.35 + 0.00005)
		end
	end

	-- Birch should be clearly less common than oak.
	if tree_type == "birch" then
		if def.fill_ratio then
			def.fill_ratio = def.fill_ratio * 0.5
		end
		if np then
			np.offset = (np.offset or 0) - math.abs(np.scale or 0) * 0.20
		end
	end
end

local function reduce_grass_density(def)
	if not is_grass_like_decoration(def) then
		return
	end

	-- Moderate throttle: keep grass visible while avoiding overpopulation.
	if def.fill_ratio then
		def.fill_ratio = def.fill_ratio * 0.3
	end
	if def.sidelen and def.sidelen < 32 then
		def.sidelen = 10
	end
	local np = def.noise_params
	if np then
		local old_scale = np.scale or 0
		if old_scale ~= 0 then
			np.scale = old_scale * 0.2
		end
		np.offset = (np.offset or 0) - math.abs(old_scale) * 0.35 - 0.00035
	end
end

function beta_register_decoration(def)
	if def and def.biomes ~= nil then
		local filtered, ok = filter_existing_biomes(def.biomes)
		if not ok then
			return
		end
		def.biomes = filtered
	end
	if not constrain_tree_biomes(def) then
		return
	end
	reduce_tree_density(def)
	reduce_grass_density(def)
	minetest.register_decoration(def)
end


	-- Oak
	-- Large oaks
	for i=1, 4 do
		beta_register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
			sidelen = 80,
			noise_params = {
				offset = 0.000545,
				scale = 0.0011,
				spread = {x = 250, y = 250, z = 250},
				seed = 3 + 5 * i,
				octaves = 3,
				persist = 0.66
			},
			biomes = {"Forest"},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			schematic = mod_mcl_core.."/schematics/mcl_core_oak_large_"..i..".mts",
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
	-- Small “classic” oak (many biomes)
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.025,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.01,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"FlowerForest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.015,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"MesaPlateauF_grasstop"},
		y_min = 30,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.008,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"MesaPlateauFM_grasstop"},
		y_min = 30,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:dirt", },
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = 0.0002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"IcePlains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
		-- Rare balloon oak
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.002083,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 3,
			octaves = 3,
			persist = 0.6,
		},
		biomes = {"Forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_oak_balloon.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Very rare cherry blossom trees in Plains.
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 80,
		fill_ratio = 0.000002,
		biomes = {"Plains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_cherry.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Huge spruce
	mcl_quick_spruce(3000, 0.0030, "mcl_core_spruce_huge_1.mts", {"MegaSpruceTaiga"})
	mcl_quick_spruce(4000, 0.0036, "mcl_core_spruce_huge_2.mts", {"MegaSpruceTaiga"})
	mcl_quick_spruce(6000, 0.0036, "mcl_core_spruce_huge_3.mts", {"MegaSpruceTaiga"})
	mcl_quick_spruce(6600, 0.0036, "mcl_core_spruce_huge_4.mts", {"MegaSpruceTaiga"})

	mcl_quick_spruce(3000, 0.0008, "mcl_core_spruce_huge_up_1.mts", {"MegaTaiga"})
	mcl_quick_spruce(4000, 0.0008, "mcl_core_spruce_huge_up_2.mts", {"MegaTaiga"})
	mcl_quick_spruce(6000, 0.0008, "mcl_core_spruce_huge_up_3.mts", {"MegaTaiga"})


	-- Common spruce
	mcl_quick_spruce(11000, 0.00150, "mcl_core_spruce_5.mts", {"Taiga", "ColdTaiga"})

	mcl_quick_spruce(2500, 0.00325, "mcl_core_spruce_1.mts", {"MegaSpruceTaiga", "MegaTaiga", "Taiga", "ColdTaiga"})
	mcl_quick_spruce(7000, 0.00425, "mcl_core_spruce_3.mts", {"MegaSpruceTaiga", "MegaTaiga", "Taiga", "ColdTaiga"})
	mcl_quick_spruce(9000, 0.00325, "mcl_core_spruce_4.mts", {"MegaTaiga", "Taiga", "ColdTaiga"})

	mcl_quick_spruce(9500, 0.00500, "mcl_core_spruce_tall.mts", {"MegaTaiga"})

	mcl_quick_spruce(5000, 0.00250, "mcl_core_spruce_2.mts", {"MegaSpruceTaiga", "MegaTaiga"})


	-- Small lollipop spruce
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:podzol"},
		sidelen = 16,
		noise_params = {
			offset = 0.004,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2500,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Taiga", "ColdTaiga"},
		y_min = 2,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_spruce_lollipop.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Matchstick spruce: Very few leaves, tall trunk
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:podzol"},
		sidelen = 80,
		noise_params = {
			offset = -0.025,
			scale = 0.025,
			spread = {x = 250, y = 250, z = 250},
			seed = 2566,
			octaves = 5,
			persist = 0.60,
		},
		biomes = {"Taiga", "ColdTaiga"},
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_spruce_matchstick.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Rare spruce in Ice Plains
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block"},
		sidelen = 16,
		noise_params = {
			offset = -0.00075,
			scale = -0.0015,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"IcePlains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_spruce_5.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Rare spruce in Forest
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = -0.0012,
			scale = -0.0017,
			spread = {x = 250, y = 250, z = 250},
			seed = 2121,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"Forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_spruce_5.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Birch
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.03,
			scale = 0.0025,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"BirchForest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_birch.mts",
		flags = "place_center_x, place_center_z",
	})
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.03,
			scale = 0.0025,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"BirchForestM"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_birch_tall.mts",
		flags = "place_center_x, place_center_z",
	})

	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.000333,
			scale = -0.0015,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Forest", "FlowerForest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_birch.mts",
		flags = "place_center_x, place_center_z",
	})
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 80,
		fill_ratio = 0.006,
		biomes = {"Plains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_birch.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 80,
		fill_ratio = 0.0025,
		biomes = {"Plains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_birch_tall.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.008,
			scale = 0.0012,
			spread = {x = 250, y = 250, z = 250},
			seed = 911,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Plains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_birch.mts",
		flags = "place_center_x, place_center_z",
	})

	local ratio_mushroom = 0.0001
	local ratio_mushroom_huge = ratio_mushroom * (11/12)
	local ratio_mushroom_giant = ratio_mushroom * (1/12)

	--Snow on snowy dirt
	beta_register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass_snow"},
		sidelen = 80,
		fill_ratio = 10,
		flags = "all_floors",
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:snow",
	})

	--Mushrooms in caves
	beta_register_decoration({
		deco_type = "simple",
		place_on = stonelike,
		sidelen = 80,
		fill_ratio = 0.009,
		noise_threshold = 2.0,
		flags = "all_floors",
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_mushrooms:mushroom_red",
	})
	beta_register_decoration({
		deco_type = "simple",
		place_on = stonelike,
		sidelen = 80,
		fill_ratio = 0.009,
		noise_threshold = 2.0,
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_mushrooms:mushroom_brown",
	})


	-- Sugar canes
	beta_register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.40,
			scale = 0.55,
			spread = {x = 200, y = 200, z = 200},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})
	beta_register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.08,
			scale = 0.38,
			spread = {x = 200, y = 200, z = 200},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"Swampland", "Swampland_shore"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})

	-- Doubletall grass
	function mcl_biomes.register_doubletall_grass(offset, scale, biomes)

		for b=1, #biomes do
			local localbiometablething = minetest.registered_biomes[biomes[b]]
			local param2 = 0
			if localbiometablething then
				param2 = localbiometablething._mcl_palette_index or 0
			end
			beta_register_decoration({
				deco_type = "schematic",
				schematic = {
					size = { x=1, y=3, z=1 },
					data = {
						{ name = "air", prob = 0 },
						{ name = "mcl_flowers:double_grass", param1=255, param2=param2 },
						{ name = "mcl_flowers:double_grass_top", param1=255, param2=param2 },
					},
				},
				place_on = {"group:grass_block_no_snow"},
				sidelen = 16,
				noise_params = {
					offset = offset,
					scale = scale,
					spread = {x = 200, y = 200, z = 200},
					seed = 420,
					octaves = 3,
					persist = 0.6,
				},
				y_min = 1,
				y_max = mcl_vars.mg_overworld_max,
				biomes = { biomes[b] },
			})
		end
	end

	local register_doubletall_grass = mcl_biomes.register_doubletall_grass

	register_doubletall_grass(-0.01, 0.03, {"Taiga", "Forest", "FlowerForest", "BirchForest", "BirchForestM", "RoofedForest"})
	register_doubletall_grass(-0.002, 0.03, {"Plains", "SunflowerPlains"})
	register_doubletall_grass(-0.0005, -0.03, {"Savanna", "SavannaM"})

	-- Large ferns
	function mcl_biomes.register_double_fern(offset, scale, biomes)
		for b=1, #biomes do
			local localbiometablething = minetest.registered_biomes[biomes[b]]
			local param2 = 0
			if localbiometablething then
				param2 = localbiometablething._mcl_palette_index or 0
			end
			beta_register_decoration({
				deco_type = "schematic",
				schematic = {
					size = { x=1, y=3, z=1 },
					data = {
						{ name = "air", prob = 0 },
						{ name = "mcl_flowers:double_fern", param1=255, param2=param2 },
						{ name = "mcl_flowers:double_fern_top", param1=255, param2=param2 },
					},
				},
				place_on = {"group:grass_block_no_snow", "mcl_core:podzol"},
				sidelen = 16,
				noise_params = {
					offset = offset,
					scale = scale,
					spread = {x = 250, y = 250, z = 250},
					seed = 333,
					octaves = 2,
					persist = 0.66,
				},
				y_min = 1,
				y_max = mcl_vars.mg_overworld_max,
				biomes = biomes[b],
			})
		end
	end

	local register_double_fern = mcl_biomes.register_double_fern

	register_double_fern(0.01, 0.03, { "Taiga", "ColdTaiga", "MegaTaiga", "MegaSpruceTaiga" })

	-- Large flowers
	function mcl_biomes.register_large_flower(name, biomes, seed, offset, flower_forest_offset)
		local maxi
		if flower_forest_offset then
			maxi = 2
		else
			maxi = 1
		end
		for i=1, maxi do
			local o, b -- offset, biomes
			if i == 1 then
				o = offset
				b = biomes
			else
				o = flower_forest_offset
				b = { "FlowerForest" }
			end

			beta_register_decoration({
				deco_type = "schematic",
				schematic = {
					size = {x = 1, y = 3, z = 1},
					data = {
						{name = "air", prob = 0},
						{name = "mcl_flowers:" .. name, param1 = 255, },
						{name = "mcl_flowers:" .. name .. "_top", param1 = 255, },
					},
				},
				place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},

				sidelen = 16,
				noise_params = {
					offset = o,
					scale = 0.01,
					spread = {x = 300, y = 300, z = 300},
					seed = seed,
					octaves = 5,
					persist = 0.62,
				},
				y_min = 1,
				y_max = mcl_vars.mg_overworld_max,
				flags = "",
				biomes = b,
			})
		end
	end

	local register_large_flower = mcl_biomes.register_large_flower

	register_large_flower("peony", {"Forest"}, 10450, -0.008, 0.003)
	register_large_flower("lilac", {"Forest"}, 10600, -0.007, 0.003)
	register_large_flower("sunflower", {"SunflowerPlains"}, 2940, 0.01)

	-- Melon world generation intentionally removed.

	-- Pumpkin
	beta_register_decoration({
		deco_type = "simple",
		decoration = "mcl_farming:pumpkin",
		param2 = 0,
		param2_max = 3,
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = -0.016,
			scale = 0.01332,
			spread = {x = 125, y = 125, z = 125},
			seed = 666,
			octaves = 6,
			persist = 0.666
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
	})

	-- Grasses and ferns
	local grass_forest = {"Plains", "Taiga", "Forest", "FlowerForest", "BirchForest", "BirchForestM", "RoofedForest" }
	local grass_mpf = {"MesaPlateauF_grasstop"}
	local grass_plains = {"Plains", "SunflowerPlains" }
	local grass_savanna = {"Savanna", "SavannaM"}
	local grass_sparse = {"ExtremeHills", "ExtremeHills+", "ExtremeHills+_snowtop", "ExtremeHillsM" }
	local grass_mpfm = {"MesaPlateauFM_grasstop" }

	local register_grass_decoration = mcl_biomes.register_grass_decoration
	register_grass_decoration("tallgrass", -0.03,  0.09, grass_forest)
	register_grass_decoration("tallgrass", -0.015, 0.075, grass_forest)
	register_grass_decoration("tallgrass", 0,      0.06, grass_forest)
	register_grass_decoration("tallgrass", 0.015,  0.045, grass_forest)
	register_grass_decoration("tallgrass", 0.03,   0.03, grass_forest)
	register_grass_decoration("tallgrass", -0.03, 0.09, grass_mpf)
	register_grass_decoration("tallgrass", -0.015, 0.075, grass_mpf)
	register_grass_decoration("tallgrass", 0, 0.06, grass_mpf)
	register_grass_decoration("tallgrass", 0.01, 0.045, grass_mpf)
	register_grass_decoration("tallgrass", 0.01, 0.05, grass_forest)
	register_grass_decoration("tallgrass", 0.03, 0.03, grass_plains)
	register_grass_decoration("tallgrass", 0.05, 0.01, grass_plains)
	register_grass_decoration("tallgrass", 0.07, -0.01, grass_plains)
	register_grass_decoration("tallgrass", 0.09, -0.03, grass_plains)
	register_grass_decoration("tallgrass", 0.18, -0.03, grass_savanna)
	register_grass_decoration("tallgrass", 0.05, -0.03, grass_sparse)
	register_grass_decoration("tallgrass", 0.05, 0.05, grass_mpfm)

	local fern_minimal = { "Taiga", "MegaTaiga", "MegaSpruceTaiga", "ColdTaiga" }
	local fern_low = { "Taiga", "MegaTaiga", "MegaSpruceTaiga" }

	register_grass_decoration("fern", -0.03,  0.09, fern_minimal)
	register_grass_decoration("fern", -0.015, 0.075, fern_minimal)
	register_grass_decoration("fern", 0,      0.06, fern_minimal)
	register_grass_decoration("fern", 0.015,  0.045, fern_low)
	register_grass_decoration("fern", 0.03,   0.03, fern_low)


	local localiceplainstablething = minetest.registered_biomes["IcePlains"]
	local localiceplainsthingparam2 = 0
	if localiceplainstablething then
		localiceplainsthingparam2 = localiceplainstablething._mcl_palette_index or 0
	end
	-- Place tall grass on snow in Ice Plains and Extreme Hills+
	beta_register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block"},
		sidelen = 16,
		noise_params = {
			offset = -0.08,
			scale = 0.09,
			spread = {x = 15, y = 15, z = 15},
			seed = 420,
			octaves = 3,
			persist = 0.6,
		},
		biomes = {"IcePlains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = { x=1, y=2, z=1 },
			data = {
				{ name = "mcl_core:dirt_with_grass", force_place=true, },
				{ name = "mcl_flowers:tallgrass", param2 = localiceplainsthingparam2 },
			},
		},
	})



	-- Small Mushrooms
	local mushrooms = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}
	local mseeds = { 7133, 8244 }
	for m=1, #mushrooms do
		-- Mushrooms in Taiga
		beta_register_decoration({
			deco_type = "simple",
			place_on = {"mcl_core:podzol"},
			sidelen = 80,
			fill_ratio = 0.003,
			biomes = {"MegaTaiga", "MegaSpruceTaiga"},
			y_min = mcl_vars.mg_overworld_min,
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
		})
		-- Mushrooms next to trees
		beta_register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:stone"},
			sidelen = 16,
			noise_params = {
				offset = 0,
				scale = 0.003,
				spread = {x = 250, y = 250, z = 250},
				seed = mseeds[m],
				octaves = 3,
				persist = 0.66,
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
			spawn_by = { "mcl_trees:tree_oak", "mcl_trees:tree_spruce", "mcl_trees:tree_birch" },
			num_spawn_by = 1,
		})

	end

	function mcl_biomes.register_flower(name, biomes, seed, is_in_flower_forest)
		if is_in_flower_forest == nil then
			is_in_flower_forest = true
		end
		if biomes then
			beta_register_decoration({
				deco_type = "simple",
				place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
				sidelen = 16,
				noise_params = {
					offset = 0.0008,
					scale = 0.006,
					spread = {x = 100, y = 100, z = 100},
					seed = seed,
					octaves = 3,
					persist = 0.6
				},
				y_min = 1,
				y_max = mcl_vars.mg_overworld_max,
				biomes = biomes,
				decoration = "mcl_flowers:"..name,
			})
		end
		if is_in_flower_forest then
			beta_register_decoration({
				deco_type = "simple",
				place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
				sidelen = 80,
				noise_params= {
					offset = 0.0008*40,
					scale = 0.003,
					spread = {x = 100, y = 100, z = 100},
					seed = seed,
					octaves = 3,
					persist = 0.6,
				},
				y_min = 1,
				y_max = mcl_vars.mg_overworld_max,
				biomes = {"FlowerForest"},
				decoration = "mcl_flowers:"..name,
			})
		end
	end

	local register_flower = mcl_biomes.register_flower

	local flower_biomes1 = {"Plains", "SunflowerPlains", "RoofedForest", "Forest", "BirchForest", "BirchForestM", "Taiga", "ColdTaiga", "Savanna", "SavannaM", "ExtremeHills", "ExtremeHillsM", "ExtremeHills+", "ExtremeHills+_snowtop" }

	register_flower("dandelion", flower_biomes1, 8)
	local flower_biomes2 = {"Plains", "SunflowerPlains"}
	register_flower("tulip_red", flower_biomes2, 436)
	register_flower("tulip_orange", flower_biomes2, 536)
	register_flower("tulip_pink", flower_biomes2, 636)
	register_flower("tulip_white", flower_biomes2, 736)
	register_flower("azure_bluet", flower_biomes2, 800)
	register_flower("oxeye_daisy", flower_biomes2, 3490)

	register_flower("allium", nil, 0) -- flower Forest only

	register_flower("lily_of_the_valley", nil, 325)
	register_flower("cornflower", flower_biomes2, 486)
