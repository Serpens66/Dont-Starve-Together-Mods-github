local G = GLOBAL
PrefabFiles = { "doc_counter_token" }
AddReplicableComponent("doc_counter")
G.STRINGS.NAMES.DOC_COUNTER_TOKEN = "Zaehler-Token"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DOC_COUNTER_TOKEN = "Ein Speerbild mit einem eigenen Zaehler."

-- Registration is identical on server and clients; effects remain server-owned.
AddModRPCHandler("doc_counter_demo", "Increment", function(player, item)
    if not G.TheWorld.ismastersim or player == nil or not player:IsValid()
        or player:HasTag("playerghost") or player.components.health == nil
        or player.components.health:IsDead() then
        return
    end
    -- Reject malformed RPC arguments before calling entity methods.
    if G.type(item) ~= "table" or G.type(item.IsValid) ~= "function"
        or item.GUID == nil or G.Ents[item.GUID] ~= item
        or not item:IsValid() or item.prefab ~= "doc_counter_token" then
        return
    end
    local inventoryitem = item.components.inventoryitem
    local counter = item.components.doc_counter
    if inventoryitem == nil or inventoryitem:GetGrandOwner() ~= player or counter == nil then
        return
    end
    -- A business-level cooldown remains necessary despite engine RPC limits.
    local now = G.GetTime()
    if now < (counter.next_request_time or 0) then
        return
    end
    counter.next_request_time = now + 1
    counter:SetCount(counter:GetCount() + 1)
end)
