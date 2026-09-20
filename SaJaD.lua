local GameplayData = require("GameLua.GameCore.Data.GameplayData")

-- ============================================================
-- PART 1: EXPIRY SYSTEM
-- ============================================================

local EXPIRY_DATE = os.time({year=2027, month=8, day=20, hour=0, min=0, sec=0})

local function GetDaysRemaining()
    local currTime = os.time()
    local daysLeft = math.ceil((EXPIRY_DATE - currTime) / 86400)
    return daysLeft < 0 and 0 or daysLeft
end

local function IsModExpired()
    return GetDaysRemaining() <= 0
end

local function isExpired()
    return IsModExpired()
end

local function ShowExpiredMessage()
    pcall(function()
        local MsgBox = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local msg = [[تم انتهاء الوقت


Contact:
- @AboAliu_Pubg (SaJaD)

https://t.me/AboAliu_Pubg]]
        MsgBox.Show(4, "انتهى الوقت", msg, nil)
    end)
end

-- ============================================================
-- PART 7: SaJaD +   VIP MOD FEATURES
-- ============================================================

local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local KismetMathLibrary = import("KismetMathLibrary")
local GameplayStatics = import("GameplayStatics")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")

_G.SaJaDConfig = _G.SaJaDConfig or {
    Wallhack = true,
    WallhackColorVisible = "Green",
    WallhackColorHidden = "Red",
    WallhackRainbow = false,
    WallhackRainbowSaJaD = 2.0,
    Aimbot = true,
    AimbotLevel = 4,
    AutoAimBone = 1,
    MapESP = true,
    LineESP = true,
    FPS165 = true,
    iPadFOV = true,
    FOVValue = 110,
    BlackSky = false,
    NoGrass = false,
    SaJaDHack = false,
    MagicBullet = true,
    EnemyCounter = true,
}

local TARGET_FOV = 110

local function EmptyFunc() end
local function FalseFunc() return false end
local function TrueFunc() return true end
local function EmptyTableFunc() return {} end

local function GetPlayerController()
    if not slua_GameFrontendHUD then return nil end
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return nil end
    return pc
end

local function GetPlayerCharacter()
    local pc = GetPlayerController()
    if not pc then return nil end
    local char = pc:GetPlayerCharacterSafety()
    if not slua.isValid(char) then return nil end
    return char
end

local function GetWeaponComponents()
    local char = GetPlayerCharacter()
    if not slua.isValid(char) then return nil, nil, nil end
    local WeaponMgr = char.WeaponManagerComponent
    if not slua.isValid(WeaponMgr) then return char, nil, nil end
    local weapon = WeaponMgr.CurrentWeaponReplicated
    if not slua.isValid(weapon) then return char, WeaponMgr, nil end
    local shootComp = weapon.ShootWeaponEntityComp
    return char, WeaponMgr, shootComp
end

local function SafeCall(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        pcall(function()
            if _G.SaJaD_Debug then
                print("[ERROR] " .. tostring(result))
            end
        end)
    end
    return result
end

local function IsValidObject(obj)
    return obj and slua.isValid and slua.isValid(obj)
end

local function IsAlive(pawn)
    if not IsValidObject(pawn) then return false end
    local isDead = false
    SafeCall(function()
        if type(pawn.IsDead) == "function" then
            isDead = pawn:IsDead()
        elseif pawn.bIsDead then
            isDead = true
        end
        if pawn.bHidden then isDead = true end
        if IsValidObject(pawn.Mesh) and pawn.Mesh.bHidden then isDead = true end
    end)
    return not isDead
end

local function IsCharacterDeadOrHidden(target)
    if not IsValidObject(target) then return true end
    local isDead = false
    SafeCall(function()
        if type(target.IsDead) == "function" then
            isDead = target:IsDead()
        elseif target.bIsDead then
            isDead = true
        end
        if target.bHidden then isDead = true end
        if IsValidObject(target.Mesh) and target.Mesh.bHidden then isDead = true end
    end)
    return isDead
end

-- ============================================================
-- PART 8: ANTI-BAN BYPASSES (FIXED VERSION)
-- ============================================================

local function nop(...) return end
local function retFalse() return false end
local function retTrue() return true end
local function nopfalse() return false end
local function noptrue() return true end
local function nopnil() return nil end
local function nopstr() return "" end
local function Valid(obj) return obj and slua.isValid and slua.isValid(obj) end

_G.BypassPermissions = {
    SecurityBypass = true,
    AntiCheatBypass = true,
    ReportBypass = true,
    BanBypass = true,
    TelemetryBypass = true,
    NetworkBypass = true,
    MD5Bypass = true,
    SignatureBypass = true,
    DNSBypass = true,
    DeviceBypass = true,
    IPBypass = true,
    MACBypass = true,
    IMEIBypass = true,
    AndroidIDBypass = true,
    AllFeaturesEnabled = true,
    NoReports = true,
    NoBan = true,
    NoDetection = true,
    NoTelemetry = true,
    NoCrashReport = true,
    NoAnalytics = true,
    NoMonitor = true,
    NoTrack = true,
    NoScan = true,
    NoVerify = true,
    NoCheck = true,
    NoValidate = true
}

_G.AntiCheatBlock = {
    BlockAllAntiCheat = true,
    BlockTSS = true,
    BlockGokuba = true,
    BlockSwiftHawk = true,
    BlockCoronaLab = true,
    BlockHawkEye = true,
    BlockHiggsBoson = true,
    BlockClientBan = true,
    BlockRealTimeBan = true,
    BlockReportSystem = true,
    BlockTLog = true,
    BlockMD5Check = true,
    BlockSignatureVerify = true,
    BlockDeviceFingerprint = true,
    BlockDNSMonitor = true,
    BlockTelemetry = true,
    BlockAnalytics = true,
    BlockCrashReport = true,
    BlockMemoryScan = true,
    BlockSaJaDCheck = true,
    BlockWallCheck = true,
    BlockShootVerify = true,
    BlockModifierException = true,
    BlockSimulateLocation = true,
    BlockPlayerSecurity = true,
    BlockCircleFlow = true,
    BlockMrpcsFlow = true,
    BlockKillFlow = true,
    BlockBehaviorScore = true,
    BlockAFKReport = true,
    BlockAvatarException = true,
    BlockFileCheck = true,
    BlockPakVerify = true,
    BlockIntegrityCheck = true,
    BlockRacingAntiCheat = true,
    BlockClientEntry = true,
    BlockNetworkException = true,
    BlockUnrealNet = true,
    BlockReplay = true,
    BlockScreenshot = true,
    BlockDebugLog = true
}

local function ClientEntryBypass()
    pcall(function()
        if Client then
            Client.SetTssNetworkStatus = nop
            Client.GEMReportEnterLobbyEvent = nop
            Client.TPerforPlatDisconnectReport = nop
            Client.IsConnected = function(NetInterface) return true end
            Client.GetUnrealNetworkStatus = nopstr
            Client.MD5LuaString = function(str) return "BYPASSED_MD5" end
            Client.GetDSVersion = function() return "999.999.999" end
            Client.IsInReplayState = nopfalse
        end
        
        if NetManager then
            NetManager.ProcRespondMsg = nop
            NetManager.isLogMsgAfterLogin = false
            NetManager.logMsgMap = {}
        end
        
        if EventSystem then
            local oldPost = EventSystem.postEvent
            EventSystem.postEvent = function(eventType, eventID, ...)
                if eventID and type(eventID) == "string" then
                    local blocked = {"SECURITY", "CHEAT", "BAN", "REPORT", "FLAG", 
                                    "VIOLATION", "DETECT", "VERIFY", "ANTI", "AC_",
                                    "SUSPICIOUS", "ABNORMAL", "MONITOR", "TRACK",
                                    "TELEMETRY", "ANALYTICS", "CRASH", "DUMP"}
                    for _, be in ipairs(blocked) do
                        if eventID:find(be) then return end
                    end
                end
                if oldPost then oldPost(eventType, eventID, ...) end
            end
        end
    end)
    print("[BYPASS] Client Entry bypassed!")
end

local function HiggsBosonBypass()
    pcall(function()
        if CHiggsBosonComponent then
            CHiggsBosonComponent.ReceiveBeginPlay = nop
            CHiggsBosonComponent.StaticShowSecurityAlertInDev = nop
            CHiggsBosonComponent.ShowABCD = nop
            CHiggsBosonComponent._ClientShowSecurityAlertWindow = nop
            CHiggsBosonComponent._ReportChatRobot = nop
            CHiggsBosonComponent.SendAntiDataFlow = nop
            CHiggsBosonComponent.SendHitFireBtnFlow = nop
            CHiggsBosonComponent.OnBattleResult = nop
            CHiggsBosonComponent.SendHisarData = nop
            CHiggsBosonComponent.RPC_Client_ShowSecurityAlertWindow = nop
            CHiggsBosonComponent.RPC_Server_TellServerName = nop
            CHiggsBosonComponent.RecordStrategyTimestampInReplay = nop
            CHiggsBosonComponent.SkipAlertServer = nop
            CHiggsBosonComponent.SetClientAlertWindowEnabled = nop
            CHiggsBosonComponent.IsCharacterOwnerWerewolf = nopfalse
            CHiggsBosonComponent.IsCharacterOwnerButcher = nopfalse
            CHiggsBosonComponent._ProcessReportChatRobotQueue = nop
            CHiggsBosonComponent.LuaNotifySecurityAbnormalJump = nop
            CHiggsBosonComponent.bSkipAlertServer = true
            CHiggsBosonComponent.bMHActive = false
            CHiggsBosonComponent.bCallPreReplication = false
            bIsSkipAlertServer = true
            bSkipUploadNoschat = true
            _nReportNosChatTimerID = nil
            _nReportNosChatMessageID = 0
            _tReportNosChatQueue = {}
            LastTimeHandleAlert = -1
        end
    end)
    print("[BYPASS] HiggsBoson bypassed!")
end

local function HawkEyeBypass()
    pcall(function()
        if ClientHawkEyePatrolSubsystem then
            ClientHawkEyePatrolSubsystem._OnHawkSync = nop
            ClientHawkEyePatrolSubsystem._OnHawkReportSuccess = nop
            ClientHawkEyePatrolSubsystem._OnRecvInspectorBroadcastCount = nop
            ClientHawkEyePatrolSubsystem.ReportCheat = nop
            ClientHawkEyePatrolSubsystem.RequestImprison = nop
            ClientHawkEyePatrolSubsystem.SendReportTLog = nop
            ClientHawkEyePatrolSubsystem.IsDuringHawkEyePatrol = nopfalse
            ClientHawkEyePatrolSubsystem._CollectBeWatchedPlayerInfo = nop
            ClientHawkEyePatrolSubsystem.HasReported = noptrue
            ClientHawkEyePatrolSubsystem.GetBeWatchedPlayerInfo = nopnil
            ClientHawkEyePatrolSubsystem._OnPlayerKilledOtherPlayer = nop
            ClientHawkEyePatrolSubsystem._StartFrameUIRefreshTimer = nop
            ClientHawkEyePatrolSubsystem.ExitWatching = nop
            ClientHawkEyePatrolSubsystem.WantMatchNextPatrol = nop
            ClientHawkEyePatrolSubsystem._InitHawkEyePatrolSubsystem = function(self)
                self._bHasInitialized = true
                self._bHasReported = true
            end
            ClientHawkEyePatrolSubsystem._StartHideUITimer = nop
            ClientHawkEyePatrolSubsystem._StartShowDistanceUITimer = nop
            ClientHawkEyePatrolSubsystem._StartCloseBattleEndedTipsTimer = nop
            ClientHawkEyePatrolSubsystem._StartBattleTimeUsageTimer = nop
            ClientHawkEyePatrolSubsystem._StartQuitVoiceRoomTimer = nop
            ClientHawkEyePatrolSubsystem._StartExitGameTimer = nop
            ClientHawkEyePatrolSubsystem._CloseExitGameTimer = nop
            ClientHawkEyePatrolSubsystem._CreateOvertimerTimerForNextPatrol = nop
            ClientHawkEyePatrolSubsystem.ClearNextPatrolOvertimeTimer = nop
            ClientHawkEyePatrolSubsystem.ReturnLobbyAndOpenH5 = nop
            ClientHawkEyePatrolSubsystem.ForceNeverCloseBattleEndedTips = nop
            ClientHawkEyePatrolSubsystem.CheckShowReportedTips = nopfalse
            ClientHawkEyePatrolSubsystem.TryShowReportedTips = nop
            ClientHawkEyePatrolSubsystem.ShowWatchEndedTips = nop
            ClientHawkEyePatrolSubsystem.HasShownWatchEndedTips = noptrue
            ClientHawkEyePatrolSubsystem.OnShowWatchEndedTips = nop
            ClientHawkEyePatrolSubsystem.OnClickLowerLeftExitWatching = nop
            ClientHawkEyePatrolSubsystem.OnClickBottomRightOpenReportWindow = nop
            ClientHawkEyePatrolSubsystem._MarkHasReported = nop
            ClientHawkEyePatrolSubsystem.GetForbidNextPatrolRemainingTimeInSeconds = function() return 0 end
            ClientHawkEyePatrolSubsystem.GetUsedDailyTimeInSeconds = function() return 0 end
            ClientHawkEyePatrolSubsystem.GetInspectorBroadcastCount = function() return -1 end
            ClientHawkEyePatrolSubsystem.GetMaxInspectorBroadcastCount = function() return 0 end
            ClientHawkEyePatrolSubsystem.CanInspectorBroadcast = nopfalse
            ClientHawkEyePatrolSubsystem.IsCharacterLocationShouldDraw = nopfalse
            ClientHawkEyePatrolSubsystem.InitHawkEyePatrolSubsystem = nop
            ClientHawkEyePatrolSubsystem._PostConstruct = function(self)
                self._bHasInitialized = true
                self._bHasReported = true
                self.nInspectorBroadcastCount = -1
            end
            ClientHawkEyePatrolSubsystem.OnRelease = nop
            ClientHawkEyePatrolSubsystem._bHasInitialized = true
            ClientHawkEyePatrolSubsystem._bHasReported = true
            ClientHawkEyePatrolSubsystem._bHasShownWatchEndedTips = true
            ClientHawkEyePatrolSubsystem.bShowBeReportedTips = true
            ClientHawkEyePatrolSubsystem.nInspectorBroadcastCount = -1
        end
    end)
    print("[BYPASS] HawkEye Patrol bypassed!")
end

local function BanLogicBypass()
    pcall(function()
        if ClientBanLogic then
            ClientBanLogic.ReqBanInfo = nop
            ClientBanLogic.OnVoiceSwitchNotify = nop
            ClientBanLogic.OnVoiceBanNotify = nop
            ClientBanLogic.OnRealTimeVoiceBanNotify = nop
            ClientBanLogic.OnVoiceBanSuccess = nop
            ClientBanLogic.TryOpenVoice = function()
                EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, false)
            end
            ClientBanLogic.IsVoiceReportEnable = nopfalse
            ClientBanLogic.OnSyncMicSuspicious = nop
            ClientBanLogic.OnSyncMicPreFilter = nop
            ClientBanLogic.OnSyncBanInfo = nop
            ClientBanLogic.OnNotifyWarningTips = nop
            ClientBanLogic.VoiceBanEndTime = 0
            ClientBanLogic.bEnableVoiceReport = false
            ClientBanLogic.SuspiciousFlag = 0
            ClientBanLogic.Reason = ""
            ClientBanLogic.IsTranslated = false
        end
        if RealTimeBan then
            RealTimeBan.Init = function() return end
            RealTimeBan.OnPlayerWithRealTimeBan = nop
            RealTimeBan.OnSyncPlayerInfo = nop
            RealTimeBan.HandleEnterGameModeFightingState = nop
            RealTimeBan.ShowAlias = nop
            RealTimeBan.SetOnRankInspectorUID = nop
            RealTimeBan.IsUIDOnRankInspector = nopfalse
            RealTimeBan.GetUIDInspectorRank = function() return -1 end
            RealTimeBan.SetInspectorBroadcastCountUID = nop
            RealTimeBan.GetUIDInspectorBroadcastCount = function() return -1 end
            RealTimeBan.GetTipsIDOffset = function() return 0 end
            RealTimeBan.GetTipsIDOffsetWithUID = function() return 0 end
            RealTimeBan.GetTipsIDOffsetInspector = function() return 0 end
            RealTimeBan.GMShowAlias = nop
            RealTimeBan.tOnRankInspectorUIDSet = {}
            RealTimeBan.tInspectorRankUIDSet = {}
            RealTimeBan.tInspectorBroadcastCountUIDSet = {}
            RealTimeBan.MaxAliasLevel = -1
            RealTimeBan.CurrentAlias = nil
            RealTimeBan.CurrentName = nil
            RealTimeBan.is_onrank_inspector = false
            RealTimeBan.inspector_rank = -1
            RealTimeBan.bHasOldAlias = false
            RealTimeBan.ShowTipsAliasConfig = {}
            RealTimeBan.DelayTime = {}
            RealTimeBan.OldShowTipsAlias = 0
        end
        if BanSystem then
            BanSystem.CheckBan = retFalse
            BanSystem.IsBanned = retFalse
            BanSystem.GetBanReason = function() return "" end
            BanSystem.GetBanTime = function() return 0 end
        end
    end)
    print("[BYPASS] Ban Logic bypassed!")
end

local function ReportSystemBypass()
    pcall(function()
        if ClientReportPlayerSubsystem then
            ClientReportPlayerSubsystem.OnInit = nop
            ClientReportPlayerSubsystem._OnPlayerKilledOtherPlayer = nop
            ClientReportPlayerSubsystem._RecordFatalDamager = nop
            ClientReportPlayerSubsystem._RecordMurdererFromDeathReplayData = nop
            ClientReportPlayerSubsystem._OnSyncFatalDamage = nop
            ClientReportPlayerSubsystem._SyncBattleResult = nop
            ClientReportPlayerSubsystem._OnBattleResult = nop
            ClientReportPlayerSubsystem._OnShowQuickReportMutualExclusiveUI = nop
            ClientReportPlayerSubsystem._OnHideQuickReportMutualExclusiveUI = nop
            ClientReportPlayerSubsystem._StartCheckGameModeTypeTimer = nop
            ClientReportPlayerSubsystem._CheckGameModeType = nop
            ClientReportPlayerSubsystem._StartCheckCurrentNotInTeamHistoricalTeammateTimer = nop
            ClientReportPlayerSubsystem._CheckCurrentNotInTeamHistoricalTeammate = nop
            ClientReportPlayerSubsystem._RecordTeammatePlayerInfo = nop
            ClientReportPlayerSubsystem._IsHealthStatusKilled = nopfalse
            ClientReportPlayerSubsystem.GetFatalDamagerMap = function() return {} end
            ClientReportPlayerSubsystem.GetFatalDamagerMapSize = function() return 0 end
            ClientReportPlayerSubsystem.GetName2InfoMap = function() return {} end
            ClientReportPlayerSubsystem.GetCachedTeammateName2InfoMap = function() return {} end
            ClientReportPlayerSubsystem.GetTeammateName2InfoMapDuringBattle = function() return {} end
            ClientReportPlayerSubsystem.GetCurrentNotInTeamHistoricalTeammateMap = function() return {} end
            ClientReportPlayerSubsystem.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
            ClientReportPlayerSubsystem.IsGameModeTypeTeamDeathMatch = nopfalse
            ClientReportPlayerSubsystem.GetGameModeType = function() return -1 end
            ClientReportPlayerSubsystem.GetMainModeID = function() return -1 end
            ClientReportPlayerSubsystem.GetSubModeID = function() return -1 end
            ClientReportPlayerSubsystem.EnableRecordFatalDamage = nop
            ClientReportPlayerSubsystem._tKnockDownerMap = {}
            ClientReportPlayerSubsystem._tMurdererMap = {}
            ClientReportPlayerSubsystem._ds2history = {}
            ClientReportPlayerSubsystem._tMapCurrentNotInTeamHistoricalTeammate = {}
            ClientReportPlayerSubsystem._tTeammateName2InfoMap = {}
            ClientReportPlayerSubsystem._bEnableRecordFatalDamage = false
            ClientReportPlayerSubsystem._bIsGameModeTypeTeamDeathMatch = false
            ClientReportPlayerSubsystem._nGameModeType = -1
            ClientReportPlayerSubsystem._nMainModeID = -1
            ClientReportPlayerSubsystem._nSubModeID = -1
            ClientReportPlayerSubsystem._nCheckTDMGameModeTypeTimer = nil
            ClientReportPlayerSubsystem._nCurrentNotInTeamHistoricalTeammateTimer = nil
        end
        if DSReportPlayerSubsystem then
            DSReportPlayerSubsystem.OnInit = nop
            DSReportPlayerSubsystem._OnNearDeathOrRescued = nop
            DSReportPlayerSubsystem._OnPlayerSettlementStart = nop
            DSReportPlayerSubsystem._OnTeammateDamage = nop
            DSReportPlayerSubsystem._OnCharacterDied = nop
            DSReportPlayerSubsystem._OnPlayerReconnect = nop
            DSReportPlayerSubsystem._RecordFatalDamager = nop
            DSReportPlayerSubsystem._RecordTeammateMurderer = nop
            DSReportPlayerSubsystem._AddMLKillerUIDToBattleResult = nop
            DSReportPlayerSubsystem._AddFatalDamagerMapToBattleResult = nop
            DSReportPlayerSubsystem._AddKnockDownerToBattleResult = nop
            DSReportPlayerSubsystem._AddKillerToBattleResult = nop
            DSReportPlayerSubsystem._AddTeammateMurderToBattleResult = nop
            DSReportPlayerSubsystem._SaveHistoricalTeammateInfo = nop
            DSReportPlayerSubsystem._SyncFatalDamagerMap = nop
            DSReportPlayerSubsystem._AddGameModeTypeToBattleResult = nop
            DSReportPlayerSubsystem._UpdateMLAIUID = nop
            DSReportPlayerSubsystem._AddEnemyMapToBattleResult = nop
            DSReportPlayerSubsystem._OnNoNetStartUpDoor = nop
            DSReportPlayerSubsystem._AssignTeammateInTeamIndex = nop
            DSReportPlayerSubsystem._FindCacheByUID = function(self, nUID, bAddIfNotExists)
                if bAddIfNotExists then return {} end
                return nil
            end
            DSReportPlayerSubsystem._GetFatalDamagerMap = function() return {} end
            DSReportPlayerSubsystem._IsBattleResultTableValid = nopfalse
            DSReportPlayerSubsystem._IsHealthStatusKilled = nopfalse
            DSReportPlayerSubsystem._tUID2InfoMap = {}
            DSReportPlayerSubsystem.nNoStartUpDoorNum = 0
        end
        if ui_complaint then
            ui_complaint.SubmitReportData = function(self) self:CloseWindow(false) return end
            ui_complaint._OnClickReport = function(self) return end
            ui_complaint._AddCommonTypesOfPlayerForReport = function(self) return end
            ui_complaint.AddPlayerForReport = function(self, ...) return end
            ui_complaint.GetSelectedReasonAsArray = function(self) return {} end
            ui_complaint.GetSelectedSubReasonAsArray = function(self) return {} end
            ui_complaint.BlockPlayerChat = function(self) return end
            ui_complaint.IsBlockChatCheck = function(self) return false end
            ui_complaint.CheckBoxBlack = function(self, bCheckState) return end
            ui_complaint.UpdateMatchBlackList = function(self) return end
            ui_complaint._SelectedReasonSet = {}
            ui_complaint._SelectedSubReasonSet = {}
            ui_complaint._SelectedCheatSubReasonSet = {}
            ui_complaint._tPlayerName2InfoMap = {}
            ui_complaint._tPlayerNamesArray = {}
        end
        if LogicComplaint then
            LogicComplaint.Submit = function(...) return end
        end
    end)
    print("[BYPASS] Report System bypassed!")
end

local function TLogBypass()
    pcall(function()
        if tlog_report_utils then
            tlog_report_utils.ReportTLogEvent = nop
            tlog_report_utils.IsCanReportLobbyEvent = nopfalse
            tlog_report_utils.IsBusinessReport = nopfalse
            tlog_report_utils.SetMarketStayUpdateEnable = nop
            tlog_report_utils.GetMarketStayUpdateEnable = nopfalse
            tlog_report_utils.SetBusinessReportEnable = nop
            tlog_report_utils.SendTLogReportImmediate = nop
            tlog_report_utils.SetTlogBeginType = nop
            tlog_report_utils.SetTlogEndType = nop
            _G.SendTLogReportImmediate = nop
            _extraTlogReportEnableCfg = {}
            _isCanReportMarketStay = false
            _BusinessReportEnable = false
            _isInitConfig = true
            start_timestamp_map = {}
        end
        if ToolReportUtil then
            ToolReportUtil.GetReportSwitch = nopfalse
            ToolReportUtil.GetPackageInfo = nopnil
            ToolReportUtil.ReParseError = function(error, reportType) return error or "" end
            ToolReportUtil.IsReleaseVersion = noptrue
            ToolReportUtil.IsWhite = nopfalse
            ToolReportUtil.IsXPcallOpenInBattle = nopfalse
            ToolReportUtil.IsClientToolOpen = nopfalse
            MyOpenID = false
            MyUID = false
            VersionInfo = nil
        end
        if DSSecurityTLogSubsystem then
            DSSecurityTLogSubsystem.OnInit = nop
            DSSecurityTLogSubsystem._OnReportServerJumpFlow = nop
            DSSecurityTLogSubsystem._OnDevAlert = nop
            DSSecurityTLogSubsystem._InitWhenEditor = nop
            DSSecurityTLogSubsystem._nInitGameSafeCallbacksTimer = nil
        end
    end)
    print("[BYPASS] TLog Report bypassed!")
end

local function MD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
            console.ExecuteConsoleCommand(nil, "CheatManager.EnableCheat 1")
            console.ExecuteConsoleCommand(nil, "Net.BlockAllAntiCheat 1")
            console.ExecuteConsoleCommand(nil, "AntiCheat.DisableAll 1")
            console.ExecuteConsoleCommand(nil, "t.MaxFPS 165")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        if _G.FileHashChecker then
            _G.FileHashChecker.CheckFileMD5 = retTrue
            _G.FileHashChecker.VerifyAll = retTrue
            _G.FileHashChecker.GetHash = function() return "BYPASS" end
        end
        if _G.STExtraBlueprintFunctionLibrary then
            _G.STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
            _G.STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
            _G.STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
        end
    end)
    print("[BYPASS] MD5 & Signature bypassed!")
end

local function DNSDeviceBypass()
    pcall(function()
        local DeviceID = import("DeviceID")
        if DeviceID then
            DeviceID.GetDeviceID = function() return "BYPASSED_DEVICE" end
            DeviceID.GetAndroidID = function() return "BYPASSED_ANDROID_ID" end
            DeviceID.GetIMEI = function() return "BYPASSED_IMEI" end
            DeviceID.GetMACAddress = function() return "BYPASSED_MAC" end
            DeviceID.GetUniqueDeviceID = function() return "BYPASSED_UNIQUE" end
            DeviceID.GetDeviceName = function() return "BYPASSED_DEVICE_NAME" end
            DeviceID.GetDeviceModel = function() return "BYPASSED_MODEL" end
            DeviceID.GetDeviceBrand = function() return "BYPASSED_BRAND" end
            DeviceID.GetDeviceManufacturer = function() return "BYPASSED_MANUFACTURER" end
            DeviceID.GetDeviceBoard = function() return "BYPASSED_BOARD" end
            DeviceID.GetDeviceBootloader = function() return "BYPASSED_BOOTLOADER" end
            DeviceID.GetDeviceHardware = function() return "BYPASSED_HARDWARE" end
            DeviceID.GetDeviceHost = function() return "BYPASSED_HOST" end
            DeviceID.GetDeviceFingerprint = function() return "BYPASSED_FINGERPRINT" end
            DeviceID.GetDeviceSerial = function() return "BYPASSED_SERIAL" end
        end
        local DNS = import("DNS")
        if DNS then
            DNS.Resolve = function() return "127.0.0.1" end
            DNS.GetHostName = function() return "BYPASSED_HOST" end
            DNS.GetIPAddress = function() return "0.0.0.0" end
        end
        local Network = import("Network")
        if Network then
            Network.GetIPAddress = function() return "0.0.0.0" end
            Network.GetMACAddress = function() return "BYPASSED_MAC" end
            Network.GetSSID = function() return "BYPASSED_SSID" end
            Network.GetBSSID = function() return "BYPASSED_BSSID" end
        end
    end)
    print("[BYPASS] DNS & Device bypassed!")
end

local function GokubaBypass()
    pcall(function()
        local Gokuba = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"]
        if Gokuba then
            Gokuba.ForwardFeature = function() return {0,0,0,0,0} end
            Gokuba.InitGokubaLogic = nop
            if Gokuba.TimerHandle then
                local time_ticker = require("common.time_ticker")
                time_ticker.RemoveTimer(Gokuba.TimerHandle)
                Gokuba.TimerHandle = nil
            end
        end
        if _G.GokubaLogic then
            _G.GokubaLogic.ForwardFeature = nop
            _G.GokubaLogic.InitGokubaLogic = nop
        end
    end)
    print("[BYPASS] Gokuba bypassed!")
end

local function RacingAntiCheatBypass()
    pcall(function()
        if RacingAntiCheatLogic then
            RacingAntiCheatLogic.HandleRacingEnter = nop
            RacingAntiCheatLogic.HandleRacingStart = nop
            RacingAntiCheatLogic.HandleRacingEnd = nop
            RacingAntiCheatLogic.StartDetectTimer = nop
            RacingAntiCheatLogic.StopDetectTimer = nop
            RacingAntiCheatLogic.DetectVehicleFloating = nop
            RacingAntiCheatLogic.HandleFloatingCheat = nop
            RacingAntiCheatLogic.SetIgnoreFloating = nop
            RacingAntiCheatLogic.HandlePlayerPassCheckBelt = nop
            RacingAntiCheatLogic.HandleSaJaDCheat = nop
            RacingAntiCheatLogic._CreateVehicleData = function() return {} end
            RacingAntiCheatLogic.vehicleDataMap = {}
            RacingAntiCheatLogic.detectTimer = nil
            RacingAntiCheatLogic.config = {
                FloatingDistLimit = 99999,
                FloatingTimeLimit = 99999,
                CheckPassIntervalLimit = 99999
            }
        end
    end)
    print("[BYPASS] Racing AntiCheat bypassed!")
end

local function CoronaLabBypass()
    pcall(function()
        _G.LocalMain = function()
            print("[BYPASS] CoronaLab telemetry timer blocked!")
            return
        end
        local uOuterController = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(uOuterController) and uOuterController.AddGameTimer then
            local orig = uOuterController.AddGameTimer
            uOuterController.AddGameTimer = function(interval, bLoop, func, ...)
                if interval == 30 and bLoop == true then
                    return nil
                end
                return orig(interval, bLoop, func, ...)
            end
        end
        if CHiggsBosonComponent then
            CHiggsBosonComponent.SecurityCoronaLabClientDataPointer = function(self) return nil end            CHiggsBosonComponent.SetFloatValueByName = function(self, name, value) return end
        end
        if _G.CoronaLab then
            _G.CoronaLab.ReportData = nop
            _G.CoronaLab.SendData = nop
            _G.CoronaLab.CollectData = nop
            _G.CoronaLab.Telemetry = nop
        end
    end)
    print("[BYPASS] CoronaLab Telemetry bypassed!")
end

local function LoginModuleBypass()
    pcall(function()
        if login_module then
            login_module["ban-login"] = function() return end
            login_module["idip-kick-out"] = function() return end
            login_module.aq_ban = function() return end
            login_module["device-in-blacklist"] = function() return end
            login_module.device_num_limit = function() return end
            login_module["register-forbidden"] = function() return end
            login_module["low-version"] = function() return end
            login_module["not-in-white-list"] = function() return end
            login_module.Login_Failed = function() return end
            login_module.aas_ban = function() return end
            login_module.PakMonitorStart = function(EnableMode) return end
            login_module.SetupFilenameHideKeywords = function() return end
            login_module.on_login_failed = function(conn_idx, reason, banInfo, banTime, uid, extra_table) return end
            login_module.DelaybanLoginCancelCallback = function() return end
            login_module.CheckBan = retFalse
            login_module.IsBanned = retFalse
        end
    end)
    print("[BYPASS] Login Module bypassed!")
end

local function SwiftHawkBypass()
    pcall(function()
        for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do
            if _G[f] then _G[f] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end
        end
    end)
    print("[BYPASS] Swift Hawk bypassed!")
end

local function ShootVerificationBypass()
    pcall(function()
        local sub = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if sub then
            sub.OnShootVerifyFailed = nop
            sub.SendVerifyData = nop
            sub.ReportBulletHit = nop
            sub.UploadHitInfo = nop
            sub.VerifyShot = retTrue
        end
    end)
    print("[BYPASS] Shoot Verification bypassed!")
end

local function ModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then _G.bReportedModifierException = false end
        local sub = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if sub then
            sub.ReportException = nop
            sub.CheckModifier = retTrue
            sub.ValidateModifier = retTrue
            sub.ReportModifierError = nop
        end
    end)
    print("[BYPASS] Modifier Exception bypassed!")
end

local function SimulateCharacterBypass()
    pcall(function()
        local sub = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if sub then
            sub.ReportLocation = nop
            sub.SendLocationData = nop
            sub.VerifyLocation = retTrue
        end
    end)
    print("[BYPASS] Simulate Character bypassed!")
end

local function PlayerSecurityBypass()
    pcall(function()
        local SecSub = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecSub then
            SecSub.ReportData = nop
            SecSub.CheckCheat = retFalse
            SecSub.ValidatePlayer = retTrue
            SecSub.CollectData = nop
            SecSub.SendToServer = nop
        end
    end)
    print("[BYPASS] Player Security bypassed!")
end

local function ClientFlowBypass()
    pcall(function()
        for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}) do
            local sub = package.loaded[name] or _G[name]
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Send") or k:find("Flow") or
                        k:find("Record") or k:find("Process") or k:find("Upload") or
                        k:find("Track") or k:find("Monitor") or k:find("Analyze")
                    ) then
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
        end
    end)
    print("[BYPASS] Client Flow bypassed!")
end

local function GameplayCallbackBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        
        local reports = {
            "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", 
            "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", 
            "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", 
            "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", 
            "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", 
            "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", 
            "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", 
            "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", 
            "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", 
            "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams",
            "ReportSecurityViolation", "ReportIntegrityCheck", "ReportSignatureVerify",
            "ReportAntiCheat", "ReportAC", "ReportSuspicious", "ReportAbnormal"
        }
        for _, f in ipairs(reports) do GC[f] = nop end
        
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse
        GC.CheckReportSecAttackFlow = retFalse
        
        GC.OnPlayerNetConnectionClosed = nop
        GC.OnPlayerActorChannelError = nop
        GC.OnPlayerRPCValidateFailed = nop
        GC.OnPlayerSpectateException = nop
        GC.OnShutdownAfterError = nop
        GC.IsBypassed = true
    end)
    print("[BYPASS] Gameplay Callback bypassed!")
end

local function KillAllSubsystems()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local toKill = {
                "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
                "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
                "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
                "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem",
                "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem",
                "MemoryCheckSubsystem", "SaJaDCheckSubsystem", "WallCheckSubsystem",
                "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem",
                "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem",
                "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
                "MD5CheckSubsystem", "PakVerifySubsystem", "DNSMonitorSubsystem",
                "DeviceFingerprintSubsystem", "ReplayMonitorSubsystem", "TelemetrySubsystem",
                "GokubaSubsystem", "RacingAntiCheatSubsystem", "ClientBanSubsystem",
                "RealTimeBanSubsystem", "TLogSubsystem", "ReportSubsystem"
            }
            for _, name in ipairs(toKill) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Send") or k:find("Upload") or
                            k:find("Verify") or k:find("Check") or k:find("Validate") or
                            k:find("Scan") or k:find("Detect") or k:find("Collect") or
                            k:find("Flow") or k:find("Heartbeat") or k:find("Monitor") or
                            k:find("Track") or k:find("Record") or k:find("Log") or
                            k:find("Alert") or k:find("Notify") or k:find("Ban") or
                            k:find("Kick") or k:find("Suspend") or k:find("Flag")
                        ) then pcall(function() sub[k] = nop end) end
                    end
                end
            end
        end
    end)
    print("[BYPASS] All subsystems killed!")
end

local function SLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
    end)
    print("[BYPASS] SLUA bypassed!")
end

local function ReplayTelemetryBypass()
    pcall(function()
        if _G.Replay then
            _G.Replay.Record = nop
            _G.Replay.StopRecord = nop
            _G.Replay.Save = nop
            _G.Replay.Upload = nop
            _G.Replay.Report = nop
        end
        if _G.Telemetry then
            _G.Telemetry.Send = nop
            _G.Telemetry.Report = nop
            _G.Telemetry.Track = nop
            _G.Telemetry.Log = nop
        end
        if _G.Analytics then
            _G.Analytics.Send = nop
            _G.Analytics.Report = nop
            _G.Analytics.Track = nop
        end
        if _G.Firebase then
            _G.Firebase.logEvent = nop
            _G.Firebase.trackEvent = nop
            _G.Firebase.setEnabled = retFalse
            _G.Firebase.sendEvent = nop
            _G.Firebase.report = nop
        end
        if _G.Adjust then
            _G.Adjust.logEvent = nop
            _G.Adjust.trackEvent = nop
            _G.Adjust.setEnabled = retFalse
            _G.Adjust.sendEvent = nop
        end
        if _G.AppsFlyer then
            _G.AppsFlyer.logEvent = nop
            _G.AppsFlyer.trackEvent = nop
            _G.AppsFlyer.setEnabled = retFalse
            _G.AppsFlyer.sendEvent = nop
        end
    end)
    print("[BYPASS] Replay & Telemetry bypassed!")
end

local function FinalProtection()
    pcall(function()
        for _, flag in ipairs({
            "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", 
            "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", 
            "ENABLE_PERFORMANCE_REPORT", "ENABLE_MONITOR", "ENABLE_TRACK",
            "ENABLE_DETECT", "ENABLE_VERIFY", "ENABLE_CHECK", "ENABLE_SCAN",
            "ENABLE_AC", "ENABLE_BEACON", "ENABLE_SDK", "ENABLE_TSS",
            "ENABLE_SWIFT_HAWK", "ENABLE_GOKUBA", "ENABLE_HIGGS",
            "ENABLE_CORONA", "ENABLE_HAWKEYE", "ENABLE_BAN",
            "ENABLE_VALIDATE", "ENABLE_AUTHENTICATE", "ENABLE_SIGNATURE"
        }) do
            if _G[flag] then _G[flag] = false end
        end
        
        if _G.BypassPermissions then
            for k, v in pairs(_G.BypassPermissions) do
                _G.BypassPermissions[k] = true
            end
        end
        
        if _G.AntiCheatBlock then
            for k, v in pairs(_G.AntiCheatBlock) do
                _G.AntiCheatBlock[k] = true
            end
        end
    end)
    print("[BYPASS] Final Protection activated!")
end

local function NetworkBypass()
    pcall(function()
        if _G.NetworkCheck then
            _G.NetworkCheck.Verify = retTrue
            _G.NetworkCheck.CheckLatency = retFalse
        end
    end)
    print("[BYPASS] Network Bypass executed!")
end

function InitAntiCheatBypasses()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        NetworkBypass()
        ClientEntryBypass()
        HiggsBosonBypass()
        HawkEyeBypass()
        BanLogicBypass()
        ReportSystemBypass()
        TLogBypass()
        MD5Bypass()
        DNSDeviceBypass()
        GokubaBypass()
        RacingAntiCheatBypass()
        CoronaLabBypass()
        LoginModuleBypass()
        SwiftHawkBypass()
        ShootVerificationBypass()
        ModifierExceptionBypass()
        SimulateCharacterBypass()
        PlayerSecurityBypass()
        ClientFlowBypass()
        GameplayCallbackBypass()
        KillAllSubsystems()
        SLUABypass()
        ReplayTelemetryBypass()
        FinalProtection()
        print("[ULTIMATE BYPASS] Complete - All Security Systems Disabled")
    end)
end

-- ============================================================
-- PART 9: SaJaD +   FEATURES - GRAPHICS UNLOCK (FIXED)
-- ============================================================

local function Apply165FPS()
    if IsModExpired() or not _G.SaJaDConfig.FPS165 then return end
    SafeCall(function()
        local gi = slua_GameFrontendHUD:GetGameInstance()
        if gi then
            gi:ExecuteCMD("t.MaxFPS", "165")
            gi:ExecuteCMD("r.FrameRateLimit", "165")
        end
    end)
end

local function Remove165FPS()
    SafeCall(function()
        local gi = slua_GameFrontendHUD:GetGameInstance()
        if gi then
            gi:ExecuteCMD("t.MaxFPS", "60")
            gi:ExecuteCMD("r.FrameRateLimit", "60")
        end
    end)
end

local function InitializeGraphicsUnlock() 
    if _G.SaJaD_GraphicsUnlocked then return end

    pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)

    pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        
        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor = import("LinearColor") or _G.FLinearColor

        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then 
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end

        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[20]=20,[25]=25,[30]=30,[40]=40,[60]=60,[90]=90,[120]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true) 
                        pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then 
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1) 
                        end
                    end
                end
            end
        end

        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            
            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end

            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end

            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
                    end
                else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)
                
                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)
            end

            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                local clamped = FPSFineTuneNum < NMinFPS and NMinFPS or (FPSFineTuneNum > 165 and 165 or FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, clamped)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(clamped))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(clamped))
                end
            end

            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(FPSFineTuneNum < NMinFPS and NMinFPS or (FPSFineTuneNum > 165 and 165 or FPSFineTuneNum))
                end
            end
            
            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)
    _G.SaJaD_GraphicsUnlocked = true
end

-- ============================================================
-- PART 10: SaJaD +   FEATURES - FOV
-- ============================================================

local FOV_VALUES = {80, 90, 100, 110, 120, 130, 140}

local function ApplyiPadFOV()
    if IsModExpired() or not _G.SaJaDConfig.iPadFOV then return end
    SafeCall(function()
        local char = GetPlayerCharacter()
        if not char then return end
        local cam = char.ThirdPersonCameraComponent
        if slua.isValid(cam) and not (char.bIsWeaponAiming or false) then
            cam.FieldOfView = _G.SaJaDConfig.FOVValue or TARGET_FOV
            cam:SetFieldOfView(_G.SaJaDConfig.FOVValue or TARGET_FOV)
        end
    end)
end

local function RemoveiPadFOV()
    SafeCall(function()
        local char = GetPlayerCharacter()
        if not char then return end
        local cam = char.ThirdPersonCameraComponent
        if slua.isValid(cam) then
            cam.FieldOfView = 80
            cam:SetFieldOfView(80)
        end
    end)
end

-- ============================================================
-- PART 11: SaJaD +   FEATURES - AIMBOT (FIXED HEAD TARGETING)
-- ============================================================

local AIMBOT_CONFIGS = {
    { SaJaD=0, SaJaDRate=0, RangeRate=0, RangeRateSight=0, SaJaDRateSight=0, CenterSaJaDRate=0, CrouchRate=0, ProneRate=0, DyingRate=0, GameDeviationFactor=0 },
    { SaJaD=5, SaJaDRate=5, RangeRate=1, RangeRateSight=1, SaJaDRateSight=5, CenterSaJaDRate=3, CrouchRate=1, ProneRate=1, DyingRate=0, GameDeviationFactor=0 },
    { SaJaD=7, SaJaDRate=7, RangeRate=2, RangeRateSight=2, SaJaDRateSight=7, CenterSaJaDRate=5, CrouchRate=2, ProneRate=2, DyingRate=0, GameDeviationFactor=0 },
    { SaJaD=10, SaJaDRate=10, RangeRate=10, RangeRateSight=10, SaJaDRateSight=10, CenterSaJaDRate=7, CrouchRate=2, ProneRate=2, DyingRate=0, GameDeviationFactor=0 },
    { SaJaD=50, SaJaDRate=20, RangeRate=20, RangeRateSight=20, SaJaDRateSight=20, CenterSaJaDRate=15, CrouchRate=5, ProneRate=5, DyingRate=0, GameDeviationFactor=0 },
}

local BONE_NAMES = {"head", "neck_01", "pelvis"}
local BONE_SOCKETS = {"راس", "رقبة", "صدر"}

local function ApplyAimbot()
    if not _G.SaJaDConfig.Aimbot or (_G.SaJaDConfig.AimbotLevel or 4) == 0 then
        DisableAimbot()
        return
    end
    if IsModExpired() then return end
    
    local level = _G.SaJaDConfig.AimbotLevel or 4
    if level < 1 then DisableAimbot(); return end
    local cfg = AIMBOT_CONFIGS[level]
    if not cfg then return end
    
    local char, WeaponMgr, shootComp = GetWeaponComponents()
    
    if slua.isValid(shootComp) then
        shootComp.RecoilKickADS = 0.05
        
        if shootComp.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local r = shootComp.AutoAimingConfig[range]
                if r then
                    r.SaJaD = cfg.SaJaD
                    r.SaJaDRate = cfg.SaJaDRate
                    r.RangeRate = cfg.RangeRate
                    r.RangeRateSight = cfg.RangeRateSight
                    r.SaJaDRateSight = cfg.SaJaDRateSight
                    r.CenterSaJaDRate = cfg.CenterSaJaDRate
                    r.CrouchRate = cfg.CrouchRate
                    r.ProneRate = cfg.ProneRate
                    r.DyingRate = cfg.DyingRate
                    r.adsorbMaxRange = 200
                    r.adsorbMinRange = 20
                    r.adsorbMinAttenuationDis = 100
                    r.adsorbMaxAttenuationDis = 8000
                    r.adsorbActiveMinRange = 20
                end
            end
        end
        
        shootComp.GameDeviationFactor = cfg.GameDeviationFactor
        
        local boneName = BONE_NAMES[_G.SaJaDConfig.AutoAimBone or 1] or "head"
        
        if shootComp.Bones then
            if type(shootComp.Bones) == "table" then
                shootComp.Bones[0] = boneName
                shootComp.Bones[1] = boneName
                shootComp.Bones[2] = boneName
            end
        end
    end
    
    if slua.isValid(char) then
        local boneName = BONE_NAMES[_G.SaJaDConfig.AutoAimBone or 1] or "head"
        local socketName = BONE_SOCKETS[_G.SaJaDConfig.AutoAimBone or 1] or "Head"
        
        local aimComponentNames = {
            "BP_AutoAimingComponent_C",
            "BP_AutoAimingComponent",
            "AutoAimingComponent",
            "AutoAimComp",
            "AutoAim",
            "AimAssistComponent"
        }
        
        for _, compName in ipairs(aimComponentNames) do
            local comp = char[compName]
            if slua.isValid(comp) then
                if comp.Bones then
                    if type(comp.Bones) == "table" then
                        for i = 0, 9 do
                            pcall(function() comp.Bones[i] = boneName end)
                        end
                    end
                end
                if comp.AutoAimBoneName then
                    comp.AutoAimBoneName = socketName
                end
                if comp.TargetBone then
                    comp.TargetBone = socketName
                end
            end
        end
    end
    
    pcall(function()
        local gi = slua_GameFrontendHUD:GetGameInstance()
        if gi then
            gi:ExecuteCMD("AutoAim.HeadTarget 1")
        end
    end)
end

local function DisableAimbot()
    local _, _, shootComp = GetWeaponComponents()
    if slua.isValid(shootComp) then
        shootComp.RecoilKickADS = 1.0
        if shootComp.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local r = shootComp.AutoAimingConfig[range]
                if r then
                    r.SaJaD = 0; r.SaJaDRate = 0; r.RangeRate = 0
                    r.RangeRateSight = 0; r.SaJaDRateSight = 0
                    r.CenterSaJaDRate = 0; r.CrouchRate = 0
                    r.ProneRate = 0; r.DyingRate = 0
                end
            end
        end
        shootComp.GameDeviationFactor = 1.0
    end
end

-- ============================================================
-- PART 12: SaJaD +   FEATURES - ENHANCED WALLHACK WITH RAINBOW
-- ============================================================

local TintColor = {R=1.0, G=1.0, B=1.0, A=1.0}

local WH_ColorPresets = {
    Red = {R=10.0, G=0.0, B=0.0, A=1.0},
    Green = {R=0.0, G=10.0, B=0.0, A=1.0},
    Blue = {R=0.0, G=0.0, B=10.0, A=1.0},
    Yellow = {R=10.0, G=10.0, B=0.0, A=1.0},
    Purple = {R=10.0, G=0.0, B=10.0, A=1.0},
    Cyan = {R=0.0, G=10.0, B=10.0, A=1.0},
    White = {R=10.0, G=10.0, B=10.0, A=1.0},
    Orange = {R=10.0, G=5.0, B=0.0, A=1.0},
    Pink = {R=10.0, G=2.0, B=5.0, A=1.0},
}

local function hslToRgb(h, s, l)
    local r, g, b
    if s == 0 then
        r, g, b = l, l, l
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end
    return r, g, b
end

local function GetRainbowColor(SaJaD, seed)
    local time = os.clock()
    local hue = (time * SaJaD + seed) % 1.0
    local r, g, b = hslToRgb(hue, 1.0, 0.5)
    return {R = r * 10, G = g * 10, B = b * 10, A = 1.0}
end

local function GetWallhackColor(visible, character)
    local cfg = _G.SaJaDConfig
    
    if cfg.WallhackRainbow then
        local seed = 0
        if slua.isValid(character) then
            seed = (character.PlayerKey or 0) * 0.1
        end
        return GetRainbowColor(cfg.WallhackRainbowSaJaD, seed)
    end
    
    local colorName = visible and cfg.WallhackColorVisible or cfg.WallhackColorHidden
    return WH_ColorPresets[colorName] or WH_ColorPresets.Green
end

local function ApplyEnhancedWallhack(Controller, Character)
    if not slua.isValid(Character) then return end
    
    local meshes = {}
    pcall(function()
        if slua.isValid(Character.Mesh) then table.insert(meshes, Character.Mesh) end
        local SkelMeshClass = import("SkeletalMeshComponent")
        if SkelMeshClass then
            local comps = Character:GetComponentsByClass(SkelMeshClass)
            if comps then
                local num = comps:Num()
                for i = 0, num - 1 do
                    local comp = comps:Get(i)
                    if slua.isValid(comp) and comp ~= Character.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    
    local visible = false
    if slua.isValid(Controller) and slua.isValid(Character) then
        pcall(function() visible = Controller:LineOfSightTo(Character) end)
    end
    
    local color = GetWallhackColor(visible, Character)
    
    for _, mesh in ipairs(meshes) do
        if slua.isValid(mesh) then
            mesh:SetVisibility(true, false)
            mesh:SetHiddenInGame(false, false)
            pcall(function()
                local material = mesh:GetMaterial(0)
                if slua.isValid(material) then
                    local baseMat = material:GetBaseMaterial()
                    if slua.isValid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                        if baseMat.BlendMode ~= 2 then baseMat.BlendMode = 2 end
                    end
                end
            end)
            mesh.UseScopeDistanceCulling = false
            mesh.PrimitiveShadingStrategy = 1
            mesh.ShadingRate = 6
        end
    end
    
    Character.WH_MIDs = Character.WH_MIDs or {}
    for _, mesh in ipairs(meshes) do
        if slua.isValid(mesh) then
            local meshId = tostring(mesh)
            Character.WH_MIDs[meshId] = Character.WH_MIDs[meshId] or {}
            for matIdx = 0, 10 do
                pcall(function()
                    local material = mesh:GetMaterial(matIdx)
                    if slua.isValid(material) then
                        local mid = Character.WH_MIDs[meshId][matIdx]
                        if not slua.isValid(mid) then
                            mid = mesh:CreateAndSetMaterialInstanceDynamic(matIdx)
                            if slua.isValid(mid) then Character.WH_MIDs[meshId][matIdx] = mid end
                        elseif material ~= mid then
                            mesh:SetMaterial(matIdx, mid)
                        end
                        if slua.isValid(mid) then
                            local paramNames = {
                                "颜色", "Extra Light Color", "Para_Color", "Para_ColorTint",
                                "Para_Color_1", "Tint", "Color", "BaseColor", "BodyColor",
                                "MainColor", "DiffuseColor", "EmissiveColor"
                            }
                            for _, paramName in ipairs(paramNames) do
                                mid:SetVectorParameterValue(paramName, color)
                            end
                            mid:SetVectorParameterValue("ParaScaleOffset", TintColor)
                        end
                    end
                end)
            end
        end
    end
    Character._SaJaD_WH_Applied = true
end

local function DisableWallhack(Character)
    if not slua.isValid(Character) then return end
    local meshes = {}
    pcall(function()
        if slua.isValid(Character.Mesh) then table.insert(meshes, Character.Mesh) end
        local SkelMeshClass = import("SkeletalMeshComponent")
        if SkelMeshClass then
            local comps = Character:GetComponentsByClass(SkelMeshClass)
            if comps then
                local num = comps:Num()
                for i = 0, num - 1 do
                    local comp = comps:Get(i)
                    if slua.isValid(comp) then table.insert(meshes, comp) end
                end
            end
        end
    end)
    for _, mesh in ipairs(meshes) do
        if slua.isValid(mesh) then
            pcall(function()
                local material = mesh:GetMaterial(0)
                if slua.isValid(material) then
                    local baseMat = material:GetBaseMaterial()
                    if slua.isValid(baseMat) then
                        if baseMat.bDisableDepthTest ~= false then baseMat.bDisableDepthTest = false end
                        if baseMat.BlendMode ~= 1 then baseMat.BlendMode = 1 end
                    end
                end
            end)
        end
    end
    Character.WH_MIDs = nil
    Character._SaJaD_WH_Applied = false
end

-- ============================================================
-- PART 13: SaJaD +   FEATURES - ENHANCED MAP ESP (NEW)
-- ============================================================

_G.SaJaD_Active_Marks_Cache = _G.SaJaD_Active_Marks_Cache or {}
_G.SaJaD_MapESP_Initialized = _G.SaJaD_MapESP_Initialized or false

local function SetupMapMarkers()
    if _G.SaJaD_MapESP_Initialized then return end
    pcall(function()
        local MapMarkerConfig = {
            UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
            MaxWidgetNum = 99,
            MaxShowDistance = 6000000,
            bBindOutScreen = true,
            bBindBlocked = true,
            bIsBindingActor = true,
            BindSocketName = "head",
            bUseLuaWorldSocketName = true,
            WorldPositionOffset = FVector(0, 0, 50),
            bNeedPreLoad = true,
            Priority = 2,
        }
        
        if InGameMarkTools and InGameMarkTools.ScreenMarkManager then
            if InGameMarkTools.ScreenMarkManager.OnInitMarkGroupData then
                pcall(function()
                    InGameMarkTools.ScreenMarkManager:OnInitMarkGroupData(9999)
                end)
            end
        end
        
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
        local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
        if ScreenMarkConfig then
            ScreenMarkConfig[9999] = MapMarkerConfig
        end
        
        _G.SaJaD_MapESP_Initialized = true
        print("[MAP ESP] Setup Complete!")
    end)
end

local function UpdateMapESP(target, localPlayer, enable)
    if not _G.SaJaD_MapESP_Initialized then
        SetupMapMarkers()
    end
    
    if enable == 1 then
        if not target.bHasSaJaDMapMarker then
            pcall(function()
                if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
                    local Marker = InGameMarkTools.ClientAddMapMark(9999, FVector(0,0,0), 0, "", 4, target)
                    if Marker then
                        target.NativeDistMark = Marker
                        target.bHasSaJaDMapMarker = true
                        _G.SaJaD_Active_Marks_Cache[tostring(target)] = {actor = target, marker = Marker}
                    end
                end
            end)
        end
    else
        if target.bHasSaJaDMapMarker then
            pcall(function()
                if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then
                    InGameMarkTools.ClientRemoveMapMark(target.NativeDistMark)
                end
            end)
            target.bHasSaJaDMapMarker = false
            target.NativeDistMark = nil
            _G.SaJaD_Active_Marks_Cache[tostring(target)] = nil
        end
    end
end

local function ClearDeadESP()
    local toRemove = {}
    for key, data in pairs(_G.SaJaD_Active_Marks_Cache or {}) do
        local target = data.actor
        if not IsValidObject(target) or IsCharacterDeadOrHidden(target) then
            table.insert(toRemove, {key = key, target = target})
        end
    end
    for _, item in ipairs(toRemove) do
        pcall(function()
            if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then
                InGameMarkTools.ClientRemoveMapMark(item.target.NativeDistMark)
            end
        end)
        if IsValidObject(item.target) then
            item.target.bHasSaJaDMapMarker = false
            item.target.NativeDistMark = nil
        end
        _G.SaJaD_Active_Marks_Cache[item.key] = nil
    end
end

-- ============================================================
-- PART 14: SaJaD +   FEATURES - ENHANCED LINE ESP (NEW)
-- ============================================================

local LineState = {active = false, lastSwitch = 0}
local LastLineUpdate = 0
local LINE_ACTIVE_TIME = 0.3
local LINE_INACTIVE_TIME = 0.2
local LINE_LENGTH = 2000
local LINE_UPDATE_RATE = 0.15

local function UpdateLineESP()
    if not _G.SaJaDConfig.LineESP then
        return
    end
    
    local currentTime = os.clock()
    if currentTime - LastLineUpdate < LINE_UPDATE_RATE then
        return
    end
    LastLineUpdate = currentTime
    
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not IsValidObject(player) then
            return
        end
        
        local controller = slua_GameFrontendHUD:GetPlayerController()
        if not IsValidObject(controller) then
            return
        end
        
        local hud = controller:GetHUD()
        if not IsValidObject(hud) then
            return
        end
        
        -- Toggle line visibility
        if LineState.active then
            if currentTime - LineState.lastSwitch >= LINE_ACTIVE_TIME then
                LineState.active = false
                LineState.lastSwitch = currentTime
            end
        else
            if currentTime - LineState.lastSwitch >= LINE_INACTIVE_TIME then
                LineState.active = true
                LineState.lastSwitch = currentTime
            end
        end
        
        if not LineState.active then
            return
        end
        
        local myTeam = player.TeamID or 0
        local myPos = player:K2_GetActorLocation()
        local halfLen = LINE_LENGTH / 2
        
        local pawns = Game:GetAllPlayerPawns() or {}
        for _, pawn in pairs(pawns) do
            if IsValidObject(pawn) and pawn ~= player then
                local team = pawn.TeamID or 0
                if team ~= myTeam and IsAlive(pawn) then
                    local pos = pawn:K2_GetActorLocation()
                    if pos then
                        local dist = FVector.Dist2D(myPos, pos)
                        if dist < 20000 then
                            -- Line from enemy up
                            hud:AddDebugText(
                                "|",
                                pawn,
                                8.0,
                                {X=0, Y=0, Z=90},
                                {X=0, Y=0, Z=halfLen},
                                {R=255, G=0, B=0, A=255},
                                true, false, true, nil, LINE_ACTIVE_TIME, true
                            )
                            
                            -- Line going up further
                            hud:AddDebugText(
                                "|",
                                pawn,
                                8.0,
                                {X=0, Y=0, Z=halfLen},
                                {X=0, Y=0, Z=LINE_LENGTH},
                                {R=255, G=60, B=0, A=255},
                                true, false, true, nil, LINE_ACTIVE_TIME, true
                            )
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- PART 15: SaJaD +   FEATURES - ENEMY COUNTER (NEW)
-- ============================================================

local BTN_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
local EnemyCounterWidget = nil

local function CreateEnemyCounterWidget()
    if EnemyCounterWidget then
        if slua.isValid(EnemyCounterWidget) then
            return EnemyCounterWidget
        else
            EnemyCounterWidget = nil
        end
    end

    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10500)
        if btn.RichText_Content then
            btn.RichText_Content:SetText("Enemies: 0  |  Nearest: 0m")
            local fontInfo = btn.RichText_Content.Font
            if fontInfo then
                fontInfo.Size = 16
                btn.RichText_Content:SetFont(fontInfo)
            end
        end
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 12))
            slot:SetSize(FVector2D(240, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        EnemyCounterWidget = btn
    end)
    return EnemyCounterWidget
end

local function UpdateEnemyCounter()
    -- التحقق من انتهاء الصلاحية
    if isExpired() then
        if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
            EnemyCounterWidget:RemoveFromParent()
            EnemyCounterWidget = nil
        end
        return
    end
    
    -- التحقق من حالة التفعيل في الإعدادات
    if not _G.SaJaDConfig.EnemyCounter then
        if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
            EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        return
    end
    
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end

        local widget = CreateEnemyCounterWidget()
        if not widget or not slua.isValid(widget) then return end
        
        -- إظهار الودجت إذا كان مفعلاً
        widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        local myTeam  = player.TeamID or 0
        local myLoc   = player:K2_GetActorLocation()
        local count   = 0
        local nearest = 999
        
        -- جمع كل اللاعبين
        local allPawns = {}
        pcall(function()
            if Game then
                local pawns = Game:GetAllPlayerPawns()
                if pawns then 
                    for _, p in pairs(pawns) do 
                        if slua.isValid(p) then table.insert(allPawns, p) end 
                    end 
                end
            end
        end)
        
        for _, tPawn in ipairs(allPawns) do
            if  slua.isValid(tPawn) and tPawn ~= player
            and (tPawn.TeamID or 0) ~= myTeam
            and (tPawn.Health or 0) > 0
            then
                count = count + 1
                local d = math.floor(FVector.Dist(myLoc, tPawn:K2_GetActorLocation()) / 100)
                if d < nearest then nearest = d end
            end
        end

        local displayText = string.format("Enemies: %d  |  Nearest: %dm", count, count > 0 and nearest or 0)

        if widget.RichText_Content then
            widget.RichText_Content:SetText(displayText)
        end
    end)
end

-- ============================================================
-- PART 16: SaJaD +   FEATURES - BLACK SKY / FIXED MAGIC BULLET
-- ============================================================

_G.BlackSky = function()
    if IsModExpired() then return end
    SafeCall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = logic_setting_graphics.GetGameInstance()
        if not gi then return end
        if _G.SaJaDConfig.BlackSky then
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
        else
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0")
        end
    end)
end

local MAGIC_CONFIG = { 
    ENABLED = true, 
    TICK_INTERVAL = 3,
    RETRY_INTERVAL = 30
}
local magicTick = 0
local magicInitialized = {}
local magicLastCheck = 0

local magicBones = {
    head = 300, neck_01 = 250, pelvis = 200,
    spine_01 = 200, spine_02 = 200, spine_03 = 200,
    upperarm_l = 200, upperarm_r = 200,
    lowerarm_l = 180, lowerarm_r = 180,
    hand_l = 150, hand_r = 150,
    thigh_l = 200, thigh_r = 200,
    calf_l = 180, calf_r = 180,
    foot_l = 150, foot_r = 150
}

local function ApplyMagicBullet()
    if not _G.SaJaDConfig.MagicBullet then return end
    if IsModExpired() then return end
    
    local currentTime = os.clock()
    
    magicTick = magicTick + 1
    if magicTick % MAGIC_CONFIG.TICK_INTERVAL ~= 0 then return end
    
    local appliedCount = 0
    local failedCount = 0
    
    pcall(function()
        local allPawns = {}
        
        if GameplayData.GetAllPlayerCharacters then
            local chars = GameplayData.GetAllPlayerCharacters()
            if chars then 
                for _, c in ipairs(chars) do 
                    if slua.isValid(c) then table.insert(allPawns, c) end 
                end 
            end
        end
        
        if Game and Game.GetAllPlayerPawns then
            local pawns = Game:GetAllPlayerPawns()
            if pawns then
                for _, p in pairs(pawns) do
                    if slua.isValid(p) then
                        local exists = false
                        for _, existing in ipairs(allPawns) do 
                            if existing == p then exists = true; break end 
                        end
                        if not exists then table.insert(allPawns, p) end
                    end
                end
            end
        end
        
        for _, pawn in ipairs(allPawns) do
            if not slua.isValid(pawn) then goto continue end
            
            local mesh = pawn.Mesh
            if not slua.isValid(mesh) then goto continue end
            
            local physAsset = mesh.PhysicsAssetOverride
            if not slua.isValid(physAsset) then
                if slua.isValid(mesh.SkeletalMesh) then
                    physAsset = mesh.SkeletalMesh.PhysicsAsset
                end
            end
            
            if not slua.isValid(physAsset) then goto continue end
            if not physAsset.SkeletalBodySetups then goto continue end
            
            local assetName = physAsset:GetName() or tostring(physAsset)
            
            if magicInitialized[assetName] then
                appliedCount = appliedCount + 1
                goto continue
            end
            
            local setups = physAsset.SkeletalBodySetups
            local modifiedBones = 0
            
            for i = 0, 99 do
                local bs = nil
                pcall(function() bs = setups:Get(i) end)
                if not bs or not slua.isValid(bs) then break end
                
                local boneName = ""
                pcall(function() boneName = tostring(bs.BoneName):lower() end)
                if boneName == "" then goto nextBone end
                
                local scaleFactor = nil
                for pattern, scale in pairs(magicBones) do
                    if boneName:find(pattern) then 
                        scaleFactor = 1.0 + scale / 100.0
                        break 
                    end
                end
                
                if scaleFactor then
                    local ag = bs.AggGeom or {}
                    
                    pcall(function()
                        local boxes = ag.BoxElems or {}
                        if boxes and boxes:Num() > 0 then
                            for j = 0, boxes:Num() - 1 do
                                local box = boxes:Get(j)
                                if box then
                                    box.X = (box.X or 30) * scaleFactor
                                    box.Y = (box.Y or 30) * scaleFactor
                                    box.Z = (box.Z or 60) * scaleFactor
                                end
                            end
                        end
                    end)
                    
                    pcall(function()
                        local spheres = ag.SphereElems or {}
                        if spheres and spheres:Num() > 0 then
                            for j = 0, spheres:Num() - 1 do
                                local sphere = spheres:Get(j)
                                if sphere then
                                    sphere.Radius = (sphere.Radius or 20) * scaleFactor
                                end
                            end
                        end
                    end)
                    
                    pcall(function()
                        local sphyls = ag.SphylElems or {}
                        if sphyls and sphyls:Num() > 0 then
                            for j = 0, sphyls:Num() - 1 do
                                local sphyl = sphyls:Get(j)
                                if sphyl then
                                    sphyl.Radius = (sphyl.Radius or 15) * scaleFactor
                                    sphyl.Length = (sphyl.Length or 30) * scaleFactor
                                end
                            end
                        end
                    end)
                    
                    modifiedBones = modifiedBones + 1
                end
                ::nextBone::
            end
            
            if modifiedBones > 0 then
                magicInitialized[assetName] = true
                if mesh.RecreatePhysicsState then 
                    mesh:RecreatePhysicsState() 
                end
                appliedCount = appliedCount + 1
            else
                failedCount = failedCount + 1
            end
            
            ::continue::
        end
    end)
    
    if failedCount > 0 and (currentTime - magicLastCheck) > MAGIC_CONFIG.RETRY_INTERVAL then
        magicLastCheck = currentTime
        for k, v in pairs(magicInitialized) do
            if v == false then magicInitialized[k] = nil end
        end
    end
end

-- ============================================================
-- PART 17: SaJaD +   FEATURES - DEVELOPER WATERMARK
-- ============================================================

local function UpdateDeveloperWatermark()
    local uCon = GetPlayerController()
    if not slua.isValid(uCon) then return end
    local HUD = uCon:GetHUD()
    if not slua.isValid(HUD) then return end
    local watermarkText = string.format(
        "SaJaD: @f_g_d_7\n Channel: @AboAliu_Pubg \n %d الايام المتبقية9",
        GetDaysRemaining()
    )
    HUD:AddDebugText(watermarkText, nil, 9999, {X=0, Y=0, Z=0}, {X=0, Y=0, Z=0}, {R=255, G=215, B=0, A=255}, true, true, true, nil, 5.0, true)
end

_G.TryShowWelcome = function()
    if _G.SaJaD_WelcomeShown then return end
    if IsModExpired() then ShowExpiredMessage(); _G.SaJaD_WelcomeShown = true; return false end
    pcall(function()
        local MsgBox = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local WebSDK = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
        local msg = string.format([[تاريخ الانتهاء: %d Day - يوم

Developers:
- SaJaD (@f_g_d_6)
- Channel (@AboAliu_Pubg)

https://t.me/AboAliu_Pubg]], GetDaysRemaining())
        MsgBox.Show(4, "WELCOME", msg, function()
            if WebSDK then WebSDK:OpenURL("https://t.me/AboAliu_Pubg") end
        end)
        _G.SaJaD_WelcomeShown = true
    end)
    return true
end

-- ============================================================
-- PART 18: SaJaD +   MAIN PROCESSING
-- ============================================================

local function ProcessAllFeatures()
    if IsModExpired() then return end
    
    local localPlayer = GetPlayerCharacter()
    if not localPlayer then return end
    
    local controller = GetPlayerController()
    local allChars = {}
    
    SafeCall(function()
        if GameplayData.GetAllPlayerCharacters then
            local chars = GameplayData.GetAllPlayerCharacters()
            if chars then for _, c in ipairs(chars) do if IsValidObject(c) then table.insert(allChars, c) end end end
        end
        if Game then
            local pawns = Game:GetAllPlayerPawns()
            if pawns then
                for _, p in pairs(pawns) do
                    if IsValidObject(p) then
                        local exists = false
                        for _, existing in ipairs(allChars) do if existing == p then exists = true; break end end
                        if not exists then table.insert(allChars, p) end
                    end
                end
            end
        end
    end)
    
    _G.SaJaD_TickCount = (_G.SaJaD_TickCount or 0) + 1
    
    if _G.SaJaD_TickCount % 30 == 0 then 
        ClearDeadESP() 
    end
    
    -- تحديث الميزات
    UpdateLineESP()
    UpdateEnemyCounter()
    UpdateDeveloperWatermark()
    ApplyAimbot()
    ApplyMagicBullet()
    
    for _, target in ipairs(allChars) do
        if IsValidObject(target) and target ~= localPlayer then
            local isEnemy = true
            SafeCall(function()
                if target.TeamID and localPlayer.TeamID and target.TeamID == localPlayer.TeamID then
                    isEnemy = false
                end
            end)
            
            if isEnemy then
                local isDead = IsCharacterDeadOrHidden(target)
                
                if not isDead then
                    if _G.SaJaDConfig.Wallhack then 
                        ApplyEnhancedWallhack(controller, target)
                    else 
                        DisableWallhack(target) 
                    end
                    
                    -- Map ESP
                    if _G.SaJaDConfig.MapESP then 
                        UpdateMapESP(target, localPlayer, 1) 
                    else 
                        UpdateMapESP(target, localPlayer, 0) 
                    end
                else
                    DisableWallhack(target)
                    if target.bHasSaJaDMapMarker then 
                        UpdateMapESP(target, localPlayer, 0) 
                    end
                end
            end
        end
    end
end

-- ============================================================
-- PART 19: SaJaD +   MENU SYSTEM
-- ============================================================

local SaJaDMenu = {}
local MENU_BP = "/Game/UMG/UI_BP/Common/Common_Legal_01_UIBP.Common_Legal_01_UIBP"
local Z_TRIGGER = 9300
local Z_MENU = 9600

SaJaDMenu.menuWidget = nil
SaJaDMenu.triggerWidget = nil
SaJaDMenu.currentPage = 1
SaJaDMenu.loadedButtons = {}

local function modLog(msg) print("[AboAliu_Pubg] " .. tostring(msg)) end
local function valid(obj) return obj and (not slua.isValid or slua.isValid(obj)) end

local function later(sec, fn)
    if _G.SetTimer then pcall(_G.SetTimer, sec, fn) return end
    local tk = _G.Mytimer_ticker
    if not tk then pcall(function() tk = require("common.time_ticker"); _G.Mytimer_ticker = tk end) end
    if tk and tk.AddTimer then pcall(tk.AddTimer, sec, fn); return end
    local GameThread = import("GameThread")
    if GameThread and GameThread.Delay then pcall(GameThread.Delay, sec, fn); return end
end

local WH_VisibleColorNames = {"Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "White", "Orange", "Pink", "Rainbow"}
local WH_HiddenColorNames = {"Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "White", "Orange", "Pink", "Rainbow"}

local function toggleWallhack()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.Wallhack = not _G.SaJaDConfig.Wallhack
    if not _G.SaJaDConfig.Wallhack then
        SafeCall(function()
            local allChars = {}
            if GameplayData.GetAllPlayerCharacters then
                local chars = GameplayData.GetAllPlayerCharacters()
                if chars then for _, c in ipairs(chars) do if IsValidObject(c) then table.insert(allChars, c) end end end
            end
            for _, target in ipairs(allChars) do DisableWallhack(target) end
        end)
    end
    modLog("Wallhack: " .. tostring(_G.SaJaDConfig.Wallhack))
end

local function cycleWallhackVisibleColor()
    local colors = WH_VisibleColorNames
    local current = _G.SaJaDConfig.WallhackColorVisible or "Green"
    local index = 1
    for i, color in ipairs(colors) do
        if color == current then index = i; break end
    end
    index = index % #colors + 1
    _G.SaJaDConfig.WallhackColorVisible = colors[index]
    _G.SaJaDConfig.WallhackRainbow = (colors[index] == "Rainbow")
    modLog("Visible Color: " .. colors[index])
end

local function cycleWallhackHiddenColor()
    local colors = WH_HiddenColorNames
    local current = _G.SaJaDConfig.WallhackColorHidden or "Red"
    local index = 1
    for i, color in ipairs(colors) do
        if color == current then index = i; break end
    end
    index = index % #colors + 1
    _G.SaJaDConfig.WallhackColorHidden = colors[index]
    modLog("Hidden Color: " .. colors[index])
end

local function toggleRainbowMode()
    _G.SaJaDConfig.WallhackRainbow = not _G.SaJaDConfig.WallhackRainbow
    modLog("Rainbow: " .. tostring(_G.SaJaDConfig.WallhackRainbow))
end

local function toggleMapESP()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.MapESP = not _G.SaJaDConfig.MapESP
    
    if not _G.SaJaDConfig.MapESP then
        local toRemove = {}
        for key, data in pairs(_G.SaJaD_Active_Marks_Cache) do
            table.insert(toRemove, {key = key, target = data.actor})
        end
        
        for _, item in ipairs(toRemove) do
            pcall(function()
                if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then
                    InGameMarkTools.ClientRemoveMapMark(item.target.NativeDistMark)
                end
            end)
            if IsValidObject(item.target) then
                item.target.bHasSaJaDMapMarker = false
                item.target.NativeDistMark = nil
            end
        end
        
        _G.SaJaD_Active_Marks_Cache = {}
    end
    
    modLog("MapESP: " .. tostring(_G.SaJaDConfig.MapESP))
end

local function toggleLineESP()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.LineESP = not _G.SaJaDConfig.LineESP
    modLog("LineESP: " .. tostring(_G.SaJaDConfig.LineESP))
end

local function cycleAimbot()
    if IsModExpired() then ShowExpiredMessage(); return end
    local cfg = _G.SaJaDConfig
    cfg.AimbotLevel = (cfg.AimbotLevel or 4) + 1
    if cfg.AimbotLevel > 4 then cfg.AimbotLevel = 0 end
    local levels = {"OFF", "LOW", "MEDIUM", "HIGH", "EXTREME"}
    cfg.Aimbot = cfg.AimbotLevel > 0
    if cfg.Aimbot then ApplyAimbot() else DisableAimbot() end
    modLog("Aimbot: " .. levels[cfg.AimbotLevel + 1])
end

local function cycleAutoAimBone()
    local cfg = _G.SaJaDConfig
    cfg.AutoAimBone = (cfg.AutoAimBone or 1) + 1
    if cfg.AutoAimBone > 3 then cfg.AutoAimBone = 1 end
    local bones = {"Head", "Neck", "Pelvis"}
    modLog("AutoAim Bone: " .. bones[cfg.AutoAimBone])
    if cfg.Aimbot then ApplyAimbot() end
end

local function toggleFPS165Menu()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.FPS165 = not _G.SaJaDConfig.FPS165
    if _G.SaJaDConfig.FPS165 then Apply165FPS() else Remove165FPS() end
    modLog("FPS165: " .. tostring(_G.SaJaDConfig.FPS165))
end

local function cycleFOV()
    local cfg = _G.SaJaDConfig
    local currentFOV = cfg.FOVValue or 110
    local currentIndex = 1
    for i, fov in ipairs(FOV_VALUES) do if fov == currentFOV then currentIndex = i; break end end
    local nextIndex = currentIndex % #FOV_VALUES + 1
    local nextFOV = FOV_VALUES[nextIndex]
    cfg.FOVValue = nextFOV
    modLog("FOV: " .. nextFOV)
    if cfg.iPadFOV then ApplyiPadFOV() end
end

local function toggleFOV()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.iPadFOV = not _G.SaJaDConfig.iPadFOV
    if _G.SaJaDConfig.iPadFOV then ApplyiPadFOV() else RemoveiPadFOV() end
    modLog("iPadFOV: " .. tostring(_G.SaJaDConfig.iPadFOV))
end

local function toggleBlackSkyMenu()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.BlackSky = not _G.SaJaDConfig.BlackSky
    _G.BlackSky()
    modLog("BlackSky: " .. tostring(_G.SaJaDConfig.BlackSky))
end

local function toggleNoGrass()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.NoGrass = not _G.SaJaDConfig.NoGrass
    pcall(function()
        local sg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = sg.GetGameInstance()
        if gi then
            if _G.SaJaDConfig.NoGrass then gi:ExecuteCMD("grass.heightScale", "0") else gi:ExecuteCMD("grass.heightScale", "1") end
        end
    end)
    modLog("NoGrass: " .. tostring(_G.SaJaDConfig.NoGrass))
end

local function toggleMagicBullet()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.MagicBullet = not _G.SaJaDConfig.MagicBullet
    modLog("MagicBullet: " .. tostring(_G.SaJaDConfig.MagicBullet))
end

local function toggleSaJaDHack()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.SaJaDHack = not _G.SaJaDConfig.SaJaDHack
    if _G.SaJaDConfig.SaJaDHack then
        pcall(function()
            local char = GetPlayerCharacter()
            if IsValidObject(char) and char.CharacterMovement then
                char.CharacterMovement.MaxWalkSaJaD = char.CharacterMovement.MaxWalkSaJaD * 1.5
            end
        end)
    else
        pcall(function()
            local char = GetPlayerCharacter()
            if IsValidObject(char) and char.CharacterMovement then
                char.CharacterMovement.MaxWalkSaJaD = char.CharacterMovement.MaxWalkSaJaD / 1.5
            end
        end)
    end
    modLog("SaJaDHack: " .. tostring(_G.SaJaDConfig.SaJaDHack))
end

local function toggleEnemyCounter()
    if IsModExpired() then ShowExpiredMessage(); return end
    _G.SaJaDConfig.EnemyCounter = not _G.SaJaDConfig.EnemyCounter
    
    -- إذا تم إيقاف العداد، إخفاء الودجت
    if not _G.SaJaDConfig.EnemyCounter then
        if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
            EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
    else
        -- إذا تم تشغيل العداد، تأكد من وجود الودجت وتحديثه
        CreateEnemyCounterWidget()
    end
    
    modLog("EnemyCounter: " .. tostring(_G.SaJaDConfig.EnemyCounter))
end

local pages = {
    { title = "ESP", features = {
        { label = "Wallhack - ويل هاك", toggle = toggleWallhack, state = function() return _G.SaJaDConfig.Wallhack end },
        { label = function() return "Visible [" .. (_G.SaJaDConfig.WallhackColorVisible or "Green") .. "]" end, toggle = cycleWallhackVisibleColor },
        { label = function() return "Hidden - مخفي[" .. (_G.SaJaDConfig.WallhackColorHidden or "Red") .. "]" end, toggle = cycleWallhackHiddenColor },
        { label = function() return "Rainbow - اللوان عشوائية[" .. tostring(_G.SaJaDConfig.WallhackRainbow) .. "]" end, toggle = toggleRainbowMode },
        { label = "Map - خريطة", toggle = toggleMapESP, state = function() return _G.SaJaDConfig.MapESP end },
        { label = "Line - خط", toggle = toggleLineESP, state = function() return _G.SaJaDConfig.LineESP end },
    }},
    { title = "AIMBOT", features = {
        { label = function() local lvls = {"ايقاف","قليل","متوسط","عالي","عالي جدا"} return "Aimbot [" .. lvls[(_G.SaJaDConfig.AimbotLevel or 4) + 1] .. "]" end, toggle = cycleAimbot, state = function() return _G.SaJaDConfig.Aimbot end },
        { label = function() local bones = {"راس","رقبة","صدر"} return "Bone [" .. bones[_G.SaJaDConfig.AutoAimBone or 1] .. "]" end, toggle = cycleAutoAimBone },
    }},
    { title = "VISUAL", features = {
        { label = "FPS 165 - فريمات عالية", toggle = toggleFPS165Menu, state = function() return _G.SaJaDConfig.FPS165 end },
        { label = function() return "FOV - روية مجال[" .. tostring(_G.SaJaDConfig.FOVValue) .. "]" end, toggle = cycleFOV, state = function() return _G.SaJaDConfig.iPadFOV end },
        { label = "Black Sky - سماء سوداء ", toggle = toggleBlackSkyMenu, state = function() return _G.SaJaDConfig.BlackSky end },
        { label = "No Grass - بدون عشب", toggle = toggleNoGrass, state = function() return _G.SaJaDConfig.NoGrass end },
    }},
    { title = "WEAPON", features = {
        { label = "ماجيك بوليت (غير فعال) ", toggle = toggleMagicBullet, state = function() return _G.SaJaDConfig.MagicBullet end },
    }},
    { title = "EXTRA", features = {
        { label = "Enemy Counter", toggle = toggleEnemyCounter, state = function() return _G.SaJaDConfig.EnemyCounter end },
        { label = "SaJaD Hack", toggle = toggleSaJaDHack, state = function() return _G.SaJaDConfig.SaJaDHack end },
        { label = function() return "Expires: " .. GetDaysRemaining() .. " days" end, action = function() if IsModExpired() then ShowExpiredMessage() else modLog("Expires in " .. GetDaysRemaining() .. " days") end end },
    }},
}

local function getLabel(feat)
    if type(feat.label) == "function" then return feat.label() end
    if feat.state then
        local s = feat.state()
        if s == true then return feat.label .. "  [ON]" end
        if s == false then return feat.label .. "  [OFF]" end
    end
    return feat.label
end

function SaJaDMenu:ClearButtons()
    for _, b in ipairs(self.loadedButtons) do
        pcall(function() if valid(b) then b:RemoveFromParent() end end)
    end
    self.loadedButtons = {}
end

function SaJaDMenu:BuildButtons(w)
    self:ClearButtons()
    local page = pages[self.currentPage]
    if not page then return end
    local startY = 200
    local btnW = 420
    local btnH = 52
    local gap = 10
    for i, feat in ipairs(page.features) do
        pcall(function()
            local btn = slua.loadUI(BTN_BP)
            if not btn or not valid(btn) then return end
            btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            if btn.RichText_Content then btn.RichText_Content:SetText(getLabel(feat)) end
            if btn.Button_Temp and btn.Button_Temp.OnClicked then
                btn.Button_Temp.OnClicked:Add(function()
                    if feat.action then feat.action()
                    elseif feat.toggle then feat.toggle() end
                    if btn.RichText_Content then btn.RichText_Content:SetText(getLabel(feat)) end
                end)
            end
            pcall(function() require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, Z_MENU + i) end)
            pcall(function()
                local slot = import("WidgetLayoutLibrary").SlotAsCanvasSlot(btn)
                if slot then
                    slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
                    slot:SetAlignment(FVector2D(0.5, 0))
                    slot:SetPosition(FVector2D(0, startY + (i - 1) * (btnH + gap)))
                    slot:SetSize(FVector2D(btnW, btnH))
                end
            end)
            table.insert(self.loadedButtons, btn)
        end)
    end
end

function SaJaDMenu:UpdateTabs(w)
    local tabNames = {}
    for i, p in ipairs(pages) do tabNames[i] = p.title end
    for i = 1, #pages do
        pcall(function()
            local sw = w["WidgetSwitcher_HighLight_" .. i]
            if sw then if i == self.currentPage then sw:SetActiveWidgetIndex(1) else sw:SetActiveWidgetIndex(0) end end
        end)
        pcall(function()
            local txt = w["TextBlock_Tab_" .. i]
            if txt then txt:SetText(tabNames[i]) end
        end)
    end
end

function SaJaDMenu:Close()
    self:ClearButtons()
    if self.menuWidget and valid(self.menuWidget) then pcall(function() self.menuWidget:RemoveFromParent() end) end
    self.menuWidget = nil
    modLog("Menu Closed")
end

function SaJaDMenu:Open()
    if IsModExpired() then ShowExpiredMessage(); return end
    if self.menuWidget and valid(self.menuWidget) then return end
    local w = nil
    pcall(function() w = slua.loadUI(MENU_BP) end)
    if not w or not valid(w) then modLog("ERROR: loadUI MENU_BP failed"); return end
    pcall(function() require("game_frontend_hud").AddToContainer(UIContainers.Top, w, Z_MENU) end)
    pcall(function() if w.HBox_Button then w.HBox_Button:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.TextBlock_tips then w.TextBlock_tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Button_OK then w.Button_OK:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Button_Cancel then w.Button_Cancel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Button_1 then w.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Background_Btn then w.Background_Btn:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.UTRichText_Content then w.UTRichText_Content:SetText("") end end)
    for i = #pages + 1, 8 do
        pcall(function() if w["CanvasPanel_Tab_" .. i] then w["CanvasPanel_Tab_" .. i]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    end
    local tabNames = {}
    for i, p in ipairs(pages) do tabNames[i] = p.title end
    for i = 1, #pages do
        pcall(function()
            local tab = w["CanvasPanel_Tab_" .. i]
            if tab then tab:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end
            local txt = w["TextBlock_Tab_" .. i]
            if txt then txt:SetText(tabNames[i]) end
        end)
        pcall(function()
            local btn = w["Button_Tab_" .. i]
            if btn then
                if btn.OnClicked then btn.OnClicked:Clear() end
                if btn.OnClicked then
                    local idx = i
                    btn.OnClicked:Add(function()
                        self.currentPage = idx
                        self:BuildButtons(w)
                        self:UpdateTabs(w)
                    end)
                end
            end
        end)
    end
    pcall(function()
        local popup = w.Common_Popup_Large_UIBP
        if popup and valid(popup) and popup.close and valid(popup.close) then
            if popup.close.OnClicked then popup.close.OnClicked:Clear() end
            if popup.close.OnClicked then popup.close.OnClicked:Add(function() self:Close() end) end
        end
    end)
    self.currentPage = 1
    self:BuildButtons(w)
    self:UpdateTabs(w)
    self.menuWidget = w
    modLog("Menu Opened")
end

function SaJaDMenu:Toggle()
    if self.menuWidget and valid(self.menuWidget) then self:Close() else self:Open() end
end

function SaJaDMenu:EnsureTrigger()
    if self.triggerWidget and valid(self.triggerWidget) then return end
    local tw = nil
    pcall(function() tw = slua.loadUI(BTN_BP) end)
    if tw and valid(tw) then
        pcall(function() require("game_frontend_hud").AddToContainer(UIContainers.Top, tw, Z_TRIGGER) end)
        pcall(function()
            if tw.RichText_Content then
                local f = tw.RichText_Content.Font
                f.Size = 14
                tw.RichText_Content:SetFont(f)
                local expText = IsModExpired() and "انتهى الوقت" or ("اضغط [" .. GetDaysRemaining() .. "d]")
                tw.RichText_Content:SetText(expText)
            end
        end)
        pcall(function()
            if tw.Button_Temp and tw.Button_Temp.OnClicked then
                tw.Button_Temp.OnClicked:Add(function() self:Toggle() end)
            end
        end)
        pcall(function()
            local slot = import("WidgetLayoutLibrary").SlotAsCanvasSlot(tw)
            if slot then
                slot:SetAnchors(FAnchors(1, 0, 1, 0))
                slot:SetAlignment(FVector2D(1, 0))
                slot:SetPosition(FVector2D(-16, 72))
                slot:SetSize(FVector2D(90, 44))
            end
            tw:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        self.triggerWidget = tw
    end
end

later(3, function() SaJaDMenu:EnsureTrigger() end)
later(10, function() SaJaDMenu:EnsureTrigger() end)

local tk = _G.Mytimer_ticker
if not tk then pcall(function() tk = require("common.time_ticker"); _G.Mytimer_ticker = tk end) end
if tk and tk.AddTimerLoop then
    tk.AddTimerLoop(30, function()
        SaJaDMenu:EnsureTrigger()
        if SaJaDMenu.triggerWidget and valid(SaJaDMenu.triggerWidget) then
            pcall(function()
                local expText = IsModExpired() and "انتهى الوقت" or ("اضغط [" .. GetDaysRemaining() .. "d]")
                if SaJaDMenu.triggerWidget.RichText_Content then
                    SaJaDMenu.triggerWidget.RichText_Content:SetText(expText)
                end
            end)
        end
    end, -1, 30)
end

-- ============================================================
-- PART 20: INITIALIZATION
-- ============================================================

local function InitESPUI()
    SafeCall(function()
        if InGameMarkTools and InGameMarkTools.ScreenMarkManager and InGameMarkTools.ScreenMarkManager.OnInitMarkGroupData then
            InGameMarkTools.ScreenMarkManager:OnInitMarkGroupData(9999)
        end
    end)
end

local SaJaDPlayerCharacterMod = {
    ServerRPC = {
        ServerRPC_NearDeathGiveupRescue = { Reliable = true, Params = {} },
        ServerRPC_CarryDeadBox = { Reliable = true, Params = { UEnums.EPropertyClass.Object } }
    },
    ClientRPC = {},
    MulticastRPC = {}
}

function SaJaDPlayerCharacterMod:ctor()
    self.SaJaD_Initialized = false
end

function SaJaDPlayerCharacterMod:_PostConstruct()
    SaJaDPlayerCharacterMod.__super._PostConstruct(self)
    self:StartSaJaDMod()
end

function SaJaDPlayerCharacterMod:ReceiveBeginPlay()
    SaJaDPlayerCharacterMod.__super.ReceiveBeginPlay(self)
    if Client then
        if GameplayData.AddCharacter then GameplayData.AddCharacter(self.Object) end
        SafeCall(function()
            local tk = require("common.time_ticker")
            if tk and tk.AddTimerOnce then tk.AddTimerOnce(3, function() _G.TryShowWelcome() end) end
        end)
    end
end

function SaJaDPlayerCharacterMod:ReceiveEndPlay(reason)
    -- تنظيف Enemy Counter Widget
    if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
        EnemyCounterWidget:RemoveFromParent()
        EnemyCounterWidget = nil
    end
    
    -- تنظيف Map ESP
    for key, data in pairs(_G.SaJaD_Active_Marks_Cache or {}) do
        SafeCall(function()
            if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then
                InGameMarkTools.ClientRemoveMapMark(data.marker)
            end
        end)
    end
    _G.SaJaD_Active_Marks_Cache = {}
    
    SaJaDPlayerCharacterMod.__super.ReceiveEndPlay(self, reason)
    if Client and GameplayData.RemoveCharacter then GameplayData.RemoveCharacter(self.Object) end
end

function SaJaDPlayerCharacterMod:StartSaJaDMod()
    if not Client then return end
    if self.SaJaD_Initialized then return end
    if IsModExpired() then _G.TryShowWelcome(); return end
    InitAntiCheatBypasses()
    InitESPUI()
    if _G.SaJaDConfig.FPS165 then Apply165FPS() end
    if _G.SaJaDConfig.iPadFOV then ApplyiPadFOV() end
    self:AddGameTimer(0.5, true, function()
        if not IsValidObject(self.Object) then return end
        if IsModExpired() then return end
        SafeCall(function()
            ApplyMagicBullet()
            ProcessAllFeatures()
        end)
    end)
    self.SaJaD_Initialized = true
end

SafeCall(function()
    local tk = require("common.time_ticker")
    if tk and tk.AddTimerOnce then tk.AddTimerOnce(3, function() _G.TryShowWelcome() end) end
end)

-- ============================================================
-- PART 21: CLASS REGISTRATION
-- ============================================================

local class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local SaJaDPlayerCharacterClass = class(CharacterBase, nil, SaJaDPlayerCharacterMod)
local combine_class = require("combine_class")

return combine_class.DeclareFeature(SaJaDPlayerCharacterClass, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
    { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" }
}, "SaJaD_BRPlayerCharacterBase")