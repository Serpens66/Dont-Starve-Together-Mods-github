--[[	Copyright © 2015 Ysovuka/Kzisor	 ]]

-- Used to delete a specific WatchWorldState.
local RemoveWatchState = function(inst, event)
    if inst.worldstatewatching ~= nil then
        for var in pairs(inst.worldstatewatching) do
        	if var == event then
            	TheWorld.components.worldstate:RemoveWatcher(var, inst)
            end
        end
    end
end


local Crystallizable = Class(function(self, inst)

	--	Sets our parent inst to the variable self.inst
	self.inst = inst
    self.lootmanager = 0
	--	Variable used to contain the name of the crystallizable material.
	self.liquid = nil

	--	Variable used to contain the previous segments time.
	self.clock = {
		segments = {
			day = 0,
			dusk = 0,
			night = 0,
		},
		time = nil,
	}

	--	Variable used to contain the cystallization information.
	self.formation = {
		canestablish = true,
		degree = 0,
		established = false,
		inquiry = nil,
		thickness = {
			current = 0,
			max = TUNING.CRYSTAL_FORMATION_THICKNESS,
		},

		temperature = {
			average = 0,
			average_count = 0,
			current = 0,
		},
	}

	--	Variable used to contain the time alotted for crystallization to be post poned.
	self.timer = {
		delay = 0,
		task = nil,
	}

	--	CreateTask()
	--	This function is used to create the timer task.
	local function CreateTask()

		--	Delete the current task if there is one running.
		if self.timer.task ~= nil then
			self.timer.task = nil
		end

		-- print( self.timer.delay )

		self.timer.task = self.inst:DoTaskInTime(self.timer.delay, function() self.formation.canestablish = true end)

	end

	--	OnStartDay(inst)
	--	This function is called when the day starts.
	local function OnStartDay(inst)
		--	Clear the average temperature for the previous day.
		self.formation.temperature.average = 0
		self.formation.temperature.average_count = 0
	end

	self.inst:WatchWorldState("startday", OnStartDay)

	--	OnFinished(inst, worker)
	--	This function is called when a player has destroyed the formation.
	local function OnFinished(inst, worker)

		--	Set the ability for our formation to be established.
		self.formation.canestablish = false

		--	Set the establishment of the formation to be destroyed.
		self.formation.established = false

		--	Push event to denote that the formation has been destryed.
		self.inst:PushEvent("Crystallizable:Destroyed")
        -- self:SetThickness( 0 )

		--	Call the CreateTask function to start our timer.
		CreateTask()

	end

	self.inst:ListenForEvent("workfinished", OnFinished)

	--	OnWorked(inst, worker, workleft)
	--	This function is called when a player works on breaking the crystallized formation.
	local function OnWorked(inst, worker, workleft)
        -- print("worker: "..tostring(worker))
		--	Push event to denote that the formation has diminished.
		-- self.inst:PushEvent("Crystallizable:Worked") -- to set the workleft to thickness value, as soon as workleft is 0 , OnFinished will be called
		if self.lootmanager == 3 then -- give ice for every 4th hit with pickaxe
            local pt = self.inst:GetPosition()
            if self.inst.components.lootdropper then self.inst.components.lootdropper:SpawnLootPrefab("ice", pt) end
            self.lootmanager = 0
        else
            self.lootmanager = self.lootmanager + 1 
        end
        --	Decrease the formation thickness.
		
        if workleft==nil then
            workleft = self.inst.components.workable.workleft 
        end
        self:SetThickness( workleft )
        self.inst:PushEvent("Crystallizable:Worked") -- not needed. dont set the workleft value when worked!, only when melting or freezing
	end

	self.inst:ListenForEvent("worked", OnWorked)
    
	--	OnClockSegmentsChanged(inst, data)
	--	This function is called when the world clock segments change.
	local function OnClockSegmentsChanged(inst, data)

		--	Set the number of day segments.
		self.clock.segments.dawn = data.dawn or 0

		--	Set the number of day segments.
		self.clock.segments.day = data.day or 0

		--	Set the number of dusk segments.
		self.clock.segments.dusk = data.dusk or 0

		--	Set the number of night segments.
		self.clock.segments.night = data.night or 0

	end

	self.inst:ListenForEvent("clocksegschanged", OnClockSegmentsChanged, TheWorld)

	--	AddTemperatureChange(inst)
	--	This function is called then the temperature changes.
	local function AddTemperature()

		local current = self.inst.components.temperature.current

		self.formation.temperature.current = current
		self.formation.temperature.average = self.formation.temperature.average + current

		--	Increase the average temperature count.
		self.formation.temperature.average_count = self.formation.temperature.average_count + 1
	end

	--	OnClockTick(inst, data)
	--	This function is called when the world clock tic\ks.
	local function OnClockTick(inst, data)

		--	Add our temperature to our calculation on each clock tick.
		AddTemperature()
		
		--	Determine whether we have a recent segment.
		if self.clock.time ~= nil then
			
			local previous_segment = math.floor(self.clock.time * ((self.clock.segments.dawn or 0) + self.clock.segments.day + self.clock.segments.dusk + self.clock.segments.night))
			local next_segment = math.floor(data.time * ((self.clock.segments.dawn or 0) + self.clock.segments.day + self.clock.segments.dusk + self.clock.segments.night))

			if previous_segment ~= next_segment then

				--	check to see the crystals are established.
				if self.formation.established then

					--	Calculate the growth of the cystallization.
					local growth = self.formation.inquiry(self.inst)

					--	Increase or decrease the thickness of the formation.
					local thickness = self:GetThickness() + growth
				
					if thickness < 0 then
						--	Push event to denote that the formation has been destryed.
						self.inst:PushEvent("Crystallizable:Destroyed")

						--	Set formation thickness to 0 as it's been destroyed.
						self:SetThickness( 0 )

						--	Set the establishment of the formation to false.
						self.formation.established = false

						--	Set the ability for our formation to be established.
						self.formation.canestablish = true

						--print("Formation has been destroyed.")

					elseif thickness >= self:GetMaxThickness() then
						
						--	Set formation thickness to our new thickness as it has not been destroyed.						
						self:SetThickness( self:GetMaxThickness() )

					else

						--	Set formation thickness to our new thickness as it has not been destroyed.						
						self:SetThickness( thickness )

					end
                    
                    if growth > 0 then
						--	Push event to denote that the formation has matured.
						self.inst:PushEvent("Crystallizable:Matured", growth)

						--print("Formation has matured by "..growth)
					elseif growth < 0 then
						--	Push event to denote that the formation has diminished.
                        self.inst:PushEvent("Crystallizable:Diminished", growth)
                        
						--print("Formation has diminished by "..growth)
					end

				end

			end

			--	Check to see if the temperature is cold enough for our pond to freeze.
			if self.formation.temperature.current < self.formation.degree and self.formation.canestablish then
			
				--	Check to see if we have crystals forming.
				if self.formation.inquiry(self.inst) > 1 then

					--	Set the ability for our formation to be established.
					self.formation.canestablish = false

					--	Push event to denote that the crystllization has started to become established.
					self.inst:PushEvent("Crystallizable:Established")

					--	Set the formation to be established.
					self.formation.established = true

					--	Set the formation thickness to allow for growth.
					if self:GetThickness() == 0 then -- if not, dont change it, cause it would overwrite the previously saved/loaded values
                        self:SetThickness( 1 )
                    end 

					--print("Establishing formation.")
				end

			end

			--print("Temperature: "..self.formation.temperature.current)

		end

		--	Set the previous segment.
		self.clock.time = data.time

	end

	self.inst:ListenForEvent("clocktick", OnClockTick, TheWorld)

	--	OnIsSummer(inst, issummer)
	--	This function is called by the world state issummer.
	local function OnIsSummer(inst, issummer)
		
		--	Check to see if the formation thickness is greater than 0.
		if self:GetThickness() > 0 then

			--	Reduce the initial amount of formation thickness when spring begins by a quarter.
			local growth = (self:GetThickness() - (self:GetThickness() * 0.25))

			--	Push event to denote that the formation has diminished.
			self.inst:PushEvent("Crystallizable:Diminished", growth)

			self:SetThickness( self:GetThickness() - growth )

		end

	end

	inst:WatchWorldState("issummer", OnIsSummer)

	--	OnIsSpring(inst, isspring)
	--	This function is called by the world state isspring.
	local function OnIsSpring(inst, isspring)

		--	Check to see if the formation thickness is greater than 0.
		if self:GetThickness() > 0 then

			--	Reduce the initial amount of formation thickness when spring begins by a quarter.
			local growth = (self:GetThickness() - (self:GetThickness() * 0.25))

			--	Push event to denote that the formation has diminished.
			self.inst:PushEvent("Crystallizable:Diminished", growth)

			self:SetThickness( self:GetThickness() - growth )

		end

	end

	inst:WatchWorldState("isspring", OnIsSpring)

end)

--	Crystallizable:CheckEstablished()
--	This function is used to determine if they 
function Crystallizable:CheckEstablished()
	if self.formation.established then
		--	Push event to denote that the crystllization has started to become established.
		self.inst:PushEvent("Crystallizable:Established")

		--	Push event to denote that the formation has matured.
		self.inst:PushEvent("Crystallizable:Matured", self:GetThickness( ) )
	end
end

--	Crystallizable:GetAverageTemperature()
--	This function will pass the average temperature if it's not nil or nan.
function Crystallizable:GetAverageTemperature()
	
	local ret = (self.formation.temperature.average / self.formation.temperature.average_count)

	if (tostring(ret) == tostring(0/0)) or (tostring(ret) == tostring(1/0)) or ret ~= ret then
		
		return self.formation.temperature.current

	end

	return ret

end

function Crystallizable:GetThickness()

	return self.formation.thickness.current or 0

end

function Crystallizable:GetMaxThickness()

	return self.formation.thickness.max

end

function Crystallizable:SetThickness( val )

	if val ~= nil then
        -- if self.formation.thickness.current~=nil then
            -- if val<self.formation.thickness.current then
                -- print(tostring(self.inst).." thickness verringert von: "..self.formation.thickness.current.." nach: "..val)
            -- end
        -- end
		self.formation.thickness.current = val
        
	end

end

--	Crystallizable:OnSave()
--	This function is called when the server saves data.
function Crystallizable:OnSave()
	return 
		{
			clock = {
				segments = {
					dawn = self.clock.segments.dawn,
					day = self.clock.segments.day,
					dusk = self.clock.segments.dusk,
					night = self.clock.segments.night,
				},
				time = self.clock.time,
			},

			formation = {
				canestablish = self.formation.canestablish,
				degree = self.formation.degree,
				established = self.formation.established,
				thickness = self.formation.thickness,
				temperature = {
					average = self.formation.temperature.average,
					average_count = self.formation.temperature.average_count,
					current = self.formation.temperature.current,
				},
			},

			liquid = self.liquid,

			timer = {
				delay = self.timer.delay,
			},
		}

end

--	Crystallizable:OnLoad(data)
--	This function is called when the server loads data.
function Crystallizable:OnLoad(data)
	if data ~= nil then
		-------------------------------------------------------		
		-- Compatibility with Dawn mod.
		self.clock.segments.dawn = data.clock.segments.dawn or nil

		-------------------------------------------------------

		self.clock.segments.day = data.clock.segments.day or nil
		self.clock.segments.dusk = data.clock.segments.dusk or nil
		self.clock.segments.night = data.clock.segments.night or nil

		self.clock.time = data.clock.time or nil

		self.formation.canestablish = data.formation.canestablish or true
		self.formation.degree = data.formation.degree or 0
		self.formation.established = data.formation.established or false
		self.formation.thickness = type(data.formation.thickness) == "table" and data.formation.thickness or { current = 0, max =TUNING.CRYSTAL_FORMATION_THICKNESS, }
		self.formation.temperature.average = data.formation.temperature.average or 0
		self.formation.temperature.average_count = data.formation.temperature.average_count or 0
		self.formation.temperature.current = data.formation.temperature.current or 0

		self.liquid = data.liquid or nil

		self.timer.delay = data.delay or self.timer.delay or 0
	end

end

-- function Crystallizable:OnUpdate(dt)

-- 	--	Remove the watch for world state snowlevel.
-- 	RemoveWatchState(self.inst, "snowlevel")

-- 	--	Remove the watch for world state isday.
-- 	RemoveWatchState(self.inst, "isday")


-- end

--	Crystallizable:SetFormationDegrees(temperature)
--	This functin will be called when we set the formation degrees of our crystalline structure.
function Crystallizable:SetFormationDegrees(temperature)

	self.formation.degree = temperature

end

--	Crystallizable:SetFormationDelay(time)
--	This function is used to set the formation delay of the crystallization process.
function Crystallizable:SetFormationDelay(time)

	self.timer.delay = time

end

--	Crystallizable:SetInquiry(func)
--	This function will be called when we set the function for the inquiry.
function Crystallizable:SetInquiry(func)

	self.formation.inquiry = func

end

--	Crystallizable:SetLiquid(liquid)
--	This function is simply used to acknowledge the material which is able to be crystallized.
function Crystallizable:SetLiquid(liquid)

	self.liquid = liquid

end

return Crystallizable