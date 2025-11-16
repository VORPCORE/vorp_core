---@class CoreAction CoreAction
CoreAction = {}
CoreAction.Admin = {}
CoreAction.Utils = {}
CoreAction.Player = {}

local T = Translation[Lang].MessageOfSystem


function CoreAction.Admin.HealPlayer()
    local player = PlayerPedId()
    local isPlayerDead = IsEntityDead(player)
    if isPlayerDead then
        print("cannot heal a dead player, revive player first")
        return
    end
    SetAttributeCoreValue(player, 0, 100)
    SetEntityHealth(player, GetEntityMaxHealth(player), 0)
    SetAttributeCoreValue(player, 1, 100)
    RestorePedStamina(player, 100.0)
    -- not sure why but player will be invincible from this point, only when max chars is to 1, makes no sense. so we gotta invoke these natives after healing.
    FreezeEntityPosition(player, false)
    SetEntityVisible(player, true)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityCanBeDamaged(player, true)
    SetGameplayCamRelativeHeading(0.0, 1.0)
end

function CoreAction.Admin.DeleteHorse()
    local player = PlayerPedId()

    if not IsPedOnMount(player) then
        return VorpNotification:NotifyRightTip(T.sit, 3000)
    end
    local mount = GetMount(player)
    local attempt = 0
    if not NetworkHasControlOfEntity(mount) then
        NetworkRequestControlOfEntity(mount)
        repeat
            Wait(100)
            attempt = attempt + 1
        until NetworkHasControlOfEntity(mount) or attempt > 100 or not DoesEntityExist(mount)
    end

    DeleteEntity(mount)
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end

        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end

        local enum = { handle = iter, destructor = disposeFunc }
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

---@param radius number
function CoreAction.Admin.DeleteVehicleInRadius(radius)
    local player = PlayerPedId()

    local function EnumerateVehicles()
        return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
    end

    local function GetVehicles()
        local vehicles = {}

        for vehicle in EnumerateVehicles() do
            table.insert(vehicles, vehicle)
        end

        return vehicles
    end

    local function GetVehiclesInArea(coords, area)
        local vehicles       = GetVehicles()
        local vehiclesInArea = {}

        for i = 1, #vehicles, 1 do
            local vehicleCoords = GetEntityCoords(vehicles[i])
            local distance      = #(coords - vehicleCoords)

            if distance <= area then
                table.insert(vehiclesInArea, vehicles[i])
            end
        end

        return vehiclesInArea
    end

    local function GetVehicleInDirection()
        local playerPed               = PlayerPedId()
        local playerCoords            = GetEntityCoords(playerPed)
        local inDirection             = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
        local rayHandle               = StartExpensiveSynchronousShapeTestLosProbe(playerCoords.x, playerCoords.y,
            playerCoords.z, inDirection.x, inDirection.y, inDirection.z, 10, playerPed, 0)
        local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)

        if hit == 1 and GetEntityType(entityHit) == 2 then
            local entityCoords = GetEntityCoords(entityHit)
            return entityHit, entityCoords
        end

        return nil
    end

    if radius and tonumber(radius) then
        radius = tonumber(radius) + 0.01
        local vehicles = GetVehiclesInArea(GetEntityCoords(player), radius)
        for k, entity in ipairs(vehicles) do
            local attempt = 0

            while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
                Wait(100)
                NetworkRequestControlOfEntity(entity)
                attempt = attempt + 1
            end

            if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
                SetEntityAsMissionEntity(entity, true, true)
                DeleteVehicle(entity)
            end
        end
    else
        local vehicle, attempt = GetVehicleInDirection(), 0

        if IsPedInAnyVehicle(player, true) then
            vehicle = GetVehiclePedIsIn(player, false)
        end

        while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
            Wait(100)
            NetworkRequestControlOfEntity(vehicle)
            attempt = attempt + 1
        end

        if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
        end
    end
end

--- teleport player to waypoint
function CoreAction.Admin.TeleportToWayPoint()
    local ped = PlayerPedId()
    local GetGroundZAndNormalFor_3dCoord = GetGroundZAndNormalFor_3dCoord
    local waypoint = IsWaypointActive()
    local coords = GetWaypointCoords()
    local x, y, groundZ, startingpoint = coords.x, coords.y, 650.0, 750.0
    local found = false

    if not waypoint then
        return VorpNotification:NotifyRightTip(T.wayPoint, 3000)
    end

    DoScreenFadeOut(500)
    Wait(1000)
    FreezeEntityPosition(ped, true)
    for i = startingpoint, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = startingpoint + i
        end
        SetEntityCoords(ped, x, y, z - 1000, false, false, false, false)
        Wait(1000)
        found, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, z)
        if found then
            RequestCollisionAtCoord(x, y, groundZ)
            Wait(200)
            SetEntityCoords(ped, x, y, groundZ, false, false, false, false)
            repeat Wait(0) until HasCollisionLoadedAroundEntity(ped)
            FreezeEntityPosition(ped, false)
            Wait(1000)
            DoScreenFadeIn(650)
            break
        end
    end
end

function CoreAction.Utils.LoadModel(hash)
    if not IsModelValid(hash) then return false end

    if not HasModelLoaded(hash) then
        RequestModel(hash, false)
        repeat Wait(0) until HasModelLoaded(hash)
    end

    return true
end

function CoreAction.Utils.LoadTexture(hash)
    if not HasStreamedTextureDictLoaded(hash) then
        RequestStreamedTextureDict(hash, true)
        repeat Wait(0) until HasStreamedTextureDictLoaded(hash)
    end
    return true
end

function CoreAction.Utils.bigInt(text)
    local string1 = DataView.ArrayBuffer(16)
    string1:SetInt64(0, text)
    return string1:GetInt64(0)
end
