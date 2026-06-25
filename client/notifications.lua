-- NOTIFICATIONS
RegisterNetEvent('vorp:NotifyLeft')
RegisterNetEvent('vorp:Tip')
RegisterNetEvent('vorp:NotifyTop')
RegisterNetEvent('vorp:TipRight')
RegisterNetEvent('vorp:TipBottom')
RegisterNetEvent('vorp:ShowTopNotification')
RegisterNetEvent('vorp:ShowAdvancedRightNotification')
RegisterNetEvent('vorp:ShowSimpleCenterText')
RegisterNetEvent('vorp:ShowBottomRight')
RegisterNetEvent('vorp:failmissioNotifY')
RegisterNetEvent('vorp:deadplayerNotifY')
RegisterNetEvent('vorp:updatemissioNotify')
RegisterNetEvent('vorp:warningNotify')
RegisterNetEvent('vorp:LeftRank')
RegisterNetEvent('vorp:ThreeSimpleTop')
RegisterNetEvent('vorp:OneSimpleTop')
RegisterNetEvent('vorp:LeftInteractive')

AddEventHandler('vorp:NotifyLeft', function(firsttext, secondtext, dict, icon, duration, color)
    VorpNotification:NotifyLeft(tostring(firsttext), tostring(secondtext), tostring(dict), tostring(icon), tonumber(duration), (tostring(color) or "COLOR_WHITE"))
end)

AddEventHandler('vorp:Tip', function(text, duration)
    VorpNotification:NotifyTip(tostring(text), tonumber(duration))
end)

AddEventHandler('vorp:NotifyTop', function(text, location, duration)
    VorpNotification:NotifyTop(tostring(text), tostring(location), tonumber(duration))
end)

AddEventHandler('vorp:TipRight', function(text, duration)
    VorpNotification:NotifyRightTip(tostring(text), tonumber(duration))
end)

AddEventHandler('vorp:TipBottom', function(text, duration)
    VorpNotification:NotifyObjective(tostring(text), tonumber(duration))
end)

AddEventHandler('vorp:ShowTopNotification', function(tittle, subtitle, duration)
    VorpNotification:NotifySimpleTop(tostring(tittle), tostring(subtitle), tonumber(duration))
end)

AddEventHandler('vorp:ShowAdvancedRightNotification', function(text, dict, icon, text_color, duration, quality)
    VorpNotification:NotifyAdvanced(tostring(text), tostring(dict), tostring(icon),
        tostring(text_color), tonumber(duration), quality)
end)

AddEventHandler('vorp:ShowSimpleCenterText', function(text, duration)
    VorpNotification:NotifyCenter(tostring(text), tonumber(duration))
end)

AddEventHandler('vorp:ShowBottomRight', function(text, duration)
    VorpNotification:NotifyBottomRight(tostring(text), tonumber(duration))
end)

AddEventHandler('vorp:failmissioNotifY', function(title, subtitle, duration)
    VorpNotification:NotifyFail(tostring(title), tostring(subtitle), tonumber(duration))
end)

AddEventHandler('vorp:deadplayerNotifY', function(title, audioRef, audioName, duration)
    VorpNotification:NotifyDead(tostring(title), tostring(audioRef), tostring(audioName), tonumber(duration))
end)

AddEventHandler('vorp:updatemissioNotify', function(utitle, umsg, duration)
    VorpNotification:NotifyUpdate(tostring(utitle), tostring(umsg), tonumber(duration))
end)

AddEventHandler('vorp:warningNotify', function(title, msg, audioRef, audioName, duration)
    VorpNotification:NotifyWarning(tostring(title), tostring(msg), tostring(audioRef), tostring(audioName),
        tonumber(duration))
end)

AddEventHandler('vorp:LeftRank', function(title, subtitle, dict, icon, duration, color)
    VorpNotification:NotifyLeftRank(tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tonumber(duration), (tostring(color)))
end)

AddEventHandler('vorp:ThreeSimpleTop', function(title, subtitle, secondary_subtitle, duration)
    VorpNotification:NotifyThreeSimpleTop(tostring(title), tostring(subtitle), tostring(secondary_subtitle), tonumber(duration))
end)

AddEventHandler('vorp:OneSimpleTop', function(title, duration)
    VorpNotification:NotifyOneSimpleTop(tostring(title), tonumber(duration))
end)

AddEventHandler('vorp:LeftInteractive', function(title, description, description_2, dict, texture, soundDict, soundName, duration, color)
    VorpNotification:NotifyLeftInteractive(tostring(title), tostring(description), tostring(description_2), tostring(dict), tostring(texture), tostring(soundDict), tostring(soundName), tonumber(duration), tostring(color))
end)
