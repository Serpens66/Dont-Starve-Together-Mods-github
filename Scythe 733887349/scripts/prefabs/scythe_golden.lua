local assets=
{ 
    Asset("ANIM", "anim/scythe_golden.zip"),
    Asset("ANIM", "anim/swap_scythe_golden.zip"), 

    Asset("ATLAS", "images/inventoryimages/scythe_golden.xml"),
    Asset("IMAGE", "images/inventoryimages/scythe_golden.tex"),
}

local prefabs = 
{
}

    local function OnEquip(inst, owner) 
        if owner:HasTag("fastpicker") then
            owner:AddTag("fastpickerorignal")
        else
            owner:AddTag("fastpicker")
        end
        owner.AnimState:OverrideSymbol("swap_object", "swap_scythe_golden", "scythe")
        owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
    end

    local function OnUnequip(inst, owner) 
        if owner:HasTag("fastpickerorignal") then
            owner:RemoveTag("fastpickerorignal") -- do not remove fastpicker if he is one also without scythe
        elseif owner:HasTag("fastpicker") then
            owner:RemoveTag("fastpicker")
        end
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end

    local function fn(Sim)

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("scythe_golden")
    inst.AnimState:SetBuild("scythe_golden")
    inst.AnimState:PlayAnimation("idle")
		
	inst:AddTag("sharp")
	inst:AddTag("mower")
    
    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

if not TheWorld.ismastersim then
        return inst
    end
inst.entity:SetPristine()  
				----

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SCYTHE_DAMAGE)
    
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PICK)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.GOLDENSCYTHE_USES)
    inst.components.finiteuses:SetUses(TUNING.GOLDENSCYTHE_USES)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.PICK, 1)

	inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "scythe_golden"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/scythe_golden.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )

    return inst
end

return  Prefab("common/inventory/scythe_golden", fn, assets, prefabs)