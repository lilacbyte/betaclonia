dg_sprint_core.IsMoving = function(player)
	local p_pos = player:get_pos()
	local controls = player:get_player_control()
        local is_moving = controls.up or controls.down or controls.left or controls.right
        local velocity = player:get_velocity()  
        velocity.y = 0
        local horizontal_speed = vector.length(velocity)
	local has_velocity = horizontal_speed > 0.05
	local is_moving = true
        if not (is_moving and has_velocity) then
		is_moving = false
	end
	return is_moving
end
