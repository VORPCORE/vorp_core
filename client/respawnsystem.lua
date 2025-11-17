local setDead = false
local TimeToRespawn = 1
local cam
local angleY = 0.0
local angleZ = 0.0
local prompts = GetRandomIntInRange(0, 0xffffff)
local prompt
local PressKey = false
local carried = false
local Done = false
local T = Translation[Lang].MessageOfSystem
local keepdown

local function CheckLabel()
    if not carried then
        if not Done then
            return VarString(10, 'LITERAL_STRING', T.RespawnIn .. TimeToRespawn .. T.SecondsMove .. T.message)
        else
            return VarString(10, 'LITERAL_STRING', T.message2)
        end
    else
        return VarString(10, 'LITERAL_STRING', T.YouAreCarried)
    end
end

local function RespawnTimer()
    TimeToRespawn = Config.RespawnTime
    CreateThread(function() -- asyncronous
        while true do
            Wait(1000)
            TimeToRespawn = TimeToRespawn - 1
            if TimeToRespawn < 0 and setDead then
                TimeToRespawn = 0
                break
            end

            if not setDead then
                TimeToRespawn = Config.RespawnTime
                break
            end
        end
    end)
end

local function ProcessNewPosition()
    local mouseX = GetDisabledControlNormal(1, 0x4D8FB4C1) * 0.5
    local mouseY = GetDisabledControlNormal(1, 0xFDA83190) * 0.5

    angleZ = angleZ - mouseX
    angleY = angleY + mouseY

    if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end
    local pCoords = GetEntityCoords(PlayerPedId())
    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (3.0 + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (3.0 + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (3.0 + 0.5)
    }
    local rayHandle = StartShapeTestLosProbe(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local _, hitBool, hitCoords = GetShapeTestResult(rayHandle)

    local maxRadius = 3.0
    if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords.x, hitCoords.y, hitCoords.z) < 3.0 + 0.5) then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords.x, hitCoords.y, hitCoords.z)
    end

    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }

    local pos = {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z
    }

    return pos
end

local function StartDeathCam()
    ClearFocus()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, 0, 0, 0, GetGameplayCamFov(), false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, false, 0)
end

local function ProcessCamControls()
    local playerCoords
    if Config.UseControlsCamera then
        playerCoords = ProcessNewPosition()
    else
        playerCoords = GetEntityCoords(PlayerPedId())
    end

    local newPos = playerCoords
    if IsEntityAttachedToAnyPed(PlayerPedId()) then
        SetCamCoord(cam, newPos.x, newPos.y + -2, newPos.z + 0.50)
        SetCamRot(cam, -20.0, 0.0, 0.0, 1)
        SetCamFov(cam, 50.0)
    else
        SetCamCoord(cam, newPos.x, newPos.y, newPos.z + 1.0)
        SetCamRot(cam, -80.0, 0.0, 0.0, 1)
        SetCamFov(cam, 50.0)
    end
end

local function EndDeathCam()
    NetworkSetInSpectatorMode(false, PlayerPedId())
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false, 0)
    DestroyCam(cam, false)
    cam = nil
    DestroyAllCams(true)
end

function CoreAction.Player.ResurrectPlayer(currentHospital, currentHospitalName, justrevive)
    local player = PlayerPedId()
    Citizen.InvokeNative(0xCE7A90B160F75046, false) --SET_CINEMATIC_MODE_ACTIVE
    TriggerEvent("vorp:showUi", not Config.HideUi)
    ResurrectPed(player)
    Wait(200)
    EndDeathCam()
    TriggerServerEvent("vorp:ImDead", false)
    setDead = false
    DisplayHud(true)
    DisplayRadar(true)
    CoreAction.Utils.setPVP()
    TriggerEvent("vorpcharacter:reloadafterdeath")
    Wait(500)
    if currentHospital and currentHospital then
        Citizen.InvokeNative(0x203BEFFDBE12E96A, player, currentHospital, false, false, false) -- _SET_ENTITY_COORDS_AND_HEADING
    end
    Wait(2000)
    CoreAction.Admin.HealPlayer()
    if Config.RagdollOnResurrection and not justrevive then
        keepdown = true
        CreateThread(function()
            while keepdown do
                Wait(0)
                SetPedToRagdoll(player, 4000, 4000, 0, false, false, false)
                ResetPedRagdollTimer(player)
                DisablePedPainAudio(player, true)
            end
        end)
        AnimpostfxPlay("Title_Gen_FewHoursLater")
        Wait(3000)
        DoScreenFadeIn(2000)
        AnimpostfxPlay("PlayerWakeUpInterrogation")
        Wait(19000)
        keepdown = false
        VorpNotification:NotifyLeft(currentHospitalName or T.message6, T.message5, "minigames_hud", "five_finger_burnout", 8000, "COLOR_PURE_WHITE")
    else
        DoScreenFadeIn(2000)
    end
end

function CoreAction.Player.RespawnPlayer(allowCleanItems)
    if allowCleanItems then
        TriggerServerEvent("vorp:PlayerForceRespawn") -- inventory clean items
    end
    TriggerEvent("vorp:PlayerForceRespawn")           -- inventory dead handler and metabolism , this need to be changed to the new events
    local closestDistance = math.huge
    local closestLocation = ""
    local coords = nil
    local pedCoords = GetEntityCoords(PlayerPedId())
    for _, location in pairs(Config.Hospitals) do
        local locationCoords = vector3(location.pos.x, location.pos.y, location.pos.z)
        local currentDistance = #(pedCoords - locationCoords)
        if currentDistance < closestDistance then
            closestDistance = currentDistance
            closestLocation = location.name
            coords = location.pos
        end
    end

    TriggerEvent("vorpmetabolism:changeValue", "Thirst", 1000)
    TriggerEvent("vorpmetabolism:changeValue", "Hunger", 1000)
    CoreAction.Player.ResurrectPlayer(coords, closestLocation, false) -- no need  to trigger events repawns even already triggered
end

-- CREATE PROMPT
CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    local str = T.prompt
    local keyPress = Config.RespawnKey
    prompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(prompt, keyPress)
    str = VarString(10, 'LITERAL_STRING', str)
    UiPromptSetText(prompt, str)
    UiPromptSetEnabled(prompt, true)
    UiPromptSetVisible(prompt, true)
    UiPromptSetHoldMode(prompt, Config.RespawnKeyTime)
    UiPromptSetGroup(prompt, prompts, 0)
    UiPromptSetPriority(prompt, 3)
    UiPromptRegisterEnd(prompt)
end)

RegisterNetEvent("vorp_core:Client:AddTimeToRespawn")
AddEventHandler("vorp_core:Client:AddTimeToRespawn", function(time)
    if TimeToRespawn >= 1 then
        TimeToRespawn = TimeToRespawn + time
    else
        RespawnTimer()
    end
end)


--DEATH HANDLER
CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession

    while Config.UseDeathHandler do
        local sleep = 1000

        if IsPlayerDead(PlayerId()) then
            if not setDead then
                setDead = true
                PressKey = false
                UiPromptSetEnabled(prompt, true)
                NetworkSetInSpectatorMode(false, PlayerPedId())
                TriggerServerEvent("vorp:ImDead", true) -- internal event
                local getKillerPed = GetPedSourceOfDeath(PlayerPedId())
                local killerServerId = 0
                if IsPedAPlayer(getKillerPed) then
                    local killer = NetworkGetPlayerIndexFromPed(getKillerPed)
                    if killer then
                        killerServerId = GetPlayerServerId(killer)
                    end
                end
                local deathCause = GetPedCauseOfDeath(PlayerPedId())
                TriggerServerEvent("vorp_core:Server:OnPlayerDeath", killerServerId, deathCause)
                TriggerEvent("vorp_core:Client:OnPlayerDeath", killerServerId, deathCause)
                DisplayRadar(false)
                CreateThread(RespawnTimer)
                CreateThread(StartDeathCam)
            end

            if not PressKey and setDead then
                sleep = 0
                if not IsEntityAttachedToAnyPed(PlayerPedId()) then
                    UiPromptSetActiveGroupThisFrame(prompts, CheckLabel(), 0, 0, 0, 0)

                    if UiPromptHasHoldModeCompleted(prompt) then
                        if Config.CanRespawn() then
                            DoScreenFadeOut(3000)
                            Wait(3000)
                            TriggerServerEvent("vorp_core:PlayerRespawnInternal", true)
                            Wait(1000)
                            PressKey      = true
                            carried       = false
                            Done          = false
                            TimeToRespawn = Config.RespawnTime
                        end
                    end

                    if TimeToRespawn >= 1 and setDead then
                        ProcessCamControls()
                        Done = false
                        UiPromptSetEnabled(prompt, false)
                    else
                        ProcessCamControls()
                        Done = true
                        UiPromptSetEnabled(prompt, true)
                    end
                    carried = false
                else
                    if setDead then
                        UiPromptSetActiveGroupThisFrame(prompts, CheckLabel(), 0, 0, 0, 0)
                        UiPromptSetEnabled(prompt, false)
                        ProcessCamControls()
                        carried = true
                    end
                end
            end
        end

        Wait(sleep)
    end
end)
