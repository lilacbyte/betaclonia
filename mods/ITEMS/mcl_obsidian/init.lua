local S = minetest.get_translator(minetest.get_current_modname())

local tools_registered = false
local function register_obsidian_tools()
	if tools_registered then
		return
	end
	if not (mcl_tools and mcl_tools.register_set) then
		return
	end

	mcl_tools.register_set("obsidian", {
		craftable = true,
		material = "mcl_core:obsidian",
		uses = 1024,
		level = 5,
		speed = 4,
		max_drop_level = 5,
		groups = { dig_class_speed = 3, enchantability = 5, reinforced_5 = 1 },
		effect_desc = S("Effect: Reinforced V"),
	}, {
		["pick"] = {
			description = S("Obsidian Pickaxe"),
			inventory_image = "obsidian_pickaxe.png",
			tool_capabilities = {
				full_punch_interval = 0.83333333,
				damage_groups = { fleshy = 3 },
			},
		},
		["shovel"] = {
			description = S("Obsidian Shovel"),
			inventory_image = "obsidian_shovel.png",
			tool_capabilities = {
				full_punch_interval = 1,
				damage_groups = { fleshy = 3 },
			},
		},
		["sword"] = {
			description = S("Obsidian Sword"),
			inventory_image = "obsidian_sword.png",
			tool_capabilities = {
				full_punch_interval = 0.625,
				damage_groups = { fleshy = 5 },
			},
		},
		["axe"] = {
			description = S("Obsidian Axe"),
			inventory_image = "obsidian_axe.png",
			tool_capabilities = {
				full_punch_interval = 1.25,
				damage_groups = { fleshy = 9 },
			},
		},
	}, {})

	tools_registered = true
end

register_obsidian_tools()

minetest.register_on_mods_loaded(function()
	register_obsidian_tools()
end)
