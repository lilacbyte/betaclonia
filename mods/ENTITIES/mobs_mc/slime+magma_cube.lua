--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local slime_chunk_spawn_max = mcl_worlds.layer_to_y(40)

local function in_slime_chunk(pos)
	local pr = PseudoRandom(mcl_mapgen_core.get_block_seed(pos))
	return pr:next(1,10) == 1
end


-- Returns a function that spawns children in a circle around pos.
-- To be used as on_die callback.
-- self: mob reference
-- pos: position of "mother" mob
-- child_mod: Mob to spawn
-- spawn_distance: Spawn distance from "mother" mob
-- eject_speed: Initial speed of child mob away from "mother" mob
local spawn_children_on_die = function(child_mob, spawn_distance, eject_speed)
	return function(self, pos)
		local posadd, newpos, dir
		if not eject_speed then
			eject_speed = 1
		end
		local mndef = minetest.registered_nodes[minetest.get_node(pos).name]
		local mother_stuck = mndef and mndef.walkable
		local angle = math.random(0, math.pi*2)
		local children = {}
		local spawn_count = math.random(2, 4)
		for _ = 1, spawn_count do
			dir = vector.new(math.cos(angle), 0, math.sin(angle))
			posadd = vector.normalize(dir) * spawn_distance
			newpos = pos + posadd
			-- If child would end up in a wall, use position of the "mother", unless
			-- the "mother" was stuck as well
			if not mother_stuck then
				local cndef = minetest.registered_nodes[minetest.get_node(newpos).name]
				if cndef and cndef.walkable then
					newpos = pos
					eject_speed = eject_speed * 0.5
				end
			end
			local mob = minetest.add_entity(newpos, child_mob, minetest.serialize({ persist_in_peaceful = self.persist_in_peaceful }))
			if mob and mob:get_pos() and not mother_stuck then
				mob:set_velocity(dir * eject_speed)
			end
		end
		-- If mother was murdered, children attack the killer after 1 second
		if self.state == "attack" then
			minetest.after(1.0, function(children, enemy)
				local le
				for c = 1, #children do
					le = children[c]:get_luaentity()
					if le then
						le.state = "attack"
						le.attack = enemy
					end
				end
			end, children, self.attack)
		end
	end
end

local slime_light_max = 7

local function slime_check_light(pos, _, artificial_light, sky_light)
	local maxlight = slime_light_max

	if pos.y <= slime_chunk_spawn_max and in_slime_chunk(pos) then
		maxlight = minetest.LIGHT_MAX + 1
	end

	return math.max(artificial_light, sky_light) <= maxlight
end

-- Slime
local slime_big = {
	description = S("Slime - big"),
	type = "monster",
	spawn_class = "hostile",
	group_attack = { "mobs_mc:slime_big", "mobs_mc:slime_small", "mobs_mc:slime_tiny" },
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{"mobs_mc_slime.png", "mobs_mc_slime.png"}},
	visual = "mesh",
	mesh = "mobs_mc_slime.b3d",
	makes_footstep_sound = true,
	does_not_prevent_sleep = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
		distance = 16,
	},
	sound_params = {
		gain = 1,
	},
	-- Strong nerf: slimes should be low-threat chip damage.
	damage = 1,
	reach = 2.0,
	dogfight_interval = 2.0,
	armor = 100,
	drops = {},
	-- TODO: Fix animations
	animation = {
		jump_speed = 14,
		stand_speed = 14,
		walk_speed = 7,
		jump_start = 1,
		jump_end = 20,
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
	},
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	walk_velocity = 1.45, -- with no jump delay 1.9<-(was) is way too fast compare to origianl deltax speed of slime
	run_velocity = 1.45,
	walk_chance = 0,
	jump_height = 8, -- (was 5.8) JUMP!
	fear_height = 0,
	spawn_small_alternative = "mobs_mc:slime_small",
	on_die = spawn_children_on_die("mobs_mc:slime_small", 1.0, 1.5),
	use_texture_alpha = true,
	check_light = slime_check_light,
}
mcl_mobs.register_mob("mobs_mc:slime_big", slime_big)

local slime_small = table.copy(slime_big)
slime_small.description = S("Slime - small")
slime_small.sounds.base_pitch = 1.15
slime_small.hp_min = 4
slime_small.hp_max = 4
slime_small.xp_min = 2
slime_small.xp_max = 2
slime_small.collisionbox = {-0.51, -0.01, -0.51, 0.51, 1.00, 0.51}
slime_small.visual_size = {x=6.25, y=6.25}
slime_small.damage = 0
slime_small.reach = 1.8
slime_small.walk_velocity = 1.45
slime_small.run_velocity = 1.45
slime_small.jump_height = 4.3
slime_small.spawn_small_alternative = "mobs_mc:slime_tiny"
slime_small.on_die = spawn_children_on_die("mobs_mc:slime_tiny", 0.6, 1.0)
slime_small.sound_params.gain = slime_big.sound_params.gain / 3
mcl_mobs.register_mob("mobs_mc:slime_small", slime_small)

local slime_tiny = table.copy(slime_big)
slime_tiny.description = S("Slime - tiny")
slime_tiny.sounds.base_pitch = 1.3
slime_tiny.hp_min = 1
slime_tiny.hp_max = 1
slime_tiny.xp_min = 1
slime_tiny.xp_max = 1
slime_tiny.collisionbox = {-0.2505, -0.01, -0.2505, 0.2505, 0.50, 0.2505}
slime_tiny.visual_size = {x=3.125, y=3.125}
slime_tiny.damage = 0
slime_tiny.reach = 1.5
slime_tiny.drops = {
	-- slimeball
	{name = "mcl_mobitems:slimeball",
	chance = 1,
	min = 0,
	max = 2,},
}
slime_tiny.walk_velocity = 1.45
slime_tiny.run_velocity = 1.45
slime_tiny.jump_height = 3
slime_tiny.spawn_small_alternative = nil
slime_tiny.on_die = nil
slime_tiny.sound_params.gain = slime_small.sound_params.gain / 3

mcl_mobs.register_mob("mobs_mc:slime_tiny", slime_tiny)

local water_level = mobs_mc.water_level

local cave_biomes = {
	"FlowerForest_underground",
	"StoneBeach_underground",
	"MesaBryce_underground",
	"Mesa_underground",
	"RoofedForest_underground",
	"MushroomIsland_underground",
	"BirchForest_underground",
	"Plains_underground",
	"MesaPlateauF_underground",
	"ExtremeHills_underground",
	"MegaSpruceTaiga_underground",
	"BirchForestM_underground",
	"SavannaM_underground",
	"MesaPlateauFM_underground",
	"Desert_underground",
	"Savanna_underground",
	"Forest_underground",
	"SunflowerPlains_underground",
	"ColdTaiga_underground",
	"IcePlains_underground",
	"IcePlainsSpikes_underground",
	"MegaTaiga_underground",
	"Taiga_underground",
	"ExtremeHills+_underground",
	"ExtremeHillsM_underground",
}

local cave_min = mcl_vars.mg_overworld_min
local cave_max = water_level - 23

for slime_name,slime_chance in pairs({
	["mobs_mc:slime_tiny"] = 1000,
	["mobs_mc:slime_small"] = 1000,
	["mobs_mc:slime_big"] = 1000
}) do
	mcl_mobs.spawn_setup({
		name = slime_name,
		type_of_spawning = "ground",
		dimension = "overworld",
		biomes = cave_biomes,
		min_light = 0,
		max_light = minetest.LIGHT_MAX+1,
		min_height = cave_min,
		max_height = cave_max,
		chance = slime_chance,
		check_position = in_slime_chunk,
	})
end

mcl_mobs.register_egg("mobs_mc:slime_big", S("Slime"), "#52a03e", "#7ebf6d")
