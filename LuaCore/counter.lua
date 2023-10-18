local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


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
---@class counter
local counter = {}

gen.versionFunctions(counter,versionNumber,fileModified,"LuaCore".."\\".."counter.lua")

local counterState = "counterState not linked"

-- This is a list of all the counters that have been defined
-- so their values can be set in the data module
-- counterList[i] = {key = key,moduleName = moduleName}
local counterList = {}


-- the module name for counters if moduleName is not specified
-- moduleName allows the use of flags in other modules or libraries
-- without worrying about name conflicts
local defaultModuleName = "events.lua"
local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        counterState = tableInStateTable
    else
        error("linkState: linkState takes a table as an argument.")
    end
end
counter.linkState = linkState

discreteEvents.linkStateToModules(function (state, stateTableKeys)
    local keyName = "counterTable"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    -- link the state table to the module
    state[keyName] = state[keyName] or {}
    linkState(state[keyName])
end)

local function transferCounterInfo()
    for _,keyInfo in pairs(counterList) do
        local key = keyInfo.key
        local moduleName = keyInfo.moduleName or defaultModuleName
        local value = counterState[key]
        if value ~= nil then
            data.counterSetValue(keyInfo.key,value,keyInfo.moduleName)
        end
    end
end
discreteEvents.onScenarioLoaded(transferCounterInfo)

--Defines a counter with a given key and initial value.
--It is recommended to use data.defineCounter instead.
---@deprecated
---@param key string
---@param initialValue number
---@param moduleName? string
function counter.define(key, initialValue, moduleName)
    if type(initialValue) ~= "number" then
        error("A counter in the counter module must have a number as an initial value.")
    end
    if type(key) ~= "string" then
        error("The counter module only allows strings for counter names.  Consider using the function tostring to make the conversion if necessary.")
    end
    if moduleName then
        data.defineModuleCounter(moduleName,key,initialValue,nil,nil,"none","never",nil,true)
    else
        data.defineCounter(key,initialValue,nil,nil,"none","never",nil,true)
    end
    counterList[#counterList+1] = {key = key,moduleName = moduleName}
end


---Returns the value of the counter associated with `key` and `moduleName`.
---It is recommended to use data.counterGetValue instead.
---@deprecated
---@param key string
---@param moduleName? string
---@return number
function counter.value(key,moduleName)
    return data.counterGetValue(key,moduleName)
end

---Adds `increment` to the counter associated with `key` and `moduleName`.
---Returns the new value of the counter.
---It is recommended to use data.counterAdd instead.
---@deprecated
---@param key string
---@param increment number
---@param moduleName? string
---@return number
function counter.add(key,increment,moduleName)
    return data.counterAdd(key,increment,nil,nil,moduleName)
end

---Subtracts `increment` from the counter associated with `key` and `moduleName`.
---Returns the new value of the counter.
---It is recommended to use data.counterSubtract instead.
---@deprecated
---@param key string
---@param increment number
---@param moduleName? string
---@return number
function counter.subtract(key,increment,moduleName)
    return data.counterSubtract(key,increment,nil,nil,moduleName)
end

---Sets the value of the counter associated with `key` and `moduleName` to `value`.
---Returns the new value of the counter.
---It is recommended to use data.counterSetValue instead.
---@deprecated
---@param key string
---@param value number
---@param moduleName? string
---@return number
function counter.setValue(key,value,moduleName)
    return data.counterSetValue(key,value,moduleName)
end

---Considers the counter associated with `key` and `moduleName`.
---If the counter is less than `minValue`, the counter is set to `minValue`.
---Otherwise, the counter remains unchanged.
---Returns the new value of the counter.
---It is recommended to use data.counterSetWithin instead.
---@deprecated
---@param key string
---@param minValue number
---@param moduleName? string
---@return number
function counter.setAtLeast(key,minValue,moduleName)
    return data.counterSetWithin(key,minValue,nil,moduleName)
end

---Considers the counter associated with `key` and `moduleName`.
---If the counter is less than 0, the counter is set to 0.
---Otherwise, the counter remains unchanged.
---Returns the new value of the counter.
---It is recommended to use data.counterSetWithin instead.
---@deprecated
---@param key string
---@param moduleName string
---@return number
function counter.setAtLeastZero(key,moduleName)
    return data.counterSetWithin(key,0,nil,moduleName)
end

---Considers the counter associated with `key` and `moduleName`.
---If the counter is greater than `maxValue`, the counter is set to `maxValue`.
---Otherwise, the counter remains unchanged.
---Returns the new value of the counter.
---It is recommended to use data.counterSetWithin instead.
---@deprecated
---@param key string
---@param maxValue number
---@param moduleName? string
---@return number
function counter.setAtMost(key,maxValue,moduleName)
    return data.counterSetWithin(key,nil,maxValue,moduleName)
end

---Considers the counter associated with `key` and `moduleName`.
---If the counter is greater than 0, the counter is set to 0.
---Otherwise, the counter remains unchanged.
---Returns the new value of the counter.
---It is recommended to use data.counterSetWithin instead.
---@deprecated
---@param key string
---@param moduleName? string
---@return number
function counter.setAtMostZero(key,moduleName)
    return data.counterSetWithin(key,nil,0,moduleName)
end

---Considers the counter associated with `key` and `moduleName`.
---If the counter is less than `minValue`, the counter is set to `minValue`.
---If the counter is greater than `maxValue`, the counter is set to `maxValue`.
---Otherwise, the counter remains unchanged.
---Returns the new value of the counter.
---It is recommended to use data.counterSetWithin instead.
---@deprecated
---@param key string
---@param minValue number
---@param maxValue number
---@param moduleName? string
---@return number
function counter.setWithin(key,minValue,maxValue,moduleName)
    return data.counterSetWithin(key,minValue,maxValue,moduleName)
end

---Returns true if the counter associated with `key` and `moduleName` is exactly 0.
---Returns false otherwise.
---@deprecated
---@param key string
---@param moduleName? string
---@return boolean
function counter.isZero(key,moduleName)
    return data.counterGetValue(key,moduleName) == 0
end

---Returns true if the counter associated with `key` and `moduleName` is greater than or equal to zero.
---Returns false otherwise.
---It is recommended to use data.counterIsAtLeast instead.
---@deprecated
---@param key string
---@param moduleName? string
---@return boolean
function counter.isPositive(key,moduleName)
    return data.counterIsAtLeast(key, 0, moduleName)
end

---Returns true if the counter associated with `key` and `moduleName` is strictly greater than zero.
---Returns false otherwise.
---@deprecated
---@param key string
---@param moduleName? string
---@return boolean
function counter.isStrictlyPositive(key,moduleName)
    return data.counterGetValue(key,moduleName) > 0
end

---Returns true if the counter associated with `key` and `moduleName` is less than zero.
---Returns false otherwise.
---It is recommended to use data.counterIsAtMost instead.
---@deprecated
---@param key string
---@param moduleName? string
---@return boolean
function counter.isNegative(key,moduleName)
    return data.counterIsAtMost(key, 0, moduleName)
end

---Returns true if the counter associated with `key` and `moduleName` is strictly less than zero.
---Returns false otherwise.
---@deprecated
---@param key string
---@param moduleName? string
---@return boolean
function counter.isStrictlyNegative(key,moduleName)
    return data.counterGetValue(key,moduleName) < 0
end

---Returns true if the counter associated with `key` and `moduleName` is greater than or equal to `minValue`.
---Returns false otherwise.
---It is recommended to use data.counterIsAtLeast instead.
---@deprecated
---@param key string
---@param minValue number
---@param moduleName? string
---@return boolean
function counter.isAtLeast(key,minValue,moduleName)
    return data.counterIsAtLeast(key, minValue, moduleName)
end

---Returns true if the counter associated with `key` and `moduleName` is less than or equal to `maxValue`.
---Returns false otherwise.
---It is recommended to use data.counterIsAtMost instead.
---@deprecated
---@param key string
---@param maxValue number
---@param moduleName? string
---@return boolean
function counter.isAtMost(key,maxValue,moduleName)
    return data.counterIsAtMost(key, maxValue, moduleName)
end

return counter