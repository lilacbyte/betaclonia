local wireflag_tab = mcl_redstone._wireflag_tab
local opaque_tab = mcl_redstone._solid_opaque_tab

-- get_power, update and init callbacks by name
local get_power_tab = {}
local update_tab = {}
local init_tab = {}

local action_tab = mcl_redstone._action_tab

local function check_bit(n, b)
	return bit.band(n, bit.lshift(1, b)) ~= 0
end

-- 0-3 correspond to the direction bits in wireflags.
local sixdirs = {
	[0] = vector.new(0, 0, 1),
	[1] = vector.new(1, 0, 0),
	[2] = vector.new(0, 0, -1),
	[3] = vector.new(-1, 0, 0),
	[4] = vector.new(0, -1, 0),
	[5] = vector.new(0, 1, 0),
}

local wiredirs = {
	[0x1] = {wire = vector.new(0, 0, -1)},
	[0x2] = {wire = vector.new(-1, 0, 0)},
	[0x4] = {wire = vector.new(0, 0, 1)},
	[0x8] = {wire = vector.new(1, 0, 0)},
}

local wiredirs_up = {
	[0x1] = {wire = vector.new(0, 1, -1), obstruct = vector.new(0, 1, 0)},
	[0x2] = {wire = vector.new(-1, 1, 0), obstruct = vector.new(0, 1, 0)},
	[0x4] = {wire = vector.new(0, 1, 1), obstruct = vector.new(0, 1, 0)},
	[0x8] = {wire = vector.new(1, 1, 0), obstruct = vector.new(0, 1, 0)},
}

local wiredirs_down = {
	[0x1] = {wire = vector.new(0, -1, -1), obstruct = vector.new(0, 0, -1)},
	[0x2] = {wire = vector.new(-1, -1, 0), obstruct = vector.new(-1, 0, 0)},
	[0x4] = {wire = vector.new(0, -1, 1), obstruct = vector.new(0, 0, 1)},
	[0x8] = {wire = vector.new(1, -1, 0), obstruct = vector.new(1, 0, 0)},
}

local function iterate_wire_neighbours(wireflags)
	local i = 1
	local state = 0
	-- core.debug("IMPORTANT!", wireflags)
	-- `state` is a special variable that meansL
	-- 0: now returning entry from the block to the side
	-- 1: now returning entry from the block to the side and up
	-- 2: now returning entry from the block to the side and down
	return function(wireflags)
		-- core.debug("ITER!", wireflags, i, state)
		if state == 0 then
			while i <= 8 do
				local val = bit.band(wireflags, bit.bor(i, bit.lshift(i, 4)))
				local tmp = wiredirs[i]
				-- core.debug("pop", val)
				if val == i then
					-- if goes to the side of that block
					state = 2
					return tmp
				elseif val ~= 0 then
					-- if goes up a block
					state = 1
					return tmp
				end
				i = i * 2
			end
			-- core.debug("terminate")
			return
		elseif state == 1 then
			state = 2
			return wiredirs_up[i]
		else
			local tmp = wiredirs_down[i]
			i = i * 2
			state = 0
			return tmp
		end
	end, wireflags
end

-- Get power from direct neighbours at pos. Returns weak and strong power.
local function get_node_power(pos, include_wire)
	local weak = 0
	local strong = 0
	for i, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local node2 = minetest.get_node(pos2)

		if get_power_tab[node2.name] then
			local power, is_strong = get_power_tab[node2.name](node2, -dir)

			weak = math.max(weak, power)
			if is_strong then
				strong = math.max(strong, power)
			end
		elseif include_wire and wireflag_tab[node2.name] and (i == 5 or check_bit(wireflag_tab[node2.name], i)) then
			-- Wire is above or pointing towards this node.
			weak = math.max(weak, node2.param2)
		end
	end

	return weak, strong
end

-- Get strong power from neighbours (including opaque nodes) at pos.
local function get_node_power_2(pos)
	local max = get_node_power(pos)
	for _, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local node2 = minetest.get_node(pos2)

		if opaque_tab[node2.name] then
			local _, power2 = get_node_power(pos2)
			max = math.max(max, power2, opaque_tab[node2.name])
		end
	end

	return max
end

-- Propagate redstone power through wires. 'clear_queue' is a queue of events
-- were power which is lowered/removed. 'fill_queue' is a queue of events were
-- power is added/raised. 'update' is a table which gets populated with
-- positions that should get redstone update events.
local function propagate_wire(clear_queue, fill_queue, updates)
	local nodecache = {}
	local updates_ = {}

	local function get_node(pos)
		local h = minetest.hash_node_position(pos)
		if not nodecache[h] then
			nodecache[h] = minetest.get_node(pos)
		end
		return nodecache[h]
	end

	local function swap_node(pos, node)
		local h = minetest.hash_node_position(pos)
		node.dirty = true
		nodecache[h] = node
	end

	local function get_power(node)
		return wireflag_tab[node.name] and node.param2 or 0
	end

	for _, entry in pairs(clear_queue.queue) do
		swap_node(entry.pos, {name = get_node(entry.pos).name, param2 = 0})
	end

	while clear_queue:size() > 0 do
		local entry = clear_queue:dequeue()
		local pos = entry.pos
		local power = entry.power
		local node = core.get_node(pos)

		updates_[minetest.hash_node_position(pos)] = pos

		for dir in iterate_wire_neighbours(wireflag_tab[node.name] or 0xFF) do
			-- core.debug(dump(dir))
			if not dir.obstruct or not opaque_tab[get_node(pos:add(dir.obstruct)).name] then
				local pos2 = pos:add(dir.wire)
				local node2 = get_node(pos2)
				local power2 = get_power(node2)

				if power2 > 0 then
					if power2 < power then
						swap_node(pos2, {name = node2.name, param2 = 0})
						clear_queue:enqueue({pos = pos2, power = power2})
					else
						swap_node(pos2, {name = node2.name, param2 = power2})
						fill_queue:enqueue({pos = pos2, power = power2})
					end
				end
			end
		end
	end

	for _, entry in pairs(fill_queue.queue) do
		swap_node(entry.pos, {name = get_node(entry.pos).name, param2 = entry.power})
	end

	while fill_queue:size() > 0 do
		local entry = fill_queue:dequeue()
		local pos = entry.pos
		local power = entry.power
		local power2 = power - 1

		updates_[minetest.hash_node_position(pos)] = pos

		for dir in iterate_wire_neighbours(wireflag_tab[core.get_node(pos).name]) do
			if not dir.obstruct or not opaque_tab[get_node(pos:add(dir.obstruct)).name] then
				local pos2 = pos:add(dir.wire)
				local node2 = get_node(pos2)
				if wireflag_tab[node2.name] and get_power(node2) < power2 then
					swap_node(pos2, {name = node2.name, param2 = power2})
					fill_queue:enqueue({pos = pos2, power = power2})
				end
			end
		end
	end

	for hash, node in pairs(nodecache) do
		if node.dirty then
			minetest.swap_node(minetest.get_position_from_hash(hash), node)
		end
	end

	for _, pos in pairs(updates_) do
		for _, dir in pairs(sixdirs) do
			local pos2 = pos:add(dir)
			local node2 = get_node(pos2)
			local hash2 = minetest.hash_node_position(pos2)

			mcl_redstone._pending_updates[hash2] = update_tab[node2.name] and pos2 or nil
			if opaque_tab[node2.name] then
				for _, dir in pairs(sixdirs) do
					local pos3 = pos2:add(dir)
					local node3 = get_node(pos3)
					local hash3 = minetest.hash_node_position(pos3)

					mcl_redstone._pending_updates[hash3] = update_tab[node3.name] and pos3 or nil
				end
			end
		end
	end
end

function mcl_redstone.get_power(pos, dir, option)
	minetest.load_area(pos:subtract(2), pos:add(2))

	-- Create table with keys corresponding to bits in wireflags to
	-- simplify wire direction checks.
	local dirs = {}
	for k, v in pairs(sixdirs) do
		if not dir or v == dir then
			dirs[k] = v
		end
	end

	local power = 0
	for i, dir in pairs(dirs) do
		local pos2 = pos:add(dir)
		local node2 = minetest.get_node(pos2)

		if get_power_tab[node2.name] then
			local power2 = get_power_tab[node2.name](node2, -dir)
			power = math.max(power, power2)
		elseif wireflag_tab[node2.name] and (i == 5 or check_bit(wireflag_tab[node2.name], i)) then
			power = math.max(power, node2.param2)
		elseif opaque_tab[node2.name] then
			power = math.max(power, opaque_tab[node2.name])
			if option ~= "direct" then
				power = math.max(power, get_node_power(pos2, true))
			end
		end
	end

	return power
end

local function schedule_update(pos, update)
	local delay = update.delay or 1
	local priority = update.priority or 1000
	local oldnode = minetest.get_node(pos)
	mcl_redstone._schedule_update(delay, priority, pos, update, oldnode)
end

local function call_init(pos)
	local node = minetest.get_node(pos)
	if init_tab[node.name] then
		local ret = init_tab[node.name](pos, node)
		if ret then
			schedule_update(pos, ret)
		end
	end
end

function mcl_redstone._call_update(pos)
	local node = minetest.get_node(pos)
	if update_tab[node.name] then
		local ret = update_tab[node.name](pos, node)
		if ret then
			schedule_update(pos, ret)
		end
	end
end

-- TODO: A bit ugly, could be refactored.
function mcl_redstone.update_node(pos)
	mcl_redstone._pending_updates[minetest.hash_node_position(pos)] = pos
end

-- Piston pusher nodes calls this during init to avoid circuits stopping if a
-- piston was extended just before a server restart. It is not a clean solution
-- but it works.
function mcl_redstone._update_neighbours(pos, oldnode, newnode)
	update_neighbours(pos, oldnode, newnode)
	if  (oldnode and action_tab[oldnode.name])
			or (newnode and action_tab[newnode.name]) then
		local callbacks = {}

		for _, func in pairs(oldnode and action_tab[oldnode.name] or {}) do
			callbacks[func] = true
		end
		for _, func in pairs(newnode and action_tab[newnode.name] or {}) do
			callbacks[func] = true
		end

		for func, _ in pairs(callbacks) do
			func(pos, oldnode, newnode)
		end
	end
end

function mcl_redstone.swap_node(pos, node)
	local oldnode = minetest.get_node(pos)
	if not node then print(debug.traceback("trying to place nil")) end
	minetest.swap_node(pos, node)
	mcl_redstone._update_neighbours(pos, oldnode, node)
end

-- Update neighbouring wires and components at pos. Oldnode is the previous
-- node at the position.
function update_neighbours(pos, oldnode, newnode)
	minetest.load_area(pos:subtract(20), pos:add(20))

	local fill_queue = mcl_util.queue()
	local clear_queue = mcl_util.queue()
	local node = newnode or minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local oldndef = oldnode and minetest.registered_nodes[oldnode.name]
	local get_power = ndef and ndef._mcl_redstone and ndef._mcl_redstone.get_power
	local old_get_power = oldndef and oldndef._mcl_redstone and oldndef._mcl_redstone.get_power

	local function update_wire(pos, oldpower, dirs)
		if oldpower then
			clear_queue:enqueue({pos = pos, power = oldpower, dirs = dirs})
		end
		local power = get_node_power_2(pos)

		fill_queue:enqueue({pos = pos, power = power, dirs = dirs})
	end

	local hash = minetest.hash_node_position(pos)
	mcl_redstone._pending_updates[hash] = update_tab[node.name] and pos or nil

	if not (get_power or old_get_power) then return end

	for _, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local power2 = get_power and get_power(node, dir) or 0
		local oldpower2 = old_get_power and old_get_power(oldnode, dir) or 0

		if power2 ~= oldpower2 then
			local node2 = minetest.get_node(pos2)
			local hash2 = minetest.hash_node_position(pos2)

			mcl_redstone._pending_updates[hash2] = update_tab[node2.name] and pos2 or nil
			if wireflag_tab[node2.name] then
				update_wire(pos2, oldpower2)
			elseif opaque_tab[node2.name] then
				for i, dir in pairs(sixdirs) do
					local pos3 = pos2:add(dir)
					local node3 = minetest.get_node(pos3)
					local hash3 = minetest.hash_node_position(pos3)

					mcl_redstone._pending_updates[hash3] = update_tab[node3.name] and pos3 or nil
					if wireflag_tab[node3.name] then
						update_wire(pos3, math.max(oldpower2, 0, opaque_tab[node2.name]))
					end
				end
			end
		end
	end

	propagate_wire(clear_queue, fill_queue)
end

local function opaque_update_neighbours(pos, added)
	local fill_queue = mcl_util.queue()
	local clear_queue = mcl_util.queue()

	local function update_wire(pos)
		local oldpower = minetest.get_node(pos).param2
		local power = get_node_power_2(pos)

		clear_queue:enqueue({pos = pos, power = oldpower})
		fill_queue:enqueue({pos = pos, power = power})
	end

	for _, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local node2 = minetest.get_node(pos2)
		if wireflag_tab[node2.name] then
			update_wire(pos2)
		elseif update_tab[node2.name] then
			local hash2 = minetest.hash_node_position(pos2)
			mcl_redstone._pending_updates[hash2] = update_tab[node2.name] and pos2 or nil
		end
	end

	propagate_wire(clear_queue, fill_queue)
end

local function update_wire(pos, oldnode)
	local fill_queue = mcl_util.queue()
	local clear_queue = mcl_util.queue()
	local node = minetest.get_node(pos)
	local power = get_node_power_2(pos)

	clear_queue:enqueue({pos = pos, power = oldnode and oldnode.param2 or 0})
	if wireflag_tab[node.name] then
		fill_queue:enqueue({pos = pos, power = power})
	end

	propagate_wire(clear_queue, fill_queue)
end

-- Override nodes to perform redstone updates on changes.
minetest.register_on_mods_loaded(function()
	for name, ndef in pairs(minetest.registered_nodes) do
		local old_construct = ndef.on_construct
		local old_destruct = ndef.after_destruct
		if minetest.get_item_group(name, "opaque") ~= 0 and minetest.get_item_group(name, "solid") ~= 0 then
			minetest.override_item(name, {
				on_construct = function(pos)
					if old_construct then
						old_construct(pos)
					end
					mcl_redstone._update_opaque_connections(pos)
					mcl_redstone.after(0, function()
						opaque_update_neighbours(pos)
					end)
				end,
				after_destruct = function(pos, oldnode)
					if old_destruct then
						old_destruct(pos, oldnode)
					end
					mcl_redstone._update_opaque_connections(pos)
					mcl_redstone.after(0, function()
						opaque_update_neighbours(pos)
					end)
				end,
			})
		end

		if minetest.get_item_group(name, "redstone_wire") ~= 0 then
			local old_construct = ndef.on_construct
			local old_destruct = ndef.after_destruct
			minetest.override_item(name, {
				on_construct = function(pos)
					if old_construct then
						old_construct(pos)
					end
					update_wire(pos)
				end,
				after_destruct = function(pos, oldnode)
					if old_destruct then
						old_destruct(pos, oldnode)
					end
					update_wire(pos, oldnode)
				end,
			})
		end

		if ndef._mcl_redstone then
			local init = ndef._mcl_redstone.init or ndef._mcl_redstone.update
			get_power_tab[name] = ndef._mcl_redstone.get_power
			init_tab[name] = init
			update_tab[name] = ndef._mcl_redstone.update

			local old_construct = ndef.on_construct
			local old_destruct = ndef.after_destruct
			minetest.override_item(name, {
				groups = table.merge(ndef.groups, {
					redstone_init = init and 1,
					redstone_get_power = ndef._mcl_redstone.get_power and 1,
				}),
				on_construct = function(pos)
					if old_construct then
						old_construct(pos)
					end
					if ndef._mcl_redstone.connects_to then
						mcl_redstone._connect_with_wires(pos)
					end
					mcl_redstone._abort_pending_update(pos)
					mcl_redstone.after(0, function()
						if init then
							call_init(pos)
						end
						if ndef._mcl_redstone.get_power then
							update_neighbours(pos)
						end
					end)
				end,
				after_destruct = function(pos, oldnode)
					if old_destruct then
						old_destruct(pos, oldnode)
					end
					if ndef._mcl_redstone.connects_to then
						mcl_redstone._connect_with_wires(pos)
					end
					if ndef._mcl_redstone.get_power then
						mcl_redstone._abort_pending_update(pos)
						mcl_redstone.after(0, function()
							update_neighbours(pos, oldnode)
						end)
					end
				end,
			})
		end
	end
end)

minetest.register_lbm({
	label = "Perform redstone node initialization",
	name = "mcl_redstone:update",
	nodenames = {"group:redstone_init"},
	run_at_every_load = true,
	action = function(pos, node, dtime)
		call_init(pos)
	end,
})

minetest.register_lbm({
	label = "Perform redstone updates to neighbouring nodes",
	name = "mcl_redstone:update_neighbours",
	nodenames = {"group:redstone_get_power"},
	run_at_every_load = true,
	action = function(pos, node, dtime)
		update_neighbours(pos)
	end,
})
