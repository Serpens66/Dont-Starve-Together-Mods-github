local Counter = Class(function(self, inst)
    self.inst = inst
end)

function Counter:GetCount()
    -- The client has no gameplay component; read the replicated public state.
    return self.inst._doc_count:value()
end

return Counter
