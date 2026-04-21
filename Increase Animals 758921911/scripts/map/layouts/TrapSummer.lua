require("constants")
local StaticLayout = require("map/static_layout")

return  StaticLayout.Get("map/static_layouts/trap_summer",
      {
      start_mask = PLACE_MASK.NORMAL,
      fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN,
      layout_position = LAYOUT_POSITION.CENTER,
      })

