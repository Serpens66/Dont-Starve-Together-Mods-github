local _G = GLOBAL
local UpvalueHacker = _G.require("upvaluehacker")
local GetMoonPhase = nil
local MOON_PHASE_NAMES = nil

local lunacy_chances = {on=GetModConfigData("lunarchance"),off=100-GetModConfigData("lunarchance")}
local day_chances = {allday=GetModConfigData("alldaychance"),alldusk=GetModConfigData("allduskchance"),allnight=GetModConfigData("allnightchance"),nothing=GetModConfigData("nothingchance")} -- chance 
local wantedmoonphase = GetModConfigData("wantedmoonphase")--"half"  -- we only add a chance for changes to "half" because it is often enough and is most likely not pushed by any other game mechanic already
local wantedmoonphase_lunar = GetModConfigData("wantedmoonphase_lunar") -- "new"
local choice_trans_seg = {allday = {day = 16, dusk = 0, night = 0}, alldusk = {day = 0, dusk = 16, night = 0}, -- translation to segments
    allnight = {day = 0, dusk = 0, night = 16}, nothing=false}


AddComponentPostInit("clock",function(self)
    if _G.TheWorld.ismastersim and (_G.TheWorld:HasTag("forest") or _G.TheWorld.ismastershard) then
        GetMoonPhase = UpvalueHacker.GetUpvalue(self.OnUpdate, "GetMoonPhase") -- use upvaluehacker to get the moonphase-function
        MOON_PHASE_NAMES = UpvalueHacker.GetUpvalue(self.OnUpdate, "MOON_PHASE_NAMES")
    end
end)


local function EnableLunacy(inst,enable,sorce)
    -- print("HIER EnableLunacy "..tostring(enable))
    if inst~=nil and inst.components~=nil and inst.components.sanity~=nil and inst:HasTag("player") then
        inst.components.sanity:EnableLunacy(enable, sorce) -- enable==nil will aslo disable it
    end
end

AddPrefabPostInit("world", function(world)
    if world.ismastersim then -- only for forest, because caves has no moonphase so it will never change
        
        local rememberstuff_stuff1 = nil
        local choice = nil
        
        if world:HasTag("forest") or world.ismastershard then -- caves has no moonphase and cycles is done by mastershard nayways
            
            world:AddComponent("rememberstuff") -- a component just to save and load information
            
            world:ListenForEvent("cycleschanged", function(world, cycles) -- we need every 16 hours (day+dusk+night), not only when moonphase changes, because ms_setclocksegs is reset every cycle by seasons
                -- print("HIER cycleschanged") --  -- is called after worldgeneration and when the first player spawns, no clue why...
                rememberstuff_stuff1 = world and world.components and world.components.rememberstuff and world.components.rememberstuff.stuff1
                -- rememberstuff_stuff1.testvar = 2
                -- print("hier testvar "..tostring(rememberstuff_stuff1.testvar))
                if GetMoonPhase~=nil and MOON_PHASE_NAMES~=nil then
                    local moonphase, waxing = GetMoonPhase()
                    moonphase = MOON_PHASE_NAMES[moonphase]
                    if moonphase~=nil then
                        
                        -- print("HIER1 set rememberstuff_stuff1 lunacy_should_be_enabled "..tostring(rememberstuff_stuff1.lunacy_should_be_enabled))
                        
                        if moonphase == wantedmoonphase then
                            if rememberstuff_stuff1.daydusknight_segs==nil then
                                choice = _G.weighted_random_choice(day_chances)
                                -- print("hier choice "..tostring(choice))
                                rememberstuff_stuff1.daydusknight_segs = choice_trans_seg[choice] -- randomly choose between always night/day/dusk
                            -- else
                                -- print("HIER set rememberstuff_stuff1 daydusknight_segs "..tostring(rememberstuff_stuff1.daydusknight_segs.day)..","..tostring(rememberstuff_stuff1.daydusknight_segs.dusk)..","..tostring(rememberstuff_stuff1.daydusknight_segs.night))
                            end
                            if rememberstuff_stuff1.daydusknight_segs~=nil and rememberstuff_stuff1.daydusknight_segs~=false then
                                world:PushEvent("ms_setclocksegs", rememberstuff_stuff1.daydusknight_segs)
                            end
                        else
                            rememberstuff_stuff1.daydusknight_segs = nil
                        end
                        if moonphase == wantedmoonphase_lunar then
                            if rememberstuff_stuff1.lunacy_should_be_enabled==nil then -- if it is nil, choose randomly, otherwise use the saved value
                                rememberstuff_stuff1.lunacy_should_be_enabled = _G.weighted_random_choice(lunacy_chances)=="on" or false
                            end
                        else
                            rememberstuff_stuff1.lunacy_should_be_enabled = nil -- save nil in this case, so it is again randomly chosen on next moonphase
                        end
                        
                        
                        for _,player in ipairs(_G.AllPlayers) do
                            EnableLunacy(player,rememberstuff_stuff1.lunacy_should_be_enabled,"serpdaynight_mod")
                        end
                        
                    end
                end
            end)
        end
        
        world:ListenForEvent("ms_playerspawn", function(world,player) -- adjust Lunacy on player spawn
            -- print("HIER playerspawn")
            rememberstuff_stuff1 = world and world.components and world.components.rememberstuff and world.components.rememberstuff.stuff1
            if world:HasTag("forest") or world.ismastershard then
                -- if rememberstuff_stuff1~=nil then
                    -- print("HIER2 set rememberstuff_stuff1 lunacy_should_be_enabled "..tostring(rememberstuff_stuff1.lunacy_should_be_enabled))
                -- end
                EnableLunacy(player,rememberstuff_stuff1~=nil and rememberstuff_stuff1.lunacy_should_be_enabled,"serpdaynight_mod")
            else -- cave, disable the mod lunacy for caves/non mastershard
                EnableLunacy(player,false,"serpdaynight_mod")
            end
        end)
        
    end
end)


