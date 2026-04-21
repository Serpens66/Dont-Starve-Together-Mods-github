-- This information tells other players more about the mod
name = "Skins"
description = "Several skins for Skins Project API, so this API mod is required! You can change skins ingame. After loading the game you have to change it again."
author = "Serpens66 and other"
version = "1.0.1" -- This is the version of the template. Change it to your own number.

forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true

-- Not compatible with Don't Starve
dont_starve_compatible = false
reign_of_giants_compatible = false

-- Character mods need this set to true
all_clients_require_mod = true 

icon_atlas = "modicon.xml"
icon = "modicon.tex"

priority = -2

-- The mod's tags displayed on the server list
server_filter_tags = {
"character",
}

--configuration_options = {}