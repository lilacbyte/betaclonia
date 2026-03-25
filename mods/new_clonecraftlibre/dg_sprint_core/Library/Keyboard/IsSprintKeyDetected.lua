local keyboard_data = {}

local function create_pdata(player)
	if not player then return end
    	return {
        	states = {
            		detected = false,
            		last_tap_time = 0,
            		is_holding = false,
            		aux_pressed = false,
        	},
		prevent_detection_reasons = {}
    	}
end

core.register_on_joinplayer(function(player)
	if not player then return end
    	local name = player:get_player_name()
    	keyboard_data[name] = create_pdata(player)
end)

core.register_on_leaveplayer(function(player)
	if not player then return end
    	local name = player:get_player_name()
    	keyboard_data[name] = nil
end)

dg_sprint_core.IsSprintKeyDetected = function(player, detect_aux, detect_double_tap, interval)
	assert(type(detect_aux) == "boolean",
        	"dg_sprint_core.IsSprintKeyDetected: 'detect_aux' must be a boolean.")
    	assert(type(detect_double_tap) == "boolean",
           	"dg_sprint_core.IsSprintKeyDetected: 'detect_double_tap' must be a boolean.")
    	assert(type(interval) == "number",
           	"dg_sprint_core.IsSprintKeyDetected: 'interval' must be a number.")

    	local name = player:get_player_name()
    	assert(type(name) == "string" and name ~= "",
           	"dg_sprint_core.IsSprintKeyDetected: Player name must be a non-empty string.")

    	-- Ensure that the global keyboard_data table and data for the player exists.
    	assert(keyboard_data and keyboard_data[name],
           	"dg_sprint_core.IsSprintKeyDetected: No keyboard data found for player: " .. tostring(name))
    	local k_data = keyboard_data[name]

    	local control_bit = player:get_player_control_bits()
    	local current_time_us = core.get_us_time() / 1e6
    	local cancel_active = false

    	-- Check if there are any detection prevention reasons.
    	if k_data.prevent_detection_reasons then
        	for reason, _ in pairs(k_data.prevent_detection_reasons) do
            		cancel_active = true
            		break
        	end
    	end

   	if cancel_active then
        	k_data.states.detected = false
        	k_data.states.is_holding = false
        	k_data.states.aux_pressed = false
        	return false
    	end

    	if control_bit == (32 + 1) and detect_aux then
        	k_data.states.detected = true
        	k_data.states.is_holding = false
        	k_data.states.aux_pressed = true
    	elseif control_bit == 1 and not detect_double_tap then
        	k_data.states.detected = false
        	k_data.states.is_holding = false
        	k_data.states.aux_pressed = false
    	elseif control_bit == 1 and detect_double_tap then
        	if not k_data.states.is_holding then
        		if current_time_us - k_data.states.last_tap_time < interval then
                		k_data.states.detected = true
            		end
            		k_data.states.last_tap_time = current_time_us
            		k_data.states.is_holding = true
        	end
        	k_data.states.aux_pressed = false
    	elseif control_bit == 0 or control_bit == 32 then
        	k_data.states.detected = false
        	k_data.states.is_holding = false
        	k_data.states.aux_pressed = false
    	end

    	return k_data.states.detected
end



dg_sprint_core.prevent_detection = function(player, enabled, reason)
    	assert(type(reason) == "string" and reason ~= "", "dg_sprint_core.prevent_detection: 'reason' must be a non-empty string.")

    	local name = player:get_player_name()
    	local k_data = keyboard_data[name]
    	assert(k_data, "dg_sprint_core.prevent_detection: No keyboard data found for player: " .. name)
    	assert(
        	k_data.prevent_detection_reasons,
        	"dg_sprint_core.prevent_detection: 'prevent_detection_reasons' does not exist for player: " .. name
    	)

    	if enabled then
        	k_data.prevent_detection_reasons[reason] = true
    	else
        	k_data.prevent_detection_reasons[reason] = nil
    	end
end
