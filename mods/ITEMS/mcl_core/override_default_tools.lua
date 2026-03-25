function ccloverridedefaulttools(mtgname, def4)
	local def1 = {
		tool_capabilities = {
			full_punch_interval = 1.1,
			max_drop_level=1,
			groupcaps={
				crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
			},
			damage_groups = {fleshy=3},
		},
	}
	local def2 = def1.tool_capabilities
	local def3 = def2.groupcaps

	def3 = table.merge(def3, def4)
	def2.groupcaps = def3
	def1.tool_capabilities = def2

	minetest.override_item(mtgname, def1)
end


local woodenpick = {
			pickaxey = {times={[3]=1.60}, uses=10, maxlevel=1},
}
local stonepick = {
			pickaxey = {times={[2]=2.0, [3]=1.00}, uses=20, maxlevel=1},
}
local ironpick = {
			pickaxey = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
}
local diamondpick = {
			pickaxey = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
}
ccloverridedefaulttools("default:pick_wood", woodenpick)
ccloverridedefaulttools("default:pick_stone", stonepick)
ccloverridedefaulttools("default:pick_steel", ironpick)
ccloverridedefaulttools("default:pick_diamond", diamondpick)


local woodenshovel = {
			shovely = {times={[1]=3.00, [2]=1.60, [3]=0.60}, uses=10, maxlevel=1},
}
local stoneshovel = {
			shovely = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
}
local ironshovel = {
			shovely = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2},
}
local diamondshovel = {
			shovely = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
}
ccloverridedefaulttools("default:shovel_wood", woodenhovel)
ccloverridedefaulttools("default:shovel_stone", stoneshovel)
ccloverridedefaulttools("default:shovel_steel", ironshovel)
ccloverridedefaulttools("default:shovel_diamond", diamondshovel)

local woodenaxe = {
			axey = {times={[2]=3.00, [3]=1.60}, uses=10, maxlevel=1},
}
local stonenaxe = {
			axey={times={[1]=3.00, [2]=2.00, [3]=1.30}, uses=20, maxlevel=1},
}
local ironnaxe = {
			axey={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=20, maxlevel=2},
}
local diamondaxe = {
			axey={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3},
}
ccloverridedefaulttools("default:axe_wood", woodenaxe)
ccloverridedefaulttools("default:axe_stone", stonenaxe)
ccloverridedefaulttools("default:axe_steel", ironnaxe)
ccloverridedefaulttools("default:axe_diamond", diamondaxe)
--[[
	minetest.override_item("default:shovel_stone", {
		tool_capabilities = {
			full_punch_interval = 1.1,
			max_drop_level=1,
			groupcaps={
				shovely = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2},
			},
			damage_groups = {fleshy=3},
		},
	})
]]
