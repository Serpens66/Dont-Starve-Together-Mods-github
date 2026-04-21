local spicedfoods = require("spicedfoods")
local TheCookbook = require("cookbookdata")() -- just for the RemoveCookedFromName function

local updatebuffer = function (self, buffer)
  self.inst.replica._foodbuffer:SetBuffer(buffer)
end

local FoodBuffer = Class(function (self, inst)
  self.inst = inst
  self.buffer = {false,false,false,false,false,false}  -- fill it up to 6, so latest eaten food is always at same position
  self.disabled = {}
  self.multipliers = {}
  self.favorites = {}
end)

function FoodBuffer:SetMultipliers(multipliers)
  if multipliers ~= nil then
    self.multipliers = multipliers
  end
end

function FoodBuffer:SetFavorites(favorites)
  if favorites ~= nil then
    self.favorites = favorites
  end
end

function FoodBuffer:SetDisabled(disabled)
  if disabled ~= nil then
    self.disabled = disabled
  end
end

function FoodBuffer:GetBaseFood(food)
  local prefab = food.prefab
  local base = prefab
  if string.find(TUNING.FOODQUEUE_MOD_BASEFOOD,"spiced")~=nil then
    base = spicedfoods[prefab] ~= nil and spicedfoods[prefab].basename or prefab
  end
  if not food:HasTag("preparedfood") and string.find(TUNING.FOODQUEUE_MOD_BASEFOOD,"cooked")~=nil and TheCookbook~=nil and string.find(base, "cooked") ~= nil then
    local without_cooked = TheCookbook:RemoveCookedFromName({base})[1]
    if PrefabExists(without_cooked) then
      base = without_cooked -- minor problem: eg birchnuts are only eadible while cooked, so adding an uncooked birchnut to the queue looks weird, but everything wil still work as intended I think
    end
  end
  if not food:HasTag("preparedfood") and string.find(TUNING.FOODQUEUE_MOD_BASEFOOD,"seeds")~=nil and string.find(base, "seeds")~= nil then
    base = "seeds"
  end
  return base
end

function FoodBuffer:IsProtected(food)
  if food~=nil and food.prefab~=nil then
    local prefab = food.prefab
    prefab = self:GetBaseFood(food)
    for _, d in pairs(self.disabled) do
        if d == prefab then return true end
    end
    for _, f in pairs(self.favorites) do
        if f == prefab then return true end
    end
  end
  return false
end

function FoodBuffer:IsInBuffer(food)
  if food~=nil and food.prefab~=nil then
      local prefab = food.prefab
      prefab = self:GetBaseFood(food)
      for i, p in pairs(self.buffer) do
        if p == prefab then
          return i
        end
      end
  end
  return nil
end

function FoodBuffer:GetMultiplier(food)
  if food~=nil and food.prefab~=nil then
    local prefab = food.prefab
    local index = self:IsInBuffer(food)
    if index ~= nil then
      local mult = self.multipliers[#self.multipliers - #self.buffer + index]
      if mult == nil then
        return 0.1
      end
      return mult
    end
  end
  return 1
end

function FoodBuffer:AddToBuffer(food)
  if food~=nil and food.prefab~=nil then
    local prefab = food.prefab
    prefab = self:GetBaseFood(food)
    local index = self:IsInBuffer(food)
    if index ~= nil then
      table.remove(self.buffer, index)
    end
    if #self.buffer >= #self.multipliers then
      table.remove(self.buffer, 1)
    end
    if not self:IsInBuffer(food) then table.insert(self.buffer, prefab) end
    updatebuffer(self, self.buffer)
  end
end

function FoodBuffer:OnSave()
  if next(self.buffer) ~= nil then
    return { buffer = self.buffer }
  end
end

function FoodBuffer:OnLoad(data)
  if data.buffer ~= nil then self.buffer = data.buffer end
  updatebuffer(self, self.buffer)
end

return FoodBuffer