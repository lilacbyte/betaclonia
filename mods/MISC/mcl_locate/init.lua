local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function get_locate_api()
	local api = rawget(_G, "mcl_beta_structures")
	if api and api.locate_structure and api.get_locatable_structures then
		return api
	end
	return nil
end

local function get_structure_list(api)
	local names = {}
	local raw = api.get_locatable_structures()
	for i = 1, #raw do
		names[#names + 1] = raw[i]
	end
	table.sort(names)
	return names
end

local function normalize_structure_name(name)
	local n = name:lower()
	local aliases = {
		["pyramid"] = "brick_pyramid",
		["pyamid"] = "brick_pyramid",
		["brick_pyramid"] = "brick_pyramid",
		["mcl_beta_structure"] = "brick_pyramid",
		["mcl_beta_structure"] = "brick_pyramid",
		["mcl_beta_pyramid"] = "brick_pyramid",
		["village"] = "empty_village",
		["empty_village"] = "empty_village",
		["mcl_beta_empty_village"] = "empty_village",
	}
	return aliases[n] or n
end

minetest.register_chatcommand("locate", {
	params = "<structure>",
	description = S("Locate the nearest supported structure."),
	privs = { interact = true },
	func = function(name, param)
		local api = get_locate_api()
		if not api then
			return false, S("Locate API unavailable. Is mcl_beta_structures loaded?")
		end

		param = trim(param)
		if param == "" then
			local names = get_structure_list(api)
			return false, S("Usage: /locate <structure>. Available: @1", table.concat(names, ", "))
		end

		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S("Player not found.")
		end

		local structure_name = normalize_structure_name(param)
		local pos = vector.round(player:get_pos())
		local result, err, extra = api.locate_structure(structure_name, pos, 256)
		if not result then
			if err == "unknown_structure" then
				local names = get_structure_list(api)
				return false, S("Unknown structure \"@1\". Available: @2", structure_name, table.concat(names, ", "))
			elseif err == "wrong_dimension" then
				return false, S("Structure \"@1\" is not in this dimension (needs @2).", structure_name, tostring(extra))
			elseif err == "not_found" then
				return false, S("No @1 found in search range.", structure_name)
			end
			return false, S("Could not locate structure: @1", tostring(err))
		end

		local msg = S(
			"Nearest @1: x=@2 y=@3 z=@4 (~@5 blocks)",
			result.name,
			tostring(result.x),
			tostring(result.y),
			tostring(result.z),
			tostring(result.distance)
		)
		return true, msg
	end,
})
