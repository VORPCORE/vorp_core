local T = Translation[Lang].MessageOfSystem
WhiteListedUsers = {}

local function CheckWhitelistStatusOnConnect(identifier)
    local result = MySQL.single.await('SELECT status FROM whitelist WHERE identifier = ?', { identifier })
    if result and result.status ~= nil then
        return result.status and true or false
    end
    return false
end

function GetDiscordID(src)
    local discordId = GetPlayerIdentifierByType(src, 'discord')
    local discordIdentifier = discordId and discordId:sub(9) or ""
    return discordIdentifier
end

local function checkBannedUser(setKickReason, deferrals, identifier)
    local resultList = MySQL.single.await('SELECT banned, banneduntil FROM users WHERE identifier = ?', { identifier })

    if resultList then
        local user = resultList
        if user.banned == true then
            local bannedUntilTime = user.banneduntil
            local currentTime = tonumber(os.time(os.date("!*t")))

            if bannedUntilTime == 0 then
                deferrals.done(T.permanentlyBan)
                setKickReason(T.permanentlyBan)
            elseif bannedUntilTime > currentTime then
                local bannedUntil = os.date(Config.DateTimeFormat, bannedUntilTime + Config.TimeZoneDifference * 3600)
                deferrals.done(T.BannedUser .. bannedUntil .. Config.TimeZone)
                setKickReason(T.BannedUser .. bannedUntil .. Config.TimeZone)
            else
                TriggerEvent("vorpbans:addtodb", false, identifier, 0)
            end
        end
    end
    deferrals.done()
end

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local _source = source
    deferrals.defer()
    Wait(0)

    local steamIdentifier = GetPlayerIdentifierByType(_source, 'steam')

    if not steamIdentifier then
        deferrals.done(T.NoSteam)
        setKickReason(T.NoSteam)
        return CancelEvent()
    end

    if Config.Whitelist then
        local discordIdentifier = GetDiscordID(_source)
        local isPlayerWhiteListed = CheckWhitelistStatusOnConnect(steamIdentifier)

        if not isPlayerWhiteListed then
            Whitelist.Functions.InsertWhitelistedUser({ identifier = steamIdentifier, discordid = discordIdentifier, status = false })
            deferrals.done(T.NoInWhitelist .. " steam id: " .. steamIdentifier)
            setKickReason(T.NoInWhitelist .. " steam id: " .. steamIdentifier)
            return CancelEvent()
        else
            Whitelist.Functions.InsertWhitelistedUser({ identifier = steamIdentifier, discordid = discordIdentifier, status = true })
        end
    end

    deferrals.update(T.LoadingUser)
    checkBannedUser(setKickReason, deferrals, steamIdentifier)

    if Logs.EnableWebhookJoinleave then
        local finaltext = string.format(T.PlayerJoinLeave.Join, playerName, steamIdentifier)
        TriggerEvent("vorp_core:addWebhook", T.JoinTitle, Logs.JoinWebhookURL, finaltext)
    end

    --TODO  this can de added as default in class characters
    if Config.SaveDiscordId then
        MySQL.update('UPDATE characters SET `discordid` = ? WHERE `identifier` = ? ', { GetDiscordID(_source), steamIdentifier })
    end


    local key = GetConvar('steam_webApiKey', '')
    if key == '' or key == 'none' then return print("if you want steam names added to server.cfg set steam_webApiKey") end

    local steamId = string.format('%d', tonumber(steamIdentifier:sub(7), 16))
    local url = ('https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s'):format(key, steamId)
    local finished = false

    local function finish()
        if finished then return end
        finished = true
        deferrals.done()
    end

    SetTimeout(10000, finish)

    PerformHttpRequest(url, function(status, body)
        if finished then return end

        if status == 200 then
            local ok, name = pcall(function()
                return json.decode(body).response.players[1].personaname
            end)

            if ok and type(name) == 'string' then
                SetPlayerName(_source, name)
            end
        end

        finish()
    end, 'GET')
end)

AddEventHandler('playerJoining', function()
    local _source = source

    if not Config.Whitelist then return end

    local identifier = GetPlayerIdentifierByType(_source, 'steam')
    local discordId = GetDiscordID(_source)
    local userid = Whitelist.Functions.GetUserId(identifier)

    if userid and WhiteListedUsers[userid] then
        if not Whitelist.Functions.GetFirstConnection(userid) then
            local steamName = GetPlayerName(_source) or ""
            local message = string.format(Translation[Lang].addWebhook.whitelistid, steamName, identifier, discordId, userid)
            local webhook = "" -- add your webhook here if you use white list
            TriggerEvent("vorp_core:addWebhook", Translation[Lang].addWebhook.whitelistid1, webhook, message)
            Whitelist.Functions.SetFirstConnection(userid, false)
        end
    end
end)
