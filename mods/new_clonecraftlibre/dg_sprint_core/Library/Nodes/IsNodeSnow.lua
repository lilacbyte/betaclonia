 
dg_sprint_core.IsNodeSnow = function(player, altPos)
	local def = dg_sprint_core.GetNodeDefinition(player, altPos)
	if def and def.groups and def.groups and def.groups.snowy and def.groups.snowy > 0  then
		return true
	end
	return false
end
