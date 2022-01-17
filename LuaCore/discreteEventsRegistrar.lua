local moduleVersion = 1 -- Module version will be provided as normal, but this module has different construction
local discreteEvents = {}
local eventsTable = {}




eventsTable.onActivateUnit = {}
eventsTable.onActivateUnitIndex = 1

function discreteEvents.performOnActivateUnit(unit,source,rep)
    for i = 1,eventsTable.onActivateUnitIndex-1 do
        eventsTable.onActivateUnit[i](unit,source,rep)
    end
end


eventsTable.onBribeUnit = {}
eventsTable.onBribeUnitIndex = 1

function discreteEvents.performOnBribeUnit(unit,previousOwner)
    for i = 1,eventsTable.onBribeUnitIndex-1 do
        eventsTable.onBribeUnit[i](unit,previousOwner)
    end
end


eventsTable.onCityDestroyed = {}
eventsTable.onCityDestroyedIndex = 1

function discreteEvents.performOnCityDestroyed(city)
    for i = 1,eventsTable.onCityDestroyedIndex-1 do
        eventsTable.onCityDestroyed[i](city)
    end
end

eventsTable.onCityFounded = {}
eventsTable.onCityFoundedIndex = 1

function discreteEvents.performOnCityFounded(city)
    local cityCancelledTable = {}
    local cityCancelledIndex = 1
    for i = 1,eventsTable.onCityFoundedIndex-1 do
        local cancellationFn = eventsTable.onCityFounded[i](city)
        if cancellationFn and type(cancellationFn) == "function" then
            cityCancelledTable[cityCancelledIndex] = cancellationFn
            cityCancelledIndex = cityCancelledIndex+1
        elseif cancellationFn then
            error("discreteEventsRegistrar: one of your onCityFounded discrete events returns a value that is not a function.  That value is "..tostring(cancellationFn)..".  Your onCityFounded event does not need to return a value, but if it does, it should be a function (or nil).")
        end
    end
    local function cancellationFunction()
        for j=1,cityCancelledIndex-1 do
            cityCancelledTable[j]()
        end
    end
    return cancellationFunction
end

eventsTable.onCityProcessed = {}
eventsTable.onCityProcessedIndex = 1
function discreteEvents.performOnCityProcessed(city)
    for i = 1,eventsTable.onCityProcessedIndex-1 do
        eventsTable.onCityProcessed[i](city)
    end
end

eventsTable.onCityProduction = {}
eventsTable.onCityProductionIndex = 1

function discreteEvents.performOnCityProduction(city,item)
    for i = 1,eventsTable.onCityProductionIndex-1 do
        eventsTable.onCityProduction[i](city,item)
    end
end


eventsTable.onCityTaken = {}
eventsTable.onCityTakenIndex = 1

function discreteEvents.performOnCityTaken(city,defender)
    for i = 1,eventsTable.onCityTakenIndex-1 do
        eventsTable.onCityTaken[i](city,defender)
    end
end

eventsTable.onScenarioLoaded = {}
eventsTable.onScenarioLoadedIndex = 1

function discreteEvents.performOnScenarioLoaded()
    for i = 1,eventsTable.onScenarioLoadedIndex-1 do
        eventsTable.onScenarioLoaded[i]()
    end
end

eventsTable.onTurn = {}
eventsTable.onTurnIndex = 1

function discreteEvents.performOnTurn(turn)
    for i = 1,eventsTable.onTurnIndex-1 do
        eventsTable.onTurn[i](turn)
    end
end

eventsTable.onUnitKilled = {}
eventsTable.onUnitKilledIndex = 1

function discreteEvents.performOnUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    for i = 1,eventsTable.onUnitKilledIndex-1 do
        eventsTable.onUnitKilled[i](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    end
end

eventsTable.onUnitDefeated = {}
eventsTable.onUnitDefeatedIndex = 1

function discreteEvents.performOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    for i = 1,eventsTable.onUnitDefeatedIndex-1 do
        eventsTable.onUnitDefeated[i](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    end
end

eventsTable.onAfterProduction = {}
eventsTable.onAfterProductionIndex = 1

function discreteEvents.performOnAfterProduction(turn,tribe)
    for i = 1,eventsTable.onAfterProductionIndex-1 do
        eventsTable.onAfterProduction[i](turn,tribe)
    end
end

eventsTable.onCityProcessingComplete = {}
eventsTable.onCityProcessingCompleteIndex = 1

function discreteEvents.performOnCityProcessingComplete(turn,tribe)
    for i = 1,eventsTable.onCityProcessingCompleteIndex-1 do
        eventsTable.onCityProcessingComplete[i](turn,tribe)
    end
end
eventsTable.onBeforeProduction = {}
eventsTable.onBeforeProductionIndex = 1

function discreteEvents.performOnBeforeProduction(turn,tribe)
    for i = 1,eventsTable.onBeforeProductionIndex-1 do
        eventsTable.onBeforeProduction[i](turn,tribe)
    end
end

eventsTable.onTribeTurnBegin = {}
eventsTable.onTribeTurnBeginIndex = 1

function discreteEvents.performOnTribeTurnBegin(turn,tribe)
    for i = 1,eventsTable.onTribeTurnBeginIndex-1 do
        eventsTable.onTribeTurnBegin[i](turn,tribe)
    end
end

eventsTable.onTribeTurnEnd = {}
eventsTable.onTribeTurnEndIndex = 1

function discreteEvents.performOnTribeTurnEnd(turn,tribe)
    for i = 1,eventsTable.onTribeTurnEndIndex-1 do
        eventsTable.onTribeTurnEnd[i](turn,tribe)
    end
end


eventsTable.linkStateToModules = {}
eventsTable.linkStateToModulesIndex = 1
-- state is the state table (after the buffer has been extracted)
-- stateTableKeys are keys for the state table that have
-- already been used, (this enables errors upon collision of keys) 
--
function discreteEvents.performLinkStateToModules(state,stateTableKeys)
    for i = 1,eventsTable.linkStateToModulesIndex-1 do
        eventsTable.linkStateToModules[i](state,stateTableKeys)
    end
end


eventsTable.onCentauriArrival = {}
eventsTable.onCentauriArrivalIndex = 1

function discreteEvents.performOnCentauriArrival(tribe)
    for i = 1,eventsTable.onCentauriArrivalIndex-1 do
        eventsTable.onCentauriArrival[i](tribe)
    end
end


eventsTable.onNegotiation = {}
eventsTable.onNegotiationIndex = 1

function discreteEvents.performOnNegotiation(talker,listener)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    -- in this case, false prevents negotiation
    local resultSoFar = true
    for i =1, eventsTable.onNegotiationIndex-1 do
        local currentResult = eventsTable.onNegotiation[i](talker,listener)
        if currentResult == nil then
            error('discreteEvents.performOnNegotiation: all discrete events registered by discreteEvents.onNegotiation must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end


eventsTable.onGameEnds = {}
eventsTable.onGameEndsIndex = 1

function discreteEvents.performOnGameEnds(reason)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    local resultSoFar = true
    for i =1, eventsTable.onGameEndsIndex-1 do
        local currentResult = eventsTable.onGameEnds[i](reason)
        if currentResult == nil then
            error('discreteEvents.performOnGameEnds: all discrete events registered by discreteEvents.onGameEnds must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end


eventsTable.onSchism = {}
eventsTable.onSchismIndex = 1

function discreteEvents.performOnSchism(tribe)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    -- in this case, false prevent schism
    local resultSoFar = true
    for i =1, eventsTable.onSchismIndex-1 do
        local currentResult = eventsTable.onSchism[i](tribe)
        if currentResult == nil then
            error('discreteEvents.performOnSchism: all discrete events registered by discreteEvents.onSchism must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end


eventsTable.onChooseSeason = {}
eventsTable.onChooseSeasonIndex = 1

function discreteEvents.performOnChooseSeason()
    for i=1, eventsTable.onChooseSeasonIndex-1 do
        eventsTable.onChooseSeason()
    end
end


eventsTable.onKeyPress = {}
eventsTable.onKeyPressIndex = 1

function discreteEvents.performOnKeyPress(keyId)
    for i=1, eventsTable.onKeyPressIndex-1 do
        eventsTable.onKeyPress[i](keyId)
    end
end


eventsTable.onCanFoundCity = {}
eventsTable.onCanFoundCityIndex = 1

function discreteEvents.performOnCanFoundCity(unit)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    local resultSoFar = true
    for i =1, eventsTable.onCanFoundCityIndex-1 do
        local currentResult = eventsTable.onCanFoundCity[i](unit)
        if currentResult == nil then
            error('discreteEvents.performOnCanFoundCity: all discrete events registered by discreteEvents.onCanFoundCity must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end


local registeredEventTypes =
[[
discreteEvents.onActivateUnit 
discreteEvents.onBribeUnit 
discreteEvents.onCityDestroyed 
discreteEvents.onCityFounded 
discreteEvents.onCityProduction 
discreteEvents.onCityTaken 
discreteEvents.onScenarioLoaded 
discreteEvents.onTurn 
discreteEvents.onUnitKilled 
discreteEvents.onUnitDefeated 
discreteEvents.onAfterProduction 
discreteEvents.onBeforeProduction 
discreteEvents.onCityProcessed
discreteEvents.linkStateToModules
discreteEvents.onCentauriArrival
discreteEvents.onNegotiation
discreteEvents.onGameEnds
discreteEvents.onChooseSeason
discreteEvents.onKeyPress
discreteEvents.onCityProcessingComplete
discreteEvents.onTribeTurnBegin
discreteEvents.onTribeTurnEnd
discreteEvents.onCanFoundCity
discreteEvents.onSchism
]]

local function newIndexFn(myTable,key,value)
    if eventsTable[key] then
        eventsTable[key][eventsTable[key.."Index"]]=value
        eventsTable[key.."Index"]=eventsTable[key.."Index"]+1
    else
        error("\ndiscreteEvents."..key.." is not a registered event type in discrete events.  These are the events that can be registered using discreteEvents:\n"..registeredEventTypes.."\nIf you desired event execution point isn't in this list, you can't register it as a discrete event.")
    end
end

local registeredEventCalls =
[[
discreteEvents.performOnActivateUnit 
discreteEvents.performOnBribeUnit 
discreteEvents.performOnCityDestroyed 
discreteEvents.performOnCityFounded 
discreteEvents.performOnCityProduction 
discreteEvents.performOnCityTaken 
discreteEvents.performOnScenarioLoaded 
discreteEvents.performOnTurn 
discreteEvents.performOnUnitKilled 
discreteEvents.performOnUnitDefeated 
discreteEvents.performOnAfterProduction 
discreteEvents.performOnBeforeProduction 
discreteEvents.performOnCityProcessed 
discreteEvents.performLinkStateToModules
discreteEvents.performOnCentauriArrival
discreteEvents.performOnNegotiation
discreteEvents.performOnGameEnds
discreteEvents.performOnChooseSeason
discreteEvents.performOnKeyPress
discreteEvents.performOnCityProcessingComplete
discreteEvents.performOnTribeTurnBegin
discreteEvents.performOnTribeTurnEnd
discreteEvents.performOnCanFoundCity
discreteEvents.performOnSchism
]]
local function indexFn(myTable,key)
    if discreteEvents[key] then
        return discreteEvents[key]
    else
        error("discreteEvents: discreteEvents."..key.." does not exist.  Perhaps you meant one of the following:\n"..registeredEventCalls)
    end
end


local superMetatable = {__index = indexFn,__newindex=newIndexFn}

local superTable = {version=moduleVersion, eventsTable=eventsTable}
setmetatable(superTable,superMetatable)

return superTable
