
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

-- This file provides an alternative to the data module, in order
-- to maintain backwards compatibility.  It is recommended to
-- use the data module instead.

---@module "data"
local data = require("data"):minVersion(2)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
local discreteEvents = require("discreteEventsRegistrar")

--[[
The functions in this module provide an alternative way to access
the data module.  The data module is recommended for new scenarios,
but this module is provided for backwards compatibility.
]]
---@class flag
local flag = {}

gen.versionFunctions(flag,versionNumber,fileModified,"LuaCore".."\\".."flag.lua")


local flagState = "flagState not linked"



-- This is a list of all the flags that have been defined
-- so their values can be set in the data module
-- flagList[i] = {key = key,moduleName = moduleName}
local flagList = {}

local defaultModuleName = "events.lua"

local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        flagState = tableInStateTable
    else
        error("linkState: linkState takes a table as an argument.")
    end
end
flag.linkState = linkState

discreteEvents.linkStateToModules(function (state, stateTableKeys)
    local keyName = "flagTable"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    -- link the state table to the module
    state[keyName] = state[keyName] or {}
    linkState(state[keyName])
end)

local function transferFlagInfo()
    for _,keyInfo in pairs(flagList) do
        local key = keyInfo.key
        local moduleName = keyInfo.moduleName
        moduleName = moduleName or defaultModuleName
        local value = flagState[moduleName..key]
        if type(value) == "boolean" then
            print(moduleName,key,value,keyInfo.moduleName)
            data.flagSetValue(keyInfo.key,value,keyInfo.moduleName)
            print(data.flagIsNil(keyInfo.key,keyInfo.modName),data.flagGetValue(keyInfo.key,keyInfo.moduleName))
            flagState[moduleName..key] = nil
        end
    end
end
discreteEvents.onScenarioLoaded(transferFlagInfo)


---Defines a flag with the given key and initial value.
---It is recommended to use data.defineFlag instead.
---@deprecated
---@param key string
---@param initialValue boolean
---@param moduleName? string
function flag.define(key,initialValue,moduleName)
    if type(initialValue) ~= "boolean" then
        error("A flag in the flag module must have an initial value of true or false.")
    end
    if type(key) ~= "string" then
        error("The flag module only allows strings for flag names.  Consider using the function tostring to make the conversion if necessary.")
    end
    if moduleName then
        data.defineModuleFlag(moduleName,key,initialValue)
    else
        data.defineFlag(key,initialValue)
    end
    flagList[#flagList+1] = {key = key,moduleName = moduleName}
end

---Returns the value of the flag associated with `key` and `moduleName`.
---@deprecated
---@param key string
---@param moduleName? string
---@return boolean
function flag.value(key,moduleName)
    return data.flagGetValue(key,moduleName)
end


---Sets the value of the flag associated with `key` and `moduleName` to true.
---@deprecated
---@param key string
---@param moduleName? string
function flag.setTrue(key,moduleName)
    data.flagSetValue(key,true,moduleName)
end

---Sets the value of the flag associated with `key` and `moduleName` to false.
---@deprecated
---@param key string
---@param moduleName? string
function flag.setFalse(key,moduleName)
    data.flagSetValue(key,false,moduleName)
end

---Changes the flag associated with `key` and `moduleName` to the opposite of its current value.
---@deprecated
---@param key string
---@param moduleName? string
function flag.toggle(key,moduleName)
    data.flagSetValue(key,not data.flagGetValue(key,moduleName),moduleName)
end


return flag