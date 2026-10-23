local G = GLOBAL
local action = AddAction("DOC_MARK_CHEST", "Markieren", function(act)
    if not G.TheWorld.ismastersim then
        return false
    end
    local player, target = act.doer, act.target
    if player == nil or not player:IsValid() or target == nil or not target:IsValid()
        or player:HasTag("playerghost") or player.components.health == nil
        or player.components.health:IsDead() or target.prefab ~= "treasurechest"
        or player:GetDistanceSqToInst(target) > 16 then
        return false
    end
    local marker = target.components.doc_markable
    return marker ~= nil and marker:Mark() or false
end)
action.rmb = true
action.priority = 2

AddComponentAction("SCENE", "doc_markable", function(inst, doer, actions, right)
    -- Client selection relies on replicated tags, never a server component.
    if right and not doer:HasTag("playerghost") and not inst:HasTag("doc_marked") then
        G.table.insert(actions, action)
    end
end)
AddStategraphActionHandler("wilson", G.ActionHandler(action, "doshortaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(action, "doshortaction"))

AddPrefabPostInit("treasurechest", function(inst)
    if G.TheWorld.ismastersim and inst.components.doc_markable == nil then
        inst:AddComponent("doc_markable")
    end
end)
