-- HELPERS functions

-- ################################################
-- ############## technical helpers ###############
-- ################################################
-- local _G = GLOBAL

local helpers = {}
local function speed_sort(a,b) -- sort the "MODMULTS_2" keys by number
    a = tonumber(string.split(a,"_")[2])
    b = tonumber(string.split(b,"_")[2])
    return a < b
end
helpers["speed_sort"] = speed_sort
-- helpers for orderedPairs
local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex, speed_sort ) -- hardcoded sorting for speedsort
    return orderedIndex
end
local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.
    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end
    if key then
        return key, t[key]
    end
    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end
-- iterate over a list in sorted order
local function orderedPairs_speed(t) -- copy pasted from util.lua and added a sorting function to table.sort(). there is also sorted_pairs function in util.lua, but that is not working right now
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end
helpers["orderedPairs_speed"] = orderedPairs_speed



local function OverrideTuningVariables(tuning) -- copy pasted from worldsettings_overrides.lua
    if tuning ~= nil then
        for k, v in pairs(tuning) do
            ORIGINAL_TUNING[k] = TUNING[k]
            TUNING[k] = v
        end
    end
end
helpers["OverrideTuningVariables"] = OverrideTuningVariables

-- ################################################
-- ############## game helpers ###############
-- ################################################

local function GetFittingImage(name)
    local imagename = name
    local atlas = nil
    if MORESET_MOD.TuningImageTansl[name]~=nil then -- if we manually added a fitting image/atlas, use it
        imagename = MORESET_MOD.TuningImageTansl[name]["imagename"]
        atlas = MORESET_MOD.TuningImageTansl[name]["atlas"] -- may be nil, then use atlas_to_search
    end
    if atlas==nil then -- eg when TuningImageTansl only changed the imagename but provided no atlas (because it is in atlas_to_search)
        for _,searchatlas in ipairs(MORESET_MOD.atlas_to_search) do
            if TheSim and TheSim:AtlasContains(searchatlas, imagename..".tex") then
                atlas = searchatlas
                break
            end
        end
    end
    if atlas==nil then
        print("More Worldsetings mod: No Image found for "..tostring(imagename).." in atlas_to_search, using defaultimage -regrowth- now. To solve this find a fitting image in them or in another atlas or create your own and add it to TuningImageTansl")
        atlas = "images/customisation.xml"
        imagename = "regrowth" -- use this as default image if we can not find a fitting one
    end
    return imagename,atlas
end
helpers["GetFittingImage"] = GetFittingImage


return helpers