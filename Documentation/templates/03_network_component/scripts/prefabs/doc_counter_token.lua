local assets = {
    Asset("ANIM", "anim/spear.zip"),
    Asset("ANIM", "anim/swap_spear.zip"),
}

local function OnDirty(inst)
    print("[DocCounter] value:", inst._doc_count:value())
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("spear")
    inst.AnimState:SetBuild("swap_spear")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)
    inst._doc_count = net_ushortint(inst.GUID, "doc_counter.count", "doc_counter_dirty")
    inst:ListenForEvent("doc_counter_dirty", OnDirty)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "spear"
    inst.components.inventoryitem.atlasname = GetInventoryItemAtlas("spear.tex")
    inst:AddComponent("doc_counter")
    return inst
end

return Prefab("doc_counter_token", fn, assets)
