if not (GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated()) then 
	return
end

AddPrefabPostInit("gunpowder", function(inst)
    if inst.components.explosive then
        inst.components.explosive.explosiverange = inst.components.explosive.explosiverange + GetModConfigData("gunpowderrange")
        inst.components.explosive.explosivedamage = inst.components.explosive.explosivedamage + GetModConfigData("gunpowderdamage")
    end
end)

AddPrefabPostInit("slurtleslime", function(inst)
	if inst.components.explosive then
        inst.components.explosive.explosiverange = inst.components.explosive.explosiverange + GetModConfigData("slurtleslimerange")
        inst.components.explosive.explosivedamage = inst.components.explosive.explosivedamage + GetModConfigData("slurtleslimedamage")
    end
end)

