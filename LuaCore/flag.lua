--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- Provides flag functionality to a scenario or other module
-- When using this flag functionality in other modules
-- (which is to say when you are not writing scenario specific events),
-- use the optional parameter moduleName with a string (the name of the module is suggested)
--
--
-- usage
-- For each flag that you will need, have a line in your event code 
-- flag.define("myFlagKey",initialBool) or flag.define("myFlagKey",initialBool,"moduleName")
-- if your flag is used in a module to be redistributed

-- If you use this code as part of the Lua Scenario Template, it will be automatically linked
-- to the state table.  Otherwise, you will need to link as described below

-- The following code must be in two places:
-- The body of code where everything is defined
-- The function run when a scenario is loaded (civ.scen.onLoad)
-- state.myFlagTableKey = state.myFlagTableKey or {} -- Note that any key name could be used here
-- flag.linkState(state.myFlagTableKey)
-- flag.initializeFlags

-- 
local flagState = "flagState not linked"
-- the module name for flags if moduleName is not specified
-- moduleName allows the use of flags in other modules or libraries
-- without worrying about name conflicts
local defaultModuleName = "events.lua"

-- a table of flag keys and their initialized values
local initializeFlagList = {}

-- table of flag functions to be returned with the module
local flag = {}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(flag,versionNumber,fileModified,"LuaCore".."\\".."flag.lua")

local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        flagState = tableInStateTable
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
        local keyName = "flagTable"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        linkState(state[keyName])
        flag.initializeFlags()
    end
end

-- This allows for object.js to be built
flag.eventsKeyList = {}

flag.linkState = linkState

-- Specifies a key for a flag, and that flag's initial value.
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function define(key,initialValue,moduleName)
    if type(initialValue) ~= "boolean" then
        error("A flag in the flag module must have an initial value of true or false.")
    end
    if type(key) ~= "string" then
        error("The flag module only allows strings for flag names.  Consider using the function tostring to make the conversion if necessary.")
    end
    -- log key for object.js if no module is specified
    if not moduleName then
        flag.eventsKeyList[#flag.eventsKeyList+1] = key
    end
    -- the moduleName is prefixed to prevent conflicts in different modules
    -- define is only meant to be used in actual scenarios, not in library modules
    moduleName = moduleName or defaultModuleName
    -- if this key hasn't been used for a flag yet, then
    if initializeFlagList[moduleName..key] == nil then
        initializeFlagList[moduleName..key] = initialValue
    else
        error("The key "..tostring(key).." has already been used for a flag.")
    end
end
flag.define = define

-- makes sure all flags are in the state table
-- if a flag is not in the state table, it is inserted
-- and initialized to the correct value
local function initializeFlags()
    if type(flagState) == "string" and flagState == "flagState not linked" then
        error("Use the function linkState before trying to initialize flags")
    end
    for key,initialValue in pairs(initializeFlagList) do
        if flagState[key] == nil then
            flagState[key] = initialValue
        end
    end
end
flag.initializeFlags = initializeFlags

-- returns the current state (i.e. true or false) of the flag with the key
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function value(key,moduleName)
    moduleName = moduleName or defaultModuleName
    if flagState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your flag definitions and "..
        "that the initializeFlags function has been executed.")
    end
    return flagState[moduleName..key]
end
flag.value = value
-- sets the flag's value to true
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setTrue(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if flagState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your flag definitions and "..
        "that the initializeFlags function has been executed.")
    else
        flagState[moduleName..key] = true
    end
end
flag.setTrue = setTrue
-- sets the flag's value to false
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function setFalse(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if flagState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your flag definitions and "..
        "that the initializeFlags function has been executed.")
    else
        flagState[moduleName..key] = false
    end
end
flag.setFalse = setFalse
-- changes the flag's value from true to false or false to true
-- optional parameter moduleName prevents name conflicts if
-- flags are used in a module or library
local function toggle(key,moduleName)
    moduleName=moduleName or defaultModuleName
    if flagState[moduleName..key] == nil then
        error("The key "..key.." has not been initialized.  Check your flag definitions and "..
        "that the initializeFlags function has been executed.")
    else
        flagState[moduleName..key] = not(flagState[moduleName..key])
    end
end
flag.toggle = toggle

if rawget(_G,"console") then
    _G["console"].flag = flag
end
return flag
