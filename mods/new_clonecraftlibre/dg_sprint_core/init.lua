dg_sprint_core = {}

--[[ START LIB INIT ]]--
local mod_name = core.get_current_modname()

local mod_dir = core.get_modpath(mod_name) .. "/"

local lib_dir = mod_dir .. "Library/"

dofile(lib_dir .. "init.lua")
--[[ END LIB INIT ]]

--[[
local your_mod_name = core.get_current_modname()

local settings = {
	enable_sprint = true,
    	aux1 = true,
    	double_tap = true,
    	particles = true,
    	tap_interval = 0.5,
}

dg_sprint_core.RegisterStep(your_mod_name, "DETECT", 0.1, function(player, state, dtime)

	local detected = dg_sprint_core.IsSprintKeyDetected(player, settings.aux1, settings.double_tap, settings.tap_interval) and dg_sprint_core.IsMoving(player)
	
	if detected ~= state.detected then
		state.detected = detected
	end

end)

dg_sprint_core.RegisterStep(your_mod_name, "SPRINT", 0.5, function(player, state, dtime)
	local detected = state.detected

	if detected then
		dg_sprint_core.ShowParticles(player:get_pos())
	end

	dg_sprint_core.Sprint(your_mod_name, player, detected, {speed = 0.8, jump = 0.1})
	
	if detected ~= state.is_sprinting then
		state.is_sprinting = detected
	end
	
end)

dg_sprint_core.RegisterStep(your_mod_name, "DRAIN", 0.2, function(player, state, dtime)
	local is_sprinting = state.is_sprinting
	if dg_sprint_core.ExtraDrainCheck(player) then
		state.is_draining = true
	end
end)

]]--
