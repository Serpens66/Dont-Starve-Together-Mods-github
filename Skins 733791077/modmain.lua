local aChars =
    {
    {prefab="Archer",name=nil,descr=nil}, -- if name is nil, the prefab will be use. if description is nil, the name will be used.
    {prefab="Saber",name=nil,descr=nil},
	{prefab="Tamamo",name=nil,descr=nil},
	{prefab="Rin",name=nil,descr=nil},
	{prefab="Zoro",name=nil,descr=nil},
	{prefab="Sanji",name=nil,descr=nil},
	{prefab="Plutia",name=nil,descr=nil},
	{prefab="Law",name=nil,descr=nil},
	{prefab="Kasen",name=nil,descr=nil},
	{prefab="Casteryoung",name="Caster",descr=nil},
	{prefab="Rei",name=nil,descr=nil},
	{prefab="Momiji",name=nil,descr=nil},
	{prefab="Mokou",name=nil,descr=nil},
	{prefab="Sdabigail",name="Abbigail",descr=nil},
    {prefab="Esctemplate",name="Cat",descr=nil},
    {prefab="Medic",name=nil,descr=nil},
    {prefab="Spek",name="Spekkle",descr=nil},
    {prefab="Spekspr",name="Spekkle Spring",descr=nil},
    {prefab="Speksum",name="Spekkle Summer",descr=nil},
    {prefab="Spekwin",name="Spekkle Winter",descr=nil},
    {prefab="Musha",name=nil,descr=nil},
    {prefab="musha_battle_k",name="Musha Battle",descr=nil},
    {prefab="dress_redeye",name="Seele",descr="Seele Dress Redeye"},
    {prefab="kagerou",name=nil,descr=nil},
    {prefab="ruby",name=nil,descr=nil},
    {prefab="issac",name=nil,descr=nil},
    {prefab="urara",name=nil,descr=nil},
    {prefab="broccoli",name=nil,descr=nil},
    {prefab="aoba_idol",name="Aoba Idol",descr=nil},
    {prefab="lamb",name=nil,descr=nil},
    {prefab="hakuya",name=nil,descr=nil},
    {prefab="finnthehuman",name=nil,descr=nil},
    {prefab="morty",name=nil,descr=nil},
    }

local aGamechars = 
    {
    {prefab="Warly",name=nil,descr=nil}, -- if name is nil, the prefab will be use. if description is nil, the name will be used.
    {prefab="Walani",name=nil,descr=nil},
    {prefab="Wilbur",name=nil,descr=nil},
    {prefab="Woodlegs",name=nil,descr=nil},
    {prefab="Wathgrithr",name="Wigfrid",descr=nil},
    {prefab="Wickerbottom",name=nil,descr=nil},
    {prefab="Wilson",name=nil,descr=nil},
    {prefab="Wx78",name="WX-78",descr=nil},
    {prefab="Willow",name=nil,descr=nil},
    {prefab="Wes",name=nil,descr=nil},
    {prefab="Wolfgang",name=nil,descr=nil},
    {prefab="Woodie",name=nil,descr=nil},
    {prefab="Wendy",name=nil,descr=nil},
    {prefab="Webber",name=nil,descr=nil},
    {prefab="Waxwell",name=nil,descr=nil},
    }      
    

if GLOBAL.rawget(GLOBAL,"SkinsProject")~=nil then
    for k,v in ipairs(aGamechars) do   -- gamechars first
        GLOBAL.SkinsProject.AddSkin(v.prefab:lower(),v.name, v.descr)
    end
        
    for k,v in ipairs(aChars) do
        GLOBAL.SkinsProject.AddSkin(v.prefab:lower(),v.name, v.descr)
    end
end