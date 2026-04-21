require("constants")
local StaticLayout = require("map/static_layout")

return  StaticLayout.Get("map/static_layouts/pigguards_easy2",
      {
      start_mask = PLACE_MASK.NORMAL,
      -- fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
      fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN,
      layout_position = LAYOUT_POSITION.CENTER,
      defs = -- Define a choice list for substitution below
          {
              chest = { "treasurechest" }, -- pandoraschests do listen to runs now and are undestructable...
          },
      })

