-- Fragment, not an independently installable creature mod.
require("behaviours/wander")
local DocWanderBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
function DocWanderBrain:OnStart()
    -- Requires locomotor, a compatible SG, and knownlocations on the master.
    self.bt = BT(self.inst, PriorityNode({
        Wander(self.inst, function()
            return self.inst.components.knownlocations:GetLocation("home")
        end, 8),
    }, 0.5))
end
return DocWanderBrain
