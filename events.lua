
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
local cityYield = require("calculateCityYield")
local onInitiateCombat = require("initiateCombat")


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
    flag.define("tribe"..tostring(i).."BeforeProductionNotDone",true)
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
    state.globalState = state.globalState or {}
    _global.state = state.globalState

end



linkStateTableToModules()
local onTurnFn = function(turn)
    -- this makes doAfterProduction work
    for i=0,7 do
        flag.setTrue("tribe"..tostring(i).."AfterProductionNotDone")
        flag.setTrue("tribe"..tostring(i).."BeforeProductionNotDone")
    end
    delayedAction.doOnTurn(turn)

    triggerEvents.onTurn(turn)
    for city in civ.iterateCities() do
        if simpleSettings.cancelWeLoveTheKing[city.owner.government] then
            gen.clearWeLoveTheKing(city)
        end
    end
end
civ.scen.onTurn(onTurnFn)
console.onTurn = function() onTurnFn(civ.getTurn()) end

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
    print("Enter console.commands() to see a list of keys in the console table.  Some give access to functions in modules, others will run event code.")
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
console.afterProduction = function() doAfterProduction(civ.getTurn(),civ.getCurrentTribe()) end
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
    scenarioLoaded.scenarioLoadedFn()
    if civ.getActiveUnit() then
        doOnUnitActivation(civ.getActiveUnit(),false)
    end
    eventTools.maintainUnitActivationTable()
end)

civ.scen.onNegotiation(negotiationSettings.negotiation)

civ.scen.onSchism(onSchism.onSchism)

civ.scen.onCentauriArrival(triggerEvents.onCentauriArrival)

civ.scen.onBribeUnit(triggerEvents.onBribeUnit)

civ.scen.onGameEnds(triggerEvents.onGameEnds)

civ.scen.onCityFounded(triggerEvents.onCityFounded)

local function doBeforeProduction(turn,tribe)
    triggerEvents.beforeProduction(turn,tribe)

end
console.beforeProduction = function () doBeforeProduction(civ.getTurn(),civ.getCurrentTribe()) end
local baseProduction = gen.computeBaseProduction
civ.scen.onCalculateCityYield( function(city,food,shields,trade)
    -- note the use of civ.getCurrentTribe().id instead of city.owner.id
    -- this is because investigating a city can calculate the yield without it being
    -- that player's turn
    local extraFood,extraShields,extraTrade = 0,0,0 -- resources to add to compensate
    -- for production changes during the beforeProductionEvent
    if flag.value("tribe"..tostring(civ.getCurrentTribe().id).."BeforeProductionNotDone") then
        flag.setFalse("tribe"..tostring(civ.getCurrentTribe().id).."BeforeProductionNotDone")
        doBeforeProduction(civ.getTurn(),civ.getCurrentTribe())
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
    -- if doBeforeProduction 
    local fCh,sChBW,sChAW,tChBC,tChAC = cityYield.onCalculateCityYield(city,food,shields,trade)
    return fCh+extraFood,sChBW+extraShields,sChAW,tChBC+extraTrade,tChAC
end)


civ.scen.onInitiateCombat( function(attacker,defender,attackerDie,attackerPower,defenderDie,defenderPower)
    diplomacy.checkTreaties()

    aggressorLocation = attacker.location
    aggressorVetStatus = attacker.veteran
    aggressor = attacker
    victimVetStatus = defender.veteran
    victim = defender
    if diplomacy.contactExists(attacker.owner,defender.owner) and not diplomacy.warExists(attacker.owner,defender.owner) then
        return coroutine.create(function() end)
    end
    return onInitiateCombat.makeCoroutine(attacker,defender,attackerDie,attackerPower,defenderDie,defenderPower)
end)

    
