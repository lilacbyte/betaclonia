local S = minetest.get_translator(minetest.get_current_modname())

mcl_torches.register_torch({
	name = "redstone_torch_off",
	description = S("Redstone Torch (off)"),
	doc_items_longdesc = S("A redstone torch is a redstone component which can be used to invert a redstone signal. It supplies its surrounding blocks with redstone power, except for the block it is attached to. A redstone torch is normally lit, but it can also be turned off by powering the block it is attached to. While unlit, a redstone torch does not power anything."),
	doc_items_usagehelp = S("Redstone torches can be placed at the side and on the top of full solid opaque blocks."),
	icon = "jeija_torches_off.png",
	tiles = {"jeija_torches_off.png"},
	light = 0,
	groups = {dig_immediate=3, dig_by_water=1, redstone_torch=2, not_in_creative_inventory=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = "mcl_redstone_torch:redstone_torch_on",
})

mcl_torches.register_torch({
	name = "redstone_torch_on",
	description = S("Redstone Torch"),
	icon = "jeija_torches_on.png",
	tiles = {"jeija_torches_on.png"},
	light = 7,
	groups = {dig_immediate=3, dig_by_water=1, redstone_torch=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

local burnout_tab = {}

local function inc_burnout(pos)
	local h = minetest.hash_node_position(pos)
	burnout_tab[h] = (burnout_tab[h] or 0) + 1
	mcl_redstone.after(30, function()
		burnout_tab[h] = burnout_tab[h] > 1 and burnout_tab[h] - 1 or nil
	end)
end

local function check_burnout(pos)
	return (burnout_tab[minetest.hash_node_position(pos)] or 0) >= 8
end

for _, name in pairs({ "mcl_redstone_torch:redstone_torch_off", "mcl_redstone_torch:redstone_torch_off_wall" }) do
	minetest.override_item(name, {
		_mcl_redstone = {
			update = function(pos, node)
				if mcl_redstone.get_power(pos, minetest.wallmounted_to_dir(node.param2)) == 0 then
					if check_burnout(pos) then
						minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
						return
					end


					local ndef = minetest.registered_nodes[node.name]
					return {
						name = ndef._mcl_redstone_torch_on,
						param2 = node.param2,
					}
				end
			end,
		}
	})
end

for _, name in pairs({ "mcl_redstone_torch:redstone_torch_on", "mcl_redstone_torch:redstone_torch_on_wall" }) do
	minetest.override_item(name, {
		_mcl_redstone = {
			connects_to = function(node, dir)
				return true
			end,
			get_power = function(node, dir)
				return minetest.dir_to_wallmounted(dir) ~= node.param2 and 15 or 0, dir.y > 0
			end,
			update = function(pos, node)
				if mcl_redstone.get_power(pos, minetest.wallmounted_to_dir(node.param2)) > 0 then
					inc_burnout(pos)

					local ndef = minetest.registered_nodes[node.name]
					return {
						name = ndef._mcl_redstone_torch_off,
						param2 = node.param2,
					}
				end
			end,
		}
	})
end

for _, name in pairs({ "mcl_redstone_torch:redstone_torch_on_wall", "mcl_redstone_torch:redstone_torch_off_wall" }) do
	minetest.override_item(name, {
		_mcl_redstone_torch_on = "mcl_redstone_torch:redstone_torch_on_wall",
		_mcl_redstone_torch_off = "mcl_redstone_torch:redstone_torch_off_wall",
	})
end

for _, name in pairs({ "mcl_redstone_torch:redstone_torch_on", "mcl_redstone_torch:redstone_torch_off" }) do
	minetest.override_item(name, {
		_mcl_redstone_torch_on = "mcl_redstone_torch:redstone_torch_on",
		_mcl_redstone_torch_off = "mcl_redstone_torch:redstone_torch_off",
	})
end

minetest.register_node("mcl_redstone_torch:redstoneblock", {
	description = S("Block of Redstone"),
	_tt_help = S("Provides redstone power"),
	_doc_items_longdesc = S("A block of redstone permanently supplies redstone power to its surrounding blocks."),
	tiles = {"redstone_redstone_block.png"},
	stack_max = 64,
	groups = {pickaxey=1, opaquely_powered=15},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_redstone = {
		connects_to = function()
			return true
		end,
	},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_craft({
	output = "mcl_redstone_torch:redstone_torch_on",
	recipe = {
		{"mcl_redstone:redstone"},
		{"mcl_core:stick"},}
})

minetest.register_craft({
	output = "mcl_redstone_torch:redstoneblock",
	recipe = {
		{"mcl_redstone:redstone","mcl_redstone:redstone","mcl_redstone:redstone"},
		{"mcl_redstone:redstone","mcl_redstone:redstone","mcl_redstone:redstone"},
		{"mcl_redstone:redstone","mcl_redstone:redstone","mcl_redstone:redstone"},
	}
})

minetest.register_craft({
	output = "mcl_redstone:redstone 9",
	recipe = {
		{"mcl_redstone_torch:redstoneblock"},
	}
})
