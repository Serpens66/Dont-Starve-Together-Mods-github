-- After game updates/adding mods one should check logfile for:
-- "More Worldsetings mod:" ... "is pickable but no fitting TUNING values"
-- "WARNING! Could not find region 'bullkelp.tex' from atlas 'images/customisation.xml'. Is the region specified in the atlas?"
-- "More Worldsetings mod: No Image found for"
-- if these happen you might want to add to PrefabTuningTansl or TuningImageTansl to solve the issue.
-- 


-- no need for adjustments on pickable or so for midgame changes (currently eg grass already growing will not change the time left if the settings changed. needs to wait for the next cycle)
-- but it seems the devs are already working on it with worldsettingsutil.lua and in lightflier_flower.lua. 
-- This one does already update the time perfectly fine when changing the worldsettings.
-- and I assume the devs will roll out this to all pickable prefabs in the future and maybe also for other components.
--
-- this could also mean that the devs will add pickable regrow worldsettings on their own in the future.
-- still:
-- short and easy code to adjust the prefab to get the advantage of this worldsettingsutil. Until the devs implement it themself in the prefabs


local _G = GLOBAL
-- AddComponentPostInit -- is not useful here because: 1) prefab is not defined within it. and 2) it is before prefab function itself is finished (while the fcuntion could change some values of pickable)
local appendix = "_REGROW_TIME" -- for pickable
local appendix_never = "_PICKABLE" -- for pickable
local reported = {}

AddPrefabPostInitAny(function(inst)
    if inst~=nil and inst.components~=nil then
        if inst.components.pickable~=nil and not inst.components.pickable.useexternaltimer and inst.components.pickable.baseregentime~=nil and not inst.components.pickable.remove_when_picked then -- only stuff that is pickable and will regrow
            local prefab = inst.prefab
            if prefab~=nil then 
                local name = prefab
                if _G.TUNING[string.upper(name)..appendix]==nil or _G.TUNING[string.upper(name)..appendix_never]==nil then
                    name = _G.MORESET_MOD.PrefabTuningTansl[prefab]
                    if name==nil then
                        print("More Worldsetings mod: "..prefab.." is pickable (1) but no fitting TUNING values: "..string.upper(prefab)..appendix..":"..tostring(_G.TUNING[string.upper(prefab)..appendix])..", "..string.upper(prefab)..appendix_never..":"..tostring(_G.TUNING[string.upper(prefab)..appendix_never]) )
                        table.insert(reported,prefab) -- report missing _G.TUNING value ones is enough
                    end
                end
                if name~=nil and not table.contains(reported,name) then -- is not in _G.TUNING, so no additional check needed
                    if _G.TUNING[string.upper(name)..appendix]~=nil and _G.TUNING[string.upper(name)..appendix_never]~=nil then
                        
                        _G.WorldSettings_Pickable_RegenTime(inst, _G.TUNING[string.upper(name)..appendix], _G.TUNING[string.upper(name)..appendix_never])
                        local old_OnPreLoad = inst.OnPreLoad
                        local function new_OnPreLoad(inst,data,...)
                            local ret = nil
                            if old_OnPreLoad~=nil then
                                ret = old_OnPreLoad(inst,data,...) -- call the original one first, not sure if needed, but should not hurt
                            end
                            _G.WorldSettings_Pickable_PreLoad(inst, data, _G.TUNING[string.upper(name)..appendix])
                            return ret
                        end
                        inst.OnPreLoad = new_OnPreLoad
                        
                    else
                        print("More Worldsetings mod: "..name.." is pickable (2) but no fitting TUNING values: "..string.upper(name)..appendix..":"..tostring(_G.TUNING[string.upper(name)..appendix])..", "..string.upper(name)..appendix_never..":"..tostring(_G.TUNING[string.upper(name)..appendix_never]) )
                        table.insert(reported,name) -- report missing _G.TUNING value ones is enough
                    end
                end
            end
        end
    end
end)

-- not perfect, but acceptable solution until defs add a tuning value themself... 
AddPrefabPostInit("bananabush",function(inst) -- add our TUNING value to growable stages
    if inst~=nil and inst.components~=nil and inst.components.growable~=nil and inst.components.growable.stages~=nil and type(inst.components.growable.stages)=="table" then
        for _,stage in ipairs(inst.components.growable.stages) do
            if stage~=nil and stage.time~=nil then
                stage.time = function(inst) return TUNING.BANANABUSH_REGROW_TIME end
            end
        end
    end
end)











