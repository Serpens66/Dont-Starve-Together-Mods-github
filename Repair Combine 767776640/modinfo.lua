name = "Repair Combine"
description = "With this mod you can repair your equipment with the same equipment.\n\nSo you can combine a logsuit with 10% and a logsuit with 30% to a logsuit with 40%!"
author = "Serpens66"
version = "1.091"
forumthread = ""
api_version = 10
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"
all_clients_require_mod = true
client_only_mod = false
server_filter_tags = {"combinate","repair","combine","repaircombine"}


configuration_options =
{
    {
        name = "bonus",
        label = "Bonus Durability",
		hover = "Getting some extra durability when combining things?",
        options = {
            {description = "-5%", data = -5, hover="negative Bonus"},
            {description = "-4%", data = -4, hover="negative Bonus"},
            {description = "-3%", data = -3, hover="negative Bonus"},
            {description = "-2%", data = -2, hover="negative Bonus"},
            {description = "-1%", data = -1, hover="negative Bonus"},
            {description = "-5-0%", data = -0.05, hover="Randomly between -5 and 0%"},
            {description = "-5-5%", data = -0.55, hover="Randomly between -5 and +5%"},
            {description = "-5-10%", data = -0.15, hover="Randomly between -5 and +10%"},
            {description = "+0%", data = 0, hover="Default"},
            {description = "+0-5%", data = 0.05, hover="Randomly between 0 and 5%"},
            {description = "+0-10%", data = 0.1, hover="Randomly between 0 and 10%"},
            {description = "+1%", data = 1, hover="\n"},
            {description = "+2%", data = 2, hover="\n"},
            {description = "+3%", data = 3, hover="\n"},
            {description = "+4%", data = 4, hover="\n"},
            {description = "+5%", data = 5, hover="\n"},
            {description = "+6%", data = 6, hover="\n"},
            {description = "+7%", data = 7, hover="\n"},
            {description = "+8%", data = 8, hover="\n"},
            {description = "+9%", data = 9, hover="\n"},
            {description = "+10%", data = 10, hover="\n"},
        },
        default = 0, 
    },
    {
        name = "repairfiniteuses",
        label = "Finiteuses",
		hover = "Allows to combine-repair items with finiteuses component (like most weapons/tools)",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = true, 
    },
    {
        name = "repairarmor",
        label = "Armor",
		hover = "Allows to combine-repair items with armor component (all armors)",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = true, 
    },
    {
        name = "repairfueled",
        label = "Fueled",
		hover = "Allows to combine-repair items with fueled component (eg. lantern, torch)",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = true, 
    },
    {
        name = "repairperishable",
        label = "Perishable",
		hover = "Allows to combine-repair equippable items with perishable component (eg. hambat, icecubehat)",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = true, 
    },
    {
        name = "null",
        label = "##### Combine Max #####",
        hover = "Enable the following options, to also combine the max value of an item. Two spears with a max use of 150 each, will result in a spear with max use of 300.",
        options =	{
						{description = "", data = 1, hover = ""},
					},
        default = 1,
	},
    {
        name = "overmaxfiniteuses",
        label = "Max Finiteuses",
		hover = "Also combine max uses (max percentage will stay 100%)",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = false, 
    },
    {
        name = "overmaxarmor",
        label = "Max Armor",
		hover = "Also combine max armor (max percentage will stay 100%)",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = false, 
    },
    {
        name = "overmaxfueled",
        label = "Max Fueled",
		hover = "Also combine max fuel (max percentage will stay 100%). This also means your combined lantern can hold more fuel than a default lantern!",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = false, 
    },
    {
        name = "overmaxperishable",
        label = "Max Perishable",
		hover = "Also combine max perishable-time (max percentage will stay 100%) Beware, this also means the stale status can get worse! So it may be better to only combine very fresh items.",
        options = {
            {description = "Off", data = false},
            {description = "On", data = true},
        },
        default = false, 
    },
    {
        name = "maxweapon",
        label = "Max Weapons(NoClient!)",
		hover = "(dont use this, better use settings above!) Does not work for clients, so only use if you are playing alone and without caves! Combinating weapons can lead to max uses of:",   -- does not work for clients
        options = {
            {description = "100%", data = 1},
            {description = "200%", data = 2},
            {description = "300%", data = 3},
            {description = "400%", data = 4},
            {description = "500%", data = 5},
            {description = "600%", data = 6},
            {description = "700%", data = 7},
            {description = "800%", data = 8},
            {description = "900%", data = 9},
            {description = "1000%", data = 10},
        },
        default = 1, 
    },
}