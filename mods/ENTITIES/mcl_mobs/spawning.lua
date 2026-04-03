--lua locals
local mob_class = mcl_mobs.mob_class

local modern_lighting = minetest.settings:get_bool("mcl_mobs_modern_lighting", true)
local peaceful_mode = minetest.settings:get_bool("only_peaceful_mobs", false)

local nether_threshold = 11
local end_threshold = 15
local overworld_threshold = 0
local overworld_sky_threshold = 7
local overworld_passive_threshold = 7

local PASSIVE_INTERVAL = tonumber(minetest.settings:get("betaclonia_passive_spawn_interval")) or 10
if PASSIVE_INTERVAL <= 0 then
	PASSIVE_INTERVAL = 10
end
local HOSTILE_INTERVAL = 10
local PASSIVE_CHANCE_MULT = tonumber(minetest.settings:get("betaclonia_passive_spawn_weight")) or 1
local ANIMAL_LOCAL_CAP = tonumber(minetest.settings:get("betaclonia_animal_local_cap")) or 8
local SPAWN_DISTANCE = tonumber(minetest.settings:get("active_block_range")) or 4
local PASSIVE_CHUNK_CAP = 10
local MOB_CAP_DIVISOR = 289
local MOB_CAP_RECIPROCAL = 1 / MOB_CAP_DIVISOR
local OVERWORLD_CEILING_MARGIN = 64
local OVERWORLD_DEFAULT_CEILING = 256
local dbg_spawn_attempts = 0
local dbg_spawn_succ = 0
local dbg_spawn_counts = {}
-- range for mob count
local aoc_range = 136
local remove_far = true

local timer_light = 30
local timer_dark = 10
local timer_light_level = 3
local instant_despawn_range = 128
local random_despawn_range = 32

local mob_cap = {
	monster = tonumber(minetest.settings:get("mcl_mob_cap_monster")) or 70,
	animal = tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 15,
	ambient = tonumber(minetest.settings:get("mcl_mob_cap_ambient")) or 15,
	water = tonumber(minetest.settings:get("mcl_mob_cap_water")) or 5,
	water_ambient = tonumber(minetest.settings:get("mcl_mob_cap_water_ambient")) or 20,
	player = tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75,
	total = tonumber(minetest.settings:get("mcl_mob_cap_total")) or 500,
}

--do mobs spawn?
local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false
local spawn_protected = minetest.settings:get_bool("mobs_spawn_protected") ~= false
local logging = minetest.settings:get_bool("mcl_logging_mobs_spawn", false)
local mgname = minetest.get_mapgen_setting("mgname")

-- count how many mobs are in an area
local function count_mobs(pos,r,mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l and l.is_mob and (mob_type == nil or l.type == mob_type) then
			local p = l.object:get_pos()
			if p and vector.distance(p,pos) < r then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_total(mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l.is_mob then
			if mob_type == nil or l.type == mob_type then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_all()
	local mobs_found = {}
	local num = 0
	for _,entity in pairs(minetest.luaentities) do
		if entity.is_mob then
			local mob_name = entity.name
			if mobs_found[mob_name] then
				mobs_found[mob_name] = mobs_found[mob_name] + 1
			else
				mobs_found[mob_name] = 1
			end
			num = num + 1
		end
	end
	return mobs_found, num
end

local function count_mobs_total_cap(mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l.is_mob then
			if ( mob_type == nil or l.type == mob_type ) and l.can_despawn and not l.nametag then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_total_cap_by_name(name_lookup)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l.is_mob and name_lookup[l.name] and l.can_despawn and not l.nametag then
			num = num + 1
		end
	end
	return num
end

--this is where all of the spawning information is kept
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
	if not mobs_spawn then return end

	assert(def, "Empty spawn setup definition from mod: "..tostring(minetest.get_current_modname()))
	assert(def.name, "Missing mob name from from mod: "..tostring(minetest.get_current_modname()))

	local mob_def = minetest.registered_entities[def.name]
	assert(mob_def, "spawn definition with invalid entity: "..tostring(def.name))
	if peaceful_mode and not mob_def.persist_in_peaceful then return end
	assert(def.chance > 0, "Chance shouldn't be less than 1 (mob name: " .. def.name ..")")

	setmetatable(def, spawn_defaults_meta)
	def.min_light        = def.min_light or mob_def.min_light or (mob_def.spawn_class == "hostile" and 0)
	def.max_light        = def.max_light or mob_def.max_light or (mob_def.spawn_class == "hostile" and 7)
	def.min_height       = def.min_height or mcl_vars["mg_"..def.dimension.."_min"]
	def.max_height       = def.max_height or mcl_vars["mg_"..def.dimension.."_max"]
	if mob_def.spawn_class == "passive" and PASSIVE_CHANCE_MULT > 1 then
		def.chance = math.max(1, math.floor(def.chance * PASSIVE_CHANCE_MULT))
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

	table.insert(spawn_dictionary, def)
end

function mcl_mobs.get_mob_light_level(mob,dim)
	for _,v in pairs(spawn_dictionary) do
		if v.name == mob and v.dimension == dim then
			return v.min_light,v.max_light
		end
	end
	local def = minetest.registered_entities[mob]
	return def.min_light,def.max_light
end

local function biome_check(biome_list, biome_goal)
	if mgname == "singlenode" then return true end
	return table.indexof(biome_list,biome_goal) ~= -1
end

local function is_farm_animal(n)
	return n == "mobs_mc:pig" or n == "mobs_mc:cow" or n == "mobs_mc:sheep" or n == "mobs_mc:chicken" or n == "mobs_mc:horse" or n == "mobs_mc:donkey"
end

local function is_passive_ground_spawn_def(spawn_def, entity_def)
	entity_def = entity_def or minetest.registered_entities[spawn_def.name]
	return entity_def
		and entity_def.spawn_class == "passive"
		and entity_def.type == "animal"
		and spawn_def.type_of_spawning == "ground"
end

local function get_water_spawn(p)
		local nn = minetest.find_nodes_in_area(vector.offset(p,-2,-1,-2),vector.offset(p,2,-15,2),{"group:water"})
		if nn and #nn > 0 then
			return nn[math.random(#nn)]
		end
end

local function has_room(self,pos)
	local cb = self.initial_properties.collisionbox
	local nodes = {}
	if self.fly_in then
		local t = type(self.fly_in)
		if t == "table" then
			nodes = table.copy(self.fly_in)
		elseif t == "string" then
			table.insert(nodes,self.fly_in)
		end
	end
	if self.swims_in then
		local t = type(self.swims_in)
		if t == "table" then
			nodes = table.copy(self.swims_in)
		elseif t == "string" then
			table.insert(nodes,self.swims_in)
		end
	end
	table.insert(nodes,"air")
	local x = cb[4] - cb[1]
	local y = cb[5] - cb[2]
	local z = cb[6] - cb[3]
	local r = math.ceil(x * y * z)
	local p1 = vector.offset(pos,cb[1],cb[2],cb[3])
	local p2 = vector.offset(pos,cb[4],cb[5],cb[6])
	local n = #minetest.find_nodes_in_area(p1,p2,nodes) or 0
	if r > n then
		minetest.log("info","[mcl_mobs] No room for mob "..self.name.." at "..minetest.pos_to_string(vector.round(pos)))
		return false
	end
	return true
end

local function spawn_check(pos,spawn_def,ignore_caps)
	if not spawn_def or not pos then return end
	dbg_spawn_attempts = dbg_spawn_attempts + 1
	local dimension = mcl_worlds.pos_to_dimension(pos)
	local mob_def = minetest.registered_entities[spawn_def.name]
	local mob_type = mob_def.type
	local gotten_node = minetest.get_node_or_nil(pos)
	if not gotten_node then return end
	gotten_node = gotten_node.name
	local is_ground = minetest.get_item_group(gotten_node,"opaque") ~= 0
	if not is_ground then
		pos.y = pos.y - 1
		gotten_node = minetest.get_node(pos).name
		is_ground = minetest.get_item_group(gotten_node,"opaque") ~= 0
	end
	pos.y = pos.y + 1
	local is_water = minetest.get_item_group(gotten_node, "water") ~= 0
	local is_lava  = minetest.get_item_group(gotten_node, "lava") ~= 0
	local is_leaf  = minetest.get_item_group(gotten_node, "leaves") ~= 0
	local is_bedrock  = gotten_node == "mcl_core:bedrock"
	local is_grass = minetest.get_item_group(gotten_node,"grass_block") ~= 0


	if not pos then return false,"no pos" end
	if not spawn_def then return false,"no spawn_def" end
	if not ( spawn_def.min_height and pos.y >= spawn_def.min_height ) then return false, "too low" end
	if not ( spawn_def.max_height and pos.y <= spawn_def.max_height ) then return false, "too high" end
	if spawn_def.dimension ~= dimension then return false, "wrong dimension" end
	if not (is_ground or spawn_def.type_of_spawning ~= "ground") then return false, "not on ground" end
	if not (spawn_def.type_of_spawning ~= "ground" or not is_leaf) then return false, "leaf" end
	if not has_room(mob_def,pos) then return false, "no room" end
	if not (spawn_def.check_position and spawn_def.check_position(pos) or true) then return false, "check_position failed" end
	if not (not is_farm_animal(spawn_def.name) or is_grass) then return false, "farm animals only on grass" end
	if not (spawn_def.type_of_spawning ~= "water" or is_water) then return false, "water mob only on water" end
	if not (spawn_def.type_of_spawning ~= "lava" or is_lava) then return false, "lava mobs only on lava" end
	if not ( not spawn_protected or not minetest.is_protected(pos, "") ) then return false, "spawn protected" end
	if is_bedrock then return false, "no spawn on bedrock" end

	-- More expensive checks last
	local biome = minetest.get_biome_data(pos)
	if not biome then return false, "no biome found" end
	biome = minetest.get_biome_name(biome.biome) --makes it easier to work with
	if not ( not spawn_def.biomes_except or (spawn_def.biomes_except and not biome_check(spawn_def.biomes_except, biome))) then return false, "biomes_except failed" end
	if not ( not spawn_def.biomes or (spawn_def.biomes and biome_check(spawn_def.biomes, biome))) then return false, "biome check failed" end

	local gotten_light = minetest.get_node_light(pos)
	local my_node = minetest.get_node(pos)
	local sky_light = minetest.get_natural_light(pos)
	local art_light = minetest.get_artificial_light(my_node.param1)
	if modern_lighting then

		if mob_def.check_light then
			return mob_def.check_light(pos, gotten_light, art_light, sky_light)
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
			-- passive threshold is apparently the same in all dimensions ...
			if gotten_light <= overworld_passive_threshold then
				return false, "too dark"
			end
		end
	else
		if gotten_light < spawn_def.min_light then return false,"too dark" end
		if gotten_light > spawn_def.max_light then return false,"too bright" end
	end

	local mob_count_wide = 0
	local mob_count = 0
	if not ignore_caps then
		mob_count = count_mobs(pos,32,mob_type)
		mob_count_wide = count_mobs(pos,aoc_range,mob_type)
	end

	if ( mob_count_wide >= (mob_cap[mob_type] or 15) ) then return false,"mob cap wide full" end
	local local_cap = (mob_type == "animal") and ANIMAL_LOCAL_CAP or 5
	if ( mob_count >= local_cap ) then return false, "local mob cap full" end

	return true, ""
end

function mcl_mobs.spawn(pos,id, staticdata)
	local def = minetest.registered_entities[id] or minetest.registered_entities["mobs_mc:"..id] or minetest.registered_entities["extra_mobs:"..id]
	if not def or (def.can_spawn and not def.can_spawn(pos)) or not def.is_mob then
		return false
	end
	if not dbg_spawn_counts[def.name] then
		dbg_spawn_counts[def.name] = 1
	else
		dbg_spawn_counts[def.name] = dbg_spawn_counts[def.name] + 1
	end
	return minetest.add_entity(pos, def.name, staticdata)
end


local function spawn_group(p,mob,spawn_on,group_max,group_min)
	if not group_min then group_min = 1 end
	local nn= minetest.find_nodes_in_area_under_air(vector.offset(p,-5,-3,-5),vector.offset(p,5,3,5),spawn_on)
	local o
	table.shuffle(nn)
	if not nn or #nn < 1 then
		nn = {}
		table.insert(nn,p)
	end
	for _ = 1, math.random(group_min,group_max) do
		local sp = vector.offset(nn[math.random(#nn)],0,1,0)
		if spawn_check(nn[math.random(#nn)],mob,true) then
			if mob.type_of_spawning == "water" then
				sp = get_water_spawn(sp)
			end
			o =  mcl_mobs.spawn(sp,mob.name)
			if o then dbg_spawn_succ = dbg_spawn_succ + 1 end
		end
	end
	return o
end

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

mcl_mobs.spawn_group = spawn_group

local S = minetest.get_translator("mcl_mobs")

--extra checks for mob spawning
local function can_spawn(spawn_def,spawning_position)
	if spawn_def.type_of_spawning == "water" then
		spawning_position = get_water_spawn(spawning_position)
		if not spawning_position then
			minetest.log("warning","[mcl_mobs] no water spawn for mob "..spawn_def.name.." found at "..minetest.pos_to_string(vector.round(spawning_position)))
			return
		end
	end
	if minetest.registered_entities[spawn_def.name].can_spawn and not minetest.registered_entities[spawn_def.name].can_spawn(spawning_position) then
		minetest.log("warning","[mcl_mobs] mob "..spawn_def.name.." refused to spawn at "..minetest.pos_to_string(vector.round(spawning_position)))
		return false
	end
	return true
end

local MOB_SPAWN_ZONE_INNER = 24
local MOB_SPAWN_ZONE_OUTER = 128


local SPAWN_MAPGEN_LIMIT  = 30911

local function math_round(x) return (x > 0) and math.floor(x + 0.5) or math.ceil(x - 0.5) end

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

local function merge_range(rangearray, start, fin)
	local nmax, first_overlap, last_overlap = #rangearray
	local last_before = 0
	assert(nmax % 2 == 0)

	for i = 1, nmax, 2 do
		if rangearray[i] < start then
			last_before = i + 1
		end
		if rangearray[i] <= fin and start <= rangearray[i + 1] then
			if not first_overlap then
				first_overlap = i
			end
			last_overlap = i
		end
	end

	if first_overlap then
		if rangearray[first_overlap] == start and rangearray[last_overlap + 1] == fin then
			return
		end
		if rangearray[first_overlap] > start then
			rangearray[first_overlap] = start
		end

		local value = rangearray[last_overlap + 1]
		local src_begin = last_overlap + 2
		local dst_begin = first_overlap + 2

		if src_begin ~= dst_begin then
			local num_copies = nmax - src_begin + 1
			for i = 0, num_copies - 1 do
				rangearray[dst_begin + i] = rangearray[src_begin + i]
			end
			for i = dst_begin + num_copies, nmax do
				rangearray[i] = nil
			end
		end
		rangearray[first_overlap + 1] = math.max(value, fin)
	else
		local new_max = nmax + 2
		for i = 0, nmax - last_before - 1 do
			rangearray[new_max - i] = rangearray[nmax - i]
		end
		rangearray[last_before + 1] = start
		rangearray[last_before + 2] = fin
	end
	return rangearray
end

local function position_in_chunk(data)
	local total = 0
	local ranges = data.y_ranges
	local psize = #ranges
	for i = 1, psize, 2 do
		total = total + (ranges[i + 1] - ranges[i] + 1)
	end
	local value = math.random(1, total)
	for i = 1, psize, 2 do
		value = value - (ranges[i + 1] - ranges[i] + 1)
		if value <= 0 then
			return ranges[i + 1] + value
		end
	end
	assert(false)
end

local function collect_unique_chunks(level)
	local chunk_data, chunks, players = {}, {}, {}
	for player in mcl_util.connected_players() do
		local pos = player:get_pos()
		local chunk_dim = mcl_worlds.pos_to_dimension(pos)
		players[player] = pos

		if chunk_dim == level then
			local chunk_x = math.floor(pos.x / 16.0)
			local chunk_z = math.floor(pos.z / 16.0)
			local start, fin = level_y_range(level, pos)
			for x = chunk_x - SPAWN_DISTANCE, chunk_x + SPAWN_DISTANCE do
				for z = chunk_z - SPAWN_DISTANCE, chunk_z + SPAWN_DISTANCE do
					local hash = ((x + 2048) * 4096) + (z + 2048)
					local data = chunk_data[hash]
					if not data then
						chunks[#chunks + 1] = hash
						chunk_data[hash] = {
							y_ranges = { start, fin },
						}
					else
						merge_range(data.y_ranges, start, fin)
					end
				end
			end
		end
	end
	return chunks, players, chunk_data
end

local function collect_all_unique_chunks()
	local chunks = {}
	local n_chunks = 0
	for _, level in ipairs({ "overworld", "nether", "end" }) do
		chunks[level] = { collect_unique_chunks(level) }
		n_chunks = n_chunks + #chunks[level][1]
	end
	return chunks, n_chunks
end

local function dist_sqr(a, b)
	local dx = b.x - a.x
	local dy = b.y - a.y
	local dz = b.z - a.z
	return dx * dx + dy * dy + dz * dz
end

local function get_nearest_player(pos, list)
	local dist, pos_nearest, player = nil
	for player_1, test_pos in pairs(list) do
		local d = dist_sqr(test_pos, pos)
		if not dist or dist > d then
			dist = d
			pos_nearest = test_pos
			player = player_1
		end
	end
	return player, pos_nearest
end

local function find_surface_spawn_pos(x, z, y_ranges)
	local surface_pos
	for i = 1, #y_ranges, 2 do
		local found = minetest.find_nodes_in_area_under_air(
			{x = x, y = y_ranges[i], z = z},
			{x = x, y = y_ranges[i + 1], z = z},
			{"group:opaque"}
		)
		for _, pos in ipairs(found or {}) do
			if not surface_pos or pos.y > surface_pos.y then
				surface_pos = pos
			end
		end
	end
	if surface_pos then
		return vector.offset(surface_pos, 0, 1, 0)
	end
end

local function get_passive_spawn_weight(def)
	local chance = tonumber(def.chance) or 1
	if chance < 1 then
		chance = 1
	end
	return 1 / chance
end

local function get_eligible_passive_spawn_def(base_pos, level, passive_defs)
	local biome_data = minetest.get_biome_data(base_pos)
	if not biome_data then
		return
	end
	local biome_name = minetest.get_biome_name(biome_data.biome)
	local total_weight = 0
	local eligible = {}

	for _, spawn_def in ipairs(passive_defs) do
		if spawn_def.dimension == level
			and base_pos.y >= spawn_def.min_height
			and base_pos.y <= spawn_def.max_height
			and (not spawn_def.biomes_except or not biome_check(spawn_def.biomes_except, biome_name))
			and (not spawn_def.biomes or biome_check(spawn_def.biomes, biome_name)) then
			local weight = get_passive_spawn_weight(spawn_def)
			total_weight = total_weight + weight
			eligible[#eligible + 1] = {
				def = spawn_def,
				weight = weight,
			}
		end
	end

	if total_weight <= 0 then
		return
	end

	local mob_weight_offset = math.random() * total_weight
	local step_weight = 0
	for _, entry in ipairs(eligible) do
		step_weight = step_weight + entry.weight
		if step_weight >= mob_weight_offset then
			return entry.def
		end
	end
	return eligible[#eligible] and eligible[#eligible].def
end

local function unpack3(x)
	return x[1], x[2], x[3]
end

local function spawn_passive_pack(level, chunk, players, chunk_data, passive_defs)
	local chunk_x = math.floor(chunk / 4096) - 2048
	local chunk_z = chunk % 4096 - 2048
	local x = math.random(chunk_x * 16, chunk_x * 16 + 15)
	local z = math.random(chunk_z * 16, chunk_z * 16 + 15)
	local base_pos = find_surface_spawn_pos(x, z, chunk_data[chunk].y_ranges)
	if not base_pos then
		return 0
	end
	local spawn_def = get_eligible_passive_spawn_def(base_pos, level, passive_defs)
	if not spawn_def then
		return 0
	end

	local entity_def = minetest.registered_entities[spawn_def.name]
	local spawn_in_group = entity_def.spawn_in_group or 4
	local spawn_in_group_min = entity_def.spawn_in_group_min or 1
	local n_spawned = 0

	for _ = 1, math.random(spawn_in_group_min, spawn_in_group) do
		local dx = math.random(0, 5) - math.random(0, 5)
		local dz = math.random(0, 5) - math.random(0, 5)
		local spawning_position = find_surface_spawn_pos(x + dx, z + dz, chunk_data[chunk].y_ranges)
		if spawning_position then
			local _, player_pos = get_nearest_player(spawning_position, players)
			local dist = player_pos and dist_sqr(player_pos, spawning_position)
			if dist and dist > 576 and dist < (MOB_SPAWN_ZONE_OUTER * MOB_SPAWN_ZONE_OUTER) then
				local check_pos = vector.new(spawning_position.x, spawning_position.y, spawning_position.z)
				if spawn_check(check_pos, spawn_def, true) and can_spawn(spawn_def, spawning_position) then
					local spawned_obj = mcl_mobs.spawn(spawning_position, spawn_def.name)
					if spawned_obj then
						dbg_spawn_succ = dbg_spawn_succ + 1
						n_spawned = n_spawned + 1
						if logging then
							minetest.log("action", "[mcl_mobs] Passive mob " .. spawn_def.name .. " spawns on " .. minetest.get_node(vector.offset(spawning_position, 0, -1, 0)).name .. " at " .. minetest.pos_to_string(spawning_position, 1))
						end
					end
				end
			end
		end
	end

	return n_spawned
end

local function spawn_passive_cycle(level, chunks, existing, global_max, passive_defs)
	local chunk_list, players, chunk_data = unpack3(chunks[level])
	if not chunk_list or #chunk_list == 0 then
		return existing
	end

	table.shuffle(chunk_list)
	for i = 1, #chunk_list do
		if existing >= global_max then
			break
		end
		local chunk = chunk_list[i]
		local chunk_x = math.floor(chunk / 4096) - 2048
		local chunk_z = chunk % 4096 - 2048
		local center_x = (chunk_x * 16) + 7.5
		local center_z = (chunk_z * 16) + 7.5
		local eligible = false

		for _, pos in pairs(players) do
			local dist = (pos.x - center_x) * (pos.x - center_x) + (pos.z - center_z) * (pos.z - center_z)
			if dist < 16384.0 then
				eligible = true
				break
			end
		end

		if eligible then
			existing = existing + spawn_passive_pack(level, chunk, players, chunk_data, passive_defs)
		end
	end

	return existing
end

local function get_next_mob_spawn_pos(pos, spawn_def)
	-- Select a distance such that distances closer to the player are selected much more often than
	-- those further away from the player. This does produce a concentration at INNER (24 blocks)
	local distance = math.random()^2 * (MOB_SPAWN_ZONE_OUTER - MOB_SPAWN_ZONE_INNER) + MOB_SPAWN_ZONE_INNER
	local dir = vector.random_direction()
	-- minetest.log("action", "Using spawn distance of "..tostring(distance).." in direction "..minetest.pos_to_string(dir))
	local goal_pos = vector.offset(pos, dir.x * distance, dir.y * distance, dir.z * distance)

	if not ( math.abs(goal_pos.x) <= SPAWN_MAPGEN_LIMIT and math.abs(goal_pos.y) <= SPAWN_MAPGEN_LIMIT and math.abs(goal_pos.z) <= SPAWN_MAPGEN_LIMIT ) then
		return nil
	end

	-- Calculate upper/lower y limits
	local R1 = distance + 3
	local d = vector.distance( pos, vector.new( goal_pos.x, pos.y, goal_pos.z ) ) -- distance from player to projected point on horizontal plane
	local y1 = math.sqrt( R1*R1 - d*d ) -- absolue value of distance to outer sphere

	local y_min
	local y_max
	if d >= MOB_SPAWN_ZONE_INNER then
		-- Outer region, y range has both ends on the outer sphere
		y_min = pos.y - y1
		y_max = pos.y + y1
	else
		-- Inner region, y range spans between inner and outer spheres
		local R2 = MOB_SPAWN_ZONE_INNER
		local y2 = math.sqrt( R2*R2 - d*d )
		if goal_pos.y > pos. y then
			-- Upper hemisphere
			y_min = pos.y + y2
			y_max = pos.y + y1
		else
			-- Lower hemisphere
			y_min = pos.y - y1
			y_max = pos.y - y2
		end
	end
	y_min = math_round(y_min)
	y_max = math_round(y_max)

	local spawn_nodes = {"group:opaque", "group:water", "group:lava"}
	local prefer_surface = false
	if spawn_def then
		if spawn_def.type_of_spawning == "ground" then
			spawn_nodes = {"group:opaque"}
			local entity_def = minetest.registered_entities[spawn_def.name]
			prefer_surface = entity_def
				and entity_def.spawn_class == "passive"
				and entity_def.type == "animal"
				and spawn_def.dimension == "overworld"
		elseif spawn_def.type_of_spawning == "water" then
			spawn_nodes = {"group:water"}
		elseif spawn_def.type_of_spawning == "lava" then
			spawn_nodes = {"group:lava"}
		end
	end

	local spawning_position_list = minetest.find_nodes_in_area_under_air(
			{x = goal_pos.x, y = y_min, z = goal_pos.z},
			{x = goal_pos.x, y = y_max, z = goal_pos.z},
			spawn_nodes
	) or {}

	-- Select only the locations at a valid distance
	local valid_positions = {}
	for _,check_pos in ipairs(spawning_position_list) do
		local dist = vector.distance(pos, check_pos)
		if dist >= MOB_SPAWN_ZONE_INNER and dist <= MOB_SPAWN_ZONE_OUTER then
			table.insert(valid_positions, check_pos)
		end
	end

	if #valid_positions == 0 then return end
	if prefer_surface then
		local surface_pos = valid_positions[1]
		for i = 2, #valid_positions do
			if valid_positions[i].y > surface_pos.y then
				surface_pos = valid_positions[i]
			end
		end
		return surface_pos
	end
	return valid_positions[math.random(#valid_positions)]

end


if mobs_spawn then
	local cumulative_spawn_weight
	local mob_library_worker_table
	local passive_ground_spawn_defs
	local passive_ground_spawn_names
	local function get_spawn_weight(def)
		return get_passive_spawn_weight(def)
	end
	local function initialize_spawn_data()
		if not mob_library_worker_table or not passive_ground_spawn_defs or not passive_ground_spawn_names then
			mob_library_worker_table = {}
			passive_ground_spawn_defs = {}
			passive_ground_spawn_names = {}
			for _, def in pairs(spawn_dictionary) do
				local entity_def = minetest.registered_entities[def.name]
				if is_passive_ground_spawn_def(def, entity_def) then
					passive_ground_spawn_defs[#passive_ground_spawn_defs + 1] = def
					passive_ground_spawn_names[def.name] = true
				else
					mob_library_worker_table[#mob_library_worker_table + 1] = def
				end
			end
		end
		if cumulative_spawn_weight == nil then
			cumulative_spawn_weight = 0
			for _, v in pairs(mob_library_worker_table) do
				cumulative_spawn_weight = cumulative_spawn_weight + get_spawn_weight(v)
			end
		end
	end

	local function spawn_a_mob(pos, _, _)
		--create a disconnected clone of the spawn dictionary
		--prevents memory leak

		local worker_table = table.copy(mob_library_worker_table)
		if not cumulative_spawn_weight or cumulative_spawn_weight <= 0 then
			return
		end

		local spawn_loop_counter = #worker_table
		--use random weighted choice with replacement to grab a mob, don't exclude any possibilities
		--shuffle table once every loop to provide equal inclusion probability to all mobs
		--repeat grabbing a mob to maintain existing spawn rates
		while spawn_loop_counter > 0 do
			table.shuffle(worker_table)
			local mob_weight_offset = math.random() * cumulative_spawn_weight
			local mob_index = 1
			local step_weight = 0
			for i = 1, #worker_table do
				step_weight = step_weight + get_spawn_weight(worker_table[i])
				if step_weight >= mob_weight_offset then
					mob_index = i
					break
				end
			end
			local spawn_def = worker_table[mob_index]
			--minetest.log(spawn_def.name.." "..step_weight.. " "..mob_weight_offset)
			if spawn_def and spawn_def.name and minetest.registered_entities[spawn_def.name] then
				local entity_def = minetest.registered_entities[spawn_def.name]
				local spawn_in_group = entity_def.spawn_in_group or 4
				local spawn_in_group_min = entity_def.spawn_in_group_min or 1
				local mob_type = entity_def.type
				local spawning_position = get_next_mob_spawn_pos(pos, spawn_def)
				if spawn_check(spawning_position,spawn_def) then

					if can_spawn(spawn_def,spawning_position) then
						--everything is correct, spawn mob
						local spawned_obj
						if spawn_in_group and ( mob_type ~= "monster" or math.random(5) == 1 ) then
							if logging then
								minetest.log("action", "[mcl_mobs] A group of mob " .. spawn_def.name .. " spawns on " ..minetest.get_node(vector.offset(spawning_position,0,-1,0)).name .." at " .. minetest.pos_to_string(spawning_position, 1))
							end
							spawned_obj = spawn_group(spawning_position,spawn_def,{minetest.get_node(vector.offset(spawning_position,0,-1,0)).name},spawn_in_group,spawn_in_group_min)

						else
							if logging then
								minetest.log("action", "[mcl_mobs] Mob " .. spawn_def.name .. " spawns on " ..minetest.get_node(vector.offset(spawning_position,0,-1,0)).name .." at ".. minetest.pos_to_string(spawning_position, 1))
							end
							spawned_obj = mcl_mobs.spawn(spawning_position, spawn_def.name)
						end
					end
				end
			end
			spawn_loop_counter = spawn_loop_counter - 1
		end
	end


	--MAIN LOOP

	local timer = HOSTILE_INTERVAL
	local passive_spawn_timer = 0
	minetest.register_globalstep(function(dtime)
		timer = timer - dtime
		passive_spawn_timer = passive_spawn_timer - dtime

		local players = minetest.get_connected_players()
		if #players == 0 then
			return
		end
		local total_mobs = count_mobs_total_cap()
		if total_mobs > mob_cap.total or total_mobs > #players * mob_cap.player then
			minetest.log("action","[mcl_mobs] global mob cap reached. no cycle spawning.")
			return
		end --mob cap per player

		initialize_spawn_data()
		if timer <= 0 then
			timer = HOSTILE_INTERVAL
			for _, player in pairs(players) do
				local pos = player:get_pos()
				local dimension = mcl_worlds.pos_to_dimension(pos)
				-- ignore void and unloaded area
				if dimension ~= "void" and dimension ~= "default" then
					spawn_a_mob(pos, dimension, dtime)
				end
			end
		end

		if passive_spawn_timer <= 0 and passive_ground_spawn_defs and #passive_ground_spawn_defs > 0 then
			local chunks, n_chunks = collect_all_unique_chunks()
			local passive_global_cap = math.max(math.floor((n_chunks * PASSIVE_CHUNK_CAP) * MOB_CAP_RECIPROCAL), PASSIVE_CHUNK_CAP)
			local existing_passives = count_mobs_total_cap_by_name(passive_ground_spawn_names)

			if existing_passives < passive_global_cap then
				existing_passives = spawn_passive_cycle("overworld", chunks, existing_passives, passive_global_cap, passive_ground_spawn_defs)
				existing_passives = spawn_passive_cycle("nether", chunks, existing_passives, passive_global_cap, passive_ground_spawn_defs)
				existing_passives = spawn_passive_cycle("end", chunks, existing_passives, passive_global_cap, passive_ground_spawn_defs)
			end

			passive_spawn_timer = PASSIVE_INTERVAL
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
					-- timer expired -> check random despawn chance

					if math.random(1, 100) < (min_dist * min_dist) / 512 then
						self:kill_me("random chance at distance " .. math.round(min_dist))
						return true
					end

					-- survived despawn check -> fall through to refresh timer
				else
					-- timer not yet expired
					return false
				end

			end

			-- (re)set timer depending on light level
			if (minetest.get_node_light(pos) or minetest.LIGHT_MAX )< timer_light_level then
				self.lifetimer = timer_dark
			else
				self.lifetimer = timer_light
			end

			return false
		else
			-- too close -> disable timer
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

minetest.register_chatcommand("spawn_mob",{
	privs = { debug = true },
	description=S("spawn_mob is a chatcommand that allows you to type in the name of a mob without 'typing mobs_mc:' all the time like so; 'spawn_mob spider'. however, there is more you can do with this special command, currently you can edit any number, boolean, and string variable you choose with this format: spawn_mob 'any_mob:var<mobs_variable=variable_value>:'. any_mob being your mob of choice, mobs_variable being the variable, and variable value being the value of the chosen variable. and example of this format: \n spawn_mob skeleton:var<passive=true>:\n this would spawn a skeleton that wouldn't attack you. REMEMBER-THIS> when changing a number value always prefix it with 'NUM', example: \n spawn_mob skeleton:var<jump_height=NUM10>:\n this setting the skelly's jump height to 10. if you want to make multiple changes to a mob, you can, example: \n spawn_mob skeleton:var<passive=true>::var<jump_height=NUM10>::var<fly_in=air>::var<fly=true>:\n etc."),
	func = function(n,param)
		local pos = minetest.get_player_by_name(n):get_pos()

		local modifiers = {}
		for capture in string.gmatch(param, "%:(.-)%:") do
			table.insert(modifiers, ":"..capture)
		end

		local mod1 = string.find(param, ":")



		local mobname = param
		if mod1 then
			mobname = string.sub(param, 1, mod1-1)
		end

		local mob = mcl_mobs.spawn(pos, mobname, minetest.serialize({ persist_in_peaceful = true }))

		if mob then
			for c=1, #modifiers do
				local modifs = modifiers[c]

				local mod1 = string.find(modifs, ":")
				local mod_start = string.find(modifs, "<")
				local mod_vals = string.find(modifs, "=")
				local mod_end = string.find(modifs, ">")
				local mob_entity = mob:get_luaentity()
				if string.sub(modifs, mod1+1, mod1+3) == "var" then
					if mod1 and mod_start and mod_vals and mod_end then
						local variable = string.sub(modifs, mod_start+1, mod_vals-1)
						local value = string.sub(modifs, mod_vals+1, mod_end-1)

						local number_tag = string.find(value, "NUM")
						if number_tag then
							value = tonumber(string.sub(value, 4, -1)) ---@diagnostic disable-line: cast-local-type
						end

						if value == "true" then
							value = true ---@diagnostic disable-line: cast-local-type
						elseif value == "false" then
							value = false ---@diagnostic disable-line: cast-local-type
						end

						if not mob_entity[variable] then
							minetest.log("warning", n.." mob variable "..variable.." previously unset")
						end

						mob_entity[variable] = value

					else
						minetest.log("warning", n.." couldn't modify "..mobname.." at "..minetest.pos_to_string(pos).. ", missing paramaters")
					end
				else
					minetest.log("warning", n.." couldn't modify "..mobname.." at "..minetest.pos_to_string(pos).. ", missing modification type")
				end
			end

			minetest.log("action", n.." spawned "..mobname.." at "..minetest.pos_to_string(pos))
			return true, mobname.." spawned at "..minetest.pos_to_string(pos)
		else
			return false, "Couldn't spawn "..mobname
		end
	end
})
minetest.register_chatcommand("spawncheck",{
	privs = { debug = true },
	func = function(n,param)
		local pl = minetest.get_player_by_name(n)
		local pos = vector.offset(pl:get_pos(),0,-1,0)
		local dim = mcl_worlds.pos_to_dimension(pos)
		local sp
		for _,v in pairs(spawn_dictionary) do
			if v.name == param and v.dimension == dim then sp = v end
		end
		if sp then
			minetest.log(dump(sp))
			local r,t = spawn_check(pos,sp)
			if r then
				return true, "spawn check for "..sp.name.." at "..minetest.pos_to_string(pos).." successful"
			else
				return r,tostring(t) or ""
			end
		else
			return false,"no spawndef found for "..param
		end
	end
})

minetest.register_chatcommand("mobstats",{
	privs = { debug = true },
	func = function(n, _)
		minetest.chat_send_player(n,dump(dbg_spawn_counts))
		local pos = minetest.get_player_by_name(n):get_pos()
		minetest.chat_send_player(n,"mobs within 32 radius of player:"..count_mobs(pos,32))
		minetest.chat_send_player(n,"total mobs:"..count_mobs_total())
		minetest.chat_send_player(n,"spawning attempts since server start:"..dbg_spawn_attempts)
		minetest.chat_send_player(n,"successful spawns since server start:"..dbg_spawn_succ)


		local mob_counts, total_mobs = count_mobs_all()
		if (total_mobs) then
			minetest.log("action", "Total mobs found: " .. total_mobs)
		end
		if mob_counts then
			for k, v1 in pairs(mob_counts) do
				minetest.log("action", "k: " .. tostring(k))
				minetest.log("action", "v1: " .. tostring(v1))
			end
		end

	end
})
