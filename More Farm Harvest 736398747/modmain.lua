if not GLOBAL.TheNet:GetIsServer() then
	return
end

local function CropPostInit(self)
	local _Harvest = self.Harvest
	self.Harvest = function(self, harvester)
		local pos = self.inst:GetPosition()
		local ret, product = _Harvest(self, harvester)
		if ret and product and harvester and pos then
            local rand = GLOBAL.GetRandomMinMax(0,1) -- between 0 and 1
            local count = 0
            if rand >= (1-GetModConfigData("one_harvest")) then -- chance for getting one extra
                count = 1
            end
            if rand >= (1-GetModConfigData("two_harvest")) then -- chance for getting two extra
                count = 2
            end
            print("Harvest Mod, give "..count.." extra harvest")
            if count>0 then
                local _prefab = product.prefab
                local _wetness = GLOBAL.TheWorld.state.wetness
                local _iswet = GLOBAL.TheWorld.state.iswet
                -- Giving function to schedule

                local _givefn = function()
                    local extra = GLOBAL.SpawnPrefab(_prefab)
                    if extra.components.inventoryitem then
                        extra.components.inventoryitem:InheritMoisture(_wetness, _iswet)
                        harvester.components.inventory:GiveItem(extra, nil, pos)
                    else
                        extra.Transform:SetPosition(pos.x, pos.y, pos.z)
                    end
                end
                -- For some reason the game can display incorrect stack amounts when giving many items at once
                -- It is better to time them separately
                if count>=1 then
                    harvester:DoTaskInTime(0.23, _givefn)
                end
                if count==2 then
                    harvester:DoTaskInTime(0.46, _givefn)
                end
            end
		end
		return ret, product
	end
end
AddComponentPostInit("crop", CropPostInit)
    
