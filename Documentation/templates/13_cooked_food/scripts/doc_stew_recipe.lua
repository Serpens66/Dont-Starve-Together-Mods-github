-- Loaded in the ordinary scripts environment; shared by registration and prefab.
local function Test(cooker, names, tags)
    if (names.carrot or 0) + (names.carrot_cooked or 0) ~= 4 then
        return false
    end
    -- Reject unrelated ingredients, even in isolated calls outside four-slot pots.
    for name, count in pairs(names) do
        if name ~= "carrot" and name ~= "carrot_cooked" and count > 0 then
            return false
        end
    end
    return true
end

return {
    name = "doc_carrot_stew",
    test = Test,
    priority = 30,
    weight = 1, -- CalculateRecipe eventually subtracts weight without a fallback.
    cooktime = 0.5,
    foodtype = FOODTYPE.VEGGIE,
    health = 8,
    hunger = 30,
    sanity = 5,
    perishtime = TUNING.PERISH_MED,
    potlevel = "low",
    overridebuild = "cook_pot_food",
    overridesymbolname = "ratatouille", -- Pot display uses this, not the new prefab name.
    cookbook_tex = "ratatouille.tex",
    cookbook_atlas = GetInventoryItemAtlas("ratatouille.tex"),
}
