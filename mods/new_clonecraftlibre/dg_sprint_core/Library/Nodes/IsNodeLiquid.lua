dg_sprint_core.IsNodeLiquid = function(player, altPos)
	local def = dg_sprint_core.GetNodeDefinition(player, altPos)
	if def and ( def.drawtype == "liquid" or def.drawtype == "flowingliquid" ) then
		return true
	end
	return false
end
