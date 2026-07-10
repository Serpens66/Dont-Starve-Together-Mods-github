-- these are the values how often the information about things is updated. If you think something is updated too often or too less, you can alter these values
local updatePlayer = GetModConfigData("update_player") -- 0.2 -- in seconds, updates eg. the floor bonus, so it checks, what the floor is and if the base is complete, to show icon and aplly bonus
local updateStructure = GetModConfigData("update_structure")--2 -- since structures don't move, we don't need to update them that often
local updateOther = GetModConfigData("update_other")--0.7
local updateHeat = 2
local boat_is_wooden = GetModConfigData("boat_is_wooden")


if GLOBAL.TUNING.HOMEBASEMOD == nil then
   GLOBAL.TUNING.HOMEBASEMOD = {}
end
modimport("customsettings") -- add some custom grounds in this file
if GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS==nil then
  -- floors that should act like wooden with this mod
  GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS = {"WOODFLOOR",}
end
if GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS==nil then
  -- floors that should act like marble with this mod
  GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS = {"CHECKER",}
end
if GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS==nil then
  -- floors that should act like carpet with this mod
  GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS = {"CARPET","CARPET2",}
end


local DoDebug = false

-- 26.06.2020: Devs removed self.dryingSpeed, self.dryingResistance, self.wetnessSpeed, self.wetnessResistance from inventoryitemmoisture -.-
local no_drywetResistance = true -- disable the code changing these deprecated values. unfortunately devs simply removed them without offering an alternative

local MaxCache = 10000 -- how big the table, that includes instances and there statuses, should get before clearing it because it might be too big data (number of saved instances). clearing it too often can lead to unneded checks again and again, ignoring the update intervall.

-- load some lua functions into local stuff. it should improve performance
local function mytinsert(t,v)
    return table.insert(t,v)
end
local function mypairs(t)
    return pairs(t)
end
local function myipairs(t)
    return ipairs(t)
end
local function mytype(v)
    return type(v)
end
local function mygetmetatable(t)
    return GLOBAL.getmetatable(t)
end
local function mysetmetatable(target,meta)
    return GLOBAL.setmetatable(target,meta)
end
local function mymathpow(a,b)
    return math.pow(a,b)
end
local function mymathmax(a,b)
    return math.max(a,b)
end
local function mymathmin(a,b)
    return math.min(a,b)
end
local function mymathabs(a)
    return math.abs(a)
end
local function mymathclamp(a,b,c)
    return math.clamp(a,b,c)
end
local function round2(num, idp)
	return GLOBAL.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

if GetModConfigData("show_mrate")==1 then
    local function OnDirtyEventMRate(inst) -- this is called on client, if the server does inst.mynetvarHomeBase:set(...)
        inst.HUD.controls.status.moisturemeter:SetTooltip("+"..round2(inst.MRate:value(),3).."/s")
    end
    local function RegisterListenersMRate(inst)
        -- check that the entity is the playing player
        if inst.HUD ~= nil then
            inst:ListenForEvent("dirtyeventShowMRate", OnDirtyEventMRate)
        end
    end
    
    AddPlayerPostInit(function(inst)
        -- defined in netvars.lua
        -- GUID of entity, unique name identifier (among entity netvars), dirty event name
        inst.MRate = GLOBAL.net_float(inst.GUID, "Home Base Bonus Show MRate", "dirtyeventShowMRate")
        -- set a default value
        inst.MRate:set(0)
        inst:DoTaskInTime(0, RegisterListenersMRate)
        inst:DoTaskInTime(5, function() if inst.HUD ~= nil and inst.components.moisture~=nil then inst.components.moisture:GetMoistureRate() end end) -- update the value 5 seconds after init
    end)
    -- now when doing server stuff, use
    -- inst.MRate:set(float), with inst being a player 
    -- changes will propagate to clients
end


local function OnBaseBonus(inst,activate)
    if inst~=nil then
        -- print("activate: "..tostring(activate).." tag: "..tostring(inst:HasTag("hasbasebonus")))
        if not inst:HasTag("hasbasebonus") and activate and inst:HasTag("player") then 
            if (GetModConfigData("base_indicator")=="colour" or GetModConfigData("base_indicator")=="both") then inst.AnimState:SetMultColour(1,.725,0,1) end -- change colour of char, RGBA value divided by 255, if the 4th value is 0, you are invisble :D
            inst:AddTag("hasbasebonus")
            if (GetModConfigData("base_indicator")=="icon" or GetModConfigData("base_indicator")=="both") then inst.mynetvarHomeBase:set(1) end
        elseif not activate and inst:HasTag("player") then
            if inst:HasTag("hasbasebonus") then 
                inst:RemoveTag("hasbasebonus")
                if (GetModConfigData("base_indicator")=="colour" or GetModConfigData("base_indicator")=="both") then inst.AnimState:SetMultColour(1,1,1,1) end
                if (GetModConfigData("base_indicator")=="icon" or GetModConfigData("base_indicator")=="both") then inst.mynetvarHomeBase:set(0) end
            end
        end
    end
end




--------------------------------------- add/remove absorb damage -----------------------------------

local function AddAbsorb(self, key, mod)
  if not self.add_absorb[key] then
      self.add_absorb[key] = mod
      self:SetAbsorptionAmount(self.absorb + mod)
  end
end

local function RemoveAbsorb(self, key)
    if self.add_absorb[key] then
        self:SetAbsorptionAmount(self.absorb - self.add_absorb[key])
        self.add_absorb[key] = nil
    end
end

local function RegisterNewCombatMembers(self)
  self.add_absorb = {} -- % modifiers on self.absorb

  self.AddAbsorb = AddAbsorb
  self.RemoveAbsorb = RemoveAbsorb
end

AddComponentPostInit("health", function(self)
    if not self.add_absorb then -- check if another mod already added this. cause we should not add this twice
        RegisterNewCombatMembers(self)
    end
end)

--*****************************************************************************************************************************************--
------------------------------------------------- Combat Component Adjustments by ZupaleX --------------------------------------------------------------
----------------------------------------------------- to add/remove damage and period multiplier ------------------------------------------------- 
--*****************************************************************************************************************************************--

local function AddDamageModifier(self, key, mod)
  self.attack_damage_modifiers[key] = mod
end

local function RemoveDamageModifier(self, key)
  self.attack_damage_modifiers[key] = nil
end

local function GetDamageModifier(self)
  local mod = 1
  for k,v in pairs(self.attack_damage_modifiers) do
    mod = mod + v
  end
  return mod
end

local function AddPeriodModifier(self, key, mod)
  self.attack_period_modifiers[key] = { mod = mod, effective = self.min_attack_period * mod }
  self:SetAttackPeriod(self.min_attack_period * (1+mod))
end

local function RemovePeriodModifier(self, key)
    if self.attack_period_modifiers[key] then
        self:SetAttackPeriod(self.min_attack_period - self.attack_period_modifiers[key].effective)
        self.attack_period_modifiers[key] = nil
    end
end

local function GetPeriodModifier(self)
  local mod = 0
  for k,v in pairs(self.attack_period_modifiers) do
    mod = mod + v
  end
  return mod
end

local function RegisterNewCombatMembers(self)

  self.attack_damage_modifiers = {} -- % modifiers on self:CalcDamage()
  self.attack_period_modifiers = {} -- % modifiers on self.min_attack_period

  self.AddDamageModifier = AddDamageModifier
  self.RemoveDamageModifier = RemoveDamageModifier
  self.GetDamageModifier = GetDamageModifier

  self.AddPeriodModifier = AddPeriodModifier
  self.RemovePeriodModifier = RemovePeriodModifier
  self.GetPeriodModifier = GetPeriodModifier
end

AddComponentPostInit("combat", function(self)
    if not self.attack_damage_modifiers then -- check if another mod already added this. cause we should not add this twice
        RegisterNewCombatMembers(self)

        local CalcDamageOld = self.CalcDamage
        -- 2025: added spdmg aka planardamage. since I dont know how this work, will have this unchanged for now
        self.CalcDamage = function(self, target, weapon, multiplier,...)
          local dmg, spdmg = CalcDamageOld(self, target, weapon, multiplier,...)
          local bonus = self.damagebonus or 0 --not affected by multipliers

          return (dmg-bonus) * self:GetDamageModifier() + bonus, spdmg
        end
    end
  end
)
--###################################################################################################################









-- ########## Icon
Assets = {
    Asset("ATLAS", "images/baseicon.xml"),
}
local Image = GLOBAL.require('widgets/image')
local function BaseIcon(self)
    self.homebase_icon = self.topleft_root:AddChild(Image("images/baseicon.xml", "baseicon.tex"))
    self.homebase_icon:SetPosition(50,-50)--(-40, -40, 0)
    self.homebase_icon:SetScale(-.7, .7, .7)
    self.homebase_icon:SetTooltip("Base Complete")
    self.homebase_icon:Hide()
    -- self.homebase_icon:Show() --
end
AddClassPostConstruct("widgets/controls", BaseIcon)



local function OnDirtyEventHomeBase(inst) -- this is called on client, if the server does inst.mynetvarHomeBase:set(...)
    local val = inst.mynetvarHomeBase:value()
    if val==1 and inst.HUD~=nil then 
        inst.HUD.controls.homebase_icon:Show()
    elseif val==0 and inst.HUD~=nil then 
        inst.HUD.controls.homebase_icon:Hide()
    end
	-- Use val and do client related stuff
end

local function RegisterListenersHomeBase(inst)
	-- check that the entity is the playing player
	if inst.HUD ~= nil then
		inst:ListenForEvent("DirtyEventHomeBase", OnDirtyEventHomeBase)
	end
end

AddPlayerPostInit(function(inst)
    -- defined in netvars.lua
	-- GUID of entity, unique name identifier (among entity netvars), dirty event name
	inst.mynetvarHomeBase = GLOBAL.net_tinybyte(inst.GUID, "HomeBaseNetStuff", "DirtyEventHomeBase")

	-- set a default value
	inst.mynetvarHomeBase:set(0)

	inst:DoTaskInTime(0, RegisterListenersHomeBase)
    inst:DoTaskInTime(1, OnBaseBonus,false) -- remove tag at game start, so it will be updated after start.
end)
-- now when doing server stuff, use
-- inst.mynetvarHomeBase:set(num), with inst being a player and num a number between 0 and 7
-- changes will propagate to clients



-- ########## The BaseCheck Stuff
local function CheckBase(inst,xyztile) -- checks, if the player is near all required buildings
    if (GetModConfigData("base_required_insulation")==0 and GetModConfigData("base_required_speed")==0 and GetModConfigData("base_required_rainproof")==0 and GetModConfigData("base_required_sanity")==0) then
        return true -- if no base needed for anything, return true always. icon is not shown in this case, cause it only should show, if the floor is in range of a base or not. 
    end
    local x, y, z = xyztile[1],xyztile[2],xyztile[3]
    if not x or not y or not z then return false end
    
    local structures = GLOBAL.TheSim:FindEntities(x, y, z, GetModConfigData("base_range"), nil, nil, {"structure","lightsource","wall"}) --(x, y, z, radius, musttags, canttags, mustoneoftags)
    local science = GetModConfigData("science")
    local magic = GetModConfigData("magic")
    local cookpot = GetModConfigData("cookpot")
    local chest = GetModConfigData("chest")
    local dryrack = GetModConfigData("dryrack")
    local lightningrod = GetModConfigData("lightningrod")
    local farm = GetModConfigData("farm")
    local birdcage = GetModConfigData("birdcage")
    local light = GetModConfigData("light")
    local walls_number = 0 -- needed walls
    local walls_count = 100 -- found walls
    if GetModConfigData("walls")==false then -- if walls are required, yes it has to be false
        walls_number = GetModConfigData("walls_number") -- the number that is needed
        walls_count = 0 -- start counting at 0
    end
    for i, v in myipairs(structures) do
        if v.prefab then
            -- if v ~= inst and v.entity:IsVisible() then
                -- print(v.prefab)
                -- print(walls_count)
            -- end
            if v.prefab=="researchlab" or v.prefab=="researchlab2" then
                science = true
            elseif v.prefab=="researchlab3" or v.prefab=="researchlab4" then 
                magic = true
            elseif v.prefab=="cookpot" or v.prefab=="cookpot_survival" then
                cookpot = true
            elseif string.match(v.prefab,"chest") then --or v.prefab=="treasurechest" or v.prefab=="pandoraschest" or v.prefab=="skullchest" or v.prefab=="minotaurchest" or v.prefab=="dragonflychest" then
                chest = true
            elseif v.prefab=="meatrack" then
                dryrack = true
            elseif v.prefab=="lightning_rod" then
                lightningrod = true
            elseif v.prefab=="slow_farmplot" or v.prefab=="fast_farmplot" then
                farm = true
            elseif v.prefab=="birdcage" then
                birdcage = true
            elseif v:HasTag("lightsource") then
                light = true
            elseif v:HasTag("wall") then -- any kind of wall
                walls_count = walls_count + 1
            end
        end
        if light and science and magic and cookpot and chest and dryrack and lightningrod and farm and birdcage and walls_count>=walls_number then -- stop search, if everything was found already
            break
        end
    end
    if light and science and magic and cookpot and chest and dryrack and lightningrod and farm and birdcage and walls_count>=walls_number then
        -- print("bonus should be active")
        if inst:HasTag("player") then
            OnBaseBonus(inst,true)
        end
        return true
    end
    if inst:HasTag("player") then
        OnBaseBonus(inst,false)
    end
    return false
end

local function GetExternalheaterpowerr(inst,iswet,isplayer,xyztile) -- eventuell zu arbeitsintensiv, wenn jedes einzelne objekt die umgebung auf feuer prüft? 
    if isplayer then return (inst.components.temperature ~= nil and inst.components.temperature.externalheaterpower or 0) end -- players have temperature
    local externalheaterpower = 0
    local x, y, z = xyztile[1],xyztile[2],xyztile[3]
    if not x or not y or not z then
        -- print("externalheat ein xyz nil")
        -- print(inst)
        -- print("______")
        return externalheaterpower 
    end -- if one of them is nil, return 0
    local ents3 = GLOBAL.TheSim:FindEntities(x, y, z, 10, nil, { "INLIMBO" }, { "HASHEATER" }) or GLOBAL.TheSim:FindEntities(x, y, z, 10, { "HASHEATER" }, { "INLIMBO" }) --(x, y, z, radius, musttags, canttags, mustoneoftags)
    for i, v in myipairs(ents3) do -- loop through all found heaters in range  .....   testen wie hoch heaterPower werden kann, wenn 3 feuer um spieler herum
        if v ~= inst and
            not v:HasTag("INLIMBO") and
            v.components.heater ~= nil and  -- components.heater is most likely nil for clients... 
            v.components.heater:IsExothermic() then-- or v.components.heater:IsEndothermic()) then
            local heat = v.components.heater:GetHeat(inst)
            if heat ~= nil then
                local heatfactor = 1 - inst:GetDistanceSqToInst(v) / (10*10) 
                if iswet then
                    heatfactor = heatfactor * GLOBAL.TUNING.WET_HEAT_FACTOR_PENALTY
                end
                -- if v.components.heater:IsExothermic() then
                    local warmingtemp = heat * heatfactor
                    externalheaterpower = externalheaterpower + warmingtemp  -- several sources will sum up.. this is like it is also done in game files
                -- end
            end
        end
    end
    -- if externalheaterpower == 0 and ents3[1]~=nil then
        -- print("heaters in range but still 0?!")
        -- print(inst)
        -- print("________")
    -- end 
    return externalheaterpower
end


local function GetxyzTile(inst,isplayer,isstructure) -- returns x,y z and tile_id of thing or owner of the thing, in a table
    local x, y, z = inst.Transform:GetWorldPosition() 
    local tile_id, tile_name, data = nil,nil, nil
    if not x or not y or not z then 
        x,y,z = nil,nil,nil-- should not happen, but if, set everything to nil
    end 
    if x and y and z then
        tile_id, data = inst:GetCurrentTileType() -- throws an error if no x,y,z
        if boat_is_wooden and GLOBAL.TheWorld.Map:GetPlatformAtPoint(x, y, z)~=nil then
            tile_id = GLOBAL.GROUND.WOODFLOOR -- count a boat as WOODFLOOR
        end
        tile_name = GLOBAL.INVERTED_WORLD_TILES[tile_id]
    end
    -- WORLD_TILES[tile_name] = tile_id
    -- INVERTED_WORLD_TILES[tile_id] = tile_name
    
    -- inst:HasTag("animal") -- in case we want to find animals... rabbits are animals, but butterflies and birds are not ...
    -- if inst.components and inst.components.inventoryitem and inst.components.inventoryitem.owner~=nil and (not isstructure) and (not isplayer) and (not inst:HasTag("animal")) then print("getxyz item with owner");print(inst);print("x,y,z,tile: "..tostring(x)..","..tostring(y)..","..tostring(z)..","..tostring(tile));print("____");end
    -- print("x,y,z,tile_id: "..tostring(x)..","..tostring(y)..","..tostring(z)..","..tostring(tile_id))
    return {x,y,z,tile_name}
end

local function UpdateManager(inst,task,isplayer,xyztile,isstructure)
    if task=="base" then
        return CheckBase(inst,xyztile)
    elseif task=="heat" then
        return GetExternalheaterpowerr(inst,inst:HasTag("IsNewWet"),isplayer,xyztile) 
    elseif task=="coordinates" then
        return GetxyzTile(inst,isplayer,isstructure)
    end
end

local aCachedInfos = {} -- aCachedInfos[inst] == {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}}

local function UpdateChached(inst,task,iplayer,isstructure,xyztile) -- updates task, task can be the keys of the aCachedInfos table. 
    
    if aCachedInfos[inst]==nil then -- if it is not already in our table, add it
        if GLOBAL.GetTableSize(aCachedInfos) > MaxCache then -- empty the list, if it contains too much entries
            aCachedInfos = {}
            print("HomeBaseMod aCachedInfos cleared, should cause no trouble. Has to be done from time to time")
        end
        -- print("______ added (and tablesize): ")
        -- print(inst)
        -- print(GLOBAL.GetTableSize(aCachedInfos))
        aCachedInfos[inst]={["base"]={false,0},["heat"]={1,0},["coordinates"]={{nil,nil,nil,nil},0}} -- add a standard table, fourth value of coordinates is the tile
    end
    
    local Time = GLOBAL.GetTime()
    local prevtime = aCachedInfos[inst][task][2]
    
    if (prevtime==0) or (Time - prevtime > updatePlayer and isplayer) or (Time - prevtime > updateStructure and isstructure) or (Time - prevtime > updateOther and not (isstructure or isplayer)) then -- update it depending on time and kind.
        aCachedInfos[inst][task][2] = Time -- update the time
        aCachedInfos[inst][task][1] = UpdateManager(inst,task,isplayer,xyztile,isstructure) -- update the task thing
    end
end

local function UpdateorGet(inst,str,updaten) -- str is not needed anymore
    -- priority for updating is: speed, sanity, insulation, rain  (because I think speed is only called 2 times per second, an otheres are called more often. and for rain, moisture of player could be 0, so it even wouldn't be called)
    if not inst or not inst:IsValid() then
        return {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} -- return the standard thing
    end 
    
    local isplayer = inst:HasTag("player")
    if (isplayer and updaten==true) or not isplayer then -- update for players only if updaten true, is true every updatePlayer seconds.
        local isstructure = inst:HasTag("structure")
        UpdateChached(inst,"coordinates",isplayer,isstructure)
        local xyztile = GLOBAL.deepcopy(aCachedInfos[inst]["coordinates"][1])
        if GetModConfigData("hot_dry_fire")==1 then -- don't need to check heat, if option is disabled
            UpdateChached(inst,"heat",isplayer,isstructure,xyztile)
        end
        local tile = xyztile[4] 
        if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then -- if base or not, does not matter if we are not on floor
            UpdateChached(inst,"base",isplayer,isstructure,xyztile)
        end
    end

    if aCachedInfos[inst]==nil then-- just in case
        return {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} -- return the standard thing, in the receiving function also check if coordinates,tile are nil
    else
        return GLOBAL.deepcopy(aCachedInfos[inst]) -- return a deepcopy of the infos of inst,  
    end
end


local function UpdateNewWetTag(inst)
    local additional = 0
    local heaterPower = 0
    local cachedinst = UpdateorGet(inst,"rain") -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
    local heat = cachedinst["heat"][1]
    if GetModConfigData("hot_dry_fire")==1 then
        heaterPower = mymathmin(1500,heat * GetModConfigData("hot_dry_fire")) -- 0 to 150 ? -- at least 115 near a big firepit fire, but they sum up, so 10 fires will be 1150 and a forest fire will be more than 1500, but we will max it with 1500
        additional = 0.2316 * mymathpow(heaterPower,0.8337)  -- from 0 to ~100. normal fire 12.5 , 2 fires 22.3  ,~6 burining trees 45 ,very big forest fire no wet structures near that... could be that with this change forest fires will be more dangerous while it rains, but I think rain did not stop forest fires before anyway... 
    end   
    local tilebonus = 0
    if GetModConfigData("rain_reduction_wooden") ~= 1 or GetModConfigData("rain_reduction_checker")~= 1 or GetModConfigData("rain_reduction_carpet")~= 1 then
        local tile = cachedinst["coordinates"][1][4]
        local isbase = cachedinst["base"][1]
        if GetModConfigData("base_required_rainproof")==0 or isbase then 
            if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile)) then
                additional = additional + mymathpow((1-GetModConfigData("rain_reduction_carpet")),3) * 65    -- + 65 if 100% rainproof, so default 35 +65 will be 100, and since it cant be over 100, it will never be wet
                tilebonus = tilebonus + mymathpow((1-GetModConfigData("rain_reduction_carpet")),3) * 65    -- for 90% it will be +47
            elseif (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile)) then
                additional = additional + mymathpow((1-GetModConfigData("rain_reduction_wooden")),3) * 65   -- for 80% -> +33
                tilebonus = tilebonus + mymathpow((1-GetModConfigData("rain_reduction_wooden")),3) * 65    -- for 50% -> + 8.125
            elseif (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then
                additional = additional + mymathpow((1-GetModConfigData("rain_reduction_checker")),3) * 65
                tilebonus = tilebonus + mymathpow((1-GetModConfigData("rain_reduction_checker")),3) * 65  
            end
        end
    end
    -- if additional>0 and GLOBAL.GetRandomMinMax(0,1)>0.99 then 
        -- print("GetIsWet last: "..tostring(inst:HasTag("IsNewWet")).." , worldwettnes: "..GLOBAL.TheWorld.state.wetness.." wet if over:"..additional+GLOBAL.TUNING.MOISTURE_WET_THRESHOLD.." dry if under:"..additional+GLOBAL.TUNING.MOISTURE_DRY_THRESHOLD.." heaterPower: "..heaterPower.." tilebonus: "..tilebonus)
        -- print(inst)
        -- print("_________")
    -- end
    if GLOBAL.TheWorld.state.wetness < GLOBAL.TUNING.MOISTURE_DRY_THRESHOLD + additional then  -- default 15
        if inst:HasTag("IsNewWet") then
            inst:RemoveTag("IsNewWet")
        end
        return false
    elseif GLOBAL.TheWorld.state.wetness > GLOBAL.TUNING.MOISTURE_WET_THRESHOLD + additional then -- default 35 
        if not inst:HasTag("IsNewWet") then
            inst:AddTag("IsNewWet")
        end
        return true
    end
    return inst:HasTag("IsNewWet")
end


AddModRPCHandler(GLOBAL.KnownModIndex:GetModActualName("Home Base Bonus"), "HomeBaseMod_handler", function(player, inst)
    if player and inst~=nil then
        UpdateNewWetTag(inst)
	end
end)

local function EntityScriptPostConstruct(self) 
    local _GetIsWet = self.GetIsWet 
    self.GetIsWet = function(inst,...) 
        
        if GLOBAL.TheWorld.state.wetness==0 or GLOBAL.TheWorld.state.wetness==nil then -- if no wetness, nothing can be wet. works at server and client
            return _GetIsWet(inst,...)
        end
        local replica = inst.replica.inventoryitem or inst.replica.moisture -- items and character have their own thing
        if replica ~= nil or inst==nil or (inst.displaynamefn and inst.displaynamefn==GLOBAL.STRINGS.NAMES.MOLE_UNDERGROUND) then--or inst:HasTag("INLIMBO") then --  replica and hastag do work at server and at client.    inst:IsInLimbo() --V2C: faster than checking tag, but only valid on mastersim
            return _GetIsWet(inst,...) -- moleworm underground = dirt pile throws and RPC invalid data error otherwise
        end
        if inst:HasTag("wet") then return inst:HasTag("wet") end -- things that are always wet
        
        -- print("_____")
        -- print(inst)
        if not GLOBAL.POPULATING and mytype(inst) == "table" and inst:IsValid() then
            if GLOBAL.TheNet:GetIsServer() then 
                UpdateNewWetTag(inst)
            else --client
                local RPC = GetModRPC(GLOBAL.KnownModIndex:GetModActualName("Home Base Bonus"), "HomeBaseMod_handler") -- makes the server call UpdateNewWetTag to get the newest wet status of this object
                SendModRPCToServer(RPC, inst)
            end
        end
        return inst:HasTag("IsNewWet")
    end
end
if GetModConfigData("hot_dry_fire")==1 or GetModConfigData("rain_reduction_wooden") ~= 1 or GetModConfigData("rain_reduction_checker")~= 1 or GetModConfigData("rain_reduction_carpet")~= 1 then
    AddGlobalClassPostConstruct("entityscript","EntityScript", EntityScriptPostConstruct)
end


if not (GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated()) then  -- what is the difference between checking GetIsSwerver or mastersim ? basically the same, but in modmain theworld is nil, so we have to use thenet
	return
end

-- Armor Bonus
if GetModConfigData("absorb_carpet")~=0 or GetModConfigData("absorb_checker")~=0 or GetModConfigData("absorb_wooden")~=0 then
    AddComponentPostInit("health", function(self)
        if self.inst:HasTag("player") then     
            self.UpdateAbsorptionHomeBase = function(inst)
                if self.absorb~= nil then  -- at beginning it is sometimes nil, so wait until it is not
                    local cachedinst = UpdateorGet(inst,"rain")-- str does not matter here -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                    local tile = cachedinst["coordinates"][1][4]
                    local isbase = cachedinst["base"][1]
                    if not (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then -- if not on a floor, hide the base icon
                        OnBaseBonus(inst,false)
                    end
                    if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) and GetModConfigData("absorb_carpet")~=0) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) and GetModConfigData("absorb_wooden")~=0) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) and GetModConfigData("absorb_checker")~=0) then
                        if GetModConfigData("base_required_absorb")==0 or isbase then -- give bonus if no base is required or if there is a base
                            if table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) then
                                self:AddAbsorb("absorb_carpet",GetModConfigData("absorb_carpet"))
                                self:RemoveAbsorb("absorb_wooden")
                                self:RemoveAbsorb("absorb_checker")
                            elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) then
                                self:AddAbsorb("absorb_wooden",GetModConfigData("absorb_wooden"))
                                self:RemoveAbsorb("absorb_carpet")
                                self:RemoveAbsorb("absorb_checker")
                            elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) then
                                self:AddAbsorb("absorb_checker",GetModConfigData("absorb_checker"))
                                self:RemoveAbsorb("absorb_carpet")
                                self:RemoveAbsorb("absorb_wooden")
                            else
                                self:RemoveAbsorb("absorb_carpet")
                                self:RemoveAbsorb("absorb_wooden")
                                self:RemoveAbsorb("absorb_checker")
                            end
                        else
                            self:RemoveAbsorb("absorb_carpet")
                            self:RemoveAbsorb("absorb_wooden")
                            self:RemoveAbsorb("absorb_checker")
                        end
                    else
                        self:RemoveAbsorb("absorb_carpet")
                        self:RemoveAbsorb("absorb_wooden")
                        self:RemoveAbsorb("absorb_checker")
                    end
                end
                inst:DoTaskInTime(updatePlayer,self.UpdateAbsorptionHomeBase)
            end    
            
            self.inst:DoTaskInTime(updatePlayer,self.UpdateAbsorptionHomeBase)
        end
    end)
end

-- Damage Bonus
if GetModConfigData("damage_carpet")~=0 or GetModConfigData("damage_checker")~=0 or GetModConfigData("damage_wooden")~=0 then
    AddComponentPostInit("combat", function(self)
        if self.inst:HasTag("player") then 
            self.UpdateDamageHomeBase = function(inst)
                local cachedinst = UpdateorGet(inst,"rain")-- str does not matter here -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                local tile = cachedinst["coordinates"][1][4]
                local isbase = cachedinst["base"][1]
                if not (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then -- if not on a floor, hide the base icon
                    OnBaseBonus(inst,false)
                end
                if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) and GetModConfigData("damage_carpet")~=1) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) and GetModConfigData("damage_wooden")~=1) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) and GetModConfigData("damage_checker")~=1) then
                    if GetModConfigData("base_required_damage")==0 or isbase then -- give bonus if no base is required or if there is a base
                        if table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) then
                            self:AddDamageModifier("damage_carpet",GetModConfigData("damage_carpet"))
                            self:RemoveDamageModifier("damage_wooden")
                            self:RemoveDamageModifier("damage_checker")
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) then
                            self:AddDamageModifier("damage_wooden",GetModConfigData("damage_wooden"))
                            self:RemoveDamageModifier("damage_carpet")
                            self:RemoveDamageModifier("damage_checker")
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) then
                            self:AddDamageModifier("damage_checker",GetModConfigData("damage_checker"))
                            self:RemoveDamageModifier("damage_wooden")
                            self:RemoveDamageModifier("damage_carpet")
                        else -- should not happen, but just in case..
                            self:RemoveDamageModifier("damage_wooden")
                            self:RemoveDamageModifier("damage_carpet")
                            self:RemoveDamageModifier("damage_checker")
                        end
                    else -- if on floor, but no base
                        self:RemoveDamageModifier("damage_wooden")
                        self:RemoveDamageModifier("damage_carpet")
                        self:RemoveDamageModifier("damage_checker")
                    end
                else -- if not on floor or no bouns is set
                    self:RemoveDamageModifier("damage_wooden")
                    self:RemoveDamageModifier("damage_carpet")
                    self:RemoveDamageModifier("damage_checker")
                end
                inst:DoTaskInTime(updatePlayer,self.UpdateDamageHomeBase) -- call this check again
            end    
            self.inst:DoTaskInTime(updatePlayer,self.UpdateDamageHomeBase)
        end
    end)
end


AddPlayerPostInit(function(inst) -- this function does the updates for players now.
    UpdateHomeBaseData = function(inst)
        UpdateorGet(inst,"",true) -- third parameter is true means that it should update. 
        inst:DoTaskInTime(updatePlayer,UpdateHomeBaseData)
    end
    inst:DoTaskInTime(updatePlayer,UpdateHomeBaseData) -- automatically update base,heat and cordinates from every player every updatePlayer seconds.
end)


-- this stuff improves the heater chekc performance. Instead of every single thing in the world checks for heater, the heaters itself will now check for things in range
-- local Heaterlist = {} -- Heaterlist[heatinst][inst1] == 0 -- a list of things the heater does effect with the heat that reaches that thing. -- zusätzlich
-- local thingswithheat = {} -- thingswithheat[inst1]==true -- to make it easier to sum up Heaterlist. so only if inst is in thingswithheat, we will iterate through all heaters to get the total heat
-- AddComponentPostInit("heater", function(self) -- is called at server
    
    -- um inaktive heater zu entfernen koennte man hier noch immer die aktuelle zeit mit einspeichern und in GetExternalheaterpowerr diese chekcen. Wenn diese dann 2*updateHeat zurückliget, kann heater aus liste gelöscht werden.
    -- oder: 
    
    -- self.UpdateExternalHeat = function(inst)
        -- if inst:IsValid() and not inst:IsInLimbo() and inst.components.heater:IsExothermic() then
            -- local cachedinst = UpdateorGet(inst,"rain")-- str does not matter here -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
            -- local xyztile = cachedinst["coordinates"][1]
            -- local x, y, z = xyztile[1],xyztile[2],xyztile[3]
            -- if DoDebug then print(tostring(x).."/"..tostring(y).."/"..tostring(z).." "..tostring(inst)) end
            -- if x and y and z then
                -- local ents = GLOBAL.TheSim:FindEntities(x, y, z, 10, nil, {"FX", "NOCLICK", "DECOR"},nil) --musttags, canttags, mustoneoftags
                -- local heat = 0
                -- if ents[1]~=nil then -- no need to ask heat, if nothing in in range of heater
                    -- heat = inst.components.heater:GetHeat(v) 
                -- end
                -- if heat ~= 0 then
                    -- for k,v in pairs(ents) do
                        -- if v:IsValid() and inst~=v then -- and v.entity:IsVisible() then items in inventry are invisible -- and aCachedInfos[v]~=nil then -- das Erste mal soll auf alte Art bestimmt werden ... evlt um zu verhindern, dass minimap und sonstiger kram reingepackt wird?
                            -- if DoDebug then print(v) end 

                            -- local heatfactor = 1 - v:GetDistanceSqToInst(inst) / (10*10) 
                            -- if v:HasTag("IsNewWet") then
                                -- heatfactor = heatfactor * GLOBAL.TUNING.WET_HEAT_FACTOR_PENALTY
                            -- end
                            -- local warmingtemp = heat * heatfactor
                            -- if not Heaterlist[inst] then
                                -- Heaterlist[inst] = {} 
                                -- Heaterlist[inst][v] = warmingtemp
                                -- thingswithheat[v] = thingswithheat[v][2]+1--[thingswithheat[v][1]+warmingtemp,thingswithheat[v][2]+1] -- totalheat sollte nicht hier gemacht werden, da sonst ~60 heater ständig die table ändern und das ist evlt nicht gut, stattdessen in getexternalheat zusammenrechnen und returnen, ohne eine table zu verändern
                            -- else
                                -- local heatadded = warmingtemp - (Heaterlist[inst][v] or 0)
                                -- Heaterlist[inst][v] = warmingtemp -- total heat from this thing from all heaters in range will be calculated  in GetExternalheaterpowerr
                                ----- anzahl bleibt unverändert, totalheat wird in getexternalheat berechnet-- thingswithheat[v] = [thingswithheat[v][1]+heatadded,thingswithheat[v][2]+1]
                            -- end
                            
                                -- wenn Heaterlist[inst] neu ist, dann die heaternumber um 1 erhoehen. wird benötigt falls ein heater ausgeht, aber noch andere da sind, die inst deswegen nicht gelöscht wird, sondern halt nur einen heater weniger hat
                                -- für die totalheat wird der vorherige Heaterlist[inst][v] heat eintrag gespeichert und so die differenz ermittelt. Diese wird zu totalheat addiert
                                
                                -- wenn total heat stattdessen in getexternalheat berechnet wird, dort die heaterlist usw table erst in local deepcopy speichern, damit diese sich nicht während berehcnung verändert.
                                
                        -- end
                    -- end
                -- end
            -- end
        -- end
        -- inst:DoTaskInTime(updateHeat,self.UpdateExternalHeat)
        
        -- man könnte zusätzlich/anstelle zu der heaterliste jedes einzelnen objekts, auch eine globale heaterliste einführen... evlt eine liste in der der heater der key ist und eine liste der dinge die er beeinflusst der value.
        -- in so einer liste koennte man dann einfach jeden heater durchgehen und testen ob die inst noch vorhanden ist und ob auch die components heater noch da ist
        
    -- end
    -- self.inst:DoTaskInTime(updateHeat,self.UpdateExternalHeat)
-- end)


--[[ -- don't add these components (for Show Me mod) because they cause too much trouble wiht other mods. Use Insights mod instead of Show Me.
local function TurfBoostDesc(prefab)
    local name = nil
    if prefab.prefab == "turf_woodfloor" then 
        name = "wooden"        
    elseif prefab.prefab == "turf_carpetfloor" then
        name = "carpet"
    elseif prefab.prefab == "turf_checkerfloor" then
        name = "checker"
    end
    if name == nil then return end

    if prefab.components.insulator then
        if prefab.components.insulator.insulation then
            prefab.components.insulator.insulation = prefab.components.insulator.insulation + GetModConfigData("insulation_time_"..name)
        else
            prefab.components.insulator.insulation = GetModConfigData("insulation_time_"..name)
        end
    else
        prefab:AddComponent("insulator") -- add insulator (thanks IvanX) --  the insulator can have only one type, summer or winter, so we show the higher one in tooltip mods.
        if GetModConfigData("insulation_time_"..name) >= GetModConfigData("summer_insulation_time_"..name) then -- if summer and winter are the same, or winter is higher, show only the winter insulation
            prefab.components.insulator:SetInsulation(GetModConfigData("insulation_time_"..name)) -- default type is winter
        else
            prefab.components.insulator:SetInsulation(GetModConfigData("summer_insulation_time_"..name)) -- if summer insulation is higher, show the summer insulation
            prefab.components.insulator:SetSummer()
        end
    end
    
    local SanityList = {GLOBAL.TUNING.DAPPERNESS_TINY,GLOBAL.TUNING.DAPPERNESS_SMALL,GLOBAL.TUNING.DAPPERNESS_MED,GLOBAL.TUNING.DAPPERNESS_MED_LARGE,GLOBAL.TUNING.DAPPERNESS_LARGE}
    local plus = SanityList[GetModConfigData("sanity_boost_"..name)]
    if not plus then plus = 0 end
    if prefab.components.dapperness then
        if prefab.components.dapperness.dapperness then
            prefab.components.dapperness.dapperness = prefab.components.dapperness.dapperness +  plus
        else
            prefab.components.dapperness.dapperness = plus
        end
    else
        prefab.components.dapperness = {} -- ther is no components dapperness I think
        prefab.components.dapperness.dapperness = plus              -- sanity
    end
    
    if prefab.components.locomotor then -- speed, I think that won't be displayed at any tooltip mod, because an item normally is not able to run... we could add components equipable, but of course we don't want anyone to equip it
        prefab.components.locomotor:SetExternalSpeedMultiplier(prefab,"Carpet_Speed_display_"..name,GetModConfigData("speed_mult_"..name))
    else
        prefab:AddComponent("locomotor")
        prefab.components.locomotor:SetExternalSpeedMultiplier(prefab,"Carpet_Speed_display_"..name,GetModConfigData("speed_mult_"..name))
    end
    
    if prefab.components.waterproofer then
        if prefab.components.waterproofer.effectiveness then
            prefab.components.waterproofer.effectiveness = prefab.components.waterproofer.effectiveness + (1-GetModConfigData("rain_reduction_"..name))
        else
            prefab.components.waterproofer.effectiveness = 1-GetModConfigData("rain_reduction_"..name)
        end
    else
        prefab:AddComponent("waterproofer")
        prefab.components.waterproofer:SetEffectiveness(1-GetModConfigData("rain_reduction_"..name))
    end
    
    if prefab.components.weapon then
        if prefab.components.weapon.damage then
            prefab.components.weapon.damage = prefab.components.weapon.damage + GetModConfigData("damage_"..name)
        else
            prefab.components.weapon.damage = GetModConfigData("damage_"..name)
        end
    else
        prefab:AddComponent("weapon")
        prefab.components.weapon:SetDamage(GetModConfigData("damage_"..name))
    end
    
    if prefab.components.armor then
        if prefab.components.armor.absorb_percent then
            prefab.components.armor.absorb_percent = prefab.components.armor.absorb_percent + GetModConfigData("absorb_"..name)
        else
            prefab.components.armor.absorb_percent = GetModConfigData("absorb_"..name)
        end
    else
        prefab:AddComponent("armor")
        prefab.components.armor:SetAbsorption(GetModConfigData("absorb_"..name))
    end
    
    
end
AddPrefabPostInit("turf_woodfloor", TurfBoostDesc) 
AddPrefabPostInit("turf_carpetfloor", TurfBoostDesc)
AddPrefabPostInit("turf_checkerfloor", TurfBoostDesc)
--]]
local _G = GLOBAL

local function AddPrefabDescriptors() -- tooltips for Insight Mod
    if _G.rawget(_G,"Insight") and _G.Insight~=nil then
        for _,prefab in ipairs{"turf_woodfloor","turf_carpetfloor","turf_checkerfloor"} do
            _G.Insight.prefab_descriptors[prefab] = {
                Describe = function(inst, context)
                    
                    
                    local description = ""
                    local str = nil
                    local name = nil
                    if inst.prefab == "turf_woodfloor" then 
                        name = "wooden"        
                    elseif inst.prefab == "turf_carpetfloor" then
                        name = "carpet"
                    elseif inst.prefab == "turf_checkerfloor" then
                        name = "checker"
                    end
                    
                    -- damagemult
                    local damagemult = GetModConfigData("damage_"..name)
                    if damagemult~=nil and damagemult>0 and type(context.lstr.weapon_damage)=="string" and type(context.lstr.weapon_damage_type.normal)=="string" then
                        -- description = description.."DamageMult: *"..tostring(round2(damagemult,2)).."\n"
                        description = description..string.format(context.lstr.weapon_damage, context.lstr.weapon_damage_type.normal, "*"..tostring(damagemult)).."\n"
                        
                    end
                    -- insulation
                    local season,insulation
                    if GetModConfigData("insulation_time_"..name) >= GetModConfigData("summer_insulation_time_"..name) then -- if summer and winter are the same, or winter is higher, show only the winter insulation
                        insulation = GetModConfigData("insulation_time_"..name) -- default type is winter
                        season = "WINTER"
                    else -- if summer insulation is higher, show the summer insulation
                        insulation = GetModConfigData("summer_insulation_time_"..name) 
                        season = "SUMMER"
                    end
                    if insulation~=nil and insulation>0 then
                        str = (season:lower() == "winter" and context.lstr.insulation_winter) or (season:lower() == "summer" and context.lstr.insulation_summer) or "?"
                        description = description..string.format(str, insulation).."\n"
                    end
                    -- armor
                    local armor = GetModConfigData("absorb_"..name)
                    if armor~=nil and armor>0 and type(context.lstr.protection)=="string" then
                        description = description..string.format(context.lstr.protection, armor * 100).."\n"
                    end
                    -- rain_reduction_
                    local waterproof = 1-GetModConfigData("rain_reduction_"..name)
                    if waterproof~=nil and waterproof>0 and type(context.lstr.waterproofness)=="string" then
                        description = description..string.format(context.lstr.waterproofness, waterproof * 100).."\n"
                    end
                    -- sanityboost
                    local SanityList = {GLOBAL.TUNING.DAPPERNESS_TINY,GLOBAL.TUNING.DAPPERNESS_SMALL,GLOBAL.TUNING.DAPPERNESS_MED,GLOBAL.TUNING.DAPPERNESS_MED_LARGE,GLOBAL.TUNING.DAPPERNESS_LARGE}
                    local plus = SanityList[GetModConfigData("sanity_boost_"..name)]
                    if plus~=nil and plus>0 and context.lstr.sanityaura and type(context.lstr.sanityaura.aura_value)=="string" then
                        description = description..string.format(context.lstr.sanityaura.aura_value, round2(plus,3)).."\n"
                    end
                    -- speedmult
                    local speed = GetModConfigData("speed_mult_"..name)
                    if speed~=nil and speed>0 then
                        description = description.."SpeedMult: *"..tostring(round2(speed,2)).."\n"
                    end
                    
                    return {
                        priority = 0,
                        description = description
                    }
                end
            }
        end
    end
end
AddSimPostInit(AddPrefabDescriptors) -- tooltips for Insight Mod


-- ########## Now the bonusses itself
-- Gives insulation for Winter, insulation for Summer
-- Winter insulation delays freezing, Summer insulation delays overheating
-- The closer to 0, the quicker the freezing/overheating comes
if GetModConfigData("insulation_time_carpet")~=0 or GetModConfigData("insulation_time_wooden")~=0 or GetModConfigData("insulation_time_checker")~=0 or GetModConfigData("summer_insulation_time_checker")~=0 or GetModConfigData("summer_insulation_time_checker")~=0 or GetModConfigData("summer_insulation_time_checker")~=0 then
    AddComponentPostInit("temperature", function(self)
        local _GetInsulation = self.GetInsulation
        self.GetInsulation = function(self,...)
            local winterInsulation, summerInsulation = _GetInsulation(self,...) -- get the original return from the old fct and change it
            if self.inst:HasTag("player") then 
                local cachedinst = UpdateorGet(self.inst,"insulation") -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                local tile = cachedinst["coordinates"][1][4]
                local isbase = cachedinst["base"][1]
                if not (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then -- if not on a floor, hide the base icon
                    OnBaseBonus(self.inst,false)
                end
                if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) and (GetModConfigData("insulation_time_carpet")~=0 or GetModConfigData("summer_insulation_time_carpet")~=0)) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) and (GetModConfigData("insulation_time_wooden")~=0 or GetModConfigData("summer_insulation_time_wooden")~=0)) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) and (GetModConfigData("insulation_time_checker")~=0 or GetModConfigData("summer_insulation_time_checker")~=0)) then
                    if GetModConfigData("base_required_insulation")==0 or isbase then -- give bonus if no base is required or if there is a base
                        if table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) then
                            winterInsulation = winterInsulation + GetModConfigData("insulation_time_carpet")
                            summerInsulation = summerInsulation + GetModConfigData("summer_insulation_time_carpet")
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) then
                            winterInsulation = winterInsulation + GetModConfigData("insulation_time_wooden")
                            summerInsulation = summerInsulation + GetModConfigData("summer_insulation_time_wooden")
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) then
                            winterInsulation = winterInsulation + GetModConfigData("insulation_time_checker")
                            summerInsulation = summerInsulation + GetModConfigData("summer_insulation_time_checker")
                        end
                    end
                end
            end
            return mymathmax(0, winterInsulation), mymathmax(0, summerInsulation)
        end
    end)
end

-- Standing on a carpet is like wearing a top hat 
if GetModConfigData("sanity_boost_carpet")~=0 or GetModConfigData("sanity_boost_wooden")~=0 or GetModConfigData("sanity_boost_checker")~=0 then
    AddPlayerPostInit(function(inst)
        if inst.components.sanity and inst:HasTag("player") then -- I think it can't be not-player
            local _crfn = inst.components.sanity.custom_rate_fn
            inst.components.sanity.custom_rate_fn = function(inst,...)
                local ret = 0
                if _crfn then
                    ret = _crfn(inst,...)
                end
                local cachedinst = UpdateorGet(inst,"sanity") -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                local tile = cachedinst["coordinates"][1][4]
                local isbase = cachedinst["base"][1]
                if not (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then-- if not on a floor, hide the base icon
                    OnBaseBonus(inst,false)
                end
                if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) and GetModConfigData("sanity_boost_carpet")~=0) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) and GetModConfigData("sanity_boost_wooden")~=0) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) and GetModConfigData("sanity_boost_checker")~=0) then
                    if GetModConfigData("base_required_sanity")==0 or isbase then -- give bonus if no base is required or if there is a base
                        local SanityList = {GLOBAL.TUNING.DAPPERNESS_TINY,GLOBAL.TUNING.DAPPERNESS_SMALL,GLOBAL.TUNING.DAPPERNESS_MED,GLOBAL.TUNING.DAPPERNESS_MED_LARGE,GLOBAL.TUNING.DAPPERNESS_LARGE}
                        if table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) and GetModConfigData("sanity_boost_carpet")~=0 then
                            ret = ret + SanityList[GetModConfigData("sanity_boost_carpet")] -- 1 for Tiny, 5 for Large.... Medium gives +3
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) and GetModConfigData("sanity_boost_wooden")~=0 then
                            ret = ret + SanityList[GetModConfigData("sanity_boost_wooden")]
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) and GetModConfigData("sanity_boost_checker")~=0 then
                            ret = ret + SanityList[GetModConfigData("sanity_boost_checker")]
                        end
                    end
                end
                return ret
            end
        end
    end)
end


local easing = GLOBAL.require("easing")
-- seperated drying code, I could make a standalone mod with that... moisturerate for fire
if GetModConfigData("hot_dry_fire")==1 then
    AddComponentPostInit("moisture", function(self)
        local _GetMoistureRate = self.GetMoistureRate -- max is 0.75
        self.GetMoistureRate = function(self,...)
            local MostuRate = easing.inSine(GLOBAL.TheWorld.state.precipitationrate, self.minMoistureRate, self.maxMoistureRate, 1) -- this is rate before other bonuses like clothes
            local MostuRateOriginal = _GetMoistureRate(self,...) -- this already contains reduction from eg. hats and so on
            local previousbonus = MostuRateOriginal / MostuRate -- e.g if with bonus is 0.2, while without bonus it is 0.4 the previousbonus would be 0.5. So at the end, multiply the result with 0.5
            if MostuRateOriginal>0 then -- only check it, if object is getting wet
                if GetModConfigData("hot_dry_fire")==1 then
                    local cachedinst = UpdateorGet(self.inst,"rain") -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                    local heat = cachedinst["heat"][1]
                    local heaterPower = mymathmin(1500,heat * GetModConfigData("hot_dry_fire")) -- moisture is for player only and player has alawys temperature
                    local rate = self.baseDryingRate -- normally 0
                        + heaterPower -- 0 to 150 ? -- at least 115 near a big firepit fire, but they sum up, so 10 fires will be 1150 and a forest fire will be more than 1500, but we will max it with 1500
                        - self:GetMoisture()/2 -- 0 to 50
                    local dryrate = mymathclamp(rate, 0, 1500) -- between 0 and 1500
                    dryrate = dryrate / 2400 -- between 0 and 0.625, with a normal fire it will be ~0.05
                    if dryrate > 0.001 then -- if less, no need to reduce...
                        MostuRate = mymathclamp(MostuRate - dryrate,0,MostuRate) -- reduced MostuRate, so in fact any warm thing can reduce moisture rate up to an absolut value of ~0.1
                    end
                    -- if GLOBAL.GetRandomMinMax(0,1)>0.99 and heaterPower>0 then print("fire moisturerate heaterPower: "..heaterPower.." previousbonus: "..previousbonus) end
                end
                MostuRate = MostuRate*previousbonus -- apply the bonus from clothes and so on, after we reduced the absolute fire value! (otherwise fire would reduce it too 0 very often, if we wear something eg. 90% rainproof)
                return mymathmax(0,MostuRate) 
            end
            return _GetMoistureRate(self,...)
        end
    end)
end

-- moisturerate for floor. This changes the same function like fire moisturerate, but it is added after that, so these changes are done after the fire bonus is applied.
if GetModConfigData("rain_reduction_wooden") ~= 1 or GetModConfigData("rain_reduction_checker")~= 1 or GetModConfigData("rain_reduction_carpet")~= 1 then
    AddComponentPostInit("moisture", function(self) -- obviously moisture is used for players only, not for buildings and items
        local _GetMoistureRate = self.GetMoistureRate -- max is 0.75
        self.GetMoistureRate = function(self,...)
            local MostuRate = _GetMoistureRate(self,...) -- this is now the value the fire moisturerate code returns, if that option is active
            if MostuRate>0 then -- only check it, if object is getting wet
                local cachedinst = UpdateorGet(self.inst,"rain") -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                local tile = cachedinst["coordinates"][1][4]
                local isbase = cachedinst["base"][1]
                if not (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then -- if not on a floor, hide the base icon
                    OnBaseBonus(self.inst,false)
                end
                if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) and GetModConfigData("rain_reduction_carpet")~=1) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) and GetModConfigData("rain_reduction_wooden")~=1) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) and GetModConfigData("rain_reduction_checker")~=1) then
                    if GetModConfigData("base_required_rainproof")==0 or isbase then -- give bonus if no base is required or if there is a base
                        if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile)) then
                            MostuRate = MostuRate*GetModConfigData("rain_reduction_carpet")
                        elseif (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile)) then
                            MostuRate = MostuRate*GetModConfigData("rain_reduction_wooden")
                        elseif (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then
                            MostuRate = MostuRate*GetModConfigData("rain_reduction_checker")
                        end
                    end
                end
                if MostuRate < 0.01 then MostuRate = 0 end -- if it is very low, reduce it to 0, cause otherwise drying won't happen, even if it is reduced 99.99%
            end
            if self.inst:HasTag("player") and GetModConfigData("show_mrate")==1 then
                self.inst.MRate:set(mymathmax(0,MostuRate)) -- send moistureRate to clients, to show it as tooltip of misturemeter
            end
            return mymathmax(0,MostuRate)
        end
    end)
end

-- items get the wetness of the player. this mod decreases the speed the items adjust to the wetness of player if player is more wet. and increase this speed if player is more dry.., if in range of heat.
if GetModConfigData("hot_dry_fire")==1 or GetModConfigData("rain_reduction_wooden") ~= 1 or GetModConfigData("rain_reduction_checker")~= 1 or GetModConfigData("rain_reduction_carpet")~= 1 then 
    AddComponentPostInit("inventoryitemmoisture", function(self)
        self.oldwetRmulti = 1 -- to undo last change, to make it compatible to game or mod changes to this
        local _GetTargetMoisture = self.GetTargetMoisture  
        self.GetTargetMoisture = function(self,...) -- change resistance and modify targetmoisture
            
            if self.inst==nil or not self.inst:IsValid() then--self.inst:IsInLimbo() then  -- limbo is for items in inventory! so it is important
                return _GetTargetMoisture(self,...)
            end     
            local printen = false
            local multi = 1 --
            local heaterPower = 0   
            local tilebonus = 0
            local activetiledata = nil
            if self.inst:GetIsWet() or (GLOBAL.TheWorld.state.wetness~=0 and GLOBAL.TheWorld.state.wetness~=nil) then -- if item is not wet and also no world wetness, we dont need to make anything    
                local cachedinst = UpdateorGet(self.inst,"rain") -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                local tile = cachedinst["coordinates"][1][4]
                local isbase = cachedinst["base"][1]
                local heat = cachedinst["heat"][1]
                if GetModConfigData("hot_dry_fire")==1 then
                    heaterPower = mymathmin(1500,heat * GetModConfigData("hot_dry_fire")) -- items and animals have no components temperature?
                    local rate = heaterPower -- 0 to 150 ? -- at least 115 near a big firepit fire, but they sum up, so 10 fires will be 1150 and a forest fire will be more than 1500, but we will max it with 1500
                    multi = mymathmin(15,(60 + rate) / 60) -- between 1 and 15.  at a big firepit it is 3 
                end
                if GetModConfigData("rain_reduction_wooden") ~= 1 or GetModConfigData("rain_reduction_checker")~= 1 or GetModConfigData("rain_reduction_carpet")~= 1 then
                    if GetModConfigData("base_required_rainproof")==0 or isbase then -- can use the rain str for players, 
                        if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile)) then
                            multi = multi + 0.02*((1-GetModConfigData("rain_reduction_carpet"))*100) -- since this is the drying rate, home won't boost it much (best without fire is multiply with 3). fire is better, since a normal fire will multiply it also with 3 
                            tilebonus = 0.02*((1-GetModConfigData("rain_reduction_carpet"))*100)
                            activetiledata = GetModConfigData("rain_reduction_carpet")
                        elseif (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile)) then
                            multi = multi + 0.02*((1-GetModConfigData("rain_reduction_wooden"))*100)
                            tilebonus = 0.02*((1-GetModConfigData("rain_reduction_wooden"))*100)
                            activetiledata = GetModConfigData("rain_reduction_wooden")
                        elseif (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then
                            multi = multi + 0.02*((1-GetModConfigData("rain_reduction_checker"))*100)  
                            tilebonus = 0.02*((1-GetModConfigData("rain_reduction_checker"))*100)
                            activetiledata = GetModConfigData("rain_reduction_checker")
                        end
                    end
                end
                if not no_drywetResistance then
                    self.inst.components.inventoryitemmoisture.wetnessResistance = (self.inst.components.inventoryitemmoisture.wetnessResistance / self.oldwetRmulti) * multi -- default is 1, is not changed by the game itself yet, but maybe by other mods..
                    self.inst.components.inventoryitemmoisture.dryingResistance = (self.inst.components.inventoryitemmoisture.dryingResistance / self.oldwetRmulti) * multi
                    self.oldwetRmulti = multi
                end
            else
                return _GetTargetMoisture(self,...)
            end
            -- if not no_drywetResistance and GLOBAL.GetRandomMinMax(0,1)>0.99 and self.inst.components.inventoryitemmoisture.wetnessResistance>1 and self.inst.components.inventoryitemmoisture.dryingResistance>1 then
                -- printen = true
            -- end
            if printen and not no_drywetResistance then
                print("itemmoisture, worldwetness: "..GLOBAL.TheWorld.state.wetness.." wetnessResistance: "..self.inst.components.inventoryitemmoisture.wetnessResistance.." dryingResistance: "..self.inst.components.inventoryitemmoisture.dryingResistance.." heaterPower: "..heaterPower.." multi: "..multi.." tilebonus: "..tilebonus)
                print(self.inst)
            end
            local owner = self.inst.components.inventoryitem.owner
            if owner~=nil or not GLOBAL.TheWorld.state.israining then
                if printen then print("______________") end
                return _GetTargetMoisture(self,...) -- if we have an owner, we just return the normal stuff, we don't want to change this. if it is not raining, the worldwetness does not matter, the orignal function will return 0
            else -- otherwise we would return the world wetness. But now we want to modify this
                local multiplier = 1
                if activetiledata~=nil then
                    multiplier = multiplier * activetiledata -- if rainreduction is 100%, all items will change moisture with their speed to 0
                end
                if heaterPower~=nil then
                    multiplier = multiplier * mymathmax(0,1-(heaterPower/700)) -- if fire heat is 700, all items near it will change moisture with their speed to 0, regardless of wetness. 
                end
                if printen then 
                    print("itemmoisture, es wird angestrebt: "..GLOBAL.TheWorld.state.wetness * multiplier)
                    print("______________") 
                end
                return GLOBAL.TheWorld.state.wetness * multiplier
            end
            return _GetTargetMoisture(self,...) -- just in case, but should not happen 
        end
    end)
end

-- speed
if GetModConfigData("speed_mult_wooden") ~= 1 or GetModConfigData("speed_mult_checker")~= 1 or GetModConfigData("speed_mult_carpet")~= 1 then
    AddComponentPostInit("locomotor", function(self)
        if self.inst:HasTag("player") then 
            local _UGSM = self.UpdateGroundSpeedMultiplier
            self.UpdateGroundSpeedMultiplier = function(self,...)
                _UGSM(self,...)
                local cachedinst = UpdateorGet(self.inst,"speed") -- returns a table like this {["base"]={false,0},["heat"]={0,0},["coordinates"]={{nil,nil,nil,nil},0}} 
                local tile = cachedinst["coordinates"][1][4]
                local isbase = cachedinst["base"][1]
                if not (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) or table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile)) then -- if not on a floor, hide the base icon
                    OnBaseBonus(self.inst,false)
                end
                if (table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) and GetModConfigData("speed_mult_carpet")~=1) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) and GetModConfigData("speed_mult_wooden")~=1) or (table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) and GetModConfigData("speed_mult_checker")~=1) then
                    if GetModConfigData("base_required_speed")==0 or isbase then -- give bonus if no base is required or if there is a base
                        if table.contains(GLOBAL.TUNING.HOMEBASEMOD.CARPET_FLOORS,tile) then
                            if self.carpetfast == nil or self.carpetfast~="speed_mult_carpet" then
                                self:SetExternalSpeedMultiplier(self.inst, "CarpetSpeed", GetModConfigData("speed_mult_carpet"))
                                self.carpetfast = "speed_mult_carpet"
                                -- print("external speed "..tostring(self.carpetfast).." set to: "..tostring(self:GetExternalSpeedMultiplier(self.inst, "CarpetSpeed")))
                            end
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.WOODEN_FLOORS,tile) then
                            if self.carpetfast == nil or self.carpetfast~="speed_mult_wooden" then
                                self:SetExternalSpeedMultiplier(self.inst, "CarpetSpeed", GetModConfigData("speed_mult_wooden"))
                                self.carpetfast = "speed_mult_wooden"
                                -- print("external speed "..tostring(self.carpetfast).." set to: "..tostring(self:GetExternalSpeedMultiplier(self.inst, "CarpetSpeed")))
                            end
                        elseif table.contains(GLOBAL.TUNING.HOMEBASEMOD.MARBLE_FLOORS,tile) then
                            if self.carpetfast == nil or self.carpetfast~="speed_mult_checker" then
                                self:SetExternalSpeedMultiplier(self.inst, "CarpetSpeed", GetModConfigData("speed_mult_checker"))
                                self.carpetfast = "speed_mult_checker"
                                -- print("external speed "..tostring(self.carpetfast).." set to: "..tostring(self:GetExternalSpeedMultiplier(self.inst, "CarpetSpeed")))
                            end
                        else
                            if self.carpetfast ~= nil then
                                self:RemoveExternalSpeedMultiplier(self.inst, "CarpetSpeed")
                                self.carpetfast = nil
                            end
                        end
                    else
                        if self.carpetfast ~= nil then
                            self:RemoveExternalSpeedMultiplier(self.inst, "CarpetSpeed")
                            self.carpetfast = nil
                        end
                    end
                else
                    if self.carpetfast ~= nil then
                        self:RemoveExternalSpeedMultiplier(self.inst, "CarpetSpeed")
                        self.carpetfast = nil
                    end
                end
            end
        end
    end)
end

-- in data/scripts/modutil.lua are all intersting functions for mods

-- local function DoBonus(inst) -- this is for blinking
    -- inst.AnimState:SetMultColour(1,.25,0,1)
    -- inst:DoTaskInTime((1/2 *.5), function(inst) inst.AnimState:SetMultColour(1,1,1,1) end)
-- end

-- local thing = condition and if_true or if_false   -- is the same like

-- local thing = nil
-- if condition and if_true then 
    -- thing = if_true
-- else
    -- thing = if_false
-- end
