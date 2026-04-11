local vorpShowUI = true
local ShowUI = true
local MenuData = exports.vorp_menu:GetMenuData()

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

RegisterNUICallback('close', function(args, cb)
    vorpShowUI = false
    cb('ok')
end)

local T <const> = Translation[Lang].MessageOfSystem.PlayerMenu
local N <const> = Translation[Lang].Notify

local function hasMultiJobs(jobs)
    return jobs and next(jobs) ~= nil
end

local function formatCooldown(seconds)
    local totalSeconds <const> = math.max(0, math.floor(tonumber(seconds) or 0))
    local minutes <const> = math.max(1, math.ceil(totalSeconds / 60))
    return minutes .. " min"
end

local function buildSkillsMenuElements(skills)
    local elements = {}
    local skillNames = {}

    for skillName in pairs(skills or {}) do
        skillNames[#skillNames + 1] = skillName
    end

    table.sort(skillNames)

    for _, skillName in ipairs(skillNames) do
        local skillData <const> = skills[skillName]
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

    return elements
end

local function buildJobsContextDescription(payload)
    local cooldownRemaining <const> = tonumber(payload.cooldownRemaining) or 0
    if cooldownRemaining > 0 then
        return T.switchCooldown .. " " .. formatCooldown(cooldownRemaining)
    end

    return nil
end

local function buildJobsMenuElements(payload)
    local elements = {}
    local jobNames = {}
    local jobs <const> = payload.jobs or {}
    local contextDescription <const> = buildJobsContextDescription(payload)
    local cooldownRemaining <const> = tonumber(payload.cooldownRemaining) or 0

    for jobName in pairs(jobs) do
        jobNames[#jobNames + 1] = jobName
    end

    table.sort(jobNames, function(left, right)
        local leftLabel <const> = jobs[left].label or left
        local rightLabel <const> = jobs[right].label or right

        if leftLabel == rightLabel then
            return left < right
        end

        return leftLabel < rightLabel
    end)

    for _, jobName in ipairs(jobNames) do
        local jobData <const> = jobs[jobName]
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

    return elements
end

local openPlayerMenu

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
    MenuData.Open('default', GetCurrentResourceName(), 'player_skills_menu', {
        title = T.skillsTitle,
        subtext = T.skillsSubtext,
        elements = buildSkillsMenuElements(payload.skills),
        align = "top-left",
        soundOpen = true,
        hideRadar = true,
        enableCursor = true,
        divider = true,
        fixedHeight = true,
        lastmenu = "__back",
    }, function(data, menu)
        if data.current == "backup" then
            menu.close(false, false, false)
            openPlayerMenu(payload)
        end
    end, function(_, menu)
        menu.close(true, true, true)
    end)
end

local function openJobsMenu(payload)
    MenuData.Open('default', GetCurrentResourceName(), 'player_jobs_menu', {
        title = T.jobsTitle,
        subtext = T.jobsSubtext,
        elements = buildJobsMenuElements(payload),
        align = "top-left",
        soundOpen = true,
        hideRadar = true,
        enableCursor = true,
        divider = true,
        fixedHeight = true,
        lastmenu = "__back",
    }, function(data, menu)
        if data.current == "backup" then
            menu.close(false, false, false)
            openPlayerMenu(payload)
            return
        end

        if type(data.current) ~= "table" then
            return
        end

        local selectedJob <const> = data.current.value
        if payload.activeJob and payload.activeJob.name == selectedJob then
            VorpNotification:NotifyRightTip(T.alreadyEquipped, 4000)
            return
        end

        local cooldownRemaining <const> = tonumber(payload.cooldownRemaining) or 0
        if cooldownRemaining > 0 then
            VorpNotification:NotifyRightTip(N.MultiJob.CoolDownMJob .. formatCooldown(cooldownRemaining), 4000)
            return
        end

        TriggerServerEvent("vorp:SwitchMultiJobMenu", selectedJob)
        menu.close(true, true, true)
    end, function(_, menu)
        menu.close(true, true, true)
    end)
end

openPlayerMenu = function(payload)
    local hasJobs <const> = hasMultiJobs(payload.jobs)
    MenuData.Open('default', GetCurrentResourceName(), 'player_menu', {
        title = T.title,
        subtext = T.subtext,
        elements = {
            {
                label = T.skillsLabel,
                value = "skills",
                desc = T.skillsDescription,
                footerText = T.moreOptionsFooterText,
            },
            {
                label = T.jobsLabel,
                value = "jobs",
                desc = hasJobs and
                    T.jobsDescription or
                    T.jobsDescriptionEmpty,
                footerText = hasJobs and T.moreOptionsFooterText or nil,
            }
        },
        align = "top-left",
        soundOpen = true,
        hideRadar = true,
        enableCursor = true,
        divider = true,
        fixedHeight = true,
    }, function(data, menu)
        if type(data.current) ~= "table" then
            return
        end

        if data.current.value == "skills" then
            menu.close(false, false, false)
            openSkillsMenu(payload)
            return
        end

        if data.current.value == "jobs" then
            if not hasMultiJobs(payload.jobs) then
                VorpNotification:NotifyRightTip(N.MultiJob.DontHaveMJob, 4000)
                return
            end

            menu.close(false, false, false)
            openJobsMenu(payload)
        end
    end, function(_, menu)
        menu.close(true, true, true)
    end)
end

local function openPlayerMenuUI(payload)
    local menuPayload <const> = normalizeMenuPayload(payload)
    if not menuPayload then
        return
    end

    MenuData.CloseAll(true, true, true)
    openPlayerMenu(menuPayload)
end

RegisterNetEvent('vorp:OpenPlayerMenu', function(payload)
    openPlayerMenuUI(payload)
end)
