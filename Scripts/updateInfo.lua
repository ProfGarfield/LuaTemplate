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

checkFile("aStarCiv",1)
checkFile("attackBonus",1)
checkFile("calendar",1)
checkFile("canBuild",2)
checkFile("characterTable")
checkFile("cityData",1)
checkFile("civilopedia",1)
checkFile("combatCalculator",1)
checkFile("consolidator",1)
checkFile("context",1)
checkFile("counter",1)
checkFile("delayedAction",1)
checkFile("diplomacy",1)
checkFile("discreteEventsRegistrar",1)
checkFile("flag",1)
checkFile("functions")
checkFile("generalLibrary",1)
checkFile("helpkey",1)
checkFile("legacyEventBuilder",1)
checkFile("legacyEventEngine",1)
checkFile("log",1)
checkFile("munitions",1)
checkFile("navy",1)
checkFile("promotion",1)
checkFile("radar",1)
checkFile("reactionBase",1)
checkFile("readRules",1)
checkFile("rules",1)
checkFile("strategicTargets",1)
checkFile("supplementalData",1)
checkFile("text",1)
checkFile("tileData",1)
checkFile("traits",1)
checkFile("unitData",1)


checkFile("attackBonusSettings",1)
checkFile("calculateCityYield",1)
checkFile("canBuildSettings",1)
checkFile("combatSettings",1)
checkFile("diplomacySettings",1)
checkFile("helpKeySettings",1)
checkFile("keyPressSettings",1)
checkFile("logSettings",1)
checkFile("munitionsSettings",1)
checkFile("navySettings",1)
checkFile("onGetFormattedDate",1)
checkFile("onUseNuclearWeapon",1)
checkFile("promotionSettings",1)
checkFile("radarSettings",1)
checkFile("rushBuySettings",1)
checkFile("simpleSettings",1)
checkFile("targetSettings",1)

checkFile("customMusicIntegration",1)
checkFile("parameters",1)


checkFile("consolidatedEvents.lua",1)
checkFile("discreteEvents.lua",1)

