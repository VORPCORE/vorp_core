---@class ServerRPC
---@field name string callback name
---@field _callback fun(source: number, cb: fun(data: any), ...) callback function
---@field uniqueId string callback unique id
ServerRPC = {}
ServerRPC.Callback = {}
ServerRPC.__index = ServerRPC
ServerRPC.__call = function()
    return 'ServerRPC'
end

function ServerRPC:New(name, callback)
    self = setmetatable({}, ServerRPC)
    self.name = name
    self._callback = callback
    self.uniqueId = ""
    return self
end

function ServerRPC:Trigger(_source, uniqueId, isSync, ...)
    if not self._callback then
        return error("Callback " .. self.name .. " does not exist. Make sure it's registered in the server side.", 1)
    end

    self._callback(_source, function(...)
        TriggerClientEvent("vorp:ServerCallback", _source, uniqueId, isSync, self.name, ...)
    end, ...)
end

local RegisteredCalls = {}

RegisterNetEvent("vorp:TriggerServerCallback", function(name, uniqueId, isSync, ...)
    local _source = source

    if not RegisteredCalls[name] then
        return error("Callback " .. name .. " hasn't been registered.", 1)
    end

    RegisteredCalls[name]:Trigger(_source, uniqueId, isSync, ...)
end)

--- Register a new Rpc callback
---@param name string callback name
---@param callback fun(source: number, cb: fun(...), ...) callback function
function ServerRPC.Callback.Register(name, callback)
    if name == nil or type(name) ~= "string" then
        return error("Parameter \"name\" must be a string!", 1)
    end
    RegisteredCalls[name] = ServerRPC:New(name, callback)
end

--- * Trigger a callback Asynchronously
---@param source number player source
---@param name string callback name
---@param callback fun(...) callback function
---@param ... any callback parameters tables strings numbers etc
function ServerRPC.Callback.TriggerAsync(name, source, callback, ...)
    local trigger = ServerRPC:New(name, callback)
    trigger:TriggerRpcAsync(source, ...)
end

--- * Trigger a callback Synchronously
---@param source number player source
---@param name string callback name
---@param ... any callback parameters tables strings numbers etc
---@return any callback return
function ServerRPC.Callback.TriggerAwait(name, source, ...)
    local trigger = ServerRPC:New(name, nil)
    return trigger:TriggerRpcAwait(source, ...)
end

-- * TRIGGER CLIENT CALLBACKS HANDLER
local TriggeredCalls = {}

--- Generates an unpredictable per-call identifier so pending responses cannot be
--- guessed or forged by third-party clients (previously a shared sequential counter).
local function GenerateUniqueId(name)
    local uniqueId
    repeat
        uniqueId = ("%s_%d_%d"):format(name, math.random(100000, 999999), math.random(1000000000, 2147483647))
    until not TriggeredCalls[uniqueId]
    return uniqueId
end

function ServerRPC:TriggerRpcAsync(source, ...)
    if not self.name and type(self.name) ~= "string" then
        return error("Callback name must be a string!", 1)
    end

    if not source and type(source) ~= "number" then
        return error("Callback source must exist and be a number!", 1)
    end

    self.uniqueId = GenerateUniqueId(self.name)

    TriggerClientEvent("vorp:TriggerServerCallback", source, self.name, self.uniqueId, false, ...)

    -- Bind the pending response to the player it was sent to.
    TriggeredCalls[self.uniqueId] = { src = source, callback = self._callback }
end

function ServerRPC:TriggerRpcAwait(source, ...)
    if not self.name and type(self.name) ~= "string" then
        return error("Callback name must be a string!", 1)
    end

    self.uniqueId = GenerateUniqueId(self.name)
    TriggerClientEvent("vorp:TriggerServerCallback", source, self.name, self.uniqueId, true, ...)

    local promise = promise.new()
    -- Bind the pending response to the player it was sent to.
    TriggeredCalls[self.uniqueId] = { src = source, promise = promise }

    local result = Citizen.Await(promise)
    return result
end

function ServerRPC.ExecuteRpc(uniqueId, isSync, name, ...)
    local _source = source
    local pending = TriggeredCalls[uniqueId]
    if not pending then
        return error("ERROR: No callback with this id found! callback name: " .. name, 1)
    end

    -- Only the player the request was sent to may answer it.
    if _source ~= pending.src then
        return error("ERROR: Callback response source mismatch! callback name: " .. name, 1)
    end

    if isSync then
        if pending.promise then
            pending.promise:resolve(...)
        end
    elseif pending.callback then
        pending.callback(...)
    end
    TriggeredCalls[uniqueId] = nil
end

RegisterNetEvent('vorp:ServerCallback', ServerRPC.ExecuteRpc)


-- Export
exports("ServerRpcCall", function()
    return ServerRPC
end)

-- backwards compatibility
RegisterNetEvent("vorp:addNewCallBack", ServerRPC.Callback.Register)
