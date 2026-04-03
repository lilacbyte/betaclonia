-- Timed sprint with stamina HUD.

mcl_sprint = {}

mcl_sprint.SPEED = 1.2
mcl_sprint.STAMINA_MAX = 20

local STAMINA_DRAIN_PER_SEC = 5.0
local STAMINA_REGEN_PER_SEC = 2.0
local FOV_SPRINT = 1.1
local FOV_NORMAL = 1.0
local PARTICLE_INTERVAL = 0.12
local DOUBLE_TAP_INTERVAL = 0.22

local sprinting_enabled = minetest.settings:get_bool("mcl_enable_sprinting", false)
local players = {}

-- Returns true if the player with the given name is sprinting, false if not.
-- Returns nil if player does not exist.
function mcl_sprint.is_sprinting(player_name)
	if not sprinting_enabled then
		return false
	end
	if players[player_name] then
		return players[player_name].sprinting
	end
	return nil
end

if not sprinting_enabled then
	return
end

local sprint_factor_guard = false
local function install_sprint_factor_guard()
	if not playerphysics
		or not playerphysics.add_physics_factor
		or playerphysics._mcl_sprint_factor_guard_installed then
		return
	end

	local raw_add = playerphysics.add_physics_factor
	playerphysics.add_physics_factor = function(player, name, modifier, value)
		if modifier == "mcl_sprint:sprint" and not sprint_factor_guard then
			return
		end
		return raw_add(player, name, modifier, value)
	end
	playerphysics._mcl_sprint_factor_guard_installed = true
end

local function set_sprint_factor(player, enabled)
	if not playerphysics then
		return
	end
	if enabled then
		sprint_factor_guard = true
		playerphysics.add_physics_factor(player, "speed", "mcl_sprint:sprint", mcl_sprint.SPEED)
		sprint_factor_guard = false
	else
		if playerphysics.remove_physics_factor then
			playerphysics.remove_physics_factor(player, "speed", "mcl_sprint:sprint")
			playerphysics.remove_physics_factor(player, "fov", "mcl_sprint:sprint")
		end
	end
end

local function clamp_stamina(value)
	return math.max(0, math.min(mcl_sprint.STAMINA_MAX, value))
end

local function ensure_hud(player, player_data)
	if not hb or not hb.init_hudbar then
		return
	end
	if player_data.hud_initialized then
		return
	end
	hb.init_hudbar(player, "stamina", player_data.stamina, mcl_sprint.STAMINA_MAX, true)
	player_data.hud_initialized = true
end

local function update_hud(player, player_data)
	if not hb or not hb.change_hudbar then
		return
	end
	ensure_hud(player, player_data)
	if not player_data.hud_initialized then
		return
	end

	-- Show while sprinting and while stamina is regenerating; hide only when idle+full.
	local is_regenerating = player_data.stamina < (mcl_sprint.STAMINA_MAX - 0.01)
	local hide = (not player_data.sprinting) and (not is_regenerating)
	if hide then
		hb.hide_hudbar(player, "stamina")
		return
	end

	hb.unhide_hudbar(player, "stamina")
	hb.change_hudbar(player, "stamina", player_data.stamina, mcl_sprint.STAMINA_MAX)
end

local function player_is_moving(player)
	local vel = player:get_velocity() or { x = 0, y = 0, z = 0 }
	return math.abs(vel.x) + math.abs(vel.z) > 0.08
end

local function cancel_client_sprinting(name)
	local data = players[name]
	if not data then
		return
	end
	if data.channel then
		data.channel:send_all("")
	end
	data.client_sprint = false
end

local function set_sprinting(player_name, sprinting)
	local data = players[player_name]
	if not data or data.sprinting == sprinting then
		return
	end

	local player = minetest.get_player_by_name(player_name)
	if not player then
		return
	end

	data.sprinting = sprinting
	if sprinting then
		set_sprint_factor(player, true)
		data.fov = FOV_SPRINT
		player:set_fov(FOV_SPRINT, true, 0.15)
	else
		set_sprint_factor(player, false)
		data.fov = FOV_NORMAL
		player:set_fov(FOV_NORMAL, true, 0.15)
	end
end

local function can_sprint(player, data, ctrl)
	if not player or not data then
		return false
	end
	if player:get_attach() or ctrl.sneak then
		return false
	end
	if player:get_meta():get_string("mcl_beds:sleeping") == "true" then
		return false
	end
	if not ctrl.up or data.stamina <= 0 then
		return false
	end
	return player_is_moving(player)
end

if hb and hb.register_hudbar then
	hb.register_hudbar("stamina", 0xFFFFFF, "Stamina", {
		icon = "minetest_wadsprint_is_sprinting_icon.png",
		bgicon = "minetest_wadsprint_is_not_sprinting_icon.png",
		bar = "minetest_wadsprint_is_sprinting_icon.png",
	}, mcl_sprint.STAMINA_MAX, mcl_sprint.STAMINA_MAX, true, nil, nil, 1)
end

install_sprint_factor_guard()

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	players[name] = {
		sprinting = false,
		client_sprint = false,
		double_tap_sprint = false,
		up_held = false,
		last_tap_time = 0,
		should_sprint = false,
		stamina = mcl_sprint.STAMINA_MAX,
		fov = FOV_NORMAL,
		channel = minetest.mod_channel_join("mcl_sprint:" .. name),
		particle_timer = 0,
		hud_initialized = false,
	}
	update_hud(player, players[name])
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	local data = players[sender]
	if data and channel_name == ("mcl_sprint:" .. sender) then
		data.client_sprint = minetest.is_yes(message)
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	local data = players[name]
	if not data then
		return
	end
	cancel_client_sprinting(name)
	set_sprinting(name, false)
	data.stamina = mcl_sprint.STAMINA_MAX
	update_hud(player, data)
end)

minetest.register_globalstep(function(dtime)
	for player_name, data in pairs(players) do
		local player = minetest.get_player_by_name(player_name)
			if player then
				if not data.sprinting then
					set_sprint_factor(player, false)
				end
				local ctrl = player:get_player_control()
				if ctrl.up then
				if not data.up_held then
					local now = minetest.get_us_time() / 1000000
					if now - data.last_tap_time <= DOUBLE_TAP_INTERVAL then
						data.double_tap_sprint = true
					end
					data.last_tap_time = now
					data.up_held = true
				end
			else
				data.up_held = false
				data.double_tap_sprint = false
			end

			data.should_sprint = data.client_sprint
				or (ctrl.aux1 and ctrl.up and not ctrl.sneak)
				or (data.double_tap_sprint and ctrl.up and not ctrl.sneak)

			local was_sprinting = data.sprinting
			local old_stamina = data.stamina

			if data.should_sprint and can_sprint(player, data, ctrl) then
				set_sprinting(player_name, true)
			else
				set_sprinting(player_name, false)
				if data.should_sprint and data.stamina <= 0 then
					cancel_client_sprinting(player_name)
					data.double_tap_sprint = false
				end
			end

			if data.sprinting then
				data.stamina = clamp_stamina(data.stamina - STAMINA_DRAIN_PER_SEC * dtime)
				if data.stamina <= 0 then
					data.stamina = 0
					cancel_client_sprinting(player_name)
					data.double_tap_sprint = false
					set_sprinting(player_name, false)
				end
			else
				data.stamina = clamp_stamina(data.stamina + STAMINA_REGEN_PER_SEC * dtime)
			end

			if data.sprinting and player_is_moving(player) then
				data.particle_timer = data.particle_timer + dtime
				if data.particle_timer >= PARTICLE_INTERVAL then
					data.particle_timer = 0
					local pos = player:get_pos()
					local below = { x = pos.x, y = pos.y - 1, z = pos.z }
					local node = minetest.get_node_or_nil(below)
					local def = node and minetest.registered_nodes[node.name]
					if def and def.walkable then
						minetest.add_particlespawner({
							amount = 1,
							time = 0.05,
							minpos = { x = -0.35, y = 0.1, z = -0.35 },
							maxpos = { x = 0.35, y = 0.1, z = 0.35 },
							minvel = { x = 0, y = 4, z = 0 },
							maxvel = { x = 0, y = 5, z = 0 },
							minacc = { x = 0, y = -12, z = 0 },
							maxacc = { x = 0, y = -12, z = 0 },
							minexptime = 0.15,
							maxexptime = 0.7,
							minsize = 0.6,
							maxsize = 1.4,
							collisiondetection = true,
							attached = player,
							vertical = false,
							node = node,
							node_tile = 1,
						})
					end
				end
			else
				data.particle_timer = 0
			end

			if was_sprinting ~= data.sprinting or math.abs(old_stamina - data.stamina) > 0.01 then
				update_hud(player, data)
			end
		end
	end
end)
