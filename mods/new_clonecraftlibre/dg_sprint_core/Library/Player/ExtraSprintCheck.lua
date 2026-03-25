dg_sprint_core.ExtraSprintCheck = function(player)
	return dg_sprint_core.IsMoving(player) and not player:get_attach()
end
