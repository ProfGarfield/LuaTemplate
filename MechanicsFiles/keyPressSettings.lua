local function optionalRequire(fileName)
    local fileFound,prefix = pcall(require,fileName)
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




local gen = require("generalLibrary")
local object = require("object")
local keyboard = require("keyboard")
local helpKeySettingsFound, helpKeySettings = pcall(require,"helpKeySettings")
--local helpKeySettings = optionalRequire("helpKeySettings")
local munitionsSettingsFound, munitionsSettings = pcall(require,"munitionsSettings")
--local munitionsSettings = optionalRequire("munitionsSettings")
local logSettingsFound,logSettings = pcall(require,"logSettings")
--local logSettings = require("logSettings")
local simpleSettingsFound, simpleSettings = pcall(require,"simpleSettings")
local diplomacySettingsFound, diplomacySettings = pcall(require,"diplomacySettings")
--local diplomacySettings = optionalRequire("diplomacySettings")
local textFound, text = pcall(require,"text")
--local text = optionalRequire("text")
local discreteEvents = require("discreteEventsRegistrar")


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


