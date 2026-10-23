local G = GLOBAL
PrefabFiles = { "doc_training_spear" }

G.STRINGS.NAMES.DOC_TRAINING_SPEAR = "Trainingsspeer"
G.STRINGS.RECIPE_DESC.DOC_TRAINING_SPEAR = "Ein einfaches Beispiel zum Lernen."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DOC_TRAINING_SPEAR = "Zeit zum \195\156ben."

AddRecipe2("doc_training_spear",
    { G.Ingredient("twigs", 2), G.Ingredient("flint", 1) },
    G.TECH.NONE,
    { atlas = G.GetInventoryItemAtlas("spear.tex"), image = "spear.tex" },
    { "WEAPONS" })
