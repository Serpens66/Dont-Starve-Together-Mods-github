local G = GLOBAL
local factor = GetModConfigData("flower_weight_multiplier")
if G.type(factor) ~= "number" or factor <= 0 or factor ~= factor or factor == G.math.huge then
    factor = 1
end

AddRoomPreInit("BGForest", function(room)
    local weights = room.contents ~= nil and room.contents.distributeprefabs or nil
    if weights ~= nil and G.type(weights.flower) == "number" then
        -- Weights compete with all other entries; this is not an absolute percent.
        weights.flower = weights.flower * factor
    end
end)
