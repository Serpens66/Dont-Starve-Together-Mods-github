
local CombineRepairable = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("combinerepairable")
end,
nil,
{})

function CombineRepairable:OnRemoveFromEntity()
    self.inst:RemoveTag("combinerepairable")
end

function CombineRepairable:Repair(doer, repair_item)
    -- print("Repair Combine: repare "..tostring(self.inst.prefab).." with "..tostring(repair_item.prefab))
    if repair_item==nil or self.inst==nil or not repair_item:IsValid() or not self.inst:IsValid() or self.inst.prefab ~= repair_item.prefab then
        return false
    end
    local actualbonus = TUNING.REPAIRCOMBINE_bonus
    if actualbonus == 0.05 then
        actualbonus = math.random(6)-1 -- between 0 and 5
    elseif actualbonus==0.1 then
        actualbonus = math.random(11)-1 -- between 0 and 10
    elseif actualbonus == -0.05 then
        actualbonus = -(math.random(6)-1) -- between 0 and -5
    elseif actualbonus == -0.15 then
        actualbonus = math.random(16)-1-5 -- between -5 and 10
    elseif actualbonus == -0.55 then
        actualbonus = math.random(11)-1-5 -- between -5 and 5
    end
    actualbonus = actualbonus/100
    local divide = 1
    local new_current,new_percent
    if self.inst.components.stackable ~= nil then
        divide = math.max(1,self.inst.components.stackable:StackSize()) -- if the item we want to repair is a stack, then make the repair less efficient, depending on the stacksize
        -- there are only vanilla perishable items with stacks and they all loose freshness at the same rate all at once.
        -- there are no stacks for the other components and if it is added some day, it heavily depends how it is implemented
         -- since they for sure wont loose uses all at once at the same time.. so do not add divide to the other components for now and only add it after it was maybe implemented (but no need for it with combine mod anyways)
    end
    if self.inst.components.finiteuses~=nil and repair_item.components.finiteuses~=nil then
        if TUNING.REPAIRCOMBINE_overmaxfiniteuses then
            -- old code
            -- self.inst.components.finiteuses:SetMaxUses(self.inst.components.finiteuses.total*divide + repair_item.components.finiteuses.total)
            -- self.inst.components.finiteuses:SetUses(self.inst.components.finiteuses:GetUses()*divide + repair_item.components.finiteuses:GetUses())
            -- self.inst.components.finiteuses:SetUses(math.min(math.ceil(self.inst.components.finiteuses:GetUses() * (1+actualbonus)),self.inst.components.finiteuses.total))
            
            new_current = math.ceil((self.inst.components.finiteuses:GetUses() + repair_item.components.finiteuses:GetUses()) * (1+actualbonus))
             -- set the new max to the highest values of them and new_current. do it like this to be more in line with the way it works while REPAIRCOMBINE_overmaxfiniteuses is disabled for eg 40%+40% repair (so it results in both cases in 80%. Doing it like this is mostly important for perishables to still have a benefit in regards to the stale status) 
            self.inst.components.finiteuses:SetMaxUses(math.max(self.inst.components.finiteuses.total,repair_item.components.finiteuses.total,new_current))
            new_percent = new_current / self.inst.components.finiteuses.total
        else
            new_percent = math.max(math.min((repair_item.components.finiteuses:GetPercent() + self.inst.components.finiteuses:GetPercent())+actualbonus,TUNING.REPAIRCOMBINE_maxweapon),0.01)
        end
        self.inst.components.finiteuses:SetPercent(new_percent)
    elseif self.inst.components.armor~=nil and repair_item.components.armor~=nil then
        if TUNING.REPAIRCOMBINE_overmaxarmor then
            -- self.inst.components.armor.maxcondition = self.inst.components.armor.maxcondition*divide + repair_item.components.armor.maxcondition
            -- self.inst.components.armor:SetCondition(self.inst.components.armor.condition*divide + repair_item.components.armor.condition)
            -- self.inst.components.armor:SetCondition(math.min(math.ceil(self.inst.components.armor.condition * (1+actualbonus)),self.inst.components.armor.maxcondition))
        
            new_current = math.ceil((self.inst.components.armor.condition + repair_item.components.armor.condition) * (1+actualbonus))
            self.inst.components.armor.maxcondition = math.max(self.inst.components.armor.maxcondition,repair_item.components.armor.condition,new_current)
            new_percent = new_current / self.inst.components.armor.maxcondition
        else
            new_percent = math.max((repair_item.components.armor:GetPercent() + self.inst.components.armor:GetPercent())+actualbonus,0.01)
        end
        self.inst.components.armor:SetPercent(new_percent) -- a max of 100% is in component
    elseif self.inst.components.fueled~=nil and repair_item.components.fueled~=nil then
        if TUNING.REPAIRCOMBINE_overmaxfueled then
            -- self.inst.components.fueled.maxfuel = self.inst.components.fueled.maxfuel*divide + repair_item.components.fueled.maxfuel
            -- self.inst.components.fueled.currentfuel = self.inst.components.fueled.currentfuel*divide + repair_item.components.fueled.currentfuel
            -- self.inst.components.fueled.currentfuel = math.min(math.ceil(self.inst.components.fueled.currentfuel * (1+actualbonus)),self.inst.components.fueled.maxfuel)

            new_current = math.ceil((self.inst.components.fueled.currentfuel + repair_item.components.fueled.currentfuel) * (1+actualbonus))
            self.inst.components.fueled.maxfuel = math.max(self.inst.components.fueled.maxfuel , repair_item.components.fueled.maxfuel , new_current)
            new_percent = new_current / self.inst.components.fueled.maxfuel
        else
            new_percent = math.max((repair_item.components.fueled:GetPercent() + self.inst.components.fueled:GetPercent())+actualbonus,0.01)
        end
        self.inst.components.fueled:SetPercent(new_percent) -- a max of 100% is in component (if overmax is enabled, the max was already increased so the limitation of 100% is no problem)
    elseif self.inst.components.perishable~=nil and self.inst.components.equippable~=nil and repair_item.components.perishable~=nil and repair_item.components.equippable~=nil then
        if TUNING.REPAIRCOMBINE_overmaxperishable then
            -- self.inst.components.perishable.perishtime = self.inst.components.perishable.perishtime*divide + repair_item.components.perishable.perishtime
            -- self.inst.components.perishable.perishremainingtime = math.min(math.ceil((self.inst.components.perishable.perishremainingtime*divide + repair_item.components.perishable.perishremainingtime) * (1+actualbonus)),self.inst.components.perishable.perishtime)
            
            new_current = math.ceil((self.inst.components.perishable.perishremainingtime + repair_item.components.perishable.perishremainingtime/divide) * (1+actualbonus))
            self.inst.components.perishable.perishtime = math.max(self.inst.components.perishable.perishtime , repair_item.components.perishable.perishtime , new_current)
            new_percent = new_current / self.inst.components.perishable.perishtime
        else
            new_percent = math.max(((repair_item.components.perishable:GetPercent()/divide) + self.inst.components.perishable:GetPercent())+actualbonus,0.01) -- a max of 100% is in component
        end
        self.inst.components.perishable:SetPercent(new_percent)
    else
        return false
    end
    
    if TUNING.REPAIRCOMBINE_bonus~=0 then
        print("Repair Combine: Give repair bonus of "..tostring(actualbonus*100).."% to "..tostring(self.inst.prefab))
    end
    if repair_item.components.stackable ~= nil then
        repair_item.components.stackable:Get():Remove()
    else
        repair_item:Remove()
    end

    return true
end
return CombineRepairable
