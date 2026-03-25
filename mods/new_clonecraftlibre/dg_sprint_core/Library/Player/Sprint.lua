
local mod_name = core.get_current_modname()
local pova_mod = core.get_modpath("pova") and core.global_exists("pova")
local armor_mod = core.get_modpath("3d_armor") and core.global_exists("armor") and armor.def
local p_monoids = core.get_modpath("player_monoids") and core.global_exists("player_monoids")




----------------------------------------------------------------------------------------------------------------------------------------------------------
--[[ API ]]--

dg_sprint_core.Sprint = function(mod_name, player, sprinting, physics_table)
	-- Validate inputs.
    	assert(type(mod_name) == "string" and mod_name ~= "", "dg_sprint_core.Sprint: 'mod_name' must be a non-empty string.")
    	assert(type(sprinting) == "boolean", "dg_sprint_core.Sprint: 'sprinting' must be a boolean.")
    	assert(type(physics_table) == "table", "dg_sprint_core.Sprint: 'physics_table' must be a table.")
    	assert(type(physics_table.speed) == "number", "dg_sprint_core.Sprint: 'physics_table.speed' must be a number.")
    	assert(type(physics_table.jump) == "number", "dg_sprint_core.Sprint: 'physics_table.jump' must be a number.")

    	local adj_name = mod_name .. ":physics"

    	if p_monoids then
        	if sprinting then
            		player_monoids.speed:add_change(player, 1 + physics_table.speed, adj_name)
            		player_monoids.jump:add_change(player, 1 + physics_table.jump, adj_name)
        	else
            		player_monoids.speed:del_change(player, adj_name)
            		player_monoids.jump:del_change(player, adj_name)
        	end
    	elseif pova_mod then
        	if sprinting then
            		pova.add_override(player:get_player_name(), adj_name, {speed = physics_table.speed, jump = physics_table.jump})
            		pova.do_override(player)
        	else
            		pova.del_override(player:get_player_name(), adj_name)
            		pova.do_override(player)
        	end
    	else
        	local def
        	if armor_mod then
            		local name = player:get_player_name()
            		def = {
                		speed = armor.def[name].speed,
                		jump = armor.def[name].jump,
                		gravity = armor.def[name].gravity
            		}
        	else
            		def = {
                		speed = 1,
                		jump = 1,
                		gravity = 1
            		}
        	end
        	if sprinting then
            		def.speed = def.speed + physics_table.speed
            		def.jump = def.jump + physics_table.jump
        	end
        	player:set_physics_override(def)
    end
end

dg_sprint_core.VoxeLibreSprint = function(player, sprint)
	if sprint then
		playerphysics.add_physics_factor(player, "speed", "mcl_sprint:sprint", mcl_sprint.SPEED)
            	mcl_fovapi.apply_modifier(player, "sprint")
        else
            	playerphysics.remove_physics_factor(player, "speed", "mcl_sprint:sprint")
            	mcl_fovapi.remove_modifier(player, "sprint")
        end
end

dg_sprint_core.McSprint = function(player, sprinting)
	if sprinting then
		playerphysics.add_physics_factor(player, "speed", "mcl_sprint:sprint", mcl_sprint.SPEED)
		playerphysics.add_physics_factor(player, "fov", "mcl_sprint:sprint", 1.1)
	else
		playerphysics.remove_physics_factor(player, "speed", "mcl_sprint:sprint")
		playerphysics.remove_physics_factor(player, "fov", "mcl_sprint:sprint")
	end
end

dg_sprint_core.McSpeed = function(speed)
	assert(type(speed) == "number", "dg_sprint_core.McSpeed: 'speed' must be a number.")
	mcl_sprint.SPEED = speed
end
