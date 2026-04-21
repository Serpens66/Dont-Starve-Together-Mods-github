-- This information tells other players more about the mod
name = "Random Day/Dusk/Night Events"
description = "Changes day/dusk/night depending on the moonphase randomly.\nBy default on every half-moon there is a chance of 30% to trigger onlyday/onlydusk/onlynight as long as the half-moon lasts (usually 3 days).\nAnd on new-moon there is a 10% chance to trigger Lunacy as long as new-moon lasts (usually 1 day).\n\nConfigurable.\nIf you change modsettings during the moonphase it will only affect the next phase."
author = "Serpens66, Ambassador, surg" -- idea from this mod: https://steamcommunity.com/sharedfiles/filedetails/?id=2061875300
version = "1.02"

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

priority = 0

-- mod_dependencies = 
-- {
    -- {
        -- workshop = "workshop-756229217",
    -- }
-- }

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

--This lets the clients know that they need to download the mod before they can join a server that is using it.
all_clients_require_mod = false

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
server_filter_tags = {"Random Day/Dusk/Night Events"}

--Adds an icon to the mod
icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options = {
	{
		name = "wantedmoonphase",
		label = "Moonphase",
		hover = "The moonphase in which the day/dusk/night may change (set chances below)",
		options = 
		{
            {description = "Full", data = "full", hover="Be aware that some game events do set the moon to full, eg. moonstorm"},
            {description = "Threequarter", data = "threequarter", hover=""},
            {description = "Half", data = "half", hover="Default"},
            {description = "Quarter", data = "quarter", hover=""},
            {description = "New", data = "new", hover=""},

        },                   
		default = "half",
    },
    {
		name = "alldaychance",
		label = "AllDay Chance",
		hover = "Chance to get Always-Day during chosen moonphase",
		options = 
		{
            {description = "0%", data = 0},
            {description = "5%", data = 5},
            {description = "10%", data = 10, hover="Default"},
            {description = "15%", data = 15},
            {description = "20%", data = 20},
            {description = "25%", data = 25},
            {description = "30%", data = 30},
            {description = "35%", data = 35},
            {description = "40%", data = 40},
            {description = "45%", data = 45},
            {description = "50%", data = 50},
            {description = "55%", data = 55},
            {description = "60%", data = 60},
            {description = "65%", data = 65},
            {description = "70%", data = 70},
            {description = "75%", data = 75},
            {description = "80%", data = 80},
            {description = "85%", data = 85},
            {description = "90%", data = 90},
            {description = "95%", data = 95},
            {description = "100%", data = 100},
        },                   
		default = 10,
    },
    {
		name = "allduskchance",
		label = "AllDusk Chance",
		hover = "Chance to get Always-Dusk during chosen moonphase",
		options = 
		{
            {description = "0%", data = 0},
            {description = "5%", data = 5},
            {description = "10%", data = 10, hover="Default"},
            {description = "15%", data = 15},
            {description = "20%", data = 20},
            {description = "25%", data = 25},
            {description = "30%", data = 30},
            {description = "35%", data = 35},
            {description = "40%", data = 40},
            {description = "45%", data = 45},
            {description = "50%", data = 50},
            {description = "55%", data = 55},
            {description = "60%", data = 60},
            {description = "65%", data = 65},
            {description = "70%", data = 70},
            {description = "75%", data = 75},
            {description = "80%", data = 80},
            {description = "85%", data = 85},
            {description = "90%", data = 90},
            {description = "95%", data = 95},
            {description = "100%", data = 100},
        },                   
		default = 10,
    },
    {
		name = "allnightchance",
		label = "AllNight Chance",
		hover = "Chance to get Always-Night during chosen moonphase",
		options = 
		{
            {description = "0%", data = 0},
            {description = "5%", data = 5},
            {description = "10%", data = 10, hover="Default"},
            {description = "15%", data = 15},
            {description = "20%", data = 20},
            {description = "25%", data = 25},
            {description = "30%", data = 30},
            {description = "35%", data = 35},
            {description = "40%", data = 40},
            {description = "45%", data = 45},
            {description = "50%", data = 50},
            {description = "55%", data = 55},
            {description = "60%", data = 60},
            {description = "65%", data = 65},
            {description = "70%", data = 70},
            {description = "75%", data = 75},
            {description = "80%", data = 80},
            {description = "85%", data = 85},
            {description = "90%", data = 90},
            {description = "95%", data = 95},
            {description = "100%", data = 100},
        },                   
		default = 10,
    },
    {
		name = "nothingchance",
		label = "Nothing Chance",
		hover = "Chance that nothing special happens during chosen moonphase",
		options = 
		{
            {description = "0%", data = 0},
            {description = "5%", data = 5},
            {description = "10%", data = 10},
            {description = "15%", data = 15},
            {description = "20%", data = 20},
            {description = "25%", data = 25},
            {description = "30%", data = 30},
            {description = "35%", data = 35},
            {description = "40%", data = 40},
            {description = "45%", data = 45},
            {description = "50%", data = 50},
            {description = "55%", data = 55},
            {description = "60%", data = 60},
            {description = "65%", data = 65},
            {description = "70%", data = 70, hover="Default"},
            {description = "75%", data = 75},
            {description = "80%", data = 80},
            {description = "85%", data = 85},
            {description = "90%", data = 90},
            {description = "95%", data = 95},
            {description = "100%", data = 100},
        },                   
		default = 70,
    },
    {
		name = "wantedmoonphase_lunar",
		label = "Moonphase Lunar",
		hover = "The moonphase in which sanity may be replaced by lunar (set chances below)",
		options = 
		{
            {description = "Full", data = "full", hover="Be aware that some game events do set the moon to full, eg. moonstorm"},
            {description = "Threequarter", data = "threequarter", hover=""},
            {description = "Half", data = "half", hover=""},
            {description = "Quarter", data = "quarter", hover=""},
            {description = "New", data = "new", hover="Default"},

        },                   
		default = "new",
    },
    {
		name = "lunarchance",
		label = "Lunar Chance",
		hover = "Chance that sanity is replaced by lunar as long it is -Moonphase Lunar-",
		options = 
		{
            {description = "0%", data = 0},
            {description = "5%", data = 5},
            {description = "10%", data = 10},
            {description = "15%", data = 15, hover="Default"},
            {description = "20%", data = 20},
            {description = "25%", data = 25},
            {description = "30%", data = 30},
            {description = "35%", data = 35},
            {description = "40%", data = 40},
            {description = "45%", data = 45},
            {description = "50%", data = 50},
            {description = "55%", data = 55},
            {description = "60%", data = 60},
            {description = "65%", data = 65},
            {description = "70%", data = 70},
            {description = "75%", data = 75},
            {description = "80%", data = 80},
            {description = "85%", data = 85},
            {description = "90%", data = 90},
            {description = "95%", data = 95},
            {description = "100%", data = 100},
        },                   
		default = 15,
    },
}