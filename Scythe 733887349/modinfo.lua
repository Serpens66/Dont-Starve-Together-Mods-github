name = "Scythe"
description = "A Scythe to quickpick grass/twigs/berries (Serp: uses fastpicker Tag instead of overwriting functions -> less bugs)"
author = "Serpens66"
version = "1.0.3"

forumthread = ""

api_version = 10
priority = 0

--This lets the clients know that they need to download the mod before they can join a server that is using it.
all_clients_require_mod = true

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true


icon_atlas = "scythe.xml"
icon = "scythe.tex"

configuration_options = {
	{
		name = "recipe_f",
		label = "Recipe (Flint Scythe)",
		hover = "How hard is it to make the Flint Scythe",
		options = {	
			{description = "Captain_M", data = "0", hover = "2 twigs, 1 rope, 2 flints"},
			{description = "Petyr", data = "1", hover = "2 twigs, 2 flints"},
		},
		default = "1"
	},
	{
		name = "science_f",
		label = "Science required (Flint Scythe)",
		hover = "What kind of science is required to build the Flint Scythe",
		options = {	
			{description = "No science", data = 0, hover = "What is science?"},
			{description = "Science machine", data = 1, hover = "Oh, I know some things"},
			{description = "Alchemy engine", data = 2, hover = "Whats next?"},
		},
		default = 0
	},
	{
		name = "durabililty_f",
		label = "Durability (Flint Scythe)",
		hover = "Number of uses of the Flint Scythe",
		options = {	
			{description = "50 uses", data = 50, hover = "Useless"},
			{description = "100 uses", data = 100, hover = "Use a few times"},
			{description = "200 uses", data = 200, hover = "Thats more like it"},
            {description = "300 uses", data = 300, hover = "Thats more like it"},
            {description = "400 uses", data = 400, hover = "Thats more like it"},
            {description = "500 uses", data = 500, hover = "Thats more like it"},
			{description = "999999 uses", data = 999999, hover = "Does it even break?"},
		},
		default = 100
	},
	{
		name = "recipe_g",
		label = "Recipe (Golden Scythe)",
		hover = "How hard is it to make the Golden Scythe",
		options = {	
			{description = "Captain_M", data = "0", hover = "4 twigs, 2 ropes, 2 golden nuggets"},
			{description = "Parusoid", data = "1", hover = "1 razor, 2 houndstooth, 4 golden nuggets"},
		},
		default = "0"
	},
	{
		name = "science_g",
		label = "Science required (Golden Scythe)",
		hover = "What kind of science is required to build the Golden Scythe",
		options = {	
			{description = "No science", data = 0, hover = "What is science?"},
			{description = "Science machine", data = 1, hover = "Oh, I know some things"},
			{description = "Alchemy engine", data = 2, hover = "Whats next?"},
		},
		default = 2
	},
	{
		name = "durabililty_g",
		label = "Durability (Golden Scythe)",
		hover = "Number of uses of the Golden Scythe",
		options = {	
			{description = "50 uses", data = 50, hover = "Useless"},
			{description = "100 uses", data = 100, hover = "Use a few times"},
			{description = "200 uses", data = 200, hover = "Thats more like it"},
            {description = "300 uses", data = 300, hover = "Thats more like it"},
            {description = "400 uses", data = 400, hover = "Thats more like it"},
            {description = "500 uses", data = 500, hover = "Thats more like it"},
			{description = "999999 uses", data = 999999, hover = "Does it even break?"},
		},
		default = 300
	}
}