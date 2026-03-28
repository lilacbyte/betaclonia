local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize

local mod_screwdriver = minetest.get_modpath("screwdriver")
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

minetest.register_node("mcl_nether:glowstone", {
	description = S("Glowstone"),
	_doc_items_longdesc = S("Glowstone is a naturally-glowing block which is home to the Nether."),
	tiles = {"mcl_nether_glowstone.png"},
	groups = {handy=1,building_block=1, material_glass=1},
	drop = {
	max_items = 1,
	items = {
			{items = {"mcl_nether:glowstone_dust 4"}, rarity = 3},
			{items = {"mcl_nether:glowstone_dust 3"}, rarity = 3},
			{items = {"mcl_nether:glowstone_dust 2"}},
		}
	},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"mcl_nether:glowstone_dust"},
		min_count = 2,
		max_count = 4,
		cap = 4,
	}
})

minetest.register_node("mcl_nether:quartz_ore", {
	description = S("Nether Quartz Ore"),
	_doc_items_longdesc = S("Nether quartz ore is an ore containing nether quartz. It is commonly found around netherrack in the Nether."),
	tiles = {"mcl_nether_quartz_ore.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, xp=3},
	drop = "mcl_nether:quartz",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
	_mcl_cooking_output = "mcl_nether:quartz"
})

-- For eternal fire on top of netherrack and magma blocks
-- (this code does not require a dependency on mcl_fire)
local function eternal_after_destruct(pos)
	pos.y = pos.y + 1
	if minetest.get_node(pos).name == "mcl_fire:eternal_fire" then
		minetest.remove_node(pos)
	end
end

local function eternal_on_ignite(player, pointed_thing)
	local pos = pointed_thing.under
	local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	local fn = minetest.get_node(flame_pos)
	local pname = player:get_player_name()
	if minetest.is_protected(flame_pos, pname) then
		minetest.record_protection_violation(flame_pos, pname)
		return
	end
	if fn.name == "air" and pointed_thing.under.y < pointed_thing.above.y then
		minetest.set_node(flame_pos, {name = "mcl_fire:eternal_fire"})
		return true
	else
		return false
	end
end

minetest.register_node("mcl_nether:netherrack", {
	description = S("Netherrack"),
	_doc_items_longdesc = S("Netherrack is a stone-like block home to the Nether. Starting a fire on this block will create an eternal fire."),
	tiles = {"mcl_nether_netherrack.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, enderman_takable=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.4,
	_mcl_hardness = 0.4,
	_mcl_cooking_output = "mcl_nether:netherbrick",

	-- Eternal fire on top
	after_destruct = eternal_after_destruct,
	_on_ignite = eternal_on_ignite,
})

minetest.register_node("mcl_nether:soul_sand", {
	description = S("Soul Sand"),
	_tt_help = S("Reduces walking speed"),
	_doc_items_longdesc = S("Soul sand is a block from the Nether. One can only slowly walk on soul sand. The slowing effect is amplified when the soul sand is on top of ice, packed ice or a slime block."),
	tiles = {"mcl_nether_soul_sand.png"},
	groups = {handy = 1, shovely = 1, building_block = 1, soil_nether_wart = 1, material_sand = 1, soul_block = 1 },
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5 - 2/16, 0.5 },
	},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

mcl_player.register_globalstep_slow(function(player)
	-- Standing on soul sand or soul soil?
	if minetest.get_item_group(mcl_player.players[player].nodes.stand, "soul_block") > 0 then
			-- TODO: Tweak walk speed
			-- TODO: Also slow down mobs
			local boots = player:get_inventory():get_stack("armor", 5)
			local soul_speed = 0
			-- If player wears Soul Speed boots, increase speed
		if soul_speed > 0 then
			playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_sand", soul_speed * 0.105 + 1.3)
		-- otherwise walk slower on soul sand
		elseif mcl_player.players[player].nodes.stand == "mcl_nether:soul_sand" then
			playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_sand", 0.4)
		else
			playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:soul_sand")
		end
	else
		playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:soul_sand")
	end
end)

local nether_brick = {
	description = S("Nether Brick Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_nether_nether_brick.png"},
	is_ground_content = false,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
}

minetest.register_node("mcl_nether:nether_brick", table.merge(nether_brick,{
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
	_mcl_cooking_output = "mcl_nether:cracked_nether_brick"
}))

minetest.register_alias("mcl_nether:chiseled_nether_brick", "mcl_nether:nether_brick")

local cracked_nether_brick = table.copy(nether_brick)
cracked_nether_brick.description = S("Cracked Nether Bricks")
cracked_nether_brick.tiles = {"mcl_nether_cracked_nether_bricks.png"}
minetest.register_node("mcl_nether:cracked_nether_brick", cracked_nether_brick)

minetest.register_node("mcl_nether:quartz_block", {
	description = S("Block of Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
	_mcl_cooking_output = "mcl_nether:quartz_smooth"
})

minetest.register_alias("mcl_nether:quartz_chiseled", "mcl_nether:quartz_block")

minetest.register_node("mcl_nether:quartz_pillar", {
	description = S("Pillar Quartz Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	tiles = {"mcl_nether_quartz_pillar_top.png", "mcl_nether_quartz_pillar_top.png", "mcl_nether_quartz_pillar_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
	_mcl_stonecutter_recipes = { "mcl_nether:quartz_block" },
})
minetest.register_node("mcl_nether:quartz_smooth", {
	description = S("Smooth Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"mcl_nether_quartz_block_bottom.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
	_mcl_stonecutter_recipes = { "mcl_nether:quartz_block" },
})

mcl_stairs.register_stair_and_slab("quartzblock", {
	baseitem = "mcl_nether:quartz_block",
	description_stair = S("Quartz Stairs"),
	description_slab = S("Quartz Slab"),
	recipeitem = "group:quartz_block",
	overrides = {_mcl_stonecutter_recipes = {"mcl_nether:quartz_block"}},
})

mcl_stairs.register_stair_and_slab("quartz_smooth", {
	baseitem = "mcl_nether:quartz_smooth",
	description_stair = S("Smooth Quartz Stairs"),
	description_slab = S("Smooth Quartz Slab"),
	recipeitem = "mcl_nether:quartz_smooth",
	overrides = {_mcl_stonecutter_recipes = {"mcl_nether:quartz_smooth"}},
})

mcl_stairs.register_stair_and_slab("nether_brick", {
	baseitem = "mcl_nether:nether_brick",
	description_stair = S("Nether Brick Stairs"),
	description_slab = S("Nether Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = { "mcl_nether:nether_brick" }},{_mcl_stonecutter_recipes = { "mcl_nether:nether_brick" }},
})

-- Nether Brick Fence (without fence gate!)
mcl_fences.register_fence_def("nether_brick_fence", {
	description = S("Nether Brick Fence"),
	tiles = { "mcl_fences_fence_nether_brick.png" },
	groups = { pickaxey = 1, fence_nether_brick = 1 },
	connects_to = { "group:fence_nether_brick", "group:solid" },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
	_mcl_fences_baseitem = "mcl_nether:nether_brick",
	_mcl_fences_stickreplacer = "mcl_nether:netherbrick",
	_mcl_fences_output_amount = 6
})

minetest.register_craftitem("mcl_nether:glowstone_dust", {
	description = S("Glowstone Dust"),
	_doc_items_longdesc = S("Glowstone dust is the dust which comes out of broken glowstones. It is mainly used in crafting."),
	inventory_image = "mcl_nether_glowstone_dust.png",
	groups = { craftitem=1, brewitem=1 },
})

minetest.register_craftitem("mcl_nether:quartz", {
	description = S("Nether Quartz"),
	_doc_items_longdesc = S("Nether quartz is a versatile crafting ingredient."),
	inventory_image = "mcl_nether_quartz.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_nether:netherbrick", {
	description = S("Nether Brick"),
	_doc_items_longdesc = S("Nether bricks are the main crafting ingredient for crafting nether brick blocks and nether fences."),
	inventory_image = "mcl_nether_netherbrick.png",
	groups = { craftitem = 1 },
})

minetest.register_craft({
	output = "mcl_nether:quartz_block",
	recipe = {
		{"mcl_nether:quartz", "mcl_nether:quartz"},
		{"mcl_nether:quartz", "mcl_nether:quartz"},
	}
})

minetest.register_craft({
	output = "mcl_nether:quartz_pillar 2",
	recipe = {
		{"mcl_nether:quartz_block"},
		{"mcl_nether:quartz_block"},
	}
})

minetest.register_craft({
	output = "mcl_nether:glowstone",
	recipe = {
		{"mcl_nether:glowstone_dust", "mcl_nether:glowstone_dust"},
		{"mcl_nether:glowstone_dust", "mcl_nether:glowstone_dust"},
	}
})

minetest.register_craft({
	output = "mcl_nether:nether_brick",
	recipe = {
		{"mcl_nether:netherbrick", "mcl_nether:netherbrick"},
		{"mcl_nether:netherbrick", "mcl_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = "mcl_nether:nether_wart_block",
	recipe = {
		{"mcl_nether:nether_wart_item", "mcl_nether:nether_wart_item", "mcl_nether:nether_wart_item"},
		{"mcl_nether:nether_wart_item", "mcl_nether:nether_wart_item", "mcl_nether:nether_wart_item"},
		{"mcl_nether:nether_wart_item", "mcl_nether:nether_wart_item", "mcl_nether:nether_wart_item"},
	}
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/nether_wart.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lava.lua")
