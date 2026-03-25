dg_sprint_core.ShowParticles = function(pos)
	-- Validate the position argument before proceeding.
    	assert(
        	type(pos) == "table" and
        	type(pos.x) == "number" and
        	type(pos.y) == "number" and
        	type(pos.z) == "number",
        	"dg_sprint_core.ShowParticles: Invalid position argument. Must be a table with numeric fields 'x', 'y', and 'z'."
    	)
	local node = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local def = minetest.registered_nodes[node.name] or {}
    	local drawtype = def.drawtype
    	if drawtype == "airlike" or drawtype == "liquid" or drawtype == "flowingliquid" then return end
	minetest.add_particlespawner({
            	amount = 5,
            	time = 0.01,
            	minpos = {x = pos.x - 0.25, y = pos.y + 0.1, z = pos.z - 0.25},
            	maxpos = {x = pos.x + 0.25, y = pos.y + 0.1, z = pos.z + 0.25},
            	minvel = {x = -0.5, y = 1, z = -0.5},
            	maxvel = {x = 0.5, y = 2, z = 0.5},
            	minacc = {x = 0, y = -5, z = 0},
            	maxacc = {x = 0, y = -12, z = 0},
            	minexptime = 0.25,
            	maxexptime = 0.5,
            	minsize = 0.5,
            	maxsize = 1.0,
            	vertical = false,
            	collisiondetection = false,
            	texture = "default_dirt.png" or "smoke_puff.png",
        })
end
