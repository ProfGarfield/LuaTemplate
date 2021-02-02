
-- events.lua for the
-- Lua Event Template
--


-- note: console is the only global.  If you need a variable to
-- be accessible from the console, put it in the console table, 
-- and access it via console.myVariable
-- Put this before requirements, in case any required items
-- are checking if there is a console table
console = {}
local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolder = string.gsub(eventsPath,"events.lua","")
--print(scenarioFolder)
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
--print(scenarioFolderPath)
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
    package.path = scenarioFolderPath..";"..scenarioFolder.."LuaCore\\?.lua"..
    ";"..scenarioFolder.."LuaRulesEvents\\?.lua"..";"..scenarioFolder.."LuaTriggerEvents\\?.lua"
    ..";"..scenarioFolder.."LuaParameterFiles\\?.lua"
    -- comment out next line to rely only on files within the scenario folder, uncomment to access the lua folder
    --..";"..civ.getToTDir().."\\lua\\?.lua"
end

local gen = require("generalLibrary")
-- noGlobal prevents new global variables from being created
-- or accessed; this should make typos easier to discover
gen.noGlobal()
local civlua = require("civluaModified")
local func = require("functions")
local flag = require("flag")
local counter = require("counter")
local text = require("text")
local canBuildSettings = require("canBuildSettings")
local canBuildFunctions = require("canBuild")
local keyPressEvents = require("keyPressEvents")
local munitions = require("munitions")
local munitionsSettings = require("munitionsSettings")
local attackBonusSettings = require("attackBonusSettings")
local delayedAction = require("delayedAction")
local eventTools = require("eventTools")
local combatResolution = require("combatResolution")
local promotion = require("promotion")
local promotionSettings = require("promotionSettings")
local simpleSettings = require("simpleSettings")
local unitActivation = require("unitActivation")
local scenarioLoaded = require("scenarioLoaded")
local negotiationSettings = require("negotiationSettings")
local onSchism = require("onSchism")
local legacy = require("legacyEventEngine")
local legacyEventTable = require("getLegacyEvents")
legacy.supplyLegacyEventsTable(legacyEventTable)
local delay = require("delayedAction")
local diplomacy = require("diplomacy")

local triggerEvents = require("triggerEvents")
local log = require("log")
-- this module compresses (and decompresses) the state
-- table so it is smaller in saved files
local lualzw = require("lualzw")


local musicFolder= string.gsub(eventsPath,civ.getToTDir(),"..")
musicFolder= string.gsub(musicFolder,"events.lua","").."\\Sound"
gen.setMusicDirectory(musicFolder)



for i=0,7 do
    flag.define("tribe"..tostring(i).."AfterProductionNotDone",true)
end

local state = {}



local function linkStateTableToModules()
    -- link the state table to the flags module
    state.flagTable = state.flagTable or {}
    flag.linkState(state.flagTable)
    flag.initializeFlags()
    -- link the state table to the counter module
    state.counterTable = state.counterTable or {}
    counter.linkState(state.counterTable)
    counter.initializeCounters()
    -- link the state table to the text module
    state.textTable = state.textTable or {}
    text.linkState(state.textTable)
    -- link the state table to the general library
    -- state.designerState is made available through gen.getState()
    -- state.generalLibraryState is used for 'internal' general library functionality
    state.designerState = state.designerState or {}
    state.generalLibraryState = state.generalLibraryState or {}
    gen.linkState(state.designerState)
    gen.linkGeneralLibraryState(state.generalLibraryState)
    state.logState = state.logState or {}
    log.linkState(state.logState)
    state.delayedAction = state.delayedAction or {}
    delayedAction.linkState(state.delayedAction)
    state.promotion = state.promotion or {}
    promotion.linkState(state.promotion)
    state.eventToolsState = state.eventToolsState or {}
    eventTools.linkState(state.eventToolsState)
    state.legacyState = state.legacyState or {}
    legacy.linkState(state.legacyState)
    state.delayedActionState = state.delayedActionState or {}
    delay.linkState(state.delayedActionState)
    state.diplomacyState = state.diplomacyState or {}
    diplomacy.linkState(state.diplomacyState)
    state.munitionsState = state.munitionsState or {}
    munitions.linkState(state.munitionsState)

end



linkStateTableToModules()
civ.scen.onTurn(function(turn)
    -- this makes doAfterProduction work
    for i=0,7 do
        flag.setTrue("tribe"..tostring(i).."AfterProductionNotDone")
    end
    delayedAction.doOnTurn(turn)

    triggerEvents.onTurn(turn)
    for city in civ.iterateCities() do
        if simpleSettings.cancelWeLoveTheKing[city.owner.government] then
            gen.clearWeLoveTheKing(city)
        end
    end
end)

civ.scen.onCanBuild(function(defaultBuildFunction,city,item)
    return canBuildFunctions.customCanBuild(defaultBuildFunction,city,item)
end)



local function doOnSave() --> string
    -- compress the text representation of the state table, so saved game files are smaller
    return lualzw.compress(civlua.serialize(state))
end
civ.scen.onSave(doOnSave)

local function doOnLoad(buffer)-->void
    -- if buffer is compressed, it is decompressed, otherwise the
    -- buffer itself is used
    state = civlua.unserialize(lualzw.decompress(buffer) or buffer)
    linkStateTableToModules()
end
civ.scen.onLoad(doOnLoad)

civ.scen.onKeyPress(keyPressEvents.doKeyPress)

civ.scen.onCityProduction(function(city,prod)
    prod = promotionSettings.overrideProdVetStatus(city,prod)
    if civ.isUnit(prod) then
        munitionsSettings.onProdPayloadRestrictionCheck(prod)
    end
    triggerEvents.onCityProduction(city,prod)
end)

local function doOnUnitActivation(unit,source)
    if (unit.owner.isHuman and simpleSettings.clearAdjacentAirProtectionHuman)
        or (not unit.owner.isHuman and simpleSettings.clearAdjacentAirProtectionAI) then
        gen.clearAdjacentAirProtection(unit)
    end
    attackBonusSettings.attackBonus(unit)
    unitActivation.activateFunction(unit,source)
    if simpleSettings.enableCustomUnitSelection then
        gen.selectNextActiveUnit(unit,source,simpleSettings.customWeightFunction)
    end

end
local function doAfterProduction(turn,tribe)
    text.displayAccumulatedMessages()
    if not simpleSettings.doNotDeleteAITextArchives then
        text.deleteAIArchives()
    end
    delayedAction.doAfterProduction(turn,tribe)
    triggerEvents.afterProduction(turn,tribe)
    eventTools.maintainUnitActivationTable()
end
gen.linkActivationFunction(doOnUnitActivation)
civ.scen.onActivateUnit(function(unit,source)
    if flag.value("tribe"..tostring(unit.owner.id).."AfterProductionNotDone") then
        flag.setFalse("tribe"..tostring(unit.owner.id).."AfterProductionNotDone")
        doAfterProduction(civ.getTurn(),unit.owner)
        eventTools.guaranteeUnitActivationForNextActiveTribe(unit.owner)
    end
    promotionSettings.performPendingUpgrades()
    diplomacy.checkTreaties()
    doOnUnitActivation(unit,source)
    eventTools.unitActivation(unit,source)
end)


-- This is for events that should only happen when a unit is killed in a 'standard' Civilization ii combat
local function doOnUnitDefeatedInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    triggerEvents.unitKilledInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    promotionSettings.checkForUpgradeCombat(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)
end

-- This event takes place whenever a unit is 'defeated' by another unit, in standard Civilization II combat
-- or by some event representing 'combat' in which there can be a clear winner and loser
-- if the unit is demoted, return the replacing unit, otherwise, return nil

local function doOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->nil or unit
    triggerEvents.unitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    promotionSettings.checkForUpgradeDefeat(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)
    return promotionSettings.demotionFunction(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)

end

-- This event takes place whenever a unit 'dies', either through standard or event combat, or when events 'kill'
-- the unit for some other reason
local function doOnUnitDeath(dyingUnit)
    triggerEvents.unitDeath(dyingUnit)

end


-- this happens whenever a unit 'dies', but not through combat (or 'defeat')
local function doOnUnitDeathOutsideCombat(dyingUnit)
    triggerEvents.unitDeathOutsideCombat(dyingUnit)
end

-- this event has any maintenance that should be done if a unit is deleted,
-- either because of combat, non combat 'death', or some other administrative deletion situation
-- if the unit is not being 'replaced', replacingUnit will be nil
local function doOnUnitDeletion(deletedUnit,replacingUnit)
    triggerEvents.unitDeleted(deletedUnit,replacingUnit)
    eventTools.unitDeletion(deletedUnit)
end

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
    --legacy.doUnitKilledEvents(loser,winner)
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


civ.scen.onResolveCombat(function(defaultResolutionFunction,defender,attacker)
    if firstRoundOfCombat then
        aggressor = attacker
        victim = defender
        aggressorVetStatus = aggressor.veteran
        aggressorLocation = aggressor.location
        victimVetStatus = victim.veteran
        firstRoundOfCombat = false
        return (combatResolution.firstRound(defaultResolutionFunction,defender,attacker) and
                combatResolution.everyRound(defaultResolutionFunction,defender,attacker))
    else
        return combatResolution.everyRound(defaultResolutionFunction,defender,attacker)
    end
end)

civ.scen.onCityTaken(function (city,defender)
    if simpleSettings.rehomeUnitsInCapturedCity then
        gen.rehomeUnitsInCapturedCity(city,defender)
    end
    triggerEvents.onCityTaken(city,defender)
end)

civ.scen.onCityDestroyed(function (city)
    if simpleSettings.rehomeUnitsInCapturedCity then
        gen.rehomeUnitsInCapturedCity(city,city.owner)
    end
    triggerEvents.onCityDestroyed(city)
end)

civ.scen.onScenarioLoaded(function ()
    if civ.getActiveUnit() then
        doOnUnitActivation(civ.getActiveUnit(),false)
    end
    scenarioLoaded.scenarioLoadedFn()
    eventTools.maintainUnitActivationTable()
end)

civ.scen.onNegotiation(negotiationSettings.negotiation)

civ.scen.onSchism(onSchism.onSchism)

civ.scen.onCentauriArrival(triggerEvents.onCentauriArrival)

civ.scen.onBribeUnit(triggerEvents.onBribeUnit)

civ.scen.onGameEnds(triggerEvents.onGameEnds)

civ.scen.onCityFounded(triggerEvents.onCityFounded)
