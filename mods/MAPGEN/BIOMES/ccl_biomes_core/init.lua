OCEAN_MIN = -15
DEEP_OCEAN_MAX = OCEAN_MIN - 1
DEEP_OCEAN_MIN = -31


local mod_mcl_core = minetest.get_modpath("mcl_core")

ccl_overworld_biomes = {
	"IcePlains",
	"Plains",
	"Forest",
	"Desert",
	"StoneBeach",
	"SunflowerPlains",
}

	local function strip_plain_biomes(biomes)
		if type(biomes) ~= "table" then
			return {}
		end
		local out = {}
		for i = 1, #biomes do
			local b = biomes[i]
			if b ~= "Plains" and b ~= "SunflowerPlains" then
				out[#out + 1] = b
			end
		end
		return out
	end

	-- Spruce
	function mcl_quick_spruce(seed, offset, sprucename, biomes, y)
		if not y then
			y = 1
		end
		biomes = strip_plain_biomes(biomes)
		if #biomes == 0 then
			return
		end
		-- Beta tuning: keep spruce present but very rare.
		local rare_offset = (offset or 0) * 0.20 - 0.00025
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block", "mcl_core:dirt", "mcl_core:podzol"},
			sidelen = 32,
			noise_params = {
				offset = rare_offset,
				scale = 0.00018,
				spread = {x = 250, y = 250, z = 250},
				seed = seed,
				octaves = 3,
				persist = 0.66
			},
			biomes = biomes,
			y_min = y,
			y_max = mcl_vars.mg_overworld_max,
			schematic = mod_mcl_core.."/schematics/"..sprucename,
			flags = "place_center_x, place_center_z",
		})
	end
