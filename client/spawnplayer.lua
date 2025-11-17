local HealthData = {}
local pvp = Config.PVP
local T = Translation[Lang].MessageOfSystem
local active = false
-- FUNCTIONS
function CoreAction.Utils.TogglePVP()
    pvp = not pvp
    TriggerEvent("vorp:setPVPUi", pvp)
    return pvp
end

function CoreAction.Utils.setPVP()
    local playerHash = joaat("PLAYER")
    NetworkSetFriendlyFireOption(pvp)

    if not active then
        if pvp then
            SetRelationshipBetweenGroups(5, playerHash, playerHash)
        else
            SetRelationshipBetweenGroups(1, playerHash, playerHash)
        end
    else
        SetRelationshipBetweenGroups(1, playerHash, playerHash)
    end
end

function CoreAction.Player.TeleportToCoords(coords, heading)
    SetEntityCoordsAndHeading(PlayerPedId(), coords.x, coords.y, coords.z, heading or 0.0, false, false, false)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    -- repeat Wait(0) until HasCollisionLoadedAroundEntity(PlayerPedId()) == 1
    --  repeat Wait(0) until not IsEntityWaitingForWorldCollision(PlayerPedId())
    -- repeat Wait(0) until HasCollisionLoadedAroundPosition(coords.x, coords.y, coords.z)
    LoadSceneStart(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 30.0, 0)
    repeat Wait(0) until IsLoadSceneLoaded() ~= 0
    LoadSceneStop()
end

function CoreAction.Player.MapCheck()
    while Config.enableTypeRadar do
        Wait(3000)
        local player = PlayerPedId()
        local playerOnMout = IsPedOnMount(player)
        local playerOnVeh = IsPedInAnyVehicle(player, false)
        if not playerOnMout and not playerOnVeh then
            SetMinimapType(Config.mapTypeOnFoot)
        elseif playerOnMout or playerOnVeh then
            SetMinimapType(Config.mapTypeOnMount)
        end
    end
end

-- PLAYERSPAWN
AddEventHandler('playerSpawned', function()
    exports.spawnmanager:setAutoSpawn(false)
    DoScreenFadeOut(0)
    if Config.UseInnitialLoadingScreen then
        Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Hold, T.Load, T.Almost) --_DISPLAY_LOADING_SCREENS
    end
    DisplayRadar(false)
    SetMinimapHideFow(false)
    SetEntityCanBeDamaged(PlayerPedId(), false)
    TriggerServerEvent("vorp:playerSpawn")

    Wait(2000)
    if Config.UseInnitialLoadingScreen then
        SetTimeout(7000, function()
            ShutdownLoadingScreen()
        end)
    end
    local isInSession = false
    CreateThread(function()
        while not isInSession do
            Wait(0)
            DisableControlAction(0, `INPUT_MP_TEXT_CHAT_ALL`, true)
            DisableControlAction(0, `INPUT_QUICK_USE_ITEM`, true)
        end
    end)

    repeat Wait(1000) until LocalPlayer.state.IsInSession
    isInSession = true
end)


--EVENTS character Innitialize
RegisterNetEvent('vorp:initCharacter')
AddEventHandler('vorp:initCharacter', function(coords, heading, isdead)
    if not IsScreenFadedOut() then
        DoScreenFadeOut(0)
    end

    CoreAction.Player.TeleportToCoords(coords, heading)
    if isdead then
        if not Config.CombatLogDeath then
            if Config.Loadinscreen then
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.forcedrespawn, T.forced, T.Almost)
            end
            SetEntityCanBeDamaged(PlayerPedId(), true)
            CoreAction.Player.RespawnPlayer() -- this one doesnt need to trigger events, its for player combat log
            Wait(Config.LoadinScreenTimer)
            Wait(1000)
            ShutdownLoadingScreen()
            Wait(5000)
        else
            if Config.Loadinscreen then
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Holddead, T.Loaddead, T.Almost)
            end
            Wait(10000)
            TriggerEvent("vorp_inventory:CloseInv")
            Wait(4000)
            SetEntityCanBeDamaged(PlayerPedId(), true)
            SetEntityHealth(PlayerPedId(), 0, 0)
            Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 0, -1)
            if Config.Loadinscreen then
                ShutdownLoadingScreen()
            end
        end
    else
        local PlayerId = PlayerId()
        if Config.Loadinscreen then
            if Config.LoadingScreenPlayerInfo then
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, LocalPlayer.state.Character.FirstName .. " " .. LocalPlayer.state.Character.LastName, "Job:" .. " " .. LocalPlayer.state.Character.JobLabel)
            else
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Hold, T.Load, T.Almost)
            end
            Wait(Config.LoadinScreenTimer)
            ShutdownLoadingScreen()
        end

        if not Config.HealthRecharge.enable then
            Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId, 0.0) -- SetPlayerHealthRechargeMultiplier
        end

        if not Config.StaminaRecharge.enable then
            Citizen.InvokeNative(0xFECA17CF3343694B, PlayerId, 0.0) -- SetPlayerStaminaRechargeMultiplier
        end

        SetEntityCanBeDamaged(PlayerPedId(), true)

        if Config.SavePlayersStatus then
            HealthData = nil
            TriggerServerEvent("vorp:GetValues")
            repeat Wait(0) until HealthData
            if HealthData then
                local player = PlayerPedId()
                if HealthData.hInner and HealthData.hInner >= 100 then
                    HealthData.hInner = 100
                else
                    HealthData.hInner = 10
                end
                if HealthData.sInner and HealthData.sInner >= 100 then
                    HealthData.sInner = 100
                else
                    HealthData.sInner = 10
                end

                local newHealth = 600
                if HealthData.hInner and HealthData.hInner >= 100 then
                    newHealth = HealthData.hOuter or 10
                end

                SetAttributeCoreValue(player, 0, HealthData.hInner) -- inner health
                SetEntityHealth(player, newHealth, 0)
                SetAttributeCoreValue(player, 1, HealthData.sInner)
                local maxStamina = GetPedMaxStamina(player)
                local amount = maxStamina - HealthData.sInner
                ChangePedStamina(player, amount + 0.0)
                HealthData = {}
            end
        else
            CoreAction.Admin.HealPlayer()
        end
    end

    DoScreenFadeIn(3000)
    repeat Wait(500) until IsScreenFadedIn()
    TriggerEvent("vorp_core:Client:OnPlayerSpawned")
end)


-- PLAYER SPAWN AFTER SELECT CHARACTER
RegisterNetEvent("vorp:SelectedCharacter", function()
    CoreAction.Utils.setPVP()
    local PlayerPed = PlayerPedId()
    local PlayerId = PlayerId()
    SetEntityCanBeDamaged(PlayerPed, true)
    Citizen.InvokeNative(0xA63FCAD3A6FEC6D2, PlayerId, Config.ActiveEagleEye)
    Citizen.InvokeNative(0x95EE1DEE1DCD9070, PlayerId, Config.ActiveDeadEye)
    TriggerEvent("vorp:showUi", not Config.HideUi)
    DisplayRadar(true)
    SetMinimapHideFow(true)
    TriggerServerEvent("vorp:chatSuggestion")
    TriggerServerEvent('vorp_core:instanceplayers', 0) -- remove instanced players
    TriggerServerEvent("vorp:SaveDate")

    SetTimeout(10000, function()
        -- GUARMA SPAWN
        local pedCoords = GetEntityCoords(PlayerPedId())
        local area = Citizen.InvokeNative(0x43AD8FC02B429D33, pedCoords, 10)
        if area == -512529193 then
            Citizen.InvokeNative(0xA657EC9DBC6CC900, 1935063277)
            Citizen.InvokeNative(0xE8770EE02AEE45C2, 1)
            Citizen.InvokeNative(0x74E2261D2A66849A, true)
        end
    end)

    CreateThread(CoreAction.Player.MapCheck)
end)

RegisterNetEvent("vorp:GetHealthFromCore", function(healthData)
    HealthData = healthData or {}
end)

-- THREADS
CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    while true do
        local pped = PlayerPedId()
        local sleep = 0

        if IsControlPressed(0, 0xCEFD9220) then
            active = true
            CoreAction.Utils.setPVP()
            Wait(4000)
        end

        if not IsPedOnMount(pped) and not IsPedInAnyVehicle(pped, false) and active then
            active = false
            CoreAction.Utils.setPVP()
        elseif active and IsPedOnMount(pped) or IsPedInAnyVehicle(pped, false) then
            if IsPedInAnyVehicle(pped, false) then

            elseif GetPedInVehicleSeat(GetMount(pped), -1) == pped then
                active = false
                CoreAction.Utils.setPVP()
            end
        else
            CoreAction.Utils.setPVP()
        end

        Wait(sleep)
    end
end)



CreateThread(function()
    while true do
        Wait(0)
        DisableControlAction(0, 0x580C4473, true)              -- Disable hud
        DisableControlAction(0, 0xCF8A4ECA, true)              -- Disable hud
        DisableControlAction(0, 0x9CC7A1A4, true)              -- disable special ability when open hud
        DisableControlAction(0, 0x1F6D95E5, true)              -- diable f4 key that contains HUD
        if IsUiappActiveByHash(`MAP`) == 1 then                -- only when map is open incase someone needs to use the X key
            DisableControlAction(0, `INPUT_FRONTEND_RS`, true) -- disables the x button that freezes players when in the big map
        end
    end
end)


CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    while Config.SavePlayersStatus do
        Wait(1000)
        local player = PlayerPedId()
        local innerCoreHealth = Citizen.InvokeNative(0x36731AC041289BB1, player, 0)
        local outerCoreStamina = Citizen.InvokeNative(0x22F2A386D43048A9, player)
        local innerCoreStamina = Citizen.InvokeNative(0x36731AC041289BB1, player, 1)
        local getHealth = GetEntityHealth(player)
        TriggerServerEvent("vorp:HealthCached", getHealth, innerCoreHealth, outerCoreStamina, innerCoreStamina)
    end
end)

CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    while Config.SavePlayersStatus do
        local player = PlayerPedId()
        Wait(300000) -- wont be accurate as it waits for too long
        local innerCoreHealth = Citizen.InvokeNative(0x36731AC041289BB1, player, 0, Citizen.ResultAsInteger())
        local outerCoreStamina = Citizen.InvokeNative(0x22F2A386D43048A9, player)
        local innerCoreStamina = Citizen.InvokeNative(0x36731AC041289BB1, player, 1, Citizen.ResultAsInteger())
        local getHealth = GetEntityHealth(player)
        local innerHealth = tonumber(innerCoreHealth)
        local innerStamina = tonumber(innerCoreStamina)
        TriggerServerEvent("vorp:SaveHealth", getHealth, innerHealth)
        TriggerServerEvent("vorp:SaveStamina", outerCoreStamina, innerStamina)
    end
end)

-- APPLY HEALTHRECHARGE WHEN CHARACTER RC
CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession

    while Config.HealthRecharge.enable or Config.StaminaRecharge.enable do
        local sleep = 1000

        if not IsPlayerDead(PlayerId()) then
            sleep = 500
            local PlayerId = PlayerId()
            local PlayerPed = PlayerPedId()

            if Config.HealthRecharge.enable then
                local NewRechargeMultiplier = GetAttributeCoreValue(PlayerPed, 0, Citizen.ResultAsInteger()) / 100 * Config.HealthRecharge.multiplier
                local RechargeMultiplier = GetPlayerHealthRechargeMultiplier(PlayerId, Citizen.ResultAsFloat())

                if math.abs(NewRechargeMultiplier - RechargeMultiplier) > 0.01 then
                    SetPlayerHealthRechargeMultiplier(PlayerId, NewRechargeMultiplier)
                end
            end

            if Config.StaminaRecharge.enable then
                local NewRechargeMultiplier = GetAttributeCoreValue(PlayerPed, 1, Citizen.ResultAsInteger()) / 100 * Config.StaminaRecharge.multiplier
                local RechargeMultiplier = GetPlayerStaminaRechargeMultiplier(PlayerId, Citizen.ResultAsFloat())

                if math.abs(NewRechargeMultiplier - RechargeMultiplier) > 0.01 then
                    SetPlayerStaminaRechargeMultiplier(PlayerId, NewRechargeMultiplier)
                end
            end
        end

        Wait(sleep)
    end
end)
