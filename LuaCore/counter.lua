--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- Provides counter functionality to a scenario or other module
-- When using this counter functionality in other modules
-- (which is to say when you are not writing scenario specific events),
-- use the optional parameter moduleName with a string (the name of the module is suggested)
--
--
-- usage
-- local counter = require("counter")
-- For each counter that you will need, have a line in your event code 
-- counter.define("myCounterKey",initialVal) or counter.define("myCounterKey",initialVal,"moduleName")
-- if your counter is used in a module to be redistributed.  moduleName is an optional parameter
-- to be used in stand alone modules.


-- If this is used in the Lua Scenario Template, this module will automatically be linked to the state table
-- otherwise,
-- The following code must be in two places:
-- The body of code where everything is defined
-- The function run when a scenario is loaded (civ.scen.onLoad)
-- state.myCounterTableKey = state.myCounterTableKey or {} -- Note that any key name could be used here
-- counter.linkState(state.myCounterTableKey)
-- counter.initializeCounters()

--  Function List
-- counter.value(key)--> number
-- counter.add(key,increment)--> number
-- counter.subtract(key,increment)--> number
-- counter.setValue(key,value)--> number
-- counter.setAtLeast(key,minValue)--> number
-- counter.setAtLeastZero(key)--> number
-- counter.setAtMost(key,maxValue)--> number
-- counter.setAtMostZero(key)--> number
-- counter.setWithin(key,minValue,maxValue)-->number
-- counter.isZero(key)-->bool
-- counter.isPositive(key)-->bool
-- counter.isStrictlyPositive(key)-->bool
-- counter.isNegative(key)-->bool
-- counter.isStrictlyNegative(key)-->bool
-- counter.isAtLeast(key,minVal)--> bool
-- counter.isAtMost(key,maxVal)--> bool
-- 
--
--
--
--
--
local counterState = "counterState not linked"

-- the module name for counters if moduleName is not specified
-- moduleName allows the use of flags in other modules or libraries
-- without worrying about name conflicts
local defaultModuleName = "events.lua"

-- a table of counter keys and their initialized values
local initializeCounterList = {}

-- table of counter functions to be returned with the module
local gen = require("generalLibrary"):minVersion(1)
local counter = {}
gen.versionFunctions(counter,versionNumber,fileModified,"LuaCore".."\\".."counter.lua")

local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        counterState = tableInStateTable
    else
        error("linkState: linkState takes a table as an argument.")
    end
end


-- requireIfAvailable(fileName) --> fileFound (bool), prefix (whatever is returned by a successful require, or nil)
local function requireIfAvailable(fileName)
    if package.loaded[fileName] then
        return true, require(fileName)
    else
        for _,searcher in ipairs(package.searchers) do
            local loader = searcher(fileName)
            if type(loader) == 'function' then
                return true, require(fileName)
            end
        end
        return false, nil
    end
end

local fileFound, discreteEvents = requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "counterTable"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        linkState(state[keyName])
        counter.initializeCounters()
    end
end



-- this allows for object.js to be built
counter.eventsKeyList = {}

counter.linkState = linkState

-- Specifies a key for a counter, and that counter's initial value.
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function define(key,initialValue,moduleName)
    if type(initialValue) ~= "number" then
        error("A counter in the counter module must have a number as an initial value.")
    end
    if type(key) ~= "string" then
        error("The counter module only allows strings for counter names.  Consider using the function tostring to make the conversion if necessary.")
    end
    -- log key for object.js if no module is specified
    if not moduleName then
        counter.eventsKeyList[#counter.eventsKeyList+1] = key
    end
    -- the moduleName is prefixed to prevent conflicts in different modules
    -- define is only meant to be used in actual scenarios, not in library modules
    moduleName = moduleName or defaultModuleName
    -- if this key hasn't been used for a flag yet, then
    if initializeCounterList[moduleName..key] == nil then
        initializeCounterList[moduleName..key] = initialValue
    else
        error("The key "..tostring(key).." has already been used for a flag.")
    end
end
counter.define = define

-- makes sure all counters are in the state table
-- if a counter is not in the state table, it is inserted
-- and initialized to the correct value
local function initializeCounters()
    if type(counterState) == "string" and counterState == "counterState not linked" then
        error("Use the function linkState before trying to initialize counters")
    end
    for key,initialValue in pairs(initializeCounterList) do
        if counterState[key] == nil then
            counterState[key] = initialValue
        end
    end
end
counter.initializeCounters = initializeCounters

-- value(key,moduleName)--> number
-- returns the current numerical value of the counter with the key
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function value(key,moduleName)
    moduleName = moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounterss function has been executed.")
    end
    return counterState[moduleName..key]
end
counter.value = value

-- add(key,increment,moduleName)--> number
-- adds to the counter's current value
-- returns the new value of the counter
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function add(key,increment,moduleName)
    if type(increment) ~= "number" then
        error("The increment for counter.add must be a number.  Key is "..key..".")
    end
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        counterState[moduleName..key] = increment + counterState[moduleName..key] 
    end
    return counterState[moduleName..key]
end
counter.add = add

-- subtract(key,increment,moduleName)--> number
-- subtracts from the counter's current value
-- returns the new value of the counter
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function subtract(key,increment,moduleName)
    if type(increment) ~= "number" then
        error("The increment for counter.subtract must be a number.  Key is "..key..".")
    end
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        counterState[moduleName..key] =  counterState[moduleName..key] - increment  
    end
    return counterState[moduleName..key]
end
counter.subtract = subtract

-- setValue(key,value,moduleName)--> number
-- changes the value of the counter to the number specified
-- returns the new value of the counter
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setValue(key,value,moduleName)
    if type(value) ~= "number" then
        error("The value for counter.setValue must be a number.  Key is "..key..".")
    end
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        counterState[moduleName..key] = value
    end
    return counterState[moduleName..key]
end
counter.setValue = setValue


-- setAtLeast(key,minValue,moduleName)--> number
-- if counter value is less than minValue, counter value is set to minValue
-- otherwise, counter value remains unchanged
-- new value of the counter is returned
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setAtLeast(key,minValue,moduleName)
    if type(minValue) ~= "number" then
        error("The minValue for counter.setAtLeast must be a number.  Key is "..key..".")
    end
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        counterState[moduleName..key] = math.max(counterState[moduleName..key],minValue)
    end
    return counterState[moduleName..key]
end
counter.setAtLeast = setAtLeast

-- setAtLeastZero(key,moduleName)--> number
-- if counter value is less than 0, counter value is set to 0
-- otherwise, counter value remains unchanged
-- new value of the counter is returned
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setAtLeastZero(key,moduleName)
    return setAtLeast(key,0,moduleName)
end
counter.setAtLeastZero = setAtLeastZero

-- setAtMost(key,maxValue,moduleName)--> number
-- if counter value is more than maxValue, counter value is set to maxValue
-- otherwise, counter value remains unchanged
-- new value of the counter is returned
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setAtMost(key,maxValue,moduleName)
    if type(maxValue) ~= "number" then
        error("The maxValue for counter.setAtMost must be a number.  Key is "..key..".")
    end
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        counterState[moduleName..key] = math.min(counterState[moduleName..key],maxValue)
    end
    return counterState[moduleName..key]
end
counter.setAtMost = setAtMost


-- setAtMostZero(key,moduleName)--> number
-- if counter value is more than 0, counter value is set to 0
-- otherwise, counter value remains unchanged
-- new value of the counter is returned
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setAtMostZero(key,moduleName)
    return setAtMost(key,0,moduleName)
end
counter.setAtMostZero = setAtMostZero

-- setWithin(key,minValue,maxValue,moduleName)-->number
-- if counter value is less than minValue, set counter to minValue
-- if counter value is more than maxValue, set counter to maxValue
-- otherwise, counterValue remains unchanged
-- new value of the counter is returned
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setWithin(key,minValue,maxValue,moduleName)
    if type(minValue) ~= "number" then
        error("The minValue for counter.setWithin must be a number.  Key is "..key..".")
    end
    if type(maxValue) ~= "number" then
        error("The maxValue for counter.setWithin must be a number.  Key is "..key..".")
    end
    if minValue > maxValue then
        error("The minValue for counter.setWithin must be less than the maxValue.  Key is "..key..".")
    end
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        counterState[moduleName..key] = math.min(counterState[moduleName..key],maxValue)
        counterState[moduleName..key] = math.max(counterState[moduleName..key],minValue)
    end
    return counterState[moduleName..key]
end


-- isZero(key,moduleName)-->bool
-- returns true if the value of the counter is exactly 0
-- returns false otherwise
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function isZero(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        return counterState[moduleName..key] == 0
    end
end
counter.isZero = isZero

-- isPositive(key,moduleName)-->bool
-- returns true if the value of the counter is at least 0
-- returns false otherwise
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function isPositive(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        return counterState[moduleName..key] >= 0
    end
end
counter.isPositive = isPositive


-- isStrictlyPositive(key,moduleName)-->bool
-- returns true if the value of the counter is strictly greater than 0
-- returns false otherwise
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function isStrictlyPositive(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        return counterState[moduleName..key] > 0
    end
end
counter.isStrictlyPositive = isStrictlyPositive

-- isNegative(key,moduleName)-->bool
-- returns true if the value of the counter is at least 0
-- returns false otherwise
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function isNegative(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        return counterState[moduleName..key] <= 0
    end
end
counter.isNegative = isNegative


-- isStrictlyNegative(key,moduleName)-->bool
-- returns true if the value of the counter is strictly greater than 0
-- returns false otherwise
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function isStrictlyNegative(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        return counterState[moduleName..key] < 0
    end
end
counter.isStrictlyNegative = isStrictlyNegative

-- isAtLeast(key,minVal,moduleName)--> bool
-- returns true if the value of the counter is at least minVal
-- returns false otherwise
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function isAtLeast(key,minVal,moduleName)
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        return counterState[moduleName..key] >= minVal
    end
end
counter.isAtLeast = isAtLeast

-- isAtMost(key,maxVal,moduleName)--> bool
-- returns true if the value of the counter is at most maxVal
-- returns false otherwise
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function isAtMost(key,maxVal,moduleName)
    moduleName=moduleName or defaultModuleName
    if counterState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your counter definitions and "..
        "that the initializeCounters function has been executed.")
    else
        return counterState[moduleName..key] <= maxVal
    end
end
counter.isAtMost = isAtMost

if rawget(_G,"console") then
    _G["console"].counter = counter
end

return counter
