return {
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
        }
