mcl_dyes = {}

local S = minetest.get_translator(minetest.get_current_modname())
local D = mcl_util.get_dynamic_translator()

-- Common color table to be used by other mods. The "mcl2" field if present
-- represents the name of the color in mcl2 if it is different. This is used
-- in the mcl_dye compat mod to adabt the recipes.
mcl_dyes.colors = {
	["white"] = {
		readable_name = "White",
		groups = {basecolor_white=1,   excolor_white=1,     unicolor_white=1},
		rgb = "#d0d6d7",
		unicolor = "white",
		mcl2 = "white",
		palette_index = 0
	},
	["silver"] = {
		readable_name = "Light Grey",
		groups = {basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1},
		rgb = "#818177",
		unicolor = "grey",
		mcl2 = "grey",
		palette_index = 1
	},
	["grey"] = {
		readable_name = "Grey",
		groups = {basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1},
		rgb = "#383c40",
		unicolor = "darkgrey",
		mcl2 = "dark_grey",
		palette_index = 2
	},
	["black"] = {
		readable_name = "Black",
		groups = {basecolor_black=1,   excolor_black=1,     unicolor_black=1},
		rgb = "#080a10",
		unicolor = "black",
		mcl2 = "black",
		palette_index = 3
	},
	["purple"] = {
		readable_name = "Purple",
		groups = {basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1},
		rgb = "#6821a0",
		unicolor = "violet",
		mcl2 = "violet",
		palette_index = 4
	},
	["blue"] = {
		readable_name = "Blue",
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1},
		rgb = "#2e3094",
		unicolor = "blue",
		mcl2 = "blue",
		palette_index = 5
	},
	["light_blue"] = {
		readable_name = "Light Blue",
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_light_blue=1},
		rgb = "#258ec9",
		unicolor = "light_blue",
		mcl2 = "lightblue",
		palette_index = 6
	},
	["cyan"] = {
		readable_name = "Cyan",
		groups = {basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1},
		rgb = "#167b8c",
		unicolor = "cyan",
		mcl2 = "cyan",
		palette_index = 7
	},
	["green"] = {
		readable_name = "Green",
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1},
		rgb = "#4b5e25",
		unicolor = "dark_green",
		mcl2 = "dark_green",
		palette_index = 8
	},
	["lime"] = {
		readable_name = "Lime",
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_green=1},
		rgb = "#60ac19",
		unicolor = "green",
		mcl2 = "green",
		palette_index = 9
	},
	["yellow"] = {
		readable_name = "Yellow",
		groups = {basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1},
		rgb = "#f1b216",
		unicolor = "yellow",
		mcl2 = "yellow",
		palette_index = 10
	},
	["brown"] = {
		readable_name = "Brown",
		groups = {basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1},
		rgb = "#633d20",
		unicolor = "dark_orange",
		mcl2 = "brown",
		palette_index = 11
	},
	["orange"] = {
		readable_name = "Orange",
		groups = {basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1},
		rgb = "#e26501",
		unicolor = "orange",
		mcl2 = "orange",
		palette_index = 12
	},
	["red"] = {
		readable_name = "Red",
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_red=1},
		rgb = "#912222",
		unicolor = "red",
		mcl2 = "red",
		palette_index = 13
	},
	["magenta"] = {
		readable_name = "Magenta",
		groups = {basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1},
		rgb = "#ab31a2",
		unicolor = "red_violet",
		mcl2 = "magenta",
		palette_index = 14
	},
	["pink"] = {
		readable_name = "Pink",
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_light_red=1},
		rgb = "#d56791",
		unicolor = "light_red",
		mcl2 = "pink",
		palette_index = 15
	},
}

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a
-- corresponding dye name (if it exists), nil otherwise.
function mcl_dyes.unicolor_to_dye(unicolor_group)
	for k,v in pairs(mcl_dyes.colors) do
		if v.groups[unicolor_group] == 1 then return "mcl_dyes:"..k end
	end
end

function mcl_dyes.mcl2_to_color(mcl2color)
	for k,v in pairs(mcl_dyes.colors) do
		if mcl2color == v.mcl2 then return k end
	end
end

---Returns the definition of a color based on it's palette_index.
---@param index number?
---@return string?
---@return table?
function mcl_dyes.palette_index_to_color(index)
	for k, v in pairs(mcl_dyes.colors) do
		if v.palette_index == index then return k, v end
	end
end

for k,v in pairs(mcl_dyes.colors) do
	minetest.register_craftitem("mcl_dyes:" .. k, {
		inventory_image = "mcl_dye.png^(mcl_dye_mask.png^[colorize:"..v.rgb..")",
		description = D(v.readable_name .. " Dye"),
		_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
		_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
		groups = table.update({craftitem = 1, dye = 1}, v.groups),
		_color = k,
		on_place = function(itemstack,placer,pointed_thing)
			local def = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
			if def and def._on_dye_place then
				local ret = def._on_dye_place(pointed_thing.under,k)
				if not minetest.is_creative_enabled(placer and placer:get_player_name() or "") then
					if ret ~= true then itemstack:take_item() end
				end
			else
				local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
				if rc then return rc end
			end

			return itemstack
		end,
	})
end

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:grey 2",
	recipe = {"mcl_dyes:black", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:light_blue 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:silver 3",
	recipe = {"mcl_dyes:black", "mcl_dyes:white", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:silver 2",
	recipe = {"mcl_dyes:grey", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:lime 2",
	recipe = {"mcl_dyes:green", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 4",
	recipe = {"mcl_dyes:blue", "mcl_dyes:white", "mcl_dyes:red", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 3",
	recipe = {"mcl_dyes:pink", "mcl_dyes:red", "mcl_dyes:blue"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 2",
	recipe = {"mcl_dyes:purple", "mcl_dyes:pink"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:pink 2",
	recipe = {"mcl_dyes:red", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:cyan 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:green"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:purple 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:orange 2",
	recipe = {"mcl_dyes:yellow", "mcl_dyes:red"},
})
