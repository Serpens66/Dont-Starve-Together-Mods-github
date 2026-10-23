local Counter = Class(function(self, inst)
    self.inst = inst
    self.count = 0
    self:SetCount(0)
end)

function Counter:SetCount(value)
    if type(value) ~= "number" or value ~= value then
        return false
    end
    self.count = math.floor(math.max(0, math.min(65535, value)))
    -- The prefab declares this netvar on every peer before SetPristine.
    self.inst._doc_count:set(self.count)
    return true
end

function Counter:GetCount()
    return self.count
end

function Counter:OnSave()
    return { version = 1, count = self.count }
end

function Counter:OnLoad(data)
    if data ~= nil and (data.version == nil or data.version == 1) then
        self:SetCount(data.count or 0)
    end
end

return Counter
