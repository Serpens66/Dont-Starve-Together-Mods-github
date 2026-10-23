local G = GLOBAL
local periods = { default = 30, fast = 15, slow = 60 }
AddCustomizeGroup(G.LEVELCATEGORY.SETTINGS, "DOC_TIMERS", "Dokumentations-Timer",
    { { text = "Normal (30 s)", data = "default" }, { text = "Schnell (15 s)", data = "fast" },
      { text = "Langsam (60 s)", data = "slow" } }, "images/customisation.xml", 99)
AddCustomizeItem(G.LEVELCATEGORY.SETTINGS, "DOC_TIMERS", "doc_pulse",
    -- customisation.xml enthält spiders.tex; spiderden.tex gehört zu einem anderen Atlas.
    { value = "default", image = "spiders.tex", order = 1, world = { "forest", "cave" } })
local overrides = G.require("worldsettings_overrides")
-- Pre wird vor dem Welt-Prefab aufgerufen: hier existiert TheWorld noch nicht.
overrides.Pre.doc_pulse = function(value) G.TUNING.DOC_PULSE_SECONDS = periods[value] or 30 end
overrides.Post.doc_pulse = function(value)
    if G.TheWorld ~= nil and G.TheWorld.components.doc_worldpulse ~= nil then
        G.TheWorld.components.doc_worldpulse:SetPeriod(periods[value] or 30)
    end
end
