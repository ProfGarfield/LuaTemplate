
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

--[[ This module provides a configuration menu to the player, so they can change scenario settings.  The scenario designer can then refer to this module to get the setting values.
--]]

local gen = require("generalLibrary")
local text = require("text")
---@module "data"
local data = require("data"):minVersion(2)
local discreteEvents = require("discreteEventsRegistrar")


---@class configuration
local configuration = {}

local moduleName = "configurationModule"
gen.versionFunctions(configuration, versionNumber, fileModified, "LuaCore\\configuration.lua")

local function valueSpecIntIndexTable(table)
    for key,_ in pairs(table) do
        if not gen.isInteger(key) then
            return "The key "..tostring(key).." is not an integer >= 1."
        end
        if key < 1 then
            return "The key "..tostring(key).." is not an integer >= 1."
        end
    end
    return true
end

local function valueSpecIntIndexStringValueTable(table)
    for key,value in pairs(table) do
        if not gen.isInteger(key) then
            return "The key "..tostring(key).." is not an integer >= 1."
        end
        if key < 1 then
            return "The key "..tostring(key).." is not an integer >= 1."
        end
        if type(value) ~= "string" then
            return "The value "..tostring(value).." is not a string."
        end
    end
    return true
end

local settingSpecKeys = {
    name = {["string"] = true},
    nameInMenu = {["string"] = true},
    placement = {["number"] = {integer=true}},
    values = {["table"] = {valueSpecIntIndexTable,"Table with integer keys starting at 1."}},
    valueNames = {["table"] = {valueSpecIntIndexStringValueTable,"Table with integer keys starting at 1 and string values."}},
    defaultIndex = {["number"] = {minVal=1,integer=true}},
    changeFunction = {["function"] = "function(newValue, oldValue,tribeID,settingSpec)"}
}

local defaultSpecKeys = {
    valueNames = {},
    changeFunction = function(newValue,oldValue,tribeID,settingSpec) end
}

local newSettingSpec, isSettingSpec, sSpedMT = gen.createDataType("settingSpec", settingSpecKeys,{},defaultSpecKeys,{},{})

local function makeSettingSpecMenu(settingSpec)
    local menuGenerator = {}
    local settingName = settingSpec.name
    for index,value in pairs(settingSpec.values) do
        local menuOptionTable = {}
        menuOptionTable.choice = {index = index, settingName = settingSpec.name}
        menuOptionTable.optionName = settingSpec.valueNames[index] or tostring(settingSpec.values[index])
        menuGenerator[index] = menuOptionTable
    end
    menuGenerator[0] = {optionName = "Change Different Setting", nextMenu = 1}
    local menuText = function(callingArgument,history)
        return "Choose a new value for "..settingSpec.nameInMenu..".\n^Current Value: "..tostring(configuration.getSettingValueName(settingName))
    end
    local menu = text.newMenuRecord({menuGenerator = menuGenerator,  menuText = menuText, canCancel = true})
    return menu
end


local configurationMenuGenerator = {}

local settingSpecTable = {}
-- settingSpec is a table with the following fields
--      name: the name of the setting (string)
--      nameInMenu: the name of the setting as it appears in the menu (string)
--      placement: the placement of the setting in the menu (integer)
--      values: a table of the possible values for the setting
--          The table should be indexed with integers starting at 1
--      valueNames: a table of the names of the possible values for the setting
--          The table should be indexed with integers starting at 1, 
--          with the names corresponding to the values of the same 
--          index in the values table.  Any omitted valueNames will 
--          be replaced with the value from the values table after 
--          applying the tostring function.
--      defaultIndex: the index of the default value for the setting
--      changeFunction: a function that is called when the setting 
--          is changed.  If absent, no function is called.
--          The function will be called with the following parameters:
--          function(newValue, oldValue,tribeID,settingSpec)
--          
---@param settingSpec table
function configuration.defineSetting(settingSpec)
    settingSpec = newSettingSpec(settingSpec)
    if settingSpecTable[settingSpec.name] then
        error("The setting "..settingSpec.name.." has already been defined.")
    end
    settingSpecTable[settingSpec.name] = settingSpec
    for i=1,gen.c.maxTribeID do
        data.defineModuleCounter(moduleName,settingSpec.name..tostring(i), settingSpec.defaultIndex)
    end
    local settingMenu = makeSettingSpecMenu(settingSpec)
    if configurationMenuGenerator[settingSpec.placement] then
        error("The placement "..settingSpec.placement.." has already been used.")
    end
    configurationMenuGenerator[settingSpec.placement] = { nextMenu = settingMenu, optionName = settingSpec.nameInMenu}
end


---Returns the current value of settingName
---By default, it returns the value for the player's tribe. (That is, the tribe of the human player returned by civ.getPlayerTribe().)
---An optional parameter tribeID can be used to get the value for a different tribe.
---@param settingName string
---@param tribeID? integer  The tribeID of the tribe whose setting value you want to get.  If omitted, the player's tribeID is used.
---@return any
function configuration.getSettingValue(settingName,tribeID)
    tribeID = tribeID or civ.getPlayerTribe().id
    local playerTribeID = tostring(tribeID)
    local settingSpec = settingSpecTable[settingName]
    if not settingSpec then
        error("configuration.getSettingValue: The setting "..settingName.." has not been defined.")
    end
    local valueIndex = data.counterGetValue(settingName..playerTribeID, moduleName)
    return settingSpec.values[valueIndex]
end

---Returns the name of the current value of settingName
---By default, it returns the value for the player's tribe. (That is, the tribe of the human player returned by civ.getPlayerTribe().)
---An optional parameter tribeID can be used to get the value for a different tribe.
---@param settingName string
---@param tribeID? integer  The tribeID of the tribe whose setting value you want to get.  If omitted, the player's tribeID is used.
---@return any
function configuration.getSettingValueName(settingName,tribeID)
    tribeID = tribeID or civ.getPlayerTribe().id
    local playerTribeID = tostring(tribeID)
    local settingSpec = settingSpecTable[settingName]
    if not settingSpec then
        error("configuration.getSettingValue: The setting "..settingName.." has not been defined.")
    end
    local valueIndex = data.counterGetValue(settingName..playerTribeID, moduleName)
    return settingSpec.valueNames[valueIndex] or tostring(settingSpec.values[valueIndex])
end

---Sets the index of the value for the setting `settingName` for the tribe with `tribeID` to `valueIndex`
---If `suppressChangeFunction` is true, the changeFunction for the setting will not be called.
---@param settingName string
---@param tribeID integer
---@param valueIndex integer
---@param suppressChangeFunction? boolean
function configuration.setSettingIndex(settingName,tribeID,valueIndex,suppressChangeFunction)
    local playerTribeID = tostring(tribeID)
    local settingSpec = settingSpecTable[settingName]
    if not settingSpec then
        error("configuration.getSettingValue: The setting "..settingName.." has not been defined.")
    end
    local oldValue = configuration.getSettingValue(settingName,tribeID)
    data.counterSetValue(settingName..playerTribeID, valueIndex, moduleName)
    if not suppressChangeFunction and settingSpec.changeFunction then
        settingSpec.changeFunction(configuration.getSettingValue(settingName, tribeID),oldValue,tribeID,settingSpec)
    end
end

---Sets the value of `settingName` for the tribe with `tribeID` to `value`
---If `suppressChangeFunction` is true, the changeFunction for the setting will not be called.
---@param settingName string
---@param tribeID integer
---@param value any
---@param suppressChangeFunction? boolean
function configuration.setSettingValue(settingName,tribeID,value,suppressChangeFunction)
    local settingSpec = settingSpecTable[settingName]
    if not settingSpec then
        error("configuration.getSettingValue: The setting "..settingName.." has not been defined.")
    end
    local valueIndex = nil
    for index,possibleValue in pairs(settingSpec.values) do
        if possibleValue == value then
            valueIndex = index
            break
        end
    end
    if not valueIndex then
        error("configuration.setSettingValue: The value "..tostring(value).." is not a valid value for the setting "..settingName..".")
    end
    configuration.setSettingIndex(settingName,tribeID,valueIndex,suppressChangeFunction)
end


local configurationMenu = text.newMenuRecord({menuGenerator = configurationMenuGenerator,  menuText = "Choose a setting to change:", canCancel = true})

--[[
    -- with changeFunction, this can now be in configurationSettings.lua
configuration.defineSetting({
    name = "linesPerTextBox",
    nameInMenu = "Lines Per Text Box",
    placement = 0,
    values = {8,10,12,14,16,18,20,25,30,35,40,45,50,55,60},
    defaultIndex = 3,
    changeFunction = function(newValue,oldValue,tribeID,settingSpec)
        text.setLinesPerWindow(newValue)
        local lineDisplayText = ""
        for i = 2, newValue do
            lineDisplayText = lineDisplayText.."\n^"..tostring(i)
        end

        text.simple("The number of lines per text box has been changed from "..tostring(oldValue).." to "..tostring(newValue).."."..lineDisplayText)
    end
})
--]]

---Opens the configuration menu, so that the player can change settings.
function configuration.openConfigurationMenu()
    local output = configurationMenu()
    if not output then
        return
    end
    local selectionIndex = output.index
    local settingName = output.settingName
    configuration.setSettingIndex(settingName,civ.getPlayerTribe().id,selectionIndex)
end

discreteEvents.onScenarioLoaded(function()
    text.setLinesPerWindow(configuration.getSettingValue("linesPerTextBox"))
end)

console.setSettingValue = configuration.setSettingValue



return configuration