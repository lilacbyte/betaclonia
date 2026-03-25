mcl_mapgen_core = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local bedrock_in_singlenode = false
local end_fixes_in_singlenode = true
--
-- Aliases for map generator outputs
--

minetest.register_alias("mapgen_air", "air")
minetest.register_alias("mapgen_stone", "mcl_core:stone")
minetest.register_alias("mapgen_dirt", "mcl_core:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "mcl_core:dirt_with_grass")
minetest.register_alias("mapgen_sand", "mcl_core:sand")
minetest.register_alias("mapgen_water_source", "mcl_core:water_source")
minetest.register_alias("mapgen_lava_source", "air") -- Built-in lava generator is too unpredictable, we generate lava on our own
minetest.register_alias("mapgen_cobble", "mcl_core:cobble")
minetest.register_alias("mapgen_river_water_source", "mcl_core:water_source")

dofile(modpath.."/api.lua")
dofile(modpath.."/ores.lua")

local mg_name = minetest.get_mapgen_setting("mg_name")
local enable_mt_dungeons = minetest.settings:get_bool("mcl_enable_mt_dungeons",false)

local function set_np(name, np)
	if minetest.set_mapgen_setting_noiseparams then
		minetest.set_mapgen_setting_noiseparams(name, np, true)
	end
end

-- Beta-like terrain profile for v7: no giant mountains, but keep ridges for cliffy hills.
if mg_name == "v7" then
	-- Keep big mountain walls disabled, but allow ridges for beta-like cliffs/hills.
	minetest.set_mapgen_setting("mgv7_spflags", "nomountains,nofloatlands,caverns", true)
	set_np("mgv7_np_terrain_base", {
		offset = 3,
		scale = 38,
		spread = {x = 480, y = 480, z = 480},
		seed = 82341,
		octaves = 5,
		persist = 0.62,
		lacunarity = 2.0,
		flags = "defaults",
	})
	set_np("mgv7_np_terrain_alt", {
		offset = 2,
		scale = 18,
		spread = {x = 420, y = 420, z = 420},
		seed = 5934,
		octaves = 5,
		persist = 0.63,
		lacunarity = 2.0,
		flags = "defaults",
	})
	set_np("mgv7_np_height_select", {
		offset = -2,
		scale = 15,
		spread = {x = 380, y = 380, z = 380},
		seed = 4213,
		octaves = 6,
		persist = 0.70,
		lacunarity = 2.0,
		flags = "defaults",
	})
elseif mg_name == "valleys" then
	minetest.set_mapgen_setting("mgvalleys_river_depth", "0", true)
	minetest.set_mapgen_setting("mgvalleys_river_size", "0", true)
elseif mg_name == "carpathian" then
	minetest.set_mapgen_setting("mgcarpathian_spflags", "caverns,norivers", true)
end

-- Content IDs
local c_bedrock = minetest.get_content_id("mcl_core:bedrock")
local c_void = minetest.get_content_id("mcl_core:void")
local c_lava = minetest.get_content_id("mcl_core:lava_source")
local c_nether_lava = c_lava
if minetest.get_modpath("mcl_nether") then
c_nether_lava = minetest.get_content_id("mcl_nether:nether_lava_source")
end
local c_water = minetest.get_content_id("mcl_core:water_source")
local c_air = minetest.CONTENT_AIR
local c_stone = minetest.get_content_id("mcl_core:stone")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_sand = minetest.get_content_id("mcl_core:sand")

local mg_flags = minetest.settings:get_flags("mg_flags")

if mcl_vars.superflat then
	-- Enforce superflat-like mapgen: no caves, decor, lakes and hills
	mg_flags.caves = false
	mg_flags.decorations = false
	minetest.set_mapgen_setting("mgflat_spflags", "nolakes,nohills", true)
end

mg_flags.dungeons = enable_mt_dungeons

for _,mg in pairs({"v7","valleys","carpathian","v5","fractal"}) do
	if mg_name == mg then
		minetest.set_mapgen_setting("mg"..mg.."_cavern_threshold", "0.20", true) --large nether caves
		minetest.set_mapgen_setting("mg"..mg.."_small_cave_num_min", "0", true) -- more large overworld caves
		minetest.set_mapgen_setting("mg"..mg.."_small_cave_num_max", "12", true)
		minetest.set_mapgen_setting("mg"..mg.."_large_cave_flooded", "0.1", true)
		minetest.set_mapgen_setting("mg"..mg.."_large_cave_num_min", "0", true)
		minetest.set_mapgen_setting("mg"..mg.."_large_cave_num_max", "9", true)
		mg_flags.caverns = true
	end
end

local mg_flags_str = ""
for k,v in pairs(mg_flags) do
	if v == false then
		k = "no" .. k
	end
	mg_flags_str = mg_flags_str .. k .. ","
end
if string.len(mg_flags_str) > 0 then
	mg_flags_str = string.sub(mg_flags_str, 1, string.len(mg_flags_str)-1)
end
minetest.set_mapgen_setting("mg_flags", mg_flags_str, true)

-- Helper function for converting a MC probability to MT, with
-- regards to MapBlocks.
-- Some MC generated structures are generated on per-chunk
-- probability.
-- The MC probability is 1/x per The OG Game chunk (16×16).

-- x: The MC probability is 1/x.
-- minp, maxp: MapBlock limits
-- returns: Probability (1/return_value) for a single MT mapblock
--local function theoggame_chunk_probability(x, minp, maxp)
	-- 256 is the MC chunk height
--	return x * (((maxp.x-minp.x+1)*(maxp.z-minp.z+1)) / 256)
--end

-- Takes x and z coordinates and minp and maxp of a generated chunk
-- (in on_generated callback) and returns a biomemap index)
-- Inverse function of biomemap_to_xz
--local function xz_to_biomemap_index(x, z, minp, maxp)
--	local xwidth = maxp.x - minp.x + 1
--	local zwidth = maxp.z - minp.z + 1
--	local minix = x % xwidth
--	local miniz = z % zwidth

--	return (minix + miniz * zwidth) + 1
--end


-- Generate basic layer-based nodes: void, bedrock, realm barrier, lava seas, etc.
-- Also perform some basic node replacements.

local bedrock_check
if mcl_vars.mg_bedrock_is_rough then
	function bedrock_check(_, y, _, _, pr)
		-- Bedrock layers with increasing levels of roughness, until a perfecly flat bedrock later at the bottom layer
		-- This code assumes a bedrock height of 5 layers.

		local diff = mcl_vars.mg_bedrock_overworld_max - y -- Overworld bedrock
		local ndiff1 = mcl_vars.mg_bedrock_nether_bottom_max - y -- Nether bedrock, bottom
		local ndiff2 = mcl_vars.mg_bedrock_nether_top_max - y -- Nether bedrock, ceiling

		local top
		if diff == 0 or ndiff1 == 0 or ndiff2 == 4 then
			-- 50% bedrock chance
			top = 2
		elseif diff == 1 or ndiff1 == 1 or ndiff2 == 3 then
			-- 66.666...%
			top = 3
		elseif diff == 2 or ndiff1 == 2 or ndiff2 == 2 then
			-- 75%
			top = 4
		elseif diff == 3 or ndiff1 == 3 or ndiff2 == 1 then
			-- 90%
			top = 10
		elseif diff == 4 or ndiff1 == 4 or ndiff2 == 0 then
			-- 100%
			return true
		else
			-- Not in bedrock layer
			return false
		end

		return pr:next(1, top) <= top-1
	end
end


-- Helper function to set all nodes in the layers between min and max.
-- content_id: Node to set
-- check: optional.
--	If content_id, node will be set only if it is equal to check.
--	If function(pos_to_check, content_id_at_this_pos), will set node only if returns true.
-- min, max: Minimum and maximum Y levels of the layers to set
-- minp, maxp: minp, maxp of the on_generated
-- lvm_used: Set to true if any node in this on_generated has been set before.
--
-- returns true if any node was set and lvm_used otherwise
local function set_layers(data, area, content_id, check, min, max, minp, maxp, lvm_used, pr)
	if (maxp.y >= min and minp.y <= max) then
		for z =minp.z, maxp.z do
		for y = math.max(min, minp.y), math.min(max, maxp.y) do
			local vi = area:index(minp.x, y, z)
			for x = minp.x, maxp.x do
				if check then
					if type(check) == "function" and check(x, y, z, data[vi], pr) then
						data[vi] = content_id
						lvm_used = true
					elseif check == data[vi] then
						data[vi] = content_id
						lvm_used = true
					end
				else
					data[vi] = content_id
					lvm_used = true
				end
				vi = vi + 1
			end
		end
		end
	end
	return lvm_used
end

-- Below the bedrock, generate air/void
local function world_structure(vm, data, data2, emin, emax, area, minp, maxp, blockseed) ---@diagnostic disable-line: unused-local
	local lvm_used = false
	local pr = PseudoRandom(blockseed)

	-- The Void below the Nether:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mapgen_edge_min                     , mcl_vars.mg_nether_min                     -1, minp, maxp, lvm_used, pr)

	-- [[ THE NETHER:					mcl_vars.mg_nether_min			       mcl_vars.mg_nether_max							]]

	-- The Air on the Nether roof, https://git.minetest.land/MineClone2/MineClone2/issues/1186
	lvm_used = set_layers(data, area, c_air		 , nil, mcl_vars.mg_nether_max			   +1, mcl_vars.mg_nether_max + 128                 , minp, maxp, lvm_used, pr)
	-- End removed: single void gap between Nether roof and Overworld floor.
	lvm_used = set_layers(data, area, c_void, nil, mcl_vars.mg_nether_max + 128 + 1, mcl_vars.mg_overworld_min - 1, minp, maxp, lvm_used, pr)

	-- Hard ceiling to mimic Beta build height.
	lvm_used = set_layers(data, area, c_void, nil, mcl_vars.mg_overworld_max + 1, mcl_vars.mapgen_edge_max, minp, maxp, lvm_used, pr)


	if (mg_name ~= "singlenode" or bedrock_in_singlenode) then
		-- Bedrock
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_overworld_min, mcl_vars.mg_bedrock_overworld_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_bottom_min, mcl_vars.mg_bedrock_nether_bottom_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_top_min, mcl_vars.mg_bedrock_nether_top_max, minp, maxp, lvm_used, pr)

		-- Flat Nether
		if mg_name == "flat" then
			lvm_used = set_layers(data, area, c_air, nil, mcl_vars.mg_flat_nether_floor, mcl_vars.mg_flat_nether_ceiling, minp, maxp, lvm_used, pr)
		end

		-- Big lava seas by replacing air below a certain height
		if mcl_vars.mg_lava then
			lvm_used = set_layers(data, area, c_lava, c_air, mcl_vars.mg_overworld_min, mcl_vars.mg_lava_overworld_max, minp, maxp, lvm_used, pr)
			lvm_used = set_layers(data, area, c_nether_lava, c_air, mcl_vars.mg_nether_min, mcl_vars.mg_lava_nether_max, minp, maxp, lvm_used, pr)
		end
	end
	local deco = false
	local ores = false
	if minp.y >  mcl_vars.mg_nether_deco_max - 64 and maxp.y <  mcl_vars.mg_nether_max + 128 then
		deco = {min=mcl_vars.mg_nether_deco_max,max=mcl_vars.mg_nether_max} ---@diagnostic disable-line: cast-local-type
	end
	if minp.y <  mcl_vars.mg_nether_min + 10 or maxp.y <  mcl_vars.mg_nether_min + 60 then
		deco = {min=mcl_vars.mg_nether_min - 10,max=mcl_vars.mg_nether_min + 20} ---@diagnostic disable-line: cast-local-type
		ores = {min=mcl_vars.mg_nether_min - 10,max=mcl_vars.mg_nether_min + 20} ---@diagnostic disable-line: cast-local-type
	end
	return lvm_used, lvm_used, deco, ores
end

local biome_id_p2 = {}
local biomecolor_nodes = {}

minetest.register_on_mods_loaded(function()
	for n, _ in pairs(minetest.registered_nodes) do
		if minetest.get_item_group(n, "biomecolor") > 0 then
			table.insert(biomecolor_nodes, n)
		end
	end
	for k, v in pairs(minetest.registered_biomes) do
		biome_id_p2[minetest.get_biome_id(k)] = v._mcl_palette_index or 255
	end
end)

local function set_param2_nodes(vm, data, data2, emin, emax, area, minp, maxp, blockseed) ---@diagnostic disable-line: unused-local
	if emin.y > mcl_vars.mg_overworld_max or emax.y < mcl_vars.mg_overworld_min then return end
	local biomemap = minetest.get_mapgen_object("biomemap")
	if not biomemap then return end
	local lvm_used = false
	local aream = VoxelArea:new({MinEdge={x=minp.x, y=0, z=minp.z}, MaxEdge={x=maxp.x, y=0, z=maxp.z}})
	local nodes = minetest.find_nodes_in_area(minp, maxp, biomecolor_nodes)
	for _, n in pairs(nodes) do
		local p_pos = area:index(n.x, n.y, n.z)
		local p2 = biome_id_p2[biomemap[aream:index(n.x, 0, n.z)]]
		if p2 then
			data2[p_pos] = math.floor(data2[p_pos] / 32) * 32 + p2
			lvm_used = true
		end
	end
	return lvm_used
end

mcl_mapgen_core.register_generator("world_structure", world_structure, nil, 1, false)
