unused_args = false
allow_defined_top = true
max_line_length = false
redefined = false
ignore = {
	--this is used intentionally in the codebase sometimes
	"512", -- Loop can be executed at most once.
}
globals = {
	"minetest", "core",
	"doc",
	"tt",
	"mesecon",
	"lightning",
	"controls",
	"flowlib",
	"awards",
	"mobs_mc",
	"screwdriver",
	"playerphysics",
	"mcl_panes",
	"tnt",
	"hb",
	"tsm_railcorridors",
	"tga_encoder",
	"hb",
	"walkover",
	"mcl_achievements",
	"mcl_amethyst",
	"mcl_anvils",
	"mcl_armor",
	"mcl_armor_stand",
	"mcl_attached",
	"_mcl_autogroup",
	"mcl_autogroup",
	"mcl_bamboo",
	"mcl_banners",
	"mcl_barrels",
	"mcl_base_textures",
	"mcl_beacons",
	"mcl_beds",
	"mcl_beehives",
	"mcl_bells",
	"mcl_biomes",
	"mcl_blackstone",
	"mcl_blast_furnace",
	"mcl_boats",
	"mcl_bone_meal",
	"mcl_books",
	"mcl_bossbars",
	"mcl_bows",
	"mcl_brewing",
	"mcl_buckets",
	"mcl_burning",
	"mcl_cake",
	"mcl_campfires",
	"mcl_cartography_table",
	"mcl_cauldrons",
	"mcl_cherry_blossom",
	"mcl_chests",
	"mcl_clock",
	"mcl_cocoas",
	"mcl_colorblocks",
	"mcl_colors",
	"mcl_commands",
	"mcl_comparators",
	"mcl_compass",
	"mcl_composters",
	"mcl_copper",
	"mcl_core",
	"mcl_craftguide",
	"mcl_crafting_table",
	"mcl_credits",
	"mcl_crimson",
	"mcl_criticals",
	"mcl_curry",
	"mcl_damage",
	"mcl_death_drop",
	"mcl_death_messages",
	"mcl_deepslate",
	"mcl_dispensers",
	"mcl_doc",
	"mcl_doc_basics",
	"mcl_doors",
	"mcl_dripping",
	"mcl_droppers",
	"mcl_dungeons",
	"mcl_dyes",
	"mcl_enchanting",
	"mcl_end",
	"mcl_end_island",
	"mcl_entity_invs",
	"mcl_events",
	"mcl_experience",
	"mcl_explosions",
	"mcl_falling_nodes",
	"mcl_farming",
	"mcl_fences",
	"mcl_fire",
	"mcl_fireworks",
	"mcl_fishing",
	"mcl_fletching_table",
	"mcl_flowerpots",
	"mcl_flowers",
	"mcl_formspec",
	"mcl_formspec_prepend",
	"mcl_furnaces",
	"mcl_grindstone",
	"mcl_hbarmor",
	"mcl_heads",
	"mcl_honey",
	"mcl_hoppers",
	"mcl_hunger",
	"mcl_info",
	"mcl_init",
	"mcl_inventory",
	"mcl_item_entity",
	"mcl_itemframes",
	"mcl_item_id",
	"mcl_jukebox",
	"mcl_lanterns",
	"mcl_lectern",
	"mcl_lightning_rods",
	"mcl_loom",
	"mcl_loot",
	"mcl_mangrove",
	"mcl_mapgen_core",
	"mcl_maps",
	"mcl_meshhand",
	"mcl_minecarts",
	"mcl_mobitems",
	"mcl_mobs",
	"mcl_mobspawners",
	"mcl_monster_eggs",
	"mcl_moon",
	"mcl_mud",
	"mcl_mushrooms",
	"mcl_nether",
	"mcl_nether_fortresses",
	"mcl_observers",
	"mcl_ocean",
	"mcl_offhand",
	"mcl_paintings",
	"mcl_particles",
	"mcl_player",
	"mcl_playerinfo",
	"mcl_player_init",
	"mcl_playerplus",
	"mcl_portals",
	"mcl_potions",
	"mcl_pottery_sherds",
	"mcl_privs",
	"mcl_raids",
	"mcl_raw_ores",
	"mcl_sculk",
	"mcl_shields",
	"mcl_signs",
	"mcl_skins",
	"mcl_smithing_table",
	"mcl_smoker",
	"mcl_sounds",
	"mcl_spawn",
	"mcl_sponges",
	"mcl_sprint",
	"mcl_spyglass",
	"mcl_stairs",
	"mcl_stonecutter",
	"mcl_strongholds",
	"mcl_structures",
	"mcl_sus_stew",
	"mcl_target",
	"mcl_temp_helper_recipes",
	"mcl_terrain_features",
	"mcl_throwing",
	"mcl_title",
	"mcl_tnt",
	"mcl_tools",
	"mcl_torches",
	"mcl_totems",
	"mcl_trees",
	"mcl_tt",
	"mcl_util",
	"mcl_villages",
	"mcl_void_damage",
	"mcl_walls",
	"mcl_weather",
	"mcl_wieldview",
	"mcl_wip",
	"mcl_wither_spawning",
	"mcl_wool",
	"mcl_worlds",
	"mcl_zombie_sieges",
	"mcl_lush_caves",
	"mcl_armor_trims",
	"settlements",
}

read_globals = {
	"DIR_DELIM",
	"dump", "dump2",
	"vector",
	"VoxelManip", "VoxelArea",
	"PseudoRandom", "PcgRandom", "PerlinNoise", "PerlinNoiseMap",
	"ItemStack",
	"Settings",
	"unpack",

	table = {
		fields = {
			update = { read_only = false },
			update_nil = { read_only = false },
			merge = { read_only = false },
			"copy",
			"indexof",
			"insert_all",
			"key_value_swap",
			"shuffle",
			reverse = { read_only = false },
		}
	},

	string = {
		fields = {
			"split",
			"trim",
		}
	},

	math = {
		fields = {
			"hypot",
			"sign",
			"factorial",
			"round",
		}
	},
	------
	--MODS
	------

	--CORE
	"mcl_vars",

	--GENERAL
	"default",


	--ENTITIES
	"cmi",

	--HUD

	"cmsg",

	"sfinv", "sfinv_buttons", "unified_inventory", "cmsg", "inventory_plus",
}
