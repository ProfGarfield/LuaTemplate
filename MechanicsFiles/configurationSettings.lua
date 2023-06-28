local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

local gen = require("generalLibrary")
local text = require("text")
local configuration = require("configuration")

--[[ In this file, you can define settings for your scenario.  The settings can be changed by the player in a menu, and the scenario designer can refer to the settings to determine how the scenario should be run.  For example, you could have a setting for whether the game should display the combat power of units at the start of combat.]]

-- A settingSpec is a table with the following fields
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
--          If absent, the items in the values will just be converted to strings
--      defaultIndex: the index of the default value for the setting

-- Define a setting by calling configuration.defineSetting(settingSpec)

-- Example: 

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
-- Note that valueNames is omitted in this example.  The default valueNames are the values converted to strings.

-- Another Example:
configuration.defineSetting({
    name = "displayCombatPower",
    nameInMenu = "Display Combat Power",
    placement = 3,
    values = {true,false},
    valueNames = {"On","Off"},
    defaultIndex = 2,
})
--]]

-- The Scenario Designer can access the values of the settings by calling
-- configuration.getSettingValue(settingName,tribeID)
-- where settingName is the name of the setting and tribeID is the 
-- tribeID of the tribe whose setting value you want to get.  
-- If you omit tribeID, the current player's tribeID is used.  
-- (I.e. the result of civ.getPlayerTribe() is used.)
-- e.g. 
-- configuration.getSettingValue("displayCombatPower") 
-- or
-- configuration.getSettingValue("displayCombatPower",object.pSomeTribe.id)

-- The Scenario Designer can also set the value of a setting by calling
-- configuration.setSettingValue(settingName,tribeID,value)
-- where settingName is the name of the setting, tribeID is the
-- tribeID of the tribe whose setting value you want to set, and
-- value is the value you want to set it to.
-- This can be useful if you want to change the value of a setting
-- during an information menu, for example.  Also, if you want to
-- use a setting for a "policy" that the player can change during
-- the game, you can use this function to change the value of the
-- setting for AI tribes.



local configSettings = {}
gen.versionFunctions(configSettings,versionNumber, fileModified, "MechanicsFiles/configurationSettings.lua")

return configSettings