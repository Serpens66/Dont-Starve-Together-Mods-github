-- require "prefabutil"
-- require "recipe"
-- require "modutil"


local assets=
{
    Asset("ANIM", "anim/trashcan.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
    Asset("ATLAS", "images/inventoryimages/trashcan.xml"),
    Asset("IMAGE", "images/inventoryimages/trashcan.tex"),
}

--------------------------------

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    -- print("[mod]trash can: onopen")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    -- print("[mod]trash can: onclose")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
    -- print("[mod]trash can: onhammered")
end

local hitedCount = 0

local function onhit(inst, worker)
  -- inst.AnimState:PushAnimation("hit", false)
  hitedCount = hitedCount + 1
  if hitedCount == 5 then
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

    fx:SetMaterial("metal")
    inst:Remove()

    inst.components.container:Close()
  end
  -- print("[mod]trash can: onhit")
end

local function onsave(inst, data)
    -- if inst.owner ~= nil then
    --     data.owner = inst.owner
    -- end
    -- print("[mod]trash can: onsave")
end

local function onload(inst, data)
    -- print("[mod]trash can: onload")
end

local function onbuilt(inst, data)

    inst.AnimState:PlayAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
    -- print("[mod]trash can: onbuilt")
end



local function OnActivate(inst)
  if inst.components.container then
    inst.components.container:Close()
  end
  if inst.components.container and not inst.components.container:IsEmpty() then
    for i = 1, inst.components.container.numslots do
        if inst.components.container:GetItemInSlot(i) then
          local item = inst.components.container.slots[i]
          local item_count = 0

          if not item:HasTag("irreplaceable") then
              if item.components.stackable then
                  item_count = item.components.stackable:StackSize()
              else
                  item_count = 1
              end

              local remove_item = inst.components.container:RemoveItemBySlot(i) -- remove items first
              if remove_item ~= nil then
                item:Remove()
              end

              for j = 1, item_count do -- add ashes
                local ash = SpawnPrefab("ash")
                if ash ~= nil then
                    inst.components.container:GiveItem(ash) -- without index, so the ash is properly stacked
                end
              end
          end
        end
    end
  end
  inst.AnimState:PlayAnimation("burn")
  inst.SoundEmitter:PlaySound("dontstarve/common/fireBurstLarge")
  
  if inst.components.container then
    inst.components.container:Close()
  end
  if inst.components.activatable~=nil then
    inst.components.activatable.inactive = true
  end
end

local function OnTurnOn(inst)
    OnActivate(inst)
    inst:DoTaskInTime(1,function() inst.components.machine:TurnOff() end)
end



-- local function onignite(inst,data) -- now replaced with OnActivate
  -- if inst.components.container then
    -- inst.components.container:Close()
  -- end
  -- if inst.components.container and not inst.components.container:IsEmpty() then
    -- for i = 1, inst.components.container.numslots do
      -- repeat
        -- if inst.components.container:GetItemInSlot(i) then
          -- local item = inst.components.container.slots[i]
          -- local item_count = 0

          -- if item:HasTag("irreplaceable") then
            -- break
          -- end

          -- if item.components.stackable then
              -- item_count = item.components.stackable:StackSize()
          -- else
              -- item_count = 1
          -- end

          -- local remove_item = inst.components.container:RemoveItemBySlot(i) -- remove items first
          -- if remove_item ~= nil then
            -- item:Remove()
          -- end

          -- for j = 1, item_count do -- add ashes
            -- local ash = SpawnPrefab("ash")
            -- if ash ~= nil then
                -- inst.components.container:GiveItem(ash, i)
            -- end
          -- end

        -- end

        -- break
      -- until true
    -- end
  -- end
  -- inst.AnimState:PlayAnimation("burn")
  -- inst.SoundEmitter:PlaySound("dontstarve/common/fireBurstLarge")
  
  -- if inst.components.container then
    -- inst.components.container:Close()
  -- end

  -- inst:RemoveComponent("burnable")
  -- inst:AddComponent("burnable")
-- end

----------------------------------

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    inst:AddTag("structure")
    inst:AddTag("chest")
    inst:AddTag("trashcan")
    inst:AddTag("fireimmune") -- fire resistant. use turn on action now instead of igniting with torch

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "trashcan.tex" )

    inst.AnimState:SetBank("trashcan")
    inst.AnimState:SetBuild("trashcan")
    inst.AnimState:PlayAnimation("idle")


    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    inst:AddComponent("container")
    
    -- inst:AddComponent("activatable") -- dont use activatable, because the priority of this action does not work well with opening a container. use machine instead...
    -- inst.components.activatable.OnActivate = OnActivate
    -- inst.components.activatable.quickaction = true
    
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = OnTurnOn
    inst.components.machine.cooldowntime = 0
    
    
    -- inst:AddComponent("burnable")

    inst.components.container:WidgetSetup("trashcan")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(TUNING.SAFEICEBOX_FIRMNESS)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)


    inst.OnSave = onsave
    inst.OnLoad = onload
    inst:ListenForEvent("onbuilt", onbuilt)
    -- inst:ListenForEvent("onignite", onignite)

    MakeSnowCovered(inst)
    MakeSnowCoveredPristine(inst)
    AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab( "common/trashcan", fn, assets),
        MakePlacer( "common/trashcan_placer", "trashcan", "trashcan", "idle" )
