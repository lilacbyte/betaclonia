local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures = {}

dofile(modpath.."/api.lua")

mcl_structures.register_structure("desert_well",{
	place_on = {"group:sand"},
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	sidelen = 4,
	chunk_probability = 15,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -2,
	biomes = { "Desert" },
	filenames = { modpath.."/schematics/mcl_structures_desert_well.mts" },
})


mcl_structures.register_structure("boulder",{
	filenames = {
		modpath.."/schematics/mcl_structures_boulder_small.mts"},
},true)

-- Re-enable natural boulder decorations for overworld life/detail.
local boulder_biomes = {
	"IcePlains",
	"ColdTaiga",
	"Taiga",
	"MegaTaiga",
	"MegaSpruceTaiga",
	"StoneBeach",
	"Plains",
	"SunflowerPlains",
	"Forest",
	"FlowerForest",
	"BirchForest",
	"BirchForestM",
	"RoofedForest",
	"Savanna",
	"SavannaM",
}

minetest.register_on_mods_loaded(function()
	minetest.register_decoration({
		name = "mcl_structures:boulder_small_worldgen",
		deco_type = "schematic",
		place_on = {
			"mcl_core:stone",
			"group:grass_block_no_snow",
			"mcl_core:dirt",
			"mcl_core:coarse_dirt",
			"mcl_core:podzol",
			"mcl_core:gravel",
			"mcl_core:sand",
		},
		sidelen = 16,
		fill_ratio = 0.00055,
		biomes = boulder_biomes,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = modpath.."/schematics/mcl_structures_boulder_small.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

end)

mcl_structures.register_structure("ice_spike_small",{
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_small.mts"	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct
mcl_structures.register_structure("ice_spike_large",{
	sidelen = 6,
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_large.mts"	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct

-- Debug command
local function dir_to_rotation(dir)
	local ax, az = math.abs(dir.x), math.abs(dir.z)
	if ax > az then
		if dir.x < 0 then
			return "270"
		end
		return "90"
	end
	if dir.z < 0 then
		return "180"
	end
	return "0"
end

minetest.register_chatcommand("spawnstruct", {
	params = "dungeon",
	description = S("Generate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		param = (param or ""):gsub("^%s+", ""):gsub("%s+$", "")
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		pos = vector.round(pos)
		local dir = minetest.yaw_to_dir(player:get_look_horizontal())
		local rot = dir_to_rotation(dir)
		local pr = PseudoRandom(pos.x+pos.y+pos.z)
		local errord = false
		local message = S("Structure placed.")
		if param == "dungeon" and mcl_dungeons and mcl_dungeons.spawn_dungeon then
			mcl_dungeons.spawn_dungeon(pos, rot, pr)
		elseif param == "" then
			message = S("Error: No structure type given. Please use “/spawnstruct <type>”.")
			errord = true
		else
			for n,d in pairs(mcl_structures.registered_structures) do
				if n == param then
					-- Emerge a safety margin first to avoid placement races at chunk edges.
					local radius = 96
					local minp = vector.offset(pos, -radius, -48, -radius)
					local maxp = vector.offset(pos, radius, 96, radius)
					minetest.emerge_area(minp, maxp, function(_, _, calls_remaining)
						if calls_remaining > 0 then
							return
						end
						local placed = mcl_structures.place_structure(pos, d, pr, math.random(), rot)
						if placed then
							minetest.chat_send_player(name, message)
						else
							minetest.chat_send_player(name, S("Structure placement failed at your position."))
						end
					end)
					return true, S("Preparing area for structure placement …")
				end
			end
			message = S("Error: Unknown structure type. Please use “/spawnstruct <type>”.")
			errord = true
		end
		minetest.chat_send_player(name, message)
		if errord then
			minetest.chat_send_player(name, S("Use /help spawnstruct to see a list of available types."))
		end
	end
})
minetest.register_on_mods_loaded(function()
	local p = ""
	for n,_ in pairs(mcl_structures.registered_structures) do
		p = p .. " | "..n
	end
	minetest.registered_chatcommands["spawnstruct"].params = minetest.registered_chatcommands["spawnstruct"].params .. p
end)
