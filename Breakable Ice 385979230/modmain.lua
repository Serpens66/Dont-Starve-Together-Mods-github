--[[	Copyright © 2015 Ysovuka/Kzisor	 ]]

-- Import the lib use.
modimport("libs/use.lua")

-- Import the mod environment as our environment.
env = use "libs/mod_env"

use "data/globals"
use "data/prefabs/pond"

TUNING.CRYSTAL_FORMATION_THICKNESS = GetModConfigData("max_thickness")

-- ###
-- tooltips for Insight Mod, code added by Serp
local _G = GLOBAL
local function round2(num, idp)
	return GLOBAL.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
local function AddDescriptors()
	if not _G.rawget(_G, "Insight") then return end
	_G.Insight.descriptors.crystallizable = {
		Describe = function(self, context)
			local description
			
			if self~=nil and self.formation~=nil
			  and self.formation.thickness~=nil
			  and type(self.formation.thickness)=="table"
			  and self.formation.thickness.current~=nil
			  and self.formation.thickness.current>0 then
                description = "Thickness "..tostring(round2(self.formation.thickness.current,1))
            end
			
			return {
				priority = 0,
				description = description
			}
		end
	}
end
AddSimPostInit(AddDescriptors)  -- tooltips for Insight Mod