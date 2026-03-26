-- Beta-style points counter (replaces XP bar gameplay).

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check
-- and replace all occurrences of [hud_elem_type_field] with type.
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

mcl_points = {}

local HUD_NUMBER_COLOR = 0xFFFF55
local HUD_LABEL_COLOR = 0xFFFFFF
local HUD_TOP_PADDING = 10
local HUD_Z_INDEX = 105
local META_KEY = "mcl_points:score"
local DIG_BASE_POINTS = 1
local CRAFT_POINTS = 1

local player_state = {}

local function clamp_points(points)
	return math.max(0, math.floor((tonumber(points) or 0) + 0.5))
end

local function get_player_obj(player_or_name)
	if not player_or_name then
		return nil
	end
	if type(player_or_name) == "userdata" and player_or_name.is_player and player_or_name:is_player() then
		return player_or_name
	end
	if type(player_or_name) == "string" then
		return minetest.get_player_by_name(player_or_name)
	end
	return nil
end

local function update_hud(player)
	local name = player:get_player_name()
	local st = player_state[name]
	if not st then
		return
	end
	player:hud_change(st.hud_number, "text", tostring(st.points))
end

local function init_player(player)
	local name = player:get_player_name()
	local meta = player:get_meta()
	local points = clamp_points(meta:get_int(META_KEY))

	local hud_number = player:hud_add({
		[hud_elem_type_field] = "text",
		position = { x = 0.5, y = 0 },
		offset = { x = 0, y = HUD_TOP_PADDING },
		alignment = { x = 1, y = 1 },
		text = tostring(points),
		number = HUD_NUMBER_COLOR,
		z_index = HUD_Z_INDEX,
	})

	local hud_label = player:hud_add({
		[hud_elem_type_field] = "text",
		position = { x = 0.5, y = 0 },
		offset = { x = 0, y = HUD_TOP_PADDING },
		alignment = { x = -1, y = 1 },
		text = "Points: ",
		number = HUD_LABEL_COLOR,
		z_index = HUD_Z_INDEX,
	})

	player_state[name] = {
		points = points,
		hud_number = hud_number,
		hud_label = hud_label,
	}
end

local function set_points_internal(player, points)
	local name = player:get_player_name()
	local st = player_state[name]
	if not st then
		init_player(player)
		st = player_state[name]
	end
	if not st then
		return 0
	end

	points = clamp_points(points)
	st.points = points
	player:get_meta():set_int(META_KEY, points)
	update_hud(player)
	return points
end

function mcl_points.get_points(player_or_name)
	local player = get_player_obj(player_or_name)
	if player then
		local st = player_state[player:get_player_name()]
		if st then
			return st.points
		end
		return clamp_points(player:get_meta():get_int(META_KEY))
	end
	return 0
end

function mcl_points.set_points(player_or_name, points)
	local player = get_player_obj(player_or_name)
	if not player then
		return 0
	end
	return set_points_internal(player, points)
end

function mcl_points.add_points(player_or_name, points)
	local player = get_player_obj(player_or_name)
	if not player then
		return 0
	end
	local add = clamp_points(points)
	if add <= 0 then
		return mcl_points.get_points(player)
	end
	local current = mcl_points.get_points(player)
	return set_points_internal(player, current + add)
end

minetest.register_on_joinplayer(function(player)
	init_player(player)
end)

minetest.register_on_leaveplayer(function(player)
	player_state[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer(function(player)
	set_points_internal(player, 0)
end)

-- Activity points: award score for digging XP-bearing blocks.
minetest.register_on_dignode(function(_, oldnode, digger)
	if not digger or not digger.is_player or not digger:is_player() then
		return
	end
	local name = oldnode and oldnode.name
	if not name or name == "" then
		return
	end
	if minetest.registered_aliases[name] then
		name = minetest.registered_aliases[name]
	end
	local def = minetest.registered_nodes[name]
	if not def or not def.groups then
		return
	end
	local xp = tonumber(def.groups.xp) or 0
	mcl_points.add_points(digger, DIG_BASE_POINTS + math.max(0, xp))
end)

minetest.register_on_craft(function(_, player)
	if not player or not player.is_player or not player:is_player() then
		return
	end
	mcl_points.add_points(player, CRAFT_POINTS)
end)
