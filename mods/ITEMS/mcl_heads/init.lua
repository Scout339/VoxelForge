local S = minetest.get_translator(minetest.get_current_modname())

local minetest = minetest
local mod_doc = minetest.get_modpath("doc")
local mod_screwdriver = minetest.get_modpath("screwdriver")

local equip_armor
if minetest.get_modpath("mcl_armor") then
	equip_armor = mcl_armor.equip_on_use
end

mcl_heads = {}
mcl_heads.FLOOR_BOX = { -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, }
mcl_heads.CEILING_BOX = { -0.25, 0, -0.25, 0.25, 0.5, 0.25, }

--- node definition template for floor mod heads
mcl_heads.deftemplate_floor = {
	drawtype = "mesh",
	mesh = "mcl_heads_floor.obj",
	selection_box = {
		type = "fixed",
		fixed = mcl_heads.FLOOR_BOX,
	},
	collision_box = {
		type = "fixed",
		fixed = mcl_heads.FLOOR_BOX,
	},
	groups = {
		handy = 1,
		armor = 1,
		armor_head = 1,
		non_combat_armor = 1,
		non_combat_armor_head = 1,
		head = 1,
		deco_block = 1,
		dig_by_piston = 1,
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype = "light",
	paramtype2 = "degrotate",
	sunlight_propagates = true,
	sounds = mcl_sounds.node_sound_defaults{
		footstep = {name="default_hard_footstep", gain=0.3},
	},
	is_ground_content = false,

	_mcl_armor_element = "head",
	_mcl_blast_resistance = 1,
	_mcl_hardness = 1,

	on_secondary_use = equip_armor,
}

mcl_heads.deftemplate_ceiling = table.copy(mcl_heads.deftemplate_floor)
mcl_heads.deftemplate_ceiling.mesh = "mcl_heads_ceiling.obj"
mcl_heads.deftemplate_ceiling.selection_box = {
	type = "fixed",
	fixed = mcl_heads.CEILING_BOX,
}
mcl_heads.deftemplate_ceiling.collision_box = {
	type = "fixed",
	fixed = mcl_heads.CEILING_BOX,
}

function mcl_heads.deftemplate_floor.on_rotate(pos, node, user, mode, new_param2)
	if mode == screwdriver.ROTATE_AXIS then
		node.name = node.name .. "_wall"
		node.param2 = minetest.dir_to_wallmounted(minetest.facedir_to_dir(node.param2))
		minetest.set_node(pos, node)
		return true
	end
end

function mcl_heads.deftemplate_floor.on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end

	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local def = minetest.registered_nodes[node.name]
	if not def then return itemstack end

	-- Allow pointed node's on_rightclick callback to override place.
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(under, node, placer, itemstack) or itemstack
		end
	end

	local above = pointed_thing.above
	local dir = {x = under.x - above.x, y = under.y - above.y, z = under.z - above.z}
	local wdir = minetest.dir_to_wallmounted(dir)

	local itemstring = itemstack:get_name()
	local placestack = ItemStack(itemstack)

	-- place wall head node (elsewhere)
	if wdir ~= 0 and wdir ~= 1 then
		placestack:set_name(itemstring .."_wall")
		itemstack = minetest.item_place(placestack, placer, pointed_thing, wdir)
	-- place floor head node (floor and ceiling)
	elseif wdir == 0 then
		placestack:set_name(itemstring .."_ceiling")
		itemstack = minetest.item_place(placestack, placer, pointed_thing, placer:get_look_horizontal() * 180 / math.pi / 1.5 ) --param2 value is degrees / 1.5
	else
		itemstack = minetest.item_place(placestack, placer, pointed_thing, placer:get_look_horizontal() * 180 / math.pi / 1.5 ) --param2 value is degrees / 1.5
	end

	-- restore item from angled and wall head nodes
	itemstack:set_name(itemstring)
	return itemstack
end

-- wall head node nodedef template -------------------------------------------------------------------------------------

--- node definition template for wall mod heads
mcl_heads.deftemplate_wall = {
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_bottom = { -0.25, -0.5, -0.25, 0.25, 0.0, 0.25, },
		wall_top = { -0.25, 0.0, -0.25, 0.25, 0.5, 0.25, },
		wall_side = { -0.5, -0.25, -0.25, 0.0, 0.25, 0.25, },
	},
	groups = {
		handy = 1,
		head = 1,
		deco_block = 1,
		dig_by_piston = 1,
		not_in_creative_inventory = 1,
	},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	sounds = mcl_sounds.node_sound_defaults{
		footstep = {name="default_hard_footstep", gain=0.3},
	},
	is_ground_content = false,

	_doc_items_create_entry = false,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 1,
}

function mcl_heads.deftemplate_wall.on_rotate(pos, node, user, mode, new_param2)
	if mode == screwdriver.ROTATE_AXIS then
		node.name = string.sub(node.name, 1, string.len(node.name)-5)
		node.param2 = minetest.dir_to_facedir(minetest.wallmounted_to_dir(node.param2))
		minetest.set_node(pos, node)
		return true
	end
end

-- API functions -------------------------------------------------------------------------------------------------------

--- @class HeadDef
--- @field name string identifier for node
--- @field texture string armor texture for node
--- @field description string translated description
--- @field longdesc string translated doc description
--- @field range_mob string name of mob affected by range reduction
--- @field range_factor number factor of range reduction

--- registers a head
--- @param head_def HeadDef head node definition
function mcl_heads.register_head(head_def)
	local name = "mcl_heads:" ..head_def.name

	-- register the floor head node
	minetest.register_node(name, table.update(table.copy(mcl_heads.deftemplate_floor), {
		description = head_def.description,
		_doc_items_longdesc = head_def.longdesc,

		-- The head textures are based off the textures of an actual mob.
			tiles = { head_def.texture },

		_mcl_armor_mob_range_mob = head_def.range_mob,
		_mcl_armor_mob_range_factor = head_def.range_factor,
		_mcl_armor_texture = head_def.texture
	}))

	minetest.register_node(name.."_ceiling", table.update(table.copy(mcl_heads.deftemplate_ceiling), {
		description = head_def.description,
		_doc_items_longdesc = head_def.longdesc,

		-- The head textures are based off the textures of an actual mob.
			tiles = { head_def.texture },

		_mcl_armor_mob_range_mob = head_def.range_mob,
		_mcl_armor_mob_range_factor = head_def.range_factor,
		_mcl_armor_texture = head_def.texture
	}))

	-- register the wall head node
	minetest.register_node(name .."_wall", table.update(table.copy(mcl_heads.deftemplate_wall), {
		-- The head textures are based off the textures of an actual mob.
		-- Note: -x coords go right per-pixel, -y coords go down per-pixel
		tiles = {
			{ name = "[combine:16x16:-36,-4=" ..head_def.texture, align_style = "world" }, -- front
			{ name = "[combine:16x16:-52,-4="..head_def.texture, align_style = "world" }, -- back
			{ name = "[combine:16x16:-40,-4=" ..head_def.texture, align_style = "world" }, -- right
			{ name = "[combine:16x16:-32,-4="  ..head_def.texture, align_style = "world" }, -- left
			{ name = "([combine:16x16:-36,0=" ..head_def.texture ..")^[transformR180", align_style = "node" }, -- top
			-- Note: bottom texture is overlaid over top texture to get rid of possible transparency.
			-- This is required for skeleton skull and wither skeleton skull.
			{ name = "([combine:16x16:-36,0=" ..head_def.texture ..")^([combine:16x16:-44,8=" ..head_def.texture..")", align_style = "node" }, -- bottom
		},
		drop = name,
	}))
end

-- initial heads -------------------------------------------------------------------------------------------------------

mcl_heads.register_head{
	name = "zombie",
	texture = "mcl_heads_zombie.png",
	description = S("Zombie Head"),
	longdesc = S("A zombie head is a small decorative block which resembles the head of a zombie. It can also be worn as a helmet, which reduces the detection range of zombies by 50%."),
	range_mob = "mobs_mc:zombie",
	range_factor = 0.5,
}

mcl_heads.register_head{
	name = "creeper",
	texture = "mcl_heads_creeper.png",
	description = S("Creeper Head"),
	longdesc = S("A creeper head is a small decorative block which resembles the head of a creeper. It can also be worn as a helmet, which reduces the detection range of creepers by 50%."),
	range_mob = "mobs_mc:creeper",
	range_factor = 0.5,
}

-- Original Minecraft name: “Head”
mcl_heads.register_head{
	name = "steve",
	texture = "mcl_heads_steve.png",
	description = S("Human Head"),
	longdesc = S("A human head is a small decorative block which resembles the head of a human (i.e. a player character). It can also be worn as a helmet for fun, but does not offer any protection."),
}

mcl_heads.register_head{
	name = "skeleton",
	texture = "mcl_heads_skeleton.png",
	description = S("Skeleton Skull"),
	longdesc = S("A skeleton skull is a small decorative block which resembles the skull of a skeleton. It can also be worn as a helmet, which reduces the detection range of skeletons by 50%."),
	range_mob = "mobs_mc:skeleton",
	range_factor = 0.5,
}

mcl_heads.register_head{
	name = "wither_skeleton",
	texture = "mcl_heads_wither_skeleton.png",
	description = S("Wither Skeleton Skull"),
	longdesc = S("A wither skeleton skull is a small decorative block which resembles the skull of a wither skeleton. It can also be worn as a helmet for fun, but does not offer any protection."),
}

local old_rots = {
	["22_5"] = 22.5,
	["45"] = 45,
	["67_5"] = 67.5,
}

local old_bheads = {
	"mcl_heads:steve",
	"mcl_heads:zombie",
	"mcl_heads:skeleton",
	"mcl_heads:creeper",
	"mcl_heads:wither_skeleton",
}

local old_rheads = {
	"mcl_heads:creeper22_5",
	"mcl_heads:creeper45",
	"mcl_heads:creeper67_5",

	"mcl_heads:wither_skeleton22_5",
	"mcl_heads:wither_skeleton45",
	"mcl_heads:wither_skeleton67_5",

	"mcl_heads:skeleton45",
	"mcl_heads:skeleton22_5",
	"mcl_heads:skeleton67_5",

	"mcl_heads:steve22_5",
	"mcl_heads:steve45",
	"mcl_heads:steve67_5",

	"mcl_heads:zombie22_5",
	"mcl_heads:zombie45",
	"mcl_heads:zombie67_5",
}

minetest.register_lbm({
	name = "mcl_heads:convert_old_angled_heads",
	nodenames = old_rheads,
	run_at_every_load = false,
	action = function(pos, node, dtime_s)
		local ceiling = node.param2 >= 20
		local rt, nn
		for k,v in pairs(old_rots) do
			if node.name:find(k) then
				rt = v
				nn = node.name:gsub(k,"")
			end
		end
		if rt and nn then
			if ceiling then nn = nn.."_ceiling" end
			minetest.swap_node(pos,{name=nn,param2=(rt / 1.5)})
		end
	end,
})

minetest.register_lbm({
	name = "mcl_heads:convert_old_ceiling_heads",
	nodenames = old_bheads,
	run_at_every_load = false,
	action = function(pos, node, dtime_s)
		local ceiling = node.param2 >= 20
		if ceiling then
			node.name = node.name.."_ceiling"
			minetest.swap_node(pos,node)
		end
	end,
})
