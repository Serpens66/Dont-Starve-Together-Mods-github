local FoodHistory = Class(function(self, inst)
    self.inst = inst
    self.history = {}
    self.active = true
    self.eater = inst.components.eater
    self.oldfn = self.eater.custom_stats_mod_fn
    self.wrapper = function(player, health, hunger, sanity, food, feeder)
        if self.oldfn ~= nil then
            health, hunger, sanity = self.oldfn(player, health, hunger, sanity, food, feeder)
        end
        -- Ein fremder Wrapper kann diese Closure auch nach RemoveComponent behalten.
        if not self.active then return health, hunger, sanity end
        local repeated = false
        for _, name in ipairs(self.history) do
            if food ~= nil and name == food.prefab then repeated = true; break end
        end
        -- Negative Wirkungen bleiben erhalten; das Event kommt erst nach den Deltas.
        if repeated then
            if health > 0 then health = health * .5 end
            if hunger > 0 then hunger = hunger * .5 end
            if sanity > 0 then sanity = sanity * .5 end
        end
        return health, hunger, sanity
    end
    self.eater.custom_stats_mod_fn = self.wrapper
    self.oneat = function(_, data)
        local name = data ~= nil and data.food ~= nil and data.food.prefab or nil
        if type(name) ~= "string" then return end
        for i = #self.history, 1, -1 do
            if self.history[i] == name then table.remove(self.history, i) end
        end
        table.insert(self.history, 1, name)
        if #self.history > 3 then table.remove(self.history) end
    end
    inst:ListenForEvent("oneat", self.oneat)
end)
function FoodHistory:OnSave()
    return { version = 1, history = self.history }
end
function FoodHistory:OnLoad(data)
    self.history = {}
    if type(data) ~= "table" or data.version ~= 1 or type(data.history) ~= "table" then return end
    for _, name in ipairs(data.history) do
        if type(name) == "string" and #name <= 128 then
            local found = false
            for _, existing in ipairs(self.history) do if existing == name then found = true end end
            if not found then table.insert(self.history, name) end
            if #self.history == 3 then break end
        end
    end
end
function FoodHistory:OnRemoveFromEntity()
    self.active = false
    self.inst:RemoveEventCallback("oneat", self.oneat)
    -- Eine später installierte fremde Funktion nicht entfernen.
    if self.eater.custom_stats_mod_fn == self.wrapper then self.eater.custom_stats_mod_fn = self.oldfn end
end
return FoodHistory
