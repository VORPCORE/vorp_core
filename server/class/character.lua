--- update state bags
local function SetState(source, key, field, newValue)
    local state = Player(source).state[key]
    if state then
        state[field] = newValue
        Player(source).state:set(key, state, true)
    end
end

if not Config.Skills then
    print("Update the config Skills config missing")
    return
end

local function setSkills(data)
    for skillName, skillData in pairs(Config.Skills) do
        if not data.skills[skillName] then
            data.skills[skillName] = {
                Exp = 0,
                Level = 1,
                Label = skillData.Levels[1].Label,
                MaxLevel = #skillData.Levels,
                NextLevel = skillData.Levels[1].NextLevel
            }
        end
    end

    for skillName, skillData in pairs(data.skills) do
        if not Config.Skills[skillName] then
            print(("Skill %s not found in config of Skills"):format(skillName))
            return
        end

        local currentLevel = skillData.Level
        local currentExp = skillData.Exp
        local info = Config.Skills[skillName].Levels
        local maxLevel = #info
        local label = info[currentLevel].Label
        local nextLevel = info[currentLevel].NextLevel
        data.skills[skillName] = {
            Exp = currentExp,
            Level = currentLevel,
            Label = label,
            MaxLevel = maxLevel,
            NextLevel = nextLevel

        }
    end

    return data.skills
end

function Character(data)
    local self = {}
    self.identifier = data.identifier
    self.charIdentifier = data.charIdentifier
    self.group = data.group
    self.job = data.job
    self.joblabel = data.joblabel
    self.jobgrade = data.jobgrade
    self.firstname = data.firstname
    self.lastname = data.lastname
    self.inventory = data.inventory
    self.status = data.status
    self.coords = data.coords
    self.skin = data.skin
    self.comps = data.comps
    self.money = data.money
    self.gold = data.gold
    self.rol = data.rol
    self.healthOuter = data.healthOuter
    self.healthInner = data.healthInner
    self.staminaOuter = data.staminaOuter
    self.staminaInner = data.staminaInner
    self.xp = data.xp
    self.isdead = data.isdead
    self.source = data.source
    self.compTints = data.compTints
    self.age = data.age
    self.gender = data.gender
    self.charDescription = data.charDescription
    self.nickname = data.nickname
    self.steamname = data.steamname
    self.slots = data.slots
    self.skills = setSkills(data)
    self.multiJobs = data.multiJobs or {}

    self.Identifier = function()
        return self.identifier
    end

    self.CharIdentifier = function(value)
        if value then self.charIdentifier = value end
        return self.charIdentifier
    end

    self.Group = function(value, flag)
        if value then
            if flag or flag == nil then -- alow true or nil, only false will not trigger the event
                TriggerEvent("vorp:playerGroupChange", self.source, value, self.group)
            end
            self.group = value
            SetState(self.source, "Character", "Group", self.group)
        end

        return self.group
    end

    self.Job = function(value, flag)
        if value then
            if flag or flag == nil then -- alow true or nil, only false will not trigger the event
                TriggerEvent("vorp:playerJobChange", self.source, value, self.job)
            end
            self.job = value
            SetState(self.source, "Character", "Job", self.job)
        end
        return self.job
    end

    self.MultiJobs = function(job, grade, label)
        self.multiJobs[job] = {
            grade = grade,
            label = label
        }
        return true
    end

    self.Joblabel = function(value)
        if value then
            self.joblabel = value
            SetState(self.source, "Character", "JobLabel", self.joblabel)
        end

        return self.joblabel
    end

    self.Jobgrade = function(value, flag)
        if value then
            if flag or flag == nil then -- alow true or nil, only false will not trigger the event
                TriggerEvent("vorp:playerJobGradeChange", self.source, value, self.jobgrade)
            end
            self.jobgrade = value
            SetState(self.source, "Character", "Grade", self.jobgrade)
        end

        return self.jobgrade
    end

    self.Firstname = function(value)
        if value then
            self.firstname = value
            SetState(self.source, "Character", "FirstName", self.firstname)
        end
        return self.firstname
    end

    self.Lastname = function(value)
        if value then
            self.lastname = value
            SetState(self.source, "Character", "LastName", self.lastname)
        end

        return self.lastname
    end

    self.Age = function(value)
        if value then
            self.age = value
            SetState(self.source, "Character", "age", self.age)
        end
        return self.age
    end

    self.Gender = function(value)
        if value then
            self.gender = value
            SetState(self.source, "Character", "Gender", self.gender)
        end
        return self.gender
    end

    self.CharDescription = function(value)
        if value then
            self.charDescription = value
            SetState(self.source, "Character", "CharDescription", self.charDescription)
        end
        return self.charDescription
    end

    self.NickName = function(value)
        if value then
            self.nickname = value
            SetState(self.source, "Character", "NickName", self.nickname)
        end
        return self.nickname
    end

    self.Inventory = function(value)
        if value then self.inventory = value end
        return self.inventory
    end

    self.Status = function(value)
        if value then self.status = value end
        return self.status
    end

    self.Coords = function(value)
        if value then self.coords = value end
        return self.coords
    end

    self.Money = function(value)
        if value then self.money = value end
        return self.money
    end

    self.Gold = function(value)
        if value then self.gold = value end
        return self.gold
    end

    self.Rol = function(value)
        if value then self.rol = value end
        return self.rol
    end

    self.HealthOuter = function(value)
        if value then self.healthOuter = value end
        return self.healthOuter
    end

    self.HealthInner = function(value)
        if value then self.healthInner = value end
        return self.healthInner
    end

    self.StaminaOuter = function(value)
        if value then self.staminaOuter = value end
        return self.staminaOuter
    end

    self.StaminaInner = function(value)
        if value then self.staminaInner = value end
        return self.staminaInner
    end

    self.Xp = function(value)
        if value then self.xp = value end
        return self.xp
    end

    self.SkillsSetter = function(index, value)
        if not self.skills[index] then
            print("Skill not found")
            return
        end
        if not Config.Skills[index] then
            print("Skill not found in config")
            return
        end

        local levelsData = Config.Skills[index].Levels
        local oldExp = self.skills[index].Exp
        local newExp = oldExp + value

        if newExp <= 0 then
            self.skills[index].Exp = 0
        else
            self.skills[index].Exp = newExp
        end

        local currentExp = self.skills[index].Exp
        local currentLevel = self.skills[index].Level
        local MaxLevel = self.skills[index].MaxLevel

        if value < 0 then -- we are deducting exp
            -- check if we lower level
            if newExp < 0 and currentLevel > 1 then
                local newLevel = currentLevel - 1
                if not newLevel then
                    print("New level could not be found")
                    return
                end

                local expLoss = math.abs(value) -- Gives us how much XP was lost (as value would be negative when deducting XP)
                local leftoverLoss = expLoss - oldExp
                local prevLevelCap = levelsData[newLevel].NextLevel
                local newExpInPrevLevel = prevLevelCap - leftoverLoss -- (Rollover the xp into previous level cap)

                self.skills[index].Level = newLevel
                self.skills[index].Exp = newExpInPrevLevel
                self.skills[index].Label = levelsData[newLevel].Label
                self.skills[index].NextLevel = levelsData[newLevel].NextLevel

                TriggerClientEvent("vorp_core:Client:OnPlayerLevelUp", self.source, index, self.skills[index].Level, currentLevel)
                TriggerEvent("vorp_core:Server:OnPlayerLevelUp", self.source, index, self.skills[index].Level, currentLevel)
            end
        else
            if MaxLevel == currentLevel then return end

            local nextLevelExp = self.skills[index].NextLevel
            if currentExp > nextLevelExp then
                local newLevel = currentLevel + 1
                if not newLevel then
                    print("New level could not be found")
                    return
                end

                self.skills[index].Level = newLevel
                self.skills[index].Exp = currentExp - nextLevelExp -- (Rollover the xp eg 102/100 will mean 2 xp into next level)
                self.skills[index].Label = levelsData[newLevel].Label
                self.skills[index].NextLevel = levelsData[newLevel].NextLevel

                TriggerClientEvent("vorp_core:Client:OnPlayerLevelUp", self.source, index, self.skills[index].Level, currentLevel)
                TriggerEvent("vorp_core:Server:OnPlayerLevelUp", self.source, index, self.skills[index].Level, currentLevel)
            end
        end
    end

    self.IsDead = function(value)
        if value ~= nil then self.isdead = value end
        return self.isdead
    end

    self.Skin = function(value)
        if value then
            self.skin = value
            MySQL.update("UPDATE characters SET `skinPlayer` = @skin WHERE `identifier` = @identifier AND `charidentifier` = @charIdentifier",
                { skin = value, identifier = self.identifier, charIdentifier = self.charIdentifier })
        end
        return self.skin
    end

    self.Comps = function(value)
        if value then
            self.comps = value
            MySQL.update("UPDATE characters SET `compPlayer` = @comps WHERE `identifier` = @identifier AND `charidentifier` = @charIdentifier",
                { comps = value, identifier = self.identifier, charIdentifier = self.charIdentifier })
        end
        return self.comps
    end

    self.CompTints = function(value)
        if value then
            self.compTints = value
            MySQL.update("UPDATE characters SET `compTints` = @tints WHERE `identifier` = @identifier AND `charidentifier` = @charIdentifier",
                { tints = value, identifier = self.identifier, charIdentifier = self.charIdentifier })
        end
        return self.compTints
    end

    self.updateCharUi = function()
        local nuipost = {
            type = "ui",
            action = "update",
            moneyquanty = self.Money(),
            goldquanty = self.Gold(),
            rolquanty = self.Rol(),
            serverId = self.source,
            xp = self.Xp()
        }
        TriggerClientEvent("vorp:updateUi", self.source, json.encode(nuipost))
    end

    self.addCurrency = function(currency, quantity) --add check for security
        if currency == 0 then
            self.money = self.money + quantity
            SetState(self.source, "Character", "Money", self.money)
        elseif currency == 1 then
            self.gold = self.gold + quantity
            SetState(self.source, "Character", "Gold", self.gold)
        elseif currency == 2 then
            self.rol = self.rol + quantity
            SetState(self.source, "Character", "Rol", self.rol)
        end
        self.updateCharUi()
    end

    self.removeCurrency = function(currency, quantity)
        if currency == 0 then
            self.money = self.money - quantity
            SetState(self.source, "Character", "Money", self.money)
        elseif currency == 1 then
            self.gold = self.gold - quantity
            SetState(self.source, "Character", "Gold", self.gold)
        elseif currency == 2 then
            self.rol = self.rol - quantity
            SetState(self.source, "Character", "Rol", self.rol)
        end

        self.updateCharUi()
    end

    self.addXp = function(quantity)
        if not quantity then return print("xp quantity is required") end
        self.xp = self.xp + quantity
        self.updateCharUi()
    end

    self.removeXp = function(quantity)
        if not quantity then return print("remove xp quantity is required") end
        self.Xp = self.xp - quantity
        self.updateCharUi()
    end

    self.saveHealthAndStamina = function(healthOuter, healthInner, staminaOuter, staminaInner)
        self.healthOuter = healthOuter
        self.healthInner = healthInner
        self.staminaOuter = staminaOuter
        self.staminaInner = staminaInner
    end

    self.setJob = function(newjob)
        self.Job(newjob)
    end

    self.setMultiJob = function(job, grade, label)
        return self.MultiJobs(job, grade, label)
    end

    self.removeMultiJob = function(job)
        if not self.multiJobs[job] then
            return false
        end

        if self.multiJobs[job] then
            self.multiJobs[job] = nil
        end

        return true
    end

    self.setGroup = function(newgroup)
        self.Group(newgroup)
    end

    self.setDead = function(dead)
        self.IsDead(dead)
    end

    self.setSlots = function(slots)
        if slots then
            self.slots = self.slots + slots
        end
        return self.slots
    end

    self.SaveNewCharacterInDb = function(cb)
        MySQL.query("INSERT INTO characters (`identifier`,`group`,`money`,`gold`,`rol`,`xp`,`healthouter`,`healthinner`,`staminaouter`,`staminainner`,`inventory`,`job`,`status`,`firstname`,`lastname`,`skinPlayer`,`compPlayer`,`jobgrade`,`coords`,`isdead`,`joblabel`, `age`,`gender`,`character_desc`,`nickname`,`compTints`,`steamname`,`slots`,`skills`,`multijobs`) VALUES (@identifier,@group, @money, @gold, @rol, @xp, @healthouter, @healthinner, @staminaouter, @staminainner, @inventory, @job, @status, @firstname, @lastname, @skinPlayer, @compPlayer, @jobgrade, @coords, @isdead, @joblabel, @age, @gender, @charDescription, @nickname,@compTints,@steamname,@slots,@skills,@multijobs)",
            {
                identifier = self.identifier,
                group = self.group,
                money = self.money,
                gold = self.gold,
                rol = self.rol,
                xp = self.xp,
                healthouter = self.healthOuter,
                healthinner = self.healthInner,
                staminaouter = self.staminaOuter,
                staminainner = self.staminaInner,
                inventory = self.inventory,
                job = self.job,
                status = self.status,
                firstname = self.firstname,
                lastname = self.lastname,
                skinPlayer = self.skin,
                compPlayer = self.comps,
                jobgrade = self.jobgrade,
                coords = self.coords,
                isdead = self.isdead,
                joblabel = self.joblabel,
                age = self.age,
                gender = self.gender,
                charDescription = self.charDescription,
                nickname = self.nickname,
                compTints = self.compTints,
                steamname = self.steamname,
                slots = self.slots,
                skills = json.encode(self.skills),
                multijobs = json.encode(self.multiJobs)

            },
            function(character)
                cb(character.insertId)
            end)
    end

    self.DeleteCharacter = function()
        MySQL.query("DELETE FROM characters WHERE `identifier` = @identifier AND `charidentifier` = @charidentifier ", { identifier = self.identifier, charidentifier = self.charIdentifier })
    end

    self.SaveCharacterCoords = function(coords)
        MySQL.update("UPDATE characters SET `coords` = @coords WHERE `identifier` =  @identifier AND `charidentifier` = @charidentifier", { coords = coords, identifier = self.identifier, charidentifier = self.charIdentifier })
    end

    self.SaveCharacterInDb = function()
        MySQL.update("UPDATE characters SET `group` =@group ,`money` =@money ,`gold` =@gold ,`rol` =@rol ,`xp` =@xp ,`healthouter` =@healthouter ,`healthinner` =@healthinner ,`staminaouter` =@staminaouter ,`staminainner` =@staminainner ,`job` =@job , `status` =@status ,`firstname` =@firstname , `lastname` =@lastname , `jobgrade` =@jobgrade , `coords` =@coords , `isdead` =@isdead , `joblabel` =@joblabel, `age` =@age, `gender`=@gender, `character_desc`=@charDescription,`nickname`=@nickname,`steamname`=@steamname, `slots` =@slots, `skills`=@skills, `multijobs`=@multijobs  WHERE `identifier` =@identifier AND `charidentifier` =@charidentifier",
            {
                group = self.group,
                money = self.money,
                gold = self.gold,
                rol = self.rol,
                xp = self.xp,
                healthouter = self.healthOuter,
                healthinner = self.healthInner,
                staminaouter = self.staminaOuter,
                staminainner = self.staminaInner,
                job = self.job,
                status = self.status,
                firstname = self.firstname,
                lastname = self.lastname,
                jobgrade = self.jobgrade,
                coords = self.coords,
                isdead = self.isdead,
                joblabel = self.joblabel,
                identifier = self.identifier,
                charidentifier = self.charIdentifier,
                age = self.age,
                gender = self.gender,
                charDescription = self.charDescription,
                nickname = self.nickname,
                steamname = self.steamname,
                slots = self.slots,
                skills = json.encode(self.skills),
                multijobs = json.encode(self.multiJobs)
            })
    end

    -- getters and functions setters
    self.getCharacter = function()
        local userData = {}
        userData.identifier = self.identifier
        userData.charIdentifier = self.charIdentifier
        userData.group = self.group
        userData.job = self.job
        userData.jobLabel = self.joblabel
        userData.jobGrade = self.jobgrade
        userData.money = self.money
        userData.gold = self.gold
        userData.rol = self.rol
        userData.xp = self.xp
        userData.healthOuter = self.healthOuter
        userData.healthInner = self.healthInner
        userData.staminaOuter = self.staminaOuter
        userData.staminaInner = self.staminaInner
        userData.firstname = self.firstname
        userData.lastname = self.lastname
        userData.inventory = self.inventory
        userData.status = self.status
        userData.coords = self.coords
        userData.isdead = self.isdead
        userData.skin = self.skin
        userData.comps = self.comps
        userData.compTints = self.compTints
        userData.age = self.age
        userData.gender = self.gender
        userData.charDescription = self.charDescription
        userData.nickname = self.nickname
        userData.invCapacity = tonumber(self.slots)
        userData.skills = self.skills
        userData.multiJobs = self.multiJobs

        userData.updateInvCapacity = function(slots)
            self.setSlots(slots)
        end

        userData.setStatus = function(status)
            self.Status(status)
        end

        userData.getMultiJobsCount = function()
            local count = 0
            for _, _ in pairs(self.multiJobs) do
                count = count + 1
            end
            return count
        end

        userData.setJobGrade = function(jobgrade, flag)
            self.Jobgrade(jobgrade, flag)
        end

        userData.setJobLabel = function(joblabel)
            self.Joblabel(joblabel)
        end

        userData.setGroup = function(group, flag)
            self.Group(group, flag)
        end

        userData.setJob = function(job, flag)
            -- just warn them that a new feature is comming so they can prepare for it
            if not Config?.REGISTERED_JOBS[job] then
                print("^3[WARNING] ^7new feature to register jobs in config/jobs.lua or by using exports.\n ^3for now this feature is disabled^7 but will be ^3enabled very soon^7 we are giving you time.\n reach out to the discord for more information about it.")
            end
            self.Job(job, flag)
        end

        userData.setMultiJob = function(job, grade, label)
            self.MultiJobs(job, grade, label)
        end

        userData.removeMultiJob = function(job)
            return self.removeMultiJob(job)
        end

        userData.setMoney = function(money)
            self.Money(money)
            self.updateCharUi()
        end

        userData.setGold = function(gold)
            self.Gold(gold)
            self.updateCharUi()
        end

        userData.setRol = function(rol)
            self.Rol(rol)
            self.updateCharUi()
        end

        userData.setXp = function(xp)
            self.Xp(xp)
            self.updateCharUi()
        end

        userData.setFirstname = function(firstname)
            self.Firstname(firstname)
        end

        userData.setLastname = function(lastname)
            self.Lastname(lastname)
        end
        -------------------
        userData.setAge = function(age)
            self.Age(age)
        end

        userData.setGender = function(gender)
            self.Gender(gender)
        end

        userData.setCharDescription = function(charDescription)
            self.CharDescription(charDescription)
        end

        userData.setNickName = function(nickname)
            self.NickName(nickname)
        end
        --------------
        userData.updateSkin = function(skin)
            self.Skin(skin)
        end

        userData.setSkills = function(index, exp)
            self.SkillsSetter(index, exp)
        end

        userData.updateComps = function(comps)
            self.Comps(comps)
        end
        userData.updateCompTints = function(tints)
            self.CompTints(tints)
        end

        userData.addCurrency = function(currency, quantity)
            self.addCurrency(currency, quantity)
        end

        userData.removeCurrency = function(currency, quantity)
            self.removeCurrency(currency, quantity)
        end

        userData.addXp = function(xp)
            self.addXp(xp)
        end

        userData.removeXp = function(xp)
            self.removeXp(xp)
        end

        userData.updateCharUi = function()
            local nuipost = {
                type = "ui",
                action = "update",
                moneyquanty = self.Money(),
                goldquanty = self.Gold(),
                rolquanty = self.Rol(),
                serverId = self.source,
                xp = self.Xp()
            }

            TriggerClientEvent("vorp:updateUi", self.source, json.encode(nuipost))
        end

        return userData
    end

    return self
end
