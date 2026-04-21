local prefabs = {}

for _, char in ipairs(SkinsProject.CharacterList) do
	local charlist = GetActiveCharacterList and GetActiveCharacterList() or MAIN_CHARACTERLIST
    local assets = {
		Asset("ATLAS", "images/inventoryimages/" .. char .. "_switch.xml"),
		Asset("IMAGE", "images/inventoryimages/" .. char .. "_switch.tex"),
	}
    if not table.contains(charlist,char) then -- dont add the asset multiple times
        table.insert(assets, 2, Asset("ANIM", "anim/" .. char .. ".zip"))
        if softresolvefilepath("anim/ghost_" .. char .. "_build.zip") then
            table.insert(assets, 2, Asset("ANIM", "anim/ghost_" .. char .. "_build.zip"))
        end
    end

	local function onbuilt(inst, builder)
		-- builder:MakeWillow()
		SetSkinsOnAnim(builder.AnimState, char, char, builder.components.skinner:GetClothing(), nil, char)
		inst:Remove()
	end

	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
        -- inst.entity:AddMiniMapEntity()
		inst:AddTag("CLASSIFIED")
		inst.persists = false
		inst:DoTaskInTime(0, inst.Remove)

		if not TheWorld.ismastersim then
			return inst
		end
	
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = char .. "_switch"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. char .. "_switch.xml"
		inst.OnBuiltFn = onbuilt
        -- inst.MiniMapEntity:SetIcon(char.."_switch.tex" )
		return inst
	end

	table.insert(prefabs, Prefab(char .. "_switch", fn, assets))
end

return unpack(prefabs)
