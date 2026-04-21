-- After game updates/adding mods one should check logfile for:
-- "More Worldsetings mod:" ... "is pickable but no fitting TUNING values"
-- "WARNING! Could not find region 'bullkelp.tex' from atlas 'images/customisation.xml'. Is the region specified in the atlas?"
-- "More Worldsetings mod: No Image found for"
-- if these happen you might want to add to PrefabTuningTansl or TuningImageTansl to solve the issue.
-- 

-- INFO:
-- most growable-like changes only take effect for the next stage when loading a game with changed settings.
-- eg if you set it to never and later change it back to default, the current stage will stay "never" (*1000)
-- this problem is solved for pickables in worldsettingsutil.lua, see lightflier_flower example or my code in modmain.lua
-- I maybe could write code similar to this for growable, but I think the game devs will add this soon anyway, so lets wait.




-- ideas:
-- evlt zu vorhandenen worldsettings mehr optionen zufügen
-- bzw. auch die alten ersetzen und mit meinem *2 *3 usw system ersetzen
-- zb _RESPAWN_TIME

if (GLOBAL.rawget(GLOBAL, "TheFrontEnd")==nil and GLOBAL.rawget(GLOBAL, "IsInFrontEnd")==nil) then return end -- AdLevelPreInitAny and stuff like that would be called this way, but we dont want this execution, because it would crash the mod.

local _G = GLOBAL
local STRINGS = _G.STRINGS
local Wset = _G.LEVELCATEGORY.SETTINGS -- just shortnaming
local Wgen = _G.LEVELCATEGORY.WORLDGEN

local WSO = require("worldsettings_overrides")
local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
local helpers = _G.require("moresettings_helpers") 
_G.MORESET_MOD = {}
modimport("scripts/define_globals") -- fills _G.MORESET_MOD, with eg. atlas_to_search , tuning_names, TuningImageTansl ...
modimport("scripts/strings") -- adds STRINGS


-- ########################################################
-- ########################################################
---------------------------------------------
-- ## Add more options to existing game settings. 
-- this is an example to add 3 and 5 days to all season lengths. Requires upvaluehacker (google for it if you dont have it)
--[[
local UpvalueHacker = GLOBAL.require("upvaluehacker")
local customize = GLOBAL.require("map/customize")
local RefreshWorldTabs = UpvalueHacker.GetUpvalue(customize.RemoveCustomizeGroup, "RefreshWorldTabs")
local customize_descriptions = UpvalueHacker.GetUpvalue(customize.GetDescription, "descriptions")
local new_seasonlengths = {{ text = "3 days", data = "3__daysseason", pos=1 },{ text = "5 days", data = "5__daysseason", pos=2 }}
for _,length in ipairs(new_seasonlengths) do
    table.insert(customize_descriptions.season_length_descriptions,length.pos,length)
end
UpvalueHacker.SetUpvalue(customize.GetDescription, customize_descriptions, "descriptions")
RefreshWorldTabs() -- refresh to display new settings
local seasons = {"autumn","summer","spring","winter"}
for i,season in ipairs(seasons) do
    local old_fn = WSO.Post[season]
    WSO.Post[season] = function(difficulty,...)
        if string.find(difficulty,"__") then
            local diff_split = difficulty:split("__") -- this way we get the desired length number from aboves data string
            GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season = season, length = diff_split[1]})
        elseif old_fn~=nil then
            return old_fn(difficulty,...)
        end
    end
end
--]]
-------------------------------
-- adding new worldsettings (instead of changing existing ones) is easier
-- ########################################################
-- ########################################################




-- multiply the games default value (or the value another mod gave it when he changed TUNING) with these values:
local speed_mults = {}
local mults = {"0.001","0.01","0.05","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1","1.25","1.5","1.75","2","2.5","3","3.5","4","4.5","5","10","1000"}
for _,mult in ipairs(mults) do
    speed_mults["MODMULTS_"..mult] = _G.tonumber(mult)
end -- 0.001 is "instant" and 1000 "never"

-- speed_mults["MODMULTS_"..tostring(1/1000)] = 1/1000 -- not 0, only close to it (also because teleportato mod can not handle this divide by zero)
-- speed_mults["MODMULTS_"..tostring(1/100)] = 1/100
-- speed_mults["MODMULTS_"..tostring(5/100)] = 5/100
-- for i=1,10 do
    -- speed_mults["MODMULTS_"..tostring(i/10)] = i/10
-- end
-- for i=5,8 do
    -- speed_mults["MODMULTS_"..tostring(i/4)] = i/4
-- end
-- for i=5,10 do
    -- speed_mults["MODMULTS_"..tostring(i/2)] = i/2
-- end
-- speed_mults["MODMULTS_"..tostring(10)] = 10
-- speed_mults["MODMULTS_"..tostring(1000)] = 1000 --> never: will disable pickable and/or put the grwo time very high, so nearly never



local mod_growspeed_descriptions = {} -- can be accessed by other mods with customize.GetOptions and then the option items with have a "options" key. See teleportato mod for example
for speed,mult in helpers.orderedPairs_speed(speed_mults,helpers.speed_sort) do
    if mult==1 then -- default
        table.insert(mod_growspeed_descriptions, { text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "MODMULTS_"..tostring(mult) } )
    elseif mult==1000 then -- never
        table.insert(mod_growspeed_descriptions, { text = STRINGS.UI.SANDBOXMENU.BRANCHINGNEVER, data = "MODMULTS_"..tostring(mult) } )  -- SLIDENEVER is translated as "None", I think "Never" fits better so I use BRANCHINGNEVER string
    else
        table.insert(mod_growspeed_descriptions, { text = "*"..tostring(mult), data = "MODMULTS_"..tostring(mult) } )
    end
end



-- adding new option groups
-- put MODMULT in front of group name to mark all settings that use the speed_mults structure, so teleportato mod can automatically see them
AddCustomizeGroup(Wset, "MODMULT_REGROW", STRINGS.UI.SANDBOXMENU.CHOICE_MOD_REGROW, mod_growspeed_descriptions, "images/customisation.xml", 20)
AddCustomizeGroup(Wset, "MODMULT_REGROW_FARM", STRINGS.UI.SANDBOXMENU.CHOICE_MOD_REGROW_FARM, mod_growspeed_descriptions, "images/customisation.xml", 21)


-- loop through all TUNING values and find ones that fit our entries in MORESET_MOD.tuning_names and add them to tuning_names
local splitted = nil
local appendix_splitted = nil
for tuning_name,data in pairs(_G.TUNING) do -- fill tuning_names with TUNING matching the key of tuning_names above
    if not table.contains(_G.MORESET_MOD.AddNoSettingFor,tuning_name) then
        for appendix,data in pairs(_G.MORESET_MOD.tuning_names) do
            appendix_splitted = string.split(appendix,"_")
            if string.match(tuning_name,appendix) and not string.match(tuning_name,appendix.."_") then -- a list of all prefabs that have a TUNING.PREFAB_REGROW_TIME value we want to offer a setting for
                splitted = string.split(tuning_name,"_")
                _G.MORESET_MOD.tuning_names[appendix][string.lower( table.concat(splitted,"_",1,#splitted-#appendix_splitted) )] = {} -- we can add more information in this info table
            end
        end
    end
end

-- add options for entries in tuning_names (currently REGROW_TIME)
local default_value = nil
local altname = nil
local imagename,atlas = nil,nil
local mult = nil
for appendix,data in pairs(_G.MORESET_MOD.tuning_names) do
    for name,info in _G.orderedPairs(data) do
        
        imagename,atlas = helpers.GetFittingImage(name)
        AddCustomizeItem(Wset,"MODMULT_REGROW","MOD_"..string.upper(name)..appendix,{atlas = atlas,value = "MODMULTS_"..tostring(1), image = imagename..".tex", order=_, world={"forest", "cave"}}) -- set order 0, so my settings appear first (tried it with high number to appear last, but did not work for whatever reason)
        altname = _G.MORESET_MOD.TuningImageTansl[name] and string.upper(_G.MORESET_MOD.TuningImageTansl[name]["imagename"])
        STRINGS.UI.CUSTOMIZATIONSCREEN["MOD_"..string.upper(name)..appendix] = STRINGS.NAMES[string.upper(name)] or STRINGS.NAMES[altname] or _G.FirstToUpper(name)
        
        if appendix=="_REGROW_TIME" then -- add PICKABLE TUNING value (may also be added by devs soon)
            _G.TUNING[string.upper(name).."_PICKABLE"] = true
        end
        
        WSO.Pre["MOD_"..string.upper(name)..appendix] = function(difficulty) -- all TUNING changes are done in "Pre" (while Post is using PushEvent)
            if difficulty~="default" then -- then we dont change anything
                mult = _G.tonumber(string.split(difficulty,"_")[2])
                default_value = nil
                if _G.ORIGINAL_TUNING[string.upper(name)..appendix]~=nil then -- if it is on ORIGINAL_TUNING, use it, otherwise the TUNING value as default
                    default_value = _G.deepcopy(_G.ORIGINAL_TUNING[string.upper(name)..appendix])
                else
                    default_value = _G.deepcopy(_G.TUNING[string.upper(name)..appendix])
                end
                if default_value~=nil then 
                    if type(default_value)=="number" then
                        _G.TUNING[string.upper(name)..appendix] = default_value*mult
                        if mult==1000 then -- is meant to be "never"
                            _G.TUNING[string.upper(name).."_PICKABLE"] = false
                        end
                    elseif type(default_value)=="table" then
                        -- the typical _GROW_TIME table .. but we should do this manually instead, eg. to have a minimum time at least for the tall stage (we can not identify this automatically)
                        if default_value[1]~=nil and type(default_value[1])=="table" and default_value[1]["base"]~=nil and default_value[1]["random"]~=nil then -- the typical _GROW_TIME table .. but we should do this manually instead, eg. to have a minimum time at least for the tall stage (we can not identify this automatically)
                            for i,entry in ipairs(default_value) do
                                _G.TUNING[string.upper(name)..appendix][i].base = default_value[i]["base"]*mult -- important to change the table value directly instead of replacing the table, so it also affects the locals in eg. evergreens.lua
                                _G.TUNING[string.upper(name)..appendix][i].random = default_value[i]["random"]*mult
                            end
                            if string.upper(name)=="EVERGREEN" then
                                print("HIER evergreen neu base: "..tostring(_G.TUNING[string.upper(name)..appendix][1].base).." alt base: "..tostring(default_value[1]["base"]))
                            end
                        else
                            print("MORE WORLDSETTINGS MOD: TUNING."..string.upper(name)..appendix.." is a table, but not what I expected. Maybe add this to the code for this:")
                            _G.dumptable(default_value)
                        end
                    else
                        print("MORE WORLDSETTINGS MOD: TUNING."..string.upper(name)..appendix.." is no number and also no table, but: "..tostring(type(default_value))..". Maybe add this to the code")
                    end
                end
            end
        end
    end
end

-- add options for:
-- PLANT_DEFS and WEED_DEFS - farm plants (new system)
local appendix = "_REGROW_FARM"-- custom appendix to mark farm_plant_defs
local counter = 0 -- order of settings
local imagename,atlas = nil,nil
for _,plantdefs in ipairs({PLANT_DEFS,WEED_DEFS}) do
    for veggiename,data in _G.orderedPairs(plantdefs) do
        if data.prefab~=nil then
            counter = counter+1 -- order of settings
            
            imagename,atlas = helpers.GetFittingImage(veggiename)
            AddCustomizeItem(Wset,"MODMULT_REGROW_FARM","MOD_"..string.upper(veggiename)..appendix,{atlas = atlas,value = "MODMULTS_"..tostring(1), image = imagename..".tex", order=counter, world={"forest", "cave"}})
            STRINGS.UI.CUSTOMIZATIONSCREEN["MOD_"..string.upper(veggiename)..appendix] = STRINGS.NAMES[string.upper(veggiename)] or STRINGS.NAMES[string.upper(data.prefab)] or _G.FirstToUpper(veggiename)
            
            WSO.Pre["MOD_"..string.upper(veggiename)..appendix] = function(difficulty) -- all TUNING changes are done in "Pre" (while Post is using PushEvent)
                if difficulty~="default" then -- then we dont change anything
                    local mult = _G.tonumber(string.split(difficulty,"_")[2])
                    for stagename,growdata in pairs(data.grow_time) do
                        if stagename~="full" and stagename~="oversized" and stagename~="regrow" then -- dont change the perish time
                            if type(growdata)=="number" then
                                data.grow_time[stagename] = data.grow_time[stagename]*mult
                            elseif type(growdata)=="table" then -- eg {germination_min, germination_max}
                                if growdata[1]~=nil then -- make sure it is an ipairs table
                                    for i,entry in ipairs(growdata) do
                                        data.grow_time[stagename][i] = data.grow_time[stagename][i]*mult
                                    end
                                end
                            else
                                print("MORE WORLDSETTINGS MOD: PLANT_DEFS."..string.upper(veggiename)..appendix.." growdata is no number and also no table, but: "..tostring(type(growdata))..". Maybe add this to the code")
                            end
                        end
                    end
                end
            end
        
        end
    end
end




-- #############
-- stuff that is not fetched automatically:

-- GROW_TIME: better add those manually, because they are complicated. on one hand there are many things that should not be multiplied,
--   or there are multiplae values (like evergreen and pinecone) or we should not multiply the "tall" stage, or at least not reduce the time of that stage

-- plants do not change the current grow time, so if you change to "never" and then back to another value, the current grow stage has to complete to change to the new one.
--   -> solved in lightflier_flower with worldsettingstimer. added that code in modmain to all pickables. but for other things it would be too much work

-- PLANT_DEFS (require farm_plant_defs.lua), dort über die PLANT_DEFS loopen und dort über die grow_time and die beinhalteten werte/tabellen mit mult multiplizieren

-- bis das evergreens.lua local problem von den devs gefixt ist, könnte man es stattdessen auch über eine modsetting machen und so den TUNING wert ändern bevor evergreens.lua gecalled wird
--   damit wäre man weiter als aktuell, wobei natürlich die aktuelle stage evlt nicht verändert wird.
--   allerdings wäre die zufallswahl vom teleportatomod nicht umsetzbar, da man keinen ort hat wo man den einmal gewählten wert zuverlässig speichern kann (außer in ner extra datei)

-- SPIDERDEN_GROW_TIME_QUEEN
-- OCEANTREENUT_GROW_TIME_VARIANCE (wobei VARIANCE evlt auch ein bereits eingebauter zufallsfaktor für selbiges ist! gibt auch BERRY_REGROW_VARIANCE in berrybush.lua)
-- 
-- manche tunings sind auch wieder so aufgebaut: prefab = {REGROW_TIME=1,abc=4}. das ist aktuell noch nicht erfasst
-- BABYBEEFALO_GROW_TIME hat eine table weniger als andere _GROW_TIME
-- SPIDERDEN_GROW_TIME hat keine base/random unterscheidung
-- mushrooms.lua has pickable, but no TUNING REGROW_TIME defined and therefore also no worldsettingstimer code... we would need to overwrite too much from the prefab to make it work properly I think..
    

--#####################
--[[
-- change some TUNING values if setting_do_variate_world is on
TUNING.SPRING_GROWTH_MODIFIER = 0.5 -- wieviel schneller das meiste im spring wächst
TUNING.GRASS_REGROW_TIME = TUNING.TOTAL_DAY_TIME*3,
TUNING.SAPLING_REGROW_TIME = TUNING.TOTAL_DAY_TIME*4,
TUNING.MARSHBUSH_REGROW_TIME = TUNING.TOTAL_DAY_TIME*4,
TUNING.CACTUS_REGROW_TIME = TUNING.TOTAL_DAY_TIME*4,
TUNING.FLOWER_CAVE_REGROW_TIME = TUNING.TOTAL_DAY_TIME*3,
TUNING.FLOWER_CAVE_LIGHT_TIME = 90,
TUNING.FLOWER_CAVE_RECHARGE_TIME = 110,
TUNING.LICHEN_REGROW_TIME = TUNING.TOTAL_DAY_TIME*5,
TUNING.BERRY_REGROW_TIME = TUNING.TOTAL_DAY_TIME*3,
TUNING.BERRY_REGROW_INCREASE = TUNING.TOTAL_DAY_TIME*.5,
TUNING.BERRY_REGROW_VARIANCE = TUNING.TOTAL_DAY_TIME*2,
TUNING.BERRYBUSH_CYCLES = 3,
TUNING.BERRY_JUICY_REGROW_TIME =  TUNING.TOTAL_DAY_TIME * 9,
TUNING.BERRY_JUICY_REGROW_INCREASE = TUNING.TOTAL_DAY_TIME*.5,
TUNING.BERRY_JUICY_REGROW_VARIANCE = TUNING.TOTAL_DAY_TIME*2,
TUNING.BERRYBUSH_JUICY_CYCLES = 3,
TUNING.REEDS_REGROW_TIME = TUNING.TOTAL_DAY_TIME*3,
TUNING.GRASS_CYCLES = 20,
ROCK_FRUIT_SPROUT_GROWTIME = 5*day_time,
ROCK_FRUIT_REGROW =
{
    EMPTY = { BASE = 2*day_time, VAR = 2*seg_time },
    PREPICK = { BASE = 6*seg_time, VAR = 2*seg_time },
    PICK = { BASE = 3*day_time, VAR = 2*seg_time },
    CRUMBLE = { BASE = 1*day_time, VAR = 2*seg_time },
},
TUNING.EVERGREEN_GROW_TIME = {
    {base=0.1*TUNING.DAY_TIME_DEFAULT, random=0.2*TUNING.DAY_TIME_DEFAULT},   --short
    {base=0.1*TUNING.DAY_TIME_DEFAULT, random=0.2*TUNING.DAY_TIME_DEFAULT},   --normal
    {base=0.1*TUNING.DAY_TIME_DEFAULT, random=0.2*TUNING.DAY_TIME_DEFAULT},   --tall
    {base=0.1*TUNING.DAY_TIME_DEFAULT, random=0.2*TUNING.DAY_TIME_DEFAULT}   --old
}
TUNING.TWIGGY_TREE_GROW_TIME = {
    {base=1.5*TUNING.DAY_TIME_DEFAULT, random=0.5*TUNING.DAY_TIME_DEFAULT},   --short
    {base=3*TUNING.DAY_TIME_DEFAULT, random=1*TUNING.DAY_TIME_DEFAULT},   --normal
    {base=3*TUNING.DAY_TIME_DEFAULT, random=1*TUNING.DAY_TIME_DEFAULT},   --tall
    {base=5*TUNING.DAY_TIME_DEFAULT, random=0.5*TUNING.DAY_TIME_DEFAULT}   --old
}
TUNING.PINECONE_GROWTIME = {base=0.75*TUNING.DAY_TIME_DEFAULT, random=0.25*TUNING.DAY_TIME_DEFAULT}
TUNING.DECIDUOUS_GROW_TIME ={
    {base=1.5*TUNING.DAY_TIME_DEFAULT, random=0.5*TUNING.DAY_TIME_DEFAULT},   --short
    {base=5*TUNING.DAY_TIME_DEFAULT, random=2*TUNING.DAY_TIME_DEFAULT},   --normal
    {base=5*TUNING.DAY_TIME_DEFAULT, random=2*TUNING.DAY_TIME_DEFAULT},   --tall
    {base=1*TUNING.DAY_TIME_DEFAULT, random=0.5*TUNING.DAY_TIME_DEFAULT}   --old
}
TUNING.ACORN_GROWTIME = {base=0.75*TUNING.DAY_TIME_DEFAULT, random=0.25*TUNING.DAY_TIME_DEFAULT}
]]--

----------------------------------------------------------------------------------------------



