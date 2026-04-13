---@class CORE_CLIENT
---@field public instancePlayers fun(set:boolean)
------------------------------- should not use these, use the lib instead --------------------------------------------------------------
---@field public AddWebhook fun(title:string, webhook:string, description:string, color:string, name:string, logo:string?, footerlogo:string?, avatar:string?)
---@field public NotifyTip fun(text:string, duration:number)
---@field public NotifyLeft fun(title:string, subtitle:string, dict:string, icon:string, duration:number, color:string)
---@field public NotifyRightTip fun(text:string, duration:number)
---@field public NotifyObjective fun(text:string, duration:number)
---@field public NotifyTop fun(text:string, location:string, duration:number)
---@field public NotifySimpleTop fun(text:string, subtitle:string, duration:number)
---@field public NotifyAvanced fun(text:string, dict:string, icon:string, text_color:string, duration:number, quality:number, showquality:boolean)
---@field public NotifyBasicTop fun(text:string, duration:number)
---@field public NotifyCenter fun(text:string, duration:number, text_color:string)
---@field public NotifyBottomRight fun(text:string, duration:number)
---@field public NotifyFail fun(text:string, subtitle:string, duration:number)
---@field public NotifyDead fun(title:string, audioRef:string, audioName:string, duration:number)
---@field public NotifyUpdate fun(title:string, subtitle:string, duration:number)
---@field public NotifyWarning fun(title:string, msg:string, audioRef:string, audioName:string, duration:number)
---@field public NotifyLeftRank fun(title:string, subtitle:string, dict:string, icon:string, duration:number, color:string)
-----------------------------------------------------------------------------------------------------------------------------------------
---@field public Graphics.ScreenResolution fun():{width:number, height:number}
---@field public Register fun(name:string, callback:function)
---@field public TriggerAsync fun(name:string, callback:function, ...:any?)
---@field public TriggerAwait fun(name:string, ...:any?):any
local CoreFunctions = {}

CoreFunctions.RpcCall = function(name, callback, ...)
    ClientRPC.Callback.TriggerAsync(name, callback, ...)
end

CoreFunctions.instancePlayers = function(set)
    TriggerServerEvent("vorp_core:instanceplayers", set)
end

CoreFunctions.AddWebhook = function()
    print("client side webhook has been removed please use server side")
end

CoreFunctions.NotifyTip = function(text, duration)
    VorpNotification:NotifyTip(tostring(text), tonumber(duration))
end

CoreFunctions.NotifyLeft = function(title, subtitle, dict, icon, duration, color)
    VorpNotification:NotifyLeft(tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tonumber(duration), tostring(color or "COLOR_WHITE"))
end

CoreFunctions.NotifyRightTip = function(text, duration)
    VorpNotification:NotifyRightTip(tostring(text), tonumber(duration))
end

CoreFunctions.NotifyObjective = function(text, duration)
    TriggerEvent('vorp:TipBottom', text, duration) -- listner
    -- VorpNotification:NotifyObjective(tostring(text), tonumber(duration))
end

CoreFunctions.NotifyTop = function(text, location, duration)
    VorpNotification:NotifyTop(tostring(text), tostring(location), tonumber(duration))
end

CoreFunctions.NotifySimpleTop = function(text, subtitle, duration)
    VorpNotification:NotifySimpleTop(tostring(text), tostring(subtitle), tonumber(duration))
end

CoreFunctions.NotifyAvanced = function(text, dict, icon, text_color, duration, quality, showquality)
    VorpNotification:NotifyAvanced(tostring(text), tostring(dict), tostring(icon), tostring(text_color), tonumber(duration), quality, showquality)
end

CoreFunctions.NotifyBasicTop = function(text, duration)
    VorpNotification:NotifyBasicTop(tostring(text), tonumber(duration))
end

CoreFunctions.NotifyCenter = function(text, duration, text_color)
    VorpNotification:NotifyCenter(tostring(text), tonumber(duration), tostring(text_color))
end

CoreFunctions.NotifyBottomRight = function(text, duration)
    VorpNotification:NotifyBottomRight(tostring(text), tonumber(duration))
end

CoreFunctions.NotifyFail = function(text, subtitle, duration)
    VorpNotification:NotifyFail(tostring(text), tostring(subtitle), tonumber(duration))
end

CoreFunctions.NotifyDead = function(title, audioRef, audioName, duration)
    VorpNotification:NotifyDead(tostring(title), tostring(audioRef), tostring(audioName), tonumber(duration))
end

CoreFunctions.NotifyUpdate = function(title, subtitle, duration)
    VorpNotification:NotifyUpdate(tostring(title), tostring(subtitle), tonumber(duration))
end

CoreFunctions.NotifyWarning = function(title, msg, audioRef, audioName, duration)
    VorpNotification:NotifyWarning(tostring(title), tostring(msg), tostring(audioRef), tostring(audioName), tonumber(duration))
end

CoreFunctions.NotifyLeftRank = function(title, subtitle, dict, icon, duration, color)
    VorpNotification:NotifyLeftRank(tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tonumber(duration), tostring(color or "COLOR_WHITE"))
end

CoreFunctions.NotifyThreeSimpleTop = function(title, subtitle, secondary_subtitle, duration)
    VorpNotification:NotifyThreeSimpleTop(tostring(title), tostring(subtitle), tostring(secondary_subtitle), tonumber(duration))
end

CoreFunctions.NotifyOneSimpleTop = function(title, duration)
    VorpNotification:NotifyOneSimpleTop(tostring(title), tonumber(duration))
end

CoreFunctions.NotifyLeftInteractive = function(title, description, description_2, dict, texture, soundDict, soundName, duration, color)
    VorpNotification:NotifyLeftInteractive(tostring(title), tostring(description), tostring(description_2), tostring(dict), tostring(texture), tostring(soundDict), tostring(soundName), tonumber(duration), tostring(color))
end

CoreFunctions.Graphics = {
    ---@return {width:number, height:number}
    ScreenResolution = function()
        local width, height = GetCurrentScreenResolution()
        return { width = width, height = height }
    end
}

CoreFunctions.Callback = {
    --- register a client callback to be triggered by the server
    ---@param name string
    ---@param callback function
    Register = function(name, callback)
        ClientRPC.Callback.Register(name, callback)
    end,
    --- asynchronous callback
    ---@param name string callback name
    ---@param callback function callback function
    ---@param ... any callback arguments if any
    TriggerAsync = function(name, callback, ...)
        ClientRPC.Callback.TriggerAsync(name, callback, ...)
    end,
    --- synchronous callback
    ---@param name string callback name
    ---@param ... any callback arguments if any
    ---@return any callback return value if more than one send as a table
    TriggerAwait = function(name, ...)
        return ClientRPC.Callback.TriggerAwait(name, ...)
    end
}

exports('GetCore', function()
    return CoreFunctions
end)

--- use exports
---@deprecated
AddEventHandler('getCore', function(cb)
    return cb(CoreFunctions)
end)
