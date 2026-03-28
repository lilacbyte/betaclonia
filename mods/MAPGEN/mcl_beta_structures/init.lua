local storage = minetest.get_mod_storage()
local world_seed = tonumber(minetest.get_mapgen_setting("seed")) or 0

mcl_beta_structures = rawget(_G, "mcl_beta_structures") or {}

local PYRAMID_REGION = 4000
local PYRAMID_HALF = 63
local PYRAMID_HEIGHT = 64
local PYRAMID_TOP_ABOVE_GROUND = 2
-- Beta 1.8.1 village grid: 32 chunks (=512 nodes), with 8-chunk margin.
local VILLAGE_REGION = 32 * 16
local VILLAGE_REGION_MARGIN = 8 * 16
local VILLAGE_CHANCE = 100
local VILLAGE_WORK_RADIUS = 52
local VILLAGE_WORK_DEPTH = 32
local VILLAGE_WORK_HEIGHT = 32
-- Beta MCP dungeon baseline: 8 generation attempts every chunk (no 1-in-4 pre-gate).
-- Here this maps to always-attempt behavior for each structure candidate.
local DUNGEON_LIKE_CHUNK_PROBABILITY = 1
local VILLAGE_GROUND_RULES = {
	min_coverage = 0.92,
	max_deviation = 3,
	min_flat_ratio = 0.8,
	max_range = 8,
}

local PYRAMID_SALT = 4101
local VILLAGE_SALT = 5107

local pending = {}
local api_registered_structures = {}

local LOCATABLE_STRUCTURES = {
	"brick_pyramid",
	"empty_village",
}

local STRUCTURE_DEFS = {
	brick_pyramid = {
		dimension = "overworld",
		region = PYRAMID_REGION,
		salt = PYRAMID_SALT,
		chance = 100,
	},
	empty_village = {
		dimension = "overworld",
		region = VILLAGE_REGION,
		salt = VILLAGE_SALT,
		chance = VILLAGE_CHANCE,
		margin = VILLAGE_REGION_MARGIN,
	},
}

local function choose_node(preferred, fallback)
	if minetest.registered_nodes[preferred] then
		return preferred
	end
	return fallback
end

local NODE = {
	air = "air",
	brick = choose_node("mcl_core:brick_block", "mcl_core:cobble"),
	cobble = choose_node("mcl_core:cobble", "mapgen_stone"),
	mossy = choose_node("mcl_core:mossycobble", "mcl_core:cobble"),
	planks = choose_node("mcl_trees:wood_oak", "mcl_core:wood"),
	log = choose_node("mcl_trees:tree_oak", "mcl_core:tree"),
	gravel = choose_node("mcl_core:gravel", "mcl_core:dirt"),
	cobweb = choose_node("mcl_core:cobweb", "air"),
	chest = choose_node("mcl_chests:chest", "air"),
	spawner = choose_node("mcl_mobspawners:spawner", "air"),
	water = choose_node("mcl_core:water_source", "air"),
}

-- Beta 1.8.1 village piece weights and bounding sizes (from MCP ComponentVillage*).
local VILLAGE_SCHEMATICS = {
	{ id = "house4_garden", kind = "house", weight = 4, width = 5, height = 6, depth = 5, wall = NODE.cobble, floor = NODE.cobble, roof = NODE.planks },
	{ id = "church", kind = "house", weight = 20, width = 5, height = 12, depth = 9, wall = NODE.cobble, floor = NODE.cobble, roof = NODE.cobble },
	{ id = "house1", kind = "house", weight = 20, width = 9, height = 9, depth = 6, wall = NODE.cobble, floor = NODE.planks, roof = NODE.planks },
	{ id = "wood_hut", kind = "house", weight = 3, width = 4, height = 6, depth = 5, wall = NODE.planks, floor = NODE.cobble, roof = NODE.log },
	{ id = "hall", kind = "house", weight = 15, width = 9, height = 7, depth = 11, wall = NODE.cobble, floor = NODE.planks, roof = NODE.planks },
	{ id = "field", kind = "field", weight = 3, width = 13, height = 4, depth = 9 },
	{ id = "field2", kind = "field", weight = 3, width = 7, height = 4, depth = 9 },
	{ id = "house2", kind = "house", weight = 15, width = 10, height = 6, depth = 7, wall = NODE.cobble, floor = NODE.planks, roof = NODE.cobble },
	{ id = "house3", kind = "house", weight = 8, width = 9, height = 7, depth = 12, wall = NODE.cobble, floor = NODE.planks, roof = NODE.planks },
}

local door_bottom = "mcl_doors:door_oak_b_1"
local door_top = "mcl_doors:door_oak_t_1"
if not minetest.registered_nodes[door_bottom] then
	door_bottom = "mcl_doors:door_wood_b_1"
	door_top = "mcl_doors:door_wood_t_1"
end

local function set_node(pos, name, param2)
	if not name or not minetest.registered_nodes[name] then
		return
	end
	local existing = minetest.get_node_or_nil(pos)
	if not existing or existing.name == "ignore" then
		return
	end
	minetest.set_node(pos, { name = name, param2 = param2 or 0 })
end

local function fill_box(p1, p2, name)
	for x = p1.x, p2.x do
		for y = p1.y, p2.y do
			for z = p1.z, p2.z do
				set_node({ x = x, y = y, z = z }, name)
			end
		end
	end
end

local function hollow_box(p1, p2, wall)
	for x = p1.x, p2.x do
		for y = p1.y, p2.y do
			for z = p1.z, p2.z do
				local edge = (x == p1.x or x == p2.x or y == p1.y or y == p2.y or z == p1.z or z == p2.z)
				set_node({ x = x, y = y, z = z }, edge and wall or NODE.air)
			end
		end
	end
end

local function line2d(x1, z1, x2, z2)
	local points = {}
	local dx = math.abs(x2 - x1)
	local dz = math.abs(z2 - z1)
	local sx = x1 < x2 and 1 or -1
	local sz = z1 < z2 and 1 or -1
	local err = dx - dz
	local x, z = x1, z1
	while true do
		table.insert(points, { x = x, z = z })
		if x == x2 and z == z2 then
			break
		end
		local e2 = err * 2
		if e2 > -dz then
			err = err - dz
			x = x + sx
		end
		if e2 < dx then
			err = err + dx
			z = z + sz
		end
	end
	return points
end

local function maybe_fill_chest(pos, pr)
	if NODE.chest == NODE.air then
		return
	end
	set_node(pos, NODE.chest)
	local def = minetest.registered_nodes[NODE.chest]
	if def and def.on_construct then
		def.on_construct(pos)
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv then
		return
	end
	local items = {
		"mcl_core:apple",
		"mcl_core:bread",
		"mcl_core:stick",
		"mcl_core:coal_lump",
		"mcl_core:torch 4",
	}
	for _ = 1, pr:next(2, 5) do
		inv:add_item("main", ItemStack(items[pr:next(1, #items)]))
	end
end

local function place_door(pos)
	if minetest.registered_nodes[door_bottom] and minetest.registered_nodes[door_top] then
		set_node(pos, door_bottom, 0)
		set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, door_top, 0)
	end
end

local function is_walkable(name)
	if name == "ignore" or name == "air" then
		return false
	end
	local def = minetest.registered_nodes[name]
	if not def or not def.walkable then
		return false
	end
	if def.liquidtype and def.liquidtype ~= "none" then
		return false
	end
	return true
end

local function node_groups(name)
	local def = minetest.registered_nodes[name]
	return (def and def.groups) or {}
end

local function is_foliage(name)
	local g = node_groups(name)
	if g.leaves or g.leafdecay or g.tree or g.log or g.sapling or g.flower
		or g.plant or g.vine or g.grass then
		return true
	end
	return name:find("leaves", 1, true) ~= nil
		or name:find("tree", 1, true) ~= nil
		or name:find("sapling", 1, true) ~= nil
end

local function is_surface_ground(name)
	return is_walkable(name) and not is_foliage(name)
end

local function is_open(name)
	if name == "air" then
		return true
	end
	local def = minetest.registered_nodes[name]
	if not def then
		return false
	end
	if def.liquidtype and def.liquidtype ~= "none" then
		return false
	end
	return not def.walkable
end

local function is_liquid(name)
	local def = minetest.registered_nodes[name]
	return def and def.liquidtype and def.liquidtype ~= "none"
end

local function is_replaceable_cover(name)
	if is_open(name) then
		return true
	end
	local def = minetest.registered_nodes[name]
	if def and def.buildable_to then
		return true
	end
	return is_foliage(name)
end

local function find_surface_y(x, z, miny, maxy)
	for y = maxy, miny, -1 do
		local here = minetest.get_node({ x = x, y = y, z = z }).name
		if is_surface_ground(here) then
			local above = minetest.get_node({ x = x, y = y + 1, z = z }).name
			if is_replaceable_cover(above) then
				return y
			end
		end
	end
	return nil
end

local function find_foundation_y(x, z, miny, maxy)
	for y = maxy, miny, -1 do
		if is_surface_ground(minetest.get_node({ x = x, y = y, z = z }).name) then
			return y
		end
	end
	return nil
end

local function floor_div(a, b)
	return math.floor(a / b)
end

local function rng_for_region(rx, rz, salt)
	local seed = minetest.hash_node_position({ x = rx, y = salt, z = rz }) + world_seed
	if seed == 0 then
		seed = salt + 1
	end
	return PcgRandom(seed, seed + salt * 97)
end

local function region_target(rx, rz, region_size, salt, margin)
	local pr = rng_for_region(rx, rz, salt)
	local edge = math.max(0, math.floor(margin or 0))
	local min_off = edge
	local max_off = region_size - 1 - edge
	if max_off < min_off then
		min_off = 0
		max_off = region_size - 1
	end
	local x = rx * region_size + pr:next(min_off, max_off)
	local z = rz * region_size + pr:next(min_off, max_off)
	return x, z, pr
end

local function region_roll_passes(pr, chance)
	if chance >= 100 then
		return true
	end
	return pr:next(1, 100) <= chance
end

local function chunk_probability_from_region(region_size, chance_percent)
	local chance = math.max(1, chance_percent or 100) / 100
	local expected_area = (region_size * region_size) / chance
	local expected_chunks = math.floor((expected_area / 256) + 0.5)
	return math.max(1, expected_chunks)
end

local function iterate_region_ring(rx0, rz0, ring, callback)
	local rx_min = rx0 - ring
	local rx_max = rx0 + ring
	local rz_min = rz0 - ring
	local rz_max = rz0 + ring
	for rx = rx_min, rx_max do
		for rz = rz_min, rz_max do
			if ring == 0
				or rx == rx_min or rx == rx_max
				or rz == rz_min or rz == rz_max then
				callback(rx, rz)
			end
		end
	end
end

local function locate_in_region_grid(pos, region_size, salt, chance, margin, max_rings)
	local rx0 = floor_div(pos.x, region_size)
	local rz0 = floor_div(pos.z, region_size)
	local best
	for ring = 0, max_rings do
		iterate_region_ring(rx0, rz0, ring, function(rx, rz)
			local x, z, pr = region_target(rx, rz, region_size, salt, margin)
			if not region_roll_passes(pr, chance) then
				return
			end
			local dx = x - pos.x
			local dz = z - pos.z
			local dist2 = dx * dx + dz * dz
			if (not best) or dist2 < best.dist2 then
				best = { x = x, z = z, dist2 = dist2 }
			end
		end)
	end
	return best
end

local function key_for(kind, rx, rz)
	return kind .. ":" .. rx .. ":" .. rz
end

local GENERATED_PREFIX = "generated:"
local GENERATED_LIST_LIMIT = 4096
local GENERATION_PROFILE_KEY = "generation_profile_version"
local GENERATION_PROFILE_VERSION = 4

local function generated_storage_key(struct_name)
	return GENERATED_PREFIX .. struct_name
end

local function migrate_generation_profile()
	if storage:get_int(GENERATION_PROFILE_KEY) >= GENERATION_PROFILE_VERSION then
		return
	end

	local t = storage:to_table()
	local fields = t and t.fields
	local removed = 0
	if type(fields) == "table" then
		for key, _ in pairs(fields) do
			if key:sub(1, 14) == "empty_village:"
				or key:sub(1, 14) == "brick_pyramid:" then
				fields[key] = nil
				removed = removed + 1
			end
		end
		fields[generated_storage_key("empty_village")] = nil
		fields[generated_storage_key("brick_pyramid")] = nil
		fields[GENERATION_PROFILE_KEY] = tostring(GENERATION_PROFILE_VERSION)
		storage:from_table(t)
	else
		storage:set_int(GENERATION_PROFILE_KEY, GENERATION_PROFILE_VERSION)
	end

	minetest.log("action", "[mcl_beta_structures] migration reset generation cache entries: " .. tostring(removed))
end

migrate_generation_profile()

local function resolved(key)
	return storage:get_int(key) ~= 0
end

local function mark_done(key)
	storage:set_int(key, 1)
end

local function mark_skipped(key)
	storage:set_int(key, 2)
end

local function load_generated_positions(struct_name)
	local s = storage:get_string(generated_storage_key(struct_name))
	if s == "" then
		return {}
	end
	local t = minetest.deserialize(s)
	if type(t) ~= "table" then
		return {}
	end
	return t
end

local function save_generated_positions(struct_name, positions)
	storage:set_string(generated_storage_key(struct_name), minetest.serialize(positions))
end

local function generated_chunk_key(pos)
	return floor_div(pos.x, 16) .. ":" .. floor_div(pos.z, 16)
end

local function record_generated_structure(struct_name, pos)
	local positions = load_generated_positions(struct_name)
	local key = generated_chunk_key(pos)
	for i = 1, #positions do
		if positions[i].k == key then
			return
		end
	end
	positions[#positions + 1] = { k = key, x = pos.x, y = pos.y, z = pos.z }
	if #positions > GENERATED_LIST_LIMIT then
		table.remove(positions, 1)
	end
	save_generated_positions(struct_name, positions)
end

local function locate_generated_structure(struct_name, pos)
	local positions = load_generated_positions(struct_name)
	local best
	for i = 1, #positions do
		local p = positions[i]
		local dx = p.x - pos.x
		local dz = p.z - pos.z
		local dist2 = dx * dx + dz * dz
		if (not best) or dist2 < best.dist2 then
			best = { x = p.x, y = p.y, z = p.z, dist2 = dist2 }
		end
	end
	return best
end

local structure_work_queue = {}
local structure_worker_running = false

local function run_next_structure_work()
	if structure_worker_running then
		return
	end
	if #structure_work_queue == 0 then
		return
	end
	structure_worker_running = true
	local job = table.remove(structure_work_queue, 1)
	minetest.after(0, function()
		local ok = job.fn()
		if ok then
			mark_done(job.key)
		end
		pending[job.key] = nil
		structure_worker_running = false
		run_next_structure_work()
	end)
end

local function enqueue_structure_work(key, fn)
	structure_work_queue[#structure_work_queue + 1] = {
		key = key,
		fn = fn,
	}
	run_next_structure_work()
end

local function with_emerged(key, p1, p2, fn)
	if pending[key] then
		return
	end
	pending[key] = true
	minetest.emerge_area(p1, p2, function(_, _, calls_remaining)
		if calls_remaining > 0 then
			return
		end
		enqueue_structure_work(key, fn)
	end)
end

local function place_brick_pyramid(center, pr)
	-- Keep only the tip above terrain so most of the pyramid is buried.
	local top_y = (center.y or 1) + PYRAMID_TOP_ABOVE_GROUND
	local base_y = top_y - (PYRAMID_HEIGHT - 1)
	local p1 = {
		x = center.x - PYRAMID_HALF,
		y = base_y,
		z = center.z - PYRAMID_HALF,
	}
	local p2 = {
		x = center.x + PYRAMID_HALF,
		y = top_y,
		z = center.z + PYRAMID_HALF,
	}

	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(p1, p2)
	local area = VoxelArea:new({ MinEdge = emin, MaxEdge = emax })
	local data = vm:get_data()
	local c_brick = minetest.get_content_id(NODE.brick)

	for y = 0, PYRAMID_HEIGHT - 1 do
		local yy = base_y + y
		local r = PYRAMID_HALF - y
		for z = center.z - r, center.z + r do
			local vi = area:index(center.x - r, yy, z)
			for _ = center.x - r, center.x + r do
				data[vi] = c_brick
				vi = vi + 1
			end
		end
	end

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
	return true
end

local function pick_weighted_schematic(pr, defs)
	local total = 0
	for i = 1, #defs do
		total = total + defs[i].weight
	end
	if total <= 0 then
		return defs[1]
	end
	local roll = pr:next(1, total)
	local acc = 0
	for i = 1, #defs do
		acc = acc + defs[i].weight
		if roll <= acc then
			return defs[i]
		end
	end
	return defs[#defs]
end

local function schematic_half_extents(def)
	local hx0 = math.floor((def.width - 1) / 2)
	local hz0 = math.floor((def.depth - 1) / 2)
	local hx1 = def.width - 1 - hx0
	local hz1 = def.depth - 1 - hz0
	return hx0, hx1, hz0, hz1
end

local function schematic_bbox_2d(pos, def, pad)
	local hx0, hx1, hz0, hz1 = schematic_half_extents(def)
	local p = pad or 0
	return {
		minx = pos.x - hx0 - p,
		maxx = pos.x + hx1 + p,
		minz = pos.z - hz0 - p,
		maxz = pos.z + hz1 + p,
	}
end

local function bbox_overlaps_2d(a, b)
	return not (a.maxx < b.minx or a.minx > b.maxx or a.maxz < b.minz or a.minz > b.maxz)
end

local function evaluate_ground_footprint(x0, x1, z0, z1, miny, maxy, rules)
	local total = (x1 - x0 + 1) * (z1 - z0 + 1)
	if total <= 0 then
		return nil
	end

	local heights = {}
	local min_h
	local max_h
	for x = x0, x1 do
		for z = z0, z1 do
			local y = find_surface_y(x, z, miny, maxy)
			if y then
				local above = minetest.get_node({ x = x, y = y + 1, z = z }).name
				if is_liquid(above) then
					return nil
				end
				heights[#heights + 1] = y
				if (not min_h) or y < min_h then
					min_h = y
				end
				if (not max_h) or y > max_h then
					max_h = y
				end
			end
		end
	end

	local min_coverage = rules.min_coverage or 1
	local min_solid = math.max(1, math.floor(total * min_coverage + 0.5))
	if #heights < min_solid then
		return nil
	end
	if (max_h - min_h) > (rules.max_range or 8) then
		return nil
	end

	table.sort(heights)
	local median = heights[math.floor((#heights + 1) / 2)]
	local max_deviation = rules.max_deviation or 3
	local flat_count = 0
	for i = 1, #heights do
		if math.abs(heights[i] - median) <= max_deviation then
			flat_count = flat_count + 1
		end
	end
	local min_flat_ratio = rules.min_flat_ratio or 1
	local min_flat = math.max(1, math.floor(#heights * min_flat_ratio + 0.5))
	if flat_count < min_flat then
		return nil
	end

	return median
end

local function reinforce_foundation(x0, x1, z0, z1, top_y, material, max_depth)
	local depth = max_depth or 20
	for x = x0, x1 do
		for z = z0, z1 do
			for y = top_y - 1, top_y - depth, -1 do
				local pos = { x = x, y = y, z = z }
				local name = minetest.get_node(pos).name
				if is_surface_ground(name) then
					break
				end
				set_node(pos, material)
			end
		end
	end
end

local function place_village_well(center)
	reinforce_foundation(center.x - 2, center.x + 2, center.z - 2, center.z + 2, center.y, NODE.cobble, 20)

	fill_box(
		{x = center.x - 2, y = center.y, z = center.z - 2},
		{x = center.x + 2, y = center.y, z = center.z + 2},
		NODE.cobble
	)
	fill_box(
		{x = center.x, y = center.y, z = center.z},
		{x = center.x + 1, y = center.y, z = center.z + 1},
		NODE.water
	)
	for _, o in ipairs({
		{ x = -2, z = -2 }, { x = -2, z = 2 }, { x = 2, z = -2 }, { x = 2, z = 2 },
	}) do
		fill_box(
			{x = center.x + o.x, y = center.y + 1, z = center.z + o.z},
			{x = center.x + o.x, y = center.y + 3, z = center.z + o.z},
			NODE.log
		)
	end
	fill_box(
		{x = center.x - 2, y = center.y + 4, z = center.z - 2},
		{x = center.x + 2, y = center.y + 4, z = center.z + 2},
		NODE.planks
	)
end

local function place_village_house_schematic(center, def, pr, ruined, with_spawner)
	local y = center.y
	local hx0, hx1, hz0, hz1 = schematic_half_extents(def)
	local wall_h = math.max(3, def.height - 2)
	local x0 = center.x - hx0
	local x1 = center.x + hx1
	local z0 = center.z - hz0
	local z1 = center.z + hz1

	reinforce_foundation(x0, x1, z0, z1, y, def.floor, 24)

	fill_box(
		{x = x0, y = y, z = z0},
		{x = x1, y = y, z = z1},
		def.floor
	)

	for ly = y + 1, y + wall_h do
		for x = x0, x1 do
			for z = z0, z1 do
				local edge = (x == x0 or x == x1 or z == z0 or z == z1)
				if edge then
					local corner = (x == x0 or x == x1) and (z == z0 or z == z1)
					set_node({ x = x, y = ly, z = z }, corner and NODE.log or def.wall)
				else
					set_node({ x = x, y = ly, z = z }, NODE.air)
				end
			end
		end
	end

	fill_box(
		{x = x0 - 1, y = y + wall_h + 1, z = z0 - 1},
		{x = x1 + 1, y = y + wall_h + 1, z = z1 + 1},
		def.roof
	)

	local door_x = center.x
	local door_z = center.z + hz1
	set_node({ x = door_x, y = y + 1, z = door_z }, NODE.air)
	set_node({ x = door_x, y = y + 2, z = door_z }, NODE.air)
	place_door({ x = door_x, y = y + 1, z = door_z })

	set_node({ x = center.x - hx0, y = y + 2, z = center.z }, NODE.air)
	set_node({ x = center.x + hx1, y = y + 2, z = center.z }, NODE.air)

	if ruined then
		local webs = math.max(6, math.floor((def.width * def.depth) / 5))
		for _ = 1, webs do
			local wx = pr:next(x0 + 1, x1 - 1)
			local wy = pr:next(y + 1, y + wall_h)
			local wz = pr:next(z0 + 1, z1 - 1)
			set_node({ x = wx, y = wy, z = wz }, NODE.cobweb)
		end
		for _ = 1, pr:next(2, 6) do
			local rx = pr:next(x0, x1)
			local rz = pr:next(z0, z1)
			set_node({ x = rx, y = y + wall_h + 1, z = rz }, NODE.air)
		end
		if with_spawner and NODE.spawner ~= NODE.air then
			local sp = { x = center.x, y = y + 1, z = center.z }
			set_node(sp, NODE.spawner)
			if mcl_mobspawners and mcl_mobspawners.setup_spawner then
				mcl_mobspawners.setup_spawner(sp, "mobs_mc:zombie", 0, 7, 4, 16, 0)
			end
		end
	elseif pr:next(1, 100) <= 25 then
		maybe_fill_chest({ x = x0 + 1, y = y + 1, z = z0 + 1 }, pr)
	end
end

local function place_village_field_schematic(center, def, pr)
	local y = center.y
	local hx0, hx1, hz0, hz1 = schematic_half_extents(def)
	local x0 = center.x - hx0
	local x1 = center.x + hx1
	local z0 = center.z - hz0
	local z1 = center.z + hz1

	reinforce_foundation(x0, x1, z0, z1, y, NODE.gravel, 16)

	fill_box(
		{x = x0, y = y, z = z0},
		{x = x1, y = y, z = z1},
		NODE.gravel
	)
	fill_box(
		{x = x0, y = y, z = z0},
		{x = x1, y = y, z = z0},
		NODE.log
	)
	fill_box(
		{x = x0, y = y, z = z1},
		{x = x1, y = y, z = z1},
		NODE.log
	)
	fill_box(
		{x = x0, y = y, z = z0},
		{x = x0, y = y, z = z1},
		NODE.log
	)
	fill_box(
		{x = x1, y = y, z = z0},
		{x = x1, y = y, z = z1},
		NODE.log
	)

	local water_x = center.x
	fill_box(
		{x = water_x, y = y, z = z0 + 1},
		{x = water_x, y = y, z = z1 - 1},
		NODE.water
	)
	for x = x0 + 1, x1 - 1 do
		if x ~= water_x then
			for z = z0 + 1, z1 - 1 do
				set_node({ x = x, y = y, z = z }, NODE.gravel)
				if pr:next(1, 100) <= 10 then
					set_node({ x = x, y = y + 1, z = z }, NODE.cobweb)
				end
			end
		end
	end
end

local function spawn_ocelots_for_village(center, pr)
	if not minetest.registered_entities["mobs_mc:ocelot"] then
		return
	end
	local rng = pr or PcgRandom(minetest.hash_node_position(center), world_seed)
	local spawned = 0
	for _ = 1, 10 do
		if spawned >= 2 then
			break
		end
		local ox = center.x + rng:next(-18, 18)
		local oz = center.z + rng:next(-18, 18)
		local y = find_surface_y(ox, oz, center.y - 12, center.y + 12)
		if y then
			local ground = minetest.get_node({ x = ox, y = y, z = oz }).name
			local above = minetest.get_node({ x = ox, y = y + 1, z = oz }).name
			if is_surface_ground(ground) and is_open(above) and not is_liquid(ground) then
				local obj = minetest.add_entity({ x = ox, y = y + 1, z = oz }, "mobs_mc:ocelot")
				if obj then
					spawned = spawned + 1
				end
			end
		end
	end
end

local function place_empty_village(center, pr)
	local well_y = evaluate_ground_footprint(
		center.x - 2,
		center.x + 2,
		center.z - 2,
		center.z + 2,
		center.y - 14,
		center.y + 14,
		VILLAGE_GROUND_RULES
	)
	if not well_y then
		return false
	end
	center.y = well_y + 1
	place_village_well(center)

	local piece_count = pr:next(7, 12)
	local pieces = {}
	local boxes = {}
	local house_pieces = {}

	for _ = 1, piece_count do
		local def = pick_weighted_schematic(pr, VILLAGE_SCHEMATICS)
		for _ = 1, 10 do
			local angle = (pr:next(0, 359) / 180) * math.pi
			local radius = pr:next(16, 36)
			local px = center.x + math.floor(math.cos(angle) * radius)
			local pz = center.z + math.floor(math.sin(angle) * radius)
			local bb = schematic_bbox_2d({ x = px, z = pz }, def, 3)
			local collides = false
			for i = 1, #boxes do
				if bbox_overlaps_2d(bb, boxes[i]) then
					collides = true
					break
				end
			end
			if not collides then
				local py = evaluate_ground_footprint(
					bb.minx,
					bb.maxx,
					bb.minz,
					bb.maxz,
					center.y - 16,
					center.y + 16,
					VILLAGE_GROUND_RULES
				)
				if py then
					local piece = {
						def = def,
						pos = { x = px, y = py + 1, z = pz },
					}
					pieces[#pieces + 1] = piece
					boxes[#boxes + 1] = bb
					if def.kind == "house" then
						house_pieces[#house_pieces + 1] = piece
					end
					break
				end
			end
		end
	end

	local ruined_piece = nil
	if #house_pieces > 0 then
		ruined_piece = house_pieces[pr:next(1, #house_pieces)]
	end
	local ruined_has_spawner = pr:next(1, 100) <= 45

	for i = 1, #pieces do
		local piece = pieces[i]
		if piece.def.kind == "field" then
			place_village_field_schematic(piece.pos, piece.def, pr)
		else
			local ruined = (piece == ruined_piece)
			place_village_house_schematic(piece.pos, piece.def, pr, ruined, ruined and ruined_has_spawner)
		end
	end

	for i = 1, #pieces do
		local hp = pieces[i].pos
		for _, pt in ipairs(line2d(center.x, center.z, hp.x, hp.z)) do
			local py = find_surface_y(pt.x, pt.z, center.y - 12, center.y + 12)
			if py then
				set_node({ x = pt.x, y = py, z = pt.z }, NODE.gravel)
			end
		end
	end
	spawn_ocelots_for_village(center, pr)
	return true
end

local function structure_bounds(struct_name, center)
	if struct_name == "brick_pyramid" then
		local top_y = (center.y or 1) + PYRAMID_TOP_ABOVE_GROUND
		local base_y = top_y - (PYRAMID_HEIGHT - 1)
		return {
			x = center.x - PYRAMID_HALF,
			y = base_y,
			z = center.z - PYRAMID_HALF,
		}, {
			x = center.x + PYRAMID_HALF,
			y = top_y,
			z = center.z + PYRAMID_HALF,
		}
	end
	if struct_name == "empty_village" then
		return {
			x = center.x - VILLAGE_WORK_RADIUS,
			y = center.y - VILLAGE_WORK_DEPTH,
			z = center.z - VILLAGE_WORK_RADIUS,
		}, {
			x = center.x + VILLAGE_WORK_RADIUS,
			y = center.y + VILLAGE_WORK_HEIGHT,
			z = center.z + VILLAGE_WORK_RADIUS,
		}
	end
	return {
		x = center.x - 16,
		y = center.y - 16,
		z = center.z - 16,
	}, {
		x = center.x + 16,
		y = center.y + 16,
		z = center.z + 16,
	}
end

local function chunk_contains(minp, maxp, x, z)
	return x >= minp.x and x <= maxp.x and z >= minp.z and z <= maxp.z
end

local function try_region_grid(minp, maxp, kind, region_size, chance, salt, try_place_fn)
	local margin = 0
	local def = STRUCTURE_DEFS[kind]
	if def and def.margin then
		margin = def.margin
	end
	local rx_min = floor_div(minp.x, region_size)
	local rx_max = floor_div(maxp.x, region_size)
	local rz_min = floor_div(minp.z, region_size)
	local rz_max = floor_div(maxp.z, region_size)

	for rx = rx_min, rx_max do
		for rz = rz_min, rz_max do
			local tx, tz, pr = region_target(rx, rz, region_size, salt, margin)
			if chunk_contains(minp, maxp, tx, tz) then
				local key = key_for(kind, rx, rz)
				if (not resolved(key)) and (not pending[key]) then
					if chance < 100 and pr:next(1, 100) > chance then
						mark_skipped(key)
					else
						try_place_fn(key, tx, tz, pr)
					end
				end
			end
		end
	end
end

local function is_dimension(minp, maxp, dim)
	local mid = { x = minp.x, y = math.floor((minp.y + maxp.y) / 2), z = minp.z }
	return mcl_worlds.pos_to_dimension(mid) == dim
end

local function try_place_pyramid(minp, maxp, key, x, z, pr)
	local y = find_surface_y(x, z, minp.y, maxp.y)
	if not y then
		return
	end
	local center = { x = x, y = y + 1, z = z }
	local p1, p2 = structure_bounds("brick_pyramid", center)
	with_emerged(key, p1, p2, function()
		local placed = place_brick_pyramid(center, pr)
		if placed then
			record_generated_structure("brick_pyramid", center)
		end
		return placed
	end)
end

local function try_place_village(minp, maxp, key, x, z, pr)
	local y = find_surface_y(x, z, minp.y, maxp.y)
	if not y then
		return
	end
	local center = { x = x, y = y + 1, z = z }
	local p1, p2 = structure_bounds("empty_village", center)
	with_emerged(key, p1, p2, function()
		local placed = place_empty_village(center, pr)
		if placed then
			record_generated_structure("empty_village", center)
		end
		return placed
	end)
end

local function guess_structure_y(struct_name, x, z)
	return (minetest.get_spawn_level(x, z) or 0) + 1
end

function mcl_beta_structures.get_locatable_structures()
	local out = {}
	for i = 1, #LOCATABLE_STRUCTURES do
		out[i] = LOCATABLE_STRUCTURES[i]
	end
	return out
end

-- Returns result table or nil,error[,extra].
-- Result table: {name, x, y, z, distance}
function mcl_beta_structures.locate_structure(name, pos, max_rings)
	local def = STRUCTURE_DEFS[name]
	if not def then
		return nil, "unknown_structure"
	end

	local dim = mcl_worlds.pos_to_dimension(pos)
	if def.dimension and dim ~= def.dimension then
		return nil, "wrong_dimension", def.dimension
	end

	local found = locate_in_region_grid(pos, def.region, def.salt, def.chance, def.margin, max_rings or 256)
	if not found then
		return nil, "not_found"
	end
	local x = found.x
	local z = found.z
	local y = guess_structure_y(name, x, z)

	local dx = x - pos.x
	local dz = z - pos.z
	return {
		name = name,
		x = x,
		y = y,
		z = z,
		distance = math.floor(math.sqrt(dx * dx + dz * dz) + 0.5),
	}
end

local function register_mcl_structure_defs()
	if not mcl_structures or not mcl_structures.register_structure then
		minetest.log("warning", "[mcl_beta_structures] mcl_structures API not available; beta structures will not auto-generate.")
		return
	end

	local function register_spawn_alias(alias_name, source_def)
		if not alias_name or not source_def then
			return
		end
		-- Alias registrations are spawn-only so they show up in /spawnstruct
		-- without adding extra mapgen decorations.
		if mcl_structures.registered_structures and mcl_structures.registered_structures[alias_name] then
			return
		end
		local alias_def = table.copy(source_def)
		mcl_structures.register_structure(alias_name, alias_def, true)
	end

	local pyramid_def = {
		place_on = {"group:solid"},
		flags = "place_center_x, place_center_z",
		chunk_probability = DUNGEON_LIKE_CHUNK_PROBABILITY,
		y_min = 1,
		y_max = (mcl_vars and mcl_vars.mg_overworld_max) or 256,
		on_place = function(pos)
			return mcl_worlds.pos_to_dimension(pos) == "overworld"
		end,
		place_func = function(pos, _, pr)
			return place_brick_pyramid(pos, pr)
		end,
	}
	mcl_structures.register_structure("brick_pyramid", pyramid_def)
	api_registered_structures[#api_registered_structures + 1] = pyramid_def
	register_spawn_alias("mcl_beta_structure", pyramid_def)
	register_spawn_alias("mcl_beta-structure", pyramid_def)
	register_spawn_alias("mcl_beta_pyramid", pyramid_def)
	register_spawn_alias("mcl_beta_structures", pyramid_def)
	register_spawn_alias("mtl_beta_structure", pyramid_def)
	register_spawn_alias("mtl_beta-structure", pyramid_def)
	register_spawn_alias("mtl_beta_pyramid", pyramid_def)
	register_spawn_alias("mtl_beta_structures", pyramid_def)

	local village_def = {
		place_on = {"group:solid"},
		flags = "place_center_x, place_center_z",
		chunk_probability = DUNGEON_LIKE_CHUNK_PROBABILITY,
		y_min = 1,
		y_max = (mcl_vars and mcl_vars.mg_overworld_max) or 256,
		on_place = function(pos)
			return mcl_worlds.pos_to_dimension(pos) == "overworld"
		end,
		place_func = function(pos, _, pr)
			return place_empty_village(vector.new(pos), pr)
		end,
	}
	mcl_structures.register_structure("empty_village", village_def)
	api_registered_structures[#api_registered_structures + 1] = village_def
	register_spawn_alias("mcl_beta_empty_village", village_def)
	register_spawn_alias("mtl_beta_empty_village", village_def)
end

local function beta_structures_from_mcl_notify(_, _, _)
	-- `get_mapgen_object("voxelmanip")` returns vm, emin, emax. We only need bounds.
	local _, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local minp, maxp = emin, emax
	if not minp or not maxp then
		return
	end
	if not is_dimension(minp, maxp, "overworld") then
		return
	end

	try_region_grid(minp, maxp, "brick_pyramid", PYRAMID_REGION, 100, PYRAMID_SALT, function(key, x, z, pr)
		try_place_pyramid(minp, maxp, key, x, z, pr)
	end)

	try_region_grid(minp, maxp, "empty_village", VILLAGE_REGION, VILLAGE_CHANCE, VILLAGE_SALT, function(key, x, z, pr)
		try_place_village(minp, maxp, key, x, z, pr)
	end)
end

register_mcl_structure_defs()
mcl_mapgen_core.register_generator("mcl_beta_structures", nil, beta_structures_from_mcl_notify, 999990, false, true)
