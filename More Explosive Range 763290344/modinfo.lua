name = "More Explosive Range"
description = "Increase Range of Explosives like Gunpowder and Slurtleslime. You can also increase damage, but by default it is not increased." 
author = "Serpens"
forumthread = ""

version = "1.03"
api_version = 10

dst_compatible = true

client_only_mod = false
all_clients_require_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
    {
        name = "gunpowderrange",
        label = "Gunpowder Range",
		hover = "Additional Range of Gunpowder (gamedefault is a range of 3)",
        options = {
            {description = "+1", data = 1},
            {description = "+2", data = 2},
            {description = "+3", data = 3},
            {description = "+4", data = 4},
            {description = "+5", data = 5},
            {description = "+6", data = 6},
        },
        default = 3, 
    },
{
        name = "slurtleslimerange",
        label = "Slurtleslime Range",
		hover = "Additional Range of Slurtleslime (gamedefault is a range of 3)",
        options = {
            {description = "+1", data = 1},
            {description = "+2", data = 2},
            {description = "+3", data = 3},
            {description = "+4", data = 4},
            {description = "+5", data = 5},
            {description = "+6", data = 6},
        },
        default = 3, 
    },
    {
        name = "gunpowderdamage",
        label = "Gunpowder Damage",
		hover = "Additional Damage of Gunpowder (gamedefault is 200)",
        options = {
            {description = "+0", data = 0},
            {description = "+10", data = 10},
            {description = "+25", data = 25},
            {description = "+50", data = 50},
            {description = "+75", data = 75},
            {description = "+100", data = 100},
            {description = "+125", data = 125},
            {description = "+150", data = 150},
            {description = "+175", data = 175},
            {description = "+200", data = 200},
        },
        default = 0, 
    },
{
        name = "slurtleslimedamage",
        label = "Slurtleslime Damage",
		hover = "Additional Damage of Slurtleslime (gamedefault is 50)",
        options = {
            {description = "+0", data = 0},
            {description = "+10", data = 10},
            {description = "+25", data = 25},
            {description = "+50", data = 50},
            {description = "+75", data = 75},
            {description = "+100", data = 100},
            {description = "+125", data = 125},
            {description = "+150", data = 150},
            {description = "+175", data = 175},
            {description = "+200", data = 200},
        },
        default = 0, 
    }, 
}