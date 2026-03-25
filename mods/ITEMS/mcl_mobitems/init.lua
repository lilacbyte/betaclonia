local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize

minetest.register_craftitem("mcl_mobitems:beef", {
	description = S("Raw Meat"),
	_doc_items_longdesc = S("Raw meat can be eaten safely. Cooking it will greatly increase its nutritional value."),
	inventory_image = "mcl_mobitems_beef_raw.png",
	wield_image = "mcl_mobitems_beef_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 1.8,
	_mcl_cooking_output = "mcl_mobitems:cooked_beef"
})

minetest.register_craftitem("mcl_mobitems:cooked_beef", {
	description = S("Meat"),
	_doc_items_longdesc = S("Cooked meat is a food item and can be eaten."),
	inventory_image = "mcl_mobitems_beef_cooked.png",
	wield_image = "mcl_mobitems_beef_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
	_mcl_saturation = 12.8,
})


-- Reset food poisoning and status effects
local function drink_milk(itemstack, player, pointed_thing)
	local bucket = minetest.do_item_eat(0, "mcl_buckets:bucket_empty", itemstack, player, pointed_thing)
	-- Check if we were allowed to drink this (eat delay check)
	if mcl_hunger.active and (bucket:get_name() ~= "mcl_mobitems:milk_bucket" or minetest.is_creative_enabled(player:get_player_name())) then
		mcl_hunger.stop_poison(player)
	end
	return bucket
end

minetest.register_craftitem("mcl_mobitems:milk_bucket", {
	description = S("Milk"),
	_tt_help = C(mcl_colors.GREEN, S("Stops food poisoning")),
	_doc_items_longdesc = S("Milk is very refreshing and can be obtained by using a bucket on a cow. Drinking it stops food poisoning, but restores no hunger points."),
	_doc_items_usagehelp = S("Use the placement key to drink the milk."),
	inventory_image = "mcl_mobitems_bucket_milk.png",
	wield_image = "mcl_mobitems_bucket_milk.png",
	on_place = drink_milk,
	on_secondary_use = drink_milk,
	stack_max = 1,
	groups = { food = 3, can_eat_when_full = 1 },
})

minetest.register_craftitem("mcl_mobitems:bone", {
	description = S("Bone"),
	_doc_items_longdesc = S("Bones can be used to tame wolves so they will protect you. They are also useful as a crafting ingredient."),
	_doc_items_usagehelp = S("Wield the bone near wolves to attract them. Use the “Place” key on the wolf to give it a bone and tame it. You can then give commands to the tamed wolf by using the “Place” key on it."),
	inventory_image = "mcl_mobitems_bone.png",
	groups = { craftitem=1 },
	_mcl_toollike_wield = true,
})

minetest.register_craftitem("mcl_mobitems:ink_sac", {
	description = S("Squid Ink Sac"),
	_doc_items_longdesc = S("This item is dropped by dead squids. Squid ink can be used to as an ingredient to craft book and quill or black dye."),
	inventory_image = "mcl_mobitems_ink_sac.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:string",{
	description = S("String"),
	_doc_items_longdesc = S("Strings are used in crafting."),
	inventory_image = "mcl_mobitems_string.png",
	groups = { craftitem = 1 },
})


minetest.register_craftitem("mcl_mobitems:leather", {
	description = S("Leather"),
	_doc_items_longdesc = S("Leather is a versatile crafting component."),
	wield_image = "mcl_mobitems_leather.png",
	inventory_image = "mcl_mobitems_leather.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:feather", {
	description = S("Feather"),
	_doc_items_longdesc = S("Feathers are used in crafting and are dropped from chickens."),
	wield_image = "mcl_mobitems_feather.png",
	inventory_image = "mcl_mobitems_feather.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:rabbit_hide", {
	description = S("Rabbit Hide"),
	_doc_items_longdesc = S("Rabbit hide is used to create leather."),
	wield_image = "mcl_mobitems_rabbit_hide.png",
	inventory_image = "mcl_mobitems_rabbit_hide.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:saddle", {
	description = S("Saddle"),
	_tt_help = S("Can be placed on animals to ride them"),
	_doc_items_longdesc = S("Saddles can be put on some animals in order to mount them."),
	_doc_items_usagehelp = S("Use the placement key with the saddle in your hand to try to put on the saddle. Saddles fit on horses, mules, donkeys and pigs. Horses, mules and donkeys need to be tamed first, otherwise they'll reject the saddle. Saddled animals can be mounted by using the placement key on them again."),
	wield_image = "mcl_mobitems_saddle.png",
	inventory_image = "mcl_mobitems_saddle.png",
	groups = { transport = 1 },
	stack_max = 1,
})

minetest.register_craftitem("mcl_mobitems:slimeball", {
	description = S("Slimeball"),
	_doc_items_longdesc = S("Slimeballs are used in crafting. They are dropped from slimes."),
	inventory_image = "mcl_mobitems_slimeball.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:gunpowder", {
	description = S("Gunpowder"),
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	inventory_image = "default_gunpowder.png",
	groups = { craftitem=1, brewitem = 1 },
})

minetest.register_tool("mcl_mobitems:carrot_on_a_stick", {
	description = S("Carrot on a Stick"),
	_tt_help = S("Lets you ride a saddled pig"),
	_doc_items_longdesc = S("A carrot on a stick can be used on saddled pigs to ride them."),
	_doc_items_usagehelp = S("Place it on a saddled pig to mount it. You can now ride the pig like a horse. Pigs will also walk towards you when you just wield the carrot on a stick."),
	wield_image = "mcl_mobitems_carrot_on_a_stick.png^[transformFY^[transformR90",
	inventory_image = "mcl_mobitems_carrot_on_a_stick.png",
	groups = { transport = 1 },
	_mcl_toollike_wield = true,
})

local horse_armor_use = S("Place it on a horse to put on the horse armor. Donkeys and mules can't wear horse armor.")

-- https://The OG Game wiki/w/Armor#Damage_reduction

minetest.register_craftitem("mcl_mobitems:leather_horse_armor", {
	description = S("Leather Horse Armor"),
	_doc_items_longdesc = S("Leather horse armor can be worn by horses to increase their protection from harm a little."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_leather_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_leather.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
	},
	stack_max = 1,
	groups = { horse_armor = 88, armor_leather = 2 },
})


minetest.register_craftitem("mcl_mobitems:iron_horse_armor", {
	description = S("Iron Horse Armor"),
	_doc_items_longdesc = S("Iron horse armor can be worn by horses to increase their protection from harm a bit."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_iron_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_iron.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
	},
	stack_max = 1,
	groups = { horse_armor = 85 },
	_mcl_cooking_output = "mcl_core:iron_ingot"
})


minetest.register_craftitem("mcl_mobitems:gold_horse_armor", {
	description = S("Golden Horse Armor"),
	_doc_items_longdesc = S("Golden horse armor can be worn by horses to increase their protection from harm."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_gold_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_gold.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
	},
	stack_max = 1,
	groups = { horse_armor = 60 },
	_mcl_cooking_output = "mcl_core:gold_nugget"
})

minetest.register_craftitem("mcl_mobitems:diamond_horse_armor", {
	description = S("Diamond Horse Armor"),
	_doc_items_longdesc = S("Diamond horse armor can be worn by horses to greatly increase their protection from harm."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_diamond_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_diamond.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
	},
	stack_max = 1,
	groups = { horse_armor = 56 },
})

minetest.register_alias("mobs_mc:iron_horse_armor", "mcl_mobitems:iron_horse_armor")
minetest.register_alias("mobs_mc:gold_horse_armor", "mcl_mobitems:gold_horse_armor")
minetest.register_alias("mobs_mc:diamond_horse_armor", "mcl_mobitems:diamond_horse_armor")

-----------
-- Crafting
-----------

minetest.register_craft({
	output = "mcl_mobitems:leather",
	recipe = {
		{ "mcl_mobitems:rabbit_hide", "mcl_mobitems:rabbit_hide" },
		{ "mcl_mobitems:rabbit_hide", "mcl_mobitems:rabbit_hide" },
	}
})

minetest.register_craft({
	output = "mcl_mobitems:carrot_on_a_stick",
	recipe = {
		{ "mcl_fishing:fishing_rod", "", },
		{ "", "mcl_farming:carrot_item" },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:carrot_on_a_stick",
	recipe = {
		{ "", "mcl_fishing:fishing_rod", },
		{ "mcl_farming:carrot_item", "" },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:leather_horse_armor",
	recipe = {{"mcl_mobitems:leather","","mcl_mobitems:leather",},
		{"mcl_mobitems:leather","mcl_mobitems:leather","mcl_mobitems:leather",},
		{"mcl_mobitems:leather","","mcl_mobitems:leather",}},
})

minetest.register_craft({
	output = "mcl_mobitems:leather_horse_armor",
	type = "shapeless",
	recipe = {"mcl_mobitems:leather_horse_armor", "group:dye" },
})
