local G = GLOBAL
local F = G.FRAMES

local Buffer = 1 -- player physics diameter
local RadCache = {} -- prefab-radius table, will be populated shortly

local function GetFabRad(fab) -- spawn a temporary version of the object we need the physics radius of. so we can... y'know, get the physics radius!
    local obj = G.SpawnPrefab(fab)
    if not obj then return end -- If prefab won't spawn, skip.

    obj.prefab = "" -- Set prefab value to a blank string so it won't save

    if obj.Physics then -- if it has a physics table, cache the radius
        local rad = obj.Physics:GetRadius()
        RadCache[fab] = rad + 1 -- 1 is the maximum physics radius of craftable objects. (not including boats)
    end

    obj:Remove()
end

AddPrefabPostInit("world",function(world) -- cache phys sizes & modify placement behavior
    world:DoTaskInTime(F,function()
        for Name,Rec in pairs(G.AllRecipes or {}) do
            GetFabRad(Rec.product)
            local dist = RadCache[Rec.product] or 0
            local new = dist + Buffer
            if new < G.AllRecipes[Name].min_spacing then
                G.AllRecipes[Name].min_spacing = new
            end
            if dist == 0 then G.AllRecipes[Name].build_distance = 0 end
        end
    end)
end)