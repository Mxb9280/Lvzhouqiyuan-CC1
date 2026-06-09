---@class UGCGameMode_C:BP_UGCGameBase_C
---@field CFG_RespawnInterval float
--Edit Below--
local UGCGameMode = {
    PlayerKeyList = {},
    PlayerSpawnPoint = {},
    RespawnWaitingTime = 3,
    GameDuration = 240,     -- 4分钟
    WinScore = 15,
    GameEndTime = 0,
    bGameEnded = false,
};

function UGCGameMode:ReceiveBeginPlay()
    ugcprint("UGCGameMode:ReceiveBeginPlay")
    if self.CFG_RespawnInterval and self.CFG_RespawnInterval > 0 then
        self.RespawnWaitingTime = self.CFG_RespawnInterval
    end
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerPawn.PawnDefeat, self, self.OnPawnDefeat)
end

function UGCGameMode:ReceiveTick(DeltaTime)
    if self.bGameEnded then return end
    if self.GameEndTime > 0 then
        local Now = UGCGameSystem.GameState:GetServerWorldTimeSeconds()
        if Now >= self.GameEndTime then
            self:EndGameByTime()
        end
    end
end

function UGCGameMode:ReceiveEndPlay()
    UGCGenericMessageSystem.UnListenMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerPawn.PawnDefeat)
end

function UGCGameMode:EndGameByTime()
    local R = self.GameState.TeamScore[1] or 0
    local B = self.GameState.TeamScore[2] or 0
    if R > B then
        self:EndGame(1)
    elseif B > R then
        self:EndGame(2)
    else
        self:EndGame(0)  -- 平局
    end
end

function UGCGameMode:EndGame(WinnerTeam)
    self.bGameEnded = true
    self.GameState:ServerEndGame(WinnerTeam)
    UnrealNetwork.CallUnrealRPC_Multicast_Unreliable(self.GameState, "MC_ShowGameResult", WinnerTeam)
    ugcprint("UGCGameMode:EndGame Winner=" .. tostring(WinnerTeam))
end

-- 登录时分队
function UGCGameMode:UGC_PlayerLoginEvent(PlayerController)
    local PlayerKey = PlayerController.PlayerKey
    if #self.PlayerKeyList % 2 == 0 then
        UGCTeamSystem.ChangePlayerTeamID(PlayerKey, 1)
    else
        UGCTeamSystem.ChangePlayerTeamID(PlayerKey, 2)
    end
    table.insert(self.PlayerKeyList, PlayerKey)
    ugcprint("UGCGameMode:UGC_PlayerLoginEvent PlayerKey=" .. tostring(PlayerKey) .. " TeamID=" .. tostring(PlayerController.TeamID))

    -- 初始出生发武器(Pawn可能还没好, 等1秒)
    local PC = PlayerController
    UGCTimerUtility.CreateLuaTimer(1, function()
        if PC.Pawn then
            UGCBackPackSystem.AddItem(PC.Pawn, 101004, 1)
            UGCBackPackSystem.AddItem(PC.Pawn, 301001, 90)
        end
    end, false)

    -- 第一个玩家登录开始计时
    if self.GameEndTime == 0 then
        self.GameEndTime = UGCGameSystem.GameState:GetServerWorldTimeSeconds() + self.GameDuration
        self.GameState.GameEndTime = self.GameEndTime
        UnrealNetwork.RepLazyProperty(self.GameState, "GameEndTime")
        ugcprint("UGCGameMode:Game timer started, duration=" .. tostring(self.GameDuration))
    end
end

-- 退出
function UGCGameMode:UGC_PlayerExitEvent(PlayerController)
    for i, key in ipairs(self.PlayerKeyList) do
        if key == PlayerController.PlayerKey then
            table.remove(self.PlayerKeyList, i)
            break
        end
    end
end

-- 淘汰处理
function UGCGameMode:OnPawnDefeat(VictimPlayerKey, InstigatorPlayerKey, DamageType)
    if self.bGameEnded then return end
    ugcprint("UGCGameMode:OnPawnDefeat Victim=" .. tostring(VictimPlayerKey) .. " Killer=" .. tostring(InstigatorPlayerKey))

    local Killer = UGCGameSystem.GetPlayerControllerByPlayerKey(InstigatorPlayerKey)
    local VictimPlayer = UGCGameSystem.GetPlayerControllerByPlayerKey(VictimPlayerKey)

    -- 计分 + 检查胜利
    if Killer and VictimPlayer and Killer.TeamID ~= VictimPlayer.TeamID then
        self.GameState:AddTeamScore(Killer.TeamID)
        local Score = self.GameState.TeamScore[Killer.TeamID] or 0
        if Score >= self.WinScore then
            self:EndGame(Killer.TeamID)
            return
        end
    end

    -- 重生
    if VictimPlayer then
        UGCTimerUtility.CreateLuaTimer(self.RespawnWaitingTime, function()
            UGCGameSystem.RespawnPlayer(VictimPlayer.PlayerKey)
        end, false)
    end

    -- 播报 + 粒子 Multicast
    local Loc = VictimPlayer.Pawn and VictimPlayer.Pawn:K2_GetActorLocation() or VictimPlayer:K2_GetActorLocation()
    UnrealNetwork.CallUnrealRPC_Multicast_Unreliable(self.GameState, "MC_ShowKillBroadcast", VictimPlayer.PlayerName, VictimPlayer.PlayerKey)
    UnrealNetwork.CallUnrealRPC_Multicast_Unreliable(self.GameState, "MC_SpawnKillParticle", Loc.X, Loc.Y, Loc.Z, self.RespawnWaitingTime)
end

-- 重生发武器
function UGCGameMode:UGC_PlayerRespawnEvent(RespawnedController)
    ugcprint("UGCGameMode:UGC_PlayerRespawnEvent PlayerKey=" .. tostring(RespawnedController.PlayerKey))
    if RespawnedController.Pawn then
        UGCBackPackSystem.AddItem(RespawnedController.Pawn, 101004, 1)
        UGCBackPackSystem.AddItem(RespawnedController.Pawn, 301001, 90)
    end
end

-- 出生点
function UGCGameMode:FindPlayerStart(Player, IncomingName)
    local PlayerKey = Player.PlayerKey
    if self.PlayerSpawnPoint[PlayerKey] then return self.PlayerSpawnPoint[PlayerKey] end
    local TeamID = Player.TeamID
    if TeamID < 0 then TeamID = 1 end
    local PlayerStartClass = UGCObjectUtility.LoadClass("/Game/BluePrints/Player/PlayerStart/BP_STPlayerStart.BP_STPlayerStart_C")
    local PlayerStartList = UGCObjectUtility.GetAllActorsOfClass(self, PlayerStartClass)
    for i = 1, #PlayerStartList do
        local PS = PlayerStartList[i]
        if PS and PS.PlayerBornPointID == TeamID then
            local used = false
            for _, v in pairs(self.PlayerSpawnPoint) do
                if v == PS then used = true; break end
            end
            if not used then self.PlayerSpawnPoint[PlayerKey] = PS; return PS end
        end
    end
end

return UGCGameMode;
