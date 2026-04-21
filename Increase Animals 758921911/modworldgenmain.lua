GLOBAL.require("map/terrain")

local function mymathclamp(num, min, max)
    return num <= min and min or (num >= max and max or num)
end
local function round2(num, idp)
	return GLOBAL.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

-- Thanks to DarkXero for explaining me what room.contents.distributeprefabs and room.contents.distributepercent do.
-- And thanks to "Pickle It" Mod for examples how to add those things in general


-- TODO
-- Adding Cave? Cave Monster on overworld? Rooms from overworld do not appear in cave, that is good.



-- CALCULATION explained:
-- Changing the distributeprefabs is not enough. (this value is relative to the other values: 0.1 and 0.1 will be 50:50. 0.1 and 3 will be a 3.22:96.77 distribution)
-- Also the distributepercent value has to be changed (this is how much of the total space is filled with things)
-- Otherwise, if we add a new prefab, it will replace some of the previous prefabs. So if we add a high chance for e.g merms, less trees, bushes and other things will appear.
-- so to make sure, that after adding merms, the number of trees, bushes and so on will be the same, we have to calculate new percent value
-- the new percent value is calculated that way:  oldpercent / (oldsum/newsum) = newpercent
-- so if we previously had trees and bushes with 0.05 both and a percent of 0.3, both prefabs were distributed 50:50 on this 30% of space.
-- now we add some merms with a value of 0.025. We still want 30% of the space to contain trees and bushes.
-- so the new percent will be: 0.3 / (0.1 / 0.125) = 0.375 , so a total of 0.075 of the space will be merms
-- Now we can also add some tallbirds with 0.025, the new percent will be: 0.375 / (0.125 / 0.15) = 0.45 , so also a total of 0.075 of the space will be tallbirds
-- instead of calcuating the new percent after every addition, we can also calculate it, after we added all the stuff: 0.3 / (0.1 / 0.15) = 0.45
-- depending on how many things are added, the percent could go over 1 = 100% ... so I think we should cap it at 1.
-- of course you can calculate this also the other way round. So if I want tallbirds to spawn at 0.075 (=totalspaceprefab) of the total space, I can calculate that I have to set their value to 0.025(=prefabvalue).
-- calculation is: 0.1 * (0.3 + 0.075) / 0.3 - 0.1 = 0.025  <--> (oldsum * (oldpercent + totalspaceprefab) / oldpercent) - oldsum = prefabvalue


-- Getting all existing rooms (thanks DarkXero) .. but dont' use it, since there are soo many rooms that we don't want to change... so instead list all the rooms manually we want to change...
-- local function GetRoomsTable()
	-- local debug = GLOBAL.debug
	-- local func = GLOBAL.AddRoom
	-- local i = 1
	-- while true do
		-- local n, v = debug.getupvalue(func, i)
		-- if not n then
			-- return {}
		-- end
		-- if n == "rooms" then
			-- return v
		-- end
		-- i = i + 1
	-- end
-- end
-- local rooms = GetRoomsTable()





-- Only use the following rooms (found in scripts\map\rooms\forest)
local Terrains = {
Badland = {"BGBadlands","Badlands",}, 
BadlandComplete = {"BGBadlands","Badlands","Lightning","HoundyBadlands","BuzzardyBadlands","Moundfield",},
Decidiuous = {"BGDeciduous","DeepDeciduous","DeciduousClearing","PondyGrass",}, 
DecidiuousComplete = {"BGDeciduous","DeepDeciduous","DeciduousMole","DeciduousClearing","PondyGrass","MolesvilleDeciduous","MagicalDeciduous",},
Grass = {"BGGrassBurnt","BGGrass","MandrakeHome",}, -- eg. hounds attack everything, so there would be no moles and beehives left...
GrassComplete = {"BGGrassBurnt","BGGrass","MandrakeHome","GrassyMoleColony","FlowerPatch","EvilFlowerPatch","Waspnests","WalrusHut_Grassy","Walrusfield","PigTown","PigVillage","PigKingdom","PigCamp",}, 
Dirt = {"BGDirt","BGNoise",},
DirtComplete = {"BGDirt","BGNoise",},
Forest = {"BGCrappyForest","BGForest","BGDeepForest","BurntForest","CrappyDeepForest","DeepForest","Forest","CrappyForest","BurntClearing","Clearing",}, 
ForestComplete = {"BGCrappyForest","BGForest","BGDeepForest","BurntForest","CrappyDeepForest","DeepForest","Forest","ForestMole","CrappyForest","BurntClearing","Clearing","SpiderForest",
    "SpiderCity","Graveyard",},  
Marsh = {"BGMarsh","Marsh",}, 
MarshComplete = {"BGMarsh","Marsh","SpiderMarsh","SlightlyMermySwamp","SpiderVillageSwamp","Mermfield","Tentacleland",}, 
Rocky = {"BGRocky","Rocky","GenericRockyNoThreat",}, 
RockyComplete = {"BGRocky","Rocky","GenericRockyNoThreat","MolesvilleRocky","BGChessRocky","RockyBuzzards","SpiderVillage","WalrusHut_Rocky","Tallbirdfield","TallbirdNests","PigCity",}, 
Savanna = {"BGSavanna","Plain","BarePlain",},
SavannaComplete = {"BGSavanna","Plain","BarePlain","WalrusHut_Plains","BeefalowPlain",},
Desert = {"BGLightningBluff","LightningBluffOasis"},
DesertComplete = {"BGLightningBluff","LightningBluffAntlion","LightningBluffOasis","LightningBluffLightning"},
}

-- enemy specific areas
local AnimalTerrain = {
Spiders = {"SpiderMarsh","SpiderForest","SpiderCity","SpiderVillage","SpiderVillageSwamp","SpiderfieldEasy","Spiderfield",},
Wasps = {"BeeClearing","FlowerPatch","EvilFlowerPatch","Waspnests",}, -- everywhere were bees are
Merms = {"SlightlyMermySwamp","MermTown","Mermfield",},
Tentacles = {"BGMarsh","Marsh","Tentacleland",},
Walrus = {"WalrusHut_Plains","WalrusHut_Grassy","WalrusHut_Rocky","Walrusfield",},
Hounds = {"HoundyBadlands","Moundfield",},
Clockworks = {"ChessArea","MarbleForest","ChessMarsh","ChessForest","ChessBarrens","BGChessRocky","Chessfield",}, -- gesamtzahl erhöhen, also countprefabs.
GuardPigs = {}, -- guardpigs have no natural room...

-- neutral
Bees = {"BeeClearing","FlowerPatch","EvilFlowerPatch","Waspnests",},
Tallbirds = {"TallbirdNests","Tallbirdfield",},
Beefalos = {"BeefalowPlain",},
Pigs = {"PigTown","PigVillage","PigKingdom","PigCity","PigCamp",}, -- man koennte dort die gesamtanzahl an pighouses erhöhen, also countprefabs.pighouse 
Rabbits = {"BGSavanna","Plain","BarePlain",},
Moles = {"GrassyMoleColony","DeciduousMole","MolesvilleDeciduous","ForestMole","MolesvilleRocky",},
Voaltgoats = {"Lightning","LightningBluffLightning"},
Catcoons = {"BGDeciduous","DeepDeciduous","MagicalDeciduous","DeciduousMole","PondyGrass",},
Fireflies = {"BGDeciduous","DeepDeciduous","MagicalDeciduous","DeciduousMole","DeciduousClearing","PondyGrass","BeeClearing","FlowerPatch","EvilFlowerPatch","Clearing","MoonbaseOne"}, -- only few MolesvilleDeciduous, MandrakeHome, "BGDeepForest",CrappyDeepForest, DeepForest,  "Forest","CritterDen","ForestMole","CrappyForest"
RockLobsters = {}, -- no cave biomes added yet, so no natural room
}


local AnimalPrefabs = {Spiders="spiderden",Wasps="wasphive",Merms="mermhouse",Tentacles="tentacle",Walrus="walrus_camp",Hounds="houndmound",GuardPigs="pigtorch",
    Tallbirds="tallbirdnest",Beefalos="beefalo",Pigs="pighouse",Rabbits="rabbithole",Moles="mole",Voaltgoats="lightninggoat",Bees="beehive",Catcoons="catcoonden",Fireflies="fireflies",RockLobsters="rocky"}
-- ,Clockworks="clockwork"
    
local ModSettings = {} -- save modsettings in this, to be able to alter them randomly, if random option is enabled. 
local function GetSettings(name,prefab)
    ModSettings[name] = GetModConfigData(name)
    ModSettings[name.."Natural"] = GetModConfigData(name.."Natural")
    for terrainname,terrainlist in pairs(Terrains) do
        ModSettings[name..terrainname] = GetModConfigData(name..terrainname)
    end
end

local function GetModSettings(name)
    return ModSettings[name]
end
    
local function AddAnimaltoWorldGeneration(name,prefab) 
    if prefab=="clockwork" then
        -- if GLOBAL.GetRandomMinMax(0,1)>=0.5 then
            -- prefab = "bishop"
        -- else
            -- prefab = "knight"
        -- end
        AddAnimaltoWorldGeneration(name,"bishop") -- add both
        AddAnimaltoWorldGeneration(name,"knight")
        return
    end
    local Increase = GetModSettings(name)
    if prefab=="knight" then
        Increase = Increase*0.75
    elseif prefab=="bishop" then
        Increase = Increase*0.25
    end
    if Increase > 0 then -- if we set to increase the number for this animal
        local choosenrooms = {}
        if GetModSettings(name.."Natural") then
            choosenrooms = GLOBAL.ArrayUnion(choosenrooms,AnimalTerrain[name])
        end
        for terrainname,terrainlist in pairs(Terrains) do
            if GetModSettings(name..terrainname)=="partly" then
                choosenrooms = GLOBAL.ArrayUnion(choosenrooms,terrainlist)
            elseif GetModSettings(name..terrainname)=="complete" then
                choosenrooms = GLOBAL.ArrayUnion(choosenrooms,Terrains[terrainname.."Complete"])
            end
        end
        local choosenroomsString = ""
        local oldpercent = 0
        local oldsum = 0
        local prefabvalue = 0
        for _,roomstr in pairs(choosenrooms) do
            choosenroomsString = choosenroomsString..roomstr..", "
            AddRoomPreInit(roomstr, -- if the room does not exist, it is added... so in case we want to support mod rooms, we shoudl call all active rooms first, and test if this room is active at the moment
                function(room) 
                    if room.contents then
                        oldpercent = room.contents.distributepercent or 0
                        if not room.contents.distributeprefabs or oldpercent==0 then
                            room.contents.distributeprefabs = {}
                            prefabvalue = 1 -- here this value does not matter, cause it is the only one
                            room.contents.distributeprefabs[prefab] = (room.contents.distributeprefabs[prefab] and room.contents.distributeprefabs[prefab] + prefabvalue) or prefabvalue
                            room.contents.distributepercent = Increase
                        else
                            oldsum = 0
                            for distprefab,number in pairs(room.contents.distributeprefabs) do
                                if type(number)=="table" then -- eg: smallmammal = {weight = 0.025, prefabs = {"rabbithole", "molehill"}},
                                    -- print("number ist eine table bei: "..tostring(distprefab).." in room: "..tostring(roomstr))
                                    for k,v in pairs(number) do
                                        -- print("k: "..tostring(k).." v: "..tostring(v))
                                        if type(v)=="number" and k=="weight" then
                                            oldsum = oldsum + v
                                        end
                                    end
                                elseif type(number)=="number" then
                                    oldsum = oldsum + number
                                end
                            end
                            room.contents.distributepercent = mymathclamp(oldpercent + Increase,0,1)
                            prefabvalue = round2((oldsum * (room.contents.distributepercent / oldpercent)) - oldsum,8)
                            room.contents.distributeprefabs[prefab] = (room.contents.distributeprefabs[prefab] and room.contents.distributeprefabs[prefab] + prefabvalue) or prefabvalue
                        end
                        -- print("AnimalIncreaser Debug: "..roomstr..": added "..prefab..". oldpercent: "..oldpercent..", oldsum: "..oldsum..", newpercent: "..room.contents.distributepercent..", prefabvalue: "..prefabvalue..", newvalue: "..room.contents.distributeprefabs[prefab])
                    end
                end
            )
        end
        print("AnimalIncreaser: Add "..tostring(round2(Increase*100,2)).."% "..prefab.." to the following rooms: "..choosenroomsString)
    end
end

local function ChangeTerrainFilter(name,prefab)
    if GLOBAL.terrain.filter[prefab]==nil then -- if it has no terrainfilter yet, add it. otherwise it will be placed mostly near roads and such stuff, because it is the only valid thing on roads...
        if prefab~="knight" and prefab~="bishop" then
            GLOBAL.terrain.filter[prefab] = {GLOBAL.WORLD_TILES.ROAD, GLOBAL.WORLD_TILES.WOODFLOOR, GLOBAL.WORLD_TILES.CARPET, GLOBAL.WORLD_TILES.CHECKER, GLOBAL.WORLD_TILES.SCALE, WORLD_TILES.MONKEY_DOCK}
        else
            GLOBAL.terrain.filter[prefab] = {GLOBAL.WORLD_TILES.ROAD, GLOBAL.WORLD_TILES.WOODFLOOR, GLOBAL.WORLD_TILES.SCALE, WORLD_TILES.MONKEY_DOCK}
        end
    else -- in case they already have filters, make sure the area we want to place it is not filtered
        if GetModSettings(name.."Badland") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.DESERT_DIRT)
            print("AnimalIncreaser: Removed terrain filter Badland for "..prefab)
        end
        if GetModSettings(name.."Decidiuous") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.DECIDUOUS)
            print("AnimalIncreaser: Removed terrain filter Decidiuous for "..prefab)
        end
        if GetModSettings(name.."Grass") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.GRASS)
            print("AnimalIncreaser: Removed terrain filter Grass for "..prefab)
        end
        if GetModSettings(name.."Dirt") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.DIRT)
            print("AnimalIncreaser: Removed terrain filter Dirt for "..prefab)
        end
        if GetModSettings(name.."Forest") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.FOREST)
            print("AnimalIncreaser: Removed terrain filter Forest for "..prefab)
        end
        if GetModSettings(name.."Marsh") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.MARSH)
            print("AnimalIncreaser: Removed terrain filter Marhs for "..prefab)
        end
        if GetModSettings(name.."Rocky") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.ROCKY)
            print("AnimalIncreaser: Removed terrain filter Rocky for "..prefab)
        end
        if GetModSettings(name.."Savanna") then
            GLOBAL.RemoveByValue(GLOBAL.terrain.filter[prefab],GLOBAL.WORLD_TILES.SAVANNA)
            print("AnimalIncreaser: Removed terrain filter Savanna for "..prefab)
        end
    end
end


local function RandomizeSettings(number)
    local animals = {}
    for name,prefab in pairs(AnimalPrefabs) do
        GLOBAL.table.insert(animals,name)
    end
    local changeanimals = GLOBAL.PickSome(2*number,animals) -- change these animals to new rnaodm values (is always increase)
    for k,name in pairs(changeanimals) do
        ModSettings[name] = GLOBAL.GetRandomItem({0,0.001,0.001,0.001,0.002,0.002,0.002,0.003,0.003,0.003,0.004,0.004,0.005,0.005,0.006,0.006,0.007,0.008,0.009,0.01}) * number
        if ModSettings[name]~=0 then
            for terrainname,terrainlist in pairs(Terrains) do
                if name=="GuardPigs" then
                    ModSettings[name..terrainname] = "partly" -- spawn them everywhere, but less
                    ModSettings[name] = ModSettings[name] / 3
                else
                    ModSettings[name..terrainname] = false -- only at natural location
                end
            end
            if name~="GuardPigs" then
                ModSettings[name.."Natural"] = true
            end
            print("Increase Animals Mod: Randomly increased amounts of "..GLOBAL.tostring(name).." to: +"..GLOBAL.tostring(ModSettings[name]*100).."%")
        end
    end
end

for name,prefab in pairs(AnimalPrefabs) do
    GetSettings(name,prefab) -- gets and saves the settings in a variable to incooperate random settings option
end
if GetModConfigData("random")~=0 then
    RandomizeSettings(GetModConfigData("random"))
end
for name,prefab in pairs(AnimalPrefabs) do
    ChangeTerrainFilter(name,prefab)
    AddAnimaltoWorldGeneration(name,prefab)
end

-- #################################
-- now adding setpieces:
GLOBAL.require("map/tasks")
local LLayouts = GLOBAL.require("map/layouts").Layouts
local LTraps = GLOBAL.require("map/traps").Layouts
local LPRes = GLOBAL.require("map/protected_resources").Layouts
local LPofIn = GLOBAL.require("map/pointsofinterest").Layouts

LLayouts["PigGuardsWithChest4"] = GLOBAL.require("map/layouts/PigGuardsWithChest4") -- by default we have layout.start_mask = PLACE_MASK.NORMAL,  and   layout.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN
LLayouts["PigGuardsWithChest7"] = GLOBAL.require("map/layouts/PigGuardsWithChest7")
LLayouts["PigGuardsWithChest12"] = GLOBAL.require("map/layouts/PigGuardsWithChest12")
LLayouts["Chilled Base"] = GLOBAL.require("map/layouts/TrapWinter") -- give it same name like original, just in case the original is activated again, so we won't have both
LLayouts["Chilled Decid Base"] = GLOBAL.require("map/layouts/TrapWinterDec") -- give it same name like original, just in case the original is activated again, so we won't have both
LLayouts["Hot Base"] = GLOBAL.require("map/layouts/TrapSummer") -- give it same name like original, just in case the original is activated again, so we won't have both

AddLevelPreInitAny(function(level) -- modify the fill mask, so chances are higher that it is placed on the map
    local function Add_IIBE_Mask(layout)
        if layout then
            if GetModConfigData("set_piece_behaviour")==0 then
                layout.fill_mask = GLOBAL.PLACE_MASK.NORMAL
            elseif GetModConfigData("set_piece_behaviour")==1 then
                layout.start_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
                layout.fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
            elseif GetModConfigData("set_piece_behaviour")==2 then
                layout.start_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
                layout.fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
            end
        end
    end

    local my_layouts = { -- things that are in layouts.lua (my custom ones were already added there)
        "PigGuardsWithChest4",
        "PigGuardsWithChest7",
        "PigGuardsWithChest12",
        "Chilled Base",
        "Chilled Decid Base",
        "Hot Base",
        "TallbirdBlockerSmall",
        "TallbirdBlocker",
        "TallbirdBlockerB",
    }

    local traps = {
        "Ice Hounds",
        "Fire Hounds",
    }
    local protected_ressources = {
        "leif_forest",
        "tenticle_reeds",
        "tallbird_rocks",
        "pigguard_berries",
        "pigguard_berries_easy",
        "pigguard_grass",
        "pigguard_grass_easy",
        "spider_forest",
        "hound_rocks",
    }
    local pointsofinterest = {
        "skeleton_hunter_swamp",
        "skeleton_researchlab1",
        "skeleton_researchlab2",
        "skeleton_researchlab3",
    }
    
    for i, v in ipairs(my_layouts) do
        Add_IIBE_Mask(LLayouts[v])
    end
    for i, v in ipairs(traps) do
        Add_IIBE_Mask(LTraps[v])
    end
    for i, v in ipairs(protected_ressources) do
        Add_IIBE_Mask(LPRes[v])
    end
    for i, v in ipairs(pointsofinterest) do
        Add_IIBE_Mask(LPofIn[v])
    end
end)



AddTaskSetPreInitAny(function(tasksetdata)
    if tasksetdata.location ~= "forest" then -- this stuff is only for overworld
        return
    end
    
    
    if GetModConfigData("WinterTrap") then -- for some reason it will be most likey less then mod settings, even if you choose ignoreall
        if GLOBAL.GetRandomMinMax(0,1)>=0.5 then -- random chance, both are very simular
            tasksetdata.set_pieces["Chilled Decid Base"] = { count = GetModConfigData("WinterTrap"), tasks={"Make a pick","Mole Colony Deciduous","Speak to the king",}}
        else
            tasksetdata.set_pieces["Chilled Base"] = { count = GetModConfigData("WinterTrap"), tasks={"Befriend the pigs","Forest hunters", "For a nice walk", "Magic meadow",}}
        end
    end
    if GetModConfigData("SummerTrap") then
        tasksetdata.set_pieces["Hot Base"] = { count = GetModConfigData("SummerTrap"), tasks={"Oasis","Badlands",}}
    end
    
    if GetModConfigData("TallbirdsOption3") then
        tasksetdata.set_pieces["TallbirdBlockerSmall"] = { count = GetModConfigData("TallbirdsOption3"), tasks={"Dig that rock","Mole Colony Rocks",}} -- "Dig that rock" is BGNoise room
    end
    if GetModConfigData("TallbirdsOption7") then
        local name = "TallbirdBlocker"
        if GLOBAL.GetRandomMinMax(0,1)>=0.5 then -- random chance, both are very simular
            name = "TallbirdBlockerB"
        end
        tasksetdata.set_pieces[name] = { count = GetModConfigData("TallbirdsOption7"), tasks={"Dig that rock","Mole Colony Rocks",}}
    end
    if GetModConfigData("TallbirdsOption17") then
        tasksetdata.set_pieces["tallbird_rocks"] = { count = GetModConfigData("TallbirdsOption17"), tasks={"Dig that rock","Mole Colony Rocks",}}
    end
    if GetModConfigData("PigGuardsBerries1") then
        tasksetdata.set_pieces["pigguard_berries_easy"] = { count = GetModConfigData("PigGuardsBerries1"), tasks={"Make a pick","Speak to the king","Beeeees!","Frogs and bugs",}} -- 1 pigguard
    end
    if GetModConfigData("PigGuardsBerries8") then
        tasksetdata.set_pieces["pigguard_berries"] = { count = GetModConfigData("PigGuardsBerries8"), tasks={"Make a pick","Speak to the king","Beeeees!","Frogs and bugs",}} -- 8 pigguard
    end
    if GetModConfigData("WasphiveGrass") then
        tasksetdata.set_pieces["wasphive_grass_easy"] = { count = GetModConfigData("WasphiveGrass"), tasks={"Make a pick","Speak to the king","Beeeees!","Frogs and bugs",}} -- 3 grass
    end
    if GetModConfigData("PigGuardsGrass4") then
        tasksetdata.set_pieces["pigguard_grass_easy"] = { count = GetModConfigData("PigGuardsGrass4"), tasks={"Great Plains", "The hunters",}} -- savanna 4
    end
    if GetModConfigData("PigGuardsGrass8") then
        tasksetdata.set_pieces["pigguard_grass"] = { count = GetModConfigData("PigGuardsGrass8"), tasks={"Great Plains", "The hunters",}} -- svanna 8
    end
    if GetModConfigData("HoundRocks") then
        tasksetdata.set_pieces["hound_rocks"] = { count = GetModConfigData("HoundRocks"), tasks={"Mole Colony Rocks","Badlands"}} --rocky 10
    end
    if GetModConfigData("SpiderForest") then
        tasksetdata.set_pieces["spider_forest"] = { count = GetModConfigData("SpiderForest"), tasks={"Forest hunters", "For a nice walk", "Magic meadow",}} -- 12 forest
    end
    if GetModConfigData("EarlyBase") then
        tasksetdata.set_pieces["skeleton_researchlab1"] = { count = GetModConfigData("EarlyBase"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
    end     
    if GetModConfigData("MidBase") then
        tasksetdata.set_pieces["skeleton_researchlab2"] = { count = GetModConfigData("MidBase"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
    end
    if GetModConfigData("LateBase") then
        tasksetdata.set_pieces["skeleton_researchlab3"] = { count = GetModConfigData("LateBase"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
    end     
    
    if GetModConfigData("PigGuardsOption4") then
        tasksetdata.set_pieces["PigGuardsWithChest4"] = { count = GetModConfigData("PigGuardsOption4"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
    end
    if GetModConfigData("PigGuardsOption7") then
        tasksetdata.set_pieces["PigGuardsWithChest7"] = { count = GetModConfigData("PigGuardsOption7"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
    end
    if GetModConfigData("PigGuardsOption12") then
        tasksetdata.set_pieces["PigGuardsWithChest12"] = { count = GetModConfigData("PigGuardsOption12"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
    end
    if GetModConfigData("IceStaff") then
        tasksetdata.set_pieces["Ice Hounds"] = { count = GetModConfigData("IceStaff"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands","Squeltch",}}
    end
    if GetModConfigData("FireStaff") then
        tasksetdata.set_pieces["Fire Hounds"] = { count = GetModConfigData("FireStaff"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands","Squeltch",}}
    end
    if GetModConfigData("Treeguardforest") then
        tasksetdata.set_pieces["leif_forest"] = { count = GetModConfigData("Treeguardforest"), tasks={"Forest hunters"}}
    end
    if GetModConfigData("Tentaclereeds") then
        tasksetdata.set_pieces["tenticle_reeds"] = { count = GetModConfigData("Tentaclereeds"), tasks={"Squeltch"}}
    end
    if GetModConfigData("Tentacleskeleton") then
        tasksetdata.set_pieces["skeleton_hunter_swamp"] = { count = GetModConfigData("Tentacleskeleton"), tasks={"Squeltch"}}
    end
    
    
    if GetModConfigData("randomsetpieces")~=0 then -- this overwrites the settings for this setpieces we set previoeuly
        local rand = GetModConfigData("randomsetpieces")
        tasksetdata.set_pieces["TallbirdBlockerSmall"] = { count = GLOBAL.math.random(0,rand), tasks={"Dig that rock","Mole Colony Rocks",}} -- "Dig that rock" is BGNoise room
        local name2 = "TallbirdBlocker"
        if GLOBAL.GetRandomMinMax(0,1)>=0.5 then -- random chance, both are very simular
            name2 = "TallbirdBlockerB"
        end
        tasksetdata.set_pieces[name2] = { count = GLOBAL.math.random(0,rand), tasks={"Dig that rock","Mole Colony Rocks",}}
        tasksetdata.set_pieces["tallbird_rocks"] = { count = GLOBAL.math.random(0,rand), tasks={"Dig that rock","Mole Colony Rocks",}}
        tasksetdata.set_pieces["pigguard_berries_easy"] = { count = GLOBAL.math.random(0,rand), tasks={"Make a pick","Speak to the king","Beeeees!","Frogs and bugs",}} -- 1 pigguard
        tasksetdata.set_pieces["pigguard_berries"] = { count = GLOBAL.math.random(0,rand), tasks={"Make a pick","Speak to the king","Beeeees!","Frogs and bugs",}} -- 8 pigguard
        tasksetdata.set_pieces["wasphive_grass_easy"] = { count = GLOBAL.math.random(0,rand), tasks={"Make a pick","Speak to the king","Beeeees!","Frogs and bugs",}} -- 3 grass
        tasksetdata.set_pieces["pigguard_grass_easy"] = { count = GLOBAL.math.random(0,rand), tasks={"Great Plains", "The hunters",}} -- savanna 4
        tasksetdata.set_pieces["pigguard_grass"] = { count = GLOBAL.math.random(0,rand), tasks={"Great Plains", "The hunters",}} -- svanna 8
        tasksetdata.set_pieces["hound_rocks"] = { count = GLOBAL.math.random(0,rand), tasks={"Mole Colony Rocks","Badlands"}} --rocky 10
        tasksetdata.set_pieces["spider_forest"] = { count = GLOBAL.math.random(0,rand), tasks={"Forest hunters", "For a nice walk", "Magic meadow",}} -- 12 forest
        tasksetdata.set_pieces["skeleton_researchlab1"] = { count = GLOBAL.math.random(0,rand), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
        tasksetdata.set_pieces["skeleton_researchlab2"] = { count = GLOBAL.math.random(0,rand), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
        tasksetdata.set_pieces["skeleton_researchlab3"] = { count = GLOBAL.math.random(0,rand), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
        tasksetdata.set_pieces["PigGuardsWithChest4"] = { count = GLOBAL.math.random(0,rand), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
        tasksetdata.set_pieces["PigGuardsWithChest7"] = { count = GLOBAL.math.random(0,rand), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
        tasksetdata.set_pieces["PigGuardsWithChest12"] = { count = GLOBAL.math.random(0,rand), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands",}}
        tasksetdata.set_pieces["Ice Hounds"] = { count = GLOBAL.math.random(0,rand), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands","Squeltch",}}
        tasksetdata.set_pieces["Fire Hounds"] = { count = GLOBAL.math.random(0,rand), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis","Badlands","Squeltch",}}
        tasksetdata.set_pieces["leif_forest"] = { count = GLOBAL.math.random(0,rand), tasks={"Forest hunters"}}
        tasksetdata.set_pieces["tenticle_reeds"] = { count = GLOBAL.math.random(0,rand), tasks={"Squeltch"}}
        tasksetdata.set_pieces["skeleton_hunter_swamp"] = { count = GLOBAL.math.random(0,rand), tasks={"Squeltch"}}    
    end

end)
