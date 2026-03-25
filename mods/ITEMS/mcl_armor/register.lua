local S = minetest.get_translator(minetest.get_current_modname())

mcl_armor.register_set({
	name = "gold",
	descriptions = {
		head = S("Golden Helmet"),
		torso = S("Golden Chestplate"),
		legs = S("Golden Leggings"),
		feet = S("Golden Boots"),
	},
	durability = 112,
	points = {
		head = 1,
		torso = 2,
		legs = 2,
		feet = 1,
	},
	craft_material = "mcl_core:gold_ingot",
	cook_material = "mcl_core:gold_nugget",
	sound_equip = "mcl_armor_equip_iron",
	sound_unequip = "mcl_armor_unequip_iron",
	effect_desc = S("While worn: Strongly reduces fall damage"),
	groups = {
		golden = 1,
	},
})

mcl_armor.register_set({
	name = "iron",
	descriptions = {
		head = S("Iron Helmet"),
		torso = S("Iron Chestplate"),
		legs = S("Iron Leggings"),
		feet = S("Iron Boots"),
	},
	durability = 200,
	points = {
		head = 2,
		torso = 3,
		legs = 2,
		feet = 1,
	},
	craft_material = "mcl_core:iron_ingot",
	cook_material = "mcl_core:iron_ingot",
	sound_equip = "mcl_armor_equip_iron",
	sound_unequip = "mcl_armor_unequip_iron"
})

if minetest.get_modpath("mcl_copper") then
mcl_armor.register_set({
	name = "copper",
	descriptions = {
		head = S("Copper Helmet"),
		torso = S("Copper Chestplate"),
		legs = S("Copper Leggings"),
		feet = S("Copper Boots"),
	},
	durability = 176,
	points = {
		head = 1,
		torso = 2,
		legs = 2,
		feet = 1,
	},
	craft_material = "mcl_copper:copper_ingot",
	cook_material = "mcl_copper:copper_nugget",
	sound_equip = "mcl_armor_equip_iron",
	sound_unequip = "mcl_armor_unequip_iron",
		effect_desc = S("While worn: Reduces fire damage.")
	})
end

mcl_armor.register_set({
	name = "diamond",
	descriptions = {
		head = S("Diamond Helmet"),
		torso = S("Diamond Chestplate"),
		legs = S("Diamond Leggings"),
		feet = S("Diamond Boots"),
	},
	durability = 420,
	points = {
		head = 2,
		torso = 4,
		legs = 3,
		feet = 1,
	},
	toughness = 1,
	craft_material = "mcl_core:diamond",
	sound_equip = "mcl_armor_equip_diamond",
	sound_unequip = "mcl_armor_unequip_diamond",
	_mcl_upgradable = false
})
