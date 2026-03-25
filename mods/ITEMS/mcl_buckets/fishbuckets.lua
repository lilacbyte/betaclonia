local D = mcl_util.get_dynamic_translator()

-- Fish Buckets
local fish_names = {
	["cod"] = {"Cod", "a Cod"},
	["salmon"] = {"Salmon", "a Salmon"},
	["tropical_fish"] = {"Tropical Fish", "a Tropical Fish"},
--	["axolotl"] = {"Axolotl", "an Axolotl"},--removed
	--["pufferfish"] = {"Pufferfish", "a Pufferfish"}, --FIXME add pufferfish
}

local fishbucket_prefix = "mcl_buckets:bucket_"

local function on_place_fish(itemstack, placer, pointed_thing)

	local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if new_stack then
		return new_stack
	end

	if pointed_thing.type ~= "node" then return end

	local pos = pointed_thing.above
	local n = minetest.get_node(pointed_thing.above)
	local def = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]

	if ( def and def.buildable_to ) or n.name == "mcl_portals:portal" then
		pos = pointed_thing.under
		n = minetest.get_node(pointed_thing.under)
	end

	local fish = itemstack:get_definition()._mcl_buckets_fish
	if fish_names[fish] then
		local o = minetest.add_entity(pos, "mobs_mc:" .. fish, minetest.serialize({ persistent = true }))
		if o and o:get_pos() then
			local props = itemstack:get_meta():get_string("properties")
			if props ~= "" then
				o:set_properties(minetest.deserialize(props))
			end
			local water = "mcl_core:water_source"
			if n.name == "mclx_core:river_water_source" then
				water = n.name
			elseif n.name == "mclx_core:river_water_flowing" then
				water = nil ---@diagnostic disable-line: cast-local-type
			end
			if mcl_worlds.pos_to_dimension(pos) == "nether" then
				water = nil ---@diagnostic disable-line: cast-local-type
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			end
			if water then
				minetest.set_node(pos,{name = water})
			end
			if not placer or not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack = ItemStack("mcl_buckets:bucket_empty")
			end
		end
	end
	return itemstack
end

for techname, fishname in pairs(fish_names) do
	local fish, a_fish, a_fish_dot = fishname[1], fishname[2], fishname[2] .. "."
	minetest.register_craftitem(fishbucket_prefix .. techname, {
		description = D("Bucket of " .. fish),
		_doc_items_longdesc = D("This bucket is filled with water and " .. a_fish_dot),
		_doc_items_usagehelp = D("Place it to empty the bucket and place " .. a_fish_dot .. " Obtain by right clicking on " .. a_fish .. " with a bucket of water."),
		_tt_help = D("Places a water source and " .. a_fish_dot),
		inventory_image = techname .. "_bucket.png",
		stack_max = 1,
		groups = {bucket = 1, fish_bucket = 1},
		liquids_pointable = false,
		_mcl_buckets_fish = techname,
		on_place = on_place_fish,
		on_secondary_use = on_place_fish,
		_on_dispense = function(stack, _, droppos)
			return on_place_fish(stack, nil, {above=droppos})
		end,
	})

	minetest.register_alias("mcl_fishing:bucket_" .. techname, "mcl_buckets:bucket_" .. techname)
end
