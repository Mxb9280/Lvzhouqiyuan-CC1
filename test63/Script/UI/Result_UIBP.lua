---@class Result_UIBP_C:UUserWidget
---@field Btn_BackToLobby UButton
---@field Image_266 UImage
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.UGCEventSystem')
UGCGameSystem.UGCRequire('Script.Common.CTCompetitioClientEvent')

local Result_UIBP = {}

function Result_UIBP:Construct()
    ugcprint("Result_UIBP:Construct")
    self.Txt_Result = self:GetWidgetFromName("Txt_Result")
    self.Txt_RedScore = self:GetWidgetFromName("Txt_RedScore")
    self.Txt_BlueScore = self:GetWidgetFromName("Txt_BlueScore")
    self.Btn_BackToLobby = self:GetWidgetFromName("Btn_BackToLobby")
    UGCEventSystem:AddListener(CTCompetitioClientEvent.GameEndEvent, self.OnGameEnd, self)
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function Result_UIBP:Destruct()
    UGCEventSystem:RemoveListener(CTCompetitioClientEvent.GameEndEvent, self.OnGameEnd, self)
end

function Result_UIBP:OnGameEnd(WinnerTeam)
    ugcprint("Result_UIBP:OnGameEnd Winner=" .. tostring(WinnerTeam))
    self:SetVisibility(ESlateVisibility.Visible)

    if WinnerTeam == 1 then
        self.Txt_Result:SetText("红队获胜！")
    elseif WinnerTeam == 2 then
        self.Txt_Result:SetText("蓝队获胜！")
    else
        self.Txt_Result:SetText("平局！")
    end

    local GS = UGCGameSystem.GameState
    if GS and GS.TeamScore then
        self.Txt_RedScore:SetText("红队击杀: " .. tostring(GS.TeamScore[1] or 0))
        self.Txt_BlueScore:SetText("蓝队击杀: " .. tostring(GS.TeamScore[2] or 0))
    end

    if self.Btn_BackToLobby then
        self.Btn_BackToLobby.OnClicked:Add(self, self.OnBackToLobby)
    end
end

function Result_UIBP:OnBackToLobby()
    ugcprint("Result_UIBP:OnBackToLobby")
    UGCGameSystem.QuitGame()
end

return Result_UIBP
