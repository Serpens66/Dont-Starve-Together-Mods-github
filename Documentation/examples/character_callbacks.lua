-- Fragment for MakePlayerCharacter callbacks, not an AddPrefabPostInit replacement.
local function common_postinit(inst)
    inst:AddTag("doc_example_character")
end
local function master_postinit(inst)
    inst.starting_inventory = { "twigs" }
    inst.doc_visits = 0
    local oldsave, oldload = inst.OnSave, inst.OnLoad
    inst.OnSave = function(inst, data)
        if oldsave ~= nil then oldsave(inst, data) end
        data.doc_example = { version = 1, visits = inst.doc_visits }
    end
    inst.OnLoad = function(inst, data)
        if oldload ~= nil then oldload(inst, data) end
        local saved = data ~= nil and data.doc_example or nil
        if type(saved) == "table" and saved.version == 1 then
            local n = saved.visits
            if type(n) == "number" and n == n and n >= 0 and n <= 1000000 and n % 1 == 0 then
                inst.doc_visits = n
            end
        end
    end
    -- player_common captures these callbacks after master_postinit and calls them
    -- from its own OnSave/OnLoad. Do not overwrite that wrapper in a later hook.
end
return { common_postinit = common_postinit, master_postinit = master_postinit }
