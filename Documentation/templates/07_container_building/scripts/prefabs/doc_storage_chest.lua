local assets = {
    Asset("ANIM", "anim/treasure_chest.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
}
local function OnOpen(inst)
    inst.AnimState:PlayAnimation("open")
end
local function OnClose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.AnimState:PushAnimation("closed", false)
end
local function OnHit(inst)
    inst.components.container:Close()
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("closed", false)
end
local function OnHammered(inst)
    inst.components.container:DropEverything()
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) end
    inst:Remove()
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .5)
    inst.AnimState:SetBank("chest")
    inst.AnimState:SetBuild("treasure_chest")
    inst.AnimState:PlayAnimation("closed")
    inst:AddTag("structure")
    inst:AddTag("chest")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("doc_storage_chest")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({ "boards" })
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnWorkCallback(OnHit)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    return inst
end
return Prefab("doc_storage_chest", fn, assets, { "collapse_small" }),
    MakePlacer("doc_storage_chest_placer", "chest", "treasure_chest", "closed")
