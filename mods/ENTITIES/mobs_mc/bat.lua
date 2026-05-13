--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local function check_light(_, _, artificial_light, _)
	local date = os.date("*t")
	local maxlight
	if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
		maxlight = 6
	else
		maxlight = 3
	end

	if artificial_light > maxlight then
		return false, "To bright"
	end

	return true, ""
end

mcl_mobs.register_mob("mobs_mc:bat", {
	description = S("Bat"),
	type = "animal",
	spawn_class = "ambient",
	can_despawn = true,
	spawn_in_group = 8,
	passive = true,
	hp_min = 6,
	hp_max = 6,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_bat.b3d",
	textures = {
		{"mobs_mc_bat.png"},
	},
	visual_size = {x=1, y=1},
	sounds = {
		random = "mobs_mc_bat_idle",
		damage = "mobs_mc_bat_hurt",
		death = "mobs_mc_bat_death",
		distance = 16,
	},
	walk_velocity = 4.5,
	run_velocity = 6.0,
	-- TODO: Hang upside down
	animation = {
		stand_speed = 80,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 80,
		walk_start = 0,
		walk_end = 40,
		run_speed = 80,
		run_start = 0,
		run_end = 40,
		die_speed = 60,
		die_start = 40,
		die_end = 80,
		die_loop = false,
	},
	walk_chance = 100,
	fall_damage = 0,
	view_range = 16,
	fear_height = 0,

	jump = false,
	fly = true,
	makes_footstep_sound = false,
	check_light = check_light,
})


-- Spawning

--[[ If the game has been launched between the 20th of October and the 3rd of November system time,
-- the maximum spawn light level is increased. ]]
local function bat_maxlight ()
	local date = os.date("*t")
	if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
		return 6
	end
	return 3
end

local default_spawner = mcl_mobs.default_spawner or mobs_mc.default_spawner or {
	test_spawn_position = function ()
		return false
	end,
}
local bat_spawner = table.merge (default_spawner, {
	name = "mobs_mc:bat",
	spawn_category = "ambient",
	spawn_placement = "ground",
	pack_min = 8,
	pack_max = 8,
	weight = 10,
	biomes = mobs_mc.overworld_biomes,
	min_light = 0,
	max_light = bat_maxlight (),
	min_height = mcl_vars.mg_overworld_min,
	max_height = mobs_mc.water_level - 1,
})

function bat_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					  spawn_flag)
	if spawn_pos.y < 0 then
		local eligible
			= (mcl_mobs.default_spawner or default_spawner).test_spawn_position (
				self, spawn_pos, node_pos, sdata, node_cache, spawn_flag)
		if eligible then
			return minetest.get_node_light (node_pos) <= bat_maxlight ()
				and not mcl_weather.can_see_outdoors (node_pos)
		end
	end
	return false
end

function bat_spawner:describe_additional_spawning_criteria ()
	return S ("Spawning will only be successful between light levels of 0 and 3 at most times of the year, or 0 and 6 between 20 October and 3 November.")
end

mcl_mobs.register_spawner (bat_spawner)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:bat", S("Bat"), "#4c3e30", "#0f0f0f", 0)
