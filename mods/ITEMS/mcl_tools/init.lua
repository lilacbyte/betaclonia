local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

mcl_tools = {}
mcl_tools.sets = {}

mcl_reinforced = rawget(_G, "mcl_reinforced") or {}
mcl_reinforced.keep_chance = mcl_reinforced.keep_chance or {
	[1] = 0.50, -- Reinforced I
	[3] = 1.5/3,  -- Reinforced III (close to Unbreaking II)
	[5] = 5/6,  -- Reinforced V
}

function mcl_reinforced.get_tier(itemname)
	local seen = {}
	while itemname and minetest.registered_aliases[itemname] and not seen[itemname] do
		seen[itemname] = true
		itemname = minetest.registered_aliases[itemname]
	end
	local def = itemname and minetest.registered_items[itemname]
	local groups = def and def.groups
	if not groups then
		return nil
	end
	if (groups.reinforced_5 or 0) > 0 then
		return 5
	end
	if (groups.reinforced_3 or 0) > 0 then
		return 3
	end
	if (groups.reinforced_1 or 0) > 0 then
		return 1
	end
	return nil
end

function mcl_reinforced.adjust_wear(itemstack, wear)
	if not itemstack or itemstack:is_empty() or not wear or wear <= 0 then
		return wear
	end
	local tier = mcl_reinforced.get_tier(itemstack:get_name())
	if not tier then
		return wear
	end
	local keep = mcl_reinforced.keep_chance[tier] or 0
	if keep <= 0 then
		return wear
	end
	if math.random() < keep then
		return 0
	end
	return wear
end

mcl_tools.commondefs = {
	["axe"] = {
		longdesc = S("An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow. Axes can be used to strip bark and hyphae from trunks. They can also be used to scrape blocks made of copper, reducing their oxidation stage or removing wax from waxed variants."),
		usagehelp = S("To strip bark from trunks and hyphae, use the ax by right-clicking on them. To reduce an oxidation stage from a block made of copper or remove wax from waxed variants, right-click on them. Doors and trapdoors also require you to hold down the sneak key while using the axe."),
		groups = { axe = 1, tool = 1 },
		diggroups = { axey = {} },
		craft_shapes = {
			{
				{ "material", "material" },
				{ "mcl_core:stick", "material" },
				{ "mcl_core:stick", "" }
			},
			{
				{ "material", "material" },
				{ "material", "mcl_core:stick" },
				{ "", "mcl_core:stick" }
			}
		}
	},
	["hoe"] = {
		longdesc = S("Hoes are essential tools for growing crops. They are used to create farmland in order to plant seeds on it. Hoes can also be used as very weak weapons in a pinch."),
		usagehelp = S("Use the hoe on a cultivatable block (by rightclicking it) to turn it into farmland. Dirt, grass blocks and grass paths are cultivatable blocks."),
		groups = { hoe = 1, tool = 1 },
		diggroups = { hoey = {} },
		craft_shapes = {
			{
				{ "material", "material" },
				{ "mcl_core:stick", "" },
				{ "mcl_core:stick", "" }
			},
			{
				{ "material", "material" },
				{ "", "mcl_core:stick" },
				{ "", "mcl_core:stick" }
			}
		}
	},
	["pick"] = {
		longdesc = S("Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient."),
		groups = { pickaxe = 1, tool = 1 },
		diggroups = { pickaxey = {} },
		craft_shapes = {
			{
				{ "material", "material", "material" },
				{ "", "mcl_core:stick", "" },
				{ "", "mcl_core:stick", "" }
			}
		}
	},
	["shovel"] = {
		longdesc = S("Shovels are tools for digging coarse blocks, such as dirt, sand and gravel. They can also be used to turn grass blocks to grass paths. Shovels can be used as weapons, but they are very weak."),
		usagehelp = S("To turn a grass block into a grass path, hold the shovel in your hand, then use (rightclick) the top or side of a grass block. This only works when there's air above the grass block."),
		groups = { shovel = 1, tool = 1 },
		diggroups = { shovely = {} },
		craft_shapes = {
			{
				{ "material" },
				{ "mcl_core:stick" },
				{ "mcl_core:stick" }
			}
		}
	},
	["sword"] = {
		longdesc = S("Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs."),
		groups = { sword = 1, weapon = 1 },
		diggroups = { swordy = {}, swordy_cobweb = {} },
		craft_shapes = {
			{
				{ "material" },
				{ "material" },
				{ "mcl_core:stick" }
			}
		}
	}
}

local shears_longdesc = S("Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from grass, leaves and similar blocks that require cutting.")
local shears_use = S("To shear sheep or carve faceless pumpkins, use the “place” key on them. Faces can only be carved at the side of faceless pumpkins. Mining works as usual, but the drops are different for a few blocks.")

local wield_scale = mcl_vars.tool_wield_scale

local function on_tool_place(itemstack, placer, pointed_thing, tool)
	if pointed_thing.type ~= "node" then return end

	local node = minetest.get_node(pointed_thing.under)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef then
		return
	end

	if not placer:get_player_control().sneak and ndef.on_rightclick then
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
	if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
		return itemstack
	end

	if itemstack and type(ndef["_on_"..tool.."_place"]) == "function" then
		local itemstack, no_wear = ndef["_on_"..tool.."_place"](itemstack, placer, pointed_thing)
		if minetest.is_creative_enabled(placer:get_player_name()) or no_wear or not itemstack then
			return itemstack
		end

		-- Add wear using the usages of the tool defined in
		-- _mcl_diggroups. This assumes the tool only has one diggroups
		-- (which is the case in Mineclone).
			local tdef = minetest.registered_tools[itemstack:get_name()]
			if tdef and tdef._mcl_diggroups then
				for group, _ in pairs(tdef._mcl_diggroups) do
					local wear = mcl_autogroup.get_wear(itemstack:get_name(), group)
					wear = mcl_reinforced.adjust_wear(itemstack, wear)
					if wear and wear > 0 then
						itemstack:add_wear(wear)
					end
					return itemstack
				end
			end
		return itemstack
	end

	--mcl_offhand.place(placer, pointed_thing)--removed new

	return itemstack
end

mcl_tools.tool_place_funcs = {}

for _,tool in pairs({"shovel","shears","axe","sword","pick"}) do
	mcl_tools.tool_place_funcs[tool] = function(itemstack,placer,pointed_thing)
		return on_tool_place(itemstack,placer,pointed_thing,tool)
	end
end

local function get_tool_diggroups(materialdefs, toolname)
	local diggroups = mcl_tools.commondefs[toolname].diggroups

	for _, diggroup in pairs(diggroups) do
		diggroup.speed = materialdefs.speed
		diggroup.level = materialdefs.level
		diggroup.uses = materialdefs.uses
	end

	return diggroups
end

local function replace_material_tag(shape, material)
	local recipe = table.copy(shape)

	for _, line in ipairs(recipe) do
		for count, tag in ipairs(line) do
			if tag == "material" then
				line[count] = material
			end
		end
	end

	return recipe
end

local function get_punch_uses(toolname, materialdefs)
	if toolname == "sword" then return materialdefs.uses end
	return materialdefs.uses / 2
end

local function register_tool(setname, materialdefs, toolname, tooldefs, overrides)
	local mod = minetest.get_current_modname()
	local itemstring = mod..":"..toolname.."_"..setname
	local commondefs = mcl_tools.commondefs[toolname]
	local effect_desc = tooldefs.effect_desc or materialdefs.effect_desc
	local tt_help = tooldefs._tt_help
	local longdesc = commondefs.longdesc
	if effect_desc and effect_desc ~= "" then
		longdesc = longdesc .. "\n\n" .. effect_desc
		if tt_help and tt_help ~= "" then
			tt_help = tt_help .. "\n" .. effect_desc
		else
			tt_help = effect_desc
		end
	end
	local tcs = table.copy(tooldefs.tool_capabilities or {})
	tooldefs.tool_capabilities = nil
	tooldefs.effect_desc = nil
	local tooldefs = table.merge({
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = commondefs.usagehelp,
		_tt_help = tt_help,
		_mcl_effect_desc = effect_desc,
		_mcl_diggroups = get_tool_diggroups(materialdefs, toolname),
		_mcl_toollike_wield = true,
		_repair_material = materialdefs.material,
		groups = table.merge(commondefs.groups, materialdefs.groups, { offhand_item = 1 }),
		tool_capabilities = table.merge(tcs, {
			max_drop_level = materialdefs.max_drop_level,
			punch_attack_uses = get_punch_uses(toolname, materialdefs)
		}),
		on_place = mcl_tools.tool_place_funcs[toolname],
		sound = { breaks = "default_tool_breaks" },
		wield_scale = wield_scale
	}, tooldefs, overrides or {})

	minetest.register_tool(itemstring, tooldefs)

	if materialdefs.craftable then
		for _, shapes in ipairs(mcl_tools.commondefs[toolname].craft_shapes) do
			local recipe = replace_material_tag(shapes, materialdefs.material)

			minetest.register_craft({
				output = itemstring,
				recipe = recipe
			})
		end
	end
end

---Used to add a new tool to all existing material sets. See [API.md](API.md) for more information.
---@param toolname string
---@param commondefs table
---@param tools table
---@param overrides table|nil
function mcl_tools.add_to_sets(toolname, commondefs, tools, overrides)
	if not mcl_tools.commondefs[toolname] then
		mcl_tools.commondefs[toolname] = commondefs
	end

	for setname, _ in pairs(mcl_tools.sets) do
		local materialdefs = mcl_tools.sets[setname]
		local tooldefs = tools[setname]

		register_tool(setname, materialdefs, toolname, tooldefs, overrides)
	end
end

---Used to add a set of tools to a material. See [API.md](API.md) for more information.
---@param setname string
---@param materialdefs table
---@param tools table
---@param overrides table|nil
function mcl_tools.register_set(setname, materialdefs, tools, overrides)
	if not mcl_tools.sets[setname] then
		mcl_tools.sets[setname] = materialdefs
	end

	for tool, defs in pairs(tools) do
		register_tool(setname, materialdefs, tool, defs, overrides)
	end
end

--Shears
minetest.register_tool("mcl_tools:shears", {
	description = S("Shears"),
	_doc_items_longdesc = shears_longdesc,
	_doc_items_usagehelp = shears_use,
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	groups = { tool=1, shears=1, dig_speed_class=4, enchantability=-1, offhand_item = 1 },
	tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level=1,
	},
	on_place = mcl_tools.tool_place_funcs.shears,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shearsy = { speed = 1.5, level = 1, uses = 238 },
		shearsy_wool = { speed = 5, level = 1, uses = 238 },
		shearsy_cobweb = { speed = 15, level = 1, uses = 238 }
	},
})

minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "mcl_core:iron_ingot", "" },
		{ "", "mcl_core:iron_ingot", },
	}
})

minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "" },
	}
})

local function resolve_alias(name)
	local seen = {}
	while name and minetest.registered_aliases[name] and not seen[name] do
		seen[name] = true
		name = minetest.registered_aliases[name]
	end
	return name
end

-- Engine applies dig wear directly from toolcaps. Reinforced tools refund
-- wear based on their tier chance after each successful dig.
minetest.register_on_dignode(function(_, oldnode, digger)
	if not digger or not digger:is_player() or not oldnode then
		return
	end
	local player_name = digger:get_player_name()
	if player_name == "" or minetest.is_creative_enabled(player_name) then
		return
	end

	local wield = digger:get_wielded_item()
	if wield:is_empty() then
		return
	end
	local tool_name = resolve_alias(wield:get_name())
	local tier = mcl_reinforced.get_tier(tool_name)

	local tdef = minetest.registered_tools[tool_name]
	local ndef = minetest.registered_nodes[oldnode.name]
	if not tdef or not ndef or not tdef._mcl_diggroups or not ndef.groups then
		return
	end

	local matched_group = nil
	for group, _ in pairs(tdef._mcl_diggroups) do
		if (ndef.groups[group] or 0) > 0 then
			matched_group = group
			break
		end
	end

	if matched_group then
		-- Proper tool-group dig:
		-- engine already applied wear; reinforced tiers partially refund it.
		if tier then
			local wear = mcl_autogroup.get_wear(tool_name, matched_group)
			local adjusted = mcl_reinforced.adjust_wear(wield, wear)
			local refund = (wear or 0) - (adjusted or 0)
			if refund > 0 then
				wield:set_wear(math.max(0, wield:get_wear() - refund))
				digger:set_wielded_item(wield)
			end
		end
		return
	end

	-- Wrong-tool dig:
	-- if a tool still breaks a block outside its dig groups, consume durability.
	mcl_util.use_item_durability(wield, 1)
	digger:set_wielded_item(wield)
end)

--dofile(modpath.."/mace.lua")--removed
dofile(modpath.."/register.lua")
