local FoodBuffer = Class(function (self, inst)
  self.inst = inst

  self._buffer = {}
  for i = 1, 6 do
    table.insert(self._buffer, net_string(inst.GUID, "foodbuffer._buffer["..tostring(i).."]"))
  end
end)

function FoodBuffer:SetBuffer(buffer)
  for i, j in pairs(buffer) do
    self._buffer[i]:set(tostring(j))
  end
end

function FoodBuffer:Buffer()
  local buffer = {}
  for i, j in pairs(self._buffer) do
    table.insert(buffer, j:value())
  end
  return buffer
end

return FoodBuffer