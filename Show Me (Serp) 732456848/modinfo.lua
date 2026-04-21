-- information about the mod
version = "0.3534"
-- version_compatible = "0.151"
name = "Show Me"
author = "Star,Serp"
forumthread = ""
description = "Shows Tooltips when hovering over things." --GAMELANGUAGE=="RU"
	--and "Рассказывает о предметах и существах после действия \"Осмотреть\"."
	--or "Shows various info about creatures and items on \"inspect\" action."

-- custom icon
icon_atlas = "preview.xml"
icon = "preview.tex"

dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod=true
client_only_mod=false
--server_only_mod=true

api_version = 10
priority = 0.00666155465 --Priority does not matter.
--russian_icon = true

server_filter_tags = {"show"}

local keyslist = {}

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

local Fkey = {"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"}
local KEY_F1 = 282
for i = 1, #Fkey do keyslist[#alpha + i] = {description = Fkey[i],data = i + KEY_F1 - 1} end

keyslist[#alpha + #Fkey + 1] = {description = "[",data = 91}
keyslist[#alpha + #Fkey + 2] = {description = "]",data = 93}

configuration_options =
{
    --[[{
        name = "message_style",
        label = "Style",
        options = 
        {
            {description = "Isolation ->", data = 1},
            {description = "isolation ->", data = 2},
            {description = "Isol ->", data = 3},
            {description = "isol ->", data = 4}, 
            {description = "<- Warm", data = 5}, 
            {description = "<- warm", data = 6}, 
        }, 
        default = 1,
    },--]]
	{
        name = "food_style",
        label = "Food Style",
        hover = "How should it be displayed?",
        options = 
        {
            {description = "long", data = 1, hover = "Hunger: +12.5 / Sanity: -10 / Health: +3"},
            {description = "short", data = 2, hover = "+12.5 / -10 / +3"},
        }, 
        default = 2,
    },
	{
        name = "food_order",
        label = "Food Properties Order",
        hover = "The Order?",
        options = 
        {
            {description = "interface", data = 1, hover = "Hunger / Sanity / Health"},
            {description = "wikia", data = 2, hover = "Health / Hunger / Sanity"},
        }, 
        default = 0,
    },
	{
        name = "food_estimation", -- estimation of food values is always on, this option is for text info when food will stale/spoil
        label = "Stale/Spoil of Food",
		hover = "Display estimated stale/spoil time?",
        options = 
        {
            {description = "No", data = 0, hover = "No"},
            {description = "Only Stale", data = 1, hover = "Stale"},
            {description = "Only Spoil", data = 2, hover = "Spoil"},
            {description = "Both", data = 3, hover = "Stale and Spoil"},
        }, 
        default = 0,
    },
    {
        name = "units_ingredients",
        label = "Display Units? Always",
		hover = "Display units for recipes/cooking?",
        options = 
        {
            {description = "No", data = 0, hover = "No"},
            {description = "Yes", data = 1, hover = "Yes"},
        }, 
        default = 0,
    },
    {
		label   = "Press to show recipe units",
        hover = "Shows the units only after pressing the key.",
		name    = "keybind",
		options = keyslist,
		default = 282, 
	},
    {
        name = "showuses_item",
        label = "Display Uses for items?",
		hover = "Displays how often an Item can be used, before it breaks.",
        options = 
        {
            {description = "No", data = 0, hover = "No"},
            {description = "Yes", data = 1, hover = "Yes"},
        }, 
        default = 0,
    },
    {
        name = "showuses_other",
        label = "Display Uses other, eg tents?",
		hover = "Displays how often a Thing (not item) can be used, before it breaks.",
        options = 
        {
            {description = "No", data = 0, hover = "No"},
            {description = "Yes", data = 1, hover = "Yes"},
        }, 
        default = 1,
    },
    {
        name = "show_worldstatus",
        label = "World Status",
		hover = "Shows how long the actual season will be\n and the world temperature when hovering over some trees",
        options = 
        {
            {description = "No", data = 0, hover = "No"},
            {description = "Yes", data = 1, hover = "Yes"},
        }, 
        default = 0,
    },
    {
        name = "show_creature_speed",
        label = "Creature Speed",
		hover = "Shows the speed of creatures. Your unchanged speed should be 4.",
        options = 
        {
            {description = "No", data = 0, hover = "No"},
            {description = "Yes", data = 1, hover = "Yes"},
        }, 
        default = 1,
    },
    {
        name = "show_foodstats_multiplier",
        label = "Food Multis",
		hover = "Shows character specific multiplied food stats? Eg. for wortox, warly, webber and more.",
        options = 
        {
            {description = "No", data = 0, hover = "No, always show the values valid for a default character"},
            {description = "Yes", data = 1, hover = "Yes"},
        }, 
        default = 1,
    },
}




