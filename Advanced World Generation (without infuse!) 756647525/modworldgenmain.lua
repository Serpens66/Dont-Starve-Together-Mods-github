local require = GLOBAL.require
require("map/lockandkey")
local taskslua = require("map/tasks")
require("map/rooms")
require("map/terrain")
require("map/level")

local blockersets = require("map/blockersets")

local LOCKS = GLOBAL.LOCKS
local KEYS = GLOBAL.KEYS
local GROUND = GLOBAL.GROUND
local LEVELTYPE = GLOBAL.LEVELTYPE

local Layouts =require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")
Layouts["Grotto_old"] = StaticLayout.Get("map/static_layouts/grotto") -- add the grotto back to layouts (but with _old in name, to not mess with devs if they want to replace the grotto by something new)



if GetModConfigData("GlobalBiomeSize") then
    GLOBAL.SIZE_VARIATION = GetModConfigData("GlobalBiomeSize")
end


AddTaskSetPreInitAny(function(tasksetdata)
	print("**********************************************************")
	print("**********************************************************")
	print("************ TASK SET PRE INIT FOR FOREST !!! ************")
	print("**********************************************************")
	print("**********************************************************")
    -- print("SIZE_VARIATION "..tostring(GLOBAL.SIZE_VARIATION))
		if tasksetdata.location ~= "forest" then
			-- print("Bailing!")
			return
		end
	-- print("Applying!")
    if GetModConfigData("RandomOptionalBiomes") then
        tasksetdata.numoptionaltasks = GetModConfigData("RandomOptionalBiomes")
    end
    
    if GetModConfigData("RandomOptionalBiomes") then
        tasksetdata.numoptionaltasks = GetModConfigData("RandomOptionalBiomes")
    end
    
    if GetModConfigData("AddOldOptionalBiomes") then -- adds tasks from forest.lua, which are not used by DST, mostly from DS I guess.
        
        --[[
        -- automatically get all tasks and add them does not work, there are too many buggy and not fitting tasks (even after filtering for cavess, dlc, special mode and locks/keys)
        local alltasks = taskslua.GetAllTaskNames()
        print("HIER alltasks")
        local task = nil
        local valid_tasks = {}
        for _,name in ipairs(alltasks) do
            if not string.find(string.upper(name),"TEST") and not string.find(string.upper(name),"CAVE") and not string.find(string.upper(name),"QUAGMIRE") and not string.find(string.upper(name),"LAVA") and not string.find(string.upper(name),"MAX") then
                if not GLOBAL.table.contains(tasksetdata.optionaltasks,name) and not GLOBAL.table.contains(tasksetdata.tasks,name) then
                    task = taskslua.GetTaskByName(name)
                    if task~=nil then
                        if not (task.locks~=nil and GLOBAL.table.contains(task.locks,GLOBAL.LOCKS.CAVE)) and not (task.keys_given~=nil and GLOBAL.table.contains(task.keys_given,GLOBAL.KEYS.CAVE)) then 
                            if not (task.locks~=nil and GLOBAL.table.contains(task.locks,GLOBAL.LOCKS.RUINS)) and not (task.keys_given~=nil and GLOBAL.table.contains(task.keys_given,GLOBAL.KEYS.RUINS))  then 
                                if not (task.locks~=nil and GLOBAL.table.contains(task.locks,GLOBAL.LOCKS.ARCHIVE)) and not (task.keys_given~=nil and GLOBAL.table.contains(task.keys_given,GLOBAL.KEYS.ARCHIVE))  then 
                                    table.insert(valid_tasks,name)
                                    print(name)
                                end
                            end
                        end
                    end
                end
            end
        end
        local all_keys = {}
        for _,name in ipairs(valid_tasks) do
            task = taskslua.GetTaskByName(name)
            if task~=nil and task.keys_given~=nil then
                for __,key in ipairs(task.keys_given) do
                    if not GLOBAL.table.contains(all_keys,key) then
                        table.insert(all_keys,key)
                    end
                end
            end
        end
        local new_valid_tasks = {}
        local do_add = nil
        local misseskey = nil
        for _,name in ipairs(valid_tasks) do
            do_add = true
            task = taskslua.GetTaskByName(name)
            if task~=nil and task.locks~=nil then
                for __,lock in ipairs(task.locks) do -- LOCKS_KEYS
                    if lock~=GLOBAL.LOCKS.NONE then
                        misseskey = true
                        for ___,allowedkey in ipairs(GLOBAL.LOCKS_KEYS[lock]) do
                            if table.contains(all_keys,allowedkey) then
                                misseskey = false -- test if we have anyone of the needed keys
                            end
                        end
                        if misseskey then
                            do_add = false
                            print(tostring(name).." hat lock "..tostring(lock)..", wozu wird keinen der keys haben")
                        end
                    end
                end
            else
                do_add = false
            end
            if do_add then
                table.insert(new_valid_tasks,name)
            end
        end
        print(#new_valid_tasks)
        ]]--
        
        -- automatically get all tasks and add them does not work, there are too many buggy and not fitting tasks (even after filtering for cavess, dlc, special mode and locks/keys)
        -- so we define working ones manually:
        -- "funzt" stands for "is working". not sure which from the outcommented causes crash
        add_tasks = {
            ---- "IslandHop_Start",
            ---- "IslandHop_Hounds",
            ---- "IslandHop_Forest",
            ---- "IslandHop_Savanna",
            ---- "IslandHop_Rocky",
            ---- "IslandHop_Merm",
            ---- "Speak to the king classic",
            ---- "Resource-rich Tier2",
            ---- "Resource-Rich",
            "Wasps and Frogs and bugs", -- funzt
            "Hounded Magic meadow", -- funzt
            "Waspy The hunters", -- funzt
            "Guarded Walrus Desolate", -- funzt
            "Walrus Desolate", -- funzt
            -- "Insanity-Blocked Necronomicon",
            -- "Necronomicon",
            "Easy Blocked Dig that rock", -- funzt
            "Tentacle-Blocked The Deep Forest", -- funzt
            "The Deep Forest", -- funzt
            -- "Trapped Befriend the pigs",
            -- "Pigs in the city",
            -- "The Pigs are back in town",
            -- "Guarded King and Spiders",
            -- "Guarded Speak to the king",
            -- "King and Spiders",
            "Hounded Greater Plains", -- funzt
            "Greater Plains", -- funzt
            "Sanity-Blocked Great Plains", -- funzt
            "Rock-Blocked HoundFields", -- funzt
            "HoundFields", -- funzt
            "Merms ahoy", -- funzt
            "Sane-Blocked Swamp", -- funzt
            "Guarded Squeltch", -- funzt
            "Swamp start", -- funzt
            "Tentacle-Blocked Spider Swamp", -- funzt
            "Lots-o-Spiders", -- funzt
            "Lots-o-Tentacles", -- funzt
            "Lots-o-Tallbirds", -- funzt
            "Lots-o-Chessmonsters", -- funzt
            "Spider swamp", -- funzt
            "Sanity-Blocked Spider Queendom", -- funzt
            "Spider Queendom", -- funzt
            "Guarded For a nice walk", -- funzt
            -- "Mine Forest",
            -- "Battlefield",
            -- "Guarded Forest hunters",
            -- "Trapped Forest hunters",
            "Walled Kill the spiders", -- funzt
            "Waspy Beeeees!", -- funzt
            "Pretty Rocks Burnt", -- funzt
            -- "The charcoal forest",  -- [00:01:16]: DoLuaFile Error: #[string "scripts/map/forest_map.lua"]:41: attempt to perform arithmetic on local 'v' (a function value) -> vermutlich function aus distributeprefab entfernen? Oder die Spawnfunctions pickspawnprefab mit upvaluehacker fixen, dass sie auch mit fn umgehen kann...
            ---- "Land of Plenty",
            ---- "The other side",
            -- "Chessworld",
            ---- "Oasis",
        }
        
        tasksetdata.optionaltasks = GLOBAL.ArrayUnion(tasksetdata.optionaltasks,add_tasks)
        -- tasksetdata.numoptionaltasks = 100 -- TEST
    end
    
    
    
    -- the outcommented ones are in my increase animals mod
    -- if GetModConfigData("PigGuardsOption4") then
        -- tasksetdata.set_pieces["PigGuardsWithChest4"] = { count = GetModConfigData("PigGuardsOption4"), tasks={"Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis"}}
    -- end
    -- if GetModConfigData("PigGuardsOption7") then
        -- tasksetdata.set_pieces["PigGuardsWithChest7"] = { count = GetModConfigData("PigGuardsOption7"), tasks={"Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis"}}
    -- end
    -- if GetModConfigData("PigGuardsOption12") then
        -- tasksetdata.set_pieces["PigGuardsWithChest12"] = { count = GetModConfigData("PigGuardsOption12"), tasks={"Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis"}}
    -- end
    -- if GetModConfigData("IceStaff") then
        -- tasksetdata.set_pieces["Ice Hounds"] = { count = GetModConfigData("IceStaff"), tasks={"Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis"}}
    -- end
    -- if GetModConfigData("FireStaff") then
        -- tasksetdata.set_pieces["Fire Hounds"] = { count = GetModConfigData("FireStaff"), tasks={"Make a pick", "Dig that rock", "Great Plains", "Beeeees!", "Speak to the king", "Forest hunters", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis"}}
    -- end
    -- if GetModConfigData("juicyberryfarm") then
        -- tasksetdata.set_pieces["juicyberryfarm"] = { count = GetModConfigData("juicyberryfarm"), tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs","Oasis"}}
    -- end
    -- if GetModConfigData("leif_forest") then
        -- tasksetdata.set_pieces["leif_forest"] = { count = GetModConfigData("leif_forest"), tasks={"Forest hunters"}}
    -- end
    -- if GetModConfigData("tenticle_reeds") then
        -- tasksetdata.set_pieces["tenticle_reeds"] = { count = GetModConfigData("tenticle_reeds"), tasks={"Squeltch"}}
    -- end
    -- if GetModConfigData("tenticle_skeleton") then
        -- tasksetdata.set_pieces["skeleton_hunter_swamp"] = { count = GetModConfigData("tenticle_skeleton"), tasks={"Squeltch"}}
    -- end
    
    

    
    if GetModConfigData("ResurrectionStoneOption") then
        tasksetdata.set_pieces["ResurrectionStone"] = { count = GetModConfigData("ResurrectionStoneOption"), tasks={"Befriend the pigs","Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Badlands"}}
	end
    -- tasksetdata.set_pieces["WormholeGrass"] = { count = 8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands"}}
    -- tasksetdata.set_pieces["CaveEntrance"] = { count = 10, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands"}}
	-- Default Biomes Set Pieces
	if GetModConfigData("FarmplotOption") then
        tasksetdata.set_pieces["Farmplot"] = { count = GetModConfigData("FarmplotOption"), tasks={"Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end
    if GetModConfigData("StoneHengeOption") then
        tasksetdata.set_pieces["StoneHenge"] = { count = GetModConfigData("StoneHengeOption"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end
    if GetModConfigData("SimpleBaseOption") then
        tasksetdata.set_pieces["SimpleBase"] = { count = GetModConfigData("SimpleBaseOption"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Badlands", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end
    if GetModConfigData("RuinedBaseOption") then
        tasksetdata.set_pieces["RuinedBase"] = { count = GetModConfigData("RuinedBaseOption"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Badlands", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end
    if GetModConfigData("GrottoOption") then
        tasksetdata.set_pieces["Grotto_old"] = { count = GetModConfigData("GrottoOption"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Badlands", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end
    if GetModConfigData("LivingTreeOption") then
        tasksetdata.set_pieces["LivingTree"] = { count = GetModConfigData("LivingTreeOption"), tasks={"Squeltch", "Forest hunters"}}
	end
    if GetModConfigData("MacTuskTownOption") then
        tasksetdata.set_pieces["MacTuskTown"] = { count = GetModConfigData("MacTuskTownOption"), tasks={"Mole Colony Rocks","Forest hunters", "Badlands"}}
	end
    if GetModConfigData("MacTuskCityOption") then
        tasksetdata.set_pieces["MacTuskCity"] = { count = GetModConfigData("MacTuskCityOption"), tasks={"Mole Colony Rocks","Forest hunters", "Badlands"}}
	end
    if GetModConfigData("MermShrineOption") then
        tasksetdata.set_pieces["MaxMermShrine"] = { count = GetModConfigData("MermShrineOption"), tasks={"Squeltch"}}
	end
    if GetModConfigData("PigShrineOption") then
        tasksetdata.set_pieces["MaxPigShrine"] = { count = GetModConfigData("PigShrineOption"), tasks={"Speak to the king"}}
	end
    if GetModConfigData("VillageSquareOption") then
        tasksetdata.set_pieces["VillageSquare"] = { count = GetModConfigData("VillageSquareOption"), tasks={"Befriend the pigs","Make a pick", "Speak to the king"}}
	end
    if GetModConfigData("PigTownOption") then
        tasksetdata.set_pieces["PigTown"] = { count = GetModConfigData("PigTownOption"), tasks={"Befriend the pigs","Make a pick", "Speak to the king"}}
	end
    if GetModConfigData("TorchPigkingOption") then
        tasksetdata.set_pieces["TorchPigking"] = { count = GetModConfigData("TorchPigkingOption"), tasks={"Speak to the king"}}
	end
    if GetModConfigData("DeciduousPondOption") then
        tasksetdata.set_pieces["DeciduousPond"] = { count = GetModConfigData("DeciduousPondOption"), tasks={"Speak to the king"}}
	end	
    if GetModConfigData("ChessSpot1Option") then
        tasksetdata.set_pieces["ChessSpot1"] = { count = GetModConfigData("ChessSpot1Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("ChessSpot2Option") then
       tasksetdata.set_pieces["ChessSpot2"] = { count = GetModConfigData("ChessSpot2Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("ChessSpot3Option") then
        tasksetdata.set_pieces["ChessSpot3"] = { count = GetModConfigData("ChessSpot3Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("Maxwell1Option") then
        tasksetdata.set_pieces["Maxwell1"] = { count = GetModConfigData("Maxwell1Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("Maxwell2Option") then
        tasksetdata.set_pieces["Maxwell2"] = { count = GetModConfigData("Maxwell2Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("Maxwell3Option") then
        tasksetdata.set_pieces["Maxwell3"] = { count = GetModConfigData("Maxwell3Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("Maxwell4Option") then
        tasksetdata.set_pieces["Maxwell4"] = { count = GetModConfigData("Maxwell4Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("Maxwell5Option") then
        tasksetdata.set_pieces["Maxwell5"] = { count = GetModConfigData("Maxwell5Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("Maxwell6Option") then
       tasksetdata.set_pieces["Maxwell6"] = { count = GetModConfigData("Maxwell6Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	
    if GetModConfigData("Maxwell7Option") then
        tasksetdata.set_pieces["Maxwell7"] = { count = GetModConfigData("Maxwell7Option"), tasks={"Mole Colony Rocks","Mole Colony Deciduous","Make a pick", "Forest hunters", "Speak to the king", "Befriend the pigs", "For a nice walk", "The hunters", "Magic meadow", "Frogs and bugs"}}
	end	

    GLOBAL.dumptable(tasksetdata)
end)

AddTaskSetPreInitAny(function(tasksetdata)
	print("**********************************************************")
	print("**********************************************************")
	print("************* TASK SET PRE INIT FOR Cave !!! *************")
	print("**********************************************************")
	print("**********************************************************")
		if tasksetdata.location ~= "cave" then
			-- print("Bailing!")
			return
		end
	-- print("Applying!")
    if GetModConfigData("RandomOptionalCaveBiomes") then
        tasksetdata.numoptionaltasks = GetModConfigData("RandomOptionalCaveBiomes")
    end
    
    if GetModConfigData("CaveBaseOption") then
        tasksetdata.set_pieces["CaveBase"] = { count = GetModConfigData("CaveBaseOption"), tasks={"SpillagmiteCaverns", "BatCloister", "BigBatCave"}}
	end
    if GetModConfigData("MushBaseOption") then
        tasksetdata.set_pieces["MushBase"] = { count = GetModConfigData("MushBaseOption"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "CaveSwamp", "RedForest", "GreenForest", "BlueForest"}}
    end
    if GetModConfigData("TentaclePillar") then
        tasksetdata.set_pieces["TentaclePillar"] = { count = GetModConfigData("TentaclePillar"), tasks= {"MudWorld", "MudCave", "MudLights", "MudPit", "BigBatCave", "RockyLand", "RedForest", "GreenForest", "BlueForest", "SpillagmiteCaverns", "SwampySinkhole", "CaveSwamp", "UndergroundForest", "PleasantSinkhole", "FungalNoiseForest", "FungalNoiseMeadow", "BatCloister", "RabbitTown", "RabbitCity", "SpiderLand", "RabbitSpiderWar",	} }
    end
    if GetModConfigData("ResurrectionStoneCave") then
        tasksetdata.set_pieces["ResurrectionStone"] = { count = GetModConfigData("ResurrectionStoneCave"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "BigBatCave", "RockyLand", "RedForest", "GreenForest", "BlueForest", "SpillagmiteCaverns", "SwampySinkhole", "CaveSwamp", "UndergroundForest", "PleasantSinkhole", "FungalNoiseForest", "FungalNoiseMeadow", "BatCloister", "RabbitTown", "RabbitCity", "SpiderLand", "RabbitSpiderWar",} }
	end
    if GetModConfigData("SinkBaseOption") then
        tasksetdata.set_pieces["SinkBase"] = { count = GetModConfigData("SinkBaseOption"), tasks={"PleasantSinkhole", "RedForest", "GreenForest", "BlueForest"}}
	end
    if GetModConfigData("RabbitTownOption") then
        tasksetdata.set_pieces["RabbitTown"] = { count = GetModConfigData("RabbitTownOption"), tasks={"PleasantSinkhole", "RedForest", "GreenForest", "BlueForest"}}
	end
    if GetModConfigData("RuinsCampOption") then
        tasksetdata.set_pieces["RuinsCamp"] = { count = GetModConfigData("RuinsCampOption"), tasks={"Sacred"}}
	end
    if GetModConfigData("AltarRoomOption") then
        tasksetdata.set_pieces["AltarRoom"] = { count = GetModConfigData("AltarRoomOption"), tasks={"Sacred"}}
	end
    if GetModConfigData("BrokenAltarOption") then
        tasksetdata.set_pieces["BrokenAltar"] = { count = GetModConfigData("BrokenAltarOption"), tasks={"Sacred"}}
	end
    if GetModConfigData("Chessy1Option") then
        tasksetdata.set_pieces["Chessy_1"] = { count = GetModConfigData("Chessy1Option"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "RockyLand", "RedForest", "GreenForest", "BlueForest"}}
	end
    if GetModConfigData("Chessy2Option") then
        tasksetdata.set_pieces["Chessy_2"] = { count = GetModConfigData("Chessy2Option"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "RockyLand", "RedForest", "GreenForest", "BlueForest"}}
	end
    if GetModConfigData("Chessy3Option") then
        tasksetdata.set_pieces["Chessy_3"] = { count = GetModConfigData("Chessy3Option"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "RockyLand", "RedForest", "GreenForest", "BlueForest"}}
	end
    if GetModConfigData("Chessy4Option") then
        tasksetdata.set_pieces["Chessy_4"] = { count = GetModConfigData("Chessy4Option"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "RockyLand", "RedForest", "GreenForest", "BlueForest"}}
	end
    if GetModConfigData("Chessy5Option") then
        tasksetdata.set_pieces["Chessy_5"] = { count = GetModConfigData("Chessy5Option"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "RockyLand", "RedForest", "GreenForest", "BlueForest"}}
	end
    if GetModConfigData("Chessy6Option") then
        tasksetdata.set_pieces["Chessy_6"] = { count = GetModConfigData("Chessy6Option"), tasks={"MudWorld", "MudCave", "MudLights", "MudPit", "RockyLand", "RedForest", "GreenForest", "BlueForest"}}
    end
end)

