-- ########################################################
-- ######################## STRINGS  ######################

-- strings for the options themself are done in modworldgenmain.lua (STRINGS), but I think there is no need to translate them, as they already use the GLOBAL.STRINGS.NAMES 

local STRINGS = GLOBAL.STRINGS
if STRINGS.UI==nil then
    STRINGS.UI = {}
end
if STRINGS.UI.CUSTOMIZATIONSCREEN==nil then
    STRINGS.UI.CUSTOMIZATIONSCREEN = {}
end
if STRINGS.UI.SANDBOXMENU==nil then
    STRINGS.UI.SANDBOXMENU = {}
end
if STRINGS.NAMES==nil then
    STRINGS.NAMES = {}
end
STRINGS.UI.SANDBOXMENU.CHOICE_MOD_REGROW = "Mod Multiply Regrowing Time (again pickable after harvest)"
STRINGS.UI.SANDBOXMENU.CHOICE_MOD_REGROW_FARM = "Mod Multiply Farmplant Growing Time"