local S = minetest.get_translator(minetest.get_current_modname())

--local mod_target = minetest.get_modpath("mcl_target")--removed

-- The snowball entity
local snowball_ENTITY={
	initial_properties = {
		physical = false,
		textures = {"mcl_throwing_snowball.png"},
		visual_size = {x=0.5, y=0.5},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},

	timer=0,
	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,
	_thrower = nil,

	_lastpos={},
}

local egg_ENTITY={
	initial_properties = {
		physical = false,
		textures = {"mcl_throwing_egg.png"},
		visual_size = {x=0.45, y=0.45},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},
	timer=0,
	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,
	_thrower = nil,

	_lastpos={},
}


local function check_object_hit(self, pos, dmg)
	for object in minetest.objects_inside_radius(pos, 1.5) do

		local entity = object:get_luaentity()

		if entity
		and entity.name ~= self.object:get_luaentity().name then

			if object:is_player() and self._thrower ~= object:get_player_name() then
				self.object:remove()
				return true
			elseif (entity.is_mob == true or entity._hittable_by_projectile) and (self._thrower ~= object) then
				local pl = self._thrower and self._thrower.is_player and self._thrower or type(self._thrower) == "string" and minetest.get_player_by_name(self._thrower)
				if pl then
					object:punch(pl, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = dmg,
					}, nil)
					return true
				end
			end
		end
	end
	return false
end

local function snowball_particles(pos, vel)
	local vel = vector.normalize(vector.multiply(vel, -1))
	minetest.add_particlespawner({
		amount = 20,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.add({x=-2, y=3, z=-2}, vel),
		maxvel = vector.add({x=2, y=5, z=2}, vel),
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 1,
		maxexptime = 3,
		minsize = 0.7,
		maxsize = 0.7,
		collisiondetection = true,
		collision_removal = true,
		object_collision = false,
		texture = "weather_pack_snow_snowflake"..math.random(1,2)..".png",
	})
end

-- Snowball on_step()--> called when snowball is moving.
local function snowball_on_step(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	-- Destroy when hitting a solid node
	if self._lastpos.x~=nil then
		if (def and def.walkable) or not def then
			minetest.sound_play("mcl_throwing_snowball_impact_hard", { pos = pos, max_hear_distance=16, gain=0.7 }, true)
			snowball_particles(self._lastpos, vel)
			self.object:remove()
--[[			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end]]--removed
			return
		end
	end
	if check_object_hit(self, pos, {snowball_vulnerable = 3}) then
		minetest.sound_play("mcl_throwing_snowball_impact_soft", { pos = pos, max_hear_distance=16, gain=0.7 }, true)
		snowball_particles(pos, vel)
		self.object:remove()
		return
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set _lastpos-->Node will be added at last pos outside the node
end

-- Movement function of egg
local function egg_on_step(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	-- Destroy when hitting a solid node with chance to spawn chicks
	if self._lastpos.x then
		if (def and def.walkable) or not def then
			-- 1/8 chance to spawn a chick
			-- FIXME: Chicks have a quite good chance to spawn in walls
			local r = math.random(1,8)

			if r == 1 then
				mcl_mobs.spawn_child(self._lastpos, "mobs_mc:chicken")

				-- BONUS ROUND: 1/32 chance to spawn 3 additional chicks
				local r = math.random(1,32)
				if r == 1 then
					local offsets = {
						{ x=0.7, y=0, z=0 },
						{ x=-0.7, y=0, z=-0.7 },
						{ x=-0.7, y=0, z=0.7 },
					}
					for o=1, 3 do
						local pos = vector.add(self._lastpos, offsets[o])
						mcl_mobs.spawn_child(pos, "mobs_mc:chicken")
					end
				end
			end
			minetest.sound_play("mcl_throwing_egg_impact", { pos = self.object:get_pos(), max_hear_distance=10, gain=0.5 }, true)
			self.object:remove()
--[[			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end]]--removed
			return
		end
	end

	-- Destroy when hitting a mob or player (no chick spawning)
	if check_object_hit(self, pos, 0) then
		minetest.sound_play("mcl_throwing_egg_impact", { pos = self.object:get_pos(), max_hear_distance=10, gain=0.5 }, true)
		self.object:remove()
		return
	end

	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

snowball_ENTITY.on_step = snowball_on_step
egg_ENTITY.on_step = egg_on_step

minetest.register_entity("mcl_throwing:snowball_entity", snowball_ENTITY)
minetest.register_entity("mcl_throwing:egg_entity", egg_ENTITY)


local how_to_throw = S("Use the punch key to throw.")

-- Snowball
minetest.register_craftitem("mcl_throwing:snowball", {
	description = S("Snowball"),
	_tt_help = S("Throwable"),
	_doc_items_longdesc = S("Snowballs can be thrown or launched from a dispenser for fun. Hitting something with a snowball does nothing."),
	_doc_items_usagehelp = how_to_throw,
	inventory_image = "mcl_throwing_snowball.png",
	stack_max = 16,
	groups = { weapon_ranged = 1 },
	on_use = mcl_throwing.get_player_throw_function("mcl_throwing:snowball_entity"),
	_on_dispense = mcl_throwing.dispense_function,
})

-- Egg
minetest.register_craftitem("mcl_throwing:egg", {
	description = S("Egg"),
	_tt_help = S("Throwable").."\n"..S("Chance to hatch chicks when broken"),
	_doc_items_longdesc = S("Eggs can be thrown or launched from a dispenser and breaks on impact. There is a small chance that 1 or even 4 chicks will pop out of the egg."),
	_doc_items_usagehelp = how_to_throw,
	inventory_image = "mcl_throwing_egg.png",
	stack_max = 16,
	on_use = mcl_throwing.get_player_throw_function("mcl_throwing:egg_entity"),
	_on_dispense = mcl_throwing.dispense_function,
	_dispense_into_walkable = true,
	groups = { craftitem = 1 },
})

mcl_throwing.register_throwable_object("mcl_throwing:snowball", "mcl_throwing:snowball_entity", 22)
mcl_throwing.register_throwable_object("mcl_throwing:egg", "mcl_throwing:egg_entity", 22)
