local S = minetest.get_translator(minetest.get_current_modname())

vlf_buttons = {}

-- Push the button
function vlf_buttons.push_button(pos, node)
	local def = minetest.registered_nodes[node.name]
	minetest.set_node(pos, {name="vlf_buttons:button_"..def._vlf_button_basename.."_on", param2=node.param2})
	minetest.sound_play(def._vlf_redstone_push_sound, {pos=pos}, true)
end

local function on_button_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
		-- no interaction possible with entities
		return itemstack
	end

	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local def = minetest.registered_nodes[node.name]
	if not def then return end
	local groups = def.groups

	local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	-- If the pointed node is buildable, let's look at the node *behind* that node
	if def.buildable_to then
		local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
		local actual = vector.subtract(under, dir)
		local actualnode = minetest.get_node(actual)
		def = minetest.registered_nodes[actualnode.name]
		groups = def.groups
	end

	-- Only allow placement on full-cube solid opaque nodes
	if type(def.placement_prevented) == "function" then
		if
			def.placement_prevented({
				itemstack = itemstack,
				placer = placer,
				pointed_thing = pointed_thing,
			})
		then
			return itemstack
		end
	elseif
		not groups
		or not groups.solid
		or not groups.opaque
		or (def.node_box and def.node_box.type ~= "regular")
	then
		return itemstack
	end

	local idef = itemstack:get_definition()
	local itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)

	if success then
		if idef.sounds and idef.sounds.place then
			minetest.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
		end
	end
	return itemstack
end

function vlf_buttons.register_button(basename, def)
	local description = def.description
	local texture = def.texture
	local recipeitem = def.recipeitem
	local groups = def.groups
	local sounds = def.sounds
	local push_by_arrow = def.push_by_arrow
	local longdesc = def.longdesc
	local push_duration = def.push_duration
	local push_sound = def.push_sound
	local burntime = def.burntime

	local tt = S("Provides redstone power when pushed")
	tt = tt .. "\n" .. S("Push duration: @1s", string.format("%.1f", push_duration))
	if push_by_arrow then
		tt = tt .. "\n" .. S("Pushable by arrow")
	end
	local commdef = {
		drawtype = "nodebox",
		tiles = {texture},
		wield_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		inventory_image = "mesecons_button_wield_mask.png^"..texture.."^mesecons_button_wield_mask.png^[makealpha:255,126,126",
		wield_scale = { x=1, y=1, z=1},
		paramtype = "light",
		paramtype2 = "wallmounted",
		is_ground_content = false,
		walkable = false,
		sunlight_propagates = true,
		groups = table.merge(groups, {attached_node=1, dig_by_water=1, dig_by_piston=1, button=1, attaches_to_base=1, attaches_to_side=1, attaches_to_top=1, button_push_by_arrow = push_by_arrow and 1 or 0}),
		description = description,
		_tt_help = tt,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = S("Use the button to push it."),
		on_place = on_button_place,
		node_placement_prediction = "",
		sounds = sounds,
		_vlf_blast_resistance = 0.5,
		_vlf_hardness = 0.5,
		_vlf_button_basename = basename,
		_vlf_burntime = burntime,
		_vlf_redstone_push_sound = push_sound or "mesecons_button_push",
		_vlf_redstone = {
			connects_to = function(node)
				return true
			end,
		},
	}

	minetest.register_node(":vlf_buttons:button_"..basename.."_off", table.merge(commdef, {
		node_box = {
			type = "wallmounted",
			wall_side = { -8/16, -2/16, -4/16, -6/16, 2/16, 4/16 },
			wall_bottom = { -4/16, -8/16, -2/16, 4/16, -6/16, 2/16 },
			wall_top = { -4/16, 6/16, -2/16, 4/16, 8/16, 2/16 },
		},
		groups = table.merge(commdef.groups, {button=1}),
		on_rightclick = function(pos, node)
			vlf_buttons.push_button(pos, node)
		end,
		sounds = sounds,
		_on_arrow_hit = function(pos, arrowent)
			local node = minetest.get_node(pos)
			local bdir = minetest.wallmounted_to_dir(node.param2)
			if vector.equals(vector.add(pos, bdir), arrowent._stuckin) then
				vlf_buttons.push_button(pos, node)
				return true
			end
		end,
		_on_copper_golem_hit = function(pos)
			local node = minetest.get_node(pos)
			if node.name == "vlf_buttons:button_copper_off" then
				vlf_buttons.push_button(pos, node)
				return true
			else
				return
			end
		end,
	}))

	minetest.register_node(":vlf_buttons:button_"..basename.."_on", table.merge(commdef, {
		node_box = {
			type = "wallmounted",
			wall_side = { -8/16, -2/16, -4/16, -7/16, 2/16, 4/16 },
			wall_bottom = { -4/16, -8/16, -2/16, 4/16, -7/16, 2/16 },
			wall_top = { -4/16, 7/16, -2/16, 4/16, 8/16, 2/16 },
		},
		groups = table.merge(commdef.groups, {button=2, button_on=1, not_in_creative_inventory=1}),
		drop = "vlf_buttons:button_"..basename.."_off",
		_doc_items_create_entry = false,
		_vlf_redstone = table.merge(commdef._vlf_redstone, {
			get_power = function(node, dir)
				return 15, node.param2 == minetest.dir_to_wallmounted(dir)
			end,
			init = function(pos, node)
				vlf_redstone.after(push_duration, function()
					minetest.sound_play(push_sound, {pos=pos, pitch=0.9}, true)
				end)
				return {
					delay = push_duration,
					name = "vlf_buttons:button_"..basename.."_off",
					param2 = node.param2,
				}
			end,
		}),
	}))

	minetest.register_craft({
		output = "vlf_buttons:button_"..basename.."_off",
		recipe = {{ recipeitem }},
	})
end

vlf_buttons.register_button("stone", {
	description = S("Stone Button"),
	texture = "default_stone.png",
	recipeitem = "vlf_core:stone",
	sounds = vlf_sounds.node_sound_stone_defaults(),
	groups = {material_stone=1,handy=1,pickaxey=1},
	push_duration = 10,
	push_by_arrow = false,
	longdesc = S("A stone button is a redstone component made out of stone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
	push_sound = "mesecons_button_push",
})

vlf_buttons.register_button("polished_blackstone", {
	description = S("Polished Blackstone Button"),
	texture = "vlf_blackstone_polished.png",
	recipeitem = "vlf_blackstone:blackstone_polished",
	sounds = vlf_sounds.node_sound_stone_defaults(),
	groups = {material_stone=1,handy=1,pickaxey=1},
	push_duration = 10,
	push_by_arrow = false,
	longdesc = S("A polished blackstone button is a redstone component made out of polished blackstone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
	push_sound = "mesecons_button_push",
})

vlf_buttons.register_button("copper", {
	description = S("Copper Button"),
	texture = "vlf_copper_copper.png",
	recipeitem = "vlf_copper:copper_block",
	sounds = vlf_sounds.node_sound_stone_defaults(),
	groups = {material_stone=1,handy=1,pickaxey=1},
	push_duration = 10,
	push_by_arrow = false,
	longdesc = S("A Copper button is a redstone component made out of copper which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
	push_sound = "mesecons_button_push"
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "vlf_buttons:button_wood_off", "nodes", "vlf_buttons:button_wood_on")
	doc.add_entry_alias("nodes", "vlf_buttons:button_stone_off", "nodes", "vlf_buttons:button_stone_on")
end
