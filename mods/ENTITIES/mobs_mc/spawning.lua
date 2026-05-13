-------------------------------------------------------------------------
-- Shared mob spawning helpers.
--
-- This keeps the mob-side spawning metadata in one place so the legacy
-- spawn_setup blocks can be migrated incrementally toward the mineclonia
-- style spawner tables.
-------------------------------------------------------------------------

local S = minetest.get_translator("mobs_mc")
local only_peaceful_mobs = minetest.settings:get_bool("only_peaceful_mobs", false)

mobs_mc.overworld_biomes = {
	"BambooJungle",
	"Beach",
	"BirchForest",
	"CherryGrove",
	"DarkForest",
	"DeepColdOcean",
	"DeepFrozenOcean",
	"DeepLukewarmOcean",
	"DeepOcean",
	"Desert",
	"DripstoneCaves",
	"ErodedMesa",
	"FlowerForest",
	"Forest",
	"FrozenOcean",
	"FrozenPeaks",
	"FrozenRiver",
	"Grove",
	"IceSpikes",
	"JaggedPeaks",
	"Jungle",
	"LukewarmOcean",
	"LushCaves",
	"MangroveSwamp",
	"Meadow",
	"Mesa",
	"MushroomIslands",
	"Ocean",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"River",
	"Savannah",
	"SavannahPlateau",
	"SnowyBeach",
	"SnowyPlains",
	"SnowySlopes",
	"SnowyTaiga",
	"SparseJungle",
	"StonyPeaks",
	"StonyShore",
	"SunflowerPlains",
	"Swamp",
	"Taiga",
	"WarmOcean",
	"WindsweptForest",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
	"WoodedMesa",
}

mobs_mc.farm_animal_biomes = {
	"BambooJungle",
	"BirchForest",
	"CherryGrove",
	"DarkForest",
	"FlowerForest",
	"Forest",
	"Jungle",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"SavannahPlateau",
	"Savannah",
	"SnowyTaiga",
	"SparseJungle",
	"SunflowerPlains",
	"Swamp",
	"Taiga",
	"WindsweptForest",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
}

mobs_mc.monster_biomes = {
	"BambooJungle",
	"Beach",
	"BirchForest",
	"CherryGrove",
	"ColdOcean",
	"DarkForest",
	"DeepColdOcean",
	"DeepFrozenOcean",
	"DeepLukewarmOcean",
	"DeepOcean",
	"Desert",
	"DripstoneCaves",
	"ErodedMesa",
	"FlowerForest",
	"Forest",
	"FrozenOcean",
	"FrozenPeaks",
	"FrozenRiver",
	"Grove",
	"IceSpikes",
	"JaggedPeaks",
	"Jungle",
	"LukewarmOcean",
	"LushCaves",
	"MangroveSwamp",
	"Meadow",
	"Mesa",
	"Ocean",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"River",
	"Savannah",
	"SavannahPlateau",
	"SnowyBeach",
	"SnowyPlains",
	"SnowySlopes",
	"StonyPeaks",
	"StonyShore",
	"SunflowerPlains",
	"Swamp",
	"Taiga",
	"WarmOcean",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
	"WoodedMesa",
}

local function in_group(node_name, group)
	return minetest.get_item_group(node_name, group) > 0
end

local function default_get_node(node_cache, y_offset, base)
	local cache = node_cache[y_offset]
	if cache then
		return cache
	end
	local pos = vector.new(base)
	pos.y = pos.y + y_offset
	cache = minetest.get_node(pos)
	node_cache[y_offset] = cache
	return cache
end

local default_spawner = {
	weight = 100,
	biomes = {},
	structures = {},
	despawn_distance_sqr = 128 * 128,
	spawn_placement = "ground",
	spawn_category = "misc",
	fire_immune = false,
	pack_min = 4,
	pack_max = 4,
	is_canonical = false,
}

function default_spawner:is_valid_spawn_ceiling(name)
	local def = minetest.registered_nodes[name]
	if name == "ignore"
		or not def
		or def.walkable
		or def.liquidtype ~= "none"
		or (def.groups.no_spawning_inside and def.groups.no_spawning_inside ~= 0)
		or (def.damage_per_second > 0)
		or (not self.fire_immune and def.groups.fire and def.groups.fire ~= 0)
		or (not self.fire_immune and def.groups.lava and def.groups.lava ~= 0) then
		return false
	end
	return true
end

function default_spawner:get_node(node_cache, y_offset, base)
	return default_get_node(node_cache, y_offset, base)
end

function default_spawner:test_spawn_position(spawn_pos, node_pos, sdata, node_cache, spawn_flag)
	local spawn_placement = self.spawn_placement
	if spawn_placement == "misc" then
		return true
	end

	if spawn_placement == "ground" then
		local node_below = default_get_node(node_cache, -1, node_pos)
		if not node_below or node_below.name == "ignore" then
			return false
		end
		if minetest.get_item_group(node_below.name, "opaque") <= 0 and node_below.name ~= "mcl_core:bedrock" then
			return false
		end
		local here = default_get_node(node_cache, 0, node_pos)
		local above = default_get_node(node_cache, 1, node_pos)
		return default_spawner.is_valid_spawn_ceiling(self, here.name)
			and default_spawner.is_valid_spawn_ceiling(self, above.name)
	end

	if spawn_placement == "aquatic" then
		local node = default_get_node(node_cache, 0, node_pos)
		if minetest.get_item_group(node.name, "water") <= 0 then
			return false
		end
		local above = default_get_node(node_cache, 1, node_pos)
		return minetest.get_item_group(above.name, "opaque") <= 0
	end

	if spawn_placement == "lava" then
		local node = default_get_node(node_cache, 0, node_pos)
		return minetest.get_item_group(node.name, "lava") > 0
	end

	return false
end

function default_spawner:test_spawn_clearance(spawn_pos, sdata)
	local mob_def = minetest.registered_entities[self.name]
	if not mob_def then
		return false
	end
	local cbox = mob_def.initial_properties and mob_def.initial_properties.collisionbox
	if not cbox then
		return false
	end

	local p1 = {
		x = spawn_pos.x + cbox[1] + 0.01,
		y = spawn_pos.y + cbox[2] + 0.01,
		z = spawn_pos.z + cbox[3] + 0.01,
	}
	local p2 = {
		x = spawn_pos.x + cbox[4] - 0.01,
		y = spawn_pos.y + cbox[5] - 0.01,
		z = spawn_pos.z + cbox[6] - 0.01,
	}

	local xmin = math.floor(p1.x + 0.5)
	local ymin = math.floor(p1.y + 0.5)
	local zmin = math.floor(p1.z + 0.5)
	local xmax = math.floor(p2.x + 0.5)
	local ymax = math.floor(p2.y + 0.5)
	local zmax = math.floor(p2.z + 0.5)

	for z = zmin, zmax do
		for x = xmin, xmax do
			for y = ymin, ymax do
				local node = minetest.get_node({x = x, y = y, z = z})
				if node.name ~= "air" and node.name ~= "ignore" then
					local def = minetest.registered_nodes[node.name]
					if def and (def.walkable or def.liquidtype ~= "none") then
						return false
					end
				end
			end
		end
	end
	return true
end

function default_spawner:spawn(spawn_pos, idx, sdata, pack_size)
	local staticdata = sdata and minetest.serialize(sdata)
	return minetest.add_entity(spawn_pos, self.name, staticdata)
end

function default_spawner:describe_mob_collision_box()
	local mob_def = minetest.registered_entities[self.name]
	if not mob_def then
		return false
	end
	local cbox = mob_def.initial_properties and mob_def.initial_properties.collisionbox
	if not cbox then
		return false
	end
	return string.format("%.2f,%.2f,%.2f", cbox[4] - cbox[1], cbox[5] - cbox[2], cbox[6] - cbox[3])
end

function default_spawner:get_misc_spawning_description()
	return nil
end

function default_spawner:describe_additional_spawning_criteria()
	return nil
end

function default_spawner:describe_criteria(tbl, omit_group_details)
	local tbl1 = {}
	local desc = self.get_misc_spawning_description and self.get_misc_spawning_description(self)
	if desc then
		tbl1[#tbl1 + 1] = desc
	elseif self.spawn_placement == "ground" then
		tbl1[#tbl1 + 1] = S("This mob will spawn on solid and opaque nodes with a surface occupying a full node.")
	elseif self.spawn_placement == "aquatic" then
		tbl1[#tbl1 + 1] = S("This mob will spawn in water when the node above is not opaque.")
	elseif self.spawn_placement == "lava" then
		tbl1[#tbl1 + 1] = S("This mob will spawn in lava.")
	else
		tbl1[#tbl1 + 1] = S("This mob does not document its spawning requirements.")
	end

	local addendum = self.describe_additional_spawning_criteria and self.describe_additional_spawning_criteria(self)
	if addendum then
		tbl1[#tbl1 + 1] = addendum
	end

	if not omit_group_details then
		if self.pack_min == 1 and self.pack_max == 1 then
			tbl1[#tbl1 + 1] = S("Mobs will spawn in individual groups of 1.")
		elseif self.pack_min == self.pack_max then
			tbl1[#tbl1 + 1] = S("Up to @1 mobs will spawn as a single group.", self.pack_min)
		else
			tbl1[#tbl1 + 1] = S("A group of @1 to @2 mobs will attempt to spawn.", self.pack_min, self.pack_max)
		end
	end

	table.insert(tbl, table.concat(tbl1, "  "))
end

local function spawn_placement_to_type(spawn_placement)
	if spawn_placement == "aquatic" then
		return "water"
	elseif spawn_placement == "lava" then
		return "lava"
	end
	return "ground"
end

function mcl_mobs.register_spawner(spawner)
	if not spawner or not spawner.name then
		return
	end

	local def = {
		name = spawner.name,
		dimension = spawner.dimension or "overworld",
		type_of_spawning = spawn_placement_to_type(spawner.spawn_placement),
		pack_min = spawner.pack_min,
		pack_max = spawner.pack_max,
		min_light = spawner.min_light,
		max_light = spawner.max_light,
		min_height = spawner.min_height,
		max_height = spawner.max_height,
		aoc = spawner.aoc,
		chance = spawner.chance or math.max(1, math.floor(8000 / (spawner.weight or 100))),
		biomes = spawner.biomes,
		biomes_except = spawner.biomes_except,
		prepare_to_spawn = spawner.prepare_to_spawn,
		spawn = spawner.spawn,
		check_position = function(pos)
			if spawner.test_spawn_position then
				local node_pos = vector.new(pos)
				local ok = spawner:test_spawn_position(pos, node_pos, nil, {}, nil)
				return ok == true
			end
			return true
		end,
	}

	mcl_mobs.spawn_setup(def)
end

mcl_mobs.default_spawner = default_spawner
mobs_mc.default_spawner = default_spawner

local function make_spawn_table(base)
	return setmetatable(table.copy(base), { __index = default_spawner })
end

local animal_spawner = make_spawn_table({
	spawn_category = "creature",
	spawn_placement = "ground",
})

function animal_spawner:test_supporting_node(node)
	return minetest.get_item_group(node.name, "grass_block") > 0
end

function animal_spawner:describe_supporting_nodes()
	return S("on grass nodes")
end

function animal_spawner:get_misc_spawning_description()
	return S("This mob will spawn infrequently on grass nodes when no obstructions exist around the surface.")
end

function animal_spawner:test_spawn_position(spawn_pos, node_pos, sdata, node_cache, spawn_flag)
	local node_below = default_get_node(node_cache, -1, node_pos)
	if animal_spawner.test_supporting_node(self, node_below) then
		return default_spawner.test_spawn_position(self, spawn_pos, node_pos, sdata, node_cache, spawn_flag)
	end
	return false
end

mobs_mc.animal_spawner = animal_spawner

local aquatic_animal_spawner = make_spawn_table({
	spawn_category = "water_ambient",
	spawn_placement = "aquatic",
})

function aquatic_animal_spawner:get_misc_spawning_description()
	return S("This mob will spawn in water between sea level and shallow depths when the surrounding fluid nodes are water.")
end

function aquatic_animal_spawner:test_spawn_position(spawn_pos, node_pos, sdata, node_cache, spawn_flag)
	if spawn_pos.y > 0.5 or spawn_pos.y < -12.5 then
		return false
	end
	local node_below = default_get_node(node_cache, -1, node_pos)
	local node_above = default_get_node(node_cache, 1, node_pos)
	if minetest.get_item_group(node_below.name, "water") > 0
		and minetest.get_item_group(node_above.name, "water") > 0 then
		return default_spawner.test_spawn_position(self, spawn_pos, node_pos, sdata, node_cache, spawn_flag)
	end
	return false
end

mobs_mc.aquatic_animal_spawner = aquatic_animal_spawner

local monster_spawner = make_spawn_table({
	spawn_placement = "ground",
	spawn_category = "monster",
	pack_min = 4,
	pack_max = 4,
	max_artificial_light = 0,
	max_light = 6,
})

function monster_spawner:test_spawn_position(spawn_pos, node_pos, sdata, node_cache, spawn_flag)
	if only_peaceful_mobs then
		return false
	end
	return default_spawner.test_spawn_position(self, spawn_pos, node_pos, sdata, node_cache, spawn_flag)
end

function monster_spawner:describe_additional_spawning_criteria()
	return S("Monsters require darkness and enough room to spawn.")
end

mobs_mc.monster_spawner = monster_spawner
