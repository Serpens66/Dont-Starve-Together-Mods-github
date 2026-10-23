local G = GLOBAL
PrefabFiles = { "doc_storage_chest" }
local containers = G.require("containers")
-- Eigene Tabelle: Änderungen dürfen Vanilla-Truhen nicht mit verändern.
containers.params.doc_storage_chest = G.deepcopy(containers.params.treasurechest)
G.STRINGS.NAMES.DOC_STORAGE_CHEST = "Dokumentationskiste"
G.STRINGS.RECIPE_DESC.DOC_STORAGE_CHEST = "Neun gespeicherte Plätze."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DOC_STORAGE_CHEST = "Hier liegen meine Beispiele."
AddRecipe2("doc_storage_chest", { G.Ingredient("boards", 3) }, G.TECH.SCIENCE_ONE,
    { placer = "doc_storage_chest_placer", atlas = G.GetInventoryItemAtlas("boards.tex"), image = "boards.tex" },
    { "STRUCTURES", "CONTAINERS" })
