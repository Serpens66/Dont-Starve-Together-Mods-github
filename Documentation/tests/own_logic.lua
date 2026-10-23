-- Run from workspace root with Lua 5.1. No engine, network or game is started.
-- Stubs implement only the contracts needed by these deterministic tests.
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    io.write("PASS ", name, "\n")
end
local function eq(a, b) assert(a == b, tostring(a).." ~= "..tostring(b)) end
function Class(ctor)
    local cls = {}
    cls.__index = cls
    return setmetatable(cls, {__call = function(_, inst)
        local self = setmetatable({}, cls)
        ctor(self, inst)
        return self
    end})
end
local base = "Documentation/templates/"
local History = dofile(base.."08_food_history/scripts/components/doc_foodhistory.lua")
local function history()
    local inst = {components = {eater = {}}}
    function inst:ListenForEvent(_, fn) self.callback = fn end
    function inst:RemoveEventCallback(_, fn) if self.callback == fn then self.callback = nil end end
    local component = History(inst)
    local function eat(name) inst.callback(inst, {food = {prefab = name}}) end
    return component, inst, eat
end
test("history MRU deduplicates and evicts", function()
    local c, _, eat = history()
    for _, n in ipairs({"a", "b", "c", "a", "d"}) do eat(n) end
    eq(table.concat(c.history, ","), "d,a,c")
end)
test("history reduces positive values only, after prior wrapper", function()
    local c, inst, eat = history()
    c.oldfn = function(_, h, u, s) return h + 2, u, s end
    eat("a")
    local h, u, s = inst.components.eater.custom_stats_mod_fn(inst, 8, -4, 0, {prefab="a"})
    eq(h, 5); eq(u, -4); eq(s, 0)
end)
test("history load validates version, length, type and duplicates", function()
    local c = history()
    c:OnLoad({version=1,history={"a", "a", 12, string.rep("x",129), "b", "c", "d"}})
    eq(table.concat(c.history, ","), "a,b,c")
    local saved = c:OnSave()
    local other = history(); other:OnLoad(saved)
    eq(table.concat(other.history, ","), "a,b,c")
    other:OnLoad({version=2,history={"x"}}); eq(#other.history, 0)
end)
test("removed history remains inactive inside later foreign wrapper", function()
    local c, inst, eat = history(); eat("a")
    local owned = c.wrapper
    local foreign = function(...) return owned(...) end
    inst.components.eater.custom_stats_mod_fn = foreign
    c:OnRemoveFromEntity()
    eq(inst.components.eater.custom_stats_mod_fn, foreign)
    eq(inst.callback, nil)
    eq(foreign(inst, 8, 10, 2, {prefab="a"}), 8)
end)
test("removed history restores previous wrapper when still owner", function()
    local c, inst = history()
    local old = function() end; c.oldfn = old
    c:OnRemoveFromEntity(); eq(inst.components.eater.custom_stats_mod_fn, old)
end)
local now = 0
GetTime = function() return now end
TUNING = {DOC_PULSE_SECONDS=30}
local Pulse = dofile(base.."12_world_option/scripts/components/doc_worldpulse.lua")
local function pulse(period)
    TUNING.DOC_PULSE_SECONDS = period
    local inst = {tasks={}}
    function inst:DoTaskInTime(delay, fn)
        local task = {delay=delay,fn=fn,cancelled=false}
        function task:Cancel() self.cancelled = true end
        table.insert(self.tasks, task)
        return task
    end
    return Pulse(inst), inst
end
test("timer preserves fractional progress on live option change", function()
    now=0; local c = pulse(30); local old = c.task
    now=15; c:SetPeriod(60)
    eq(old.cancelled, true); eq(c.task.delay, 30); eq(c.deadline, 45)
end)
test("timer load migrates old period to current option", function()
    now=0; local c = pulse(15); local old = c.task
    c:OnLoad({version=1,period=60,remaining=30,ticks=3.8})
    eq(old.cancelled, true); eq(c.task.delay, 7.5); eq(c.ticks, 3)
    eq(c:OnSave().remaining, 7.5)
end)
test("timer rejects NaN, infinities, bounds and unknown save version", function()
    local c = pulse(30); local task = c.task
    for _, n in ipairs({0/0, math.huge, -math.huge, 14, 61}) do c:SetPeriod(n) end
    eq(c.task, task)
    c:OnLoad({version=2}); eq(c.task, task)
    c:OnLoad({version=1,period=math.huge,remaining=-4,ticks=-3})
    eq(c.task.delay, 0); eq(c.ticks, 0)
    c:OnLoad({version=1,period=30,remaining=100})
    eq(c.task.delay, 30)
end)
test("timer callback rearms once and removal cancels", function()
    now=0; local c, inst = pulse(30)
    now=30; c.task.fn()
    eq(c.ticks, 1); eq(#inst.tasks, 2); eq(c.task.delay, 30)
    local task=c.task; c:OnRemoveFromEntity(); eq(task.cancelled, true); eq(c.task,nil)
end)
local handler
local scans = 0
local G = {tonumber=tonumber,GetTime=GetTime,TheWorld={ismastersim=true},
    TheNet={IsDedicated=function() return true end},
    TheSim={FindEntities=function() scans=scans+1; return {{},{},{}} end}}
local env = {GLOBAL=G,math=math,type=type,tostring=tostring,
    AddReplicableComponent=function() end, AddPlayerPostInit=function() end,
    AddModRPCHandler=function(_,_,fn) handler=fn end}
local loader=assert(loadfile(base.."10_query_ui/modmain.lua")); setfenv(loader,env); loader()
local function player()
    local p={components={doc_query={next_request=0}},replica={doc_query={}},Transform={}}
    function p:IsValid() return true end
    function p:HasTag() return false end
    function p.Transform:GetWorldPosition() return 0,0,0 end
    function p.replica.doc_query:SetReply(s) p.reply=s end
    return p
end
test("query rejects malformed sequence before scanning", function()
    now=0; local p=player(); local before=scans
    for _, v in ipairs({false,"1",{},0,-1,1.5,65536,0/0,math.huge}) do handler(p,v) end
    handler(nil,1); eq(scans,before)
end)
test("query uses authenticated player, bounds reply and throttles", function()
    now=0; local p=player(); local before=scans
    handler(p,1); eq(p.reply,"1:3"); eq(scans,before+1)
    handler(p,2); eq(scans,before+1)
    now=1; handler(p,65535); eq(p.reply,"65535:3"); eq(scans,before+2)
    p.HasTag=function() return true end; now=2; handler(p,3); eq(scans,before+2)
end)
test("client callback works in real-style mod environment without tonumber", function()
    local hook, label, button, update
    local function widget()
        return {SetPosition=function() end, SetString=function(self,s) self.text=s end,
            SetText=function() end, SetOnClick=function(self,fn) self.click=fn end}
    end
    G.TheNet.IsDedicated=function() return false end
    G.require=function(name)
        return function()
            local w=widget()
            if name=='widgets/text' then label=w else button=w end
            return w
        end
    end
    env.AddClassPostConstruct=function(_,fn) hook=fn end
    env.GetModRPC=function() return {} end
    env.SendModRPCToServer=function() end
    loader=assert(loadfile(base.."10_query_ui/modmain.lua")); setfenv(loader,env); loader()
    local p=player(); G.ThePlayer=p
    function p.replica.doc_query:GetReply() return p.reply or '' end
    local controls={owner=p,topleft_root={AddChild=function(_,w) return w end},inst={}}
    controls.inst.ListenForEvent=function(_,_,fn) update=fn end
    hook(controls); now=0; button.click()
    p.reply='1:42'; update(); eq(label.text,'Blumen: 42')
    p.reply='2:88'; update(); eq(label.text,'Blumen: 42')
    p.reply='malformed'; update(); eq(label.text,'Blumen: 42')
    eq(env.tonumber,nil)
end)
test("historical Lua boolean precedence is reproducible", function()
    for _, n in ipairs({0,1,10}) do eq((not n == 0),false) end
    eq((not {} ~= nil),true)
    eq(({pigman="Pig",pigman="Werepig"}).pigman,"Werepig")
end)
-- Recipe modules are ordinary scripts, loaded with explicit minimal globals here.
local saved_tuning, saved_foodtype, saved_atlas = TUNING, FOODTYPE, GetInventoryItemAtlas
TUNING = {PERISH_MED=4800}; FOODTYPE = {VEGGIE="VEGGIE"}
GetInventoryItemAtlas = function(image) eq(image,"ratatouille.tex"); return "stub-atlas.xml" end
local stew = dofile(base.."13_cooked_food/scripts/doc_stew_recipe.lua")
TUNING, FOODTYPE, GetInventoryItemAtlas = saved_tuning, saved_foodtype, saved_atlas

test("stew accepts every raw-cooked four-carrot distribution", function()
    for raw=0,4 do
        eq(stew.test("cookpot",{carrot=raw,carrot_cooked=4-raw},{veggie=4}),true)
    end
end)
test("stew rejects incomplete and unrelated ingredients", function()
    for _,names in ipairs({{}, {carrot=3}, {carrot=5}, {carrot=3,berries=1},
        {carrot=4,berries=1}, {carrot=2,carrot_cooked=1,corn=1}}) do
        eq(stew.test("cookpot",names,{veggie=4}),false)
    end
end)
test("stew test leaves shared cooking inputs unchanged", function()
    local names,tags={carrot=2,carrot_cooked=2},{veggie=4}
    stew.test("cookpot",names,tags)
    eq(names.carrot,2);eq(names.carrot_cooked,2);eq(tags.veggie,4)
    eq(names.doc_carrot_stew,nil)
end)
test("stew has explicit finite weight and consistent visual fields", function()
    assert(stew.weight>0 and stew.weight<math.huge and stew.weight==stew.weight)
    assert(stew.priority>0 and stew.perishtime>0 and stew.cooktime>0)
    eq(stew.overridebuild,"cook_pot_food");eq(stew.overridesymbolname,"ratatouille")
    eq(stew.cookbook_tex,stew.overridesymbolname..".tex")
    eq(stew.foodtype,"VEGGIE")
end)
test("stew modmain registers all three cookers with its product", function()
    local registered={}
    local g={STRINGS={NAMES={},CHARACTERS={GENERIC={DESCRIBE={}}}},
        require=function(name)
            if name=="doc_stew_recipe" then return stew end
            eq(name,"containers");return {params={portablespicer={itemtestfn=function() return true end}}}
        end}
    local e={GLOBAL=g,ipairs=ipairs,AddCookerRecipe=function(name,recipe) registered[name]=recipe end}
    local f=assert(loadfile(base.."13_cooked_food/modmain.lua"));setfenv(f,e);f()
    eq(e.PrefabFiles[1],stew.name)
    eq(registered.cookpot,stew);eq(registered.portablecookpot,stew);eq(registered.archive_cookpot,stew)
    eq(g.STRINGS.NAMES.DOC_CARROT_STEW,"Karotteneintopf")
end)
test("spicer guard rejects only new unspiced food and preserves prior filter", function()
    local calls=0
    local params={portablespicer={itemtestfn=function(container,item,slot)
        calls=calls+1;eq(container,"c");eq(slot,1);return item.accepted
    end}}
    local g={STRINGS={NAMES={},CHARACTERS={GENERIC={DESCRIBE={}}}},require=function(name)
        if name=="doc_stew_recipe" then return stew end
        eq(name,"containers");return {params=params}
    end}
    local e={GLOBAL=g,ipairs=ipairs,AddCookerRecipe=function() end}
    local f=assert(loadfile(base.."13_cooked_food/modmain.lua"));setfenv(f,e);f()
    eq(params.portablespicer.itemtestfn("c",{prefab=stew.name,accepted=true},1),false)
    eq(calls,0)
    eq(params.portablespicer.itemtestfn("c",{prefab="ratatouille",accepted=true},1),true)
    eq(params.portablespicer.itemtestfn("c",{prefab="twigs",accepted=false},1),false)
    eq(calls,2)
end)
-- Execute the actual audited cooking module with empty external registries.
-- These synthetic conflicts test selection, not every Vanilla/mod recipe combination.
test("actual cooking selection resolves priority and weighted conflicts", function()
    local e=setmetatable({}, {__index=_G})
    e.require=function(name)
        if name == "prefabs/oceanfishdef" then return {fish={}} end
        assert(name == "tuning" or name == "preparedfoods" or name == "preparedfoods_warly"
            or name == "spicedfoods" or name == "preparednonfoods", name)
        return {}
    end
    e.math=setmetatable({random=function() return 0.5 end},{__index=math})
    local vanilla="D:/CDesktopLink/Unterlagen/Mods/DST/_scripts/scripts_02_10_2026/scripts/cooking.lua"
    local f=assert(loadfile(vanilla));setfenv(f,e);local cooking=f()
    local own={name=stew.name,test=stew.test,priority=stew.priority,weight=stew.weight,cooktime=stew.cooktime}
    local rival={name="doc_test_rival",test=stew.test,priority=0,weight=1,cooktime=1}
    e.AddCookerRecipe("cookpot",own,true);e.AddCookerRecipe("cookpot",rival,true)
    local ingredients={"carrot","carrot_cooked","carrot","carrot_cooked"}
    eq(cooking.CalculateRecipe("cookpot",ingredients),stew.name)
    rival.priority=stew.priority+1
    eq(cooking.CalculateRecipe("cookpot",ingredients),rival.name)
    rival.priority=stew.priority;rival.weight=3
    local candidates=e.GetCandidateRecipes("cookpot",{names={carrot=2,carrot_cooked=2},tags={veggie=4}})
    eq(#candidates,2)
    -- Sorting puts weight 3 first; deterministic draw 0.5 selects that candidate.
    eq(cooking.CalculateRecipe("cookpot",ingredients),rival.name)
    rival.weight=1
    local selected=cooking.CalculateRecipe("cookpot",ingredients)
    assert(selected==own.name or selected==rival.name) -- No stable equal-weight ordering promised.
end)
local callbacks=dofile("Documentation/examples/character_callbacks.lua")
local function character_fragment()
    local inst={AddTag=function(self,tag) self.tag=tag end}
    callbacks.common_postinit(inst);callbacks.master_postinit(inst)
    return inst
end
test("character callback fragment restores own state without issuing startitems", function()
    local a=character_fragment();a.doc_visits=12;local data={};a:OnSave(data)
    local b=character_fragment();b:OnLoad(data)
    eq(b.doc_visits,12);eq(b.tag,"doc_example_character")
    eq(data.doc_example.version,1)
end)
test("character callback fragment rejects malformed saved state", function()
    for _,n in ipairs({-1,1.5,1000001,math.huge,0/0,"5",false}) do
        local c=character_fragment();c:OnLoad({doc_example={version=1,visits=n}})
        eq(c.doc_visits,0)
    end
    local c=character_fragment();c:OnLoad({doc_example={version=2,visits=5}});eq(c.doc_visits,0)
    c:OnLoad(nil);eq(c.doc_visits,0)
end)
io.write("RESULT ",passed," tests passed; engine and multiplayer not tested\n")
