--lua locals
local mob_class = mcl_mobs.mob_class

local modern_lighting = minetest.settings:get_bool("mcl_mobs_modern_lighting", true)
local peaceful_mode = minetest.settings:get_bool("only_peaceful_mobs", false)

local nether_threshold = 11
local end_threshold = 15
local overworld_threshold = 0
local overworld_sky_threshold = 7
local overworld_passive_threshold = 7

local PASSIVE_INTERVAL = tonumber(minetest.settings:get("betaclonia_passive_spawn_interval")) or 2
if PASSIVE_INTERVAL <= 0 then
	PASSIVE_INTERVAL = 2
end
local HOSTILE_INTERVAL = tonumber(minetest.settings:get("betaclonia_hostile_spawn_interval")) or 2
if HOSTILE_INTERVAL <= 0 then
	HOSTILE_INTERVAL = 2
end
local SPAWN_WEIGHT_MULT = tonumber(minetest.settings:get("betaclonia_spawn_weight")) or 8
local PASSIVE_CHANCE_MULT = tonumber(minetest.settings:get("betaclonia_passive_spawn_weight")) or 4
local MOB_CAP_MULT = tonumber(minetest.settings:get("betaclonia_mob_cap_multiplier")) or 3
local ANIMAL_LOCAL_CAP = tonumber(minetest.settings:get("betaclonia_animal_local_cap")) or 16
local SURFACE_SEARCH_TRIES = 16
local GROUP_SEARCH_TRIES = 8
local MOB_SPAWN_ZONE_INNER = 24
local MOB_SPAWN_ZONE_OUTER = 128
local SPAWN_MAPGEN_LIMIT = 30911
local OVERWORLD_CEILING_MARGIN = 64
local OVERWORLD_DEFAULT_CEILING = 256

local dbg_spawn_attempts = 0
local dbg_spawn_succ = 0
local dbg_spawn_counts = {}

local aoc_range = 136
local remove_far = true

local timer_light = 30
local timer_dark = 10
local timer_light_level = 3
local instant_despawn_range = 128
local random_despawn_range = 32

local mob_cap = {
	monster = (tonumber(minetest.settings:get("mcl_mob_cap_monster")) or 70) * MOB_CAP_MULT,
	animal = (tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 15) * MOB_CAP_MULT,
	ambient = (tonumber(minetest.settings:get("mcl_mob_cap_ambient")) or 15) * MOB_CAP_MULT,
	water = (tonumber(minetest.settings:get("mcl_mob_cap_water")) or 5) * MOB_CAP_MULT,
	water_ambient = (tonumber(minetest.settings:get("mcl_mob_cap_water_ambient")) or 20) * MOB_CAP_MULT,
	player = (tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75) * MOB_CAP_MULT,
	total = (tonumber(minetest.settings:get("mcl_mob_cap_total")) or 500) * MOB_CAP_MULT,
}

local BUCKET_ATTEMPTS = {
	hostile = 8,
	ambient = 3,
	water = 4,
	lava = 2,
	passive = 8,
}

local BUCKET_CAPS = {
	hostile = mob_cap.monster,
	ambient = mob_cap.ambient,
	water = mob_cap.water,
	lava = mob_cap.monster,
	passive = math.max(mob_cap.animal, 30),
}

--do mobs spawn?
local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false
local spawn_protected = minetest.settings:get_bool("mobs_spawn_protected") ~= false
local logging = minetest.settings:get_bool("mcl_logging_mobs_spawn", false)
local mgname = minetest.get_mapgen_setting("mgname")

local S = minetest.get_translator("mcl_mobs")

local function count_mobs(pos, r, mob_type)
	local num = 0
	for _, entity in pairs(minetest.luaentities) do
		if entity and entity.is_mob and (mob_type == nil or entity.type == mob_type) then
			local p = entity.object:get_pos()
			if p and vector.distance(p, pos) < r then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_total(mob_type)
	local num = 0
	for _, entity in pairs(minetest.luaentities) do
		if entity.is_mob and (mob_type == nil or entity.type == mob_type) then
			num = num + 1
		end
	end
	return num
end

local function count_mobs_all()
	local mobs_found = {}
	local num = 0
	for _, entity in pairs(minetest.luaentities) do
		if entity.is_mob then
			mobs_found[entity.name] = (mobs_found[entity.name] or 0) + 1
			num = num + 1
		end
	end
	return mobs_found, num
end

local function count_mobs_total_cap(mob_type)
	local num = 0
	for _, entity in pairs(minetest.luaentities) do
		if entity.is_mob
			and (mob_type == nil or entity.type == mob_type)
			and entity.can_despawn
			and not entity.nametag then
			num = num + 1
		end
	end
	return num
end

local function count_mobs_total_cap_by_name(name_lookup)
	local num = 0
	for _, entity in pairs(minetest.luaentities) do
		if entity.is_mob
			and name_lookup[entity.name]
			and entity.can_despawn
			and not entity.nametag then
			num = num + 1
		end
	end
	return num
end

local spawn_dictionary = {}

local spawn_defaults = {
	dimension = "overworld",
	type_of_spawning = "ground",
	min_light = 7,
	max_light = minetest.LIGHT_MAX + 1,
	chance = 1000,
	aoc = aoc_range,
	min_height = -31000,
	max_height = 31000,
}

local spawn_defaults_meta = { __index = spawn_defaults }

function mcl_mobs.spawn_setup(def)
	if not mobs_spawn then
		return
	end

	assert(def, "Empty spawn setup definition from mod: " .. tostring(minetest.get_current_modname()))
	assert(def.name, "Missing mob name from mod: " .. tostring(minetest.get_current_modname()))

	local mob_def = minetest.registered_entities[def.name]
	assert(mob_def, "spawn definition with invalid entity: " .. tostring(def.name))
	if peaceful_mode and not mob_def.persist_in_peaceful then
		return
	end
	assert(def.chance > 0, "Chance shouldn't be less than 1 (mob name: " .. def.name .. ")")

	setmetatable(def, spawn_defaults_meta)
	def.min_light = def.min_light or mob_def.min_light or (mob_def.spawn_class == "hostile" and 0)
	def.max_light = def.max_light or mob_def.max_light or (mob_def.spawn_class == "hostile" and 7)
	def.min_height = def.min_height or mcl_vars["mg_" .. def.dimension .. "_min"]
	def.max_height = def.max_height or mcl_vars["mg_" .. def.dimension .. "_max"]
	def.chance = math.max(1, math.floor(def.chance / SPAWN_WEIGHT_MULT))
	if mob_def.spawn_class == "passive" and PASSIVE_CHANCE_MULT > 1 then
		def.chance = math.max(1, math.floor(def.chance / PASSIVE_CHANCE_MULT))
	end

	if type(def.biomes) == "table" then
		local filtered = {}
		for i = 1, #def.biomes do
			local biome_name = def.biomes[i]
			local biome_id = minetest.get_biome_id(biome_name)
			if biome_id and biome_id ~= 0 and biome_id ~= -1 then
				filtered[#filtered + 1] = biome_name
			end
		end
		if #filtered == 0 then
			return
		end
		def.biomes = filtered
	end

	spawn_dictionary[#spawn_dictionary + 1] = def
end

function mcl_mobs.get_mob_light_level(mob, dim)
	for _, def in pairs(spawn_dictionary) do
		if def.name == mob and def.dimension == dim then
			return def.min_light, def.max_light
		end
	end
	local def = minetest.registered_entities[mob]
	return def.min_light, def.max_light
end

local function biome_check(biome_list, biome_goal)
	if mgname == "singlenode" then
		return true
	end
	return table.indexof(biome_list, biome_goal) ~= -1
end

local function is_farm_animal(name)
	return name == "mobs_mc:pig"
		or name == "mobs_mc:cow"
		or name == "mobs_mc:sheep"
		or name == "mobs_mc:chicken"
		or name == "mobs_mc:horse"
		or name == "mobs_mc:donkey"
end

local function is_passive_ground_spawn_def(spawn_def, entity_def)
	entity_def = entity_def or minetest.registered_entities[spawn_def.name]
	return entity_def
		and entity_def.spawn_class == "passive"
		and entity_def.type == "animal"
		and spawn_def.type_of_spawning == "ground"
end

local function math_round(x)
	return (x > 0) and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

local function clamp(value, min_value, max_value)
	return math.max(min_value, math.min(max_value, value))
end

local function random_signed_offset(radius)
	return math.random(-radius, radius)
end

local function dist_sqr(a, b)
	local dx = b.x - a.x
	local dy = b.y - a.y
	local dz = b.z - a.z
	return dx * dx + dy * dy + dz * dz
end

local function get_spawn_weight(def)
	local chance = tonumber(def.chance) or 1
	if chance < 1 then
		chance = 1
	end
	return 1 / chance
end

local function get_spawn_bucket(spawn_def, entity_def)
	if not entity_def then
		return
	end
	if spawn_def.type_of_spawning == "water" then
		return "water"
	elseif spawn_def.type_of_spawning == "lava" then
		return "lava"
	elseif entity_def.spawn_class == "passive" and entity_def.type == "animal" then
		return "passive"
	elseif entity_def.type == "monster" then
		return "hostile"
	else
		return "ambient"
	end
end

local function new_bucket_table()
	return {
		hostile = {},
		ambient = {},
		water = {},
		lava = {},
		passive = {},
	}
end

local function get_water_spawn(pos)
	local nodes = minetest.find_nodes_in_area(
		vector.offset(pos, -2, -1, -2),
		vector.offset(pos, 2, -15, 2),
		{"group:water"}
	)
	if nodes and #nodes > 0 then
		return nodes[math.random(#nodes)]
	end
end

local function get_lava_spawn(pos)
	local nodes = minetest.find_nodes_in_area(
		vector.offset(pos, -2, -1, -2),
		vector.offset(pos, 2, -15, 2),
		{"group:lava"}
	)
	if nodes and #nodes > 0 then
		return nodes[math.random(#nodes)]
	end
end

local function has_room(self, pos)
	local cb = self.initial_properties.collisionbox
	local nodes = { "air" }
	if self.fly_in then
		if type(self.fly_in) == "table" then
			for _, node in ipairs(self.fly_in) do
				nodes[#nodes + 1] = node
			end
		elseif type(self.fly_in) == "string" then
			nodes[#nodes + 1] = self.fly_in
		end
	end
	if self.swims_in then
		if type(self.swims_in) == "table" then
			for _, node in ipairs(self.swims_in) do
				nodes[#nodes + 1] = node
			end
		elseif type(self.swims_in) == "string" then
			nodes[#nodes + 1] = self.swims_in
		end
	end
	local x = cb[4] - cb[1]
	local y = cb[5] - cb[2]
	local z = cb[6] - cb[3]
	local r = math.ceil(x * y * z)
	local p1 = vector.offset(pos, cb[1], cb[2], cb[3])
	local p2 = vector.offset(pos, cb[4], cb[5], cb[6])
	local n = #(minetest.find_nodes_in_area(p1, p2, nodes) or {})
	if r > n then
		return false
	end
	return true
end

local function spawn_check(pos, spawn_def, ignore_caps)
	if not spawn_def or not pos then
		return
	end

	dbg_spawn_attempts = dbg_spawn_attempts + 1

	local check_pos = vector.new(pos.x, pos.y, pos.z)
	local dimension = mcl_worlds.pos_to_dimension(check_pos)
	local mob_def = minetest.registered_entities[spawn_def.name]
	local mob_type = mob_def.type
	local gotten_node = minetest.get_node_or_nil(check_pos)
	if not gotten_node then
		return false, "no node"
	end
	gotten_node = gotten_node.name

	local is_ground = minetest.get_item_group(gotten_node, "opaque") ~= 0
	if not is_ground then
		check_pos.y = check_pos.y - 1
		gotten_node = minetest.get_node(check_pos).name
		is_ground = minetest.get_item_group(gotten_node, "opaque") ~= 0
	end
	check_pos.y = check_pos.y + 1

	local is_water = minetest.get_item_group(gotten_node, "water") ~= 0
	local is_lava = minetest.get_item_group(gotten_node, "lava") ~= 0
	local is_leaf = minetest.get_item_group(gotten_node, "leaves") ~= 0
	local is_bedrock = gotten_node == "mcl_core:bedrock"
	local is_grass = minetest.get_item_group(gotten_node, "grass_block") ~= 0

	if check_pos.y < spawn_def.min_height then
		return false, "too low"
	end
	if check_pos.y > spawn_def.max_height then
		return false, "too high"
	end
	if spawn_def.dimension ~= dimension then
		return false, "wrong dimension"
	end
	if spawn_def.type_of_spawning == "ground" and not is_ground then
		return false, "not on ground"
	end
	if spawn_def.type_of_spawning == "ground" and is_leaf then
		return false, "leaf"
	end
	if not has_room(mob_def, check_pos) then
		return false, "no room"
	end
	if spawn_def.check_position and not spawn_def.check_position(check_pos) then
		return false, "check_position failed"
	end
	if is_farm_animal(spawn_def.name) and not is_grass then
		return false, "farm animals only on grass"
	end
	if spawn_def.type_of_spawning == "water" and not is_water then
		return false, "water mob only on water"
	end
	if spawn_def.type_of_spawning == "lava" and not is_lava then
		return false, "lava mob only on lava"
	end
	if spawn_protected and minetest.is_protected(check_pos, "") then
		return false, "spawn protected"
	end
	if is_bedrock then
		return false, "no spawn on bedrock"
	end

	local biome = minetest.get_biome_data(check_pos)
	if not biome then
		return false, "no biome found"
	end
	biome = minetest.get_biome_name(biome.biome)
	if spawn_def.biomes_except and biome_check(spawn_def.biomes_except, biome) then
		return false, "biomes_except failed"
	end
	if spawn_def.biomes and not biome_check(spawn_def.biomes, biome) then
		return false, "biome check failed"
	end

	local gotten_light = minetest.get_node_light(check_pos)
	local my_node = minetest.get_node(check_pos)
	local sky_light = minetest.get_natural_light(check_pos)
	local art_light = minetest.get_artificial_light(my_node.param1)

	if modern_lighting then
		if mob_def.check_light then
			return mob_def.check_light(check_pos, gotten_light, art_light, sky_light)
		elseif mob_type == "monster" then
			if dimension == "nether" then
				if art_light > nether_threshold then
					return false, "too bright"
				end
			elseif dimension == "end" then
				if art_light > end_threshold then
					return false, "too bright"
				end
			elseif dimension == "overworld" then
				if art_light > overworld_threshold or sky_light > overworld_sky_threshold then
					return false, "too bright"
				end
			end
		else
			if gotten_light <= overworld_passive_threshold then
				return false, "too dark"
			end
		end
	else
		if gotten_light < spawn_def.min_light then
			return false, "too dark"
		end
		if gotten_light > spawn_def.max_light then
			return false, "too bright"
		end
	end

	if not ignore_caps then
		local mob_count = count_mobs(check_pos, 32, mob_type)
		local mob_count_wide = count_mobs(check_pos, aoc_range, mob_type)
		if mob_count_wide >= (mob_cap[mob_type] or 15) then
			return false, "mob cap wide full"
		end
		local local_cap = (mob_type == "animal") and ANIMAL_LOCAL_CAP or 5
		if mob_count >= local_cap then
			return false, "local mob cap full"
		end
	end

	return true, ""
end

function mcl_mobs.spawn(pos, id, staticdata)
	local def = minetest.registered_entities[id]
		or minetest.registered_entities["mobs_mc:" .. id]
		or minetest.registered_entities["extra_mobs:" .. id]
	if not def or (def.can_spawn and not def.can_spawn(pos)) or not def.is_mob then
		return false
	end
	dbg_spawn_counts[def.name] = (dbg_spawn_counts[def.name] or 0) + 1
	return minetest.add_entity(pos, def.name, staticdata)
end

local function get_support_nodes_for_spawn_def(spawn_def)
	if spawn_def.type_of_spawning == "ground" then
		if is_farm_animal(spawn_def.name) then
			return {"group:grass_block"}
		end
		return {"group:opaque"}
	elseif spawn_def.type_of_spawning == "water" then
		return {"group:water"}
	elseif spawn_def.type_of_spawning == "lava" then
		return {"group:lava"}
	end
end

local function level_y_range(level, pos)
	if level == "overworld" then
		local nodepos = math.floor(pos.y + 0.5)
		if nodepos < OVERWORLD_DEFAULT_CEILING - OVERWORLD_CEILING_MARGIN then
			return mcl_vars.mg_overworld_min, OVERWORLD_DEFAULT_CEILING
		end
		return nodepos
			- OVERWORLD_DEFAULT_CEILING
			+ OVERWORLD_CEILING_MARGIN
			+ mcl_vars.mg_overworld_min,
			nodepos + OVERWORLD_CEILING_MARGIN
	elseif level == "nether" then
		return mcl_vars.mg_nether_min, mcl_vars.mg_nether_max - 1
	elseif level == "end" then
		return mcl_vars.mg_end_min, (mcl_vars.mg_end_max_official or mcl_vars.mg_end_max) - 1
	end
end

local function get_vertical_search_range(player_pos, spawn_def)
	local y_min, y_max = level_y_range(spawn_def.dimension, player_pos)
	if not y_min or not y_max then
		return
	end
	y_min = clamp(math.floor(y_min), spawn_def.min_height, spawn_def.max_height)
	y_max = clamp(math.floor(y_max), spawn_def.min_height, spawn_def.max_height)
	if y_min > y_max then
		return
	end
	return y_min, y_max
end

local function get_spawn_target_xz(player_pos)
	local distance = math.random()^2 * (MOB_SPAWN_ZONE_OUTER - MOB_SPAWN_ZONE_INNER) + MOB_SPAWN_ZONE_INNER
	local dir = vector.random_direction()
	local x = math_round(player_pos.x + dir.x * distance)
	local z = math_round(player_pos.z + dir.z * distance)
	if math.abs(x) > SPAWN_MAPGEN_LIMIT or math.abs(z) > SPAWN_MAPGEN_LIMIT then
		return
	end
	return x, z
end

local function find_surface_spawn_pos(x, z, y_min, y_max, support_nodes)
	local supports = minetest.find_nodes_in_area_under_air(
		{x = x, y = y_min, z = z},
		{x = x, y = y_max, z = z},
		support_nodes
	) or {}
	local support_pos
	for _, pos in ipairs(supports) do
		if not support_pos or pos.y > support_pos.y then
			support_pos = pos
		end
	end
	if support_pos then
		return vector.offset(support_pos, 0, 1, 0)
	end
end

local function get_next_mob_spawn_pos(player_pos, spawn_def)
	local distance = math.random()^2 * (MOB_SPAWN_ZONE_OUTER - MOB_SPAWN_ZONE_INNER) + MOB_SPAWN_ZONE_INNER
	local dir = vector.random_direction()
	local goal_pos = vector.offset(player_pos, dir.x * distance, dir.y * distance, dir.z * distance)

	if not (math.abs(goal_pos.x) <= SPAWN_MAPGEN_LIMIT
		and math.abs(goal_pos.y) <= SPAWN_MAPGEN_LIMIT
		and math.abs(goal_pos.z) <= SPAWN_MAPGEN_LIMIT) then
		return
	end

	local r_outer = distance + 3
	local horizontal_dist = vector.distance(player_pos, vector.new(goal_pos.x, player_pos.y, goal_pos.z))
	local y_outer = math.sqrt(r_outer * r_outer - horizontal_dist * horizontal_dist)

	local y_min
	local y_max
	if horizontal_dist >= MOB_SPAWN_ZONE_INNER then
		y_min = player_pos.y - y_outer
		y_max = player_pos.y + y_outer
	else
		local r_inner = MOB_SPAWN_ZONE_INNER
		local y_inner = math.sqrt(r_inner * r_inner - horizontal_dist * horizontal_dist)
		if goal_pos.y > player_pos.y then
			y_min = player_pos.y + y_inner
			y_max = player_pos.y + y_outer
		else
			y_min = player_pos.y - y_outer
			y_max = player_pos.y - y_inner
		end
	end

	y_min = math_round(y_min)
	y_max = math_round(y_max)

	local spawn_nodes = {"group:opaque", "group:water", "group:lava"}
	if spawn_def.type_of_spawning == "ground" then
		spawn_nodes = {"group:opaque"}
	elseif spawn_def.type_of_spawning == "water" then
		spawn_nodes = {"group:water"}
	elseif spawn_def.type_of_spawning == "lava" then
		spawn_nodes = {"group:lava"}
	end

	local positions = minetest.find_nodes_in_area_under_air(
		{x = goal_pos.x, y = y_min, z = goal_pos.z},
		{x = goal_pos.x, y = y_max, z = goal_pos.z},
		spawn_nodes
	) or {}
	if #positions == 0 then
		return
	end

	local valid_positions = {}
	for _, check_pos in ipairs(positions) do
		local dist = vector.distance(player_pos, check_pos)
		if dist >= MOB_SPAWN_ZONE_INNER and dist <= MOB_SPAWN_ZONE_OUTER then
			valid_positions[#valid_positions + 1] = check_pos
		end
	end
	if #valid_positions == 0 then
		return
	end

	if spawn_def.type_of_spawning == "ground" and is_passive_ground_spawn_def(spawn_def) then
		local best = valid_positions[1]
		for i = 2, #valid_positions do
			if valid_positions[i].y > best.y then
				best = valid_positions[i]
			end
		end
		return best
	end

	return valid_positions[math.random(#valid_positions)]
end

local function find_passive_ground_spawn_pos(player_pos, spawn_def)
	local support_nodes = get_support_nodes_for_spawn_def(spawn_def)
	local y_min, y_max = get_vertical_search_range(player_pos, spawn_def)
	if not y_min or not y_max then
		return
	end

	for _ = 1, SURFACE_SEARCH_TRIES do
		local x, z = get_spawn_target_xz(player_pos)
		if x and z then
			local spawn_pos = find_surface_spawn_pos(x, z, y_min, y_max, support_nodes)
			if spawn_pos then
				local horizontal = vector.distance(
					{x = player_pos.x, y = spawn_pos.y, z = player_pos.z},
					{x = spawn_pos.x, y = spawn_pos.y, z = spawn_pos.z}
				)
				if horizontal >= MOB_SPAWN_ZONE_INNER and horizontal <= MOB_SPAWN_ZONE_OUTER then
					return spawn_pos
				end
			end
		end
	end
end

local function resolve_spawn_position(spawn_def, spawn_pos)
	if not spawn_pos then
		return
	end
	if spawn_def.type_of_spawning == "water" then
		spawn_pos = get_water_spawn(spawn_pos)
	elseif spawn_def.type_of_spawning == "lava" then
		spawn_pos = get_lava_spawn(spawn_pos)
	end
	if not spawn_pos then
		return
	end
	local entity_def = minetest.registered_entities[spawn_def.name]
	if entity_def and entity_def.can_spawn and not entity_def.can_spawn(spawn_pos) then
		return
	end
	return spawn_pos
end

local function find_group_member_spawn_pos(base_pos, spawn_def)
	if spawn_def.type_of_spawning == "ground" and is_passive_ground_spawn_def(spawn_def) then
		local support_nodes = get_support_nodes_for_spawn_def(spawn_def)
		local y_min = math.floor(base_pos.y) - 8
		local y_max = math.floor(base_pos.y) + 8
		for _ = 1, GROUP_SEARCH_TRIES do
			local x = math_round(base_pos.x) + random_signed_offset(5)
			local z = math_round(base_pos.z) + random_signed_offset(5)
			local spawn_pos = find_surface_spawn_pos(x, z, y_min, y_max, support_nodes)
			if spawn_pos then
				return spawn_pos
			end
		end
	elseif spawn_def.type_of_spawning == "water" then
		for _ = 1, GROUP_SEARCH_TRIES do
			local spawn_pos = get_water_spawn(vector.offset(base_pos, random_signed_offset(4), 0, random_signed_offset(4)))
			if spawn_pos then
				return spawn_pos
			end
		end
	elseif spawn_def.type_of_spawning == "lava" then
		for _ = 1, GROUP_SEARCH_TRIES do
			local spawn_pos = get_lava_spawn(vector.offset(base_pos, random_signed_offset(4), 0, random_signed_offset(4)))
			if spawn_pos then
				return spawn_pos
			end
		end
	else
		return vector.offset(base_pos, random_signed_offset(5), random_signed_offset(2), random_signed_offset(5))
	end
end

local function find_spawn_pos_for_def(player_pos, spawn_def)
	if spawn_def.type_of_spawning == "ground" and is_passive_ground_spawn_def(spawn_def) then
		return find_passive_ground_spawn_pos(player_pos, spawn_def)
	end
	return get_next_mob_spawn_pos(player_pos, spawn_def)
end

local function try_spawn_def_at(spawn_pos, spawn_def, ignore_caps)
	if not spawn_pos then
		return false
	end
	local check_pos = vector.new(spawn_pos.x, spawn_pos.y, spawn_pos.z)
	if not spawn_check(check_pos, spawn_def, ignore_caps) then
		return false
	end
	spawn_pos = resolve_spawn_position(spawn_def, spawn_pos)
	if not spawn_pos then
		return false
	end
	local object = mcl_mobs.spawn(spawn_pos, spawn_def.name)
	if object then
		dbg_spawn_succ = dbg_spawn_succ + 1
		return true
	end
	return false
end

local function spawn_def_pack(player_pos, spawn_def)
	local entity_def = minetest.registered_entities[spawn_def.name]
	if not entity_def then
		return 0
	end

	local base_pos = find_spawn_pos_for_def(player_pos, spawn_def)
	if not base_pos then
		return 0
	end

	local spawn_in_group = entity_def.spawn_in_group or 1
	local spawn_in_group_min = entity_def.spawn_in_group_min or 1
	local group_size = math.random(spawn_in_group_min, spawn_in_group)
	local spawned = 0

	if try_spawn_def_at(base_pos, spawn_def, false) then
		spawned = 1
	end

	for _ = 2, group_size do
		local spawn_pos = find_group_member_spawn_pos(base_pos, spawn_def)
		if try_spawn_def_at(spawn_pos, spawn_def, true) then
			spawned = spawned + 1
		end
	end

	if logging and spawned > 0 then
		if spawned == 1 then
			minetest.log("action", "[mcl_mobs] Spawned " .. spawn_def.name .. " at " .. minetest.pos_to_string(base_pos, 1))
		else
			minetest.log("action", "[mcl_mobs] Spawned pack of " .. spawned .. " " .. spawn_def.name .. " near " .. minetest.pos_to_string(base_pos, 1))
		end
	end

	return spawned
end

local function spawn_group(pos, spawn_def, spawn_on, group_max, group_min)
	group_min = group_min or 1
	local found = minetest.find_nodes_in_area_under_air(
		vector.offset(pos, -5, -3, -5),
		vector.offset(pos, 5, 3, 5),
		spawn_on
	)
	if not found or #found == 0 then
		found = { vector.offset(pos, 0, -1, 0) }
	end
	table.shuffle(found)

	local last_spawn
	for _ = 1, math.random(group_min, group_max) do
		local support_pos = found[math.random(#found)]
		local spawn_pos = vector.offset(support_pos, 0, 1, 0)
		if try_spawn_def_at(spawn_pos, spawn_def, true) then
			last_spawn = spawn_pos
		end
	end
	return last_spawn
end

mcl_mobs.spawn_group = spawn_group

function mob_class:despawn_allowed()
	local nametag = self.nametag and self.nametag ~= ""
	local not_busy = self.state ~= "attack" and self.following == nil
	if self.can_despawn == true then
		if not nametag and not_busy and not self.tamed and not self.persistent then
			return true
		end
	end
	return false
end

if mobs_spawn then
	local spawn_buckets
	local bucket_weights
	local bucket_name_lookups

	local function initialize_spawn_data()
		if spawn_buckets and bucket_weights and bucket_name_lookups then
			return
		end

		spawn_buckets = {
			overworld = new_bucket_table(),
			nether = new_bucket_table(),
			["end"] = new_bucket_table(),
		}
		bucket_weights = {
			overworld = { hostile = 0, ambient = 0, water = 0, lava = 0, passive = 0 },
			nether = { hostile = 0, ambient = 0, water = 0, lava = 0, passive = 0 },
			["end"] = { hostile = 0, ambient = 0, water = 0, lava = 0, passive = 0 },
		}
		bucket_name_lookups = {
			overworld = new_bucket_table(),
			nether = new_bucket_table(),
			["end"] = new_bucket_table(),
		}

		for _, spawn_def in ipairs(spawn_dictionary) do
			local entity_def = minetest.registered_entities[spawn_def.name]
			local bucket = get_spawn_bucket(spawn_def, entity_def)
			if bucket and spawn_buckets[spawn_def.dimension] then
				spawn_buckets[spawn_def.dimension][bucket][#spawn_buckets[spawn_def.dimension][bucket] + 1] = spawn_def
				bucket_weights[spawn_def.dimension][bucket] = bucket_weights[spawn_def.dimension][bucket] + get_spawn_weight(spawn_def)
				bucket_name_lookups[spawn_def.dimension][bucket][spawn_def.name] = true
			end
		end
	end

	local function pick_weighted_spawn_def(dimension, bucket)
		local defs = spawn_buckets[dimension][bucket]
		local total_weight = bucket_weights[dimension][bucket]
		if not defs or #defs == 0 or total_weight <= 0 then
			return
		end
		local target = math.random() * total_weight
		local step = 0
		for _, spawn_def in ipairs(defs) do
			step = step + get_spawn_weight(spawn_def)
			if step >= target then
				return spawn_def
			end
		end
		return defs[#defs]
	end

	local function run_bucket_for_player(player_pos, dimension, bucket)
		local defs = spawn_buckets[dimension][bucket]
		if not defs or #defs == 0 then
			return
		end

		local name_lookup = bucket_name_lookups[dimension][bucket]
		local bucket_cap = BUCKET_CAPS[bucket] or mob_cap.total
		if count_mobs_total_cap_by_name(name_lookup) >= bucket_cap then
			return
		end

		for _ = 1, BUCKET_ATTEMPTS[bucket] or 1 do
			if count_mobs_total_cap_by_name(name_lookup) >= bucket_cap then
				break
			end
			local spawn_def = pick_weighted_spawn_def(dimension, bucket)
			if spawn_def then
				spawn_def_pack(player_pos, spawn_def)
			end
		end
	end

	local hostile_timer = HOSTILE_INTERVAL
	local passive_timer = 0
	minetest.register_globalstep(function(dtime)
		hostile_timer = hostile_timer - dtime
		passive_timer = passive_timer - dtime

		local players = minetest.get_connected_players()
		if #players == 0 then
			return
		end

		local total_mobs = count_mobs_total_cap()
		if total_mobs > mob_cap.total or total_mobs > #players * mob_cap.player then
			if logging then
				minetest.log("action", "[mcl_mobs] global mob cap reached. no cycle spawning.")
			end
			return
		end

		initialize_spawn_data()

		if hostile_timer <= 0 then
			hostile_timer = HOSTILE_INTERVAL
			for _, player in ipairs(players) do
				local pos = player:get_pos()
				local dimension = mcl_worlds.pos_to_dimension(pos)
				if spawn_buckets[dimension] then
					run_bucket_for_player(pos, dimension, "hostile")
					run_bucket_for_player(pos, dimension, "ambient")
					run_bucket_for_player(pos, dimension, "water")
					run_bucket_for_player(pos, dimension, "lava")
				end
			end
		end

		if passive_timer <= 0 then
			passive_timer = PASSIVE_INTERVAL
			for _, player in ipairs(players) do
				local pos = player:get_pos()
				local dimension = mcl_worlds.pos_to_dimension(pos)
				if spawn_buckets[dimension] then
					run_bucket_for_player(pos, dimension, "passive")
				end
			end
		end
	end)
end

function mob_class:check_despawn(pos, dtime)
	if remove_far and self:despawn_allowed() then
		local min_dist = math.huge
		for player in mcl_util.connected_players() do
			min_dist = math.min(min_dist, vector.distance(player:get_pos(), pos))
		end

		if min_dist > instant_despawn_range then
			self:kill_me("no players within distance " .. instant_despawn_range)
			return true
		elseif min_dist > random_despawn_range then
			if self.lifetimer then
				self.lifetimer = self.lifetimer - dtime
				if self.lifetimer <= 0 then
					if math.random(1, 100) < (min_dist * min_dist) / 512 then
						self:kill_me("random chance at distance " .. math.round(min_dist))
						return true
					end
				else
					return false
				end
			end

			if (minetest.get_node_light(pos) or minetest.LIGHT_MAX) < timer_light_level then
				self.lifetimer = timer_dark
			else
				self.lifetimer = timer_light
			end

			return false
		else
			self.lifetimer = nil
			return false
		end
	end
end

function mob_class:kill_me(msg)
	if logging then
		minetest.log("action", "[mcl_mobs] Mob " .. self.name .. " despawns at " .. minetest.pos_to_string(self.object:get_pos(), 1) .. ": " .. msg)
	end
	self:safe_remove()
end

minetest.register_chatcommand("spawn_mob", {
	privs = { debug = true },
	description = S("spawn_mob is a chatcommand that allows you to type in the name of a mob without 'typing mobs_mc:' all the time like so; 'spawn_mob spider'. however, there is more you can do with this special command, currently you can edit any number, boolean, and string variable you choose with this format: spawn_mob 'any_mob:var<mobs_variable=variable_value>:'. any_mob being your mob of choice, mobs_variable being the variable, and variable value being the value of the chosen variable. and example of this format: \n spawn_mob skeleton:var<passive=true>:\n this would spawn a skeleton that wouldn't attack you. REMEMBER-THIS> when changing a number value always prefix it with 'NUM', example: \n spawn_mob skeleton:var<jump_height=NUM10>:\n this setting the skelly's jump height to 10. if you want to make multiple changes to a mob, you can, example: \n spawn_mob skeleton:var<passive=true>::var<jump_height=NUM10>::var<fly_in=air>::var<fly=true>:\n etc."),
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "No player"
		end
		local pos = player:get_pos()

		local modifiers = {}
		for capture in string.gmatch(param, "%:(.-)%:") do
			modifiers[#modifiers + 1] = ":" .. capture
		end

		local mod1 = string.find(param, ":")
		local mobname = mod1 and string.sub(param, 1, mod1 - 1) or param
		local mob = mcl_mobs.spawn(pos, mobname, minetest.serialize({ persist_in_peaceful = true }))

		if not mob then
			return false, "Couldn't spawn " .. mobname
		end

		for i = 1, #modifiers do
			local modifs = modifiers[i]
			local mod_start = string.find(modifs, "<")
			local mod_vals = string.find(modifs, "=")
			local mod_end = string.find(modifs, ">")
			local mob_entity = mob:get_luaentity()
			if string.sub(modifs, 2, 4) == "var" and mod_start and mod_vals and mod_end then
				local variable = string.sub(modifs, mod_start + 1, mod_vals - 1)
				local value = string.sub(modifs, mod_vals + 1, mod_end - 1)
				if string.find(value, "NUM") then
					value = tonumber(string.sub(value, 4, -1))
				elseif value == "true" then
					value = true
				elseif value == "false" then
					value = false
				end
				mob_entity[variable] = value
			end
		end

		minetest.log("action", name .. " spawned " .. mobname .. " at " .. minetest.pos_to_string(pos))
		return true, mobname .. " spawned at " .. minetest.pos_to_string(pos)
	end,
})

minetest.register_chatcommand("spawncheck", {
	privs = { debug = true },
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "No player"
		end
		local pos = vector.offset(player:get_pos(), 0, -1, 0)
		local dim = mcl_worlds.pos_to_dimension(pos)
		local spawn_def
		for _, def in pairs(spawn_dictionary) do
			if def.name == param and def.dimension == dim then
				spawn_def = def
			end
		end
		if not spawn_def then
			return false, "no spawndef found for " .. param
		end
		local ok, why = spawn_check(pos, spawn_def)
		if ok then
			return true, "spawn check for " .. spawn_def.name .. " at " .. minetest.pos_to_string(pos) .. " successful"
		end
		return false, tostring(why) or ""
	end,
})

minetest.register_chatcommand("mobstats", {
	privs = { debug = true },
	func = function(name, _)
		minetest.chat_send_player(name, dump(dbg_spawn_counts))
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "No player"
		end
		local pos = player:get_pos()
		minetest.chat_send_player(name, "mobs within 32 radius of player:" .. count_mobs(pos, 32))
		minetest.chat_send_player(name, "total mobs:" .. count_mobs_total())
		minetest.chat_send_player(name, "spawning attempts since server start:" .. dbg_spawn_attempts)
		minetest.chat_send_player(name, "successful spawns since server start:" .. dbg_spawn_succ)

		local mob_counts, total_mobs = count_mobs_all()
		if total_mobs then
			minetest.log("action", "Total mobs found: " .. total_mobs)
		end
		if mob_counts then
			for k, v in pairs(mob_counts) do
				minetest.log("action", "k: " .. tostring(k))
				minetest.log("action", "v1: " .. tostring(v))
			end
		end
	end,
})
