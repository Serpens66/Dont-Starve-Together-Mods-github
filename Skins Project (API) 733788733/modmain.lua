local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

PrefabFiles = {
	"generic_switch",
}

--Skin Tab
local skintab

if GLOBAL.CUSTOM_RECIPETABS.Skins then
	skintab = GLOBAL.CUSTOM_RECIPETABS.Skins
else
	Assets = {
		Asset("ATLAS", "images/hud/skintab.xml"),
		Asset("IMAGE", "images/hud/skintab.tex"),
	}
	skintab = AddRecipeTab("Skins", 990, "images/hud/skintab.xml", "skintab.tex", nil)
end

-- Core Api
local SkinsProject = {CharacterList = {}}

function SkinsProject.AddSkin(prefab, name, description)
	--Skin Prefab
	table.insert(SkinsProject.CharacterList, prefab)

	--Skin Recipe
    AddRecipe(prefab .. "_switch", {}, skintab, TECH.NONE, nil, nil, nil, nil, nil, "images/inventoryimages/" .. prefab .. "_switch.xml", prefab .. "_switch.tex")    
    if name==nil then
        name = string.gsub(" "..prefab, "%W%l", string.upper):sub(2) -- first character uppercase
    end
    if description==nil then
        description = name
    end
    --Skin Description
	local key = prefab:upper() .. "_SWITCH"
    STRINGS.NAMES[key] = name .. " Switch"
    STRINGS.RECIPE_DESC[key] = description

end

GLOBAL.SkinsProject = SkinsProject