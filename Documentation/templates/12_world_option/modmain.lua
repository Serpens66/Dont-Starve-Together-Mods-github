local function Install(inst)
    if GLOBAL.TheWorld.ismastersim then inst:AddComponent("doc_worldpulse") end
end
AddPrefabPostInit("forest", Install)
AddPrefabPostInit("cave", Install)
