
-- events.lua for the
-- Lua Event Template
--


-- note: console and global are the only globals.  If you need a variable to
-- be accessible from the console, put it in the console table, 
-- and access it via console.myVariable
-- If you want to share values between files, use global.myValue
-- (from a technical stand point, you can use either one for
-- either purpose
-- Put this before requirements, in case any required items
-- are checking if there is a console table
console = {}
console.commands = function() print('These are keys currently stored in the console table.\n')
    for k,__ in pairs(console) do
        print('console.'..k)
    end end
_global = {}
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
end

local function attemptToRun(fileName,warningMessage)
    local fileFound,prefix = pcall(require,fileName)
    if not fileFound then
        print(warningMessage)
    end
end

local gen = require("generalLibrary")
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
local delayedAction = require("delayedAction")
local eventTools = require("eventTools")
local promotion = require("promotion")
local promotionSettings = require("promotionSettings")
local simpleSettings = require("simpleSettings")
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
local discreteEvents = require("discreteEventsRegistrar")
require("discreteEvents")
local consolidated = require("consolidatedEvents")


--local triggerEvents = require("triggerEvents")
local log = require("log")
-- this module compresses (and decompresses) the state
-- table so it is smaller in saved files
local lualzw = require("lualzw")


local musicFolder= string.gsub(eventsPath,civ.getToTDir(),"..")
musicFolder= string.gsub(musicFolder,"events.lua","").."\\Sound"
gen.setMusicDirectory(musicFolder)



for i=0,7 do
    flag.define("tribe"..tostring(i).."AfterProductionNotDone",true,"eventMachinery")
    flag.define("tribe"..tostring(i).."BeforeProductionNotDone",true,"eventMachinery")
end

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
    local fileFound, prefix = pcall(require,moduleName)
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

local individualFileDirectory = "EventsFiles\\"

local function doOnChooseSeason()
    discreteEvents.performOnChooseSeason()
end
local onTurnFn = function(turn)
    -- this makes doAfterProduction work
    for i=0,7 do
        flag.setTrue("tribe"..tostring(i).."AfterProductionNotDone","eventMachinery")
        flag.setTrue("tribe"..tostring(i).."BeforeProductionNotDone","eventMachinery")
    end
    doOnChooseSeason()
    discreteEvents.performOnTurn(turn)
    consolidated.onTurn(turn)
    attemptRequireWithKey(individualFileDirectory.."onTurn","onTurn")(turn)
    delayedAction.doOnTurn(turn)
    for city in civ.iterateCities() do
        if simpleSettings.cancelWeLoveTheKing[city.owner.government] then
            gen.clearWeLoveTheKing(city)
        end
    end
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


local function doOnSave() --> string
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
    discreteEvents.performOnKeyPress(keyCode)
    consolidated.onKeyPress(keyCode)
    attemptRequireWithKey(individualFileDirectory.."onKeyPress","onKeyPress")(keyCode)
end)


registeredInThisFile["onKeyPress"] = true

civ.scen.onCityProduction(function(city,prod)
    prod = promotionSettings.overrideProdVetStatus(city,prod)
    discreteEvents.performOnCityProduction(city,prod)
    consolidated.onCityProduction(city,prod)
    attemptRequireWithKey(individualFileDirectory.."onCityProduction","onCityProduction")(city,prod)
end)
registeredInThisFile["onCityProduction"] = true

local function doOnUnitActivation(unit,source,repeatMove)
    if (unit.owner.isHuman and simpleSettings.clearAdjacentAirProtectionHuman)
        or (not unit.owner.isHuman and simpleSettings.clearAdjacentAirProtectionAI) then
        gen.clearAdjacentAirProtection(unit)
    end
    attemptRequireWithKey('attackBonusSettings',"attackBonus")(unit)
    discreteEvents.performOnActivateUnit(unit,source,repeatMove)
    consolidated.onActivateUnit(unit,source,repeatMove)
    attemptRequireWithKey(individualFileDirectory.."onActivateUnit","onActivateUnit")(unit,source,repeatMove)
    -- don't need to run this for repeat moves
    if simpleSettings.enableCustomUnitSelection and not repeatMove then
        gen.selectNextActiveUnit(unit,source,simpleSettings.customWeightFunction)
    end
end

registeredInThisFile["onActivateUnit"]=true

local function doAfterProduction(turn,tribe)
    text.displayAccumulatedMessages()
    if not simpleSettings.doNotDeleteAITextArchives then
        text.deleteAIArchives()
    end
    discreteEvents.performOnAfterProduction(turn,tribe)
    consolidated.afterProduction(turn,tribe)
    attemptRequireWithKey(individualFileDirectory.."onAfterProduction","onAfterProduction")(turn,tribe)
    delayedAction.doAfterProduction(turn,tribe)
    eventTools.maintainUnitActivationTable()
end
console.afterProduction = function() doAfterProduction(civ.getTurn(),civ.getCurrentTribe()) end
gen.linkActivationFunction(doOnUnitActivation)
registeredInThisFile["onAfterProduction"] = true
civ.scen.onActivateUnit(function(unit,source,repeatMove)
    if flag.value("tribe"..tostring(unit.owner.id).."AfterProductionNotDone","eventMachinery") then
        flag.setFalse("tribe"..tostring(unit.owner.id).."AfterProductionNotDone","eventMachinery")
        doAfterProduction(civ.getTurn(),unit.owner)
        eventTools.guaranteeUnitActivationForNextActiveTribe(unit.owner)
    end
    promotionSettings.performPendingUpgrades()
    diplomacy.checkTreaties()
    doOnUnitActivation(unit,source,repeatMove)
    eventTools.unitActivation(unit,source)
end)


-- This is for events that should only happen when a unit is killed in a 'standard' Civilization ii combat
local function doOnUnitDefeatedInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    discreteEvents.performOnUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    consolidated.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    attemptRequireWithKey(individualFileDirectory.."onUnitKilled","onUnitKilled")(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    promotionSettings.checkForUpgradeCombat(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)
end

-- This event takes place whenever a unit is 'defeated' by another unit, in standard Civilization II combat
-- or by some event representing 'combat' in which there can be a clear winner and loser
-- if the unit is demoted, return the replacing unit, otherwise, return nil

local function doOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->nil or unit
    discreteEvents.performOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    consolidated.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    attemptRequireWithKey(individualFileDirectory.."onUnitDefeated","onUnitDefeated")(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    log.onUnitKilled(winner,loser)
    promotionSettings.checkForUpgradeDefeat(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)
    return promotionSettings.demotionFunction(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)

end
registeredInThisFile["onUnitDefeated"] = true

-- This event takes place whenever a unit 'dies', either through standard or event combat, or when events 'kill'
-- the unit for some other reason
local function doOnUnitDeath(dyingUnit)
    attemptRequireWithKey(individualFileDirectory.."onUnitDeath","onUnitDeath")(dyingUnit)

end


-- this happens whenever a unit 'dies', but not through combat (or 'defeat')
local function doOnUnitDeathOutsideCombat(dyingUnit)
    attemptRequireWithKey(individualFileDirectory.."onUnitDeath","onUnitDeathOutsideCombat")(dyingUnit)
end

-- this event has any maintenance that should be done if a unit is deleted,
-- either because of combat, non combat 'death', or some other administrative deletion situation
-- if the unit is not being 'replaced', replacingUnit will be nil
local function doOnUnitDeletion(deletedUnit,replacingUnit)
    attemptRequireWithKey(individualFileDirectory.."onUnitDeath","onUnitDeleted")(deletedUnit,replacingUnit)
    eventTools.unitDeletion(deletedUnit)
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

end)


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
    if simpleSettings.rehomeUnitsInCapturedCity then
        gen.rehomeUnitsInCapturedCity(city,defender)
    end
    discreteEvents.performOnCityTaken(city,defender)
    consolidated.onCityTaken(city,defender)
    attemptRequireWithKey(individualFileDirectory.."onCityTaken","onCityTaken")(city,defender)
end)
registeredInThisFile["onCityTaken"]=true

civ.scen.onCityDestroyed(function (city)
    if simpleSettings.rehomeUnitsInCapturedCity then
        gen.rehomeUnitsInCapturedCity(city,city.owner)
    end
    discreteEvents.performOnCityDestroyed(city)
    consolidated.onCityDestroyed(city)
    attemptRequireWithKey(individualFileDirectory.."onCityDestroyed","onCityDestroyed")(city)
end)
registeredInThisFile["onCityDestroyed"] = true

civ.scen.onScenarioLoaded(function ()
    doOnChooseSeason()
    discreteEvents.performOnScenarioLoaded()
    consolidated.onScenarioLoaded()
    attemptRequireWithKey(individualFileDirectory.."onScenarioLoaded","onScenarioLoaded")()
    if civ.getActiveUnit() then
        doOnUnitActivation(civ.getActiveUnit(),false)
    end
    eventTools.maintainUnitActivationTable()
end)
registeredInThisFile["onScenarioLoaded"] = true

civ.scen.onNegotiation(function(talker,listener)
    -- if all registered events return true for a talker and listener, then they can talk
    -- if any return false, they can't
    local discreteEventsResult = discreteEvents.performOnNegotiation(talker,listener)
    local consolidatedEventsResult = consolidated.onNegotiation(talker,listener)
    local individualEventsResult = attemptRequireWithKey(individualFileDirectory.."onNegotiation","onNegotiation",true)(talker,listener)
    return discreteEventsResult and consolidatedEventsResult and individualEventsResult
end)
registeredInThisFile["onScenarioLoaded"] = true


civ.scen.onSchism(function(tribe)
    -- if all registered events return true for a tribe, that tribe can schism (default behaviour)
    -- if any return false, the tribe can't schism
    local discreteEventsResult = discreteEvents.performOnSchism(tribe)
    local consolidatedEventsResult = consolidated.onSchism(tribe)
    local individualEventsResult = attemptRequireWithKey(individualFileDirectory.."onSchism","onSchism",true)(tribe)
    return discreteEventsResult and consolidatedEventsResult and individualEventsResult
end)

registeredInThisFile["onSchism"] = true


civ.scen.onCentauriArrival(function(tribe)
    discreteEvents.performOnCentauriArrival(tribe)
    consolidated.onCentauriArrival(tribe)
    attemptRequireWithKey(individualFileDirectory.."onCentauriArrival","onCentauriArrival")(tribe)
end)
registeredInThisFile["onCentauriArrival"] = true

civ.scen.onBribeUnit(function(unit,previousOwner)
   discreteEvents.performOnBribeUnit(unit,previousOwner)
   consolidated.onBribeUnit(unit,previousOwner)
   attemptRequireWithKey(individualFileDirectory.."onBribeUnit","onBribeUnit")(unit,previousOwner)
end)
registeredInThisFile["onBribeUnit"] = true

civ.scen.onGameEnds(function(reason)
    -- if all registered events return true for a reason, then the game ends (default behaviour)
    -- if any return false, the game doesn't end
    local discreteEventsResult = discreteEvents.performOnGameEnds(reason)
    local consolidatedEventsResult = consolidated.onGameEnds(reason)
    local individualEventsResult = attemptRequireWithKey(individualFileDirectory.."onGameEnds","onGameEnds",true)(reason)
    return discreteEventsResult and consolidatedEventsResult and individualEventsResult
end)

registeredInThisFile["onGameEnds"]=true

civ.scen.onCityFounded(function(city)
    discreteEvents.performOnCityFounded(city)
    consolidated.onCityFounded(city)
    attemptRequireWithKey(individualFileDirectory.."onCityFounded","onCityFounded")(city)
end)
registeredInThisFile["onCityFounded"] = true

local function doBeforeProduction(turn,tribe)
    consolidated.beforeProduction(turn,tribe)
    discreteEvents.performOnBeforeProduction(turn,tribe)
    attemptRequireWithKey(individualFileDirectory.."onBeforeProduction","onBeforeProduction")(turn,tribe)
end
console.beforeProduction = function () doBeforeProduction(civ.getTurn(),civ.getCurrentTribe()) end
registeredInThisFile["onBeforeProduction"] = true

local function doOnCityProcessed(city)
    discreteEvents.performOnCityProcessed(city)
    consolidated.onCityProcessed(city)
    attemptRequireWithKey(individualFileDirectory.."onCityProcessed","onCityProcessed")(city)
end
registeredInThisFile["onCityProcessed"] = true



local baseProduction = gen.computeBaseProduction
civ.scen.onCalculateCityYield( function(city,food,shields,trade)
    -- note the use of civ.getCurrentTribe().id instead of city.owner.id
    -- this is because investigating a city can calculate the yield without it being
    -- that player's turn
    local extraFood,extraShields,extraTrade = 0,0,0 -- resources to add to compensate
    -- for production changes during the beforeProductionEvent
    if flag.value("tribe"..tostring(civ.getCurrentTribe().id).."BeforeProductionNotDone","eventMachinery") then
        flag.setFalse("tribe"..tostring(civ.getCurrentTribe().id).."BeforeProductionNotDone","eventMachinery")
        doBeforeProduction(civ.getTurn(),civ.getCurrentTribe())
        -- prepare for onCityProcessed execution point by resetting the list of processed cities
        for key,val in pairs(state.processedCities) do
            state.processedCities[key] = nil
        end
        -- if doBeforeProduction changed the tile production, we have to compensate for that
        -- for the current city
        local correctFood,correctShields,correctTrade = baseProduction(city)
        extraFood = correctFood-food
        food = correctFood
        extraShields = correctShields - shields
        shields = correctShields
        extraTrade = correctTrade - trade
        trade = correctTrade
    end
    
    -- onCityProcessed execution point
    if city.owner == civ.getCurrentTribe() and (not state.processedCities[city.id]) then
        state.processedCities[city.id] = true
        doOnCityProcessed(city)
    end

    -- if doBeforeProduction 
    local fCh,sChBW,sChAW,tChBC,tChAC = cityYield.onCalculateCityYield(city,food,shields,trade)
    return fCh+extraFood,sChBW+extraShields,sChAW,tChBC+extraTrade,tChAC
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




local rushBuySettingsFound, rushBuySettings = pcall(require,"rushBuySettings")
if not rushBuySettingsFound then
    print("WARNING: rushBuySettings.lua not found")
    rushBuySettings = {}
    rushBuySettings.onGetRushBuyCost = function(city,cost) return cost end
end
civ.scen.onGetRushBuyCost(rushBuySettings.onGetRushBuyCost)

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
        local fileFound, prefix = pcall(require,'EventsGroupedByExecutionPoint\\'..registerName)
        if fileFound then
            civ.scen[registerName](prefix[registerName])
        end
    end
end
