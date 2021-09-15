--  This file organizes the 'trigger events' of the scenario,
--  which is to say events that happen either at a specific time
--  or as a reaction to a specific action or trigger.
--
--  If you have a relatively small number of such events, you may
--  simply wish to define them all within this file.  However, if
--  you are designing a scenario with a large number of events,
--  you will probably find it more convenient to have events
--  in separate files depending on the 'trigger'.
--

--When designing with lua using this template, you're essentially "weaving a web" between different modules.
--Any given lua file that references any other needs to have the connection linked.  You do that with the 
--following lines:
local legacy = require("legacyEventEngine")
local delay = require("delayedAction")
local object = require("object")
local func = require("functions")
local civlua = require("civluaModified")
local param = require("parameters")
local gen = require("generalLibrary")
local civlua = require("civluaModified")
local flag = require("flag")
local diplomacy = require("diplomacy")
local log = require("log")
local triggerEvents = {}



-- getContext()-->integer
-- Returns the 'context' of the game, and chooses the context events that
-- will take place
-- 0 means there is no special context, and a function that
-- doesn't do anything is executed.

local function getContext()
    return 0
    --return 1
    --return 0
end

local function emptyFunction()
    return
end

-- contextFolders is the number of different folders labeled ContextX in
-- the ContextTriggerEvents folder

-- This allows you to change the names of your context folders
-- no gaps in numbers are allowed and you should have an entry for each context
local contextNames = {
    [1] = "Context1",
    [2] = "MainScenario",
}
local contextFolders = #contextNames


local triggerFileNames = {
"onTurn",
"afterProduction",
"beforeProduction",
"onUnitKilled",
"onCityTaken",
"onCityProduction",
"onCityDestroyed",
"onBribeUnit",
"onGameEnds",
"onCityFounded",
"onCentauriArrival",
"onCityProcessed",
}

local context = {[0]={}}
local universal = {}
for __,name in pairs(triggerFileNames) do
    local univ = require("UniversalTriggerEvents\\"..name)
    for funcName,func in pairs(univ) do
        universal[funcName] = func
        context[0][funcName] = emptyFunction
    end
    for i=1,contextFolders do
        context[i] = context[i] or {}
        local cont = require("ContextTriggerEvents\\"..contextNames[i].."\\"..name)
        for funcName,func in pairs(cont) do
            context[i][funcName] = func
        end
    end
end


--FUNCTIONS
--Sometimes its helpful to keep your functions that you'll reference later in the code near the top.  
--You can be as organized as you want.  
--THE SPECIFIC TRIGGERS
--Hereunder you'll find the specific triggers we discussed in the designer read me.
--Note that unlike macro.txt, where  you could, for example, have onTurn events all over the place,
--In lua, they must all be within the same function (in this example, triggerEvents.onTurn(turn).

function triggerEvents.onTurn(turn)
    context[getContext()]["onTurn"](turn)
    universal["onTurn"](turn)
    delay.doOnTurn(turn)
    legacy.onTurnEventsAndMaintenance(turn)

end 

-- This will only run when a unit is killed in combat (i.e. not when an event
-- 'kills' a unit)
-- note that if the aggressor loses, aggressor.location will not work
-- note: use loserLocation instead of loser.location, since loser.location doesn't work if the attacker loses
-- (the game returns a 'tile' off the map)
function triggerEvents.unitKilledInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->void
    context[getContext()]["unitKilledInCombat"](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    universal["unitKilledInCombat"](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
	
end

-- This will run any time a unit is killed, either in combat or by events
--
function triggerEvents.unitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    context[getContext()]["unitDefeated"](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    universal["unitDefeated"](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    legacy.doUnitKilledEvents(loser,winner)
    log.onUnitKilled(winner,loser)

end

-- this happens whenever a unit 'dies', regardless of combat, as long as it is not replaced
function triggerEvents.unitDeath(dyingUnit)
    context[getContext()]["unitDeath"](dyingUnit)
    universal["unitDeath"](dyingUnit)

end

-- this happens whenever a unit 'dies', but not through combat (or 'defeat')
function triggerEvents.unitDeathOutsideCombat(dyingUnit)
    context[getContext()]["unitDeathOutsideCombat"](dyingUnit)
    universal["unitDeathOutsideCombat"](dyingUnit)

end
-- this happens if a unit is deleted (either through combat death, or by some other event,
-- but not if the unit is disbanded)
-- If the unit isn't being replaced, replacingUnit is nil
function triggerEvents.unitDeleted(deletedUnit,replacingUnit)
    context[getContext()]["unitDeleted"](deletedUnit,replacingUnit)
    universal["unitDeleted"](deletedUnit,replacingUnit)

end


function triggerEvents.onCityProduction(city,prod)
    context[getContext()]["onCityProduction"](city,prod)
    universal["onCityProduction"](city,prod)
    legacy.doCityProductionEvents(city,prod)

end


function triggerEvents.afterProduction(turn,tribe)
    context[getContext()]["afterProduction"](turn,tribe)
    universal["afterProduction"](turn,tribe)
    delay.doAfterProduction(turn,tribe)
	
end 


function triggerEvents.beforeProduction(turn,tribe)
    context[getContext()]["beforeProduction"](turn,tribe)
    universal["beforeProduction"](turn,tribe)
	delay.doBeforeProduction(turn,tribe) -- at the moment this
    -- is an empty function, but we might want to use it,
    -- so it is here for future compatibility

	
end 



function triggerEvents.onCityTaken(city,defender)
    context[getContext()]["onCityTaken"](city,defender)
    universal["onCityTaken"](city,defender)
    legacy.doCityTakenEvents(city,defender)
	
end 


function triggerEvents.onCentauriArrival(tribe)
    context[getContext()]["onCentauriArrival"](tribe)
    universal["onCentauriArrival"](tribe)
    legacy.doAlphaCentauriArrivalEvents(tribe)

end

function triggerEvents.onCityDestroyed(city)
    context[getContext()]["onCityDestroyed"](city)
    universal["onCityDestroyed"](city)
    legacy.doCityDestroyedEvents(city)

end

function triggerEvents.onBribeUnit(unit,previousOwner)
    context[getContext()]["onBribeUnit"](unit,previousOwner)
    universal["onBribeUnit"](unit,previousOwner)
    legacy.doBribeUnitEvents(unit,previousOwner)

end

function triggerEvents.onGameEnds(reason)
    context[getContext()]["onGameEnds"](reason)
    universal["onGameEnds"](reason)
    return legacy.endTheGame(reason)
    --return true
end


function triggerEvents.onCityFounded(city)
    context[getContext()]["onCityFounded"](city)
    universal["onCityFounded"](city)

end

function triggerEvents.onCityProcessed(city)
    context[getContext()]["onCityProcessed"](city)
    universal["onCityProcessed"](city)

end

return triggerEvents
