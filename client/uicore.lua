local vorpShowUI = true
local ShowUI = true
local MenuData = exports.vorp_menu:GetMenuData()
local T <const> = Translation[Lang].MessageOfSystem.PlayerMenu
local N <const> = Translation[Lang].Notify

function CoreAction.Utils.ToggleVorpUI()
    vorpShowUI = not vorpShowUI
    TriggerEvent("vorp:showUi", vorpShowUI)
end

function CoreAction.Utils.ToggleAllUI()
    ShowUI = not ShowUI
    DisplayRadar(ShowUI)
    TriggerEvent("syn_displayrange", ShowUI)
    TriggerEvent("vorp:showUi", ShowUI)
end

RegisterNetEvent('vorp:updateUi', function(stringJson)
    SendNUIMessage(json.decode(stringJson))
end)

RegisterNetEvent('vorp:showUi', function(active)
    vorpShowUI = active
    local jsonpost = { type = "ui", action = "hide" }
    if active then jsonpost = { type = "ui", action = "show" } end

    SendNUIMessage(jsonpost)
end)

RegisterNetEvent('vorp:setPVPUi', function(active)
    SendNUIMessage({ type = "ui", action = "setpvp", pvp = active })
end)

RegisterNetEvent('vorp:SelectedCharacter', function()
    Wait(10000)
    SendNUIMessage({
        type = "ui",
        action = "initiate",
        hidegold = Config.HideGold,
        hidemoney = Config.HideMoney,
        hidelevel = Config.HideLevel,
        hideid = Config.HideID,
        hidetokens = Config.HideTokens,
        uiposition = Config.UIPosition,
        uilayout = Config.UILayout,
        closeondelay = Config.CloseOnDelay,
        closeondelayms = Config.CloseOnDelayMS,
        hidepvp = Config.HidePVP,
        pvp = Config.PVP
    })

    if Config.HideWithRader then
        local cantoggle = not Config.HideUi

        CreateThread(function()
            while true do
                if IsRadarHidden() then
                    cantoggle = true
                    SendNUIMessage({ type = "ui", action = "hide" })
                    vorpShowUI = false
                elseif cantoggle and Config.OpenAfterRader then
                    cantoggle = false
                    SendNUIMessage({ type = "ui", action = "show" })
                    vorpShowUI = true
                end

                Wait(1000)
            end
        end)
    end
end)

RegisterNUICallback('close', function(_, cb)
    vorpShowUI = false
    cb('ok')
end)


local function formatCooldown(seconds)
    local totalSeconds <const> = math.max(0, math.floor(tonumber(seconds) or 0))
    local minutes <const> = math.max(1, math.ceil(totalSeconds / 60))
    return minutes .. " min"
end

local function buildJobsContextDescription(payload)
    local cooldownRemaining <const> = tonumber(payload.cooldownRemaining) or 0
    if cooldownRemaining > 0 then
        return T.switchCooldown .. " " .. formatCooldown(cooldownRemaining)
    end

    return nil
end


local function normalizeMenuPayload(payload)
    if type(payload) ~= "table" then
        return nil
    end

    if payload.skills then
        return payload
    end

    return {
        skills = payload,
        jobs = {},
        activeJob = {},
        cooldownRemaining = 0,
    }
end

local function openSkillsMenu(payload)
    MenuData.CloseAll()
    local skills <const> = payload.skills or {}
    local elements <const> = {}

    for skillName, skillData in pairs(skills) do
        elements[#elements + 1] = {
            label = skillName .. " " .. skillData.Level,
            value = skillName,
            isDisabled = true,
            desc = skillData.Label ..
                "<br>" .. T.currentExp .. " " .. skillData.Exp ..
                "<br>" .. T.currentLevel .. " (" .. skillData.Level .. " / " .. skillData.MaxLevel .. ")" ..
                "<br>" .. T.nextLevelAt .. " " .. skillData.NextLevel .. " " .. T.exp,
        }
    end

    if #elements == 0 then
        elements[1] = {
            label = T.noSkillsLabel,
            value = "no_skills",
            isDisabled = true,
            desc = T.noSkillsDesc
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'openSkillsMenu', {
        title = T.skillsTitle,
        subtext = T.skillsSubtext,
        elements = elements,
        align = "top-left",
        hideRadar = true,
        enableCursor = true,
        divider = true,
        fixedHeight = true,
        lastmenu = "OpenPlayerMenuUI",
    }, function(data, _)
        if (data.current == "backup") then -- go back
            _G[data.trigger](payload)
        end
    end)
end

local function openJobsMenu(payload)
    MenuData.CloseAll()
    local elements <const> = {}
    local jobs <const> = payload.jobs or {}
    local contextDescription <const> = buildJobsContextDescription(payload)
    local cooldownRemaining <const> = tonumber(payload.cooldownRemaining) or 0

    for jobName, jobData in pairs(jobs) do
        local isActive <const> = payload.activeJob and payload.activeJob.name == jobName
        local isDisabled <const> = cooldownRemaining > 0 and not isActive
        local label = jobData.label or jobName
        if isActive then
            label = label .. " [" .. T.activeTag .. "]"
        end

        local desc = T.job .. " " .. jobName .. "<br>" .. T.grade .. " " .. tostring(jobData.grade or 0)
        if contextDescription then
            desc = desc .. "<br>" .. contextDescription
        end
        if isDisabled then
            desc = desc .. "<br>" .. T.cooldownBlockedDescription
        end

        elements[#elements + 1] = {
            label = label,
            value = jobName,
            desc = desc,
            footerText = not isActive and not isDisabled and T.applyMultiJobFooterText or nil,
            isDisabled = isDisabled,
        }
    end


    MenuData.Open('default', GetCurrentResourceName(), 'openJobsMenu', {
        title = T.jobsTitle,
        subtext = T.jobsSubtext,
        elements = elements,
        align = "top-left",
        hideRadar = true,
        enableCursor = true,
        divider = true,
        fixedHeight = true,
        lastmenu = "OpenPlayerMenuUI",
    }, function(data, menu)
        if (data.current == "backup") then -- go back
            _G[data.trigger](payload)
        end

        local selectedJob <const> = data.current.value
        if payload.activeJob and payload.activeJob.name == selectedJob then
            VorpNotification:NotifyRightTip(T.alreadyEquipped, 4000)
            return
        end

        if cooldownRemaining > 0 then
            VorpNotification:NotifyRightTip(N.MultiJob.CoolDownMJob .. formatCooldown(cooldownRemaining), 4000)
            return
        end

        TriggerServerEvent("vorp:SwitchMultiJobMenu", selectedJob)
        menu.close(true, true, true)
    end)
end

function OpenPlayerMenuUI(payload)
    local menuPayload <const> = normalizeMenuPayload(payload)
    if not menuPayload then
        return
    end

    MenuData.CloseAll()

    local hasJobs <const> = menuPayload.jobs and next(menuPayload.jobs) ~= nil
    local elements <const> = {
        {
            label = T.skillsLabel,
            value = "skills",
            desc = T.skillsDescription,
            footerText = T.moreOptionsFooterText,
        },
        {
            label = T.jobsLabel,
            value = "jobs",
            desc = hasJobs and T.jobsDescription or T.jobsDescriptionEmpty,
            footerText = hasJobs and T.moreOptionsFooterText or nil,
        }
    }

    if not hasJobs then
        table.remove(elements, 2)
    end


    MenuData.Open('default', GetCurrentResourceName(), 'OpenPlayerMenuUI', {
        title = T.title,
        subtext = T.subtext,
        elements = elements,
        align = "top-left",
        soundOpen = true,
        hideRadar = true,
        enableCursor = true,
        divider = true,
        fixedHeight = true,
    }, function(data, _)
        if data.current.value == "skills" then
            openSkillsMenu(payload)
        end

        if data.current.value == "jobs" then
            openJobsMenu(payload)
        end
    end, function(_, menu)
        menu.close(true, true, true)
    end)
end

RegisterNetEvent('vorp:OpenPlayerMenu', function(payload)
    OpenPlayerMenuUI(payload)
end)
