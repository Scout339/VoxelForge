vlf_player = {
	registered_globalsteps = {},
	registered_globalsteps_slow = {},
	players = {},
}

local default_fov = 86.1 --see <https://minecraft.gamepedia.com/Options#Video_settings>>>>

local tpl_playerinfo = {
	textures = { "character.png", "blank.png", "blank.png" },
	model = "",
	animation = "",
	sneak = false,
	visible = true,
	attached = false,
	elytra = {active = false, rocketing = 0, speed = 0},
	is_pressing_jump = {},
	lastPos = nil,
	swimDistance = 0,
	jump_cooldown = -1,	-- Cooldown timer for jumping, we need this to prevent the jump exhaustion to increase rapidly
	vel_yaw = nil,
	is_swimming = false,
	nodes = {},
}

local nodeinfo_pos = { --offset positions of the "nodeinfo" nodes.
	stand =       vector.new(0, -0.1, 0),
	stand_below = vector.new(0, -1.1, 0),
	head =        vector.new(0, 1.4, 0),
	head_top =    vector.new(0, 1.9, 0),
	feet =        vector.new(0, 0.2, 0),
}
vlf_player.node_offsets = nodeinfo_pos

-- Minetest bug: get_bone_position() returns all zeros vectors.
-- Workaround: call set_bone_position() one time first.
-- (Set in on_joinplayer)
local bone_start_positions = {
	Head_Control =            vector.new(0, 6.75, 0),
	Arm_Right_Pitch_Control = vector.new(-3, 5.785, 0),
	Arm_Left_Pitch_Control =  vector.new(3, 5.785, 0),
	Body_Control =            vector.new(0, 6.75, 0),
}

for k, _ in pairs(nodeinfo_pos) do
	tpl_playerinfo.nodes[k] = ""
end

local slow_gs_timer = 0.5

minetest.register_on_joinplayer(function(player)
	vlf_player.players[player] = table.copy(tpl_playerinfo)
	player:get_inventory():set_size("hand", 1)
	player:set_fov(default_fov)
	for bone, pos in pairs(bone_start_positions) do
		player:set_bone_position(bone, pos)
	end
end)

minetest.register_on_leaveplayer(function(player)
	vlf_player.players[player] = nil
end)

local function node_ok(pos, fallback)
	local node = minetest.get_node_or_nil(pos)
	if node and node.name and minetest.registered_nodes[node.name] then
		return node.name
	end
	return fallback or "air"
end

function vlf_player.register_globalstep(func)
	table.insert(vlf_player.registered_globalsteps, func)
end

function vlf_player.register_globalstep_slow(func)
	table.insert(vlf_player.registered_globalsteps_slow, func)
end

-- Check each player and run callbacks
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		for _, func in pairs(vlf_player.registered_globalsteps) do
			if vlf_player.players[player] then
				func(player, dtime)
			end
		end
	end

	slow_gs_timer = slow_gs_timer - dtime
	if slow_gs_timer > 0 then return end
	slow_gs_timer = 0.5
	for _, player in pairs(minetest.get_connected_players()) do
		for _, func in pairs(vlf_player.registered_globalsteps_slow) do
			if vlf_player.players[player] then
				func(player, dtime)
			end
		end
		vlf_player.players[player].lastPos = player:get_pos()
	end
end)

--cache nodes near the player according to offsets defined above
vlf_player.register_globalstep_slow(function(player, dtime)
	for k, v in pairs(nodeinfo_pos) do
		vlf_player.players[player].nodes[k] = node_ok(vector.add(player:get_pos(), v))
	end
end)

vlf_player.register_globalstep_slow(function(player, dtime)
	-- Is player suffocating inside node? (Only for solid full opaque cube type nodes
	-- without group disable_suffocation=1)
	-- if swimming, check the feet node instead, because the head node will be above the player when swimming
	local ndef = minetest.registered_nodes[vlf_player.players[player].nodes.head]
	if vlf_player.players[player].is_swimming then
		ndef = minetest.registered_nodes[vlf_player.players[player].nodes.feet]
	end
	if (ndef.walkable == nil or ndef.walkable == true)
	and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
	and (ndef.node_box == nil or ndef.node_box.type == "regular")
	and (ndef.groups.disable_suffocation ~= 1)
	and (ndef.groups.opaque == 1)
	and (vlf_player.players[player].nodes.head ~= "ignore")
	-- Check privilege, too
	and (not minetest.check_player_privs(player:get_player_name(), {noclip = true})) then
		if player:get_hp() > 0 then
			vlf_util.deal_damage(player, 1, {type = "in_wall"})
		end
	end
end)

-- Don't change HP if the player falls in the water or through End Portal:
vlf_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "fall" then
		local pos = obj:get_pos()
		local node = minetest.get_node(pos)
		local velocity = obj:get_velocity() or obj:get_player_velocity() or {x=0,y=-10,z=0}
		local v_axis_max = math.max(math.abs(velocity.x), math.abs(velocity.y), math.abs(velocity.z))
		local step = {x = velocity.x / v_axis_max, y = velocity.y / v_axis_max, z = velocity.z / v_axis_max}
		for i = 1, math.ceil(v_axis_max/5)+1 do -- trace at least 1/5 of the way per second
			if not node or node.name == "ignore" then
				minetest.get_voxel_manip():read_from_map(pos, pos)
				node = minetest.get_node(pos)
			end
			if node then
				local def = minetest.registered_nodes[node.name]
				if not def or def.walkable then
					return
				end
				if minetest.get_item_group(node.name, "water") ~= 0 then
					return 0
				end
				if node.name == "vlf_portals:portal_end" then
					if vlf_portals and vlf_portals.end_teleport then
						vlf_portals.end_teleport(obj)
					end
					return 0
				end
				if node.name == "vlf_core:cobweb" then
					return 0
				end
				if node.name == "vlf_powder_snow:powder_snow" then
					return 0
				end
				if node.name == "vlf_core:vine" then
					return 0
				end
			end
			pos = vector.add(pos, step)
			node = minetest.get_node(pos)
		end
	end
end, -200)

local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/animations.lua")
dofile(modpath.."/compat.lua")

local hud_def = {
	hud_id = {},
	image = "underwater_overlay.png",
	position = {x=0.5, y=0.5},
	offset = {x=0, y=0},
	size = {x=100, y=100},
	alignment = {x=0, y=0},
	scale = {x=300, y=100},
}

local function is_player_underwater(player)
	local pos = player:get_pos()
	local node = minetest.get_node_or_nil({x = pos.x, y = pos.y + 1.7, z = pos.z})
	if node and minetest.get_item_group(node.name, "water") > 0 then
		return true
	end
	return false
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if is_player_underwater(player) then
			if not hud_def.hud_id[player_name] then
				hud_def.hud_id[player_name] = player:hud_add({
					hud_elem_type = "image",
					position = hud_def.position,
					offset = hud_def.offset,
					text = hud_def.image,
					alignment = hud_def.alignment,
					scale = hud_def.scale,
					size = hud_def.size,
				})
			end
			player:set_sun({texture = "vlf_sun_underwater_sun.png", scale=3.25})
			player:set_moon({scale=4.25})
		else
			if hud_def.hud_id[player_name] then
				player:hud_remove(hud_def.hud_id[player_name])
				hud_def.hud_id[player_name] = nil
			end
			player:set_sun({texture = "vlf_sun_underwater_sun.png", scale=2.5})
			player:set_sun({scale=2.5})
			player:set_moon({scale=3.75})
		end
	end
end)
