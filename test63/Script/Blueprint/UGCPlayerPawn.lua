local UGCPlayerPawn = {}

function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)

    if UGCGameSystem.IsServer() then
        self.NearDeatchComponent:SetIsDirectlyDie(true)
    end
end

function UGCPlayerPawn:GetReplicatedProperties()
    return {"__SubObjectRepList", "Lazy"}
end

return UGCPlayerPawn
