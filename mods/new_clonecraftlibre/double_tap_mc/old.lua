local your_mod_name = core.get_current_modname()

local settings = {
    	aux1 = true,
    	double_tap = true,
    	tap_interval = tonumber(core.settings:get(your_mod_name .. ".tap_interval")) or 0.5,
	
}
dg_sprint_core.McSpeed(tonumber(core.settings:get(your_mod_name .. ".set_speed")) or 1.8)
dg_sprint_core.RegisterStep(your_mod_name, "DETECT", tonumber(core.settings:get(your_mod_name .. ".detection_step")) or 0.1, function(player, state, dtime)
	local detected = dg_sprint_core.IsSprintKeyDetected(player, false, settings.double_tap, settings.tap_interval) and dg_sprint_core.ExtraSprintCheck(player) and not (mcl_hunger.get_hunger(player) <= 6)
	if detected ~= state.detected then
		state.detected = detected
	end

end)

dg_sprint_core.RegisterStep(your_mod_name, "SPRINT", tonumber(core.settings:get(your_mod_name .. ".sprint_step")) or 0.2, function(player, state, dtime)
	local detected = state.detected
	if detected ~= state.is_sprinting then
		state.is_sprinting = detected
		dg_sprint_core.McSprint(player, state.is_sprinting)

	end
end)

dg_sprint_core.RegisterStep(your_mod_name, "DRAIN", tonumber(core.settings:get(your_mod_name .. ".drain_step")) or 0.2, function(player, state, dtime)
	if state.is_sprinting and dg_sprint_core.ExtraDrainCheck(player) then
		mcl_hunger.exhaust(player:get_player_name(), mcl_hunger.EXHAUST_SPRINT)
	end
end)
