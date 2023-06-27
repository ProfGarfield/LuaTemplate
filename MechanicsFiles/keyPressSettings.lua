
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file






local gen = require("generalLibrary"):minVersion(1)
local function optionalRequire(fileName)
    local fileFound,prefix = gen.requireIfAvailable(fileName)
    if fileFound then
        return prefix
    else
        print("WARNING: keyPressSettings.lua: could not find the file "..fileName..".  Any key press functionality provided by that file is not available.")
        local emptyTable = {}
        local emptyMetatable = {__index = function(tbl,key) return function() end end}
        setmetatable(emptyTable,emptyMetatable)
        return emptyTable
    end
end
local object = require("object")
local keyboard = require("keyboard")
local helpKeySettingsFound, helpKeySettings = gen.requireIfAvailable("helpKeySettings")
--local helpKeySettings = optionalRequire("helpKeySettings")
local munitionsSettingsFound, munitionsSettings = gen.requireIfAvailable("munitionsSettings")
--local munitionsSettings = optionalRequire("munitionsSettings")
local logSettingsFound,logSettings = gen.requireIfAvailable("logSettings")
--local logSettings = require("logSettings")
local simpleSettingsFound, simpleSettings = gen.requireIfAvailable("simpleSettings")
local diplomacySettingsFound, diplomacySettings = gen.requireIfAvailable("diplomacySettings")
--local diplomacySettings = optionalRequire("diplomacySettings")
local textFound, text = gen.requireIfAvailable("text")
--local text = optionalRequire("text")
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
local configuration = require("configuration")


-- key press events can be registered here using the discreteEvents
-- (You can register multiple key press effects by using elseif
-- in your keycode checks.  Key press events can also be registered
-- in the consolidated events and in onKeyPress.lua


if textFound then
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.one then
            text.openArchive()
        end
    end
else
    print("WARNING: text.lua not found.  Archived messages not available with keypress 1")
end

if diplomacySettingsFound then
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.two then
            diplomacySettings.diplomacyMenu()
        end
    end
else
    print("WARNING: diplomacySettings.lua not found.  Gifting options not available with keypress 2")
end

if munitionsSettingsFound then
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.k and civ.getActiveUnit() then
            munitionsSettings.primaryAttack(civ.getActiveUnit())
        end
    end
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.u and civ.getActiveUnit() then
            munitionsSettings.secondaryAttack(civ.getActiveUnit())
        end
    end
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.h and civ.getActiveUnit() then
            munitionsSettings.keyPressPayloadRestrictionCheck(civ.getActiveUnit())
        end
    end
else
    print("WARNING: munitionsSettings.lua not found.  Keys k and u will not generate munitions")
end

if helpKeySettingsFound then
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.tab then
            helpKeySettings.doHelpKey() 
        end
    end
else
    print("WARNING: helpKeySettings.lua not found.  Tab will not display help messages.")
end

if logSettingsFound then
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.escape then
            return logSettings.combatReportFunction()
        end
    end
else
    print("WARNING: logSettings.lua not found.  Escape will not produce a combat log.")
end

if simpleSettings then
    function discreteEvents.onKeyPress(keyCode)
        if keyCode == keyboard.w and simpleSettings.enableCustomUnitSelection then
            gen.betterUnitManualWait()
        end
    end
end

discreteEvents.onKeyPress(function(keyCode)
    if keyCode == keyboard.zero then
        configuration.openConfigurationMenu()
    end
end)


--[[some testing code, can be removed
local keyboardToMarkerType = {}

keyboardToMarkerType[keyboard.one]="irrigation"
keyboardToMarkerType[keyboard.two]="mine"
keyboardToMarkerType[keyboard.three]="farmland"
keyboardToMarkerType[keyboard.four]="road"
keyboardToMarkerType[keyboard.five]="railroad"
keyboardToMarkerType[keyboard.six]="fortress"
keyboardToMarkerType[keyboard.seven]="airbase"
keyboardToMarkerType[keyboard.eight]="pollution"
keyboardToMarkerType[keyboard.nine]="transporter"
keyboardToMarkerType[keyboard.zero]="testNotMarker"
        
function discreteEvents.onKeyPress(keyCode)
    local markerType = keyboardToMarkerType[keyCode]
    if not markerType then
        return
    end
    if gen.hasMarker(civ.getCurrentTile(),civ.getCurrentTribe(),markerType) then
        gen.removeMarker(civ.getCurrentTile(),civ.getCurrentTribe(),markerType)
    else
        gen.placeMarker(civ.getCurrentTile(),civ.getCurrentTribe(),markerType)
    end
end

--]]
local versionTable = {}

gen.versionFunctions(versionTable,versionNumber,fileModified,"MechanicsFiles".."\\".."keyPressSettings.lua")

return versionTable
