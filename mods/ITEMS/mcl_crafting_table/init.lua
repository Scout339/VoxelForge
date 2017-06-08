minetest.register_node("mcl_crafting_table:crafting_table", {
	description = "Crafting Table",
	_doc_items_longdesc = "A crafting table is a block which grants you access to a 3×3 crafting grid which allows you to perform advanced crafts.",
	_doc_items_usagehelp = "Rightclick the crafting table to access the 3×3 crafting grid.",
	_doc_items_hidden = false,
	is_ground_content = false,
	tiles = {"crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png"},
	paramtype2 = "facedir",
	paramtype = "light",
	groups = {handy=1,axey=1, deco_block=1, material_wood=1},
	on_rightclick = function(pos, node, player, itemstack)
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)

		local form = "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;crafting_formspec_bg.png^crafting_inventory_workbench.png]"..
		mcl_vars.inventory_header..
		"list[current_player;main;0,4.5;9,3;9]"..
		"list[current_player;main;0,7.74;9,1;]"..
		"list[current_player;craft;1.75,0.5;3,3;]"..
		"list[current_player;craftpreview;6.1,1.5;1,1;]"..
		"image_button[0.75,1.5;1,1;craftguide_book.png;__mcl_craftguide;]"..
		"tooltip[__mcl_craftguide;Show crafting recipes]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"

		minetest.show_formspec(player:get_player_name(), "main", form)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 12.5,
	_mcl_hardness = 2.5,
})

minetest.register_craft({
	output = "mcl_crafting_table:crafting_table",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_crafting_table:crafting_table",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "mcl_crafting_table:crafting_table")
minetest.register_alias("mcl_inventory:workbench", "mcl_crafting_table:crafting_table")
