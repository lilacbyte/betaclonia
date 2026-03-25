mcl_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "player" then
		local hitter = reason.direct
		if mcl_sprint.is_sprinting(hitter) then
			obj:add_velocity(hitter:get_velocity())
		end
	end
end, -100)
