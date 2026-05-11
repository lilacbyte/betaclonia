mcl_damage.register_modifier(function(obj, damage, reason)
	if false and reason.type == "player" then
		local hitter = reason.direct
		obj:add_velocity(hitter:get_velocity())
	end
end, -100)
