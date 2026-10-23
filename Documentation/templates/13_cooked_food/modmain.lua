local G = GLOBAL
PrefabFiles = { "doc_carrot_stew" }
G.STRINGS.NAMES.DOC_CARROT_STEW = "Karotteneintopf"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DOC_CARROT_STEW = "Vier Karotten, ein Eintopf."

local recipe = G.require("doc_stew_recipe")
-- Recipes belong to each cooker separately; do not alter Vanilla ingredient values.
for _, cooker in ipairs({ "cookpot", "portablecookpot", "archive_cookpot" }) do
    AddCookerRecipe(cooker, recipe)
end

-- preparedfood is accepted by the spicer even without a matching mod spice recipe.
-- Keep this unspiced teaching example out of that station on server and client.
local containers = G.require("containers")
local spicer = containers.params.portablespicer
local old_itemtest = spicer.itemtestfn
spicer.itemtestfn = function(container, item, slot)
    if item.prefab == recipe.name then return false end
    return old_itemtest(container, item, slot)
end
