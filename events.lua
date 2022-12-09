-- Note: this isn't actually the first version of this file.  It is just the first version that
-- I assigned a version number to.
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
local regressionNumber = 1 -- this number is incremented whenever an update to events.lua
-- removes some functionality.  This should be rare

-- some code to root out pcalls, that I wanted to replace with something requireIfAvailable
--temppcall = pcall
--pcall = function() error("remove pcall") end
-- events.lua for the
-- Lua Event Template
--
--  This code can let you find the location of rogue print statements.
--newprint = print
--print = function(...) 
--    newprint("print function in file "..debug.getinfo(2).short_src)
--    newprint("print function on line "..debug.getinfo(2).currentline)
--    newprint(...)
--end




-- note: console and global are the only globals.  If you need a variable to
-- be accessible from the console, put it in the console table, 
-- and access it via console.myVariable
-- If you want to share values between files, use global.myValue
-- (from a technical stand point, you can use either one for
-- either purpose
-- Put this before requirements, in case any required items
-- are checking if there is a console table

math.randomseed(os.time())

local TOTPPMajor = 0
local TOTPPMinor = 18
local TOTPPPatch = 4
if not totpp.version then
    local messageBox = "You are using Test of Time Patch Project version 0.15 or older.  This scenario requires TOTPP v"..TOTPPMajor.."."..TOTPPMinor.."."..TOTPPPatch.." or later.  A link to the TOTPP will be in the console error message."
    local message1 = "You are using Test of Time Patch Project version 0.15 or older.  This scenario requires TOTPP v"..TOTPPMajor.."."..TOTPPMinor.."."..TOTPPPatch.." or later.  Get the latest version of the TOTPP here:"
    local message2 = "https://forums.civfanatics.com/threads/the-test-of-time-patch-project.517282/" 
    civ.ui.text(messageBox)
    error(message1..message2)
end
if (totpp.version.major < TOTPPMajor) or 
    (totpp.version.major == TOTPPMajor and totpp.version.minor < TOTPPMinor)    or (totpp.version.major == TOTPPMajor and totpp.version.minor == TOTPPMinor
    and totpp.version.patch < TOTPPPatch)
    then
    local messageBox = "You are using Test of Time Patch Project version "..totpp.version.major.."."..totpp.version.minor.."."..totpp.version.patch..".  This scenario requires TOTPP v"..TOTPPMajor.."."..TOTPPMinor.."."..TOTPPPatch.." or later.   A link to the TOTPP will be in the console error message."
    local message1 = "You are using Test of Time Patch Project version "..totpp.version.major.."."..totpp.version.minor.."."..totpp.version.patch..".  This scenario requires TOTPP v"..TOTPPMajor.."."..TOTPPMinor.."."..TOTPPPatch.." or later.  Get the latest version of the TOTPP here: "
    local message2 = "https://forums.civfanatics.com/threads/the-test-of-time-patch-project.517282/" 
    civ.ui.text(messageBox)
    error(message1..message2)
end
_G._discreteEventsRegistrar_events_lua_versionNumber = versionNumber
_G._discreteEventsRegistrar_events_lua_fileModified = fileModified
_G._discreteEventsRegistrar_events_lua_regressionNumber = regressionNumber


console = {}
console.commands = function() print('These are keys currently stored in the console table.\n')
    for k,__ in pairs(console) do
        print('console.'..k)
    end end
_global = {}
_global.eventTesting = false -- set to true to run event civ.ui.text statements in default code
local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolder = string.gsub(eventsPath,"events.lua","")
--print(scenarioFolder)
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
--print(scenarioFolderPath)
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
    local luaCoreScenarioFolder = scenarioFolder
    -- if the name of the scenario folder has AltLuaCore in the name
    -- it doesn't look in the existing scenario folder for the luaCore, but
    -- instead looks in <ToTDir>\Template\LuaCore
    -- where <ToTDir> is your test of time directory, from civ.getToTDir()
    if string.find(string.lower(scenarioFolderPath),string.lower("AltLuaCore")) then
        luaCoreScenarioFolder = civ.getToTDir().."\\Template\\"
        print("WARNING: Your scenario folder name contaions AltLuaCore, so the Lua Console will attempt to look for Lua Core files in "..luaCoreScenarioFolder.."\\LuaCore instead of this scenario directory.")
    end
    -- this can allow you to only update one folder with new LuaCore files, and just
    -- copy the current lua core when you are actually ready to release

    package.path = scenarioFolderPath..";"..luaCoreScenarioFolder.."LuaCore\\?.lua"..
    ";"..scenarioFolder.."MechanicsFiles\\?.lua"..";"..scenarioFolder.."EventsFiles\\?.lua"
    ..";"..scenarioFolder.."LuaParameterFiles\\?.lua"
    -- comment out next line to rely only on files within the scenario folder, uncomment to access the lua folder
    --..";"..civ.getToTDir().."\\lua\\?.lua"
    -- This line allows you to give the full path (civ.getToTDir()..\\rest\\of\\path) of a module,
    -- this allows checking for the custom music patch in <TOT Dir>\lua (and perhaps other stuff)
    -- without looking in that folder for other modules
    -- this is unneeded with the new onSelectMusic event
    --..";?.lua"
    
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



local function attemptToRun(fileName,warningMessage)
    --local fileFound,prefix = pcall(require,fileName)
    local fileFound,prefix = requireIfAvailable(fileName)
    if not fileFound then
        print(warningMessage)
    end
end

-- This function allows for executing files that haven't been
-- created yet.  By naming them 'recentFeatureX.lua', they will
-- automatically be run (but only if there is also a recentFeature(X-1).lua
-- as well).  If a file is named recentFeature.lua, a text box will advise
-- the player what they should rename it.  This way, I can provide files
-- as recentFeature.lua, without worrying how many recentFeature files
-- someone already has.
local function executeRecentFeatures(fileNumber)
    fileNumber = fileNumber or 1
    local fileFound, prefix = requireIfAvailable("recentFeature"..tostring(fileNumber))
    if fileFound then
        return executeRecentFeatures(fileNumber+1)
    else
        local found, pre = requireIfAvailable("recentFeature")
        if found then
            civ.ui.text("A file named recentFeature.lua has been found.  If you want this file to be part of the Lua events for this scenario, please rename it to recentFeature"..tostring(fileNumber)..".lua .  If you don't want this file to be part of the Lua events for this scenario, change its name so something else.  (New additions to the Lua Scenario Template are often distributed with the file name recentFeature.lua, since I don't know how many recentFeatureX.lua files you already have.)")
        error("A file named recentFeature.lua has been found.  If you want this file to be part of the Lua events for this scenario, please rename it to recentFeature"..tostring(fileNumber)..".lua .  If you don't want this file to be part of the Lua events for this scenario, change its name so something else.  (New additions to the Lua Scenario Template are often distributed with the file name recentFeature.lua, since I don't know how many recentFeatureX.lua files you already have.)")
        end
        return
    end
end
        


local gen = require("generalLibrary"):minVersion(1)
gen.registerEventsLuaVersion(versionNumber,fileModified,regressionNumber)

-- noGlobal prevents new global variables from being created
-- or accessed; this should make typos easier to discover
gen.noGlobal()
gen.setScenarioDirectory(scenarioFolder)
local civlua = require("civluaModified")
--local func = require("functions")
local flag = require("flag")
--local counter = require("counter")
local text = require("text")
local canBuildFunctions = require("canBuild")
attemptToRun("canBuildSettings","WARNING: Did not find canBuildSettings.lua.  Standard production options will apply.")



attemptToRun('keyPressSettings',"WARNING: did not find keyPressSettings.lua.  You might be missing standard key press events that are registered in that file.")
--local keyPressEvents = require("keyPressSettings")
--local munitions = require("munitions")
--local munitionsSettings = require("munitionsSettings")


--local attackBonusSettings = require("attackBonusSettings")
local delayedAction = require("delayedAction"):minVersion(1)
--local eventTools = require("eventTools")
local promotion = require("promotion")
local promotionSettings = require("promotionSettings")
local simpleSettings = require("simpleSettings"):recommendedVersion(1)
--local unitActivation = require("unitActivation")
--local negotiationSettings = require("negotiationSettings")
--local onSchism = require("onSchism")
--local legacy = require("legacyEventEngine")
--local legacyEventTable = require("getLegacyEvents")
attemptToRun("getLegacyEvents","WARNING: getLegacyEvents.lua not found.  You will not have any legacy events.")
--legacy.supplyLegacyEventsTable(legacyEventTable)
--local delay = require("delayedAction")
local diplomacy = require("diplomacy")
local cityYield = require("calculateCityYield")
local combatSettings = require("combatSettings")
local setTraits = require("setTraits")
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
require("discreteEvents")
local consolidated = require("consolidatedEvents"):minVersion(1)

attemptToRun('targetSettings',"WARNING: targetSettings.lua not found.  You will not have strategic targets.")
attemptToRun('navySettings', "WARNING: navySettings.lua not found.  You will not have the navy settings from that file.")
attemptToRun('radarSettings',"WARNING: radarSettings.lua not found.  You will not have any radar tools defined in that file.")
local supplementalData = require("supplementalData"):minVersion(1)
local unitData = require("unitData"):minVersion(1)
local cityData = require("cityData"):minVersion(1)
require("registerFiles"):minVersion(1)






--local triggerEvents = require("triggerEvents")
local log = require("log")
-- this module compresses (and decompresses) the state
-- table so it is smaller in saved files
local lualzw = require("lualzw")

executeRecentFeatures()
-- If I wish to distribute an example, I can call the file
-- to run exampleFeature.lua, and it will work automatically
requireIfAvailable("exampleFeature")


local musicFolder= string.gsub(eventsPath,civ.getToTDir(),"..")
musicFolder= string.gsub(musicFolder,"events.lua","").."\\Sound"
gen.setMusicDirectory(musicFolder)



--for i=0,7 do
--    flag.define("tribe"..tostring(i).."AfterProductionNotDone",true,"eventMachinery")
--    flag.define("tribe"..tostring(i).."BeforeProductionNotDone",true,"eventMachinery")
--end

local state = {}



--local function linkStateTableToModules()
    -- link the state table to the flags module
    --state.flagTable = state.flagTable or {}
    --flag.linkState(state.flagTable)
    --flag.initializeFlags()
    -- link the state table to the counter module
    --state.counterTable = state.counterTable or {}
    --counter.linkState(state.counterTable)
    --counter.initializeCounters()
    -- link the state table to the text module
    --state.textTable = state.textTable or {}
    --text.linkState(state.textTable)
    -- link the state table to the general library
    -- state.designerState is made available through gen.getState()
    -- state.generalLibraryState is used for 'internal' general library functionality
    --state.designerState = state.designerState or {}
    --state.generalLibraryState = state.generalLibraryState or {}
    --gen.linkState(state.designerState)
    --gen.linkGeneralLibraryState(state.generalLibraryState)
    --state.logState = state.logState or {}
    --log.linkState(state.logState)
    --state.delayedAction = state.delayedAction or {}
    --delayedAction.linkState(state.delayedAction)
    --state.promotion = state.promotion or {}
    --promotion.linkState(state.promotion)
    --state.eventToolsState = state.eventToolsState or {}
    --eventTools.linkState(state.eventToolsState)
    --state.legacyState = state.legacyState or {}
    --legacy.linkState(state.legacyState)
    ----state.delayedActionState = state.delayedActionState or {} -- this was from a duplicate require
    ----delay.linkState(state.delayedActionState)
    --state.diplomacyState = state.diplomacyState or {}
    --diplomacy.linkState(state.diplomacyState)
    --state.munitionsState = state.munitionsState or {}
    --munitions.linkState(state.munitionsState)
    --state.globalState = state.globalState or {}
    --_global.state = state.globalState
    -- this table keeps track of cities that have already been processed this turn
    -- it is regularly cleared
    -- it helps govern the onCityProcessed execution point, so it only happens once per city
    --state.processedCities = state.processedCities or {}
--end



--linkStateTableToModules()

-- This table keeps track of execution points which are registered by explicit
-- code in this file.  This way, a loop through civ.scen can check for new
-- improvements to the Lua Scenario Template by simply adding files
local registeredInThisFile = {}
-- registeredInThisFile[key]=true

-- Attempts to require moduleName, and if successful, returns
-- the value at key.  If unsuccessful, returns an empty function.
-- If defaultReturnValue is specified, the empty function returns that
-- value; otherwise, it returns void
local attemptRequireResults = {}
local function attemptRequireWithKey(moduleName,key,defaultReturnValue)
    if attemptRequireResults[moduleName.."."..key] then
        return attemptRequireResults[moduleName.."."..key]
    end
    local fileFound, prefix = requireIfAvailable(moduleName)
    if fileFound then
        if type(prefix[key]) == "function" then
            attemptRequireResults[moduleName.."."..key] = prefix[key]
            return prefix[key]
        else
            print("WARNING: did not find function associated with key "..key.." in module "..moduleName..".lua.")
            if defaultReturnValue ~= nil then
                attemptRequireResults[moduleName.."."..key] = function() return defaultReturnValue end
                return function() return defaultReturnValue end
            else
                attemptRequireResults[moduleName.."."..key] = function() end
                return function() end
            end
        end
    elseif defaultReturnValue ~= nil then
        attemptRequireResults[moduleName.."."..key] = function() return defaultReturnValue end
        return function() return defaultReturnValue end
    else
        attemptRequireResults[moduleName.."."..key] = function() end
        return function() end
    end
end


local individualFileDirectory = "" --"EventsFiles\\" was unnecessary and duplicated require calls in requireIfAvailable if the same file was required without the directory name

-- the results of attemptRequireWithKey are placed here
-- this way, all the requires happen at once, so the warnings can
-- be shown to the console
local eventsFiles = {}
eventsFiles.onTurn = attemptRequireWithKey(individualFileDirectory.."onTurn","onTurn")
eventsFiles.onKeyPress = attemptRequireWithKey(individualFileDirectory.."onKeyPress","onKeyPress")
eventsFiles.onCityProduction = attemptRequireWithKey(individualFileDirectory.."onCityProduction","onCityProduction")
eventsFiles.attackBonus = attemptRequireWithKey('attackBonusSettings',"attackBonus")
eventsFiles.onActivateUnit = attemptRequireWithKey(individualFileDirectory.."onActivateUnit","onActivateUnit")
eventsFiles.onAfterProduction = attemptRequireWithKey(individualFileDirectory.."onAfterProduction","onAfterProduction")
eventsFiles.onCityProcessingComplete = attemptRequireWithKey(individualFileDirectory.."onCityProcessingComplete","onCityProcessingComplete")
eventsFiles.onUnitKilled = attemptRequireWithKey(individualFileDirectory.."onUnitKilled","onUnitKilled")
eventsFiles.onUnitDefeated = attemptRequireWithKey(individualFileDirectory.."onUnitDefeated","onUnitDefeated")
eventsFiles.onUnitDeath = attemptRequireWithKey(individualFileDirectory.."onUnitDeath","onUnitDeath")
eventsFiles.onUnitDeathOutsideCombat = attemptRequireWithKey(individualFileDirectory.."onUnitDeath","onUnitDeathOutsideCombat")
eventsFiles.onUnitDeleted = attemptRequireWithKey(individualFileDirectory.."onUnitDeath","onUnitDeleted") 
eventsFiles.onCityTaken = attemptRequireWithKey(individualFileDirectory.."onCityTaken","onCityTaken") 
eventsFiles.onCityDestroyed =  attemptRequireWithKey(individualFileDirectory.."onCityDestroyed","onCityDestroyed")
eventsFiles.onScenarioLoaded = attemptRequireWithKey(individualFileDirectory.."onScenarioLoaded","onScenarioLoaded")
eventsFiles.onNegotiation = attemptRequireWithKey(individualFileDirectory.."onNegotiation","onNegotiation",true)
eventsFiles.onSchism = attemptRequireWithKey(individualFileDirectory.."onSchism","onSchism",true)
eventsFiles.onCentauriArrival = attemptRequireWithKey(individualFileDirectory.."onCentauriArrival","onCentauriArrival")
eventsFiles.onBribeUnit = attemptRequireWithKey(individualFileDirectory.."onBribeUnit","onBribeUnit")
eventsFiles.onGameEnds = attemptRequireWithKey(individualFileDirectory.."onGameEnds","onGameEnds",true)
eventsFiles.onBeforeProduction = attemptRequireWithKey(individualFileDirectory.."onBeforeProduction","onBeforeProduction")
eventsFiles.onCityFounded = attemptRequireWithKey(individualFileDirectory.."onCityFounded","onCityFounded",function() end)
eventsFiles.onTribeTurnBegin = attemptRequireWithKey(individualFileDirectory.."onTribeTurnBegin","onTribeTurnBegin")
eventsFiles.onCityProcessed = attemptRequireWithKey(individualFileDirectory.."onCityProcessed","onCityProcessed")
eventsFiles.onTribeTurnEnd = attemptRequireWithKey(individualFileDirectory.."onTribeTurnEnd","onTribeTurnEnd")
eventsFiles.onCanFoundCity = attemptRequireWithKey(individualFileDirectory.."onCanFoundCity","onCanFoundCity",true)
eventsFiles.onEnterTile = attemptRequireWithKey(individualFileDirectory.."onEnterTile","onEnterTile")
eventsFiles.onFinalOrderGiven = attemptRequireWithKey(individualFileDirectory.."onFinalOrderGiven","onFinalOrderGiven")

local function doOnChooseSeason()
    discreteEvents.performOnChooseSeason()
end

-- this is so the "activateUnitBackstop" function
-- doesn't run at certain times, like when
-- other events are underway
local suppressActivateUnitBackstop = false
local humanUnitActive = false
local humanPlayerActive = false

local onTurnFn = function(turn)
    -- this makes doAfterProduction work
    -- not necessary with civ.scen.onCityProcessingComplete
    --for i=0,7 do
    --    flag.setTrue("tribe"..tostring(i).."AfterProductionNotDone","eventMachinery")
    --    flag.setTrue("tribe"..tostring(i).."BeforeProductionNotDone","eventMachinery")
    --end
    suppressActivateUnitBackstop = true
    supplementalData.onTurn(turn)
    doOnChooseSeason()
    discreteEvents.performOnTurn(turn)
    consolidated.onTurn(turn)
    eventsFiles.onTurn(turn)
    delayedAction.doOnTurn(turn)
    for city in civ.iterateCities() do
        if simpleSettings.cancelWeLoveTheKing[city.owner.government] then
            gen.clearWeLoveTheKing(city)
        end
    end
    suppressActivateUnitBackstop = false
end
civ.scen.onTurn(onTurnFn)
console.onTurn = function() onTurnFn(civ.getTurn()) end
registeredInThisFile["onTurn"]=true

civ.scen.onCanBuild(function(defaultBuildFunction,city,item)
    local ignoreInitialization = true
    if item.id == 0 and civ.isUnitType(item) then
        ignoreInitialization = false
    end
    return canBuildFunctions.customCanBuild(defaultBuildFunction,city,item, ignoreInitialization)
end)

registeredInThisFile["onCanBuild"]=true

-- onEnterTile(unit,previousTile)
-- executes when a unit successfully enters a tile (so not when it attacks
-- a unit or fails to enter a tile because it lacks movement points)
local function onEnterTile(unit,previousTile,previousDomainSpec)
    -- onEnterTile priority is for transport events, so units can
    -- 'drag' other units into the tile before the regular onEnterTile event
    discreteEvents.performOnEnterTilePriority(unit,previousTile,previousDomainSpec)
    discreteEvents.performOnEnterTile(unit,previousTile)
    consolidated.onEnterTile(unit,previousTile)
    eventsFiles.onEnterTile(unit,previousTile)
end

registeredInThisFile["onEnterTile"] = true
-- onFinalOrderGiven(unit)
-- executes when a unit has been given its last order for the turn
-- that is, when a new unit is active, and the previous unit has spent
-- all its movement points
local function onFinalOrderGiven(unit)
    discreteEvents.performOnFinalOrderGiven(unit)
    consolidated.onFinalOrderGiven(unit)
    eventsFiles.onFinalOrderGiven(unit)
end
registeredInThisFile["onFinalOrderGiven"] = true

local previousUnitActivated = nil
local locationOfPreviousUnitActivated = nil
local previousDomainSpec = nil
local function executeOnEnterTile(currentActiveUnit)
    -- check that there was a previous unit activated, that the unit is still on the map
    -- (so not destroyed/deleted) and that the unit is on a different square from
    -- the previous check.  If so, perform the onEnterTile function
    if previousUnitActivated and previousUnitActivated.location ~= locationOfPreviousUnitActivated
        and previousUnitActivated.location.x < 60000 then
        onEnterTile(previousUnitActivated,locationOfPreviousUnitActivated,previousDomainSpec)
    end
    if previousUnitActivated and gen.moveRemaining(previousUnitActivated) <= 0 and
        previousUnitActivated.location.x < 60000 then
        onFinalOrderGiven(previousUnitActivated)
    end
    previousUnitActivated = currentActiveUnit
    if previousUnitActivated then
        locationOfPreviousUnitActivated = previousUnitActivated.location
        previousDomainSpec = previousUnitActivated.domainSpec
    end
    --civ.ui.text("on enter tile check "..tostring(previousUnitActivated))
end


local function doOnSave() --> string
    discreteEvents.performOnSave()
    -- compress the text representation of the state table, so saved game files are smaller
    return lualzw.compress(civlua.serialize(state))
end
civ.scen.onSave(doOnSave)
registeredInThisFile["onSave"]=true

local function doOnLoad(buffer)-->void
    -- if buffer is compressed, it is decompressed, otherwise the
    -- buffer itself is used
    state = civlua.unserialize(lualzw.decompress(buffer) or buffer)
    local stateTableKeys = {}
    discreteEvents.performLinkStateToModules(state,stateTableKeys)
    --linkStateTableToModules()
    print("Enter console.commands() to see a list of keys in the console table.  Some give access to functions in modules, others will run event code.")
end
civ.scen.onLoad(doOnLoad)
registeredInThisFile["onLoad"]=true


civ.scen.onKeyPress(function(keyCode)
    suppressActivateUnitBackstop = true
    discreteEvents.performOnKeyPress(keyCode)
    consolidated.onKeyPress(keyCode)
    eventsFiles.onKeyPress(keyCode)
    suppressActivateUnitBackstop = false
end)


registeredInThisFile["onKeyPress"] = true

civ.scen.onCityProduction(function(city,prod)
    prod = promotionSettings.overrideProdVetStatus(city,prod)
    if civ.isUnit(prod) then
        -- since this is a newly produced unit, it should have no data
        unitData.deleteData(prod)
    end
    discreteEvents.performOnCityProduction(city,prod)
    consolidated.onCityProduction(city,prod)
    eventsFiles.onCityProduction(city,prod)
end)
registeredInThisFile["onCityProduction"] = true

local activateUnitBackstopMostRecent = false
local previousUnitActivationTime = os.time()+os.clock()
local function doOnUnitActivation(unit,source,repeatMove)
    executeOnEnterTile(unit)
    humanUnitActive = unit.owner.isHuman
    if (unit.owner.isHuman and simpleSettings.clearAdjacentAirProtectionHuman)
        or (not unit.owner.isHuman and simpleSettings.clearAdjacentAirProtectionAI) then
        gen.clearAdjacentAirProtection(unit)
    end
    eventsFiles.attackBonus(unit)
    discreteEvents.performOnActivateUnit(unit,source,repeatMove)
    consolidated.onActivateUnit(unit,source,repeatMove)
    eventsFiles.onActivateUnit(unit,source,repeatMove)
    -- don't need to run this for repeat moves
    if simpleSettings.enableCustomUnitSelection and not repeatMove then
        gen.selectNextActiveUnit(unit,source,simpleSettings.customWeightFunction)
    end
    activateUnitBackstopMostRecent = false
    previousUnitActivationTime = os.time()+os.clock()
end

registeredInThisFile["onActivateUnit"]=true


gen.linkActivationFunction(doOnUnitActivation)
civ.scen.onActivateUnit(function(unit,source,repeatMove)
    suppressActivateUnitBackstop = true
    --if flag.value("tribe"..tostring(unit.owner.id).."AfterProductionNotDone","eventMachinery") then
    --    flag.setFalse("tribe"..tostring(unit.owner.id).."AfterProductionNotDone","eventMachinery")
    --    doAfterProduction(civ.getTurn(),unit.owner)
    --    eventTools.guaranteeUnitActivationForNextActiveTribe(unit.owner)
    --end
    promotionSettings.performPendingUpgrades()
    diplomacy.checkTreaties()
    doOnUnitActivation(unit,source,repeatMove)
    --eventTools.unitActivation(unit,source)
    suppressActivateUnitBackstop = false
end)

local function doAfterProduction(turn,tribe)
    text.displayAccumulatedMessages()
    if not simpleSettings.doNotDeleteAITextArchives then
        text.deleteAIArchives()
    end
    discreteEvents.performOnAfterProduction(turn,tribe)
    discreteEvents.performOnCityProcessingComplete(turn,tribe)
    consolidated.afterProduction(turn,tribe)
    consolidated.onCityProcessingComplete(turn,tribe)
    eventsFiles.onAfterProduction(turn,tribe)
    eventsFiles.onCityProcessingComplete(turn,tribe)
    delayedAction.doAfterProduction(turn,tribe)
    --eventTools.maintainUnitActivationTable()
    suppressActivateUnitBackstop = false
end
civ.scen.onCityProcessingComplete(doAfterProduction)
console.afterProduction = function() doAfterProduction(civ.getTurn(),civ.getCurrentTribe()) end
console.onCityProcessingComplete = console.afterProduction
registeredInThisFile["onAfterProduction"] = true
registeredInThisFile["onCityProcessingComplete"] = true

-- This is for events that should only happen when a unit is killed in a 'standard' Civilization ii combat
local function doOnUnitDefeatedInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    discreteEvents.performOnUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    consolidated.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    eventsFiles.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    promotionSettings.checkForUpgradeCombat(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)
end

-- This event takes place whenever a unit is 'defeated' by another unit, in standard Civilization II combat
-- or by some event representing 'combat' in which there can be a clear winner and loser
-- if the unit is demoted, return the replacing unit, otherwise, return nil

local function doOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->nil or unit
    discreteEvents.performOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    consolidated.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    eventsFiles.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    log.onUnitKilled(winner,loser)
    promotionSettings.checkForUpgradeDefeat(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)
    return promotionSettings.demotionFunction(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)

end
registeredInThisFile["onUnitDefeated"] = true

-- This event takes place whenever a unit 'dies', either through standard or event combat, or when events 'kill'
-- the unit for some other reason
local function doOnUnitDeath(dyingUnit)
    eventsFiles.onUnitDeath(dyingUnit)
end


-- this happens whenever a unit 'dies', but not through combat (or 'defeat')
local function doOnUnitDeathOutsideCombat(dyingUnit)
    eventsFiles.onUnitDeathOutsideCombat(dyingUnit)
end

-- this event has any maintenance that should be done if a unit is deleted,
-- either because of combat, non combat 'death', or some other administrative deletion situation
-- if the unit is not being 'replaced', replacingUnit will be nil
local function doOnUnitDeletion(deletedUnit,replacingUnit)
    eventsFiles.onUnitDeleted(deletedUnit,replacingUnit)
    unitData.onUnitDeleted(deletedUnit,replacingUnit)
    --eventTools.unitDeletion(deletedUnit)
end
registeredInThisFile["onUnitDeath"] = true

gen.setDeathFunctions(doOnUnitDefeated,doOnUnitDeath,doOnUnitDeletion,doOnUnitDeathOutsideCombat)

-- used to determine whether or not it is the first round of combat in the
-- civ.scen.onResolveCombat function
local firstRoundOfCombat = true
-- saves the location of the aggressor, since if an attacker loses, its location
-- is no longer available for use in a function
local aggressorLocation = nil
-- saves the veteran status of the combatants before combat, since promotion
-- happens between combat and the unit killed event
local aggressorVetStatus = false
local victimVetStatus = false
local aggressor = nil
local victim = nil

civ.scen.onUnitKilled(function (loser,winner)
    suppressActivateUnitBackstop = true
    firstRoundOfCombat = true
    local loserLocation = nil
    -- vet status of the combatants before combat
    local winnerVetStatus = nil
    local loserVetStatus = nil
    if loser == aggressor then
        loserLocation = aggressorLocation
        winnerVetStatus = victimVetStatus
        loserVetStatus = aggressorVetStatus
    else
        loserLocation = loser.location
        winnerVetStatus = aggressorVetStatus
        loserVetStatus = victimVetStatus
    end
    promotion.customVetChance(loser,winner,aggressor,victim,loserLocation,victimVetStatus,aggressorVetStatus,promotionSettings.promotionChanceFunction)
    doOnUnitDefeatedInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    local survivor = doOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    if not survivor then
        doOnUnitDeath(loser)
    end
    doOnUnitDeletion(loser,survivor)
    suppressActivateUnitBackstop = false
end)

registeredInThisFile["onUnitKilled"] = true

local nukeFileFound,useNuke = requireIfAvailable("onUseNuclearWeapon")

if not nukeFileFound then
    useNuke = {}
    useNuke.onUseNuclearWeapon = function(unit,tile) return true end
end

local function nukeDeath(loser,winner)
    firstRoundOfCombat = true
    local loserLocation = nil
    -- vet status of the combatants before combat
    local winnerVetStatus = nil
    local loserVetStatus = nil
    if loser == aggressor then
        loserLocation = aggressorLocation
        winnerVetStatus = victimVetStatus
        loserVetStatus = aggressorVetStatus
    else
        loserLocation = loser.location
        winnerVetStatus = aggressorVetStatus
        loserVetStatus = victimVetStatus
    end
    promotion.customVetChance(loser,winner,aggressor,victim,loserLocation,victimVetStatus,aggressorVetStatus,promotionSettings.promotionChanceFunction)
    doOnUnitDefeatedInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    local survivor = doOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    if not survivor then
        doOnUnitDeath(loser)
    end
    doOnUnitDeletion(loser,survivor)
    if survivor then
        nukeDeath(survivor,winner)
    end
end

civ.scen.onUseNuclearWeapon( function(unit,tile)
    suppressActivateUnitBackstop = true
    local result = useNuke.onUseNuclearWeapon(unit,tile)
    if result then
        local map = tile.z
        for nearbyUnit in gen.nearbyUnits(tile,1) do
            -- this is most of the unit killed stuff above
            -- but demoted units won't be replaced
            if nearbyUnit.location.z == map and nearbyUnit ~= unit then
                nukeDeath(nearbyUnit,unit)
            end
        end
    end
    suppressActivateUnitBackstop = false
    return result
end)
registeredInThisFile["onUseNuclearWeapon"] = true

local formattedDateFileFound,formattedDate = requireIfAvailable("onGetFormattedDate")

if not formattedDateFileFound then
    formattedDate = {}
    formattedDate.onGetFormattedDate = function(turn,defaultDateString) return defaultDateString end
end

-- this function is run occasionally to make sure events tied
-- to unit activation run smoothly, specifically events that
-- use unit activation as a substitute for checking AFTER
-- something has happened.  For example, onEnterTile
-- and unit upgrades
-- This check is done occasionally in onGetFormattedDate
-- and also in onTribeTurnEnd
local function activateUnitBackstop()
    executeOnEnterTile(nil)
    promotionSettings.performPendingUpgrades()
    activateUnitBackstopMostRecent = true
end


civ.scen.onGetFormattedDate(function(turn,defaultDateString)
        if humanUnitActive and (not suppressActivateUnitBackstop) and (not activateUnitBackstopMostRecent) and os.time()+os.clock() >= previousUnitActivationTime + 2 and (not civ.getActiveUnit()) then
            activateUnitBackstop()
        end
        return formattedDate.onGetFormattedDate(turn,defaultDateString)
    end
)
registeredInThisFile["onGetFormattedDate"] = true

-- this code was replaced by the code above, it is here just in case, but it was causing errors
--local altGetActiveUnit = function()
--    gen.limitedExecutions("alt",4,function() civ.ui.text("active unit check human playerActive: "..tostring(humanPlayerActive)) end)
--    return civ.getActiveUnit()
--end
--
--local function onDrawTileFn()
--    if humanUnitActive and (not suppressActivateUnitBackstop) and (not activateUnitBackstopMostRecent) and os.time()+os.clock() >= previousUnitActivationTime + 2 and (not altGetActiveUnit()) then
--        return function() 
--                civ.ui.text("Backstop")
--                activateUnitBackstop()
--            end
--    else
--        return function() end
--    end
--end
--
--civ.scen.onDrawTile(onDrawTileFn())


-- deprecated and replaced by civ.scen.onInitiateCombat

--local combatResolution = require("combatResolution")
--civ.scen.onResolveCombat(function(defaultResolutionFunction,defender,attacker)
--    if firstRoundOfCombat then
--        aggressor = attacker
--        victim = defender
--        aggressorVetStatus = aggressor.veteran
--        aggressorLocation = aggressor.location
--        victimVetStatus = victim.veteran
--        firstRoundOfCombat = false
--        return (combatResolution.firstRound(defaultResolutionFunction,defender,attacker) and
--                combatResolution.everyRound(defaultResolutionFunction,defender,attacker))
--    else
--        return combatResolution.everyRound(defaultResolutionFunction,defender,attacker)
--    end
--end)
--



civ.scen.onCityTaken(function (city,defender)
    suppressActivateUnitBackstop = true
    if simpleSettings.rehomeUnitsInCapturedCity then
        gen.rehomeUnitsInCapturedCity(city,defender)
    end
    discreteEvents.performOnCityTaken(city,defender)
    consolidated.onCityTaken(city,defender)
    eventsFiles.onCityTaken(city,defender)
    suppressActivateUnitBackstop = false
end)
registeredInThisFile["onCityTaken"]=true

civ.scen.onCityDestroyed(function (city)
    suppressActivateUnitBackstop = true
    if simpleSettings.rehomeUnitsInCapturedCity then
        gen.rehomeUnitsInCapturedCity(city,city.owner)
    end
    discreteEvents.performOnCityDestroyed(city)
    consolidated.onCityDestroyed(city)
    eventsFiles.onCityDestroyed(city)
    cityData.onCityDestroyed(city)
    suppressActivateUnitBackstop = false
end)
registeredInThisFile["onCityDestroyed"] = true

civ.scen.onScenarioLoaded(function ()
    suppressActivateUnitBackstop = true
    doOnChooseSeason()
    discreteEvents.performOnScenarioLoaded()
    consolidated.onScenarioLoaded()
    eventsFiles.onScenarioLoaded()
    if civ.getActiveUnit() then
        doOnUnitActivation(civ.getActiveUnit(),false)
        --executeOnEnterTile(civ.getActiveUnit())
    end
    --eventTools.maintainUnitActivationTable()
    activateUnitBackstopMostRecent = true -- around this time, the backstop runs for some unknown reason, this stops that until unit activation happens again
    suppressActivateUnitBackstop = false
    humanPlayerActive = civ.getCurrentTribe().isHuman
end)
registeredInThisFile["onScenarioLoaded"] = true

civ.scen.onNegotiation(function(talker,listener)
    suppressActivateUnitBackstop = true
    -- if all registered events return true for a talker and listener, then they can talk
    -- if any return false, they can't
    local discreteEventsResult = discreteEvents.performOnNegotiation(talker,listener)
    local consolidatedEventsResult = consolidated.onNegotiation(talker,listener)
    local individualEventsResult = eventsFiles.onNegotiation(talker,listener)
    suppressActivateUnitBackstop = false
    return discreteEventsResult and consolidatedEventsResult and individualEventsResult
end)
registeredInThisFile["onNegotiation"] = true


civ.scen.onSchism(function(tribe)
    suppressActivateUnitBackstop = true
    -- if all registered events return true for a tribe, that tribe can schism (default behaviour)
    -- if any return false, the tribe can't schism
    local discreteEventsResult = discreteEvents.performOnSchism(tribe)
    local consolidatedEventsResult = consolidated.onSchism(tribe)
    local individualEventsResult = eventsFiles.onSchism(tribe)
    suppressActivateUnitBackstop = false
    return discreteEventsResult and consolidatedEventsResult and individualEventsResult
end)

registeredInThisFile["onSchism"] = true


civ.scen.onCentauriArrival(function(tribe)
    discreteEvents.performOnCentauriArrival(tribe)
    consolidated.onCentauriArrival(tribe)
    eventsFiles.onCentauriArrival(tribe)
end)
registeredInThisFile["onCentauriArrival"] = true

civ.scen.onBribeUnit(function(unit,previousOwner)
    suppressActivateUnitBackstop = true
   discreteEvents.performOnBribeUnit(unit,previousOwner)
   consolidated.onBribeUnit(unit,previousOwner)
   eventsFiles.onBribeUnit(unit,previousOwner)
   suppressActivateUnitBackstop = false
end)
registeredInThisFile["onBribeUnit"] = true

civ.scen.onGameEnds(function(reason)
    -- if all registered events return true for a reason, then the game ends (default behaviour)
    -- if any return false, the game doesn't end
    local discreteEventsResult = discreteEvents.performOnGameEnds(reason)
    local consolidatedEventsResult = consolidated.onGameEnds(reason)
    local individualEventsResult = eventsFiles.onGameEnds(reason)
    return discreteEventsResult and consolidatedEventsResult and individualEventsResult
end)

registeredInThisFile["onGameEnds"]=true

civ.scen.onCityFounded(function(city)
    suppressActivateUnitBackstop = true
    local discreteCancelFn = discreteEvents.performOnCityFounded(city) -- always returns a function
    local consolidatedCancelFn = consolidated.onCityFounded(city) -- may return a function, so account for case where it doesn't
    -- note that type(void) is an error, but
    -- local a = void
    -- type(a) -> nil
    -- hence, consolidatedCancelFn will not be void
    local separateCancelFn = eventsFiles.onCityFounded(city) -- may return a function, so account for case where it doesn't
    if consolidatedCancelFn and type(consolidatedCancelFn) ~= 'function' then
        error("consolidatedFunctions.onCityFounded: value returned that isn't a function.  The value is "..tostring(consolidatedCancelFn)..".  Your onCityFounded event does not need to return a value, but if it does, it should be a function (or nil).")
    end
    if separateCancelFn and type(separateCancelFn) ~= 'function' then
        error("separateFunctions.onCityFounded: value returned that isn't a function.  The value is "..tostring(separateCancelFn)..".  Your onCityFounded event does not need to return a value, but if it does, it should be a function (or nil).")
    end
    local function linkedCancelFunction()
        discreteCancelFn()
        if consolidatedCancelFn then
            consolidatedCancelFn()
        end
        if separateCancelFn then
            separateCancelFn()
        end
    end
    suppressActivateUnitBackstop = false
    return linkedCancelFunction
end)
registeredInThisFile["onCityFounded"] = true

local function doBeforeProduction(turn,tribe)
    suppressActivateUnitBackstop = true
    supplementalData.onTribeTurnBegin(turn,tribe)
    consolidated.beforeProduction(turn,tribe)
    consolidated.onTribeTurnBegin(turn,tribe)
    discreteEvents.performOnBeforeProduction(turn,tribe)
    discreteEvents.performOnTribeTurnBegin(turn,tribe)
    eventsFiles.onBeforeProduction(turn,tribe)
    eventsFiles.onTribeTurnBegin(turn,tribe)
    humanUnitActive = false
    humanPlayerActive = tribe.isHuman
end
console.beforeProduction = function () doBeforeProduction(civ.getTurn(),civ.getCurrentTribe()) end
console.onTribeTurnBegin = console.beforeProduction
civ.scen.onTribeTurnBegin(doBeforeProduction)
registeredInThisFile["onBeforeProduction"] = true
registeredInThisFile["onTribeTurnBegin"] = true

local function doOnCityProcessed(city)
    consolidated.onCityProcessed(city)
    discreteEvents.performOnCityProcessed(city)
    eventsFiles.onCityProcessed(city)
end
registeredInThisFile["onCityProcessed"] = true

local function doOnTribeTurnEnd(turn,tribe)
    activateUnitBackstop()
    discreteEvents.performOnTribeTurnEnd(turn,tribe)
    consolidated.onTribeTurnEnd(turn,tribe)
    eventsFiles.onTribeTurnEnd(turn,tribe)
    supplementalData.onTribeTurnEnd(turn,tribe)
    humanPlayerActive = false
end
civ.scen.onTribeTurnEnd(doOnTribeTurnEnd)
registeredInThisFile["onTribeTurnEnd"] = true


local baseProduction = gen.computeBaseProduction
civ.scen.onCalculateCityYield( function(city,food,shields,trade)
    -- note the use of civ.getCurrentTribe().id instead of city.owner.id
    -- this is because investigating a city can calculate the yield without it being
    -- that player's turn
    --local extraFood,extraShields,extraTrade = 0,0,0 -- resources to add to compensate
    ---- for production changes during the beforeProductionEvent
    --if flag.value("tribe"..tostring(civ.getCurrentTribe().id).."BeforeProductionNotDone","eventMachinery") then
    --    flag.setFalse("tribe"..tostring(civ.getCurrentTribe().id).."BeforeProductionNotDone","eventMachinery")
    --    doBeforeProduction(civ.getTurn(),civ.getCurrentTribe())
    --    -- prepare for onCityProcessed execution point by resetting the list of processed cities
    --    for key,val in pairs(state.processedCities) do
    --        state.processedCities[key] = nil
    --    end
    --    -- if doBeforeProduction changed the tile production, we have to compensate for that
    --    -- for the current city
    --    local correctFood,correctShields,correctTrade = baseProduction(city)
    --    extraFood = correctFood-food
    --    food = correctFood
    --    extraShields = correctShields - shields
    --    shields = correctShields
    --    extraTrade = correctTrade - trade
    --    trade = correctTrade
    --end
    --
    -- onCityProcessed execution point
    if city.owner == civ.getCurrentTribe() and (not state.processedCities[city.id]) then
        state.processedCities[city.id] = true
        doOnCityProcessed(city)
    end

    -- if doBeforeProduction 
    local fCh,sChBW,sChAW,tChBC,tChAC = cityYield.onCalculateCityYield(city,food,shields,trade)
    --return fCh+extraFood,sChBW+extraShields,sChAW,tChBC+extraTrade,tChAC
    return fCh,sChBW,sChAW,tChBC,tChAC
end)
registeredInThisFile["onCalculateCityYield"] = true


civ.scen.onInitiateCombat( function(attacker,defender,attackerDie,attackerPower,defenderDie,defenderPower,isSneakAttack)
    diplomacy.checkTreaties()

    aggressorLocation = attacker.location
    aggressorVetStatus = attacker.veteran
    aggressor = attacker
    victimVetStatus = defender.veteran
    victim = defender
    if diplomacy.contactExists(attacker.owner,defender.owner) and not diplomacy.warExists(attacker.owner,defender.owner) then
        return coroutine.create(function() end)
    end
    return combatSettings.onInitiateCombatMakeCoroutine(attacker,defender,attackerDie,attackerPower,defenderDie,defenderPower,isSneakAttack)
end)

registeredInThisFile["onInitiateCombat"] = true

civ.scen.onChooseDefender(combatSettings.onChooseDefender)

registeredInThisFile["onChooseDefender"] = true

-- note: For this item, the function is registered in the required file
requireIfAvailable("customMusicIntegration")
registeredInThisFile["onSelectMusic"] = true



local rushBuySettingsFound, rushBuySettings = requireIfAvailable("rushBuySettings")
if not rushBuySettingsFound then
    print("WARNING: rushBuySettings.lua not found")
    rushBuySettings = {}
    rushBuySettings.onGetRushBuyCost = function(city,cost) return cost end
end
civ.scen.onGetRushBuyCost(rushBuySettings.onGetRushBuyCost)



-- Checking if a unit can found a city
-- Return true if the unit can found a city
-- return false if it can't
-- If any one of the consolidated event, the discrete events, 
-- or the separate file event return false, then the city
-- can't be built
-- Notes: Returning true does NOT override any normal city
-- building condition (like no adjacent cities, or cities at sea)
-- This event is not called for advanced tribes (as of TOTPPv18.1),
-- so it can't prevent them.  Setting that tile's fertility to 0
-- will prevent it (and stop the AI from settling that tile also)
local function onCanFoundCity(unit)
    -- if all registered events return true for a unit, the city is allowed to be built (default behaviour)
    -- if any return false, the city can't be built (so return false for this function)
    local discreteEventsResult = discreteEvents.performOnCanFoundCity(unit)
    local consolidatedEventsResult = consolidated.onCanFoundCity(unit)
    local individualEventsResult = eventsFiles.onCanFoundCity(unit)
    return discreteEventsResult and consolidatedEventsResult and individualEventsResult
end
civ.scen.onCanFoundCity(onCanFoundCity)
registeredInThisFile["onCanFoundCity"] = true


function discreteEvents.linkStateToModules(state,stateTableKeys)
    local keyName = "globalState"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    state[keyName] = state[keyName] or {}
    _global.state = state[keyName]
    local keyName = "processedCities"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    state.processedCities = state.processedCities or {}
end
discreteEvents.performLinkStateToModules(state,{})   
-- find files to register the events
for registerName,registerFunction in pairs(civ.scen) do
    if not registeredInThisFile[registerName] then
        local fileFound, prefix = requireIfAvailable('EventsFiles\\'..registerName)
        if fileFound then
            civ.scen[registerName](prefix[registerName])
            print("NOTICE: civ.scen."..registerName.." registered automatically.  If you didn't add the file 'EventsFiles\\"..registerName.."' deliberately, this might indicate a mistake in the Lua Scenario Template.  Contact Prof. Garfield if that is the case.")
        end
    end
end

local scriptIntegratorFound,prefix = requireIfAvailable("Scripts\\scriptIntegrator")
if not scriptIntegratorFound then
    print("WARNING: Did not find Scripts\\scriptIntegrator.lua.  CTRL+SHIFT+F4 script menu not available.")
end

local seasonSettingsFound, prefix = requireIfAvailable("seasonSettings")
if not seasonSettingsFound then
    print("WARNING: Did not find seasonSettings.lua. If you have registered season information in that file, it is not available.")
end

