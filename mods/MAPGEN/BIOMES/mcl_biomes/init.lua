local mg_seed = minetest.get_mapgen_setting("seed")

local mod_mcl_structures = minetest.get_modpath("mcl_structures")
local mod_mcl_core = minetest.get_modpath("mcl_core")
local mod_mcl_mushrooms = minetest.get_modpath("mcl_mushrooms")

local beach_skycolor = "#78A7FF" -- This is the case for all beach biomes except for the snowy ones! Those beaches will have their own colour instead of this one.
local ocean_skycolor = "#7BA4FF" -- This is the case for all ocean biomes except for non-deep frozen oceans! Those oceans will have their own colour instead of this one.
local overworld_fogcolor = "#C0D8FF"

--local nether_skycolor = "#6EB1FF"

--local end_fogcolor = "#A080A0"
--local end_skycolor = "#000000"

mcl_biomes = {}

local function content_id_if_known(name)
	if not minetest.registered_nodes[name] then
		return nil
	end
	return minetest.get_content_id(name)
end

local c_water = content_id_if_known("mcl_core:water_source")
local c_water_flowing = content_id_if_known("mcl_core:water_flowing")
local c_river_water = content_id_if_known("mclx_core:river_water_source")
local c_river_water_flowing = content_id_if_known("mclx_core:river_water_flowing")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_sand = minetest.get_content_id("mcl_core:sand")
local c_gravel = minetest.get_content_id("mcl_core:gravel")
local c_grass = minetest.get_content_id("mcl_core:dirt_with_grass")
local c_grass_snow = minetest.get_content_id("mcl_core:dirt_with_grass_snow")
local water_level = tonumber(minetest.get_mapgen_setting("water_level")) or 1

local function is_water_cid(cid)
	return cid == c_water
		or cid == c_water_flowing
		or cid == c_river_water
		or cid == c_river_water_flowing
end

--
-- Register biomes
--



local stonelike = {"mcl_core:stone"}
--[[ Special biome field: _mcl_biome_type:
Rough categorization of biomes: One of "snowy", "cold", "medium" and "hot"
Based off The OG Game gamepedia.com/Biomes ]]

-- Replace submerged shoreline grass/dirt with sand or gravel so water edges
-- never show grassy blocks in rivers/oceans.
local function shoreline_cleanup(vm, data, data2, emin, emax, area, minp, maxp, blockseed) --luacheck: ignore 212
	if maxp.y < (water_level - 8) or minp.y > water_level then
		return false
	end
	local dim_pos = { x = minp.x, y = math.floor((minp.y + maxp.y) / 2), z = minp.z }
	if mcl_worlds.pos_to_dimension(dim_pos) ~= "overworld" then
		return false
	end

	local x0 = minp.x + 1
	local x1 = maxp.x - 1
	local z0 = minp.z + 1
	local z1 = maxp.z - 1
	if x0 > x1 or z0 > z1 then
		return false
	end

	local y0 = math.max(minp.y, water_level - 8)
	local y1 = math.min(maxp.y, water_level)
	local changed = false

	for y = y0, y1 do
		for z = z0, z1 do
			local vi = area:index(x0, y, z)
			for x = x0, x1 do
				local cid = data[vi]
				if cid == c_grass or cid == c_grass_snow or cid == c_dirt then
					local up = vi + area.ystride
					if is_water_cid(data[up]) then
						local west = data[vi - 1]
						local east = data[vi + 1]
						local north = data[vi - area.zstride]
						local south = data[vi + area.zstride]
						if is_water_cid(west) or is_water_cid(east) or is_water_cid(north) or is_water_cid(south) then
							if cid == c_grass_snow or y <= (water_level - 2) then
								data[vi] = c_gravel
							else
								data[vi] = c_sand
							end
							changed = true
						end
					end
				end
				vi = vi + 1
			end
		end
	end

	return changed
end

-- One-time cleanup for already-generated terrain.
minetest.register_lbm({
	name = "mcl_biomes:shoreline_cleanup_existing",
	nodenames = {
		"mcl_core:dirt_with_grass",
		"mcl_core:dirt_with_grass_snow",
		"mcl_core:dirt",
	},
	run_at_every_load = false,
	action = function(pos, node)
		if pos.y < (water_level - 8) or pos.y > water_level then
			return
		end
		if mcl_worlds.pos_to_dimension(pos) ~= "overworld" then
			return
		end

		local is_water_name = function(name)
			return minetest.get_item_group(name, "water") > 0
		end
		local above = minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name
		if not is_water_name(above) then
			return
		end
		local west = minetest.get_node({ x = pos.x - 1, y = pos.y, z = pos.z }).name
		local east = minetest.get_node({ x = pos.x + 1, y = pos.y, z = pos.z }).name
		local north = minetest.get_node({ x = pos.x, y = pos.y, z = pos.z - 1 }).name
		local south = minetest.get_node({ x = pos.x, y = pos.y, z = pos.z + 1 }).name
		if not is_water_name(west)
			and not is_water_name(east)
			and not is_water_name(north)
			and not is_water_name(south) then
			return
		end

		if node.name == "mcl_core:dirt_with_grass_snow" or pos.y <= (water_level - 2) then
			minetest.set_node(pos, { name = "mcl_core:gravel" })
		else
			minetest.set_node(pos, { name = "mcl_core:sand" })
		end
	end,
})

local function register_classic_superflat_biome()
	-- Classic Superflat: bedrock (not part of biome), 2 dirt, 1 grass block
	minetest.register_biome({
		name = "flat",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_stone = "mcl_core:dirt",
		y_min = mcl_vars.mg_overworld_min - 512,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 50,
		heat_point = 50,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 0,
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = overworld_fogcolor
	})
end



-- Register biomes of non-Overworld biomes
local function register_dimension_biomes()
	--[[ REALMS ]]

	--[[ THE NETHER ]]
	-- the following decoration is a hack to cover exposed bedrock in netherrack - be careful not to put any ceiling decorations in a way that would apply to this (they would get generated regardless of biome)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:bedrock"},
		sidelen = 16,
		fill_ratio = 10,
		y_min = mcl_vars.mg_lava_nether_max,
		y_max = mcl_vars.mg_nether_max + 15,
		height = 6,
		max_height = 10,
		decoration = "mcl_nether:netherrack",
		flags = "all_ceilings",
		param2 = 0,
	})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:bedrock"},
		sidelen = 16,
		fill_ratio = 10,
		y_min = mcl_vars.mg_nether_min - 10,
		y_max = mcl_vars.mg_lava_nether_max,
		height = 7,
		max_height = 14,
		decoration = "mcl_nether:netherrack",
		flags = "all_floors,force_placement",
		param2 = 0,
	})


	minetest.register_biome({
		name = "Nether",
		node_filler = "mcl_nether:netherrack",
		node_stone = "mcl_nether:netherrack",
		node_top = "mcl_nether:netherrack",
		node_water = "air",
		node_river_water = "air",
		node_cave_liquid = "air",
		y_min = mcl_vars.mg_nether_min,

		y_max = mcl_vars.mg_nether_max + 80,
		heat_point = 100,
		humidity_point = 0,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 17,
--		_mcl_skycolor = nether_skycolor,
--		_mcl_fogcolor = "#330808"
	})

--[[	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:netherrack","mcl_nether:glowstone","mcl_blackstone:nether_gold","mcl_nether:quartz_ore","mcl_core:gravel","mcl_nether:soul_sand","mcl_nether:glowstone","mcl_nether:magma"},
		sidelen = 16,
		fill_ratio = 10,
		biomes = { "Nether" },
		y_min = mcl_vars.mg_lava_nether_max,
		y_max = mcl_vars.mg_nether_deco_max,
		decoration = "mcl_nether:netherrack",
		flags = "all_floors",
		param2 = 0,
	})]]--removed

end

-- Non-Overworld ores
local function register_dimension_ores()

	--[[ NETHER GENERATION ]]

	-- Soul sand
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_nether:soul_sand",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity  = 13 * 13 * 13,
		clust_size      = 5,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_worlds.layer_to_y(64, "nether"),
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 5, y = 5, z = 5},
			seed = 2316,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Glowstone
	minetest.register_ore({
		ore_type        = "blob",
		ore             = "mcl_nether:glowstone",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity  = 26 * 26 * 26,
		clust_size      = 5,
		y_min           = mcl_vars.mg_lava_nether_max + 10,
		y_max           = mcl_vars.mg_nether_max - 13,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Gravel (Nether)
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_core:gravel",
		wherein         = {"mcl_nether:netherrack"},
		column_height_min = 1,
		column_height_max = 1,
		column_midpoint_factor = 0,
		y_min           = mcl_worlds.layer_to_y(63, "nether"),
		-- This should be 65, but for some reason with this setting, the sheet ore really stops at 65. o_O
		y_max           = mcl_worlds.layer_to_y(65+2, "nether"),
		noise_threshold = 0.2,
		noise_params    = {
			offset = 0.0,
			scale = 0.5,
			spread = {x = 20, y = 20, z = 20},
			seed = 766,
			octaves = 3,
			persist = 0.6,
		},
	})

	-- Nether quartz
	if minetest.settings:get_bool("mcl_generate_ores", true) then
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_nether:quartz_ore",
			wherein         = {"mcl_nether:netherrack"},
			clust_scarcity = 850,
			clust_num_ores = 4, -- MC cluster amount: 4-10
			clust_size     = 3,
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_vars.mg_nether_max,
		})
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_nether:quartz_ore",
			wherein         = {"mcl_nether:netherrack"},
			clust_scarcity = 1650,
			clust_num_ores = 8, -- MC cluster amount: 4-10
			clust_size     = 4,
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_vars.mg_nether_max,
		})
	end

	-- Lava springs in the Nether
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity = 13500, --rare
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max,
		y_max           = mcl_vars.mg_nether_max - 13,
	})

	local lava_biomes = {"Nether"}
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 500,
		clust_num_ores = 1,
		clust_size     = 1,
		biomes         = lava_biomes,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_lava_nether_max + 1,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity = 1000,
		clust_num_ores = 1,
		clust_size     = 1,
		biomes         = lava_biomes,
		y_min           = mcl_vars.mg_lava_nether_max + 2,
		y_max           = mcl_vars.mg_lava_nether_max + 12,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity = 2000,
		clust_num_ores = 1,
		clust_size     = 1,
		biomes         = lava_biomes,
		y_min           = mcl_vars.mg_lava_nether_max + 13,
		y_max           = mcl_vars.mg_lava_nether_max + 48,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity = 3500,
		clust_num_ores = 1,
		clust_size     = 1,
		biomes         = lava_biomes,
		y_min           = mcl_vars.mg_lava_nether_max + 49,
		y_max           = mcl_vars.mg_nether_max - 13,
	})
end


-- Decorations in non-Overworld dimensions
local function register_dimension_decorations()
	--[[ NETHER ]]
	--NETHER WASTES (Nether)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:netherrack","mcl_nether:magma"},
		sidelen = 16,
		fill_ratio = 0.04,
		biomes = {"Nether"},
		y_min = mcl_vars.mg_lava_nether_max + 1,
		y_max = mcl_vars.mg_nether_max  - 1,
		flags = "all_floors",
		decoration = "mcl_fire:eternal_fire",
	})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:netherrack"},
		sidelen = 16,
		fill_ratio = 0.013,
		biomes = {"Nether"},
		y_min = mcl_vars.mg_lava_nether_max + 1,
		y_max = mcl_vars.mg_nether_max  - 1,
		flags = "all_floors",
		decoration = "mcl_mushrooms:mushroom_brown",
	})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:netherrack"},
		sidelen = 16,
		fill_ratio = 0.012,
		biomes = {"Nether"},
		y_min = mcl_vars.mg_lava_nether_max + 1,
		y_max = mcl_vars.mg_nether_max  - 1,
		flags = "all_floors",
		decoration = "mcl_mushrooms:mushroom_red",
	})

end
--
-- Detect mapgen to select functions
--
if not mcl_vars.superflat then
	dofile(minetest.get_modpath("mcl_biomes") .. "/overworld_generic_biomes_register.lua")

	--Register “fake” ores directly related to the biomes. These are mostly low-level landscape alternations
	-- Random dirt floor variation in Mega Taiga
	minetest.register_ore({
		ore_type	= "sheet",
		ore		= "mcl_core:dirt",
		wherein		= {"mcl_core:podzol", "mcl_core:dirt"},
		clust_scarcity	= 1,
		clust_num_ores	= 12,
		clust_size	= 10,
		y_min		= mcl_vars.mg_overworld_min,
		y_max		= mcl_vars.mg_overworld_max,
		noise_threshold = 0.2,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70},
		biomes = { "MegaTaiga" },
	})


	dofile(minetest.get_modpath("mcl_biomes") .. "/register_decorations.lua")
	mcl_mapgen_core.register_generator("mcl_biomes_shoreline_cleanup", shoreline_cleanup, nil, 7000, false)
else
	-- Implementation of The OG Game's Superflat mapgen, classic style:
	-- * Perfectly flat land, 1 grass biome, no decorations, no caves
	-- * 4 layers, from top to bottom: grass block, dirt, dirt, bedrock
	minetest.clear_registered_biomes()
	minetest.clear_registered_decorations()
	minetest.clear_registered_schematics()
	register_classic_superflat_biome()
end

-- Non-overworld stuff is registered independently
register_dimension_biomes()
register_dimension_ores()
register_dimension_decorations()
