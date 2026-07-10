-- Descriptor for Insight Mod: https://github.com/penguin0616/Insight/blob/master/doc/Adding%20Modded%20Information.md

-- inst is the component or prefab being described
-- see rest of docs for context
local function Describe(inst, context)
	local description = ""
  local str = nil
  local name = nil
  if inst.prefab == "turf_woodfloor" then 
      name = "wooden"        
  elseif inst.prefab == "turf_carpetfloor" then
      name = "carpet"
  elseif inst.prefab == "turf_checkerfloor" then
      name = "checker"
  end
  
  -- damagemult
  local damagemult = GetModConfigData("damage_"..name)
  if damagemult~=nil and damagemult>0 and type(context.lstr.weapon_damage)=="string" and type(context.lstr.weapon_damage_type.normal)=="string" then
      -- description = description.."DamageMult: *"..tostring(round2(damagemult,2)).."\n"
      description = description..string.format(context.lstr.weapon_damage, context.lstr.weapon_damage_type.normal, "*"..tostring(damagemult)).."\n"
      
  end
  -- insulation
  local season,insulation
  if GetModConfigData("insulation_time_"..name) >= GetModConfigData("summer_insulation_time_"..name) then -- if summer and winter are the same, or winter is higher, show only the winter insulation
      insulation = GetModConfigData("insulation_time_"..name) -- default type is winter
      season = "WINTER"
  else -- if summer insulation is higher, show the summer insulation
      insulation = GetModConfigData("summer_insulation_time_"..name) 
      season = "SUMMER"
  end
  if insulation~=nil and insulation>0 then
      str = (season:lower() == "winter" and context.lstr.insulation_winter) or (season:lower() == "summer" and context.lstr.insulation_summer) or "?"
      description = description..string.format(str, insulation).."\n"
  end
  -- armor
  local armor = GetModConfigData("absorb_"..name)
  if armor~=nil and armor>0 and type(context.lstr.protection)=="string" then
      description = description..string.format(context.lstr.protection, armor * 100).."\n"
  end
  -- rain_reduction_
  local waterproof = 1-GetModConfigData("rain_reduction_"..name)
  if waterproof~=nil and waterproof>0 and type(context.lstr.waterproofness)=="string" then
      description = description..string.format(context.lstr.waterproofness, waterproof * 100).."\n"
  end
  -- sanityboost
  local SanityList = {GLOBAL.TUNING.DAPPERNESS_TINY,GLOBAL.TUNING.DAPPERNESS_SMALL,GLOBAL.TUNING.DAPPERNESS_MED,GLOBAL.TUNING.DAPPERNESS_MED_LARGE,GLOBAL.TUNING.DAPPERNESS_LARGE}
  local plus = SanityList[GetModConfigData("sanity_boost_"..name)]
  if plus~=nil and plus>0 and context.lstr.sanityaura and type(context.lstr.sanityaura.aura_value)=="string" then
      description = description..string.format(context.lstr.sanityaura.aura_value, round2(plus,3)).."\n"
  end
  -- speedmult
  local speed = GetModConfigData("speed_mult_"..name)
  if speed~=nil and speed>0 then
      description = description.."SpeedMult: *"..tostring(round2(speed,2)).."\n"
  end
  
  return {
      priority = 0, -- The priority of this information. Higher priority means closer to the top.
      description = description,
      -- alt_description = nil,
  }
end

-- Can return nil or a table.
return {
	Describe = Describe
}