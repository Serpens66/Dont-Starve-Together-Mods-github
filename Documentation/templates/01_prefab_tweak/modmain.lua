local G = GLOBAL
local multiplier = GetModConfigData("damage_multiplier")
if G.type(multiplier) ~= "number" or multiplier <= 0 or multiplier ~= multiplier or multiplier == G.math.huge then
    multiplier = 1
end

AddPrefabPostInit("spear", function(inst)
    if not G.TheWorld.ismastersim then
        return
    end
    local weapon = inst.components.weapon
    -- Other mods may supply a damage function; do not replace that contract.
    if weapon ~= nil and G.type(weapon.damage) == "number" then
        weapon:SetDamage(weapon.damage * multiplier)
    end
end)
