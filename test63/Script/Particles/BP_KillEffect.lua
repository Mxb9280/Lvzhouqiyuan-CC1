---@class BP_KillEffect_C:AActor
---@field ParticleSystem UParticleSystemComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local BP_KillEffect = {}
 
--[[
function BP_KillEffect:ReceiveBeginPlay()
    BP_KillEffect.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function BP_KillEffect:ReceiveTick(DeltaTime)
    BP_KillEffect.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function BP_KillEffect:ReceiveEndPlay()
    BP_KillEffect.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function BP_KillEffect:GetReplicatedProperties()
    return
end
--]]

--[[
function BP_KillEffect:GetAvailableServerRPCs()
    return
end
--]]

return BP_KillEffect