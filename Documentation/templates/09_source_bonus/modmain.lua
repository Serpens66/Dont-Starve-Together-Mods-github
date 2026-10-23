local G = GLOBAL
PrefabFiles = { "doc_bonus_spear" }
G.STRINGS.NAMES.DOC_BONUS_SPEAR = "Bonusspeer"
G.STRINGS.RECIPE_DESC.DOC_BONUS_SPEAR = "25 Prozent zusätzlicher ausgehender Schaden."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DOC_BONUS_SPEAR = "Die Quelle dieses Bonus ist eindeutig."
AddRecipe2("doc_bonus_spear", { G.Ingredient("twigs", 2), G.Ingredient("flint", 1) }, G.TECH.NONE,
    { atlas = G.GetInventoryItemAtlas("spear.tex"), image = "spear.tex" }, { "WEAPONS" })
