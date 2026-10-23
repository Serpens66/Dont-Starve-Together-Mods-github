local recipe = require("doc_stew_recipe")
local assets = { Asset("ANIM", "anim/cook_pot_food.zip") }
local prefabs = { "spoiled_food" }

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("cook_pot_food")
    inst.AnimState:SetBuild("cook_pot_food")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "ratatouille")
    inst:AddTag("preparedfood")
    -- The edible component restores the food type tag on the master.
    inst:AddTag("edible_"..FOODTYPE.VEGGIE)
    MakeInventoryFloatable(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = recipe.foodtype
    inst.components.edible.healthvalue = recipe.health
    inst.components.edible.hungervalue = recipe.hunger
    inst.components.edible.sanityvalue = recipe.sanity
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("ratatouille")
    inst.components.inventoryitem.atlasname = GetInventoryItemAtlas("ratatouille.tex")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(recipe.perishtime)
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst.components.perishable:StartPerishing()
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndPerish(inst)
    inst:AddComponent("bait")
    inst:AddComponent("tradable")
    -- Inventory, stack size and freshness use their existing component Save/Load.
    return inst
end

return Prefab("doc_carrot_stew", fn, assets, prefabs)
