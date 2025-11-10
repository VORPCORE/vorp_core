local T <const> = Translation[Lang].MessageOfSystem

local function checkUser(target)
    return CoreFunctions.getUser(tonumber(target))
end

local function checkArgs(args, requiered)
    return #args == requiered
end

local function checkAce(ace, source)
    if not ace then
        return true
    end
    local all = 'vorpcore.showAllCommands'
    local aceAllowed = IsPlayerAceAllowed(source, all)

    if aceAllowed then
        return true
    end

    aceAllowed = IsPlayerAceAllowed(source, ace)

    if aceAllowed then
        return true
    end

    return false
end

local function logMessage(_source)
    local Identifier = GetPlayerIdentifier(_source, 1) -- steam id
    local getDiscord = GetPlayerIdentifierByType(_source, 'discord')
    local discordId = getDiscord and string.sub(getDiscord, 9) or "No discord found"
    local ip = GetPlayerEndpoint(_source)    -- ip
    local steamName = GetPlayerName(_source) -- steam name
    local message = Translation[Lang].Commands.webHookMessage
    message = string.format(message, steamName, Identifier, discordId, ip)

    return message
end

local function checkGroupAllowed(Table, Group)
    if not next(Table) then
        return true
    end

    for _, value in pairs(Table) do
        if value == Group then
            return true
        end
    end
    return false
end

local function checkJobAllowed(Table, Job)
    if not Table or not next(Table) then
        return true
    end

    for _, value in pairs(Table) do
        if value == Job then
            return true
        end
    end

    return false
end

local function registerCommands(value, key)
    RegisterCommand(value.commandName, function(source, args, rawCommand)
        local _source = source

        if _source == 0 then
            return print("you must be in game to use this command")
        end

        local group = CoreFunctions.getUser(_source).getGroup -- admin group

        if not checkAce(value.aceAllowed, _source) and not checkGroupAllowed(value.groupAllowed, group) then
            return CoreFunctions.NotifyObjective(_source, T.NoPermissions, 4000)
        end

        if value.userCheck then
            if not checkUser(args[1]) then
                return CoreFunctions.NotifyObjective(_source, Translation[Lang].Notify.userNonExistent, 4000)
            end
        end

        if value.jobAllow and not checkJobAllowed(value.jobAllow, _source) then
            return CoreFunctions.NotifyObjective(_source, T.NoPermissions, 4000)
        end

        if not checkArgs(args, (key == "addJob" and #args == 5) and #value.suggestion + 1 or #value.suggestion) then
            return CoreFunctions.NotifyObjective(_source, Translation[Lang].Notify.ReadSuggestion, 4000)
        end

        local arguments = { source = _source, args = args, rawCommand = rawCommand, config = value }
        value.callFunction(arguments)
    end, false)
end

-- cor main commands
CreateThread(function()
    for key, value in pairs(Commands) do
        registerCommands(value, key)
    end
end)

--====================================== FUNCTIONS =========================================================--

local function sendDiscordLogs(link, data, arg1, arg2, arg3)
    if link then
        local message = logMessage(data.source)
        local custom = data.config.custom
        local finaltext = message .. string.format(custom, arg1, arg2, arg3)
        local title = data.config.title
        CoreFunctions.AddWebhook(title, link, finaltext)
    end
end

--ADDGROUPS
function SetGroup(data)
    local target = tonumber(data.args[1])
    local newgroup = tostring(data.args[2])

    local user = CoreFunctions.getUser(target)
    if not user then return end

    user.setGroup(newgroup)
    sendDiscordLogs(data.config.webhook, data, data.source, newgroup, "")
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.SetGroup, target), 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.SetGroup1, newgroup), 4000)
end

function SetGroupCharacter(data)
    local target = tonumber(data.args[1])
    local newgroup = tostring(data.args[2])
    local Character = CoreFunctions.getUser(target).getUsedCharacter

    Character.setGroup(newgroup)
    sendDiscordLogs(data.config.webhook, data, data.source, newgroup, "")
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.SetGroup, target), 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.SetGroup1, newgroup), 4000)
end

--ADDJOBS
function AddJob(data)
    local target = tonumber(data.args[1])
    local newjob = tostring(data.args[2])
    local jobgrade = tonumber(data.args[3])
    local joblabel = tostring(data.args[4]) .. " " .. (data.args[5] and tostring(data.args[5]) or "")
    local Character = CoreFunctions.getUser(target).getUsedCharacter

    Character.setJob(newjob)
    Character.setJobGrade(jobgrade)
    Character.setJobLabel(joblabel)
    sendDiscordLogs(data.config.webhook, data, data.source, newjob, jobgrade)
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.AddJob, newjob, target, jobgrade), 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.AddJob1, newjob, jobgrade), 4000)
end

--ADDMONEY
function AddMoney(data)
    if type(tonumber(data.args[2])) ~= "number" then
        return CoreFunctions.NotifyObjective(data.source, Translation[Lang].Notify.error, 4000)
    end

    local target = tonumber(data.args[1])
    local montype = tonumber(data.args[2])
    local quantity = tonumber(data.args[3])
    local Character = CoreFunctions.getUser(target).getUsedCharacter

    Character.addCurrency(montype, quantity)

    sendDiscordLogs(data.config.webhook, data, data.source, montype, quantity)
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.AddMoney, quantity, target), 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.AddMoney1, quantity), 4000)
end

--ADDITEMS
function AddItems(data)
    local target = tonumber(data.args[1])
    local item = tostring(data.args[2])
    local count = tonumber(data.args[3])

    local VORPInv = exports.vorp_inventory
    local itemCheck = VORPInv:getItemDB(item)
    local canCarry = VORPInv:canCarryItems(target, count)       --can carry inv space
    local canCarry2 = VORPInv:canCarryItem(target, item, count) --cancarry item limit

    if not itemCheck then
        return print(item .. " < item dont exist in the database", 4000)
    end

    if not canCarry then
        return CoreFunctions.NotifyObjective(data.source, Translation[Lang].Notify.invfull, 4000)
    end

    if not canCarry2 then
        return CoreFunctions.NotifyObjective(data.source, Translation[Lang].Notify.cantcarry, 4000)
    end

    VORPInv:addItem(target, item, count)
    sendDiscordLogs(data.config.webhook, data, data.source, item, count)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.AddItems, item, count), 4000)
end

--ADDWEAPONS
function AddWeapons(data)
    local target = tonumber(data.args[1])
    local weaponHash = tostring(data.args[2])
    local canCarry = exports.vorp_inventory:canCarryWeapons(target, 1, nil, weaponHash)
    if not canCarry then
        return CoreFunctions.NotifyObjective(data.source, T.cantCarry, 4000)
    end

    local result = exports.vorp_inventory:createWeapon(target, weaponHash, {})
    if not result then
        return CoreFunctions.NotifyRightTip(target, T.Wepnotexist, 4000)
    end
    sendDiscordLogs(data.config.webhook, data, data.source, weaponHash, "")
    CoreFunctions.NotifyRightTip(target, Translation[Lang].Notify.AddWeapons, 4000)
end

--DELCURRENCY
function RemmoveCurrency(data)
    if type(tonumber(data.args[2])) ~= "number" then
        return CoreFunctions.NotifyObjective(data.source, Translation[Lang].Notify.error, 4000)
    end

    local target = tonumber(data.args[1])
    local montype = tonumber(data.args[2])
    local quantity = tonumber(data.args[3])
    local Character = CoreFunctions.getUser(target).getUsedCharacter

    Character.removeCurrency(montype, quantity)
    sendDiscordLogs(data.config.webhook, data, data.source, montype, quantity)
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.removedcurrency, quantity, target), 4000)
end

--REVIVEPLAYERS
function RevivePlayer(data)
    local target = tonumber(data.args[1])
    CoreFunctions.Player.Revive(target)
    sendDiscordLogs(data.config.webhook, data, target, "", "")
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.revived, target), 4000)
end

--TELPORTPLAYER
function TeleporPlayer(data)
    TriggerClientEvent('vorp:teleportWayPoint', data.source)
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
end

--DELETEHORSES
function DeleteHorse(data)
    TriggerClientEvent("vorp:delHorse", data.source)
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
end

--DELETEWAGONS
function DeleteWagons(data)
    local radius = tonumber(data.args[1])

    if radius < 1 then
        return CoreFunctions.NotifyRightTip(data.source, Translation[Lang].Notify.radius, 4000)
    end
    TriggerClientEvent("vorp:deleteVehicle", data.source, radius)
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
end

--HEALPLAYERS
function HealPlayers(data)
    local target = tonumber(data.args[1])
    CoreFunctions.Player.Heal(target)
    sendDiscordLogs(data.config.webhook, data, target, "", "")
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.healedPlayer, target), 4000)
end

--BANPLAYERS
function BanPlayers(data)
    local targetsteam = tonumber(data.args[1])
    local steamid = GetPlayerIdentifierByType(data.source, 'steam')
    if steamid and steamid == targetsteam then
        return CoreFunctions.NotifyRightTip(data.source, T.CantBanSelf, 4000)
    end

    local banTime = tonumber(data.args[2]:match("%d+"))
    if not banTime then return end

    local unit = tostring(data.args[2]:match("%a+"))
    if unit == "d" then
        banTime = banTime * 24
    elseif unit == "w" then
        banTime = banTime * 168
    elseif unit == "m" then
        banTime = banTime * 720
    elseif unit == "y" then
        banTime = banTime * 8760
    end

    local datetime = os.time() + banTime * 3600
    TriggerEvent("vorpbans:addtodb", true, targetsteam, banTime)

    local text = banTime == 0 and Translation[Lang].Notify.banned or (Translation[Lang].Notify.banned2 .. os.date(Config.DateTimeFormat, datetime + Config.TimeZoneDifference * 3600) .. Config.TimeZone)
    sendDiscordLogs(data.config.webhook, data, data.source, text, "")
end

--UNBANPLAYERS
function UnBanPlayers(data)
    local targetsteam = tonumber(data.args[1])
    TriggerEvent("vorpbans:addtodb", false, targetsteam, 0)
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
end

--WHITELISTPLAYERS
function AddPlayerToWhitelist(data)
    local target = tostring(data.args[1])
    Whitelist.Functions.InsertWhitelistedUser({ identifier = target, status = true })
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
end

--UNWHITELISTPLAYERS
function RemovePlayerFromWhitelist(data)
    local target = tostring(data.args[1])
    local userid = Whitelist.Functions.GetUserId(target)
    Whitelist.Functions.WhitelistUser(userid, false)
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
end

--UNWARNPLAYERS
function UnWarnPlayer(data)
    local source = tonumber(data.source)
    local target = tonumber(data.args[1])
    TriggerEvent("vorpwarns:addtodb", false, target, source)
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
end

--WARN PLAYERS
function WarnPlayers(data)
    local source = tonumber(data.source)
    local target = tonumber(data.args[1])
    if data.source ~= target then -- dont warn yourself
        TriggerEvent("vorpwarns:addtodb", true, target, source)
        sendDiscordLogs(data.config.webhook, data, data.source, "", "")
    end
end

--ALLOW CHAR CREATION
function AddCharCanCreateMore(data)
    local target = data.args[1]
    local number = tonumber(data.args[2])
    local Character = CoreFunctions.getUser(target)
    if not Character then return end
    Character.setCharperm(number)
    sendDiscordLogs(data.config.webhook, data, data.source, "", "")
    CoreFunctions.NotifyRightTip(data.source, T.AddChar .. target, 4000)
end

--MODIFY CHARACTER NAME
function ModifyCharName(data)
    local target = tonumber(data.args[1])
    local firstname = tostring(data.args[2])
    local lastname = tostring(data.args[3])

    local Character = CoreFunctions.getUser(target).getUsedCharacter
    Character.setFirstname(firstname)
    Character.setLastname(lastname)
    sendDiscordLogs(data.config.webhook, data, data.source, firstname, lastname)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.namechange, firstname, lastname), 4000)
end

--MYJOB
function MyJob(data)
    local _source   = data.source
    local Character = CoreFunctions.getUser(_source).getUsedCharacter
    local job       = Character.job
    local grade     = Character.jobGrade
    local label     = Character.jobLabel
    CoreFunctions.NotifyRightTip(_source, T.myjob .. label .. " (" .. job .. ") " .. T.mygrade .. grade, 5000)
end

function SetExp(data)
    local target = tonumber(data.args[1])
    local skillName = tostring(data.args[2])
    local exp = tonumber(data.args[3])
    local Character = CoreFunctions.getUser(target).getUsedCharacter
    Character.setSkills(skillName, exp)
    sendDiscordLogs(data.config.webhook, data, data.source, skillName, exp)
    CoreFunctions.NotifyRightTip(data.source, Translation[Lang].Notify.Exp, 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.GivenExp, exp, skillName), 4000)
end

--my exp
function MyExp(data)
    local _source = data.source
    local User = CoreFunctions.getUser(_source).getUsedCharacter
    local skills = User.skills
    if not skills[data.args[1]] then
        return CoreFunctions.NotifyRightTip(_source, Translation[Lang].Notify.NotFound, 4000)
    end
    local exp = skills[data.args[1]].Exp
    local lvl = skills[data.args[1]].Level
    local label = skills[data.args[1]].Label
    local text = Translation[Lang].Notify.Level
    CoreFunctions.NotifyRightTip(_source, text:format(label, lvl, exp, data.args[1]), 4000)
end

-- command to set multi job max allowed
function SetMultiJobMaxAllowed(data)
    local _source <const> = data.source
    local target <const> = tonumber(data.args[1])
    local maxJobs <const> = tonumber(data.args[2])
    local user <const> = CoreFunctions.getUser(target)
    if not user then return end

    user.setMaxJobsAllowed(maxJobs)

    sendDiscordLogs(data.config.webhook, data, _source, maxJobs, "")
    CoreFunctions.NotifyRightTip(_source, string.format(Translation[Lang].Notify.MultiJob.MaxMJob, maxJobs), 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.MultiJob.MaxMJobSet, maxJobs), 4000)
end

-- new funtion to add multijobs to users
function AddMultiJob(data)
    local _source <const> = data.source
    local target <const> = tonumber(data.args[1])
    local job <const> = data.args[2]
    local grade <const> = tonumber(data.args[3])
    local label <const> = data.args[4]
    local user <const> = CoreFunctions.getUser(target)
    if not user then return end

    local maxJobs <const> = user.maxJobsAllowed
    local character <const> = user.getUsedCharacter
    local count <const> = character.getMultiJobsCount()
    if count >= maxJobs then return CoreFunctions.NotifyRightTip(_source, Translation[Lang].Notify.MultiJob.ReachedMaxMJob, 4000) end

    character.setMultiJob(job, grade, label)
    sendDiscordLogs(data.config.webhook, data, _source, job, grade)
    CoreFunctions.NotifyRightTip(_source, string.format(Translation[Lang].Notify.MultiJob.YouAddedMJob, job, target), 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.MultiJob.YouGiveMJob, job), 4000)
end

-- remove multijob from user
function RemoveMultiJob(data)
    local _source <const> = data.source
    local target <const> = tonumber(data.args[1])
    local job <const> = data.args[2]
    local user <const> = CoreFunctions.getUser(target)
    if not user then return end

    local character <const> = user.getUsedCharacter
    local result <const> = character.removeMultiJob(job)
    if not result then return CoreFunctions.NotifyRightTip(_source, Translation[Lang].Notify.MultiJob.InvalidMJob, 4000) end

    sendDiscordLogs(data.config.webhook, data, data.source, job, "")
    CoreFunctions.NotifyRightTip(data.source, string.format(Translation[Lang].Notify.MultiJob.YouRemovedMJob, job, target), 4000)
    CoreFunctions.NotifyRightTip(target, string.format(Translation[Lang].Notify.MultiJob.YouLostMJob, job), 4000)
end

local usersJobCoolDown <const> = {}
-- allows users t oswitch over jobs
function SwitchMultiJob(data)
    local _source <const> = data.source
    local job <const> = data.args[2]
    local Character = CoreFunctions.getUser(_source)?.getUsedCharacter
    if not Character then return end

    local value <const> = Character.multiJobs
    if not value or not next(value) then
        return CoreFunctions.NotifyRightTip(_source, Translation[Lang].Notify.MultiJob.DontHaveMJob, 4000)
    end

    if not value[job] then
        return CoreFunctions.NotifyRightTip(_source, Translation[Lang].Notify.MultiJob.DontHaveThisMJob, 4000)
    end

    if usersJobCoolDown[_source] and usersJobCoolDown[_source] > os.time() then
        local timeDiff <const> = usersJobCoolDown[_source] - os.time()
        local minutes <const> = math.floor(timeDiff / 60)
        local seconds <const> = timeDiff % 60
        return CoreFunctions.NotifyRightTip(_source, Translation[Lang].Notify.MultiJob.CoolDownMJob .. minutes .. " minutes and " .. seconds .. " seconds", 4000)
    end
    usersJobCoolDown[_source] = os.time() + Config.SwitchJobCoolDown * 60

    -- this will fire the event player job update for scripts to listen to the changes
    Character.setJob(job)
    Character.setJobGrade(value[job].grade)
    Character.setJobLabel(value[job].label)
    CoreFunctions.NotifyRightTip(_source, Translation[Lang].Notify.MultiJob.YouSwitchedMjob .. value[job].label .. " Job", 4000)
    sendDiscordLogs(data.config.webhook, data, _source, value[job].label, value[job].grade)
end

AddEventHandler("playerDropped", function(source)
    local _source = source
    if usersJobCoolDown[_source] then
        usersJobCoolDown[_source] = nil
    end
end)

--============================================ CHAT ADD SUGGESTION ========================================================--

function AddCommandSuggestions(_source, group, value)
    if checkAce(value.aceAllowed, _source) or checkGroupAllowed(value.groupAllowed, group) then
        return TriggerClientEvent("chat:addSuggestion", _source, "/" .. value.commandName, value.label, value.suggestion)
    end

    if value.jobAllow and checkJobAllowed(value.jobAllow, _source) then
        return TriggerClientEvent("chat:addSuggestion", _source, "/" .. value.commandName, value.label, value.suggestion)
    end

    TriggerClientEvent("chat:removeSuggestion", _source, "/" .. value.commandName)
end

RegisterServerEvent("vorp:chatSuggestion", function()
    local _source = source
    local user    = checkUser(_source)
    if not user then return end

    local group = user.getGroup
    for _, value in pairs(Commands) do
        AddCommandSuggestions(_source, group, value)
    end

    -- Client Commands
    TriggerClientEvent("chat:addSuggestion", _source, "/" .. Commands.myJob.commandName, Commands.myJob.label, {})
end)
--============================================================================================================================--
