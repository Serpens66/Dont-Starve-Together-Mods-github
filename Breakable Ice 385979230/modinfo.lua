name = "Breakable Ice"
description = "Allows players to break ice on ponds during winter.\n\nIce can be destroyed or melted by the following methods:\nPickaxe will slowly reduce ice when worked.\nFire will slowly melt ice when lit.\nGunpowder will reduce ice by a massive amount."
author = "Ysovuka & Serpens66"
version = "1.0.01"

forumthread = ""

api_version = 10

dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true

all_clients_require_mod = false
client_only_mod = false

server_filter_tags = {"break ice", "breakable ice", "ice", "break", "breakable"}

icon_atlas = "preview.xml"
icon = "preview.tex"

configuration_options = 
{
	{
		name = "pond.formation.delay.hours",
		label = "Pond Formation Delay",
		hover = "This is the amount of delay it takes for ice crystals to form in our pond.",
		options = 
		{
			{description = "0 Hours", data = 0.00},
			{description = "1 Hour", data = 0.25},
			{description = "2 Hours", data = 0.50},
			{description = "3 Hours", data = 0.75},
			{description = "4 Hours", data = 1.00},
			{description = "5 Hours", data = 1.25},
			{description = "6 Hours", data = 1.50},
			{description = "7 Hours", data = 1.75},
			{description = "8 Hours", data = 2.00},
			{description = "9 Hours", data = 2.25},
			{description = "10 Hours", data = 2.50},
			{description = "11 Hours", data = 2.75},
			{description = "12 Hours", data = 3.00},
			{description = "13 Hours", data = 3.25},
			{description = "14 Hours", data = 3.50},
			{description = "15 Hours", data = 3.75},
			{description = "16 Hours", data = 4.00},
			{description = "17 Hours", data = 4.25},
			{description = "18 Hours", data = 4.50},
			{description = "19 Hours", data = 4.75},
			{description = "20 Hours", data = 5.00},
			{description = "21 Hours", data = 5.25},
			{description = "22 Hours", data = 5.50},
			{description = "23 Hours", data = 5.75},
			{description = "24 Hours", data = 6.00},
		},
		default = 1.00,
	},

	{
		name = "swamp.formation.delay.hours",
		label = "Swamp Formation Delay",
		hover = "This is the amount of delay it takes for ice crystals to form in our swamp pond.",
		options = 
		{
			{description = "0 Hours", data = 0.00},
			{description = "1 Hour", data = 0.25},
			{description = "2 Hours", data = 0.50},
			{description = "3 Hours", data = 0.75},
			{description = "4 Hours", data = 1.00},
			{description = "5 Hours", data = 1.25},
			{description = "6 Hours", data = 1.50},
			{description = "7 Hours", data = 1.75},
			{description = "8 Hours", data = 2.00},
			{description = "9 Hours", data = 2.25},
			{description = "10 Hours", data = 2.50},
			{description = "11 Hours", data = 2.75},
			{description = "12 Hours", data = 3.00},
			{description = "13 Hours", data = 3.25},
			{description = "14 Hours", data = 3.50},
			{description = "15 Hours", data = 3.75},
			{description = "16 Hours", data = 4.00},
			{description = "17 Hours", data = 4.25},
			{description = "18 Hours", data = 4.50},
			{description = "19 Hours", data = 4.75},
			{description = "20 Hours", data = 5.00},
			{description = "21 Hours", data = 5.25},
			{description = "22 Hours", data = 5.50},
			{description = "23 Hours", data = 5.75},
			{description = "24 Hours", data = 6.00},
		},
		default = 1.00,
	},
    {
		name = "max_thickness",
		label = "Max Thickness",
		hover = "How thick should the ice can get? The higher, the longer it takes to remove ice\n(changes will work in a new game)",
		options = 
		{
			{description = "10", data = 10},
            {description = "20", data = 20},
            {description = "25", data = 25},
            {description = "30", data = 30},
            {description = "40", data = 40},
            {description = "50", data = 50},
            {description = "60", data = 60},
            {description = "70", data = 70},
            {description = "80", data = 80},
            {description = "90", data = 90},
            {description = "100", data = 100},
            {description = "110", data = 110},
            {description = "120", data = 120},
            {description = "130", data = 130},
            {description = "140", data = 140},
            {description = "150", data = 150},
            {description = "200", data = 200},
		},
		default = 25,
	},
}