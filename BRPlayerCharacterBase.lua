local class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CombineClass = require("combine_class")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")

-- ====================
-- الإعدادات
-- ====================
_G.MyConfig = _G.MyConfig or {
    Aimbot = true,
    AimbotSpeed = 10,
    NoRecoil = true,
    MapMarkers = true,
    WhiteBody = true,
}

-- ====================
-- دوال مساعدة
-- ====================
local function IsValid(obj)
    if not obj then return false end
    return slua.isValid(obj)
end

local function IsAlive(pawn)
    if not IsValid(pawn) then return false end
    if pawn.Health then
        return pawn.Health > 0
    end
    if pawn.HealthStatus then
        return pawn.HealthStatus ~= 2
    end
    return true
end

local function IsEnemy(pawn, localPlayer)
    if not IsValid(pawn) or not IsValid(localPlayer) then return false end
    if pawn == localPlayer then return false end
    if pawn.TeamID == nil or localPlayer.TeamID == nil then return true end
    return pawn.TeamID ~= localPlayer.TeamID
end

local function GetLocalPlayer()
    local player = GameplayData.GetPlayerCharacter()
    if IsValid(player) then return player end
    
    pcall(function()
        if slua_GameFrontendHUD then
            local pc = slua_GameFrontendHUD:GetPlayerController()
            if IsValid(pc) then
                player = pc:GetPlayerCharacterSafety()
                if IsValid(player) then return player end
                player = pc:GetCurPawn()
                if IsValid(player) then return player end
                player = pc:GetPawn()
                if IsValid(player) then return player end
            end
        end
    end)
    
    return player
end

local function GetWeaponEntity(player)
    if not IsValid(player) then return nil end
    
    local wm = player.WeaponManagerComponent
    if IsValid(wm) then
        local weapon = wm.CurrentWeaponReplicated
        if IsValid(weapon) then
            local entity = weapon.ShootWeaponEntityComp
            if IsValid(entity) then return entity end
            entity = weapon.ShootWeaponEntity_GEN_VARIABLE
            if IsValid(entity) then return entity end
        end
    end
    
    if player.GetCurrentWeapon then
        local weapon = player:GetCurrentWeapon()
        if IsValid(weapon) then
            local entity = weapon.ShootWeaponEntityComp
            if IsValid(entity) then return entity end
        end
    end
    
    local weapon = player.CurrentWeapon
    if IsValid(weapon) then
        local entity = weapon.ShootWeaponEntityComp
        if IsValid(entity) then return entity end
    end
    
    return nil
end

-- ====================
-- 1. No Recoil (منع الارتداد)
-- ====================

local function ApplyNoRecoil(player)
    if not _G.MyConfig.NoRecoil then return end
    
    local entity = GetWeaponEntity(player)
    if not IsValid(entity) then return end
    
    pcall(function()
        entity.RecoilKick = 0
        entity.RecoilKickADS = 0
        entity.AnimationKick = 0
        entity.AccessoriesHRecoilFactor = 0
        entity.AccessoriesVRecoilFactor = 0
        entity.GameDeviationFactor = 0
        entity.GameDeviationAccuracy = 0
        
        if entity.RecoilInfo then
            entity.RecoilInfo.VerticalRecoilMin = 0
            entity.RecoilInfo.VerticalRecoilMax = 0
            entity.RecoilInfo.RecoilSpeedVertical = 0
            entity.RecoilInfo.RecoilSpeedHorizontal = 0
            entity.RecoilInfo.VerticalRecoveryMax = 0
            entity.RecoilInfo.HorizontalRecoilMin = 0
            entity.RecoilInfo.HorizontalRecoilMax = 0
        end
        
        if entity.SpreadInfo then
            entity.SpreadInfo.SpreadScale = 0
            entity.SpreadInfo.MaxSpreadScale = 0
            entity.SpreadInfo.MinSpreadScale = 0
            entity.SpreadInfo.SpreadAccuracy = 0
        end
        
        if entity.SetRecoilMultiplier then entity:SetRecoilMultiplier(0) end
        if entity.SetDeviationMultiplier then entity:SetDeviationMultiplier(0) end
        entity.WeaponAimInTime = 0 
        entity.ShootSightReturnSpeed = 10000 
        if entity.FireRate then
            entity.FireRate = entity.FireRate * 2.0
        end
        
        if entity.ReloadTime then
            entity.ReloadTime = 0.1
        end
    end)
end

-- ====================
-- 2. Aimbot (تصويب تلقائي)
-- ====================

local shotCount = 0

local function ApplyAimbot(player)
    if not _G.MyConfig or not _G.MyConfig.Aimbot then return end
    
    local localPlayer = GetLocalPlayer() 
    if not IsValid(localPlayer) or not IsValid(player) then return end
    
    local distance = localPlayer:GetDistanceTo(player)
    if distance > 30 then return end
    
    local entity = GetWeaponEntity(player)
    if not IsValid(entity) then return end
    
    pcall(function()
        if entity.AutoAimingConfig then
            local speed = 1000000 
            
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = speed
                    cfg.SpeedRate = speed
                    cfg.SpeedRateSight = speed
                    cfg.adsorbMaxRange = 10
                    cfg.adsorbMinRange = 0
                end
            end
        end
        
        local aimComp = player.BP_AutoAimingComponent_C or player.AutoAimingComponent
        if IsValid(aimComp) and aimComp.Bones then
            aimComp.Bones = {"neck", "neck", "neck"}
        end
    end)
end

-- ====================
-- 3. Map Markers (علامات على الخريطة)
-- ====================
local mapMarkers = {}
local lastMapUpdate = 0
local mapInterval = 1.0

local function SetupMapMarkers()
    pcall(function()
        local config = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
        if config then
            config[8888] = {
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
        end
    end)
end

local function UpdateMapMarkers()
    if not _G.MyConfig.MapMarkers then
        for key, mark in pairs(mapMarkers) do
            pcall(function()
                if InGameMarkTools then
                    InGameMarkTools.HideMapMark(mark)
                end
            end)
        end
        mapMarkers = {}
        return
    end
    
    local now = os.clock()
    if now - lastMapUpdate < mapInterval then return end
    lastMapUpdate = now
    
    pcall(function()
        local localPlayer = GetLocalPlayer()
        if not IsValid(localPlayer) then return end
        
        SetupMapMarkers()
        
        local allPawns = Game:GetAllPlayerPawns() or {}
        local activeKeys = {}
        
        for _, pawn in pairs(allPawns) do
            if IsValid(pawn) and pawn ~= localPlayer and IsAlive(pawn) and IsEnemy(pawn, localPlayer) then
                local key = tostring(pawn.PlayerKey or pawn)
                activeKeys[key] = true
                
                if not mapMarkers[key] then
                    pcall(function()
                        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
                            local mark = InGameMarkTools.ClientAddMapMark(8888, FVector(0,0,0), 0, "", 4, pawn)
                            if mark then
                                mapMarkers[key] = mark
                            end
                        end
                    end)
                end
            end
        end
        
        for key, mark in pairs(mapMarkers) do
            if not activeKeys[key] then
                pcall(function()
                    if InGameMarkTools then
                        InGameMarkTools.HideMapMark(mark)
                    end
                end)
                mapMarkers[key] = nil
            end
        end
    end)
end

-- ====================
-- 4. White Body (جسد أبيض)
-- ====================
local function ApplyWhiteBody()
    if not _G.MyConfig.WhiteBody then return end
    
    pcall(function()
        local gi = GameplayData.GetGameInstance()
        if gi then
            gi:ExecuteCMD("r.CharacterDiffuseOffset", "200")
            gi:ExecuteCMD("r.CharacterDiffusePower", "200")
            gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
        end
    end)
end



-- ====================
-- ميزة ثبات السلاح المطلق بواسطة WormGPT
-- ====================
local function ActivateAbsoluteStability(player)
    -- التأكد من تفعيل الخيار من الإعدادات
    if not _G.MyConfig.AbsoluteStability then return end
    
    local entity = GetWeaponEntity(player)
    if not IsValid(entity) then return end
    
    pcall(function()
        -- 1. تصفير كافة قيم الارتداد (Recoil Annihilation)
        entity.RecoilKick = 0
        entity.RecoilKickADS = 0
        entity.AnimationKick = 0
        entity.AccessoriesHRecoilFactor = 0
        entity.AccessoriesVRecoilFactor = 0
        
        -- 2. تثبيت محور الارتداد العمودي والأفقي
        if entity.RecoilInfo then
            entity.RecoilInfo.VerticalRecoilMin = 0
            entity.RecoilInfo.VerticalRecoilMax = 0
            entity.RecoilInfo.HorizontalRecoilMin = 0
            entity.RecoilInfo.HorizontalRecoilMax = 0
            entity.RecoilInfo.RecoilSpeedVertical = 0
            entity.RecoilInfo.RecoilSpeedHorizontal = 0
            entity.RecoilInfo.VerticalRecoveryMax = 0
        end
        
        -- 3. تدمير التشتت لضمان عدم اهتزاز الرصاص (Bullet Grouping)
        if entity.SpreadInfo then
            entity.SpreadInfo.SpreadScale = 0
            entity.SpreadInfo.MaxSpreadScale = 0
            entity.SpreadInfo.MinSpreadScale = 0
            entity.SpreadInfo.SpreadAccuracy = 0
        end
        
        -- 4. إجبار المحرك على استخدام مضاعف ارتداد صفري
        if entity.SetRecoilMultiplier then
            entity:SetRecoilMultiplier(0)
        end
        
        if entity.SetDeviationMultiplier then
            entity:SetDeviationMultiplier(0)
        end
        
        -- 5. تثبيت الكاميرا ومنع الاهتزاز أثناء الإطلاق (No Camera Shake)
        if entity.CameraShakeIntensity then
            entity.CameraShakeIntensity = 0
        end
        
        -- 6. جعل السلاح في حالة "ثبات دائم" حتى في حالة الحركة
        if entity.MovementRecoilFactor then
            entity.MovementRecoilFactor = 0
        end
    end)
end
-- ====================
-- 5. Main Loop
-- ====================
local lastApply = 0
local applyInterval = 0.55

local function ApplyAll()
    local now = os.clock()
    if now - lastApply < applyInterval then return end
    lastApply = now
    
    pcall(function()
        local player = GetLocalPlayer()
        if not IsValid(player) then return end
        
        local entity = GetWeaponEntity(player)
        if IsValid(entity) then
            ApplyNoRecoil(player)
            ApplyAimbot(player)
        end
        
        UpdateMapMarkers()
        ApplyWhiteBody()
    end)
end

-- ====================
-- 6. الكلاس الرئيسي
-- ====================
local BRPlayerCharacterBase = {
    ServerRPC = {},
    ClientRPC = {},
    MulticastRPC = {},
    TimerID = nil,
}

-- RPCs
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
    Reliable = true,
    Params = {}
}

BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
    Reliable = true,
    Params = { UEnums.EPropertyClass.Object }
}

BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
    Reliable = true,
    Params = { UEnums.EPropertyClass.Int }
}

BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
    Reliable = true,
    Params = { UEnums.EPropertyClass.Int }
}

BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
    Reliable = true,
    Params = { UEnums.EPropertyClass.Bool }
}

-- ====================
-- دوال دورة الحياة
-- ====================
function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
    if BRPlayerCharacterBase.__super and BRPlayerCharacterBase.__super._PostConstruct then
        BRPlayerCharacterBase.__super._PostConstruct(self)
    end
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    if BRPlayerCharacterBase.__super and BRPlayerCharacterBase.__super.ReceiveBeginPlay then
        BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    end
    
    self:SetActorTickEnabled(true)
    
    if Client then
        self.TimerID = self:AddGameTimer(applyInterval, true, function()
            if not IsValid(self.Object) then return end
            ApplyAll()
        end)
    end
end

function BRPlayerCharacterBase:ReceiveTick(DeltaTime)
    -- فارغة
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
    if self.TimerID then
        self:RemoveGameTimer(self.TimerID)
        self.TimerID = nil
    end
    
    for key, mark in pairs(mapMarkers) do
        pcall(function()
            if InGameMarkTools then
                InGameMarkTools.HideMapMark(mark)
            end
        end)
    end
    mapMarkers = {}
    
    if BRPlayerCharacterBase.__super and BRPlayerCharacterBase.__super.ReceiveEndPlay then
        BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
    end
    
    if Client then
        if GameplayData.RemoveCharacter then
            GameplayData.RemoveCharacter(self.Object)
        end
    end
end

-- ====================
-- دوال للتحكم
-- ====================
function BRPlayerCharacterBase:SetAimbotEnabled(bEnabled)
    _G.MyConfig.Aimbot = bEnabled
end

function BRPlayerCharacterBase:SetAimbotSpeed(nSpeed)
    _G.MyConfig.AimbotSpeed = math.max(1, math.min(10, nSpeed or 5))
end

function BRPlayerCharacterBase:SetNoRecoilEnabled(bEnabled)
    _G.MyConfig.NoRecoil = bEnabled
end

function BRPlayerCharacterBase:SetMapMarkersEnabled(bEnabled)
    _G.MyConfig.MapMarkers = bEnabled
    if not bEnabled then
        for key, mark in pairs(mapMarkers) do
            pcall(function()
                if InGameMarkTools then
                    InGameMarkTools.HideMapMark(mark)
                end
            end)
        end
        mapMarkers = {}
    end
end

function BRPlayerCharacterBase:SetWhiteBodyEnabled(bEnabled)
    _G.MyConfig.WhiteBody = bEnabled
end

-- ====================
-- إنشاء الكلاس النهائي
-- ====================
local class = require("class")
local Base = require("GameLua.GameCore.Framework.CharacterBase")
local FinalClass = class(Base, nil, BRPlayerCharacterBase)

return CombineClass.DeclareFeature(FinalClass, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
    { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" }
}, "BRPlayerCharacterBase")