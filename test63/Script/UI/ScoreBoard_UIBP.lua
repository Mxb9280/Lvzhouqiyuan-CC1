---@class ScoreBoard_UIBP_C:UUserWidget
---@field Txt_BlueScore UTextBlock
---@field Txt_KillMsg UTextBlock
---@field Txt_RedScore UTextBlock
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.UGCEventSystem')
UGCGameSystem.UGCRequire('Script.Common.CTCompetitioClientEvent')

local ScoreBoard_UIBP = { GameDuration = 240 }

function ScoreBoard_UIBP:Construct()
    ugcprint("ScoreBoard_UIBP:Construct")
    self.Txt_RedScore = self:GetWidgetFromName("Txt_RedScore")
    self.Txt_BlueScore = self:GetWidgetFromName("Txt_BlueScore")
    self.Txt_KillMsg = self:GetWidgetFromName("Txt_KillMsg")
    self.Txt_Timer = self:GetWidgetFromName("Txt_Timer")
    UGCEventSystem:AddListener(CTCompetitioClientEvent.KillBroadcastEvent, self.ShowKillMsg, self)
    self.StartTime = UGCGameSystem.GameState:GetServerWorldTimeSeconds()
    self:UpdateScore()
end

function ScoreBoard_UIBP:Destruct()
    UGCEventSystem:RemoveListener(CTCompetitioClientEvent.KillBroadcastEvent, self.ShowKillMsg, self)
end

function ScoreBoard_UIBP:Tick(DeltaTime)
    self:UpdateScore()
end

function ScoreBoard_UIBP:UpdateScore()
    local GS = UGCGameSystem.GameState
    if GS and GS.TeamScore then
        self.Txt_RedScore:SetText("红队: " .. tostring(GS.TeamScore[1] or 0))
        self.Txt_BlueScore:SetText("蓝队: " .. tostring(GS.TeamScore[2] or 0))
    end

    if self.Txt_Timer and self.StartTime then
        local elapsed = UGCGameSystem.GameState:GetServerWorldTimeSeconds() - self.StartTime
        local remain = self.GameDuration - elapsed
        if remain < 0 then remain = 0 end
        local min = math.floor(remain / 60)
        local sec = math.floor(remain % 60)
        self.Txt_Timer:SetText(string.format("%02d:%02d", min, sec))
    end
end

function ScoreBoard_UIBP:ShowKillMsg(VictimName)
    ugcprint("ScoreBoard_UIBP:ShowKillMsg " .. tostring(VictimName))
    self.Txt_KillMsg:SetText(tostring(VictimName) .. " 被击倒")
    UGCTimerUtility.CreateLuaTimer(3, function()
        self.Txt_KillMsg:SetText("")
    end, false)
end

return ScoreBoard_UIBP
