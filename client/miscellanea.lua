local T = Translation[Lang].MessageOfSystem


local function HidePlayerCores()
    local playerCores = {
        playerhealth = 0,
        playerhealthcore = 1,
        playerdeadeye = 3,
        playerdeadeyecore = 2,
        playerstamina = 4,
        playerstaminacore = 5,
    }

    local horsecores = {
        horsehealth = 6,
        horsehealthcore = 7,
        horsedeadeye = 9,
        horsedeadeyecore = 8,
        horsestamina = 10,
        horsestaminacore = 11,
    }

    if Config.HideOnlyDEADEYE then
        Citizen.InvokeNative(0xC116E6DF68DCE667, 2, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 3, 2)
    end
    if Config.HidePlayersCore then
        for key, value in pairs(playerCores) do
            Citizen.InvokeNative(0xC116E6DF68DCE667, value, 2)
        end
    end
    if Config.HideHorseCores then
        for key, value in pairs(horsecores) do
            Citizen.InvokeNative(0xC116E6DF68DCE667, value, 2)
        end
    end
end

local function FillUpCores()
    local a2 = DataView.ArrayBuffer(12 * 8)
    local a3 = DataView.ArrayBuffer(12 * 8)
    Citizen.InvokeNative(0xCB5D11F9508A928D, 1, a2:Buffer(), a3:Buffer(), GetHashKey("UPGRADE_HEALTH_TANK_1"), 1084182731, Config.maxHealth, 752097756)
    local a2 = DataView.ArrayBuffer(12 * 8)
    local a3 = DataView.ArrayBuffer(12 * 8)
    Citizen.InvokeNative(0xCB5D11F9508A928D, 1, a2:Buffer(), a3:Buffer(), GetHashKey("UPGRADE_STAMINA_TANK_1"), 1084182731, Config.maxStamina, 752097756)
end

-- remove event notifications
local events = {
    [`EVENT_CHALLENGE_GOAL_COMPLETE`] = true,
    [`EVENT_CHALLENGE_REWARD`] = true,
    [`EVENT_DAILY_CHALLENGE_STREAK_COMPLETED`] = true,
}

--f6 photo mode doesnt work so just hide the prompt
local function disablePhotoMode()
    DatabindingAddDataBoolFromPath('', 'bPauseMenuPhotoModeVisible', false)
    DatabindingAddDataBoolFromPath('', 'bEnablePauseMenuPhotoMode', false)
end

CreateThread(function()
    disablePhotoMode()
    HidePlayerCores()
    while true do
        Wait(0)
        local event = GetNumberOfEvents(0)

        if event > 0 then
            for i = 0, event - 1 do
                local eventAtIndex = GetEventAtIndex(0, i)
                if events[eventAtIndex] then
                    Citizen.InvokeNative(0x6035E8FBCA32AC5E) -- _UI_FEED_CLEAR_ALL_CHANNELS
                end
            end
        end
    end
end)

-- run it separately because events need to be detected with precision
CreateThread(function()
    while true do
        Wait(0)
        if Config.disableAutoAIM then
            Citizen.InvokeNative(0xD66A941F401E7302, 3) -- SET_PLAYER_TARGETING_MODE
            Citizen.InvokeNative(0x19B4F71703902238, 3) -- _SET_PLAYER_IN_VEHICLE_TARGETING_MODE
        end

        if Config.DisableCinematicMode then -- Cinematic Camera / Mode
            DisableCinematicModeThisFrame()
        end
    end
end)

-- show players id when focus on other players
CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession
    FillUpCores()

    while true do
        local sleep = 1000
        if #GetActivePlayers() > 1 then -- we also count ourselfs
            sleep = 400
            for _, playersid in ipairs(GetActivePlayers()) do
                if playersid ~= PlayerId() then
                    local ped = GetPlayerPed(playersid)
                    local id = GetPlayerServerId(playersid)
                    local state = Player(id).state
                    if state and state.Character then
                        local name = Player(id).state.Character.FirstName .. " " .. Player(id).state.Character.LastName
                        local promptName = Config.showplayerIDwhenfocus and GetPlayerServerId(playersid) or name
                        SetPedPromptName(ped, T.PlayerWhenFocus .. promptName)
                    else
                        SetPedPromptName(ped, T.PlayerWhenFocus .. GetPlayerServerId(playersid))
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- logic taken from:
-- https://github.com/femga/rdr3_discoveries/commit/62a4540839361bbdcfea6cca582f86894e7fc6ea

local EXCLUDED_INTERIORS <const> = {
    [`agu_fus_cave_int`] = true,
    [`bea_01_int`] = true,
    [`elh_seacaves_int`] = true,
    [`j_16_tunnel_int`] = true,
    [`l_14_cave_int`] = true,
    [`m05_bearcave_main`] = true,
    [`mil_mine_cave_int`] = true,
    [0x26FB0E67] = true,
    [0x615D3CCA] = true,
}

local INCLUDED_TOWN_ZONES <const> = {
    [`aguasdulcesfarm`] = true,
    [`aguasdulcesruins`] = true,
    [`aguasdulcesvilla`] = true,
    [`annesburg`] = true,
    [`armadillo`] = true,
    [`beechershope`] = true,
    [`blackwater`] = true,
    [`braithwaite`] = true,
    [`butcher`] = true,
    [`caliga`] = true,
    [`cornwall`] = true,
    [`emerald`] = true,
    [`lagras`] = true,
    [`manicato`] = true,
    [`manzanita`] = true,
    [`rhodes`] = true,
    [`siska`] = true,
    [`stdenis`] = true,
    [`strawberry`] = true,
    [`tumbleweed`] = true,
    [`valentine`] = true,
    [`vanhorn`] = true,
    [`wallace`] = true,
    [`wapiti`] = true,
}

local eZONE_TYPE <const> = {
    STATE = 0,
    TOWN = 1,
    LAKE = 2,
    RIVER = 3,
    OIL_SPILL = 4,
    SWAMP = 5,
    OCEAN = 6,
    CREEK = 7,
    POND = 8,
    GLACIER = 9,
    DISTRICT = 10,
    TEXT_PRINTED = 11,
    TEXT_WRITTEN = 12
}

local lastState = nil

local function isIndoors(ped)
    local interior = GetInteriorFromEntity(ped)
    if not IsValidInterior(interior) then return false end
    local _, hash = GetInteriorLocationAndNamehash(interior)
    if EXCLUDED_INTERIORS[hash] then return false end
    return true
end

-- Note: This may be too big in certain cases
-- Game uses volumes for this, this is a simpler but less accurate approach
local function isInTown(ped)
    local pos = GetEntityCoords(ped)
    local zone = GetMapZoneAtCoords(pos.x, pos.y, pos.z, eZONE_TYPE.TOWN)
    return INCLUDED_TOWN_ZONES[zone]
end

local function isRiding(ped)
    return IsPedOnMount(ped) or IsPedInAnyVehicle(ped, false) or IsPedInAnyTrain(ped)
end

local function updateSpeedState(speed, riding, current)
    local margin = (current == nil) and 0.0 or (riding and 2.5 or 1.0)
    local threshold = riding and 7.0 or 3.0

    if speed < (threshold - margin) then return false end
    if speed >= (threshold + margin) then return true end
    return current
end

local function updateRadar()
    local ped = PlayerPedId()
    local isPlayerDead = IsPlayerDead(PlayerId())
    if isPlayerDead then return end

    local speed = GetEntitySpeed(ped)
    local riding = isRiding(ped)

    -- Speed is relative to the current state
    lastState = updateSpeedState(speed, riding, lastState)

    if isIndoors(ped) then
        SetRadarConfigType(`RADAR_CONFIG_INDOOR`, 0)
        return
    end

    -- Construct the radar config key dynamically
    local strRide = riding and "RIDE" or "FOOT"
    local strSpeed = lastState and "FAST" or "SLOW"
    local strLoc = isInTown(ped) and "TOWN" or "WILDERNESS"
    local config = string.format("RADAR_CONFIG_%s_%s_%s", strRide, strSpeed, strLoc)

    SetRadarConfigType(joaat(config), 0)
end

CreateThread(function()
    repeat Wait(5000) until LocalPlayer.state.IsInSession

    local lastPlayerPed = PlayerPedId()
    while true do
        updateRadar()

        -- for horse ducking feature like RDO
        if lastPlayerPed ~= PlayerPedId() then
            SetPedConfigFlag(lastPlayerPed, 560, true)
            lastPlayerPed = PlayerPedId()
        end

        Wait(1000)
    end
end)
