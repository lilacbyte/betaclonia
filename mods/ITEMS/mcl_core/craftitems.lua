local S = minetest.get_translator(minetest.get_current_modname())

function cclregisterdefaultcraftitems(nameccl, namemtg, defshared, defccl)
	if cclmtgsettingiscompat2enabled and minetest.get_modpath("default") and not minetest.get_modpath("minetest_compatibility_layer_and_port") then
		local def = minetest.registered_items[namemtg]
		local def_groups = def.groups or {}
		defshared.groups = table.merge(defshared.groups, def_groups)
		minetest.register_alias(nameccl, namemtg)
		core.override_item(namemtg, defshared)
	else
		defshared = table.merge(defshared, defccl)
		minetest.register_craftitem(nameccl, defshared)
	end
end

cclregisterdefaultcraftitems("mcl_core:stick", "default:stick", {
	_doc_items_longdesc = S("Sticks are a very versatile crafting material; used in countless crafting recipes."),
	_doc_items_hidden = false,
	groups = { craftitem=1, stick=1 },
	_mcl_toollike_wield = true,
	_mcl_burntime = 5
}, {
	description = S("Stick"),
	inventory_image = "default_stick.png",
})

minetest.register_craftitem("mcl_core:paper", {
	description = S("Paper"),
	_doc_items_longdesc = S("Paper is used to craft books and maps."),
	inventory_image = "default_paper.png",
	groups = { craftitem=1 },
})

cclregisterdefaultcraftitems("mcl_core:coal_lump", "default:coal_lump", {
	_doc_items_longdesc = S("“Coal” refers to coal lumps obtained by digging coal ore which can be found underground. Coal is your standard furnace fuel, but it can also be used to make torches, coal blocks and a few other things."),
	_doc_items_hidden = false,
	groups = { craftitem=1, coal=1 },
	_mcl_burntime = 80
}, {
	description = S("Coal"),
	inventory_image = "default_coal_lump.png",
})

minetest.register_craftitem("mcl_core:charcoal_lump", {
	description = S("Charcoal"),
	_doc_items_longdesc = S("Charcoal is an alternative furnace fuel created by cooking wood in a furnace. It has the same burning time as coal and also shares many of its crafting recipes, but it can not be used to create coal blocks."),
	_doc_items_hidden = false,
	inventory_image = "mcl_core_charcoal.png",
	groups = { craftitem=1, coal=1 },
	_mcl_burntime = 80
})

cclregisterdefaultcraftitems("mcl_core:diamond", "default:diamond", {
	_doc_items_longdesc = S("Diamonds are precious minerals and useful to create the highest tier of armor and tools."),
	groups = { craftitem=1 },
}, {
	description = S("Diamond"),
	inventory_image = "default_diamond.png",
})

cclregisterdefaultcraftitems("mcl_core:clay_lump", "default:clay_lump", {
	_doc_items_longdesc = S("Clay balls are a raw material, mainly used to create bricks in the furnace."),
	_doc_items_hidden = false,
	groups = { craftitem=1 },
	_mcl_cooking_output = "mcl_core:brick"
}, {
	description = S("Clay Ball"),
	inventory_image = "default_clay_lump.png",
})

cclregisterdefaultcraftitems("mcl_core:iron_ingot", "default:steel_ingot", {
	_doc_items_longdesc = S("Molten iron. It is used to craft armor, tools, and whatnot."),
	groups = { craftitem=1 },
}, {
	description = S("Iron Ingot"),
	inventory_image = "default_steel_ingot.png",
})

minetest.register_craftitem("mcl_core:raw_iron", {
	description = S("Raw Iron"),
	_doc_items_longdesc = S("Unrefined iron chunk. Smelt it into an iron ingot."),
	inventory_image = "mcl_raw_ores_raw_iron.png",
	groups = { craftitem = 1, blast_furnace_smeltable = 1 },
	_mcl_cooking_output = "mcl_core:iron_ingot",
})

cclregisterdefaultcraftitems("mcl_core:gold_ingot", "default:gold_ingot", {
	_doc_items_longdesc = S("Molten gold. It is used to craft armor, tools, and whatnot."),
	groups = { craftitem=1 },
}, {
	description = S("Gold Ingot"),
	inventory_image = "default_gold_ingot.png",
})

minetest.register_craftitem("mcl_core:raw_gold", {
	description = S("Raw Gold"),
	_doc_items_longdesc = S("Unrefined gold chunk. Smelt it into a gold ingot."),
	inventory_image = "mcl_raw_ores_raw_gold.png",
	groups = { craftitem = 1, blast_furnace_smeltable = 1 },
	_mcl_cooking_output = "mcl_core:gold_ingot",
})

minetest.register_craftitem("mcl_core:lapis", {
	description = S("Lapis Lazuli"),
	_doc_items_longdesc = S("Lapis Lazuli are required for enchanting items on an enchanting table."),
	inventory_image = "mcl_core_lapis.png",
	groups = { craftitem=1 },
})

cclregisterdefaultcraftitems("mcl_core:brick", "default:clay_brick", {
	_doc_items_longdesc = S("Bricks are used to craft brick blocks."),
	groups = { craftitem=1 },
}, {
	description = S("Brick"),
	inventory_image = "default_clay_brick.png",
})

cclregisterdefaultcraftitems("mcl_core:flint", "default:flint", {
	_doc_items_longdesc = S("Flint is a raw material."),
	groups = { craftitem=1 },
}, {
	description = S("Flint"),
	inventory_image = "default_flint.png",
})

minetest.register_craftitem("mcl_core:sugar", {
	description = S("Sugar"),
	_doc_items_longdesc = S("Sugar comes from sugar canes and is used to make sweet foods."),
	inventory_image = "mcl_core_sugar.png",
	groups = { craftitem = 1, brewitem=1 },
})

minetest.register_craftitem("mcl_core:bowl",{
	description = S("Bowl"),
	_doc_items_longdesc = S("Bowls are mainly used to hold tasty soups."),
	inventory_image = "mcl_core_bowl.png",
	groups = { craftitem = 1 },
	_mcl_burntime = 10
})

cclregisterdefaultcraftitems("mcl_core:apple", "default:apple", {
	_doc_items_longdesc = S("Apples are food items which can be eaten."),
	wield_image = "default_apple.png",
	on_secondary_use = minetest.item_eat(10),
	groups = { eatable = 10, compostability = 65 },
}, {
	description = S("Apple"),
	inventory_image = "default_apple.png",
	on_place = minetest.item_eat(10),
})

local gapple_hunger_restore = minetest.item_eat(20)

local function eat_gapple(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	if pointed_thing.type == "object" then
		return itemstack
	end

	return gapple_hunger_restore(itemstack, placer, pointed_thing)
end

minetest.register_craftitem("mcl_core:apple_gold", {
	description = S("Golden Apple"),
	_doc_items_longdesc = S("Golden apples are precious food items which can be eaten."),
	wield_image = "mcl_core_apple_golden.png",
	inventory_image = "mcl_core_apple_golden.png",
	on_place = eat_gapple,
	on_secondary_use = eat_gapple,
	groups = { eatable = 20, can_eat_when_full = 1, rarity = 2 },
})
