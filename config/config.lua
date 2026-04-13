--=============================================
--            VORP SHARED CONFIG             --
--=============================================

Lang = "English"
Config = Config or {}

Config = {
    autoUpdateDB          = true, -- Enables automatic database updates.

    ReportCrashes         = true, -- Reports crashes to https://monitor.gtp-dev.com login in here to create your API KEY , by doing this you will help the community to improve the server stability and fix crashes faster

    API_KEY               = "",   -- API key for crash reporting. Get your API key at https://monitor.gtp-dev.com to allow more requests make a donation in the website

    -- (IF YOU HAVE WHITELIST ENABLED DONT ENABLE THIS)--
    DeleteFromUsersTable  = true, -- this will delete from users table if character does not exist "optimising the queries"
    -----------------------------------------------------

    CanRespawn            = function() -- use this function to add your own logic if player can respawn or not
        -- add your logic here
        return true                    -- dont touch
    end,
    --=============================================
    --        STARTING CONFIGURATION             --
    --=============================================

    initGold              = 0.0,          -- Initial gold amount for new players.

    initMoney             = 200.0,        -- Initial money amount for new players.

    initRol               = 0.0,          -- Initial role-play currency amount for new players.

    initInvCapacity       = 35.0,         -- Initial number of character inventory weight for new players. for old characters you must change in the database if you dont ave a new server

    initXp                = 0,            -- Initial experience points for new players.

    initJob               = "unemployed", -- Default job for new players. Recommended not to change.

    initJobGrade          = 0,            -- Default job grade for new players. Recommended not to change.

    initGroup             = "user",       -- Default user group for new players. Recommended not to change.

    initJobLabel          = "Unemployed", -- Default job label for new players. Recommended not to change.

    Whitelist             = false,        -- Enable if not using TxAdmin's whitelist system.

    SavePlayersStatus     = false,        -- Future deprecated. Advised not to use, as it will be removed.

    maxHealth             = 10,           -- Maximum health for players. 10 is full, 0 is empty.

    maxStamina            = 10,           -- Maximum stamina for players. 10 is full, 0 is empty.

    PVP                   = true,         -- Enables player vs player combat.

    PVPToggle             = false,        -- Allows players to toggle their PVP status.

    CommandOnOffPVP       = 'pvp',        -- Command to toggle PVP status, requires PVPToggle to be true.

    savePlayersTimer      = 10,           -- Interval in minutes for automatically saving all players to the database.

    showplayerIDwhenfocus = true,         -- Shows player Steam name when focusing on them with RMB if set to false.

    disableAutoAIM        = true,         -- Disables auto-aim for controller players if set to false.

    DisableCinematicMode  = false,        -- Set false to disable cineamtic mode/camera (While holding "V" key) (You should be aware that disabling cinematic mode may break functionality in scripts that use it.)
    --=============================================
    --          MULTICHARACTER SUPPORT           --
    --=============================================

    SaveDiscordId         = true, -- Saves Discord ID in the character/user database upon joining/leaving.

    MaxCharacters         = 5,    -- Maximum number of characters a player can create. when first join, for old users go to users table and change the number of characters there

    MaxCharacterJobs      = 5,    -- Maximum number of jobs a player can have. for multijob system, this is for new players, for old change in database column max_jobs

    SwitchJobCoolDown     = 10,   -- Cool down time in minutes for switching jobs.

    --=============================================
    --             UI CORE SETTINGS              --
    --=============================================

    HideOnlyDEADEYE       = true,  -- Hides only the Dead Eye core in the UI.

    HidePlayersCore       = false, -- Hides player cores in the UI.

    HideHorseCores        = false, -- Hides horse cores in the UI.

    --=============================================
    --          WEBHOOK CONFIGURATIONS           --
    --     Refer to commands.config for usage.   --
    --=============================================

    webhookColor          = 16711680,                            -- Color for embeds in Discord webhooks.

    name                  = "VORP",                              -- Name displayed in webhook embeds.

    logo                  = "https://via.placeholder.com/30x30", -- Logo URL for webhook embeds.

    footerLogo            = "https://via.placeholder.com/30x30", -- Footer logo URL for webhook embeds.

    Avatar                = "https://via.placeholder.com/30x30", -- Avatar URL for webhook embeds.


    --=============================================
    --            UI CONFIGURATIONS              --
    --=============================================


    HideUi                   = false,      -- Shows or hides the overall UI.

    HideGold                 = false,      -- Disables the Gold UI for all players.

    HideMoney                = false,      -- Disables the Money UI for all players.

    HideLevel                = false,      -- Disables the Level UI for all players.

    HideID                   = false,      -- Disables the ID UI for all players.

    HideTokens               = false,      -- Disables the Token UI for all players.

    HidePVP                  = false,      -- Disables the PVP UI for all players.

    UIPosition               = 'TopRight', -- Sets the UI position on the screen. Options are 'TopRight', 'TopLeft', 'BottomRight', 'BottomLeft', 'MiddleRight', 'TopMiddle', 'BottomMiddle'.

    UILayout                 = 'Column',   -- Sets the UI layout, options are 'Row' or 'Column'.

    HideWithRader            = true,       -- UI hides when the radar (minimap) is hidden.

    OpenAfterRader           = true,       -- UI shows when the radar (minimap) reappears.

    CloseOnDelay             = false,      -- UI automatically closes after a set time.

    CloseOnDelayMS           = 10000,      -- Time in milliseconds before the UI auto-closes, 10000 equals 10 seconds.

    CommandHideIU            = 'hideUi',   -- Command to hide all UI elements, useful for screenshots.

    CommandToogleUI          = 'toggleUi', -- Command to toggle the visibility of VORP UI elements.

    CommandClearAnim         = 'stopAnim', -- Command to stop animations if a player is stuck.

    StopAnimCooldown         = 5,          -- Cooldown time to reuse the command to stop animations. (Second)

    --=============================================
    --            MAP CONFIGURATIONS             --
    --=============================================

    mapTypeOnFoot            = 3,     -- Radar type when on foot. 0 = Off, 1 = Regular, 2 = Expanded, 3 = Simple (compass).

    mapTypeOnMount           = 3,     -- Radar type when on horse. Same options as on foot.

    enableTypeRadar          = false, -- Enables custom radar types if true, otherwise players use game settings.

    --=============================================
    --            LOADING SCREEN CONFIGURATIONS    --
    --=============================================

    UseInnitialLoadingScreen = true,  -- Enables the use of the initial game loading screen usually if you have a custom loading screen you could add this to false
    -- USING THIS LOADING SCREEN WILL AFFECT HOW FAST THE PLAYER SPAWNS
    Loadinscreen             = false, -- Enables loading screens during spawn this is the second loading screen after player choose a character

    LoadinScreenTimer        = 10000, -- Duration of loading screens in milliseconds.

    LoadingScreenPlayerInfo  = false, -- Enables showing player information on the loading screen (Player name, surname and job)

    --=============================================
    --            RESPAWN SETTINGS               --
    --=============================================

    HealthOnRespawn          = 500,                                  -- Player health after respawning at a hospital (max is 500).

    HealthOnResurrection     = 100,                                  -- Player health after being resurrected (max is 500).

    RagdollOnResurrection    = true,                                 -- Enables ragdoll and revive effects upon resurrection.

    HealthRecharge           = { enable = true, multiplier = 0.37 }, -- Auto-recharge for health, with a multiplier for speed.

    StaminaRecharge          = { enable = true, multiplier = 0.4 },  -- Auto-recharge for stamina, with a multiplier for speed.

    RespawnTime              = 10,                                   -- Time in seconds before a player can respawn.

    RespawnKey               = 0xDFF812F9,                           -- Key code for respawning (default is 'E').

    RespawnKeyTime           = 5000,                                 -- Time in milliseconds to hold the respawn key.

    CombatLogDeath           = true,                                 -- Combat loggers respawn in a dead state instead of alive.

    UseControlsCamera        = false,                                -- Allows dead or carried players to move the camera with WASD (resource intensive).

    UseDeathHandler          = true,                                 -- Keeps default death handling unless you have a custom system.

    Hospitals                = {                                     -- Spawn points for players respawning at hospitals.
        Valentine = {
            name = "Valentine",
            pos = vector4(-283.83, 806.4, 119.38, 321.76), -- Vector4 coordinates: x, y, z, heading.
        },
        SaintDenis = {
            name = "Saint Denis",
            pos = vector4(2721.4562, -1446.0975, 46.2303, 321.76),
        },
        Armadillo = {
            name = "Armadillo",
            pos = vector4(-3742.5, -2600.9, -13.23, 321.76),
        },
        Blackwater = {
            name = "Black water",
            pos = vector4(-723.9527, -1242.8358, 44.7341, 321.76),
        },
        Rhodes = {
            name = "Rhodes",
            pos = vector4(1229.0, -1306.1, 76.9, 321.76),
        },
    },
    ActiveEagleEye           = true,  -- Enables or disables Eagle Eye feature.

    ActiveDeadEye            = false, -- Enables or disables Dead Eye feature.

    --=============================================
    --         BAN SYSTEM CONFIGURATIONS         --
    --=============================================

    DateTimeFormat           = "%d/%m/%y %H:%M:%S", -- Format for displaying date and time in ban notifications.

    TimeZone                 = " CET",              -- Set your server's timezone.

    TimeZoneDifference       = 1,                   -- Time difference from UTC, used in the banning system.

    --===========================================
    --    DISCORD RICH PRESENCE INTEGRATION    --
    --===========================================
    appid                    = nil,                        -- Discord Application ID. Replace this with your own application's ID.

    biglogo                  = "LOGOname",                 -- Name of the image asset to use for the large icon in the rich presence.

    biglogodesc              = " Redm Server Connect: ",   -- Description displayed when hovering over the large icon.

    smalllogo                = "smallboy name",            -- Name of the image asset for the small icon in the rich presence. This is optional.

    smalllogodesc            = "Join us for a good time ", -- Description displayed when hovering over the small icon.

    richpresencebutton       = "Join Discord",             -- Text displayed on the rich presence button.

    shownameandid            = true,                       -- Whether to display the player's Steam name and ID.

    Buttons                  = {                           -- Configuration for buttons shown in the Discord rich presence.
        {
            text = 'Join Discord!',                        -- Text displayed on the first button.
            -- URL the first button directs to. Replace with your Discord invite link.
            url = 'https://discord.gg/vorpcore'

        },
        {
            text = 'Website', -- Text displayed on the second button.
            -- URL the second button directs to. Fill in with your website URL.
            url = ''          -- Example for Rich Presence Button
        }
    },

    --=============================================
    --           AMBIENT POPULATION              --
    --=============================================
    -- allows you to control population density of the world
    Multipliers              = {
        AnimalDensity         = {
            enable = false, -- enable disable them
            value = 0.0     -- default values can be adjusted in here 0.001 -> 1.0
        },
        HumanDensity          = {
            enable = false,
            value = 0.0
        },
        PedDensity            = {
            enable = false,
            value = 0.0
        },
        VehicleDensity        = {
            enable = false,
            value = 0.0
        },
        ScenarioAnimalDensity = {
            enable = false,
            value = 0.0
        },
        ScenarioHumanDensity  = {
            enable = false,
            value = 0.0
        },
        ScenarioPedDensity    = {
            enable = false,
            value = 0.0
        },
        ParkedVehicleDensity  = {
            enable = false,
            value = 0.0
        },
        RandomVehicleDensity  = {
            enable = false,
            value = 0.0
        },

    },

}
