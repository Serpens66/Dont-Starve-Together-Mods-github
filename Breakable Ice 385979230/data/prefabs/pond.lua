--[=[	

	Code copyright © 2015 Ysovuka/Kzisor
	
	Equation has no copyright.
	Growth Equation: Thickness = (1.33 * (FDD * (T^0.58)))
	T = Temperature (°C Celsius)
	FDD = Freezing Degree Days

	FDD Equation:	FDD = F - AvgT / D 
	F = Freezing Temperature of Liquid
	AvgT = Average Temperature of Period
	D = Days in Period

	Snow Depth: A snow depth above 30 to 45 cm will cause ice growth to slow.
	Snow Depth Equation:	(SD / Thickness)
	SD = Snow Depth/Level
	Thickness = Ice Growth Equation Thickness 	

--]=]

--	Import the configurations for our mod.
use "data/configs/pond"

--	CalculateFreezingDegree(inst)
--	This function is used to calculate the freezing day degree of our formation.
local function CalculateFormationDegree(inst)
	
	local average = inst.components.crystallizable:GetAverageTemperature()

	--	Reduces the formation degree by the average degree and then multiplies it by 16 segments divided by total world time of 480 seconds.
	local ret = ((inst.components.crystallizable.formation.degree - average) * ( 16 / 480 ))

	if IsNan(ret) then return 1 end

	return ret

end

--	CalculateGrowth(inst)
--	This function is used to calculate the growth of our formation.
local function CalculateGrowth(inst)

	local formation_degree = CalculateFormationDegree(inst)
	
	-- Calculates the right side of the final equation.
	local equation_right = math.pow(math.abs(formation_degree * inst.components.crystallizable.formation.temperature.current), 0.58)

	-- Determines if we are maturing or diminishing the formation.
	if inst.components.crystallizable.formation.temperature.current > 0 then
		
		equation_right = (-1 * equation_right)

	end

	local ret = 0

	--	Obtain the snowlevel to be used in the final equation.
	local snowlevel = TheWorld.state.snowlevel

	--	If snowlevel is equal to 0 do not change the formula. If it's not equal change the formula based on snowlevel.
	if not snowlevel == 0 then

		ret = ((1.33 * equation_right) / (snowlevel * (16 / 480)))

	else

		ret = (1.33 * equation_right)

	end

	if IsNan(ret) then return 0 end

	return ret

end

--	FormationDelay()
--	This function is used to calculate the formation delay.
local function FormationDelay(inst)

	if inst.pondtype == "" then

		return (((96 * pond.formation.delay.hours) + (24 * pond.formation.delay.minutes)))

	elseif inst.pondtype == "_mos" then

		return (((96 * swamp.formation.delay.hours) + (24 * swamp.formation.delay.minutes)))

	end

end

--	PondPostInit(inst)
--	This function is called by the AddPrefabPostInit function.
local function PondPostInit(inst)

	--	Server side only code, do nt change things on client.
	if not TheWorld.ismastersim then
		return inst
	end

	if inst.task ~= nil then

		inst.task:Cancel()

		inst.task = nil
	end

	--	Remove the watch for world state snowlevel.
	RemoveWatchState(inst, "snowlevel")

	--	Remove the watch for world state isday.
	RemoveWatchState(inst, "isday")

	--	Add the temperature component to our pond instance.
	inst:AddComponent("temperature")

	--	Configure the crystallizable component for our pond instance.
	inst:AddComponent("crystallizable")
	inst.components.crystallizable:SetFormationDegrees(math.random(-1.8, 0))
	inst.components.crystallizable:SetLiquid("water")
	inst.components.crystallizable:SetInquiry(CalculateGrowth)
	inst.components.crystallizable:SetFormationDelay(FormationDelay(inst))


	--	OnEstablished(inst)
	--	This function is used when our formation has become established.
	local function OnEstablished(inst)

		-- Set inst.frozen to acknowledge our pond has frozen.
		inst.frozen = true

		-- Set the pond animation to frozen.
		inst.AnimState:PlayAnimation("frozen")
		inst.SoundEmitter:PlaySound("dontstarve/winter/pondfreeze")

		-- Error Prevention: inst.components.fishable
		if inst.components.fishable then
			inst.components.fishable:Freeze()
		end

		-- Set the physics for the pond instance.
		inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.WORLD)
		inst.Physics:CollidesWith(COLLISION.ITEMS)

		-- Remove all decor from the pond.
		if inst.decor then
			for i,item in ipairs(inst.decor) do
				item:Remove()
			end
		end

		inst.decor = {}

		-- Create our workable component if it doesn't exist on the pond isntance.
		inst:AddWorkableFormation(inst)

		inst:RemoveTag("watersource")

	end

	inst:ListenForEvent("Crystallizable:Established", OnEstablished)

	--	OnDestroyed(inst)
	--	This function is used when our formation has been destroyed.
	local function OnDestroyed(inst)

		-- Set inst.frozen to acknowledge our pond has thawed.
		inst.frozen = false
		inst.AnimState:PlayAnimation("idle"..inst.pondtype)

		-- Error Prevention: inst.components.fishable
    	if inst.components.fishable then
    		inst.components.fishable:Unfreeze()
    	end

    	-- Set the physics for the pond instance.
		inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    	inst.Physics:ClearCollisionMask()
    	inst.Physics:CollidesWith(COLLISION.WORLD)
    	inst.Physics:CollidesWith(COLLISION.ITEMS)
    	inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    	-- Spawn our plants.
		inst:SpawnPlants(inst, inst.planttype)

		-- Error Prevention: inst.components.workable
		inst:RemoveWorkableFormation(inst)

		inst:AddTag("watersource")

	end

	inst:ListenForEvent("Crystallizable:Destroyed", OnDestroyed)

	--	OnMatured(inst, amount)
	--	This function is called when our formation has matured.
	local function OnMatured(inst, amount)
		--	Increase the work left on our workable component.

		--	Error Prevention: inst.components.workable
		if inst.components.workable then
			inst.components.workable:SetWorkLeft( inst.components.crystallizable:GetThickness( ) )
		end

	end

	inst:ListenForEvent("Crystallizable:Matured", OnMatured)

	--	OnDiminish(inst, amount)
	--	This function is called when our formation has diminished.
	local function OnDiminished(inst, amount)
		--	Decrease the work left on our workable component.

		--	Error Prevention: inst.components.workable
		if inst.components.workable then
			inst.components.workable:SetWorkLeft( inst.components.crystallizable:GetThickness( ) )
		end

	end

	inst:ListenForEvent("Crystallizable:Diminished", OnDiminished)   
    

	--	Pond:AddWorkableFormation(inst)
	--	This function is used when our formation has been established.
	function inst:AddWorkableFormation(inst)

		--	Error Prevention: inst.components.workable
		if not inst.components.workable then
			inst:AddComponent("workable")
			inst.components.workable:SetWorkAction(ACTIONS.MINE)
			inst.components.workable:SetWorkLeft(1)
		end
        if not inst.components.lootdropper then--serp
			inst:AddComponent("lootdropper")
			inst.components.lootdropper:SetLoot(nil)
            inst.components.lootdropper:SetChanceLootTable("rock_ice_short")
		end

	end

	--	Pond:RemoveWorkableFormation(inst)
	--	This function is used when our formation has been destroyed.
	function inst:RemoveWorkableFormation(inst)

		--Error Prevention: inst.components.workable
		if inst.components.workable then
			inst:RemoveComponent("workable")
            inst:RemoveComponent("lootdropper")-- serp
		end

	end

	--	Pond:SpawnPlants(inst, plantname)
	--	This function is used when our formation has been destroyed.
	--	Directly copied from the pond.lua local function SpawnPlants.
	function inst:SpawnPlants(inst, plantname)

		if inst.decor then
			for i,item in ipairs(inst.decor) do
				item:Remove()
			end
		end
		inst.decor = {}

		local plant_offsets = {}

		for i=1,math.random(2,4) do
			local a = math.random()*math.pi*2
			local x = math.sin(a)*1.9+math.random()*0.3
			local z = math.cos(a)*2.1+math.random()*0.3
			table.insert(plant_offsets, {x,0,z})
		end

		for k, offset in pairs( plant_offsets ) do
			local plant = SpawnPrefab( plantname )
			plant.entity:SetParent( inst.entity )
			plant.Transform:SetPosition( offset[1], offset[2], offset[3] )
			table.insert( inst.decor, plant )
		end

	end


	--	Pond:ReturnChildren(inst)
	--	This function is used when our children are to be returned home.
	--	Directly copied from the pond.lua local function ReturnChildren.
	function inst:ReturnChildren(inst)
		for k,child in pairs(inst.components.childspawner.childrenoutside) do
			if child.components.homeseeker then
				child.components.homeseeker:GoHome()
			end
			child:PushEvent("gohome")
		end
	end


	--	OnIsday(inst, isday)
	--	This function is used when the day changes.
	--	Directly copied from the pond.lua local function OnIsDay.
	local function OnIsDay(inst, isday)
	    if isday ~= inst.dayspawn then
	        inst.components.childspawner:StopSpawning()
	        inst:ReturnChildren(inst)
	    elseif not TheWorld.state.iswinter and not inst.frozen then
	        inst.components.childspawner:StartSpawning()
	    end
	end
	inst:WatchWorldState("isday", OnIsDay)

	inst._OnLoad = inst.OnLoad

	inst.OnLoad = function(data)
		inst._OnLoad(data)
		
		--	Push the destroyed event just to verify that we don't have a frozen pond from original data.
		inst:PushEvent("Crystallizable:Destroyed")

		--	Check for established formations.
		inst.components.crystallizable:CheckEstablished()
	end


	--	Return the instance that we've modified.
	return inst
end

AddPrefabPostInit("pond", PondPostInit)
AddPrefabPostInit("pond_mos", PondPostInit)

if KnownModIndex:IsModEnabled("workshop-364821573") then
	AddPrefabPostInit("pond_cave", PondPostInit)
end

if KnownModIndex:IsModEnabled("workshop-369544255") then
	AddPrefabPostInit("sktiletroupplepond", PondPostInit)
end