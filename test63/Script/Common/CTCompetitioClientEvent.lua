
CTCompetitioClientEvent = CTCompetitioClientEvent or {}; 

CTCompetitioClientEvent.GameStatusChanged									= 101;  --游戏状态变更

CTCompetitioClientEvent.NextStatusTimeStampChanged							= 102;  --显示战绩UI

CTCompetitioClientEvent.TeamDataChanged										= 103;  --改变队伍

CTCompetitioClientEvent.TeamUIDChanged										= 104;  --改变队伍


--params:
-- ├─ 10002
-- │  ├─ KillCount: 0
-- │  ├─ UID: 10002
-- │  ├─ DeathCount: 1
-- │  └─ TeamID: 1
-- └─ 10001
--    ├─ KillCount: 1
--    ├─ UID: 10001
--    ├─ DeathCount: 0
--    └─ TeamID: 2
CTCompetitioClientEvent.PlayerScoreChanged									= 105   --战绩数据改变

--params:
-- ├─ 1: 1
-- └─ 2: 0
CTCompetitioClientEvent.TeamScoreChanged									= 106   --战绩数据改变 

--params:
-- ├─ TeamScore
-- │  ├─ 1: 5
-- │  └─ 2: 1
-- ├─ PlayerScore
-- │  ├─ 10002
-- │  │  ├─ AssistCount: 0
-- │  │  ├─ KillCount: 1
-- │  │  ├─ DeathCount: 5
-- │  │  ├─ TeamID: 2
-- │  │  └─ UID: 10002
-- │  └─ 10001
-- │     ├─ AssistCount: 0
-- │     ├─ KillCount: 5
-- │     ├─ DeathCount: 1
-- │     ├─ TeamID: 1
-- │     └─ UID: 10001
-- └─ WinTeam: 1
CTCompetitioClientEvent.GameEndEvent										= 107   --对局结束

CTCompetitioClientEvent.ShowCommonTipsUI									= 108   --弹Tips消息事件

CTCompetitioClientEvent.EquipSelectRangeChanged								= 109   --装备选择范围下发

--params:
-- ├─ KillerName: "Player_10001"
-- ├─ VictimName: "Player_10002"
-- ├─ VictimPlayerKey: 10002
-- └─ VictimLocation: {X=..., Y=..., Z=...}
CTCompetitioClientEvent.KillBroadcastEvent									= 110   --击杀播报事件
