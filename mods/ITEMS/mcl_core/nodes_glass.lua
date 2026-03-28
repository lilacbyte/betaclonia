-- Glass nodes
local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_core:glass", {
	description = S("Glass"),
	_doc_items_longdesc = S("A decorative and mostly transparent block."),
	drawtype = "glasslike_framed_optional",
	is_ground_content = false,
	tiles = {"default_glass.png", "default_glass_detail.png"},
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	groups = {handy=1, glass=1, building_block=1, material_glass=1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	drop = "",
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
})

-- Stained glass has been removed in this game profile.
for _, color in ipairs({
	"white", "silver", "grey", "gray", "black", "purple", "blue", "light_blue",
	"cyan", "green", "lime", "yellow", "brown", "orange", "red", "magenta",
	"pink", "light_gray", "dark_grey",
}) do
	minetest.register_alias("mcl_core:glass_"..color, "mcl_core:glass")
end
