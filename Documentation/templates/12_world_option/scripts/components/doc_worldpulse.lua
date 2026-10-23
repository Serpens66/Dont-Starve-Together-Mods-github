local function ValidNumber(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
local Pulse = Class(function(self, inst)
    self.inst = inst
    self.period = TUNING.DOC_PULSE_SECONDS or 30
    self.ticks = 0
    self:Arm(self.period)
end)
function Pulse:Arm(delay)
    if self.task ~= nil then self.task:Cancel() end
    self.deadline = GetTime() + delay
    self.task = self.inst:DoTaskInTime(delay, function()
        self.task = nil
        self.ticks = self.ticks + 1
        print("doc_worldpulse", self.ticks, self.period)
        self:Arm(self.period)
    end)
end
function Pulse:SetPeriod(period)
    if not ValidNumber(period) or period < 15 or period > 60 then return end
    if period == self.period then return end
    local fraction = math.max(0, math.min(1, (self.deadline - GetTime()) / self.period))
    self.period = period
    self:Arm(fraction * period)
end
function Pulse:OnSave()
    return { version = 1, period = self.period, remaining = math.max(0, self.deadline - GetTime()), ticks = self.ticks }
end
function Pulse:OnLoad(data)
    if type(data) ~= "table" or data.version ~= 1 then return end
    local old = ValidNumber(data.period) and data.period >= 15 and data.period <= 60 and data.period or self.period
    local left = ValidNumber(data.remaining) and math.max(0, math.min(old, data.remaining)) or old
    self.ticks = ValidNumber(data.ticks) and math.max(0, math.floor(data.ticks)) or 0
    -- Neue Option behält den relativen Fortschritt eines alten Timers bei.
    self:Arm(left / old * self.period)
end
function Pulse:OnRemoveFromEntity()
    if self.task ~= nil then self.task:Cancel(); self.task = nil end
end
return Pulse
