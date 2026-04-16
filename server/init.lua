local function init_core()
    local IsLinux = false

    print("###############################################################################\n" ..
        "\n^1----- ^3#RedM ^1----------------------------------------------------------------------^0\n" ..
        " /##    /##  /######  /#######  /#######   /######   /######  /#######  /########\n" ..
        "| ##   | ## /##__  ##| ##__  ##| ##__  ## /##__  ## /##__  ##| ##__  ##| ##_____/\n" ..
        "| ##   | ##| ##  | ##| ##  | ##| ##  | ##| ##  |__/| ##  | ##| ##  | ##| ##      \n" ..
        "|  ## / ##/| ##  | ##| #######/| #######/| ##      | ##  | ##| #######/| #####   \n" ..
        " |  ## ##/ | ##  | ##| ##__  ##| ##____/ | ##      | ##  | ##| ##__  ##| ##__/   \n" ..
        "  |  ###/  | ##  | ##| ##  | ##| ##      | ##    ##| ##  | ##| ##  | ##| ##      \n" ..
        "   |  #/   |  ######/| ##  | ##| ##      |  ######/|  ######/| ##  | ##| ########\n" ..
        "    |_/     |______/ |__/  |__/|__/       |______/  |______/ |__/  |__/|________/\n" ..
        "^1----------------------------------------------------^3VORPcore Framework ^2Lua^0 ^1-----^0\n")

    if IsLinux then
        print("\nVORP CORE Running on Linux, thanks for using VorpCore");
    end
end

local resourcename = GetCurrentResourceName()
if resourcename ~= 'vorp_core' then
    return print("^3WARNING ^0 This resource is not named correctly, please change it to ^1'vorp_core'^0.")
end

local steamwebapikey = GetConvar("steam_webApiKey", "") == ""
if steamwebapikey then
    return print("Steam Web API Key is not set, please set it in your server.cfg")
end

local oneSyncConvar = GetConvar('onesync', 'off')
if oneSyncConvar == 'off' then
    return print('^1WARNING: onesync is off, you must enable it in txAdmin settings | onesync infinity')
end


local ScriptList = {}
local Changelogs = 0

VorpInitialized = false
local function changelog()
    print('')
    for _, v in pairs(ScriptList) do
        local isNewVersion = v.Version ~= v.NewestVersion
        local hasChangelog = v.CL

        if isNewVersion and hasChangelog then
            local resourceUpper = v.Resource:upper()
            local clStringFmt = '^3%s - Changelog:\n^0%s\n^1###############################^0\n'
            print(string.format(clStringFmt, resourceUpper, v.Changelog))
        end
    end
    print('^0###############################################################################')
end


local function checker()
    print("^3VORPcore Version check ")
    print("^2Resources found\n")

    local outdated, upToDate = {}, {}

    for i, v in pairs(ScriptList) do
        if string.find(v.NewestVersion, v.Version) then
            table.insert(upToDate,
                {
                    message = '^4' .. v.Name .. ' (' .. v.Resource .. ') ^2✅ ' .. 'Up to date - Version ' .. v.Version .. '\n'
                })
        elseif v.Version > v.NewestVersion then
            table.insert(outdated, {
                message = '^4' .. v.Name .. ' (' .. v.Resource .. ') ⚠️ ' .. 'Mismatch (v' .. v.Version .. ') ^5- Official Version: ' .. v.NewestVersion .. ' ^0(' .. v.Github .. ')\n'
            })
        else
            table.insert(outdated, {
                message = '^4' .. v.Name .. ' (' .. v.Resource .. ') ^1❌ ' .. 'Outdated (v' .. v.Version .. ') ^5- Update found: Version ' .. v.NewestVersion .. ' ^0(' .. v.Github .. ')\n'
            })
        end

        if v.CL then
            Changelogs = Changelogs + 1
        end
    end
    -- print outdated first and up-to-date at the end
    for _, data in ipairs(outdated) do
        print(data.message)
    end

    if Changelogs > 0 then
        print('^1###############################')
        changelog()
    else
        print('^0\n###############################################################################')
    end

    for _, data in ipairs(upToDate) do
        print(data.message)
    end
end

local function updateChecker(resource)
    if resource and GetResourceState(resource) == 'started' then
        if GetResourceMetadata(resource, 'vorp_checker', 0) == 'yes' then
            local Name = GetResourceMetadata(resource, 'vorp_name', 0)
            local Github = GetResourceMetadata(resource, 'vorp_github', 0)
            local Version = GetResourceMetadata(resource, 'vorp_version', 0)
            local GithubL, NewestVersion
            if Github then
                Script = {}

                Script['Resource'] = resource
                if Version == nil then
                    Version = GetResourceMetadata(resource, 'version', 0)
                end
                if Name ~= nil then
                    Script['Name'] = Name
                else
                    resource = resource:upper()
                    Script['Name'] = '^6' .. resource
                end
                if string.find(Github, "github") then
                    if string.find(Github, "github.com") then
                        Script['Github'] = Github
                        Github = string.gsub(Github, "github", "raw.githubusercontent") .. '/master/version'
                    else
                        GithubL = string.gsub(Github, "raw.githubusercontent", "github"):gsub("/master", "")
                        Github = Github .. '/version'
                        Script['Github'] = GithubL
                    end
                else
                    Script['Github'] = Github .. '/version'
                end
                PerformHttpRequest(Github, function(Error, V, Header)
                    NewestVersion = V
                end)
                repeat
                    Wait(10)
                until NewestVersion ~= nil

                StripVersion = NewestVersion:match("<%d?%d.%d?%d.?%d?%d?>")
                if StripVersion == nil then
                    print(Name, "Version is setup incorrectly!")
                else
                    CleanedVersion = StripVersion:gsub("[<>]", "")
                    Version1 = CleanedVersion

                    if string.find(Version1, Version) then
                    else
                        if Version1 < Version then
                            _Changelog = "Your script version is newer than what was found in github"
                            NewestVersion = Version
                        else
                            local MinV = NewestVersion:gsub("<" .. Version1 .. ">", "")
                            local StripedExtra
                            local isMatch = MinV:match("<" .. Version .. ">")
                            if isMatch then
                                StripedExtra = MinV:gsub("<" .. Version .. ">.*", "")
                            else
                                StripedExtra = MinV:gsub("<%d?%d.%d?%d.?%d?%d?>.*", "")
                            end

                            local stripedVersions = StripedExtra:gsub("<%d?%d.%d?%d.?%d?%d?>", "")

                            local _Changelog = stripedVersions
                            _Changelog = string.gsub(_Changelog, "\n", "")
                            _Changelog = string.gsub(_Changelog, "-", " \n-"):gsub("%b<>", ""):sub(1, -2)

                            NewestVersion = Version1

                            Script['CL'] = true
                            Script['Changelog'] = _Changelog
                        end
                    end
                    Script['NewestVersion'] = Version1
                    Script['Version'] = Version

                    table.insert(ScriptList, Script)
                end
            else
                print(Name, "version metadata now found in the fxmanifest", resource)
            end
        end
    end
end

CreateThread(function()
    local Resources = GetNumResources()

    for i = 0, Resources, 1 do
        local resource = GetResourceByFindIndex(i)
        updateChecker(resource)
    end

    if next(ScriptList) ~= nil then
        VorpInitialized = true
        init_core()
        checker()
    end

    -- just warn them that a new feature is comming so they can prepare for it
    print("^3[WARNING] ^7new feature to register jobs in config/jobs.lua or by using exports.\n ^3for now this feature is disabled^7 but will be ^3enabled very soon^7 we are giving you time.\n reach out to the discord for more information about it.")
end)
