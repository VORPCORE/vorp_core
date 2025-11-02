local T = Translation[Lang].Commands
--============================
--? EXAMPLE
-- * in this file is where vorp core commands are registered
-- * you can register your own commands here too
-- * it has features such as : arguments needed , is user in game , groups allowed ,aces allowed ,jobs allowed, webhooks and chat suggestions
-- * callfunction bellow, will return a table  with    {source , args , rawCommand , config} config is the value on this file the parameters of the command used like commandName
-- TODO job grade support

--[[ addgroup = {
        webhook = "", -- discord log when someone uses this command leave to false if you dont need
        custom = "\n**PlayerID** `%d`\n**Group given** `%s`", -- for webhook
        title = "📋 `/Group command`", -- webhook title
        ---#end webhook
        commandName = "addGroup", -- name of the command to use
        label = "set players group", -- label of command when using
        suggestion = { -- chat arguments needed
            { name = "Id",    help = T.Commands.help1 }, -- add how many you need
            { name = "Group", help = T.Commands.help2 },
        },
        userCheck = true, -- does this command need to check if user is playing ?
        groupAllowed = { "admin" }, -- from users table in the database this group will be allowed to use this command
        aceAllowed = 'vorpcore.setGroup.Command', -- dont touch,
        jobsAllow = {}, -- jobs allowed ? remove or leave empty if not needed
        callFunction = function(...) -- dont touch
            -- this is a function
            -- you can run code here trigger client events or server events , exports etc,
            -- get source local data = ...
            --local source = data.source
            SetGroup(...)
        end

    },]]
--END

--==============================
Commands = {
    giveExp = {
        webhook = "",
        custom = T.giveExp.custom,
        title = T.giveExp.title,
        commandName = "addExp",
        label = T.giveExp.label,
        suggestion = {
            { name = T.giveExp.name,  help = T.giveExp.help },
            { name = T.giveExp.name1, help = T.giveExp.help1 },
            { name = T.giveExp.name2, help = T.giveExp.help2 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.setExp.Command',
        callFunction = function(...)
            SetExp(...)
        end
    },
    myExp = {
        webhook = "",
        custom = T.myExp.custom,
        title = T.myExp.title,
        commandName = "myExp",
        label = T.myExp.label,
        suggestion = {
            { name = T.myExp.name, help = T.myExp.help },
        },
        userCheck = false,
        groupAllowed = {},
        aceAllowed = nil,
        callFunction = function(...)
            MyExp(...)
        end
    },
    addgroup = {
        webhook = "",
        custom = T.addGroup.custom,
        title = T.addGroup.tittle,
        ---#end webhook
        commandName = "addGroup",
        label = T.addGroup.label,
        suggestion = {
            { name = T.addGroup.name,  help = T.addGroup.help },
            { name = T.addGroup.name1, help = T.addGroup.help1 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.setGroup.Command',
        callFunction = function(...)
            SetGroup(...)
        end
    },
    addGroupCharacter = {
        webhook = "",
        custom = T.addGroupCharacter.custom,
        title = T.addGroupCharacter.tittle,
        ---#end webhook
        commandName = "addGroupChar",
        label = T.addGroupCharacter.label,
        suggestion = {
            { name = T.addGroupCharacter.name,  help = T.addGroupCharacter.help },
            { name = T.addGroupCharacter.name1, help = T.addGroupCharacter.help1 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.setGroup.Command',
        callFunction = function(...)
            SetGroupCharacter(...)
        end
    },
    addJob = {
        webhook = "",
        custom = T.addJob.custom,
        title = T.addJob.title,
        ---#end webhook
        commandName = "addJob",
        label = T.addJob.label,
        suggestion = {
            { name = T.addJob.name,  help = T.addJob.help },
            { name = T.addJob.name1, help = T.addJob.help1 },
            { name = T.addJob.name2, help = T.addJob.help2 },
            { name = T.addJob.name3, help = T.addJob.help3 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.setJob.Command',
        callFunction = function(...)
            AddJob(...)
        end
    },
    switchMultiJob = {
        webhook = "",
        custom = "\n**PlayerID:** `%d` \n**Job switched** `%s`\n**Grade:** `%d`",
        title = "📋 `/switchMultiJob command`",
        commandName = "switchMultiJob",
        label = "VORPcore command to switch your job",
        suggestion = {
            { name = "Id",  help = "your ID" },
            { name = "Job", help = "job name to switch to" },
        },
        userCheck = false,
        groupAllowed = {},
        aceAllowed = nil,
        callFunction = function(...)
            SwitchMultiJob(...)
        end
    },
    setMaxJobsAllowed = {
        webhook = "",
        custom = "\n**PlayerID:** `%d` \n**Max jobs allowed** `%d`",
        title = "📋 `/setMaxJobsAllowed command`",
        commandName = "setMaxJobsAllowed",
        label = "VORPcore command to set the maximum number of jobs allowed for a user",
        suggestion = {
            { name = "Id",       help = "your ID" },
            { name = "Max jobs", help = "maximum number of jobs allowed for a user" },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = "",
        callFunction = function(...)
            SetMultiJobMaxAllowed(...)
        end
    },
    addMultiJob = {
        webhook = "",
        custom = "\n**PlayerID:** `%d` \n**Job added** `%s`\n**Grade:** `%d`",
        title = "📋 `/addMultiJob command`",
        commandName = "addMultiJob",
        label = "VORPcore command to add a multi job to a user",
        suggestion = {
            { name = "Id",    help = "your ID" },
            { name = "Job",   help = "job name to add" },
            { name = "Grade", help = "job grade to add" },
            { name = "Label", help = "job label to add" },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = "",
        callFunction = function(...)
            AddMultiJob(...)
        end
    },
    removeMultiJob = {
        webhook = "",
        custom = "\n**PlayerID:** `%d` \n**Job removed** `%s`",
        title = "📋 `/removeMultiJob command`",
        commandName = "removeMultiJob",
        label = "VORPcore command to remove a multi job from a user",
        suggestion = {
            { name = "Id",  help = "your ID" },
            { name = "Job", help = "job name to remove" },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = "",
        callFunction = function(...)
            RemoveMultiJob(...)
        end
    },
    addItem = {
        webhook = "",
        custom = T.addItem.custom,
        title = T.addItem.title,
        ---#end webhook
        commandName = "addItems",
        label = T.addItem.label,
        suggestion = {
            { name = T.addItem.name,  help = T.addItem.help },
            { name = T.addItem.name1, help = T.addItem.help1 },
            { name = T.addItem.name2, help = T.addItem.help2 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.additems.Command',
        callFunction = function(...)
            AddItems(...)
        end
    },
    addWeapon = {
        webhook = "",
        custom = T.addWeapon.custom,
        title = T.addWeapon.title,
        ---#end webhook
        commandName = "addWeapon",
        label = T.addWeapon.label,
        suggestion = {
            { name = T.addWeapon.name,  help = T.addWeapon.help },
            { name = T.addWeapon.name1, help = T.addWeapon.help1 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.addweapons.Command',
        callFunction = function(...)
            AddWeapons(...)
        end
    },
    delMoney = {
        webhook = "",
        custom = T.delMoney.custom,
        title = T.delMoney.title,
        ---#end webhook
        commandName = "delMoney",
        label = T.delMoney.label,
        suggestion = {
            { name = T.delMoney.name,  help = T.delMoney.help },
            { name = T.delMoney.name1, help = T.delMoney.help1 },
            { name = T.delMoney.name2, help = T.delMoney.help2 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.delCurrency.Command',
        callFunction = function(...)
            RemmoveCurrency(...)
        end
    },
    addMoney = {
        webhook = "",
        custom = T.addMoney.custom,
        title = T.addMoney.title,
        ---#end webhook
        commandName = "addMoney",
        label = T.addMoney.label,
        suggestion = {
            { name = T.addMoney.name,  help = T.addMoney.help },
            { name = T.addMoney.name1, help = T.addMoney.help1 },
            { name = T.addMoney.name2, help = T.addMoney.help2 },

        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.addMoney.Command',
        callFunction = function(...)
            AddMoney(...)
        end
    },
    delWagons = {
        webhook = "",
        custom = T.delWagons.custom,
        title = T.delWagons.title,
        ---#end webhook
        commandName = "delWagons",
        label = T.delWagons.label,
        suggestion = {
            { name = T.delWagons.name, help = T.delWagons.help },
        },
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.delwagons.Command',
        callFunction = function(...)
            DeleteWagons(...)
        end
    },
    revive = {
        webhook = "",
        custom = T.revive.custom,
        title = T.revive.title,
        commandName = "revive",
        label = T.revive.label,
        suggestion = {
            { name = T.revive.name, help = T.revive.help }
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.reviveplayer.Command',
        callFunction = function(...)
            RevivePlayer(...)
        end
    },
    teleport = {
        webhook = "",
        custom = T.teleport.custom,
        title = T.teleport.title,
        commandName = "tpm",
        label = T.teleport.label,
        suggestion = {},
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.tpm.Command',
        callFunction = function(...)
            TeleporPlayer(...)
        end
    },
    delHorse = {
        webhook = "",
        custom = T.delHorse.custom,
        title = T.delHorse.title,
        commandName = "delHorse",
        label = T.delHorse.label,
        suggestion = {},
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.delhorse.Command',
        callFunction = function(...)
            DeleteHorse(...)
        end
    },
    heal = {
        webhook = "",
        custom = T.heal.custom,
        title = T.heal.title,
        commandName = "heal",
        label = T.heal.label,
        suggestion = {
            { name = T.heal.name, help = T.heal.help }
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.healplayer.Command',
        callFunction = function(data)
            -- in here you can add your metabolism events
            TriggerClientEvent("vorpmetabolism:changeValue", tonumber(data.args[1]), "Thirst", 1000)
            TriggerClientEvent("vorpmetabolism:changeValue", tonumber(data.args[1]), "Hunger", 1000)
            HealPlayers(data)
        end
    },
    addWhitelist = {
        webhook = "",
        custom = T.addWhitelist.custom,
        title = T.addWhitelist.title,
        commandName = "addWhtelist",
        label = T.addWhitelist.label,
        suggestion = {
            { name = T.addWhitelist.name, help = T.addWhitelist.help },

        },
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.wlplayer.Command',
        callFunction = function(...)
            AddPlayerToWhitelist(...)
        end
    },
    unWhitelist = {
        webhook = "",
        custom = T.unWhitelist.custom,
        title = T.unWhitelist.title,
        commandName = "unWhitelist",
        label = T.unWhitelist.label,
        suggestion = {
            { name = T.unWhitelist.name, help = T.unWhitelist.help },
        },
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.unwlplayer.Command',
        callFunction = function(...)
            RemovePlayerFromWhitelist(...)
        end
    },
    ban = {
        webhook = "",
        custom = T.ban.custom,
        title = T.ban.title,
        commandName = "ban",
        label = T.ban.label,
        suggestion = {
            { name = T.ban.name,  help = T.ban.help },
            { name = T.ban.name1, help = T.ban.help1 },
        },
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.ban.Command',
        callFunction = function(...)
            BanPlayers(...)
        end
    },
    unBan = {
        webhook = "",
        custom = T.unBan.custom,
        title = T.unBan.title,
        commandName = "unBan",
        label = T.unBan.label,
        suggestion = {
            { name = T.unBan.name, help = T.unBan.help },
        },
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.unban.Command',
        callFunction = function(...)
            UnBanPlayers(...)
        end
    },
    warn = {
        webhook = "",
        custom = T.warn.custom,
        title = T.warn.title,
        commandName = "warn",
        label = T.warn.label,
        suggestion = {
            { name = T.warn.name, help = T.warn.help },
        },
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.warn.Command',
        callFunction = function(...)
            WarnPlayers(...)
        end
    },
    unWarn = {
        webhook = "",
        custom = T.unWarn.custom,
        title = T.unWarn.title,
        commandName = "unWarn",
        label = T.unWarn.label,
        suggestion = {
            { name = T.unWarn.name, help = T.unWarn.help }
        },
        userCheck = false,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.unwarn.Command',
        callFunction = function(...)
            UnWarnPlayer(...)
        end
    },
    charName = {
        webhook = "",
        custom = T.charName.custom,
        title = T.charName.title,
        commandName = "modifyCharName",
        label = T.charName.label,
        suggestion = {
            { name = T.charName.name,  help = T.charName.help },
            { name = T.charName.name1, help = T.charName.help1 },
            { name = T.charName.name2, help = T.charName.help2 },

        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.changeCharName',
        callFunction = function(...)
            ModifyCharName(...)
        end
    },
    charCreateAdd = {
        webhook = "",
        custom = T.charCreateAdd.custom,
        title = T.charCreateAdd.title,
        commandName = "addChar",
        label = T.charCreateAdd.label,
        suggestion = {
            { name = T.charCreateAdd.name,  help = T.charCreateAdd.help },
            { name = T.charCreateAdd.name1, help = T.charCreateAdd.help1 },
        },
        userCheck = true,
        groupAllowed = { "admin" },
        aceAllowed = 'vorpcore.addchar.Command',
        callFunction = function(...)
            AddCharCanCreateMore(...)
        end
    },
    myJob = {
        webhook = "",
        commandName = "myJob",
        label = T.myJob.label,
        suggestion = {},
        userCheck = false,
        groupAllowed = {}, -- leave empty anyone can use
        aceAllowed = nil,  -- leave nil anyone can use
        callFunction = function(...)
            MyJob(...)
        end
    },

    -- create your commands here just copy from above , see first line on how to do it


}
