require("constants")

-- klappt aus inem grund so nicht, deswegen alles in einzelne dateien packen und dann in modworldgenmain mit Layouts laden.

local StaticLayout = require("map/static_layout")
local ExampleLayout = 
	{
		-- ["PigGuardsWithChest4"] = 
						-- {
							-- StaticLayout.Get("map/static_layouts/pigguards_easy",
                                -- {
                                -- start_mask = PLACE_MASK.NORMAL,
                                -- fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
                                -- layout_position = LAYOUT_POSITION.CENTER,
                                -- defs = -- Define a choice list for substitution below
                                    -- {
                                        -- chests = { "treasurechest" },
                                    -- },
                                -- layout = -- Lay the objects in whatever pattern
                                    -- {
                                        -- chests = {
                                                         -- {x=0,y=0},
                                                        -- },
                                    -- },
                                -- properties = 
                                    -- { 
                                        -- chests = {{"chest_totalrandom"},{"chest_totalrandom"},{"chest_totalrandom"},{"chest_totalrandom"},}
                                    -- }
                                -- })
						-- },
        -- ["PigGuardsWithChest7"] = 
						-- {
							-- StaticLayout.Get("map/static_layouts/pigguards_b",
                                -- {
                                -- start_mask = PLACE_MASK.NORMAL,
                                -- fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
                                -- layout_position = LAYOUT_POSITION.CENTER,
                                -- defs = -- Define a choice list for substitution below
                                    -- {
                                        -- chests = { "treasurechest" },
                                    -- },
                                -- layout = -- Lay the objects in whatever pattern
                                    -- {
                                        -- chests = {
                                                         -- {x=-10,y=-10}, {x=10,y=-10},
                                                         -- {x=-10, y=10}, {x=10, y=10},
                                                        -- },
                                    -- },
                                -- properties = 
                                    -- { 
                                        -- chests = {{"chest_totalrandom"},{"chest_totalrandom"},{"chest_totalrandom"},{"chest_totalrandom"},}
                                    -- }
                                -- })
						-- },
        -- ["PigGuardsWithChest12"] = 
						-- {
							-- StaticLayout.Get("map/static_layouts/pigguards",
                                -- {
                                -- start_mask = PLACE_MASK.NORMAL,
                                -- fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
                                -- layout_position = LAYOUT_POSITION.CENTER,
                                -- defs = -- Define a choice list for substitution below
                                    -- {
                                        -- chests = { "treasurechest" },
                                    -- },
                                -- layout = -- Lay the objects in whatever pattern
                                    -- {
                                        -- chests = {

                                                         -- {x=-10,y=-10}, {x=0,y=-10}, {x=10,y=-10},
                                                         
                                                         -- {x=-10, y=10}, {x=0,y=10}, {x=10, y=10},
                                                        -- },
                                    -- },
                                -- properties = 
                                    -- { 
                                        -- chests = {{"chest_totalrandom"},{"chest_totalrandom"},{"chest_totalrandom"},{"chest_totalrandom"},}
                                    -- }
                                -- })
						-- },
        ["Farmplot2"] = 
						{
							type = LAYOUT.STATIC, -- Choose layout type
							args = nil, -- Add any arguments for the layout function
							defs = -- Define a choice list for substitution below
								{
								 	unknown_plant = { "berrybush_juicy" },
								},
							layout = -- Lay the objects in whatever pattern
								{
									unknown_plant = {
													 {x=-1,y=-1}, {x=1,y=-1},
													 {x=-1, y=1}, {x=1, y=1}
													},
								},
							count = nil, -- Either choose to specify the objects positions or a number of objects
							scale = 0.3 -- Choose a scale on which to place everything
						},
        -- ["PigGuardsEasy2"] = StaticLayout.Get("map/static_layouts/pigguards_easy", {
							-- start_mask = PLACE_MASK.NORMAL,
							-- fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							-- layout_position = LAYOUT_POSITION.CENTER
						-- }),
		-- ["TreeFarm"] = 
						-- {
							-- type = LAYOUT.GRID,
							-- count = 
								-- {
									-- evergreen_short = 16,
								-- },
							-- scale = 0.9
						-- },
		-- ["MushroomRingSmall"] = 
						-- {
							-- type = LAYOUT.CIRCLE_EDGE,
							-- defs = 
								-- {
								 	-- unknown_plant = { "red_mushroom", "green_mushroom", "blue_mushroom"},
								-- },
							-- count = 
								-- {
									-- unknown_plant = 7,
								-- },
							-- scale = 1
						-- },
		-- ["SimpleBase"] = StaticLayout.Get("map/static_layouts/simple_base", {
							-- areas = {
								-- construction_area = function() return PickSome(2, { "birdcage", "cookpot", "firepit", "homesign", "beebox", "meatrack", "icebox", "tent" }) end, --PickSome jedes maximal einmal nehmen
							-- },
						-- }),
		-- ["ResurrectionStone"] = StaticLayout.Get("map/static_layouts/resurrectionstone"),
        -- ["MacTuskCity"] = StaticLayout.Get("map/static_layouts/mactusk_city", {
							-- start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							-- fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							-- layout_position = LAYOUT_POSITION.CENTER
						-- }),
        -- ["ChessSpot1"] = StaticLayout.Get("map/static_layouts/chess_spot", {
								-- defs={
									-- evil_thing={"marblepillar","flower_evil","marbletree"},
								-- },
							-- }),
        -- ["MaxwellHome"] = StaticLayout.Get("map/static_layouts/maxwellhome", {
							-- areas = 
							-- {								
								-- barren_area = function(area) return PickSomeWithDups( 0.5 * area  --  PickSomeWithDups, mehrfachdassele wählen ist moeglich, returned eine Liste
									-- , {"marsh_tree", "marsh_bush", "rock1", "rock2", "evergreen_burnt", "evergreen_stump"}) end,
								-- gold_area = function() return PickSomeWithDups(math.random(15,20), {"goldnugget"}) end,
								-- livinglog_area = function() return PickSomeWithDups(math.random(5, 10), {"livinglog"}) end,
								-- nightmarefuel_area = function() return PickSomeWithDups(math.random(5, 10), {"nightmarefuel"}) end,
								-- deadlyfeast_area = function() return PickSomeWithDups(math.random(25,30), {"monstermeat", "green_cap", "red_cap", "spoiled_food", "meat"}) end,
								-- marblegarden_area = function(area) return PickSomeWithDups(1.5*area, {"marbletree", "flower_evil"}) end,
							-- },
							-- start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							-- fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							-- layout_position = LAYOUT_POSITION.CENTER,
							-- disable_transform = true
						-- }),
}

-- return {Layouts = ExampleLayout}