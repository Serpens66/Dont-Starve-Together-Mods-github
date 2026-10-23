local Markable = Class(function(self, inst)
    self.inst = inst
    self.marked = false
end)

function Markable:Mark()
    if self.marked then
        return false
    end
    self.marked = true
    self.inst:AddTag("doc_marked")
    print("[DocMark] marked chest:", self.inst.GUID)
    return true
end

function Markable:OnSave()
    return { version = 1, marked = self.marked }
end

function Markable:OnLoad(data)
    if data ~= nil and data.marked == true then
        self:Mark()
    end
end

return Markable
