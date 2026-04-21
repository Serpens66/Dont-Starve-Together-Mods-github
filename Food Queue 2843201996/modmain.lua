local require = GLOBAL.require
AddReplicableComponent("_foodbuffer")

Assets = {
  Asset("ANIM" , "anim/foodbuffer.zip")
}

-- TODO:
-- wilson comüonent nicht geben und gucken ob UI weg belbit
-- insight mod anzeige fuer _foodbuffer zufuegen, zb akzuelle position anzeigen

local disabled = {
  "gears",
  "nightmarepie"
}

local foodmults = { GetModConfigData("6"), GetModConfigData("5"), GetModConfigData("4"), GetModConfigData("3"), GetModConfigData("2"), GetModConfigData("1") }

local handle_favorite = GetModConfigData("handle_favorite")
local reduce_negative = GetModConfigData("reduce_negative")
local replace_foodmemory = GetModConfigData("replace_foodmemory")
local affect_modchars = GetModConfigData("affect_modchars")
GLOBAL.TUNING.FOODQUEUE_MOD_BASEFOOD = GetModConfigData("basefood")
local NoCheaseValue = GetModConfigData("NoCheaseValue")

AddPlayerPostInit(function (inst)
    if inst ~= nil and inst.components.eater ~= nil then
        if not affect_modchars and GLOBAL.table.contains(GLOBAL.MODCHARACTERLIST,inst.prefab) then
            return -- then dont change mod-characters
        end
        
        if inst.components.foodmemory and replace_foodmemory then
            inst:RemoveComponent("foodmemory") -- may cause other mods crash if they rely on it. therefore it is disabled by default
        end
        if not inst.components.foodmemory and not inst.components.eater.custom_stats_mod_fn then  -- do not change chars with foodmemory like warly or ones that already have a custom_stats_mod_fn
            local favorites = {}
            
            if inst.components.foodaffinity ~= nil then
                for prefab,bonus in pairs(inst.components.foodaffinity.prefab_affinities) do
                    if bonus > 1 then -- only food with bonus > 1 can be a "favorite" (but any value removes negative sanity/health effects from food, so this is only intended as "bonus" and never as "debuff"...)
                        table.insert(favorites,prefab)
                    end
                end
                if string.find(handle_favorite,"defhunger")~=nil then -- if we want to remove the favorite hunger bonus
                    for _,prefab in ipairs(favorites) do
                        inst.components.foodaffinity:AddPrefabAffinity(prefab,1) -- instead of removing, we set the bonus to 1. this way the hungervalue is not increased, but you still don't get the negative health/sanity.
                    end
                    ---------- not sure if we also should call TagAffinity or FoodtypeAffinity... I think it is fine without, because eg wurt should still get more from any veggie
                end
            end
            
            inst:AddComponent("_foodbuffer")
            if inst.components._foodbuffer ~= nil then
                if string.find(handle_favorite,"noqueue")~=nil then -- then we want favorites to be handled like any other food
                    inst.components._foodbuffer:SetFavorites(favorites)
                end
                inst.components._foodbuffer:SetMultipliers(foodmults)
                inst.components._foodbuffer:SetDisabled(disabled)
            end
            
            inst:ListenForEvent("oneat",function(inst,data)
                if inst.components._foodbuffer ~= nil then
                    if data~=nil and type(data)=="table" and data.food~=nil then -- also contains data.feeder
                        if NoCheaseValue~=false and data.food.components~=nil and data.food.components.edible~=nil then -- then only add food to queue that has a minimum value
                            -- dont provide eater to the edible functions to make sure custom_stats_mod_fn is not taken into account, so we compare the default food values.
                            if data.food.components.edible:GetHunger(nil)>=NoCheaseValue or data.food.components.edible:GetSanity(nil)>=NoCheaseValue or data.food.components.edible:GetHealth(nil)>=NoCheaseValue then
                                inst.components._foodbuffer:AddToBuffer(data.food) -- at least one default value must be >= NoCheaseValue, only then count it to the queue. this prevents eg eating flowers/ice to go into the queue
                            end
                        else
                            inst.components._foodbuffer:AddToBuffer(data.food)
                        end
                    end
                end
            end)
            
            
            inst.components.eater.custom_stats_mod_fn = function (inst, health_delta, hunger_delta, sanity_delta, food, feeder)
                if inst.components._foodbuffer ~= nil then
                    local protected = inst.components._foodbuffer:IsProtected(food)
                    if protected ~= true then
                        local mult = inst.components._foodbuffer:GetMultiplier(food)
                        if hunger_delta >= 0 or reduce_negative then hunger_delta = mult * hunger_delta end
                        if health_delta >= 0 or reduce_negative then health_delta = mult * health_delta end
                        if sanity_delta >= 0 or reduce_negative then sanity_delta = mult * sanity_delta end
                    end
                end
                return health_delta, hunger_delta, sanity_delta
            end
        end
    end
end)


if not GetModConfigData("hide_widget") then
    local FoodBufferWidget = require "widgets/foodbuffer"
    AddClassPostConstruct("widgets/inventorybar", function (self)
      self.owner:DoTaskInTime(0, function (inst)
        if inst ~= nil and (inst.replica~=nil and inst.replica._foodbuffer~=nil) then
          self.buffer = self:AddChild(FoodBufferWidget(inst))
        end
      end)
    end)
end



-- ### Insight Tooltip support for the queue

local _G = GLOBAL
local function AddDescriptors()
	if not _G.rawget(_G, "Insight") then return end
	local oldDescribe = nil
    if _G.Insight.descriptors.edible==false then return end -- if it is false something went wrong in Insight so we can not change it, must be fixed within Insight
    if type(_G.Insight.descriptors.edible) == "table" then
        if _G.Insight.descriptors.edible.Describe then
            oldDescribe = _G.Insight.descriptors.edible.Describe
        end
    -- else
        -- _G.Insight.descriptors.edible = {} -- descriptors is a metatable that automatically creates an empty table when indexed and previously nil -> no need for this line
    end
    _G.Insight.descriptors.edible.Describe = function(self, context,...) -- context is background information about the player
        local my_description
        
        if self~=nil and self.inst~=nil and context~=nil and context.player~=nil
          and context.player.components~=nil and context.player.components._foodbuffer~=nil
          and context.player.components._foodbuffer.IsInBuffer~=nil
          and context.player.components._foodbuffer:IsInBuffer(self.inst)~=nil then
            my_description = "FoodQueue Pos: "..tostring(7-context.player.components._foodbuffer:IsInBuffer(self.inst)).." Mult: "..tostring(context.player.components._foodbuffer:GetMultiplier(self.inst))
        end
        
        if oldDescribe~=nil then -- if anyone already added a description, do not overwrite it, but add stuff to it
            local packed = _G.Insight.env.pack(oldDescribe(self, context, ...))
            local old_description = ""
            local old_alt_description = ""
            if my_description~=nil then
                for i,v in ipairs(packed) do
                    if v and v.name == "edible" then
                        old_description = v.description or ""
                        old_alt_description = v.alt_description or ""
                        -- v.description = old_description.."\n"..my_description -- append our new description
                        v.alt_description = old_alt_description.."\n"..my_description -- append our new description to detailed info
                        break
                    end
                end
            end
            return _G.Insight.env.vararg(packed)
        else
            return {
                name = "edible",
                priority = 10,
                -- description = my_description
                alt_description = my_description -- detailed info only shwon when holding shift
            }
        end
    end
end
AddSimPostInit(AddDescriptors)  -- tooltips for Insight Mod






