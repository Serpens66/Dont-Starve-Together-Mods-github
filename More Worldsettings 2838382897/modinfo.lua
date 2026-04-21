-- This information tells other players more about the mod
name = "More Worldsettings"
description = "Adds more worldsettings. Enable this mod first and then go to the Worldsettings section screen and scroll to bottom.\n\nAdds:\n-Regrowing Time\n-Farm Grow Time\n\nI may add more settings in the future"
author = "Serpens66"
version = "1.029"


priority = 9000 -- load order compared to other mods. Make it higher than 8888 which is the priority of Teleportato mod, so worldsettings load before teleportato so it is able to change the new settings

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

--This lets the clients know that they need to download the mod before they can join a server that is using it.
all_clients_require_mod = false -- not 100% sure if clients need it... tested multiplayer and it seems client work fine

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
server_filter_tags = {"More Worldsettings","Regrowing Time"}

--Adds an icon to the mod
icon_atlas = "preview.xml"
icon = "preview.tex"

configuration_options = {}