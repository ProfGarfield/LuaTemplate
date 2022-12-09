-- This script automatically constructs a new updateInfo.lua file
-- You don't need this script unless you have taken over
-- responsibility for updating the Lua Scenario Template

-- This script gathers the version number of all the files in this table,
-- and recommends the current versions of the file.
-- To change the minimum version of a file, change the value associated
-- with it in this table:

-- files[fileName] = minVersion
-- file name is what is required to require the file
-- usually, this will be the name of the file, without .lua
-- sometimes, you may need to prepend the directory as well
-- if minVersion is a number, that is the minimum version
-- if minVersion is false, there is no minimum version.
-- if minVersion is true, there is no recommended version or minimum version
--
require("discreteEventsRegistrar"):minVersion(2)
local files = {
    ["aStarCiv"] = false,
    ["attackBonus"] = false,
    ["calendar"] = false,
    ["canBuild"] = false,
    ["characterTable"] = true,
    ["cityData"] = false,
    ["civilopedia"] = false,
    ["combatCalculator"] = false,
    ["consolidator"] = false,
    ["context"] = false,
    ["counter"] = false,
    ["delayedAction"] = false,
    ["diplomacy"] = false,
    ["discreteEventsRegistrar"] = false,
    ["flag"] = false,
    ["functions"] = true,
    ["generalLibrary"] = false,
    ["helpkey"] = false,
    ["legacyEventBuilder"] = false,
    ["legacyEventEngine"] = false,
    ["log"] = false,
    ["munitions"] = false,
    ["navy"] = false,
    ["promotion"] = false,
    ["radar"] = 2,
    ["reactionBase"] = false,
    ["readRules"] = false,
    ["rules"] = false,
    ["strategicTargets"] = false,
    ["supplementalData"] = false,
    ["text"] = false,
    ["tileData"] = false,
    ["traits"] = false,
    ["unitData"] = false,
    ["attackBonusSettings"] = false,
    ["calculateCityYield"] = false,
    ["canBuildSettings"] = false,
    ["combatSettings"] = 2,
    ["diplomacySettings"] = false,
    ["helpKeySettings"] = false,
    ["keyPressSettings"] = false,
    ["logSettings"] = false,
    ["munitionsSettings"] = false,
    ["navySettings"] = false,
    ["onGetFormattedDate"] = false,
    ["onUseNuclearWeapon"] = false,
    ["promotionSettings"] = false,
    ["radarSettings"] = false,
    ["rushBuySettings"] = false,
    ["simpleSettings"] = false,
    ["targetSettings"] = false,
    ["customMusicIntegration"] = false,
    ["parameters"] = false,
    ["consolidatedEvents"] = false,
    ["discreteEvents"] = false,
    ["combatModifiers"] = false,
    ["registerCombatModifiers"] = false,
    ["registerFiles"]=false,
}

local outputString = [==[

-- This file keeps tracks of the current recommended versions of files
-- If you have the most recent version of this file, you can run it
-- using CTRL+SHIFT+F4, and it will print to the console all the
-- Lua Scenario Template files that are out of date
--
-- Any file which has had an actual bugfix will cause an error with
-- using minVersion instead of recommendedVersion


local gen = require("generalLibrary"):minVersion(1):recommendedVersion(1)
local text = require("text"):minVersion(1):recommendedVersion(1)

civ.ui.text("Welcome to the Update Help Tool for the Lua Scenario Template.")

local choice = text.menu({"No. Tell me how.","Yes."},"Have you updated Scripts\\updateInfo.lua?")

if choice == 1 then
    text.simple("Step 1:\n^Save a copy of your scenario's directory just in case.")
    civ.ui.text("Step 2:","^Download the most recent version of the Lua Scenario Template.")
    
    civ.ui.text("Step 3:","^Copy the Scripts\\updateInfo.lua file into the scripts folder of your scenario, replacing the existing file.")
    text.simple("Step 4:\n^Run this script again, choosing Yes.")
    return
end

text.simple("This file will check all of the Lua Scenario Template files.  Any files which have had known bug fixes since your version will generate an error in the console.  It is recommended that you replace the relevant file from the new LST folder to your scenario.   Comment out the relevant line in Scripts\\updateInfo.lua if you want to suppress the error.")

text.simple("If a file is either new, or has had a feature update, a message will be printed to the console telling you about that file.  If you have changed the file and altered the fileModified line at the top of that file to true, the message will warn you that you've made changes, and you should take care when updating.  If in doubt, ask for help.")

text.simple("Upon updating a file, you may find that errors are generated when you restart your game.  This will be because the file you changed relies on a more recent version of a module than you currently have.  Replace any such files (watching for warnings that you've changed files)")

local function checkFile(fileName,recVer,minVer)
    local fileFound, modulePrefix = gen.requireIfAvailable(fileName)
    if not fileFound then
        print(fileName.." is an available file, which is not in your scenario.\n")
        return
    end
    if minVer then
        modulePrefix:minVersion(minVer):recommendedVersion(recVer)
        return
    end
    if recVer then
        modulePrefix:recommendedVersion(recVer)
        return
    end
end

print("Beginning Check")

]==]

for fileName,minValue in pairs(files) do
    if minValue == true then
        outputString = outputString.."checkFile('"..fileName.."')\n"
    elseif minValue == false then
        outputString = outputString.."checkFile('"..fileName.."',"..tostring(require(fileName).getVersion)..")\n"
    else
        outputString = outputString.."checkFile('"..fileName.."',"..tostring(require(fileName).getVersion)..","..tostring(minValue)..")\n"
    end
end

outputString = outputString..'print("\\nCheck Complete\\n")'

local gen = require("generalLibrary"):minVersion(1)
local fileLocation = gen.getScenarioDirectory().."\\Scripts".."\\"..tostring(os.time()).."updateInfo.lua"

local file = io.open(fileLocation,"a")
io.output(file)
io.write(outputString)
io.close(file)
print("Update Info file written to "..fileLocation)
