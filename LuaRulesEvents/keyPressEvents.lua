local gen = require("generalLibrary")
local object = require("object")
local keyboard = require("keyboard")
local helpKeySettings = require("helpKeySettings")
local munitionsSettings = require("munitionsSettings")
local logSettings = require("logSettings")
local simpleSettings = require("simpleSettings")
local diplomacySettings = require("diplomacySettings")
local text = require("text")
local consolidated = require("consolidatedEvents")




local keyPressFunctions = {}



-- Save the instructions for each key press as a function
-- in the table keyPressFunctions, indexed by keyID
-- (This system means that there doesn't have to be a giant
-- list of if statements to check every time a key is pressed
-- use the function generalKeyPress if it doesn't make sense
-- to split the function into individual keys


keyPressFunctions[keyboard.zero] = function()

end

keyPressFunctions[keyboard.one] = function()
    text.openArchive()
end
keyPressFunctions[keyboard.two] = function()
    diplomacySettings.diplomacyMenu()
end
keyPressFunctions[keyboard.three] = function()

end
keyPressFunctions[keyboard.four] = function()

end
keyPressFunctions[keyboard.five] = function()

end
keyPressFunctions[keyboard.six] = function()

end
keyPressFunctions[keyboard.seven] = function()

end
keyPressFunctions[keyboard.eight] = function()

end
keyPressFunctions[keyboard.nine] = function()

end
keyPressFunctions[keyboard.k] = function()
    if civ.getActiveUnit() then
        munitionsSettings.primaryAttack(civ.getActiveUnit())
    end
end
keyPressFunctions[keyboard.u] = function()
    if civ.getActiveUnit() then
        munitionsSettings.secondaryAttack(civ.getActiveUnit())
    end
end
keyPressFunctions[keyboard.h] = function()
    if civ.getActiveUnit() then
        civ.sleep(100)
        munitionsSettings.payloadRestrictionCheck(civ.getActiveUnit())
    end
end
keyPressFunctions[keyboard.tab] = function()
   helpKeySettings.doHelpKey() 
end
keyPressFunctions[keyboard.escape] = function()
    return logSettings.combatReportFunction()
end
keyPressFunctions[keyboard.backspace] = function()

end
keyPressFunctions[keyboard.w] = function()
    if simpleSettings.enableCustomUnitSelection then
        gen.betterUnitManualWait()
    end
end

-- Use this if it makes sense to group several keys
-- into a single event
local function generalKeyPress(keyID)

end

local function doKeyPress(keyID)
    if keyPressFunctions[keyID] then
        keyPressFunctions[keyID]()
    end
    consolidated.onKeyPress(keyID)
    generalKeyPress(keyID)
end

return {doKeyPress = doKeyPress}
