--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local rabbit = {
	description = S("Rabbit"),
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	spawn_in_group_min = 2,
	spawn_in_group = 3,
	passive = true,
	reach = 1,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, -0.1, -0.2, 0.2, 0.49, 0.2},
	head_swivel = "head.control",
	bone_eye_height = 2,
	head_eye_height = 0.5,
	horizontal_head_height = -.3,
	curiosity = 20,
	head_yaw="z",
	visual = "mesh",
	mesh = "mobs_mc_rabbit.b3d",
	textures = {
        {"mobs_mc_rabbit_brown.png"},
        {"mobs_mc_rabbit_gold.png"},
        {"mobs_mc_rabbit_white.png"},
        {"mobs_mc_rabbit_white_splotched.png"},
        {"mobs_mc_rabbit_salt.png"},
        {"mobs_mc_rabbit_black.png"},
	},
	sounds = {
		random = "mobs_mc_rabbit_random",
		damage = "mobs_mc_rabbit_hurt",
		death = "mobs_mc_rabbit_death",
		attack = "mobs_mc_rabbit_attack",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 2, -- was 3.7, we can make it faster if we have run with jumping animation
	avoid_from = {"mobs_mc:wolf"},
	follow_velocity = 1.1,
	floats = 1,
	runaway = true,
	jump = true,
	drops = {
		{name = "mcl_mobitems:rabbit_hide", chance = 1, min = 0, max = 1, looting = "common",},
	},
	fear_height = 4,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 20, walk_speed = 60,
		run_start = 0, run_end = 20, run_speed = 5,
	},
	_child_animations = {
		stand_start = 21, stand_end = 21,
		walk_start = 21, walk_end = 41, walk_speed = 30,
		run_start = 21, run_end = 41, run_speed = 45,
	},
	-- Follow (yellow) dangelions, carrots and golden carrots
	follow = {
		"mcl_flowers:dandelion",
		"mcl_farming:carrot_item",
		"mcl_farming:carrot_item_gold",
	},
	view_range = 8,
	-- Eat carrots and reduce their growth stage by 1
	replace_rate = 10,
	replace_what = {
		{"mcl_farming:carrot", "mcl_farming:carrot_7", 0},
		{"mcl_farming:carrot_7", "mcl_farming:carrot_6", 0},
		{"mcl_farming:carrot_6", "mcl_farming:carrot_5", 0},
		{"mcl_farming:carrot_5", "mcl_farming:carrot_4", 0},
		{"mcl_farming:carrot_4", "mcl_farming:carrot_3", 0},
		{"mcl_farming:carrot_3", "mcl_farming:carrot_2", 0},
		{"mcl_farming:carrot_2", "mcl_farming:carrot_1", 0},
		{"mcl_farming:carrot_1", "air", 0},
	},
	on_rightclick = function(self, clicker)
		if self:follow_holding(clicker) and self:feed_tame(clicker, 4, true, false) then return end
	end,
	do_custom = function(self)
		-- TODO this is a silly thing to run all the time, if it's wanted it should be done by overriding set_nametag
		-- Easter egg: Change texture if rabbit is named “Toast”
		local nametag = self.object:get_properties().nametag
		if nametag == "Toast" and not self._has_toast_texture then
			self._original_rabbit_texture = self.base_texture
			self.base_texture = { "mobs_mc_rabbit_toast.png" }
			self.object:set_properties({ textures = self.base_texture })
			self._has_toast_texture = true
		elseif nametag ~= "Toast" and self._has_toast_texture then
			self.base_texture = self._original_rabbit_texture
			self.object:set_properties({ textures = self.base_texture })
			self._has_toast_texture = false
		end
	end,
}

mcl_mobs.register_mob("mobs_mc:rabbit", rabbit)

-- The killer bunny (Only with spawn egg)
local killer_bunny = table.copy(rabbit)
killer_bunny.description = S("Killer Bunny")
killer_bunny.type = "monster"
killer_bunny.spawn_class = "hostile"
killer_bunny.attack_type = "dogfight"
killer_bunny.specific_attack = { "player", "mobs_mc:wolf", "mobs_mc:dog" }
killer_bunny.damage = 8
killer_bunny.passive = false
killer_bunny.does_not_prevent_sleep = true
-- 8 armor points
killer_bunny.armor = 50
killer_bunny.textures = { "mobs_mc_rabbit_caerbannog.png" }
killer_bunny.view_range = 16
killer_bunny.replace_rate = nil
killer_bunny.replace_what = nil
killer_bunny.on_rightclick = nil
killer_bunny.run_velocity = 6
killer_bunny.do_custom = function(self)
	if self.nametag ~= "The Killer Bunny" then
		self:set_nametag("The Killer Bunny")
	end
end

mcl_mobs.register_mob("mobs_mc:killer_bunny", killer_bunny)

-- Mob spawning rules.
local function rabbit_biome_name (pos)
	local biome_data = minetest.get_biome_data(pos)
	if not biome_data then
		return nil
	end
	return minetest.get_biome_name(biome_data.biome)
end

local spawns_white_rabbits = {
	["FrozenOcean"] = true,
	["FrozenPeaks"] = true,
	["FrozenRiver"] = true,
	["Grove"] = true,
	["IceSpikes"] = true,
	["JaggedPeaks"] = true,
	["SnowyBeach"] = true,
	["SnowyPlains"] = true,
	["SnowySlopes"] = true,
	["SnowyTaiga"] = true,
}

local function rabbit_spawn_texture (biome_name)
	local random = math.random(100)

	if spawns_white_rabbits[biome_name] then
		if random < 80 then
			return "mobs_mc_rabbit_white.png"
		end
		return "mobs_mc_rabbit_white_splotched.png"
	elseif biome_name == "Desert" then
		return "mobs_mc_rabbit_gold.png"
	elseif random < 50 then
		return "mobs_mc_rabbit_brown.png"
	elseif random < 90 then
		return "mobs_mc_rabbit_salt.png"
	end
	return "mobs_mc_rabbit_black.png"
end

local rabbit_spawner_woody = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:rabbit",
	weight = 4,
	min_light = 9,
	pack_min = 2,
	pack_max = 3,
	biomes = {
		"FlowerForest",
		"OldGrowthPineTaiga",
		"OldGrowthSpruceTaiga",
		"Taiga",
	},
})

function rabbit_spawner_woody:test_supporting_node (node)
	return minetest.get_item_group (node.name, "grass_block") > 0
		or node.name == "mcl_core:sand"
		or node.name == "mcl_core:snowblock"
end

function rabbit_spawner_woody:prepare_to_spawn (pack_size, center)
	return {
		_spawn_texture = rabbit_spawn_texture (rabbit_biome_name (center)),
	}
end

local rabbit_spawner_meadow_or_cherry_grove = table.merge (rabbit_spawner_woody, {
	name = "mobs_mc:rabbit",
	weight = 2,
	min_light = 9,
	biomes = {
		"Meadow",
		"CherryGrove",
	},
})

local rabbit_spawner_snowy = table.merge (rabbit_spawner_woody, {
	name = "mobs_mc:rabbit",
	weight = 10,
	min_light = 9,
	biomes = {
		"FrozenOcean",
		"FrozenRiver",
		"IceSpikes",
		"SnowyBeach",
		"SnowyPlains",
		"SnowySlopes",
		"SnowyTaiga",
	},
})

local rabbit_spawner_grove = table.merge (rabbit_spawner_woody, {
	name = "mobs_mc:rabbit",
	weight = 8,
	min_light = 9,
	biomes = {
		"Grove",
	},
})

local rabbit_spawner_desert = table.merge (rabbit_spawner_woody, {
	name = "mobs_mc:rabbit",
	weight = 4,
	min_light = 9,
	biomes = {
		"Desert",
	},
})

mcl_mobs.register_spawner (rabbit_spawner_woody)
mcl_mobs.register_spawner (rabbit_spawner_meadow_or_cherry_grove)
mcl_mobs.register_spawner (rabbit_spawner_snowy)
mcl_mobs.register_spawner (rabbit_spawner_grove)
mcl_mobs.register_spawner (rabbit_spawner_desert)

-- Spawn egg
mcl_mobs.register_egg("mobs_mc:rabbit", S("Rabbit"), "#995f40", "#734831", 0)

-- Note: This spawn egg does not exist in The OG Game
mcl_mobs.register_egg("mobs_mc:killer_bunny", S("Killer Bunny"), "#f2f2f2", "#ff0000", 0)
