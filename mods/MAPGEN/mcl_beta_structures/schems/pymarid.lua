local HALF = 63
local HEIGHT = 64
local SIZE = 127
local LAYER_HALVES = {
	63, 62, 61, 60, 59, 58, 57, 56,
	55, 54, 53, 52, 51, 50, 49, 48,
	47, 46, 45, 44, 43, 42, 41, 40,
	39, 38, 37, 36, 35, 34, 33, 32,
	31, 30, 29, 28, 27, 26, 25, 24,
	23, 22, 21, 20, 19, 18, 17, 16,
	15, 14, 13, 12, 11, 10, 9, 8,
	7, 6, 5, 4, 3, 2, 1, 0,
}

local brick_name = "mcl_core:brick_block"
if not minetest.registered_nodes[brick_name] then
	brick_name = "mcl_core:cobble"
end

local data = {}
for y = 1, HEIGHT do
	local radius = LAYER_HALVES[y] or 0
	for z = -HALF, HALF do
		local inside_z = math.abs(z) <= radius
		for x = -HALF, HALF do
			if inside_z and math.abs(x) <= radius then
				data[#data + 1] = { name = brick_name, prob = 255, param2 = 0 }
			else
				data[#data + 1] = { name = "air", prob = 0, param2 = 0 }
			end
		end
	end
end

return {
	size = { x = SIZE, y = HEIGHT, z = SIZE },
	data = data,
}
