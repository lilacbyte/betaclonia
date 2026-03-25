local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("mcl_fishing:fish_raw", {
	description = S("Raw Fish"),
	_doc_items_longdesc = S("Raw fish is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_fish_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_cooking_output = "mcl_fishing:fish_cooked"
})

minetest.register_craftitem("mcl_fishing:fish_cooked", {
	description = S("Cooked Fish"),
	_doc_items_longdesc = S("Mmh, fish! This is a healthy food item."),
	inventory_image = "mcl_fishing_fish_cooked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	groups = { eatable=5 },
})

--[[minetest.register_craftitem("mcl_fishing:salmon_raw", {
	description = S("Raw Salmon"),
	_doc_items_longdesc = S("Raw salmon is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_salmon_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_cooking_output = "mcl_fishing:salmon_cooked"
})

minetest.register_craftitem("mcl_fishing:salmon_cooked", {
	description = S("Cooked Salmon"),
	_doc_items_longdesc = S("This is a healthy food item which can be eaten."),
	inventory_image = "mcl_fishing_salmon_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { eatable=6 },
})

minetest.register_craftitem("mcl_fishing:clownfish_raw", {
	description = S("Clownfish"),
	_doc_items_longdesc = S("Clownfish may be obtained by fishing (and luck) and is a food item which can be eaten safely."),
	inventory_image = "mcl_fishing_clownfish_raw.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	groups = { eatable = 1 },
})]]--removed

local function eat_pufferfish(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	return minetest.item_eat(0)(itemstack, placer, pointed_thing)
end
minetest.register_craftitem("mcl_fishing:pufferfish_raw", {
	description = S("Pufferfish"),
	_tt_help = minetest.colorize(mcl_colors.YELLOW, S("Very harmful")),
	_doc_items_longdesc = S("Pufferfish are a common species of fish and can be obtained by fishing. You can eat one, but there's a 60% chance it will deal heavy damage."),
	inventory_image = "mcl_fishing_pufferfish_raw.png",
	on_place = eat_pufferfish,
	on_secondary_use = eat_pufferfish,
	groups = { eatable=0, brewitem = 1 },
})

minetest.register_on_item_eat(function(_, _, itemstack, user)
	if not user or not user:is_player() then
		return
	end
	if itemstack:get_name() ~= "mcl_fishing:pufferfish_raw" then
		return
	end
	if math.random() > 0.6 then
		return
	end

	local damage = math.random(8, 14) -- 4 to 7 hearts
	local player_name = user:get_player_name()
	minetest.after(0, function()
		local player = minetest.get_player_by_name(player_name)
		if not player or player:get_hp() <= 0 then
			return
		end
		if mcl_damage and mcl_damage.damage_player then
			mcl_damage.damage_player(player, damage, { type = "generic" })
		else
			player:set_hp(math.max(0, player:get_hp() - damage), { type = "set_hp" })
			minetest.sound_play("player_damage", { to_player = player_name, gain = 0.5 }, true)
		end
	end)
end)

minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{"","","mcl_core:stick"},
		{"","mcl_core:stick","mcl_mobitems:string"},
		{"mcl_core:stick","","mcl_mobitems:string"},
	}
})
minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{"mcl_core:stick", "", ""},
		{"mcl_mobitems:string", "mcl_core:stick", ""},
		{"mcl_mobitems:string","","mcl_core:stick"},
	}
})
