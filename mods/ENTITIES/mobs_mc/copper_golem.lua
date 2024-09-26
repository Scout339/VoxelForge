local S = minetest.get_translator(minetest.get_current_modname())

local oxidation_levels = {
	{level = 1, name = "normal", texture = "copper_golem.png"},
	{level = 2, name = "exposed", texture = "exposed_copper_golem.png"},
	{level = 3, name = "weathered", texture = "weathered_copper_golem.png"},
	{level = 4, name = "oxidized", texture = "oxidized_copper_golem.png"}
}

local button_check_interval = 15

local function find_nearby_copper_button(pos)
	local nearby_buttons = minetest.find_nodes_in_area(
		vector.subtract(pos, 5),
		vector.add(pos, 5),
		{"mesecons_button:copper_button_off"}
	)
	if #nearby_buttons > 0 then
		return nearby_buttons[math.random(#nearby_buttons)]
	end
	return nil
end

-- Function to handle oxidation
local function handle_oxidation(self)
	if self.oxidation_level < 4 and not self.waxed then
		-- 33% chance to oxidize to the next level
		if math.random() < 0.33 then
			self.oxidation_level = self.oxidation_level + 1
			self.base_texture = {oxidation_levels[self.oxidation_level].texture}
			self.object:set_properties({textures = self.base_texture})
			if self.oxidation_level == 4 then
				self.walk_velocity = 0
				self.run_velocity = 0
				self.randomly_turn = false
				self.pushable = false
				self.animation = {
					stand_start = 48, stand_end = 49, stand_speed = 2,
					walk_start = 48, walk_end = 49, speed_normal = 0
				}
				self.state = "stand"
			end
		end
	end
end

vlf_mobs.register_mob("mobs_mc:copper_golem", {
	description = S("Copper Golem"),
	type = "npc",
	can_despawn = false,
	passive = true,
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.5, -0.0, -0.5, 0.5, 0.7, 0.5},
	visual = "mesh",
	mesh = "mobs_mc_copper_golem-2.b3d",
	textures = {"copper_golem.png"},
	visual_size = {x = 10, y = 10},
	sounds = {},
	walk_velocity = 0.34,
	run_velocity = 0.34,
	animation = {
		stand_start = 38, stand_end = 44, stand_speed = 2,
		walk_start = 0, walk_end = 25, speed_normal = 25,
	},
	walk_chance = 80,
	fall_damage = 10,
	view_range = 8,
	fear_height = 4,
	jump = true,
	randomly_turn = true,
	makes_footstep_sound = false,
	oxidation_level = 1,
	base_texture = "",
	waxed = false,
	heading_to_button = false,
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local item_name = item:get_name()
		local pos = self.object:get_pos()

		if item_name:find("axe") and not item_name:find("pickaxe") and not item_name:find("waxed") and (self.oxidation_level > 1 or self.waxed) then
			if self.waxed then
				awards.unlock(clicker:get_player_name(), "vlf:wax_off")
				self.waxed = false
				vlf_honey.particles(pos)
			else
				self.oxidation_level = self.oxidation_level - 1
				self.object:set_properties({textures = {oxidation_levels[self.oxidation_level].texture}})
				if self.oxidation_level < 4 then
					self.walk_velocity = 0.34
					self.run_velocity = 0.34
					self.randomly_turn = true
					self.pushable = true
					self.animation = {
						stand_start = 38, stand_end = 44, stand_speed = 2,
						walk_start = 0, walk_end = 25, speed_normal = 25,
					}
					self.state = "walk"
					if self.oxidation_level > 3 then
						vlf_honey.particles(pos)
					else
						vlf_honey.particles(pos, "vlf_copper_anti_oxidation_particle.png^[colorize:#6CC298:125")
					end
				end
			end
		end
		if item_name == "vlf_honey:honeycomb" and self.oxidation_level < 4 and not self.waxed then
			awards.unlock(clicker:get_player_name(), "vlf:wax_on")
			self.waxed = true
			vlf_honey.particles(pos, "vlf_copper_anti_oxidation_particle.png^[colorize:#E58A14:125")
		end
	end,
	do_custom = function(self)
		local curr_time = os.time()
		if not self.last_oxidation_attempt then
			self.last_oxidation_attempt = os.time()
		end
		local current_time = os.time()
		local time_since_last_oxidation = current_time - self.last_oxidation_attempt
		if time_since_last_oxidation >= 2 then
			self.last_oxidation_attempt = current_time
			handle_oxidation(self)
		end
		if not self.button_timer then
			self.button_timer = curr_time
		end
		if curr_time - self.button_timer >= button_check_interval then
			self.button_timer = curr_time  -- Reset the timer for the next interval
			if self.oxidation_level < 4 then
				local pos = self.object:get_pos()
				if not self.target_button_pos then
					self.target_button_pos = find_nearby_copper_button(pos)
				end
				if self.target_button_pos then
					self:go_to_pos(self.target_button_pos)
					self.randomly_turn = false
					self.heading_to_button = true	
				end
			end
		end
	end,
	on_deactivate  = function(self, staticdata)
		oxidation_level = self.oxidation_level
		self.base_texture = self.base_texture or {oxidation_levels[oxidation_level].texture}
		self.object:set_properties({textures = self.base_texture})
	end, 
	on_activate = function(self, staticdata)
		oxidation_level = self.oxidation_level
		self.base_texture = self.base_texture or {oxidation_levels[oxidation_level].texture}
		self.object:set_properties({textures = self.base_texture})
	end,
	_on_lightning_strike = function(self)
		if self.oxidation_level > 1 and not self.waxed then
			self.oxidation_level = self.oxidation_level - 1
			return true
		end
	end,
})

-- Spawn egg
vlf_mobs.register_egg("mobs_mc:copper_golem", S("Copper Golem"), "#A56C68", "#663939", 0)

local function activate_copper_button(button_pos)
	local node = minetest.get_node(button_pos)
	local dpos = vector.round(vector.new(button_pos))
	local bdef = minetest.registered_nodes[node.name]
	if (bdef and bdef._on_copper_golem_hit) then
		bdef._on_copper_golem_hit(dpos, self)
	end
end

local function check_golem_near_buttons()
	local players = minetest.get_connected_players()
	local curr_time = minetest.get_gametime()
	for _, player in ipairs(players) do
		local player_pos = player:get_pos()
		local nearby_objects = minetest.get_objects_inside_radius(player_pos, 20)
		for _, obj in ipairs(nearby_objects) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "mobs_mc:copper_golem" then
 				local golem = obj:get_luaentity()
				local golem_pos = obj:get_pos()
				local copper_buttons = minetest.find_nodes_in_area(
					vector.subtract(golem_pos, 5),
					vector.add(golem_pos, 5),
					{"mesecons_button:copper_button_off"}
				)
				if golem.heading_to_button then
					for _, button_pos in ipairs(copper_buttons) do
						local distance = vector.distance(golem_pos, button_pos)
						if distance <= 2 and golem.oxidation_level < 4 then
							golem.walk_velocity = 0.0
							golem:look_at(button_pos)
							--if golem_pos.y >= button_pos.y then
							if button_pos.y < golem_pos.y+1 then
								golem.object:set_animation({x = 176, y = 214}, 10, 0, false) -- Bending Down
							elseif button_pos.y >= golem_pos.y+1 then
								golem.object:set_animation({x = 72, y = 110}, 10, 0, false)  -- Reaching up
							end
							minetest.after(1, function()
								activate_copper_button(button_pos)
								golem.state = "walk"
								golem.walk_velocity = 0.34
								golem.randomly_turn = true
							end)
							minetest.after(0.1, function()
								golem.heading_to_button = false
							end)
						end
					end
				end
			end
		end
	end
end

minetest.register_globalstep(function(dtime)
	check_golem_near_buttons()
end)
