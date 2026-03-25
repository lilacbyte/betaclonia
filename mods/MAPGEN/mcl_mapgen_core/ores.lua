local mountains = {
	"ExtremeHills", "ExtremeHills_beach", "ExtremeHills_ocean", "ExtremeHills_deep_ocean", "ExtremeHills_underground",
	"ExtremeHills+", "ExtremeHills+_ocean", "ExtremeHills+_deep_ocean", "ExtremeHills+_underground",
	"ExtremeHillsM", "ExtremeHillsM_ocean", "ExtremeHillsM_deep_ocean", "ExtremeHillsM_underground",
}

local mesa = {
	"Mesa", "Mesa_sandlevel", "Mesa_ocean", "MesaBryce", "MesaBryce_sandlevel",
	"MesaBryce_ocean", "MesaPlateauF", "MesaPlateauF_sandlevel", "MesaPlateauF_ocean",
	"MesaPlateauFM", "MesaPlateauFM_sandlevel", "MesaPlateauFM_ocean",
}

--Clay
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:clay",
	wherein        = {"mcl_core:sand","mcl_core:stone","mcl_core:gravel"},
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = -5,
	y_max          = 0,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 34843,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

local stonelike = {"mcl_core:stone"}

-- Dirt
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:dirt",
	wherein        = stonelike,
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_vars.mg_overworld_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Gravel
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:gravel",
	wherein        = stonelike,
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_worlds.layer_to_y(111),
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})


if minetest.settings:get_bool("mcl_generate_ores", true) then
	local stonelike = { "mcl_core:stone" }

	local function register_ore_mg(ore, wherein, defs)
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = ore,
			wherein        = wherein,
			clust_scarcity = defs[1],
			clust_num_ores = defs[2],
			clust_size     = defs[3],
			y_min          = defs[4],
			y_max          = defs[5],
			biomes		   = defs[6],
		})
	end

	local ore_mapgen = {
		["stone"] = {
			["coal"] = {
				{ 525*3, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(50) },
				{ 510*3, 8, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(50) },
				{ 500*3, 12, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(50) },
				{ 550*3, 4, 2, mcl_worlds.layer_to_y(51), mcl_worlds.layer_to_y(80) },
				{ 525*3, 6, 3, mcl_worlds.layer_to_y(51), mcl_worlds.layer_to_y(80) },
				{ 500*3, 8, 3, mcl_worlds.layer_to_y(51), mcl_worlds.layer_to_y(80) },
				{ 600*3, 3, 2, mcl_worlds.layer_to_y(81), mcl_worlds.layer_to_y(128) },
				{ 550*3, 4, 3, mcl_worlds.layer_to_y(81), mcl_worlds.layer_to_y(128) },
				{ 500*3, 5, 3, mcl_worlds.layer_to_y(81), mcl_worlds.layer_to_y(128) },
			},
			["iron"] = {
				{ 830, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(39) },
				{ 1660, 4, 2, mcl_worlds.layer_to_y(40), mcl_worlds.layer_to_y(63) },
			},
			["gold"] = {
				{ 4775, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(30) },
				{ 6560, 7, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(30) },
				{ 13000, 4, 2, mcl_worlds.layer_to_y(31), mcl_worlds.layer_to_y(33) },
				{ 3333, 5, 3, mcl_worlds.layer_to_y(32), mcl_worlds.layer_to_y(79), mesa }
			},
			["diamond"] = {
				{ 10000, 4, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(12) },
				{ 5000, 2, 2, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(12) },
				{ 10000, 8, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(12) },
				{ 20000, 1, 1, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
				{ 20000, 2, 2, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
			},
			["redstone"] = {
				{ 500, 4, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(13) },
				{ 800, 7, 4, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(13) },
				{ 1000, 4, 3, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
				{ 1600, 7, 4, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
			},
			["lapis"] = {
				{ 7000, 7, 4, mcl_worlds.layer_to_y(14), mcl_worlds.layer_to_y(16) },
				{ 10000, 6, 3, mcl_worlds.layer_to_y(10), mcl_worlds.layer_to_y(13) },
				{ 12000, 5, 3, mcl_worlds.layer_to_y(6), mcl_worlds.layer_to_y(9) },
				{ 16000, 4, 3, mcl_worlds.layer_to_y(2), mcl_worlds.layer_to_y(5) },
				{ 18000, 3, 2, mcl_worlds.layer_to_y(0), mcl_worlds.layer_to_y(2) },
				{ 10000, 6, 3, mcl_worlds.layer_to_y(17), mcl_worlds.layer_to_y(20) },
				{ 12000, 5, 3, mcl_worlds.layer_to_y(21), mcl_worlds.layer_to_y(24) },
				{ 14000, 4, 3, mcl_worlds.layer_to_y(25), mcl_worlds.layer_to_y(28) },
				{ 18000, 3, 2, mcl_worlds.layer_to_y(29), mcl_worlds.layer_to_y(32) },
				{ 28000, 1, 1, mcl_worlds.layer_to_y(31), mcl_worlds.layer_to_y(32) },
			},
		}
	}

	for stone, ore in pairs(ore_mapgen) do
		local modname = ""
		local wherein

		for name, defs in pairs(ore) do
			if stone == "stone" then
				modname = "mcl_core"
				wherein = stonelike
				if name == "copper" then
					modname = "mcl_copper"
				end
			end
			for _, def in pairs(defs) do
				register_ore_mg(modname..":"..stone.."_with_"..name, wherein, def)
			end
		end
	end
end

if not mcl_vars.superflat then
-- Water and lava springs (single blocks of lava/water source)
-- Water appears at nearly every height, but not near the bottom
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:water_source",
	wherein         = {"mcl_core:stone", "mcl_core:dirt"},
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(5),
	y_max          = mcl_worlds.layer_to_y(128),
})

-- Lava springs are rather common at -31 and below
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(1),
	y_max          = mcl_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(11),
	y_max          = mcl_worlds.layer_to_y(31),
})

-- Lava springs will become gradually rarer with increasing height
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 32000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(32),
	y_max          = mcl_worlds.layer_to_y(47),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 72000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(48),
	y_max          = mcl_worlds.layer_to_y(61),
})

-- Lava may even appear above surface, but this is very rare
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 96000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(62),
	y_max          = mcl_worlds.layer_to_y(127),
})
end
