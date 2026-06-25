---VorpNotifications can be used to display notifications on the screen. You can reference this file in your resource manifest to ensure the VorpNotifications API resource is started before your own resource.
---VorpNotifications is a singleton class that should be accessed using the global variable VorpNotifications.

---@class VorpNotifications
---@field public NotifyLeft fun(title: string, subtitle: string, dict: string, icon: string, duration?: number, color?: string): nil
---@field public NotifyTip fun(tipMessage: string, duration?: number): nil
---@field public NotifyTop fun(message: string, location: string, duration?: number): nil
---@field public NotifyRightTip fun(tipMessage: string, duration?: number): nil
---@field public NotifyObjective fun(message: string, duration?: number): nil
---@field public NotifySimpleTop fun(tittle: string, duration?: number): nil
---@field public NotifyAdvanced fun(text: string, dict: string, icon: string, text_color: string, duration?: number, quality?: number, showquality?: boolean): nil
---@field public NotifyCenter fun(text: string, duration?: number, text_color?: string): nil
---@field public NotifyBottomRight fun(text: string, duration?: number): nil
---@field public NotifyFail fun(title: string, subtitle: string, duration?: number): nil
---@field public NotifyDead fun(title: string, audioRef: string, audioName: string, duration?: number): nil
---@field public NotifyUpdate fun(title: string, message: string, duration?: number): nil
---@field public NotifyWarning fun(title: string, message: string, audioRef: string, audioName: string, duration?: number): nil
---@field public NotifyLeftRank fun(title: string, subtitle: string, dict: string, texture: string, duration?: number, color?: string): nil

local T = Translation[Lang].MessageOfSystem

VorpNotification = setmetatable({}, VorpNotification)
VorpNotification.__index = VorpNotification
VorpNotification.__call = function()
  return 'VorpNotifications'
end


---NotifyLeft
---@param title string
---@param subtitle string
---@param dict string
---@param icon string
---@param duration? number -- default 3000
---@param color? string -- default COLOR_WHITE
function VorpNotification:NotifyLeft(title, subtitle, dict, icon, duration, color)
  CoreAction.Utils.LoadTexture(dict)

  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
  local structData = DataView.ArrayBuffer(8 * 8)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", subtitle)))
  structData:SetInt32(8 * 3, 0)
  structData:SetInt64(8 * 4, CoreAction.Utils.bigInt(joaat(dict)))
  structData:SetInt64(8 * 5, CoreAction.Utils.bigInt(joaat(icon)))
  structData:SetInt64(8 * 6, CoreAction.Utils.bigInt(joaat(color or "COLOR_WHITE")))

  Citizen.InvokeNative(0x26E87218390E6729, structConfig:Buffer(), structData:Buffer(), 1, 1)
  -- SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED
  Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict)
end

---NotifyTip
---@param tipMessage string
---@param duration? number -- default 3000
function VorpNotification:NotifyTip(tipMessage, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
  structConfig:SetInt32(8 * 1, 0)
  structConfig:SetInt32(8 * 2, 0)
  structConfig:SetInt32(8 * 3, 0)

  local structData = DataView.ArrayBuffer(8 * 3)
  structData:SetUint64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", tipMessage)))

  Citizen.InvokeNative(0x049D5C615BD38BAD, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyTop
---@param message string
---@param location string
---@param duration? number -- default 3000
function VorpNotification:NotifyTop(message, location, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 5)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", location)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", message)))

  Citizen.InvokeNative(0xD05590C1AB38F068, structConfig:Buffer(), structData:Buffer(), 0, 1)
end

---NotifyRightTip
---@param tipMessage string
---@param duration? number -- default 3000
function VorpNotification:NotifyRightTip(tipMessage, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 3)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", tipMessage)))

  Citizen.InvokeNative(0xB2920B9760F0F36B, structConfig:Buffer(), structData:Buffer(), 1)
end

---DisplayObjective
---@param message string
---@param duration? number -- default 3000
function VorpNotification:NotifyObjective(message, duration)
  Citizen.InvokeNative(0xDD1232B332CBB9E7, 3, 1, 0)

  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 3)
  local strMessage = VarString(10, "LITERAL_STRING", message)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(strMessage))

  Citizen.InvokeNative(0xCEDBF17EFCC0E4A4, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyTwoSimpleTop
---@param title string
---@param subtitle string
---@param duration? number -- default 3000
function VorpNotification:NotifySimpleTop(title, subtitle, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 7)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", subtitle)))

  Citizen.InvokeNative(0xA6F4216AB10EB08E, structConfig:Buffer(), structData:Buffer(), 1, 1)
end

---NotifyThreeSimpleTop
---@param title string
---@param subtitle string
---@param secondary_subtitle string
---@param duration? number -- default 3000
function VorpNotification:NotifyThreeSimpleTop(title, subtitle, secondary_subtitle, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 7)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", subtitle)))
  structData:SetInt64(8 * 3, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", secondary_subtitle)))

  Citizen.InvokeNative(0x02BCC0FE9EBA3529, structConfig:Buffer(), structData:Buffer(), true, true, true)
end

---NotifyOneSimpleTop
---@param title string
---@param duration? number -- default 3000
function VorpNotification:NotifyOneSimpleTop(title, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 7)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))

  Citizen.InvokeNative(0x860DDFE97CC94DF0, structConfig:Buffer(), structData:Buffer(), true)
end

---NotifyAvanced
---@param text string
---@param dict string
---@param icon string
---@param text_color string
---@param duration? number -- default 3000
---@param quality? number -- default 1
---@param showquality? boolean -- default false
function VorpNotification:NotifyAdvanced(text, dict, icon, text_color, duration, quality, showquality)
  CoreAction.Utils.LoadTexture(dict)

  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
  structConfig:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", "Transaction_Feed_Sounds")))
  structConfig:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", "Transaction_Positive")))

  local structData = DataView.ArrayBuffer(8 * 10)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", text)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", dict)))
  structData:SetInt64(8 * 3, CoreAction.Utils.bigInt(joaat(icon)))
  --structData:SetInt64(8 * 4, 100) --bounce amount dont seem to work it would be for money
  structData:SetInt64(8 * 5, CoreAction.Utils.bigInt(joaat(text_color or "COLOR_WHITE")))
  if showquality then
    structData:SetInt32(8 * 6, quality or 1)
  end

  Citizen.InvokeNative(0xB249EBCB30DD88E0, structConfig:Buffer(), structData:Buffer(), 1)
  -- SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED
  Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict)
end

---NotifyCenter
---@param text string
---@param duration? number -- default 3000
---@param text_color? string -- default COLOR_PURE_WHITE
function VorpNotification:NotifyCenter(text, duration, text_color)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 4)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", text)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(joaat(text_color or "COLOR_PURE_WHITE")))

  Citizen.InvokeNative(0x893128CDB4B81FBB, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyBottomRight
---@param text string
---@param duration? number -- default 3000
function VorpNotification:NotifyBottomRight(text, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

  local structData = DataView.ArrayBuffer(8 * 5)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", text)))

  Citizen.InvokeNative(0x2024F4F333095FB1, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyFail
---@param title string
---@param subtitle string
---@param duration? number -- default 3000
function VorpNotification:NotifyFail(title, subtitle, duration)
  local structConfig = DataView.ArrayBuffer(8 * 5)

  local structData = DataView.ArrayBuffer(8 * 9)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", subtitle)))

  local result = Citizen.InvokeNative(0x9F2CC2439A04E7BA, structConfig:Buffer(), structData:Buffer(), 1)
  Wait(duration or 3000)
  Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyDead
---@param title string
---@param audioRef string
---@param audioName string
---@param duration? number -- default 3000
function VorpNotification:NotifyDead(title, audioRef, audioName, duration)
  local structConfig = DataView.ArrayBuffer(8 * 5)

  local structData = DataView.ArrayBuffer(8 * 9)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", audioRef)))
  structData:SetInt64(8 * 3, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", audioName)))

  local result = Citizen.InvokeNative(0x815C4065AE6E6071, structConfig:Buffer(), structData:Buffer(), 1)
  Wait(duration or 3000)
  Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyUpdate
---@param title string
---@param message string
---@param duration? number -- default 3000
function VorpNotification:NotifyUpdate(title, message, duration)
  local structConfig = DataView.ArrayBuffer(8 * 5)

  local structData = DataView.ArrayBuffer(8 * 9)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", message)))

  local result = Citizen.InvokeNative(0x339E16B41780FC35, structConfig:Buffer(), structData:Buffer(), 1)
  Wait(duration or 3000)
  Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyWarning
---@param title string
---@param message string
---@param audioRef string
---@param audioName string
---@param duration? number -- default 3000
function VorpNotification:NotifyWarning(title, message, audioRef, audioName, duration)
  local structConfig = DataView.ArrayBuffer(8 * 5)

  local structData = DataView.ArrayBuffer(8 * 9)
  structData:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  structData:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", message)))
  structData:SetInt64(8 * 3, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", audioRef)))
  structData:SetInt64(8 * 4, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", audioName)))

  local result = Citizen.InvokeNative(0x339E16B41780FC35, structConfig:Buffer(), structData:Buffer(), 1)
  Wait(duration or 3000)
  Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyLeftRank
---@param title string title of the notification
---@param subtitle string subtitle of the notification
---@param dict1 string dictionary of the texture
---@param texture string texture (icon) of the notification
---@param duration number duration of the notification
---@param color string color of the notification
function VorpNotification:NotifyLeftRank(title, subtitle, dict1, texture, duration, color)
  CoreAction.Utils.LoadTexture(dict1)
  duration = duration or 5000
  local dict = joaat(dict1 or "TOASTS_MP_GENERIC")
  local texture = joaat(texture or "toast_mp_standalone_sp")
  local string1 = VarString(10, "LITERAL_STRING", title)
  local string2 = VarString(10, "LITERAL_STRING", subtitle)

  local struct1 = DataView.ArrayBuffer(8 * 8)
  local struct2 = DataView.ArrayBuffer(8 * 10)

  struct1:SetInt32(8 * 0, duration)

  struct2:SetInt64(8 * 1, CoreAction.Utils.bigInt(string1))
  struct2:SetInt64(8 * 2, CoreAction.Utils.bigInt(string2))
  struct2:SetInt64(8 * 4, CoreAction.Utils.bigInt(dict))
  struct2:SetInt64(8 * 5, CoreAction.Utils.bigInt(texture))
  struct2:SetInt64(8 * 6, CoreAction.Utils.bigInt(joaat(color or "COLOR_WHITE")))
  struct2:SetInt32(8 * 7, 1)
  Citizen.InvokeNative(0x3F9FDDBA79117C69, struct1:Buffer(), struct2:Buffer(), 1, 1)
  -- SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED
  Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict1)
end

-- NotifyLeftInteractive
---@param title string title of the notification
---@param description string description of the notification
---@param description_2 string description_2 of the notification
---@param dict string dictionary of the texture
---@param texture string texture (icon) of the notification
---@param soundDict string description of the notification
---@param soundName string sound name
---@param duration number duration of the notification
---@param color string color of the notification
function VorpNotification:NotifyLeftInteractive(title, description, description_2, dict, texture, soundDict, soundName, duration, color)
  dict = dict and dict or "elements_stamps_icons"
  CoreAction.Utils.LoadTexture(dict)

  soundDict = soundDict and VarString(10, "LITERAL_STRING", soundDict) or 0
  soundName = soundName and VarString(10, "LITERAL_STRING", soundName) or 0

  local data = DataView.ArrayBuffer(8 * 7)
  data:SetInt32(8 * 0, CoreAction.Utils.bigInt(duration or -2)) -- -2 or -1 to always show
  -- sounds
  data:SetInt64(8 * 1, CoreAction.Utils.bigInt(soundDict))
  data:SetInt64(8 * 2, CoreAction.Utils.bigInt(soundName))

  data:SetInt32(8 * 3, CoreAction.Utils.bigInt(0)) -- unknown INPUT_FEED_INTERACT_GENERIC
  data:SetInt64(8 * 4, CoreAction.Utils.bigInt(0)) -- unknown joaat("player_menu")
  data:SetInt64(8 * 5, CoreAction.Utils.bigInt(0)) -- unknown joaat("sp_notifications")
  data:SetInt64(8 * 6, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", description_2)))

  local info = DataView.ArrayBuffer(8 * 7)
  info:SetInt32(8 * 0, CoreAction.Utils.bigInt(0)) -- unknown
  info:SetInt64(8 * 1, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", title)))
  info:SetInt64(8 * 2, CoreAction.Utils.bigInt(VarString(10, "LITERAL_STRING", description)))
  info:SetInt32(8 * 3, CoreAction.Utils.bigInt(0)) -- unknown
  info:SetInt64(8 * 4, CoreAction.Utils.bigInt(joaat(dict)))
  info:SetInt64(8 * 5, CoreAction.Utils.bigInt(joaat(texture or "stamp_cash")))
  info:SetInt32(8 * 6, CoreAction.Utils.bigInt(joaat(color or "COLOR_WHITE")))


  Citizen.InvokeNative(0x18D6869FBFFEC0F8, data:Buffer(), info:Buffer(), true, true)
  -- SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED
  Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict)
end

---Test function to test all notifications
---@return nil
function VorpNotification:Test()
  local testText = T.testText
  local testDuration = 3000
  local testWaitDuration = 4000
  local testDict = "generic_textures"
  local testIcon = "tick"
  local testColor = "COLOR_WHITE"
  local testLocation = "top_center"
  local testSoundDict = "Transaction_Feed_Sounds"
  local testSoundName = "Transaction_Positive"
  VorpNotification:NotifyLeft(testText, testText, testDict, testIcon, testDuration, testColor)
  print("^2Displaying: NotifyLeft")
  Wait(testWaitDuration)
  VorpNotification:NotifyTip(testText, testDuration)
  print("^2Displaying: NotifyTip")
  Wait(testWaitDuration)
  VorpNotification:NotifyTop(testText, testLocation, testDuration)
  print("^2Displaying: NotifyTop")
  Wait(testWaitDuration)
  VorpNotification:NotifyRightTip(testText, testDuration)
  print("^2Displaying: NotifyRightTip")
  Wait(testWaitDuration)
  VorpNotification:NotifyObjective(testText, testDuration)
  print("^2Displaying: NotifyObjective")
  Wait(testWaitDuration)
  VorpNotification:NotifySimpleTop(testText, testText, testDuration)
  print("^2Displaying: NotifySimpleTop")
  Wait(testWaitDuration)
  VorpNotification:NotifyAdvanced(testText, testDict, testIcon, testColor, testDuration, 1, false)
  print("^2Displaying: NotifyAdvanced")
  Wait(testWaitDuration)
  VorpNotification:NotifyCenter(testText, testDuration)
  print("^2Displaying: NotifyCenter")
  Wait(testWaitDuration)
  VorpNotification:NotifyBottomRight(testText, testDuration)
  print("^2Displaying: NotifyBottomRight")
  Wait(testWaitDuration)
  VorpNotification:NotifyFail(testText, testText, testDuration)
  print("^2Displaying: NotifyFail")
  Wait(testWaitDuration)
  VorpNotification:NotifyDead(testText, testDict, testIcon, testDuration)
  print("^2Displaying: NotifyDead")
  Wait(testWaitDuration)
  VorpNotification:NotifyUpdate(testText, testText, testDuration)
  print("^2Displaying: NotifyUpdate")
  Wait(testWaitDuration)
  VorpNotification:NotifyWarning(testText, testText, testDict, testIcon, testDuration)
  print("^2Displaying: NotifyWarning")
  Wait(testWaitDuration)
  VorpNotification:NotifyLeftRank(testText, testText, testDict, testIcon, testDuration, testColor)
  print("^2Displaying: NotifyLeftRank")
  Wait(testWaitDuration)
  VorpNotification:NotifyLeftInteractive(testText, testText, testText, testDict, testIcon, testSoundDict, testSoundName, testDuration, testColor)
  print("^2Displaying: NotifyLeftInteractive")
  Wait(testWaitDuration)
end
