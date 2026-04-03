local S = minetest.get_translator(minetest.get_current_modname())

local mcl_hbarmor = {
    -- HUD statbar values
    armor = {},
    -- Stores if player's HUD bar has been initialized so far.
    player_active = {},
    -- Time difference in seconds between updates to the HUD armor bar.
    -- Increase this number for slow servers.
    tick = 0.1,
    -- If true, the armor bar is hidden when the player does not wear any armor
    autohide = true,
}

local stamina_align_state = {}

local tick_config = minetest.settings:get("mcl_hbarmor_tick")

if tonumber(tick_config) then
	mcl_hbarmor.tick = tonumber(tick_config)
end


local function must_hide(_, arm)
	return arm == 0
end

local function arm_printable(arm)
	return math.ceil(math.floor(arm+0.5))
end

local function get_hud_component(player, hud_id)
	if not hud_id then
		return nil
	end
	local def = player:hud_get(hud_id)
	if not def then
		return nil
	end
	local out = {}
	if def.offset then
		out.offset = { x = def.offset.x, y = def.offset.y }
	end
	if def.direction ~= nil then
		out.direction = def.direction
	end
	return out
end

local function capture_hudbar_layout(player, identifier)
	if not hb or not hb.get_hudtable then
		return nil
	end
	local htable = hb.get_hudtable(identifier)
	if not htable then
		return nil
	end
	local name = player:get_player_name()
	local ids = htable.hudids and htable.hudids[name]
	if not ids then
		return nil
	end
	local layout = {}
	layout.bar = get_hud_component(player, ids.bar)
	layout.bg = get_hud_component(player, ids.bg)
	layout.icon = get_hud_component(player, ids.icon)
	layout.text = get_hud_component(player, ids.text)
	if not layout.bar and not layout.bg and not layout.icon and not layout.text then
		return nil
	end
	return layout
end

local function apply_hudbar_layout(player, identifier, layout)
	if not layout or not hb or not hb.get_hudtable then
		return
	end
	local htable = hb.get_hudtable(identifier)
	if not htable then
		return
	end
	local name = player:get_player_name()
	local ids = htable.hudids and htable.hudids[name]
	if not ids then
		return
	end

	for _, field in ipairs({ "bar", "bg", "icon", "text" }) do
		local comp = layout[field]
		local hud_id = ids[field]
		if comp and hud_id then
			if comp.offset then
				player:hud_change(hud_id, "offset", comp.offset)
			end
			if field == "bar" and comp.direction ~= nil then
				player:hud_change(hud_id, "direction", comp.direction)
			end
		end
	end
end

local function update_stamina_alignment(player, arm)
	local name = player:get_player_name()
	local state = stamina_align_state[name] or {}

	if not state.default_layout then
		state.default_layout = capture_hudbar_layout(player, "stamina")
	end
	if not state.armor_layout then
		state.armor_layout = capture_hudbar_layout(player, "armor")
	end

	local move_to_armor_row = (arm or 0) <= 0
	local target_layout = move_to_armor_row and state.armor_layout or state.default_layout
	local target_mode = move_to_armor_row and "armor_row" or "default_row"

	if target_layout and state.mode ~= target_mode then
		apply_hudbar_layout(player, "stamina", target_layout)
		state.mode = target_mode
	end

	stamina_align_state[name] = state
end

local function custom_hud(player)
	local name = player:get_player_name()

	if minetest.settings:get_bool("enable_damage") then
		local ret = mcl_hbarmor.get_armor(player)
		if ret == false then
			minetest.log("error", "[mcl_hbarmor] Call to mcl_hbarmor.get_armor in custom_hud returned with false!")
			return
		end
		local arm = tonumber(mcl_hbarmor.armor[name])
		if not arm then
			arm = 0
		end
		local hide
			if mcl_hbarmor.autohide then
				hide = must_hide(name, arm)
			else
				hide = false
			end
				hb.init_hudbar(player, "armor", arm_printable(arm), nil, hide)
				update_stamina_alignment(player, arm)
			end
end

--register and define armor HUD bar
hb.register_hudbar("armor", 0xFFFFFF, S("Armor"), { icon = "hbarmor_icon.png", bgicon = "hbarmor_bgicon.png", bar = "hbarmor_bar.png" }, 0, 20, mcl_hbarmor.autohide, nil, nil, 1)

function mcl_hbarmor.get_armor(player)
	local name = player:get_player_name()
	local pts = player:get_meta():get_int("mcl_armor:armor_points")
	if not pts then
		return false
	else
		mcl_hbarmor.set_armor(name, pts)
	end
	return true
end

function mcl_hbarmor.set_armor(player_name, pts)
	mcl_hbarmor.armor[player_name] = math.max(0, math.min(20, pts))
end

-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
	--armor
	local arm = tonumber(mcl_hbarmor.armor[name])
	if not arm then
		arm = 0
		mcl_hbarmor.armor[name] = 0
	end
	if mcl_hbarmor.autohide then
		-- hide armor bar completely when there is none
		if must_hide(name, arm) then
			hb.hide_hudbar(player, "armor")
		else
			hb.change_hudbar(player, "armor", arm_printable(arm))
			hb.unhide_hudbar(player, "armor")
		end
	else
		hb.change_hudbar(player, "armor", arm_printable(arm))
	end
	update_stamina_alignment(player, arm)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	custom_hud(player)
	mcl_hbarmor.player_active[name] = true
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mcl_hbarmor.player_active[name] = false
	stamina_align_state[name] = nil
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
    --TODO: replace this by playerglobalstep API then implemented
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > mcl_hbarmor.tick or timer > 4 then
		if minetest.settings:get_bool("enable_damage") then
			if main_timer > mcl_hbarmor.tick then main_timer = 0 end
			for player in mcl_util.connected_players() do
				local name = player:get_player_name()
				if mcl_hbarmor.player_active[name] == true then
					local ret = mcl_hbarmor.get_armor(player)
					if ret == false then
						minetest.log("error", "[mcl_hbarmor] Call to mcl_hbarmor.get_armor in globalstep returned with false!")
					end
					-- update all hud elements
					update_hud(player)
				end
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
