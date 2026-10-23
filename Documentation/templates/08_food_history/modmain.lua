AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    if inst.components.eater ~= nil then inst:AddComponent("doc_foodhistory") end
end)
