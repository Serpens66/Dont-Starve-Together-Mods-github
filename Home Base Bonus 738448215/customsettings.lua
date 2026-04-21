
-------------------------------
-- If you want other ground/floors also work with this mod, add them here.
-- Make sure to do a backup of this modified file, because every mod-update will overwrite your customized customsettings.lua file!

-- The values in these tables will be compared with the "tile_name" from: 
-- tile_id, data = inst:GetCurrentTileType()  ->  GLOBAL.INVERTED_WORLD_TILES[tile_id] = tile_name
-- You can find the games allowed values for example in the tiledefs.lua file "AddTile", use the "tile_name", which is the first argument to AddTile function. 

-- The game saves them in GLOBAL 
-- WORLD_TILES[tile_name] = tile_id
-- INVERTED_WORLD_TILES[tile_id] = tile_name

-- floors that should act like wooden with this mod
GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS = 
{
  "WOODFLOOR",
}

-- floors that should act like marble with this mod
GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS = 
{
  "CHECKER",
  "COTL_GOLD",
  "MOSAIC_GREY",
  "MOSAIC_RED",
  "MOSAIC_BLUE",
}

-- floors that should act like carpet with this mod
GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS = 
{
  "CARPET",
  "CARPET2",
  "SCALE",
}





