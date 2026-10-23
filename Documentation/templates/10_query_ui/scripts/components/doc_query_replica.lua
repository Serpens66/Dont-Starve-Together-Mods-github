local Query = Class(function(self, inst)
    self.inst = inst
    self.reply = net_string(inst.GUID, "doc_query.reply", "doc_query_dirty")
    inst:ListenForEvent("doc_query_dirty", function()
        inst:PushEvent("doc_query_updated")
    end)
end)
function Query:GetReply() return self.reply:value() end
function Query:SetReply(value)
    if TheWorld.ismastersim then
        self.reply:set(value)
        -- Host-HUD reagiert direkt; entfernte Clients benutzen das Dirty-Event.
        self.inst:PushEvent("doc_query_updated")
    end
end
return Query
