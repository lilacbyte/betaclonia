--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mod_bows = minetest.get_modpath("mcl_bows") ~= nil

local skeleton = {
	description = S("Skeleton"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 6,
	xp_max = 6,
	breath_max = -1,
	armor = {undead = 100, fleshy = 100},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.98, 0.3},
	pathfinding = 1,
	group_attack = true,
	head_swivel = "Head_Control",
	bone_eye_height = 2.38,
	curiosity = 6,
	visual = "mesh",
	mesh = "mobs_mc_skeleton.b3d",
	shooter_avoid_enemy = true,
	strafes = true,
	makes_footstep_sound = true,
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_skeleton.png", -- texture
			"mcl_bows_bow_0.png", -- wielded_item
		}
	},
	walk_velocity = 1.1,
	run_velocity = 1.45, -- skeletons are really anoying in mc, so i made only walkin 0.2 slower
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		distance = 16,
	},
	runaway_from = {"mobs_mc:wolf"},
	damage = 2,
	reach = 2,
	drops = {
		{name = "mcl_bows:arrow",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		{name = "mcl_bows:bow",
		chance = 100 / 8.5,
		min = 1,
		max = 1,
		looting = "rare",},
		{name = "mcl_mobitems:bone",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		{name = "mcl_heads:skeleton",
		 chance = 200, -- 0.5% chance
		 min = 1,
		 max = 1,
		 mob_head = true,},
	},
	animation = {
		stand_speed = 15,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 15,
		walk_start = 40,
		walk_end = 60,
		run_speed = 30,
		shoot_start = 70,
		shoot_end = 90,
		jockey_start = 172,
		jockey_end = 172,
		die_start = 160,
		die_end = 170,
		die_speed = 15,
		die_loop = false,
	},
	on_spawn = function(self)
		if math.random(100) == 1 then
			self:jock_to("mobs_mc:spider", vector.new(0,0,0), vector.new(0,0,0))
		end
		return true
	end,
	ignited_by_sunlight = true,
	floats = 0,
	view_range = 16,
	fear_height = 4,
	attack_type = "dogshoot",
	arrow = "mcl_bows:arrow_entity",
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			if self.attack then
				self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
			end
			local dmg = math.random(3, 4)
			mcl_bows.shoot_arrow("mcl_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
		end
	end,
	shoot_interval = 2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	harmed_by_heal = true,
	on_die = function(self, pos, cmi_cause)
		return
	end,
}

mcl_mobs.register_mob("mobs_mc:skeleton", skeleton)

local witherskeleton = table.copy(skeleton)
witherskeleton.description = S("Wither Skeleton")
witherskeleton.textures = {
	{
		"mobs_mc_empty.png", -- armor
		"mobs_mc_skeleton.png^[multiply:#3a3a3a", -- texture
		"default_tool_stonesword.png", -- wielded_item
	}
}
witherskeleton.damage = 4
witherskeleton.hp_min = 24
witherskeleton.hp_max = 24
witherskeleton.attack_type = "dogfight"
witherskeleton.reach = 2.5
witherskeleton.ignited_by_sunlight = false
witherskeleton.shooter_avoid_enemy = false
witherskeleton.strafes = false
witherskeleton.arrow = nil
witherskeleton.shoot_arrow = nil
witherskeleton.shoot_interval = nil
witherskeleton.shoot_offset = nil
witherskeleton.dogshoot_switch = nil
witherskeleton.dogshoot_count_max = nil
witherskeleton.drops = {
	{name = "mcl_mobitems:bone", chance = 1, min = 0, max = 2, looting = "common"},
	{name = "mcl_core:coal_lump", chance = 1, min = 0, max = 1, looting = "common"},
}
witherskeleton.on_spawn = nil

mcl_mobs.register_mob("mobs_mc:witherskeleton", witherskeleton)


mcl_mobs.spawn_setup({
	name = "mobs_mc:skeleton",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 2,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 800,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:skeleton", S("Skeleton"), "#c1c1c1", "#494949", 0)
mcl_mobs.register_egg("mobs_mc:witherskeleton", S("Wither Skeleton"), "#141414", "#474d4d", 0)
