--[[	Copyright © 2015 Ysovuka/Kzisor	 ]]

-- Used to import mod settings.
GetConfiguration = GetModConfigData

-- Used to delete a specific WatchWorldState.
RemoveWatchState = function(inst, event)
    if inst.worldstatewatching ~= nil then
        for var in pairs(inst.worldstatewatching) do
        	if var == event then
            	TheWorld.components.worldstate:RemoveWatcher(var, inst)
            end
        end
    end
end

-- Checks to see if a string is nil or empty.
IsNilOrEmpty = function (string)
	return string == nil or string == "" and true or false
end

IsNan = function (value)
	if (value ~= value) then
		return true
	end

	if (tostring(value) == (tostring(0/0))) then
		return true
	end

	if (tostring(value) == (tostring(1/0))) then
		return true
	end

	return false

end