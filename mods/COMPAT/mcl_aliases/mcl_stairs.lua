-- Aliases for backwards-compability with 0.21.0

local materials = {
	"wood", "junglewood", "sprucewood", "acaciawood", "birchwood", "darkwood",
	"cobble", "brick_block", "sandstone",
	"quartzblock", "nether_brick"--removed "purpur_block"
}

for m=1, #materials do
	local mat = materials[m]
	minetest.register_alias("stairs:slab_"..mat, "mcl_stairs:slab_"..mat)
	minetest.register_alias("stairs:stair_"..mat, "mcl_stairs:stair_"..mat)

	-- corner stairs
	minetest.register_alias("stairs:stair_"..mat.."_inner", "mcl_stairs:stair_"..mat.."_inner")
	minetest.register_alias("stairs:stair_"..mat.."_outer", "mcl_stairs:stair_"..mat.."_outer")
end

minetest.register_alias("stairs:slab_stone", "mcl_stairs:slab_stone")
minetest.register_alias("stairs:slab_stone_double", "mcl_stairs:slab_stone_double")

minetest.register_alias("stairs:slab_redsandstone", "mcl_stairs:slab_sandstone")
minetest.register_alias("stairs:stair_redsandstone", "mcl_stairs:stair_sandstone")
minetest.register_alias("stairs:stair_redsandstone_inner", "mcl_stairs:stair_sandstone_inner")
minetest.register_alias("stairs:stair_redsandstone_outer", "mcl_stairs:stair_sandstone_outer")
minetest.register_alias("mcl_stairs:slab_redsandstone", "mcl_stairs:slab_sandstone")
minetest.register_alias("mcl_stairs:stair_redsandstone", "mcl_stairs:stair_sandstone")
minetest.register_alias("mcl_stairs:stair_redsandstone_inner", "mcl_stairs:stair_sandstone_inner")
minetest.register_alias("mcl_stairs:stair_redsandstone_outer", "mcl_stairs:stair_sandstone_outer")

minetest.register_alias("mcl_stairs:slab_stonebrick", "mcl_stairs:slab_cobble")
minetest.register_alias("mcl_stairs:slab_stonebrick_top", "mcl_stairs:slab_cobble_top")
minetest.register_alias("mcl_stairs:slab_stonebrick_double", "mcl_stairs:slab_cobble_double")
minetest.register_alias("mcl_stairs:stair_stonebrick", "mcl_stairs:stair_cobble")
minetest.register_alias("mcl_stairs:stair_stonebrick_inner", "mcl_stairs:stair_cobble_inner")
minetest.register_alias("mcl_stairs:stair_stonebrick_outer", "mcl_stairs:stair_cobble_outer")
minetest.register_alias("mcl_stairs:slab_stonebrickmossy", "mcl_stairs:slab_cobble")
minetest.register_alias("mcl_stairs:slab_stonebrickmossy_top", "mcl_stairs:slab_cobble_top")
minetest.register_alias("mcl_stairs:slab_stonebrickmossy_double", "mcl_stairs:slab_cobble_double")
minetest.register_alias("mcl_stairs:stair_stonebrickmossy", "mcl_stairs:stair_cobble")
minetest.register_alias("mcl_stairs:stair_stonebrickmossy_inner", "mcl_stairs:stair_cobble_inner")
minetest.register_alias("mcl_stairs:stair_stonebrickmossy_outer", "mcl_stairs:stair_cobble_outer")
