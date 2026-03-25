local server_steps = {}

local function validate_step_parameters(mod_name, step_name, step_interval, step_callback)
	assert(type(step_name) == "string", "Step name must be a string.")
    	assert(type(step_interval) == "number" and step_interval > 0, "Interval must be a positive number.")
    	assert(type(step_callback) == "function", "Callback must be a function.")
end

dg_sprint_core.RegisterStep = function(mod_name, step_name, step_interval, step_callback)
    	validate_step_parameters(mod_name, step_name, step_interval, step_callback)
    	if not server_steps[mod_name] then
        	server_steps[mod_name] = {}
    	end
    	if server_steps[mod_name][step_name] then
        	error("Step with name '" .. step_name .. "' already exists for mod '" .. mod_name .. "'.")
    	end
    	server_steps[mod_name][step_name] = {
        	interval = step_interval,
        	elapsed = 0,
        	callback = step_callback
    	}
end


local player_info = {}
local player_states = {}

core.register_on_joinplayer(function(player, last_login)
    	if not player then return end
    	local name = player:get_player_name()
    	if not player_states[name] then
        	player_states[name] = {}
    	end 
end)

core.register_on_leaveplayer(function(player)
    	if not player then return end
    	local name = player:get_player_name()
    	player_states[name] = nil
end)


core.register_globalstep(function(dtime)
    	for mod, steps in pairs(server_steps) do
        	for step_name, tick in pairs(steps) do
            		tick.elapsed = tick.elapsed + dtime
            		if tick.elapsed >= tick.interval then
                		local players = core.get_connected_players()
                		for _, player in ipairs(players) do
                    			local name = player:get_player_name()
                    			if player_states[name] then
                        			local p_states = player_states[name]
                        			tick.callback(player, p_states, dtime)
                        			tick.elapsed = tick.elapsed - tick.interval
                    			end
                		end
            		end
        	end
    	end
end)
