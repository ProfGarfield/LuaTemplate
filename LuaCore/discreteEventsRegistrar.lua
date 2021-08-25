local discreteEvents = {}
local eventsTable = {}




eventsTable.onActivateUnit = {}
eventsTable.onActivateUnitIndex = 1

function discreteEvents.performOnActivateUnit(unit,source)
    for i = 1,eventsTable.onActivateUnitIndex-1 do
        eventsTable.onActivateUnit[i](unit,source)
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
    for i = 1,eventsTable.onCityFoundedIndex-1 do
        eventsTable.onCityFounded[i](city)
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

eventsTable.afterProduction = {}
eventsTable.afterProductionIndex = 1

function discreteEvents.performAfterProduction(turn,tribe)
    for i = 1,eventsTable.afterProductionIndex-1 do
        eventsTable.afterProduction[i](turn,tribe)
    end
end

eventsTable.beforeProduction = {}
eventsTable.beforeProductionIndex = 1

function discreteEvents.performBeforeProduction(turn,tribe)
    for i = 1,eventsTable.beforeProductionIndex-1 do
        eventsTable.beforeProduction[i](turn,tribe)
    end
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
discreteEvents.afterProduction 
discreteEvents.beforeProduction 
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
discreteEvents.performAfterProduction 
discreteEvents.performBeforeProduction 
]]
local function indexFn(myTable,key)
    if discreteEvents[key] then
        return discreteEvents[key]
    else
        error("discreteEvents: discreteEvents."..key.." does not exist.  Perhaps you meant one of the following:\n"..registeredEventCalls)
    end
end


local superMetatable = {__index = indexFn,__newindex=newIndexFn}

local superTable = {}
setmetatable(superTable,superMetatable)

return superTable
