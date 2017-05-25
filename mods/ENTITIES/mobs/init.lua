
local path = minetest.get_modpath("mobs")

-- Mob API
dofile(path .. "/api.lua")

-- Rideable Mobs
dofile(path .. "/mount.lua")

-- Mob Items
dofile(path .. "/crafts.lua")

-- Mob Spawner
-- MCL2 has its own spawners in mcl_mobspawners

-- Lucky Blocks
dofile(path .. "/lucky_block.lua")

print ("[MOD] Mobs Redo loaded")
