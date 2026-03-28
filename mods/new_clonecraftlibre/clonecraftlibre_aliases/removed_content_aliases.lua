-- Backward-compatibility aliases for removed content.
-- Goal: keep old worlds loadable after content removals.

local function is_registered_name(name)
	return minetest.registered_nodes[name]
		or minetest.registered_items[name]
		or minetest.registered_tools[name]
		or minetest.registered_craftitems[name]
		or minetest.registered_aliases[name]
end

local function fallback_target_for(src)
	if src:find(":") then
		if src:find("pane") or src:find("glass") then
			return "mcl_core:glass"
		end
		if src:find("lantern") or src:find("torch") then
			return "mcl_torches:torch"
		end
		if src:find("map") then
			return "mcl_core:paper"
		end
		if src:find("bell") then
			return "mcl_core:stone"
		end
	end
	return "mcl_core:stone"
end

local function register_safe_alias(src, dst)
	if type(src) ~= "string" or type(dst) ~= "string" then
		return
	end
	if not src:match("^[a-z0-9_]+:[a-z0-9_]+$") then
		return
	end
	if is_registered_name(src) then
		return
	end
	if not is_registered_name(dst) then
		dst = fallback_target_for(src)
	end
	minetest.register_alias_force(src, dst)
end

local explicit_pairs = {
	{"mcl_cherry_blossom:cherry_fence_gate_open", "mcl_fences:cherry_blossom_fence_gate_open"},
	{"mcl_cherry_blossom:cherry_fence_gate", "mcl_fences:cherry_blossom_fence_gate"},
	{"mcl_cherry_blossom:cherry_fence", "mcl_fences:cherry_blossom_fence"},
	{"mcl_cherry_blossom:cherryleaves", "mcl_trees:leaves_cherry_blossom"},
	{"mcl_cherry_blossom:cherrysapling", "mcl_trees:sapling_cherry_blossom"},
	{"mcl_cherry_blossom:cherrytree_bark", "mcl_trees:bark_cherry_blossom"},
	{"mcl_cherry_blossom:cherrytree", "mcl_trees:tree_cherry_blossom"},
	{"mcl_cherry_blossom:cherrywood", "mcl_trees:wood_cherry_blossom"},
	{"mcl_cherry_blossom:pressure_plate_cherrywood_off", "mcl_pressureplates:pressure_plate_cherry_blossom_off"},
	{"mcl_cherry_blossom:pressure_plate_cherrywood_on", "mcl_pressureplates:pressure_plate_cherry_blossom_on"},
	{"mcl_cherry_blossom:stripped_cherrytree_bark", "mcl_trees:bark_stripped_cherry_blossom"},
	{"mcl_cherry_blossom:stripped_cherrytree", "mcl_trees:stripped_cherry_blossom"},
	{"mcl_crimson:crimson_fence_gate_open", "mcl_fences:crimson_fence_gate_open"},
	{"mcl_crimson:crimson_fence_gate", "mcl_fences:crimson_fence_gate"},
	{"mcl_crimson:crimson_fence", "mcl_fences:crimson_fence"},
	{"mcl_crimson:crimson_hyphae_bark", "mcl_trees:bark_crimson"},
	{"mcl_crimson:crimson_hyphae_wood", "mcl_trees:wood_crimson"},
	{"mcl_crimson:crimson_hyphae", "mcl_trees:tree_crimson"},
	{"mcl_crimson:stripped_crimson_hyphae_bark", "mcl_trees:bark_stripped_crimson"},
	{"mcl_crimson:stripped_crimson_hyphae", "mcl_trees:stripped_crimson"},
	{"mcl_crimson:stripped_warped_hyphae_bark", "mcl_trees:bark_stripped_warped"},
	{"mcl_crimson:stripped_warped_hyphae", "mcl_trees:stripped_warped"},
	{"mcl_crimson:warped_fence_gate_open", "mcl_fences:warped_fence_gate_open"},
	{"mcl_crimson:warped_fence_gate", "mcl_fences:warped_fence_gate"},
	{"mcl_crimson:warped_fence", "mcl_fences:warped_fence"},
	{"mcl_crimson:warped_hyphae_bark", "mcl_trees:bark_warped"},
	{"mcl_crimson:warped_hyphae_wood", "mcl_trees:wood_warped"},
	{"mcl_crimson:warped_hyphae", "mcl_trees:tree_warped"},
	{"mcl_stairs:slab_cherrywood_double", "mcl_stairs:slab_cherry_blossom_double"},
	{"mcl_stairs:slab_cherrywood_top", "mcl_stairs:slab_cherry_blossom_top"},
	{"mcl_stairs:slab_cherrywood", "mcl_stairs:slab_cherry_blossom"},
	{"mcl_stairs:slab_crimson_hyphae_tree_bark_double", "mcl_stairs:slab_crimson_bark_double"},
	{"mcl_stairs:slab_crimson_hyphae_tree_bark_top", "mcl_stairs:slab_crimson_bark_top"},
	{"mcl_stairs:slab_crimson_hyphae_tree_bark", "mcl_stairs:slab_crimson_bark"},
	{"mcl_stairs:slab_crimson_hyphae_wood_double", "mcl_stairs:slab_crimson_double"},
	{"mcl_stairs:slab_crimson_hyphae_wood_top", "mcl_stairs:slab_crimson_top"},
	{"mcl_stairs:slab_crimson_hyphae_wood", "mcl_stairs:slab_crimson"},
	{"mcl_stairs:slab_warped_hyphae_tree_bark_double", "mcl_stairs:slab_warped_bark_double"},
	{"mcl_stairs:slab_warped_hyphae_tree_bark_top", "mcl_stairs:slab_warped_bark_top"},
	{"mcl_stairs:slab_warped_hyphae_tree_bark", "mcl_stairs:slab_warped_bark"},
	{"mcl_stairs:slab_warped_hyphae_wood_double", "mcl_stairs:slab_warped_double"},
	{"mcl_stairs:slab_warped_hyphae_wood_top", "mcl_stairs:slab_warped_top"},
	{"mcl_stairs:slab_warped_hyphae_wood", "mcl_stairs:slab_warped"},
	{"mcl_stairs:stair_cherrywood_inner", "mcl_stairs:stair_cherry_blossom_inner"},
	{"mcl_stairs:stair_cherrywood_outer", "mcl_stairs:stair_cherry_blossom_outer"},
	{"mcl_stairs:stair_cherrywood", "mcl_stairs:stair_cherry_blossom"},
	{"mcl_stairs:stair_crimson_hyphae_tree_bark_inner", "mcl_stairs:stair_crimson_bark_inner"},
	{"mcl_stairs:stair_crimson_hyphae_tree_bark_outer", "mcl_stairs:stair_crimson_bark_outer"},
	{"mcl_stairs:stair_crimson_hyphae_tree_bark", "mcl_stairs:stair_crimson_bark"},
	{"mcl_stairs:stair_crimson_hyphae_wood_inner", "mcl_stairs:stair_crimson_inner"},
	{"mcl_stairs:stair_crimson_hyphae_wood_outer", "mcl_stairs:stair_crimson_outer"},
	{"mcl_stairs:stair_crimson_hyphae_wood", "mcl_stairs:stair_crimson"},
	{"mcl_stairs:stair_warped_hyphae_tree_bark_inner", "mcl_stairs:stair_warped_bark_inner"},
	{"mcl_stairs:stair_warped_hyphae_tree_bark_outer", "mcl_stairs:stair_warped_bark_outer"},
	{"mcl_stairs:stair_warped_hyphae_tree_bark", "mcl_stairs:stair_warped_bark"},
	{"mcl_stairs:stair_warped_hyphae_wood_inner", "mcl_stairs:stair_warped_inner"},
	{"mcl_stairs:stair_warped_hyphae_wood_outer", "mcl_stairs:stair_warped_outer"},
	{"mcl_stairs:stair_warped_hyphae_wood", "mcl_stairs:stair_warped"},
	{"mcl_trees:bark_stripped_bamboo", "mcl_trees:stripped_bamboo"},
	{"mclx_fences:red_nether_brick_fence_gate_open", "mcl_fences:red_nether_brick_fence_gate_open"},
	{"mclx_fences:red_nether_brick_fence_gate", "mcl_fences:red_nether_brick_fence_gate"},
	{"mclx_fences:red_nether_brick_fence", "mcl_fences:red_nether_brick_fence"},
	{"mesecons_button:button_cherry_blossom_off", "mcl_buttons:button_cherry_blossom_off"},
	{"mesecons_button:button_cherry_blossom_on", "mcl_buttons:button_cherry_blossom_on"},
	{"mesecons_button:button_cherrywood_off", "mesecons_button:button_cherry_blossom_off"},
	{"mesecons_button:button_cherrywood_on", "mcl_buttons:button_cherry_blossom_on"},
	{"mesecons_button:button_crimson_hyphae_off", "mesecons_button:button_crimson_off"},
	{"mesecons_button:button_crimson_hyphae_on", "mcl_buttons:button_crimson_on"},
	{"mesecons_button:button_crimson_off", "mcl_buttons:button_crimson_off"},
	{"mesecons_button:button_crimson_on", "mcl_buttons:button_crimson_on"},
	{"mesecons_button:button_polished_blackstone_off", "mcl_buttons:button_polished_blackstone_off"},
	{"mesecons_button:button_polished_blackstone_on", "mcl_buttons:button_polished_blackstone_on"},
	{"mesecons_button:button_warped_hyphae_off", "mesecons_button:button_warped_off"},
	{"mesecons_button:button_warped_hyphae_on", "mcl_buttons:button_warped_on"},
	{"mesecons_button:button_warped_off", "mcl_buttons:button_warped_off"},
	{"mesecons_button:button_warped_on", "mcl_buttons:button_warped_on"},
	{"mesecons_pressureplates:pressure_plate_cherry_blossom_off", "mcl_pressureplates:pressure_plate_cherry_blossom_off"},
	{"mesecons_pressureplates:pressure_plate_cherry_blossom_on", "mcl_pressureplates:pressure_plate_cherry_blossom_on"},
	{"mesecons_pressureplates:pressure_plate_crimson_hyphae_off", "mcl_pressureplates:pressure_plate_crimson_hyphae_off"},
	{"mesecons_pressureplates:pressure_plate_crimson_hyphae_off", "mcl_pressureplates:pressure_plate_crimson_off"},
	{"mesecons_pressureplates:pressure_plate_crimson_hyphae_on", "mcl_pressureplates:pressure_plate_crimson_hyphae_on"},
	{"mesecons_pressureplates:pressure_plate_crimson_hyphae_on", "mcl_pressureplates:pressure_plate_crimson_on"},
	{"mesecons_pressureplates:pressure_plate_crimson_off", "mcl_pressureplates:pressure_plate_crimson_off"},
	{"mesecons_pressureplates:pressure_plate_crimson_on", "mcl_pressureplates:pressure_plate_crimson_on"},
	{"mesecons_pressureplates:pressure_plate_warped_hyphae_off", "mcl_pressureplates:pressure_plate_warped_hyphae_off"},
	{"mesecons_pressureplates:pressure_plate_warped_hyphae_off", "mcl_pressureplates:pressure_plate_warped_off"},
	{"mesecons_pressureplates:pressure_plate_warped_hyphae_on", "mcl_pressureplates:pressure_plate_warped_hyphae_on"},
	{"mesecons_pressureplates:pressure_plate_warped_hyphae_on", "mcl_pressureplates:pressure_plate_warped_on"},
	{"mesecons_pressureplates:pressure_plate_warped_off", "mcl_pressureplates:pressure_plate_warped_off"},
	{"mesecons_pressureplates:pressure_plate_warped_on", "mcl_pressureplates:pressure_plate_warped_on"},
	-- Removed pane IDs
	{"mcl_panes:bar", "mcl_core:glass"},
	{"mcl_panes:bar_flat", "mcl_core:glass"},
	{"mcl_panes:pane_natural", "mcl_core:glass"},
	{"mcl_panes:pane_natural_flat", "mcl_core:glass"},
	{"mcl_panes:pane_white", "mcl_core:glass"},
	{"mcl_panes:pane_white_flat", "mcl_core:glass"},
	{"mcl_panes:pane_silver", "mcl_core:glass"},
	{"mcl_panes:pane_silver_flat", "mcl_core:glass"},
	{"mcl_panes:pane_grey", "mcl_core:glass"},
	{"mcl_panes:pane_grey_flat", "mcl_core:glass"},
	{"mcl_panes:pane_black", "mcl_core:glass"},
	{"mcl_panes:pane_black_flat", "mcl_core:glass"},
	{"mcl_panes:pane_red", "mcl_core:glass"},
	{"mcl_panes:pane_red_flat", "mcl_core:glass"},
	{"mcl_panes:pane_orange", "mcl_core:glass"},
	{"mcl_panes:pane_orange_flat", "mcl_core:glass"},
	{"mcl_panes:pane_yellow", "mcl_core:glass"},
	{"mcl_panes:pane_yellow_flat", "mcl_core:glass"},
	{"mcl_panes:pane_lime", "mcl_core:glass"},
	{"mcl_panes:pane_lime_flat", "mcl_core:glass"},
	{"mcl_panes:pane_green", "mcl_core:glass"},
	{"mcl_panes:pane_green_flat", "mcl_core:glass"},
	{"mcl_panes:pane_cyan", "mcl_core:glass"},
	{"mcl_panes:pane_cyan_flat", "mcl_core:glass"},
	{"mcl_panes:pane_light_blue", "mcl_core:glass"},
	{"mcl_panes:pane_light_blue_flat", "mcl_core:glass"},
	{"mcl_panes:pane_blue", "mcl_core:glass"},
	{"mcl_panes:pane_blue_flat", "mcl_core:glass"},
	{"mcl_panes:pane_purple", "mcl_core:glass"},
	{"mcl_panes:pane_purple_flat", "mcl_core:glass"},
	{"mcl_panes:pane_magenta", "mcl_core:glass"},
	{"mcl_panes:pane_magenta_flat", "mcl_core:glass"},
	{"mcl_panes:pane_pink", "mcl_core:glass"},
	{"mcl_panes:pane_pink_flat", "mcl_core:glass"},
	{"mcl_panes:pane_brown", "mcl_core:glass"},
	{"mcl_panes:pane_brown_flat", "mcl_core:glass"},

	-- Removed map/bell/lantern IDs (common variants)
	{"mcl_maps:id", "mcl_core:paper"},
	{"mcl_maps:treasure_map", "mcl_core:paper"},
	{"mcl_maps:map", "mcl_core:paper"},
	{"mcl_maps:empty_map", "mcl_core:paper"},
	{"mcl_maps:filled_map", "mcl_core:paper"},
	{"mcl_bells:bell", "mcl_core:stone"},
	{"mcl_lanterns:lantern", "mcl_torches:torch"},
	{"mcl_lanterns:lantern_floor", "mcl_torches:torch"},
	{"mcl_lanterns:lantern_ceiling", "mcl_torches:torch"},
	{"mcl_lanterns:soul_lantern", "mcl_torches:torch"},
	{"mcl_lanterns:soul_lantern_floor", "mcl_torches:torch"},
	{"mcl_lanterns:soul_lantern_ceiling", "mcl_torches:torch"},
}

local mangrove_ids = {
	"mcl_buttons:button_mangrove_off",
	"mcl_buttons:button_mangrove_on",
	"mcl_fences:mangrove_fence",
	"mcl_fences:mangrove_fence_gate",
	"mcl_fences:mangrove_fence_gate_open",
	"mcl_mangrove:mangrove_leaves",
	"mcl_mangrove:mangrove_log",
	"mcl_mangrove:mangrove_stripped_bark",
	"mcl_mangrove:mangrove_stripped_trunk",
	"mcl_mangrove:mangrove_tree",
	"mcl_mangrove:mangrove_tree_bark",
	"mcl_mangrove:mangrove_wood",
	"mcl_mangrove:mangrove_wood_fence",
	"mcl_mangrove:mangrove_wood_fence_gate",
	"mcl_mangrove:mangrove_wood_fence_gate_open",
	"mcl_mangrove:mangroveleaves",
	"mcl_mangrove:mangroveleaves_orphan",
	"mcl_pressureplates:pressure_plate_mangrove_off",
	"mcl_pressureplates:pressure_plate_mangrove_on",
	"mcl_signs:standing_sign_mangrove",
	"mcl_signs:standing_sign_mangrove_wood",
	"mcl_stairs:slab_mangrove",
	"mcl_stairs:slab_mangrove_bark",
	"mcl_stairs:slab_mangrove_bark_double",
	"mcl_stairs:slab_mangrove_bark_top",
	"mcl_stairs:slab_mangrove_double",
	"mcl_stairs:slab_mangrove_top",
	"mcl_stairs:slab_mangrove_tree_bark",
	"mcl_stairs:slab_mangrove_tree_bark_double",
	"mcl_stairs:slab_mangrove_tree_bark_top",
	"mcl_stairs:slab_mangrove_wood",
	"mcl_stairs:slab_mangrove_wood_double",
	"mcl_stairs:slab_mangrove_wood_top",
	"mcl_stairs:stair_mangrove",
	"mcl_stairs:stair_mangrove_bark",
	"mcl_stairs:stair_mangrove_bark_inner",
	"mcl_stairs:stair_mangrove_bark_outer",
	"mcl_stairs:stair_mangrove_inner",
	"mcl_stairs:stair_mangrove_outer",
	"mcl_stairs:stair_mangrove_tree_bark",
	"mcl_stairs:stair_mangrove_tree_bark_inner",
	"mcl_stairs:stair_mangrove_tree_bark_outer",
	"mcl_stairs:stair_mangrove_wood",
	"mcl_stairs:stair_mangrove_wood_inner",
	"mcl_stairs:stair_mangrove_wood_outer",
	"mcl_trees:bark_mangrove",
	"mcl_trees:bark_stripped_mangrove",
	"mcl_trees:leaves_mangrove",
	"mcl_trees:leaves_mangrove_orphan",
	"mcl_trees:stripped_mangrove",
	"mcl_trees:tree_mangrove",
	"mcl_trees:wood_mangrove",
	"mesecons_button:button_mangrove_off",
	"mesecons_button:button_mangrove_on",
	"mesecons_button:button_mangrove_wood_off",
	"mesecons_button:button_mangrove_wood_on",
	"mesecons_pressureplates:pressure_plate_mangrove_off",
	"mesecons_pressureplates:pressure_plate_mangrove_on",
	"mesecons_pressureplates:pressure_plate_mangrove_wood_off",
	"mesecons_pressureplates:pressure_plate_mangrove_wood_on",
}

local function mangrove_target(src)
	local oak_variant = src:gsub("mangrove", "oak")
	if is_registered_name(oak_variant) then
		return oak_variant
	end
	if src:find("leaves") then
		return "mcl_trees:leaves_oak"
	end
	if src:find("sapling") or src:find("propagule") then
		return "mcl_trees:sapling_oak"
	end
	if src:find("fence") then
		return "mcl_fences:oak_fence"
	end
	if src:find("door") then
		return "mcl_doors:door_oak"
	end
	if src:find("button") then
		return "mcl_buttons:button_oak_off"
	end
	if src:find("pressure_plate") then
		return "mcl_pressureplates:pressure_plate_oak_off"
	end
	if src:find("sign") then
		return "mcl_signs:standing_sign_oak"
	end
	if src:find("stair") then
		return "mcl_stairs:stair_oak"
	end
	if src:find("slab") then
		return "mcl_stairs:slab_oak"
	end
	if src:find("wood") or src:find("log") or src:find("tree") or src:find("bark") or src:find("stripped") then
		return "mcl_trees:wood_oak"
	end
	return "mcl_core:stone"
end

minetest.register_on_mods_loaded(function()
	for i = 1, #explicit_pairs do
		register_safe_alias(explicit_pairs[i][1], explicit_pairs[i][2])
	end

	for i = 1, #mangrove_ids do
		local src = mangrove_ids[i]
		register_safe_alias(src, mangrove_target(src))
	end
end)
