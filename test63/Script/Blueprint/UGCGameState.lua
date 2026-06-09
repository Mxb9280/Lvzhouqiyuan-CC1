---@class UGCGameState_C:BP_UGCGameState_C
---@field CurrentGameStatus int32
---@field NextStatusTimeStamp float
---@field WinnerTeam int32
---@field GameEndTime float
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.ue_enum_custom')
UGCGameSystem.UGCRequire('Script.Common.UGCEventSystem')
UGCGameSystem.UGCRequire('Script.Common.CTCompetitioClientEvent')
local UGCGameState = {
    CurrentGameStatus = 0,
    NextStatusTimeStamp = 0,
    TeamScore = {},
    WinnerTeam = -1,
    GameEndTime = 0,   -- 游戏结束时间戳(服务端时间)
};

UGCGameState.TeamScore[1] = 0
UGCGameState.TeamScore[2] = 0

function UGCGameState:ReceiveBeginPlay()
    ugcprint("UGCGameState:ReceiveBeginPlay")
    if not UGCGameSystem.IsServer() then
        UGCWidgetManagerSystem.CreateWidgetAsync(
            UGCMapInfoLib.GetRootLongPackagePath() .. "Asset/UI/ScoreBoard_UIBP.ScoreBoard_UIBP_C",
            function(Widget)
                if Widget then Widget:AddToViewport(100) end
            end
        )
        -- 结算面板预创建，开局透明，结束弹出
        UGCWidgetManagerSystem.CreateWidgetAsync(
            UGCMapInfoLib.GetRootLongPackagePath() .. "Asset/UI/Result_UIBP.Result_UIBP_C",
            function(Widget)
                if Widget then Widget:AddToViewport(1000) end
            end
        )
    end
end

function UGCGameState:GetReplicatedProperties()
    return {"CurrentGameStatus", "Lazy"}, {"NextStatusTimeStamp", "Lazy"}, {"TeamScore", "Lazy"}, {"WinnerTeam", "Lazy"}, {"GameEndTime", "Lazy"}
end

function UGCGameState:AddTeamScore(TeamID)
    self.TeamScore[TeamID] = (self.TeamScore[TeamID] or 0) + 1
    UnrealNetwork.RepLazyProperty(self, "TeamScore")
end

function UGCGameState:OnRep_TeamScore()
end

-- 服务端调：结束游戏并推给客户端
function UGCGameState:ServerEndGame(WinnerTeam)
    self.WinnerTeam = WinnerTeam
    UnrealNetwork.RepLazyProperty(self, "WinnerTeam")
end

-- Multicast: 通知结算
function UGCGameState:MC_ShowGameResult(WinnerTeam)
    UGCEventSystem:SendEvent(CTCompetitioClientEvent.GameEndEvent, WinnerTeam)
end

-- 客户端回调
function UGCGameState:OnRep_WinnerTeam()
end

-- Multicast: 击杀播报，被淘汰者跳过
function UGCGameState:MC_ShowKillBroadcast(VictimName, VictimPlayerKey)
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.PlayerKey ~= VictimPlayerKey then
        UGCEventSystem:SendEvent(CTCompetitioClientEvent.KillBroadcastEvent, VictimName)
    end
end

-- Multicast: 粒子特效
function UGCGameState:MC_SpawnKillParticle(LocX, LocY, LocZ, LifeSpan)
    local EffectClass = UE.LoadClass(UGCMapInfoLib.GetRootLongPackagePath() .. "Asset/Particles/BP_KillEffect.BP_KillEffect_C")
    if not EffectClass then return end
    local Effect = ScriptGameplayStatics.SpawnActor(self, EffectClass, { X = LocX, Y = LocY, Z = LocZ }, { Roll = 0, Pitch = 0, Yaw = 0 }, { X = 1, Y = 1, Z = 1 })
    if Effect then Effect:SetLifeSpan(LifeSpan) end
end

return UGCGameState;
