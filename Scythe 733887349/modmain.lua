
local recipe_f = GetModConfigData("recipe_f")
local science_f = GetModConfigData("science_f")
local durabililty_f = GetModConfigData("durabililty_f")
local recipe_g = GetModConfigData("recipe_g")
local science_g = GetModConfigData("science_g")
local durabililty_g = GetModConfigData("durabililty_g")

TUNING.SCYTHE_USES = durabililty_f
TUNING.GOLDENSCYTHE_USES = durabililty_g
TUNING.SCYTHE_DAMAGE = 25

GLOBAL.TOOLACTIONS["PICK"] = true -- allow PICK for scythe tool

PrefabFiles = {
    "scythe",
    "scythe_golden",
}

Assets = {
	Asset("ATLAS", "images/inventoryimages/scythe.xml"),
	Asset("ATLAS", "images/inventoryimages/scythe_golden.xml"),

	Asset( "IMAGE", "images/inventoryimages/scythe.tex" ),
	Asset( "IMAGE", "images/inventoryimages/scythe_golden.tex" ),

	Asset("ANIM", "anim/scythe.zip"),
	Asset("ANIM", "anim/scythe_golden.zip"),

	Asset("ANIM", "anim/swap_scythe.zip"),
	Asset("ANIM", "anim/swap_scythe_golden.zip"),
}

local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS

GLOBAL.STRINGS.NAMES.SCYTHE = "Scythe"
GLOBAL.STRINGS.RECIPE_DESC.SCYTHE = "Gathering more effective."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SCYTHE = "Gathering more effective."

GLOBAL.STRINGS.NAMES.SCYTHE_GOLDEN = "Golden Scythe"
GLOBAL.STRINGS.RECIPE_DESC.SCYTHE_GOLDEN = "Gathering longer more effective."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SCYTHE_GOLDEN = "Gathering longer more effective."

if recipe_f == "0" then
	local scythe = GLOBAL.Recipe("scythe", { Ingredient("twigs", 2), Ingredient("rope", 1), Ingredient("flint", 2)}, RECIPETABS.TOOLS, {SCIENCE = science_f} )
	scythe.atlas = "images/inventoryimages/scythe.xml"
else
	local scythe = GLOBAL.Recipe("scythe", { Ingredient("twigs", 2), Ingredient("flint", 2)}, RECIPETABS.TOOLS, {SCIENCE = science_f} )
	scythe.atlas = "images/inventoryimages/scythe.xml"
end

if recipe_g == "0" then
	local scythe_golden = GLOBAL.Recipe("scythe_golden", { Ingredient("twigs", 4), Ingredient("rope", 2), Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS, {SCIENCE = science_g} )
	scythe_golden.atlas = "images/inventoryimages/scythe_golden.xml"
else
	local scythe_golden = GLOBAL.Recipe("scythe_golden", { Ingredient("razor", 1), Ingredient("houndstooth", 2), Ingredient("goldnugget", 4)}, RECIPETABS.TOOLS, {SCIENCE = science_g} )
	scythe_golden.atlas = "images/inventoryimages/scythe_golden.xml"
end
